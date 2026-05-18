echo "Change akatsuki-screenrecord to use gpu-screen-recorder"
akatsuki-pkg-drop wf-recorder wl-screenrec

# Add slurp in case it hadn't been picked up from an old migration
akatsuki-pkg-add slurp gpu-screen-recorder
