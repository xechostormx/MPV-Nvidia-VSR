-- scripts/screenshotfolder.lua
-- Cleaned version: no more 1 Hz spam

local options = {
    screenshot_key           = 's',
    file_ext                 = "jpg",
    save_location            = "~~desktop/mpv/screenshots/",
    time_stamp_format        = "%tY-%tm-%td_%tH-%tM-%tS",
    save_as_time_stamp       = true,
    save_based_on_chapter_name = false,
    short_saved_message      = true,
    include_YouTube_ID       = true
}
require "mp.options".read_options(options)

local title            = "default"
local chaptername      = ""
local count            = 0
local current_format   = options.file_ext

-- Builds & applies directory + template + format
local function set_screenshot_template()
    local function safe(name) return name:gsub('[\\/:*?"<>|]', '') end

    mp.set_property("screenshot-format", current_format)

    local subdir = options.save_location .. safe(title) .. "/"
    mp.set_property("screenshot-directory", subdir)

    if options.save_as_time_stamp then
        local suffix = (count > 0) and ("(" .. count .. ")") or ""
        if options.save_based_on_chapter_name and chaptername ~= "" then
            mp.set_property("screenshot-template",
                safe(chaptername) .. " (" .. options.time_stamp_format .. ")" .. suffix)
        else
            mp.set_property("screenshot-template",
                options.time_stamp_format .. suffix)
        end
    end
end

-- Called on file load or when chapter metadata changes
local function init()
    -- Determine title (with YouTube ID if URL)
    local path = mp.get_property("path") or ""
    local name = mp.get_property("filename/no-ext") or ""
    local media = mp.get_property("media-title") or name

    if media:match("^[%w]+://") and options.include_YouTube_ID then
        local vid = mp.get_property("filename"):match("[?&]v=([^&]+)")
        if vid then media = media .. " [" .. vid .. "]" end
    end
    title = media

    count = 0
    set_screenshot_template()
end

-- Called when you hit the screenshot key
local function screenshot_done()
    mp.commandv("screenshot")
    count = count + 1
    set_screenshot_template()

    if options.short_saved_message then
        mp.osd_message("Screenshot saved", 2)
    else
        local dir = mp.command_native({"expand-path", "~~" .. mp.get_property("screenshot-directory")})
            :gsub("\\", "/")
        mp.osd_message("Saved to: " .. dir, 2)
    end
end

-- Update on chapter changes (optional)
mp.observe_property("chapter-metadata/title", "string", function(_, v)
    chaptername = v or ""
    set_screenshot_template()
end)

-- Only run on file load/start-file
mp.register_event("start-file", init)
mp.register_event("file-loaded", init)

-- Bind screenshot key
mp.add_key_binding(options.screenshot_key, "screenshot-done", screenshot_done)
