function apply_vsr()
    -- Get properties
    local display_width = mp.get_property_native("display-width")
    local display_height = mp.get_property_native("display-height")
    local video_width = mp.get_property_native("width")
    local video_height = mp.get_property_native("height")
    local pixfmt = mp.get_property_native("video-params/hw-pixelformat") or mp.get_property_native("video-params/pixelformat")

    if video_width and display_width then
        -- Calculate scale factor (e.g., 1080p to 4K = ~2)
        local scale = math.max(display_width, display_height) / math.max(video_width, video_height)
        scale = scale - (scale % 0.1)  -- Round down to nearest 0.1

        -- Remove existing VSR filter if present
        if string.match(mp.get_property("vf"), "@vsr") then
            mp.command("vf remove @vsr")
        end

        -- Apply only if upscale needed and compatible format
        if scale > 1 and (pixfmt == "nv12" or pixfmt == "yuv420p") then
            mp.command("vf append @vsr:d3d11vpp:scaling-mode=nvidia:scale=" .. scale)
        end
    end
end

function delayed_apply()
    mp.add_timeout(3, apply_vsr)
end

-- Observe properties to trigger on changes
mp.observe_property("video-params/pixelformat", "native", delayed_apply)
mp.observe_property("vf", "native", delayed_apply)