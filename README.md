# LinuxSetup

This repo includes basic configuration of setup Linux development environment.

## TLDR

```shell
git clone https://github.com/leonling-ll/LinuxSetup.git
cd LinuxSetup && ./setup.py --all
```

If you want to see what will be installed, please follow the steps below.

## Softwares to install at first

```shell
sudo apt update && sudo apt upgrade -y
sudo apt install vim git tmux curl wget python-is-python3
sudo apt install gcc g++ ccls
sudo apt install htop
```

## Enable SSH Server

* Install openssh-server

  ```shell
  sudo apt update
  sudo apt install openssh-server
  ```

* Verify installation

  ```shell
  sudo systemctl status ssh
  ```

* Enable and disable openssh service

  ```shell
  sudo systemctl disable --now ssh
  sudo systemctl enable --now ssh
  ```

## Install ZSH & Oh-My-Zsh

* ZSH with [Oh-My-Zsh](https://ohmyz.sh/) are very productive shell for developers
  
  * Install ZSH

  ```shell
  sudo apt install zsh
  echo $SHELL
  chsh -s $(which zsh)
  ```

  log out of the terminal and log in again to enable zsh.

  * Install Oh-My-Zsh

    ```shell
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```

  * Install Plugins for ZSH
  
    * ZSH-autosuggestions & ZSH-Syntax-highlighting

      ```shell
      git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
      ```

    Don't forget update these two into `.zshrc` plugins field.

    * Autojump

      ```shell
      git clone https://github.com/wting/autojump.git $ZSH_CUSTOM/plugins/autojump
      $ZSH_CUSTOM/plugins/autojump
      ./install.py
      ```

      Please also add `autojump` to `.zshrc` plugins with this line in below.

      ```shell
      [ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
      autoload -U compinit && compinit -u
      ```

* `Oh-My-Zsh` also provides various themes, `ys` is the best for me.

## Git Pretty log

Set alias for log prettify syntax

```shell
git config --global alias.logline "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

## Beatify

### Tmux Powerline

This part refers to [Tmux with Powerline on Ubuntu - tutorial for beginners](https://bobbyhadz.com/blog/tmux-powerline-ubuntu).

* Install Powerline

  ```shell
  sudo apt install powerline -y
  ```

* Install powerline fonts

  ```shell
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts
  ```

* Add below code section to `~/.tmux.conf`

  ```shell
  # enable the powerline status bar
  run-shell 'powerline-config tmux setup'

  # Set tmux mode to vi (default is emac)
  set-window-option -g mode-keys vi
  ```
