#!/bin/bash

# Linux Development Environment Setup Script
# Based on LinuxSetup README.md

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}\n"
}

# Function to check if running in Docker container
is_docker() {
    if [ -f /.dockerenv ]; then
        return 0
    elif grep -sq 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if running as root
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

# Function to install basic software
install_basic_software() {
    print_section "Installing Basic Software"
    
    print_info "Updating package lists..."
    sudo apt update
    
    print_info "Upgrading existing packages..."
    sudo apt upgrade -y
    
    print_info "Installing basic development tools..."
    sudo apt install -y vim git tmux curl wget python-is-python3
    
    print_info "Installing C/C++ development tools..."
    sudo apt install -y gcc g++ ccls
    
    print_info "Installing system monitoring tools..."
    sudo apt install -y htop
    
    print_success "Basic software installation completed!"
}

# Function to install ZSH
install_zsh() {
    print_section "Installing ZSH"
    
    if command -v zsh >/dev/null 2>&1; then
        print_warning "ZSH is already installed"
    else
        print_info "Installing ZSH..."
        sudo apt install -y zsh
        print_success "ZSH installed successfully!"
    fi
    
    print_info "Current shell: $SHELL"
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_warning "Your default shell is not ZSH yet."
        read -p "Do you want to change your default shell to ZSH? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chsh -s "$(which zsh)"
            print_success "Default shell changed to ZSH. Please log out and log back in for changes to take effect."
        else
            print_info "Skipping shell change. You can change it later with: chsh -s \$(which zsh)"
        fi
    else
        print_success "ZSH is already your default shell"
    fi
}

# Function to install Oh-My-Zsh
install_oh_my_zsh() {
    print_section "Installing Oh-My-Zsh"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh-My-Zsh is already installed"
    else
        print_info "Installing Oh-My-Zsh..."
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh-My-Zsh installed successfully!"
    fi
}

# Function to install ZSH plugins
install_zsh_plugins() {
    print_section "Installing ZSH Plugins"
    
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Install zsh-autosuggestions
    if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        print_warning "zsh-autosuggestions already installed"
    else
        print_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed!"
    fi
    
    # Install zsh-syntax-highlighting
    if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        print_warning "zsh-syntax-highlighting already installed"
    else
        print_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed!"
    fi
    
    # Install autojump
    if [ -d "$ZSH_CUSTOM/plugins/autojump" ]; then
        print_warning "autojump already installed"
    else
        print_info "Installing autojump..."
        git clone https://github.com/wting/autojump.git "$ZSH_CUSTOM/plugins/autojump"
        cd "$ZSH_CUSTOM/plugins/autojump"
        
        # Set SHELL variable if not set (common in Docker containers)
        if [ -z "$SHELL" ] || [ "$SHELL" = "None" ]; then
            export SHELL=$(which zsh)
            print_info "Setting SHELL to $SHELL for autojump installation"
        fi
        
        # Install autojump with explicit shell specification
        ./install.py --force
        cd - > /dev/null
        print_success "autojump installed!"
    fi
    
    # Update .zshrc with plugins
    print_info "Updating .zshrc with plugins..."
    if [ -f "$HOME/.zshrc" ]; then
        # Check if plugins line exists
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            # Backup original .zshrc
            cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
            print_info "Backed up .zshrc"
            
            # Update plugins line
            sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)/' "$HOME/.zshrc"
            
            # Add autojump configuration if not present
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

# Function to set ZSH theme
set_zsh_theme() {
    print_section "Setting ZSH Theme"
    
    if [ -f "$HOME/.zshrc" ]; then
        print_info "Setting theme to 'ys'..."
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="ys"/' "$HOME/.zshrc"
        print_success "Theme set to 'ys'!"
    else
        print_warning ".zshrc not found. Please set theme manually later."
    fi
}

# Function to install Powerline
install_powerline() {
    print_section "Installing Tmux Powerline"
    
    print_info "Installing powerline..."
    sudo apt install -y powerline
    
    print_success "Powerline installed!"
}

# Function to install Powerline fonts
install_powerline_fonts() {
    print_section "Installing Powerline Fonts"
    
    print_info "Cloning powerline fonts repository..."
    TEMP_DIR=$(mktemp -d)
    git clone https://github.com/powerline/fonts.git --depth=1 "$TEMP_DIR"
    
    print_info "Installing fonts..."
    cd "$TEMP_DIR"
    ./install.sh
    cd - > /dev/null
    
    print_info "Cleaning up..."
    rm -rf "$TEMP_DIR"
    
    print_success "Powerline fonts installed!"
}

# Function to configure tmux
configure_tmux() {
    print_section "Configuring Tmux"
    
    TMUX_CONF="$HOME/.tmux.conf"
    
    if [ -f "$TMUX_CONF" ]; then
        print_warning "Tmux configuration file already exists"
        read -p "Do you want to backup and update it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$TMUX_CONF" "$TMUX_CONF.backup.$(date +%Y%m%d_%H%M%S)"
            print_info "Backed up existing tmux configuration"
        else
            print_info "Skipping tmux configuration"
            return
        fi
    fi
    
    print_info "Adding powerline configuration to tmux..."
    
    # Check if powerline config already exists
    # if [ -f "$TMUX_CONF" ] && grep -q "powerline-config tmux setup" "$TMUX_CONF"; then
    #     print_warning "Powerline configuration already exists in .tmux.conf"
    # else
    #     cat >> "$TMUX_CONF" << 'EOF'

# enable the powerline status bar
# run-shell 'powerline-config tmux setup'

# Set tmux mode to vi (default is emac)
set-window-option -g mode-keys vi
EOF
        print_success "Tmux configured with Powerline!"
    fi
}

# Main menu
show_menu() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}Linux Development Environment Setup${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    echo "1) Install Basic Software"
    echo "2) Install ZSH"
    echo "3) Install Oh-My-Zsh"
    echo "4) Install ZSH Plugins"
    echo "5) Set ZSH Theme (ys)"
    echo "6) Install Tmux Powerline"
    echo "7) Install Powerline Fonts"
    echo "8) Configure Tmux"
    echo "9) Run All Setup Steps"
    echo "0) Exit"
    echo ""
}

# Function to run all steps
run_all_steps() {
    print_section "Running Complete Setup"
    
    install_basic_software
    install_zsh
    install_oh_my_zsh
    install_zsh_plugins
    set_zsh_theme
    # install_powerline
    # install_powerline_fonts
    configure_tmux
    
    print_section "Setup Complete!"
    print_success "All setup steps completed successfully!"
    print_warning "Please log out and log back in for all changes to take effect."
    print_info "Don't forget to select a Powerline-compatible font in your terminal emulator!"
}

# Main function
main() {
    check_not_root
    
    # Check if running in non-interactive mode
    if [ "$1" == "--all" ] || [ "$1" == "-a" ]; then
        run_all_steps
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_menu
        read -p "Select an option: " choice
        
        case $choice in
            1) install_basic_software ;;
            2) install_zsh ;;
            3) install_oh_my_zsh ;;
            4) install_zsh_plugins ;;
            5) set_zsh_theme ;;
            6) install_powerline ;;
            7) install_powerline_fonts ;;
            8) configure_tmux ;;
            9) run_all_steps; break ;;
            0) print_info "Exiting..."; exit 0 ;;
            *) print_error "Invalid option. Please try again." ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"

