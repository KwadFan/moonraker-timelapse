#!/usr/bin/env bash
#### Moonraker Timelapse component uninstaller
####
#### Copyright (C) 2021 till today Christoph Frei <fryakatkop@gmail.com>
#### Copyright (C) 2021 till today Stephan Wendel aka KwadFan <me@stephanwe.de>
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
### END

## Find SRCDIR from the pathname of this script
SRC_DIR="$( cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"/ && pwd )"
### END

## Initialize global vars and arrays
DATA_DIR=()
DEPENDS_ON=( moonraker klipper )
MOONRAKER_TARGET_DIR="${HOME}/moonraker/moonraker/components"
SERVICES=()
### END

## Helper funcs
### Ask for proceding install (Step 2)
function continue_install() {
    local reply
    while true; do
        read -erp "Would you like to proceed? [Y/n]: " -i "Y" reply
        case "${reply}" in
            [Yy]* )
                break
            ;;
            [Nn]* )
                abort_msg ### See Error messages
                exit 0
            ;;
            * )
                printf "\033[31mERROR: Please type Y or N !\033[0m"
            ;;
        esac
    done
}
### END

### Initial check func (Step 3)
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
### END

### Service related funcs (Step 4)
function get_service_names() {
    for i in "${DEPENDS_ON[@]}"; do
        sudo systemctl list-units --full --all -t service --no-legend \
        | grep "${i}*" | awk -F" " '{print $1}'
    done
}

function set_service_name_array() {
    while read -r service ; do
        SERVICES+=("${service}")
    done < <(get_service_names)
}

function stop_services() {
    local service
    ## Create services array
    set_service_name_array
    ## Dsiplay header message
    stop_service_header_msg
    ## Stop services
    for service in "${SERVICES[@]}"; do
        stop_service_msg "${service}"
        if sudo systemctl -q is-active "${service}"; then
            sleep 1
            sudo systemctl stop "${service}"
            service_stopped_msg
        else
            service_not_active_msg
        fi
    done
}

function start_services() {
    local service
    ## Dsiplay header message
    start_service_header_msg
    ## Stop services
    for service in "${SERVICES[@]}"; do
        start_service_msg "${service}"
        if ! sudo systemctl -q is-active "${service}"; then
            sleep 1
            sudo systemctl start "${service}"
            service_started_msg
        else
            service_start_failed_msg
        fi
    done
}
### END

# Get Instance names, also used for single instance installs
function get_instance_names() {
    local instances path
    instances="$(find "${HOME}" -maxdepth 1 -type d -name "*_data" -printf "%P\n")"
    while read -r path ; do
        DATA_DIR+=("${path}")
    done <<< "${instances}"
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

### Welcome message (Step 1)
function welcome_msg() {
    printf "\n\033[31mAhoi!\033[0m\n"
    printf "moonraker-timelapse install routine\n"
    printf "\n\tThis will take some time ...\n\tYou'll be prompted for sudo password if needed!\n"
    printf "\n\033[31m#################### WARNING #####################\033[0m\n"
    printf "Make sure you are \033[31mnot\033[0m printing during install!\n"
    printf "All related services will be stopped!\n"
    printf "\033[31m##################################################\033[0m\n\n"
}

### Dependencie messages
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
### END

### Service related msg
function stop_service_header_msg() {
    printf "Stopping related service(s) ... \n"
}

function stop_service_msg() {
    printf "Stopping service '%s' ... " "${1}"
}

function service_stopped_msg() {
    printf "[\033[32mOK\033[0m]\n"
}

function service_not_active_msg() {
    printf "[\033[31mNOT ACTIVE\033[0m]\n"
}

function start_service_header_msg() {
    printf "Starting related service(s) ... \n"
}

function start_service_msg() {
    printf "Starting service '%s' ... " "${1}"
}

function service_started_msg() {
    printf "[\033[32mOK\033[0m]\n"
}

function service_start_failed_msg() {
    printf "[\033[31mFAILED\033[0m]\n"
}
### END

### Error messages
function install_first_msg() {
    printf "Please install '%s' first! [\033[31mEXITING\033[0m]\n" "${1}"
    exit 1
}

function abort_msg() {
    printf "Install aborted by user ... \033[31mExiting!\033[0m\n"
}

# function reboot_declined_msg() {
#     printf "\nRemember all service are stopped!\nReboot or start them by hand ...\n"
#     printf "GoodBye ...\n"
# }
### END

### Install finished message(s)
function finished_install_msg() {
    printf "\nmoonraker-timelapse \033[32msuccessful\033[0m installed ...\n"
    printf "\033[34mHappy printing!\033[0m\n"
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
stop_services

# Step 5: Determine data structure

# Step 6: Link component to $MOONRAKER_TARGET_DIR

# Step 7: Link timelapse.cfg to $INSTANCE

# Step 8: Restart services
start_services

# Step 9: Print finish message
finished_install_msg

}

## MAIN

main
exit 0

###### EOF ######

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







# # Run steps
# stop_klipper
# stop_moonraker
# link_extension
# restart_services
# check_ffmpeg

# # If something checks status of install
# exit 0
