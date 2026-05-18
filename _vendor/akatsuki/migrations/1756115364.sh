echo "Replace buggy native Zoom client with webapp"

if akatsuki-pkg-present zoom; then
  akatsuki-pkg-drop zoom
  akatsuki-webapp-install "Zoom" https://app.zoom.us/wc/home https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/zoom.png
fi
