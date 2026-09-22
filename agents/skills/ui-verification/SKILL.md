---
name: ui-verification
description: >-
  Verify and inspect UI, web applications, GUI apps, desktop widgets, or styling
  on Hyprland using grimblast screenshots and browser window discovery. Use whenever
  developing, styling, or testing user interfaces to visually inspect and validate changes.
---

# UI Visual Verification (Hyprland, grimblast & browser discovery)

This skill provides procedures for capturing and visually inspecting rendered UI components on Hyprland, including targeting browser windows hosting local development servers (e.g. `localhost:8080`, `localhost:5173`, `localhost:3000`).

## When to Use
- Developing or styling web pages, web applications, or frontends.
- Verifying a local web dev server running in a browser window.
- Modifying desktop shell elements, Hyprland widgets, Waybar, Agsv, or GTK/Qt applications.
- Verifying bug fixes related to layout, rendering, font rendering, clipping, or contrast.

---

## Browser Window Discovery & Capture (Web Apps)

When verifying a local development site or URL, you do not need the browser window to be currently active. Use the bundled script:
`~/.agents/skills/ui-verification/scripts/capture_browser.py` (or `capture-browser-ui` in `$PATH`).

### Supported Browsers
Works with all major browser families in Hyprland:
- **Firefox Derivatives**: Zen Browser (`app.zen_browser.zen`), Mozilla Firefox, LibreWolf, Floorp, Waterfox, Mullvad Browser, Tor Browser.
- **Chromium Derivatives**: Google Chrome, Chromium, Brave Browser, Microsoft Edge, Vivaldi, Opera, Thorium, Arc.

### Usage
```bash
# Capture a site by URL / host & port:
capture-browser-ui "localhost:8080" -o /tmp/ui-verify.png

# Capture by port only:
capture-browser-ui "8080" -o /tmp/ui-verify.png

# Capture by tab or page title:
capture-browser-ui "Dashboard" -o /tmp/ui-verify.png

# List all open browser clients and their window titles:
capture-browser-ui --list

# Keep the browser focused (do not restore focus back to terminal):
capture-browser-ui "localhost:8080" --no-restore
```

**How it works:**
1. Queries Hyprland clients (`hyprctl clients -j`) to identify the browser window matching the URL, port, or title pattern.
2. Dispatches focus to the window (switching to its workspace if necessary).
3. Waits for the compositor to render the frame (default 0.35s).
4. Captures the window geometry using `grimblast save active <OUTPUT_PATH>`.
5. Restores focus back to the original active window seamlessly.

---

## Desktop & Native App Capture

For native applications, status bars, or desktop widgets:

- **Active Application Window**:
  ```bash
  grimblast save active /tmp/ui-verify.png
  ```
- **Active Output / Monitor** (full screen view):
  ```bash
  grimblast save output /tmp/ui-verify.png
  ```
- **With a Settle Delay** (for animations, transitions, or page loads):
  ```bash
  grimblast --wait 1 save active /tmp/ui-verify.png
  ```

---

## Inspection and Quality Checklist

Open and inspect the captured image using your file viewing tool:
```text
view_file /tmp/ui-verify.png
```

Check the rendered image for:
- **Layout Integrity**: Text clipping, overflowing containers, broken flex/grid alignment, unexpected line breaks.
- **Visual Polish**: Font sizing and weights, spacing/padding balance, color contrast, border radiuses.
- **Component States**: Hover states, active tabs, modal overlays, dropdowns, and button styling.

### Cleanup
Once verified, remove temporary screenshot files:
```bash
rm /tmp/ui-verify.png
```
