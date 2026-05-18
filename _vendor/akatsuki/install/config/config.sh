# Copy over Akatsuki configs
mkdir -p ~/.config
cp -R ~/.local/share/akatsuki/config/* ~/.config/

# Use default bashrc from Akatsuki
cp ~/.local/share/akatsuki/default/bashrc ~/.bashrc
