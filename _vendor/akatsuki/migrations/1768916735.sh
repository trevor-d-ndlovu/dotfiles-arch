echo "Fix microphone gain and audio mixing on Asus ROG laptops"

source "$AKATSUKI_PATH/install/config/hardware/asus/fix-mic.sh"
source "$AKATSUKI_PATH/install/config/hardware/asus/fix-audio-mixer.sh"

if akatsuki-hw-asus-rog; then
  akatsuki-restart-pipewire
fi
