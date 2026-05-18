echo "Change to akatsuki-nvim package"
akatsuki-pkg-drop akatsuki-lazyvim
akatsuki-pkg-add akatsuki-nvim

# Will trigger to overwrite configs or not to pickup new hot-reload themes
akatsuki-nvim-setup
