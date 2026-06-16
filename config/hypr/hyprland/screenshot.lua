local M = {}

local screenshot_dir = (os.getenv("XDG_PICTURES_DIR") or (os.getenv("HOME") .. "/Pictures")) .. "/Screenshots"

local check_grim =
    "if ! command -v grimblast >/dev/null 2>&1; then notify-send \"Error\" \"grimblast is required\"; exit 1; fi; "

local function header()
    local dir = screenshot_dir
    return string.format(
        "DIR=\"%s\"; mkdir -p \"$DIR\"; PICNAME=\"Screenshot $(date '+%%Y-%%m-%%d %%H%%M%%S').png\"; PICPATH=\"$DIR/$PICNAME\"; ",
        dir)
end

local function save_and_notify(grimblast_args)
    return header() ..
        string.format("grimblast copysave %s \"$PICPATH\" && notify-send \"Screenshot saved\" \"$PICPATH\" --icon=\"$PICPATH\" && (command -v wl-copy >/dev/null && wl-copy < \"$PICPATH\" || true)",
            grimblast_args)
end

local function edit_cmd()
    return "TMP=\"/tmp/$(whoami)-snip.png\"; grimblast save area \"$TMP\" && (command -v swappy >/dev/null && swappy -f \"$TMP\" || notify-send \"Error\" \"swappy is required for edit mode\"); rm \"$TMP\""
end

local function ocr_cmd()
    return "TMP=\"/tmp/$(whoami)-snip.png\"; grimblast save area \"$TMP\" && (command -v tesseract >/dev/null && tesseract -l eng \"$TMP\" - | wl-copy && notify-send \"Screenshot\" \"OCR copied to clipboard\" || notify-send \"Error\" \"tesseract is required for OCR mode\"); rm \"$TMP\""
end

local modes = {
    area   = check_grim .. save_and_notify("area"),
    screen = check_grim .. save_and_notify("screen"),
    edit   = check_grim .. edit_cmd(),
    ocr    = check_grim .. ocr_cmd(),
}

for name, cmd in pairs(modes) do
    M[name] = cmd
end

return M
