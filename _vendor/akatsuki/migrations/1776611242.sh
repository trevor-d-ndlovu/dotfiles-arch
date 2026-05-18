echo "Install socat so we can reactivate internal display when external display is removed"

akatsuki-pkg-add socat
uwsm-app -- akatsuki-hyprland-monitor-watch &
