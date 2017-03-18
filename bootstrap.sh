#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

if [ "$USER" == "root" ]; then
    echo 'This script is not intended to be run as root.'
    exit 1
fi

export DOTFILES=~/.dotfiles

if [ `uname` == "Darwin" ]; then
    # Brew packages
    [ ! -f /usr/local/bin/brew ] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install ack colordiff emacs python hub

    [ ! -L ~/.myzshrc ] && ln -sf $DOTFILES/.myzshrc_mac ~/.myzshrc

    # symlink /home for compatibility with linux
    [ ! -L /home ] && sudo sed -i 's|/home|#/home|' && \
	sudo automount -cv && \
	sudo rm -rf /home && \
	sudo ln -s /Users /home

    # TODO: install powerline fonts
    # TODO: iTerm2 conf
elif [ `uname` == "Linux" ]; then
    [ ! -f /etc/sudoers.d/$USER ] && sudo sh -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"

    # Aptitude packages
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y aptitude zsh tmux curl ntp emacs24-nox python-virtualenv git unzip zip

    if [ ! -n "$SSH_CLIENT" ] || [ ! -n "$SSH_TTY" ]; then
	sudo apt-get install -y x11-xserver-utils conky xsel xautolock libnotify-bin rxvt-unicode-256color firefox scrot redshift

	if [ ! -f /etc/apt/sources.list.d/i3.list ]; then
	    sudo sh -c "echo \"deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe\" >> /etc/apt/sources.list.d/i3.list"
	    sudo apt-get update
	    sudo apt-get --allow-unauthenticated install sur5r-keyring
	    sudo apt-get update
	    sudo apt-get install i3
	fi

	if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
	    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	    sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
	    sudo apt-get update
	    sudo install google-chrome-stable
	fi

	[ ! -L ~/.Xresources ] && ln -sf $DOTFILES/.Xresources ~/
	[ ! -L ~/.conkyrc ] && ln -sf $DOTFILES/.conkyrc ~/
	[ ! -L ~/.i3 ] && ln -sf $DOTFILES/.i3 ~/
	[ ! -L ~/.urxvt ] && ln -sf $DOTFILES/.urxvt ~/
	[ ! -L ~/.config ] && ln -sf $DOTFILES/.config ~/
	[ ! -f ~/.fonts/Monaco\ for\ Powerline.otf ] && wget -P ~/.fonts/ https://raw.githubusercontent.com/supermarin/powerline-fonts/master/Monaco/Monaco%20for%20Powerline.otf
	# TODO: install siji
	[ -f /etc/fonts/conf.d/70-no-bitmaps.conf ] && sudo rm /etc/fonts/conf.d/70-no-bitmaps.conf
	[ ! -L /etc/default/keyboard ] && sudo ln -sf $DOTFILES/default/keyboard /etc/default/keyboard
    fi
fi

# shell
[ ! -d ~/.oh-my-zsh ] && sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
[ ! -L ~/.zshrc ] && ln -sf $DOTFILES/.zshrc ~/.zshrc
[ "$SHELL" != "/bin/zsh" ] && chsh --shell /bin/zsh

# Python packages
export PIP_REQUIRE_VIRTUALENV=false
pip install diff-highlight

# TODO: install heroku toolbelt
# TODO: install travis

# symlink common files
[ ! -L ~/.emacs ] && ln -sf $DOTFILES/.emacs ~/
[ ! -L ~/.tmux.conf ] && ln -sf $DOTFILES/.tmux.conf ~/
[ ! -L ~/.gitconfig ] && ln -sf $DOTFILES/.gitconfig ~/

exit 0