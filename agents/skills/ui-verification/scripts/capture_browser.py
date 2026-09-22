#!/usr/bin/env python3
"""
capture_browser.py - Hyprland browser window capture utility.

Finds open browser windows (all Firefox and Chromium derivatives) matching
a specific URL/port (e.g. localhost:8080) or page title, brings them into focus,
captures them via grimblast, and restores focus to the original active window.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time
from urllib.parse import urlparse

# Recognizes known Firefox and Chromium derivatives
BROWSER_REGEX = re.compile(
    r"(firefox|zen|librewolf|floorp|waterfox|mullvad|tor-browser|ladybird|"
    r"chrome|chromium|brave|vivaldi|edge|opera|thorium|arc|browser)",
    re.IGNORECASE
)

def get_clients():
    try:
        raw = subprocess.check_output(["hyprctl", "clients", "-j"], stderr=subprocess.DEVNULL)
        return json.loads(raw.decode("utf-8"))
    except Exception as e:
        print(f"Error fetching Hyprland clients: {e}", file=sys.stderr)
        return []

def get_active_window():
    try:
        raw = subprocess.check_output(["hyprctl", "activewindow", "-j"], stderr=subprocess.DEVNULL)
        return json.loads(raw.decode("utf-8"))
    except Exception:
        return {}

def is_browser(client):
    cls = client.get("class", "")
    init_cls = client.get("initialClass", "")
    return bool(BROWSER_REGEX.search(cls) or BROWSER_REGEX.search(init_cls))

def normalize_query(query):
    """Extract patterns to search for from a URL or title query."""
    q = query.strip()
    patterns = [q.lower()]
    
    # If query looks like a URL
    if "://" in q or q.startswith("localhost") or ":" in q:
        url = q if "://" in q else f"http://{q}"
        try:
            parsed = urlparse(url)
            netloc = parsed.netloc or parsed.path
            patterns.append(netloc.lower())
            if ":" in netloc:
                host, port = netloc.split(":", 1)
                patterns.append(port)
                patterns.append(f":{port}")
                patterns.append(f"{host}:{port}".lower())
            if parsed.path and parsed.path != "/":
                patterns.append(parsed.path.lstrip("/").lower())
        except Exception:
            pass
    return list(dict.fromkeys(patterns))  # deduplicate preserving order

def find_matching_browser(clients, query=None):
    browser_clients = [c for c in clients if is_browser(c)]
    other_clients = [c for c in clients if not is_browser(c)]

    if not query:
        # If no query, return the first browser or active client
        return browser_clients[0] if browser_clients else (clients[0] if clients else None)

    patterns = normalize_query(query)

    # 1. Look for browser clients matching the search patterns in title or initialTitle
    for pat in patterns:
        for c in browser_clients:
            title = (c.get("title") or "").lower()
            init_title = (c.get("initialTitle") or "").lower()
            if pat in title or pat in init_title:
                return c

    # 2. Look across ANY client matching the patterns
    for pat in patterns:
        for c in other_clients:
            title = (c.get("title") or "").lower()
            init_title = (c.get("initialTitle") or "").lower()
            if pat in title or pat in init_title:
                return c

    # 3. Fallback: query might be a browser class name (e.g. "firefox", "zen", "chrome")
    q_low = query.lower()
    for c in browser_clients:
        cls = (c.get("class") or "").lower()
        if q_low in cls:
            return c

    return None

def focus_window_by_address(addr):
    """Focuses a window address using Hyprland Lua repl or fallback dispatcher."""
    # Attempt 1: Lua repl focus (handles multi-workspace dispatch cleanly on Hyprland Lua)
    lua_code = (
        f'for _, w in ipairs(hl.get_windows()) do '
        f'if tostring(w):lower():find("{addr.lower()}", 1, true) then '
        f'hl.dispatch(hl.dsp.focus({{ window = w }})); return "ok" end end; return "fail"\n'
    )
    try:
        res = subprocess.run(["hyprctl", "repl"], input=lua_code, capture_output=True, text=True, timeout=3)
        if "ok" in res.stdout:
            return True
    except Exception:
        pass

    # Attempt 2: Standard hyprctl dispatch
    try:
        subprocess.run(["hyprctl", "dispatch", "focuswindow", f"address:{addr}"], capture_output=True, timeout=3)
        return True
    except Exception:
        pass

    return False

def main():
    parser = argparse.ArgumentParser(
        description="Find and capture browser windows (Firefox & Chromium derivatives) in Hyprland."
    )
    parser.add_argument("query", nargs="?", default="", help="URL, port, or title substring to match (e.g. 'localhost:8080', 'vite')")
    parser.add_argument("-o", "--output", default="/tmp/ui-verify.png", help="Output file path (default: /tmp/ui-verify.png)")
    parser.add_argument("-w", "--wait", type=float, default=0.35, help="Delay in seconds after focus before capture (default: 0.35)")
    parser.add_argument("--no-restore", action="store_true", help="Do not restore focus to the previously active window")
    parser.add_argument("-l", "--list", action="store_true", help="List all open browser windows and exit")

    args = parser.parse_args()
    clients = get_clients()

    if args.list:
        print("Discovered Open Windows:")
        for c in clients:
            browser_flag = "[BROWSER]" if is_browser(c) else "         "
            print(f" {browser_flag} {c.get('address')} | WS {c.get('workspace', {}).get('name')} | {c.get('class')} | {c.get('title')}")
        return 0

    target = find_matching_browser(clients, args.query)
    if not target:
        print(f"Error: No window found matching query '{args.query}'.", file=sys.stderr)
        print("\nCurrently open windows:", file=sys.stderr)
        for c in clients:
            b_mark = "(Browser)" if is_browser(c) else ""
            print(f"  - {c.get('class')} {b_mark}: \"{c.get('title')}\" [Addr: {c.get('address')}]", file=sys.stderr)
        return 1

    orig_win = get_active_window()
    orig_addr = orig_win.get("address")

    target_addr = target.get("address")
    target_title = target.get("title")
    target_class = target.get("class")
    print(f"Targeting: {target_class} - \"{target_title}\" ({target_addr})")

    # Focus target window
    focus_window_by_address(target_addr)
    time.sleep(args.wait)

    # Capture with grimblast
    output_path = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    try:
        subprocess.run(["grimblast", "save", "active", output_path], check=True)
        print(f"Successfully captured screenshot: {output_path}")
    except Exception as e:
        print(f"Failed to capture screenshot with grimblast: {e}", file=sys.stderr)
        return 1
    finally:
        # Restore focus
        if not args.no_restore and orig_addr and orig_addr != target_addr:
            focus_window_by_address(orig_addr)

    return 0

if __name__ == "__main__":
    sys.exit(main())
