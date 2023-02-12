#!/usr/bin/env bash
#### Moonraker Timelapse component uninstaller
####
#### Copyright (C) 2021 Christoph Frei <fryakatkop@gmail.com>
#### Copyright (C) 2021 Stephan Wendel aka KwadFan <me@stephanwe.de>
####
#### This file may be distributed under the terms of the GNU GPLv3 license.
####

# shellcheck enable=require-variable-braces

## Error handling
set -Ee

## Debug Option
set -x

# Find SRCDIR from the pathname of this script
SRC_DIR="$( cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"/ && pwd )"

## Helper funcs

# Check if ffmpeg is installed, returns path if installed
function ffmpeg_installed() {
    local path
    path="$(command -v ffmpeg)"
    if [[ -n "${path}" ]]; then
        echo "${path}"
    fi
}

# Default Parameters
MOONRAKER_TARGET_DIR="${HOME}/moonraker/moonraker/components"
DATA_DIR=( "$(find "${HOME}" -maxdepth 1 -type d -name "*_data" -printf "%P ")" )
FFMPEG_BIN="$(ffmpeg_installed)"
DEPENDS_ON=( moonraker klipper )


echo "${DATA_DIR[@]}"
dirname "${SRC_DIR}"

# function stop_klipper() {
#     if [ "$(sudo systemctl list-units --full --all -t service --no-legend | grep -F "klipper.service")" ]; then
#         echo "Klipper service found! Stopping during Install."
#         sudo systemctl stop klipper
#     else
#         echo -e "${RED}Error:${NC} Klipper service not found, please install Klipper first\nNOTE: If you use multiple instances of klipper you need to create the symlinks manually for now! see Github issue #13 for further information"
#         exit 1
#     fi
# }

# function stop_moonraker() {
#     if [ "$(sudo systemctl list-units --full --all -t service --no-legend | grep -F "moonraker.service")" ]; then
#         echo "Moonraker service found! Stopping during Install."
#         sudo systemctl stop moonraker
#     else
#         echo "Moonraker service not found, please install Moonraker first"
#         exit 1
#     fi
# }

# function link_extension() {
#     if [ -d "${MOONRAKER_TARGET_DIR}" ]; then
#         echo "Linking extension to moonraker..."
#         ln -sf "${SRCDIR}/component/timelapse.py" "${MOONRAKER_TARGET_DIR}/timelapse.py"
#     else
#         echo -e "ERROR: ${MOONRAKER_TARGET_DIR} not found."
#         echo -e "Please Install moonraker first!\nExiting..."
#         exit 1
#     fi
#     if [ -d "${KLIPPER_CONFIG_DIR}" ]; then
#         echo "Linking macro file..."
#         ln -sf "${SRCDIR}/klipper_macro/timelapse.cfg" "${KLIPPER_CONFIG_DIR}/timelapse.cfg"
#     else
#         echo -e "ERROR: ${KLIPPER_CONFIG_DIR} not found."
#         echo -e "Try:\nUsage: ${0} -c /path/to/klipper_config\nExiting..."
#         exit 1
#     fi
# }


# function restart_services() {
#     echo "Restarting Moonraker..."
#     sudo systemctl restart moonraker
#     echo "Restarting Klipper..."
#     sudo systemctl restart klipper
# }


# function check_ffmpeg() {

#     if [ ! -f "$FFMPEG_BIN" ]; then
#         echo -e "${YELLOW}WARNING: FFMPEG not found in '${FFMPEG_BIN}'. Render will not be possible!${NC}\nPlease install FFMPEG running:\n\n  sudo apt install ffmpeg\n\nor specify 'ffmpeg_binary_path' in moonraker.conf in the [timelapse] section if ffmpeg is installed in a different directory, to use render functionality"
# 	fi

# }


# ### MAIN

# # Parse command line arguments
# while getopts "c:h" arg; do
#     if [ -n "${arg}" ]; then
#         case $arg in
#             c)
#                 KLIPPER_CONFIG_DIR=$OPTARG
#                 break
#             ;;
#             [?]|h)
#                 echo -e "\nUsage: ${0} -c /path/to/klipper_config"
#                 exit 1
#             ;;
#         esac
#     fi
#     break
# done

# # Run steps
# stop_klipper
# stop_moonraker
# link_extension
# restart_services
# check_ffmpeg

# # If something checks status of install
# exit 0
