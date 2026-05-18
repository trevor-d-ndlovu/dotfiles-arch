echo "Switch back to mainline chromium now that it supports full live theming"

if akatsuki-pkg-present akatsuki-chromium; then
  if gum confirm "Ready to switch to mainstream chromium? (Will close Chromium + reset settings)"; then
    pkill -x chromium
    akatsuki-pkg-drop akatsuki-chromium
    akatsuki-pkg-add chromium
    akatsuki-theme-set-browser
  fi
fi
