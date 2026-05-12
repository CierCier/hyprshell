local M = {}

local screenshot_dir = (os.getenv("XDG_PICTURES_DIR") or (os.getenv("HOME") .. "/Pictures")) .. "/Screenshots"

local function get_cmd(mode)
    local dir = screenshot_dir
    local base_cmd = string.format(
        "DIR=\"%s\"; mkdir -p \"$DIR\"; PICNAME=\"Screenshot $(date '+%%Y-%%m-%%d %%H%%M%%S').png\"; PICPATH=\"$DIR/$PICNAME\"; ",
        dir)
    local check_grim =
    "if ! command -v grimblast >/dev/null 2>&1; then notify-send \"Error\" \"grimblast is required\"; exit 1; fi; "

    if mode == "area" then
        return check_grim ..
            base_cmd ..
            "grimblast copysave area \"$PICPATH\" && notify-send \"Screenshot saved\" \"$PICPATH\" --icon=\"$PICPATH\" && (command -v wl-copy >/dev/null && wl-copy < \"$PICPATH\" || true)"
    elseif mode == "screen" then
        return check_grim ..
            base_cmd ..
            "grimblast copysave screen \"$PICPATH\" && notify-send \"Screenshot saved\" \"$PICPATH\" --icon=\"$PICPATH\" && (command -v wl-copy >/dev/null && wl-copy < \"$PICPATH\" || true)"
    elseif mode == "edit" then
        return check_grim ..
            "TMP=\"/tmp/$(whoami)-snip.png\"; grimblast save area \"$TMP\" && (command -v swappy >/dev/null && swappy -f \"$TMP\" || notify-send \"Error\" \"swappy is required for edit mode\"); rm \"$TMP\""
    elseif mode == "ocr" then
        return check_grim ..
            "TMP=\"/tmp/$(whoami)-snip.png\"; grimblast save area \"$TMP\" && (command -v tesseract >/dev/null && tesseract -l eng \"$TMP\" - | wl-copy && notify-send \"Screenshot\" \"OCR copied to clipboard\" || notify-send \"Error\" \"tesseract is required for OCR mode\"); rm \"$TMP\""
    end
end

M.area = get_cmd("area")
M.screen = get_cmd("screen")
M.edit = get_cmd("edit")
M.ocr = get_cmd("ocr")

return M
