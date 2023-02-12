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
# set -x

### Check non-root
if [[ ${UID} = "0" ]]; then
    printf "\n\tYOU DONT NEED TO RUN INSTALLER AS ROOT!\n"
    printf "\tYou will be prompted for sudo password if needed!\nExiting...\n"
    exit 1
fi


# Find SRCDIR from the pathname of this script
SRC_DIR="$( cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"/ && pwd )"

# Initialize global vars and arrays
DATA_DIR=()
DEPENDS_ON=( moonraker klipper )
MOONRAKER_TARGET_DIR="${HOME}/moonraker/moonraker/components"

## Helper funcs

# Get Instance names, also used for single instance installs
function get_instance_names() {
    local instances path
    instances="$(find "${HOME}" -maxdepth 1 -type d -name "*_data" -printf "%P\n")"
    while read -r path ; do
        DATA_DIR+=("${path}")
    done <<< "${instances}"
}

function initial_check() {
    dep_check_msg
    for i in "${DEPENDS_ON[@]}"; do
        if [[ -d "${HOME}/${i}" ]]; then
            dep_found_msg "${i}"
        fi
        if [[ ! -d "${HOME}/${i}" ]]; then
            dep_not_found_msg "${i}"
        fi
    done
}

# Ask for proceding
function continue_install() {
    local reply
    while true; do
        read -erp "Would you like to proceed? [Y/n]: " -i "Y" reply
        case "${reply}" in
            [Yy]* )
                break
            ;;
            [Nn]* )
                abort_msg
                exit 0
            ;;
            * )
                printf "\033[31mERROR: Please type Y or N !\033[0m"
            ;;
        esac
    done
}

# Ask for proceding
function ask_to_reboot() {
    local reply
    finished_install_msg
    while true; do
        read -erp "Would you like to proceed? [Y/n]: " -i "Y" reply
        case "${reply}" in
            [Yy]* )
                sudo reboot
            ;;
            [Nn]* )
                reboot_msg
                exit 0
            ;;
            * )
                printf "\033[31mERROR: Please type Y or N !\033[0m"
            ;;
        esac
    done
}

# Check if ffmpeg is installed, returns path if installed
function ffmpeg_installed() {
    local path
    path="$(command -v ffmpeg)"
    if [[ -n "${path}" ]]; then
        echo "${path}"
    fi
}

function link_component() {
    if [ -d "${MOONRAKER_TARGET_DIR}" ]; then
        echo "Linking extension to moonraker..."
        ln -sf "${SRC_DIR}/component/timelapse.py" "${MOONRAKER_TARGET_DIR}/timelapse.py"
    else
        echo -e "ERROR: ${MOONRAKER_TARGET_DIR} not found."
        echo -e "Please Install moonraker first!\nExiting..."
        exit 1
    fi
}

## Message helper funcs
function welcome_msg() {
    printf "\n\033[31mAhoi!\033[0m\n"
    printf "moonraker-timelapse install routine\n"
    printf "\n\tThis will take some time ...\n"
    printf "\n\033[31m#################### WARNING #####################\033[0m\n"
    printf "Make sure you are \033[31mnot\033[0m printing during install!\n"
    printf "All related services will be stopped!\n"
    printf "\033[31m##################################################\033[0m\n\n"
}

function abort_msg() {
    printf "Install aborted by user ... \033[31mExiting!\033[0m\n"
}

function dep_check_msg() {
    printf "Check for dependencies to use moonraker-timelapse ...\n"
}

function dep_found_msg() {
    printf "Dependency '%s' found ... [\033[32mOK\033[0m]\n" "${1}"
}

function dep_not_found_msg() {
    printf "Dependency '%s' not found ... [\033[31mFAILED\033[0m]\n" "${1}"
    install_first_msg "${1}"
}

function install_first_msg() {
    printf "Please install '%s' first! [\033[31mEXITING\033[0m]\n" "${1}"
    exit 1
}

function finished_install_msg() {
    printf "\nmoonraker-timelapse \033[32msuccessful\033[0m installed ...\n"
}

function reboot_msg() {
    printf "\nRemember all service are stopped!\nReboot or start them by hand ...\n"
    printf "GoodBye ...\n"
}


# Default Parameters
function main() {

# Step 1: Print welcome message
welcome_msg

# Step 2: Ask to proceed
continue_install

# Step 3: Initial checks for dependencies (klipper/moonraker)
initial_check

# Step 4: Stop related services

# Step 5: Determine data structure

# Step 6: Link component to $MOONRAKER_TARGET_DIR

# Step 7: Link timelapse.cfg to $INSTANCE

# Step 8: ask for reboot
ask_to_reboot

}

main
exit 0



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
#
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
