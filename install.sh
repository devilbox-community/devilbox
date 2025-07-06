#!/usr/bin/env bash

###
### Devilbox Automated Installation Script
###
### This script automates the installation of Devilbox for macOS users
### as described in the feature request.
###
### Usage: ./install.sh [OPTIONS]
###
### Options:
###   -h, --help     Show this help message
###   -f, --force    Force installation even if Devilbox already exists
###   -v, --verbose  Enable verbose output
###

set -e
set -u
set -o pipefail

# Color definitions for output
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  PURPLE="$(tput setaf 5)"
  CYAN="$(tput setaf 6)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  PURPLE=""
  CYAN=""
  BOLD=""
  NORMAL=""
fi

# Configuration
WORKSPACE_DIR="$HOME/Workspace"
DEVILBOX_REPO="https://github.com/devilbox-community/devilbox"
CONTAINERS_CONFIG="bind httpd php php74 php81 php82 php83 php84 mysql redis opensearch buggregator"
SHELL_PROFILE=""
VERBOSE=false
FORCE=false

# Detect shell and set appropriate profile file
detect_shell_profile() {
  # Get the user's default shell
  local user_shell=$(basename "$SHELL")
  case "$user_shell" in
    zsh)
      SHELL_PROFILE="$HOME/.zprofile"
      ;;
    bash)
      SHELL_PROFILE="$HOME/.bash_profile"
      ;;
    fish)
      SHELL_PROFILE="$HOME/.config/fish/config.fish"
      ;;
    *)
      # Default to .zprofile for macOS (most common)
      SHELL_PROFILE="$HOME/.zprofile"
      ;;
  esac
}

# Logging functions
log_info() {
  echo "${BLUE}[INFO]${NORMAL} $1"
}

log_success() {
  echo "${GREEN}[SUCCESS]${NORMAL} $1"
}

log_warning() {
  echo "${YELLOW}[WARNING]${NORMAL} $1"
}

log_error() {
  echo "${RED}[ERROR]${NORMAL} $1" >&2
}

log_step() {
  echo ""
  echo "${CYAN}${BOLD}=== $1 ===${NORMAL}"
}

log_verbose() {
  if [ "$VERBOSE" = true ]; then
    echo "${PURPLE}[VERBOSE]${NORMAL} $1"
  fi
}

# Error handling
cleanup() {
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    log_error "Installation failed with exit code $exit_code"
    log_error "Please check the output above for details"
  fi
}

trap cleanup EXIT

# Usage function
usage() {
  echo "Devilbox Automated Installation Script"
  echo ""
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help     Show this help message"
  echo "  -f, --force    Force installation even if Devilbox already exists"
  echo "  -v, --verbose  Enable verbose output"
  echo ""
  echo "This script will:"
  echo "  1. Clone Devilbox repository to ~/Workspace"
  echo "  2. Create .env file from env-example"
  echo "  3. Copy Magento2 docker-compose override file"
  echo "  4. Set environment variables in shell profile"
  echo "  5. Configure NEW_UID and NEW_GID"
  echo "  6. Install Homebrew if not present"
  echo "  7. Create symlink to dvl command"
  echo ""
}

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      -f|--force)
        FORCE=true
        shift
        ;;
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
}

# Check if running on macOS
check_macos() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    log_warning "This script is designed for macOS, but you're running on: $OSTYPE"
    read -p "Do you want to continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "Installation cancelled"
      exit 0
    fi
  fi
}

# Check prerequisites
check_prerequisites() {
  log_step "Checking Prerequisites"

  # Check for git
  if ! command -v git &> /dev/null; then
    log_error "Git is not installed. Please install git first."
    exit 1
  fi
  log_success "Git is installed"

  # Check for Docker
  if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker Desktop first."
    exit 1
  fi
  log_success "Docker is installed"

  # Check if Docker is running
  if ! docker info &> /dev/null; then
    log_error "Docker is not running. Please start Docker Desktop first."
    exit 1
  fi
  log_success "Docker is running"
}

# Step 1: Clone Devilbox repository
clone_devilbox() {
  log_step "Step 1: Cloning Devilbox Repository"

  if [ -d "$WORKSPACE_DIR" ] && [ "$FORCE" = false ]; then
    log_warning "Directory $WORKSPACE_DIR already exists"
    read -p "Do you want to continue and overwrite it? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "Installation cancelled"
      exit 0
    fi
  fi

  # Remove existing directory if force is enabled
  if [ -d "$WORKSPACE_DIR" ] && [ "$FORCE" = true ]; then
    log_verbose "Removing existing directory: $WORKSPACE_DIR"
    rm -rf "$WORKSPACE_DIR"
  fi

  log_info "Cloning Devilbox repository to $WORKSPACE_DIR"
  git clone "$DEVILBOX_REPO" "$WORKSPACE_DIR"
  log_success "Repository cloned successfully"
}

# Step 2: Create .env file and copy override file
setup_configuration() {
  log_step "Step 2: Setting up Configuration Files"

  cd "$WORKSPACE_DIR"

  # Copy env-example to .env
  log_info "Creating .env file from env-example"
  cp env-example .env
  log_success ".env file created"

  # Copy magento2 docker-compose override file
  log_info "Copying Magento2 docker-compose override file"
  cp compose/docker-compose.override.yml-magento2 docker-compose.override.yml
  log_success "docker-compose.override.yml file created"
}

# Step 3: Configure NEW_UID and NEW_GID
configure_uid_gid() {
  log_step "Step 3: Configuring User and Group IDs"

  local current_uid=$(id -u)
  local current_gid=$(id -g)

  log_info "Current UID: $current_uid"
  log_info "Current GID: $current_gid"

  # Update .env file with current UID and GID
  # Use a more portable approach that works reliably on macOS
  if command -v perl >/dev/null 2>&1; then
    # Perl approach - most portable and reliable
    perl -i -pe "s/^NEW_UID=.*/NEW_UID=$current_uid/" .env
    perl -i -pe "s/^NEW_GID=.*/NEW_GID=$current_gid/" .env
  else
    # Fallback to sed with temporary file approach for maximum compatibility
    sed "s/^NEW_UID=.*/NEW_UID=$current_uid/" .env > .env.tmp && mv .env.tmp .env
    sed "s/^NEW_GID=.*/NEW_GID=$current_gid/" .env > .env.tmp && mv .env.tmp .env
  fi

  log_success "UID and GID configured in .env file"
}

# Step 4: Setup shell profile
setup_shell_profile() {
  log_step "Step 4: Setting up Shell Profile"

  detect_shell_profile
  log_info "Using shell profile: $SHELL_PROFILE"

  # Create profile file if it doesn't exist
  touch "$SHELL_PROFILE"

  # Check if DEVILBOX_CONTAINERS is already set
  if ! grep -q "DEVILBOX_CONTAINERS" "$SHELL_PROFILE"; then
    log_info "Adding DEVILBOX_CONTAINERS to $SHELL_PROFILE"
    echo "" >> "$SHELL_PROFILE"
    echo "# Devilbox configuration" >> "$SHELL_PROFILE"
    echo "export DEVILBOX_CONTAINERS=\"$CONTAINERS_CONFIG\"" >> "$SHELL_PROFILE"
  else
    log_info "DEVILBOX_CONTAINERS already exists in $SHELL_PROFILE"
  fi

  # Check if DEVILBOX_PATH is already set
  if ! grep -q "DEVILBOX_PATH" "$SHELL_PROFILE"; then
    log_info "Adding DEVILBOX_PATH to $SHELL_PROFILE"
    echo "export DEVILBOX_PATH=\"$WORKSPACE_DIR\"" >> "$SHELL_PROFILE"
  else
    log_info "DEVILBOX_PATH already exists in $SHELL_PROFILE"
  fi

  log_success "Shell profile configured"
}

# Step 5: Install Homebrew if not present
install_homebrew() {
  log_step "Step 5: Checking Homebrew Installation"

  if command -v brew &> /dev/null; then
    log_success "Homebrew is already installed"
    return 0
  fi

  log_info "Homebrew not found, installing..."

  # Check if we're on macOS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      export PATH="/usr/local/bin:$PATH"
    fi

    log_success "Homebrew installed successfully"
  else
    log_error "Homebrew installation is only supported on macOS"
    exit 1
  fi
}

# Step 6: Create symlink to dvl command
create_symlink() {
  log_step "Step 6: Creating DVL Command Symlink"

  # Determine Homebrew bin directory
  local brew_bin_dir
  if [[ -d "/opt/homebrew/bin" ]]; then
    brew_bin_dir="/opt/homebrew/bin"
  elif [[ -d "/usr/local/bin" ]]; then
    brew_bin_dir="/usr/local/bin"
  else
    log_error "Cannot find Homebrew bin directory"
    exit 1
  fi

  local dvl_script="$WORKSPACE_DIR/dvl.sh"
  local dvl_symlink="$brew_bin_dir/dvl"

  # Check if dvl.sh exists
  if [[ ! -f "$dvl_script" ]]; then
    log_error "dvl.sh not found in $WORKSPACE_DIR"
    exit 1
  fi

  # Create symlink
  log_info "Creating symlink: $dvl_symlink -> $dvl_script"
  ln -snf "$dvl_script" "$dvl_symlink"

  # Make sure the script is executable
  chmod +x "$dvl_script"

  log_success "DVL command symlink created"
}

# Final setup and instructions
final_setup() {
  log_step "Installation Complete!"

  echo ""
  echo "${GREEN}${BOLD}Devilbox has been successfully installed!${NORMAL}"
  echo ""
  echo "${CYAN}Next steps:${NORMAL}"
  echo "1. Restart your terminal or run: ${YELLOW}source $SHELL_PROFILE${NORMAL}"
  echo "2. Start Devilbox with: ${YELLOW}dvl up${NORMAL}"
  echo "3. Access the Devilbox intranet at: ${YELLOW}http://localhost${NORMAL}"
  echo ""
  echo "${CYAN}Useful commands:${NORMAL}"
  echo "  ${YELLOW}dvl up${NORMAL}       - Start Devilbox"
  echo "  ${YELLOW}dvl down${NORMAL}     - Stop Devilbox"
  echo "  ${YELLOW}dvl ps${NORMAL}       - Show running containers"
  echo "  ${YELLOW}dvl logs${NORMAL}     - Show logs"
  echo "  ${YELLOW}dvl --help${NORMAL}   - Show all available commands"
  echo ""
  echo "${CYAN}Configuration:${NORMAL}"
  echo "  Workspace: ${YELLOW}$WORKSPACE_DIR${NORMAL}"
  echo "  Profile:   ${YELLOW}$SHELL_PROFILE${NORMAL}"
  echo "  DVL command: ${YELLOW}$(which dvl 2>/dev/null || echo "$brew_bin_dir/dvl")${NORMAL}"
  echo ""
}

# Main function
main() {
  echo "${CYAN}${BOLD}Devilbox Automated Installation Script${NORMAL}"
  echo ""

  parse_args "$@"
  check_macos
  check_prerequisites
  clone_devilbox
  setup_configuration
  configure_uid_gid
  setup_shell_profile
  install_homebrew
  create_symlink
  final_setup

  log_success "Installation completed successfully!"
}

# Run main function with all arguments
main "$@"
