#!/bin/bash

# Linux Development Environment Setup Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

print_section() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}\n"
}

# Check if running in Docker container
is_docker() {
    [ -f /.dockerenv ] || grep -sq 'docker\|lxc' /proc/1/cgroup 2>/dev/null
}

check_not_root() {
    if is_docker; then
        print_info "Running in Docker container, skipping root check"
        return 0
    fi
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root. It will use sudo when needed."
        exit 1
    fi
}

install_basic_software() {
    print_section "Installing Basic Software"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y vim git tmux curl wget python-is-python3
    git config --global alias.logline "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    print_success "Basic software installation completed!"
}

install_nvim() {
    print_section "Installing NeoVim"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/nvim/install.sh"
}

install_zsh() {
    print_section "Installing ZSH"

    if command -v zsh >/dev/null 2>&1; then
        print_warning "ZSH is already installed"
    else
        sudo apt install -y zsh
        print_success "ZSH installed successfully!"
    fi

    if [ "$SHELL" != "$(which zsh)" ]; then
        print_warning "Your default shell is not ZSH yet."
        chsh -s "$(which zsh)"
        print_success "Default shell changed to ZSH. Please log out and log back in."
    else
        print_success "ZSH is already your default shell"
    fi
}

install_oh_my_zsh() {
    print_section "Installing Oh-My-Zsh"

    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh-My-Zsh is already installed"
    else
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh-My-Zsh installed successfully!"
    fi
}

install_zsh_plugins() {
    print_section "Installing ZSH Plugins"

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed!"
    else
        print_warning "zsh-autosuggestions already installed"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed!"
    else
        print_warning "zsh-syntax-highlighting already installed"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/autojump" ]; then
        git clone https://github.com/wting/autojump.git "$ZSH_CUSTOM/plugins/autojump"
        cd "$ZSH_CUSTOM/plugins/autojump"
        if [ -z "$SHELL" ] || [ "$SHELL" = "None" ]; then
            export SHELL=$(which zsh)
        fi
        ./install.py --force
        cd - > /dev/null
        print_success "autojump installed!"
    else
        print_warning "autojump already installed"
    fi

    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
            sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)/' "$HOME/.zshrc"
            if ! grep -q "profile.d/autojump.sh" "$HOME/.zshrc"; then
                echo "" >> "$HOME/.zshrc"
                echo "# Autojump configuration" >> "$HOME/.zshrc"
                echo "[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh" >> "$HOME/.zshrc"
                echo "autoload -U compinit && compinit -u" >> "$HOME/.zshrc"
            fi
            print_success "Updated .zshrc with plugins!"
        else
            print_warning "Could not find plugins line in .zshrc. Please add manually:"
            echo "  plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)"
        fi
    else
        print_warning ".zshrc not found. Please run zsh first to create it."
    fi
}

configure_tmux() {
    print_section "Configuring Tmux"

    TMUX_CONF="$HOME/.tmux.conf"
    if grep -q "mode-keys vi" "$TMUX_CONF" 2>/dev/null; then
        print_warning "Tmux vi mode already configured"
    else
        echo "set-window-option -g mode-keys vi" >> "$TMUX_CONF"
        print_success "Tmux vi mode enabled in $TMUX_CONF"
    fi
}

set_zsh_theme() {
    print_section "Setting ZSH Theme"

    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="ys"/' "$HOME/.zshrc"
        print_success "Theme set to 'ys'!"
    else
        print_warning ".zshrc not found. Please set theme manually later."
    fi
}

show_menu() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}Linux Development Environment Setup${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    echo "1) Install Basic Software"
    echo "2) Install NeoVim"
    echo "3) Install ZSH"
    echo "4) Install Oh-My-Zsh"
    echo "5) Install ZSH Plugins"
    echo "6) Set ZSH Theme (ys)"
    echo "7) Configure Tmux (vi mode)"
    echo "9) Run All Setup Steps"
    echo "0) Exit"
    echo ""
}

run_all_steps() {
    print_section "Running Complete Setup"
    install_basic_software
    install_nvim
    install_zsh
    install_oh_my_zsh
    install_zsh_plugins
    set_zsh_theme
    configure_tmux
    print_section "Setup Complete!"
    print_success "All setup steps completed successfully!"
    print_warning "Please log out and log back in for all changes to take effect."
}

main() {
    check_not_root

    if [ "$1" == "--all" ] || [ "$1" == "-a" ]; then
        run_all_steps
        exit 0
    fi

    while true; do
        show_menu
        read -p "Select an option: " choice
        case $choice in
            1) install_basic_software ;;
            2) install_nvim ;;
            3) install_zsh ;;
            4) install_oh_my_zsh ;;
            5) install_zsh_plugins ;;
            6) set_zsh_theme ;;
            7) configure_tmux ;;
            9) run_all_steps; break ;;
            0) print_info "Exiting..."; exit 0 ;;
            *) print_error "Invalid option. Please try again." ;;
        esac
        read -p "Press Enter to continue..."
    done
}

main "$@"
