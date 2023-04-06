#!/bin/bash

# ANSI escapes
RED='\033[31m'
GREEN='\033[32m'
BOLD='\033[1m'
ITALIC='\033[3m'
STRIKETHROUGH='\033[9m'
RESET='\033[0m'

# usage: repeat character number
# example: repeat = 10
# output: ==========
repeat() {
  	for ((i = 1; i < $2; i++)); do
    		echo -n "$1"
  	done
}

# usage: step text command
# example: step "echoing hey" "echo hey"
# output:
# echoing hey...
# hey
# echoing hey... done!
# ====================
step() {
	echo -e "${BOLD}$1${RESET}" && eval "$2"
	if [ "${PIPESTATUS[0]}" -gt 0 ]; then
		echo -e "${RED}${ITALIC}${STRIKETHROUGH}$1${RESET}${RED} error!${RESET}" && \
		exit 1
	else
		TEXT="${GREEN}${ITALIC}${STRIKETHROUGH}$1${RESET}${GREEN} done!${RESET}"
		echo -e "$TEXT"
	fi
	echo -e "${BOLD}$(repeat "=" "$(echo "$TEXT" | sed -E 's/\\033[^\\]*m//g' | wc -c)")${RESET}"
}

build() {
  	step "Updating packages and installing archiso..." "pacman -Syu --noconfirm archiso"
  	step "Building ISO..." "mkarchiso -v -w work/ -o ./ configs/wip-conf"
  	step "Generating checksums text file..." "
		cat <<-EOL >CHECKSUMS.txt
			b2sum  $(b2sum "liquidlinux-$DATE-x86_64.iso")
			md5sum  $(md5sum "liquidlinux-$DATE-x86_64.iso")
			sha1sum  $(sha1sum "liquidlinux-$DATE-x86_64.iso")
			sha256sum  $(sha256sum "liquidlinux-$DATE-x86_64.iso")
		EOL
  	"
}

main() {
  	if [ -z ${DATE+x} ]; then
    		echo -e "${RED}DATE variable not set!${RESET}" &&
      		exit 1
  	else
    		build
  	fi
}

main
