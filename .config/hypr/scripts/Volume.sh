#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for volume controls for audio and mic 

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

# Get Volume
get_volume() {
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        echo "Muted"
        return
    fi

    local volume
    volume=$(pamixer --get-volume)
    if [[ "$volume" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Get icons
get_icon() {
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        echo "$iDIR/volume-mute.png"
        return
    fi

    current=$(pamixer --get-volume)
    if [[ "$current" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "$current" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

# Notify
# Notify for Volume
notify_user() {
    local level="$(pamixer --get-volume)"
    local icon="$(get_icon)"
    # ID 2593 is a custom ID to ensure the notification replaces itself
    notify-send -r 2593 -e -h int:value:"$level" -u low -i "$icon" " Volume Level:" " ${level}%"
    "$sDIR/Sounds.sh" --volume
}



# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -i "$1" --allow-boost --set-limit 150 && notify_user
    fi
}

# Decrease Volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -d "$1" && notify_user
    fi
}

# Toggle Mute
toggle_mute() {
	if [ "$(pamixer --get-mute)" == "false" ]; then
		pamixer -m && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/volume-mute.png" " Mute"
	elif [ "$(pamixer --get-mute)" == "true" ]; then
		pamixer -u && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$(get_icon)" " Volume:" " Switched ON"
	fi
}

# Toggle Mic
toggle_mic() {
	if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
		pamixer --default-source -m && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone-mute.png" " Microphone:" " Switched OFF"
	elif [ "$(pamixer --default-source --get-mute)" == "true" ]; then
		pamixer --default-source -u && notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone.png" " Microphone:" " Switched ON"
	fi
}
# Get Mic Icon
get_mic_icon() {
    local muted="$(pamixer --default-source --get-mute)"
    local current="$(pamixer --default-source --get-volume)"
    if [[ "$muted" == "true" || "$current" -eq "0" ]]; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

# Get Microphone Volume
get_mic_volume() {
    if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
        echo "Muted"
        return
    fi

    local volume
    volume=$(pamixer --default-source --get-volume)
    if [[ "$volume" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Notify for Microphone
# Notify for Microphone
notify_mic_user() {
    local level="$(pamixer --default-source --get-volume)"
    local icon="$(get_mic_icon)"
    # ID 2594 for Mic to separate it from Volume
    notify-send -r 2594 -e -h int:value:"$level" -u low -i "$icon" " Mic Level:" " ${level}%"
}

# Increase MIC Volume
inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -i 5 && notify_mic_user
    fi
}

# Decrease MIC Volume
dec_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -d 5 && notify_mic_user
    fi
}

# Execute accordingly
case "$1" in
"--get")
  get_volume
  ;;
"--inc")
  inc_volume 5
  ;;
"--inc-precise")
  inc_volume 1
  ;;
"--dec")
  dec_volume 5
  ;;
"--dec-precise")
  dec_volume 1
  ;;
"--toggle")
  toggle_mute
  ;;
"--toggle-mic")
  toggle_mic
  ;;
"--get-icon")
  get_icon
  ;;
"--get-mic-icon")
  get_mic_icon
  ;;
"--mic-inc")
  inc_mic_volume
  ;;
"--mic-dec")
  dec_mic_volume
  ;;
*)
  get_volume
  ;;
esac
