#!/usr/bin/env bash

############ Variables ############
enable_battery=true
battery_charging=true
enable_media=true

####### Check availability ########
for battery in /sys/class/power_supply/*BAT*; do
  if [[ -f "$battery/uevent" ]]; then
    enable_battery=true
    if [[ $(cat /sys/class/power_supply/*/status | head -1) == "Charging" ]]; then
      battery_charging=true
    else
      battery_charging=false
    fi

    break
  fi
done

############# Output #############
if [[ $enable_battery == true ]]; then
  if [[ $battery_charging == true ]]; then
    echo -n "(+) "
  fi
  echo -n "$(cat /sys/class/power_supply/*/capacity | head -1)"%
  if [[ $battery_charging == false ]]; then
    echo -n " remaining"
  fi
fi

if [[ $enable_media == true ]]; then
    media=$(playerctl metadata title)
    artist=$(playerctl metadata artist)
    if [[ -n $media ]]; then
	  echo -n " | $media"
	  if [[ -n $artist ]]; then
		echo -n " by $artist"
	  fi
    fi
fi

echo ''
