#!/bin/sh -x

# disable auto download
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool FALSE

# disable softwareupdate schedule
softwareupdate --schedule off