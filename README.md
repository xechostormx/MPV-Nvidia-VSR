🧠 Overview

This setup is built for users who have Nvidia RTX Video Super Resolution (VSR) enabled in the Nvidia Control Panel. It includes:

    A streamlined mpv.conf optimized for modern GPUs

    A custom Lua script that triggers VSR after 3 seconds of playback

    Font and UI tweaks for a clean, modern look

    Fully portable structure with optional system integration

⚙️ Installation & Usage

✅ To install:

    Run 1_Full_Latest_MPV_Installer.ps1

        Installs the latest versions of MPV, FFmpeg, and yt-dlp

        Fully portable, no admin required

    Run 2_Register_MPV_SANELY_Add_PATH.ps1 (optional)

        Adds MPV to system PATH

        Registers MPV for “Open With” functionality

        Requires admin, will auto detect and prompt

    Run 3_Add_Supported_Filetypes_To_Open_With.ps1 (optional)

        Adds common media formats to MPV’s Open With list

        Requires admin, will auto detect and prompt

🔄 To uninstall:

    Run X1_Unregister_MPV_SANELY_REMOVE_PATH.ps1

        Removes PATH entry and Open With registration

    Run X2_Remove_Supported_File_types_From_Open_With.ps1

        Removes filetype associations
        

🔁 To update:

        Simply run 1_Full_Latest_MPV_Installer.ps1

        Updates MPV, FFmpeg, and yt-dlp

        No need to re-run 2 or 3 unless you’ve uninstalled

📁 Folder Structure

All scripts and configuration files are contained in the portable_config folder.
This includes:

    mpv.conf

    input.conf

    fonts.conf

    Lua scripts

    Shader presets

    Font assets

🎯 Features

    Base: ModernZ

    Fonts: ModernZ + Netflix Medium (default), with light and bold variants included

    Upscaling: RTX VSR script activates after 3 seconds, auto-upscales to native resolution

    UI: Borders enabled by default

    Playback: High-quality defaults tuned for RTX hardware
    

📌 Notes

    All scripts are silent, reversible, and require no user input except to exit

    Designed for Windows 10/11 with PowerShell 3+ (written for 7)

    No registry bloat, no filetype hijacking, no start menu shortcuts

