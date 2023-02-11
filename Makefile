#### Install routine for moonraker-timelapse
####
#### https://github.com/mainsail-crew/moonraker-timelapse
####
#### Copyright 2023 till today
####
###############################################################################
####
#### Self documenting Makefile
#### Based on https://www.freecodecamp.org/news/self-documenting-makefile/
#### ##########################################################################


.PHONY: help
.DEFAULT_GOAL := help




















update: ## Update moonraker-timelapse
	@git fetch && git pull
	@printf "Please restart moonrakerto take changes effect ..."



help: ## Show this help
	@printf "Welcome to moonraker-timelapse installer\n"
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
