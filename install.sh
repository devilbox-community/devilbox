#!/usr/bin/env bash

###
### Devilbox Automated Installation Script
###
### Cross-platform installer for Devilbox.
### Supported: macOS, Debian/Ubuntu, Arch/Manjaro, Fedora/RHEL, Alpine, WSL2.
###
### Usage: ./install.sh [OPTIONS]
###
### Options:
###   -h, --help              Show this help message
###   -f, --force             Force installation even if Devilbox already exists
###   -v, --verbose           Enable verbose output
###       --non-interactive   Never prompt; use safe defaults; fail loudly on destructive ops
###       --workspace <path>  Override target directory (default: $HOME/Workspace)
###

set -e
set -u
set -o pipefail

# Color definitions for output
ncolors=""
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors 2>/dev/null || echo "")
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
WORKSPACE_DIR_DEFAULT="$HOME/Workspace"
WORKSPACE_DIR="$HOME/Workspace"
DEVILBOX_REPO="https://github.com/devilbox-community/devilbox"
# Populated by _load_containers_from_env_example after clone.
CONTAINERS_CONFIG=""
SHELL_PROFILE=""
VERBOSE=false
FORCE=false
NONINTERACTIVE=false
WORKSPACE_OVERRIDE=""

# OS detection globals
OS_FAMILY="unknown"
OS_PRETTY="unknown"
IS_WSL=0

# Detect shell and set appropriate profile file
detect_shell_profile() {
  # Get the user's default shell
  local user_shell
  user_shell=$(basename "${SHELL:-/bin/sh}")
  case "$user_shell" in
    zsh)
      SHELL_PROFILE="$HOME/.zprofile"
      ;;
    bash)
      # Linux convention: ~/.bashrc; macOS: ~/.bash_profile.
      if [ "$OS_FAMILY" = "darwin" ]; then
        SHELL_PROFILE="$HOME/.bash_profile"
      else
        SHELL_PROFILE="$HOME/.bashrc"
      fi
      ;;
    fish)
      SHELL_PROFILE="$HOME/.config/fish/config.fish"
      ;;
    ash|sh)
      SHELL_PROFILE="$HOME/.profile"
      ;;
    *)
      if [ "$OS_FAMILY" = "darwin" ]; then
        SHELL_PROFILE="$HOME/.zprofile"
      else
        SHELL_PROFILE="$HOME/.profile"
      fi
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
  echo "  -h, --help              Show this help message"
  echo "  -f, --force             Force installation even if Devilbox already exists"
  echo "  -v, --verbose           Enable verbose output"
  echo "      --non-interactive   Never prompt; use safe defaults; fail on destructive ops"
  echo "      --workspace <path>  Override target directory (default: \$HOME/Workspace)"
  echo ""
  echo "Environment variables:"
  echo "  DEVILBOX_NONINTERACTIVE=1   Same as --non-interactive"
  echo "  DEVILBOX_WORKSPACE=<path>   Same as --workspace <path>"
  echo ""
  echo "Supported operating systems:"
  echo "  - macOS (Darwin)"
  echo "  - Debian / Ubuntu"
  echo "  - Arch / Manjaro / EndeavourOS"
  echo "  - Fedora / RHEL / CentOS / Rocky / AlmaLinux"
  echo "  - Alpine"
  echo "  - WSL2 (with above Linux distros)"
  echo ""
  echo "This script will:"
  echo "  1. Detect your OS and required package manager"
  echo "  2. Clone Devilbox repository to the workspace directory"
  echo "  3. Create .env file from env-example"
  echo "  4. Copy Magento2 docker-compose override file"
  echo "  5. Load CONTAINERS_CONFIG from env-example (source-of-truth)"
  echo "  6. Set environment variables in your shell profile"
  echo "  7. Configure NEW_UID and NEW_GID"
  echo "  8. On macOS: install Homebrew if missing"
  echo "  9. Create symlink to the dvl command"
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
      --non-interactive)
        NONINTERACTIVE=true
        shift
        ;;
      --workspace)
        if [ $# -lt 2 ] || [ -z "${2:-}" ]; then
          log_error "--workspace requires a path argument"
          usage
          exit 1
        fi
        WORKSPACE_OVERRIDE="$2"
        shift 2
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Env-var fallbacks (CLI wins)
  if [ "$NONINTERACTIVE" = false ] && [ "${DEVILBOX_NONINTERACTIVE:-0}" = "1" ]; then
    NONINTERACTIVE=true
  fi

  if [ -n "$WORKSPACE_OVERRIDE" ]; then
    WORKSPACE_DIR="$WORKSPACE_OVERRIDE"
  elif [ -n "${DEVILBOX_WORKSPACE:-}" ]; then
    WORKSPACE_DIR="$DEVILBOX_WORKSPACE"
  else
    WORKSPACE_DIR="$WORKSPACE_DIR_DEFAULT"
  fi
}

# Detect operating system family
detect_os() {
  local uname_s
  uname_s=$(uname -s 2>/dev/null || echo "unknown")

  if [ "$uname_s" = "Darwin" ]; then
    OS_FAMILY="darwin"
    OS_PRETTY="macOS ($(sw_vers -productVersion 2>/dev/null || echo 'unknown'))"
    IS_WSL=0
    return 0
  fi

  # WSL detection
  if [ -r /proc/version ] && grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
    IS_WSL=1
  fi

  # Distro detection from /etc/os-release
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    local id_val="${ID:-}"
    local id_like_val="${ID_LIKE:-}"
    local pretty_val="${PRETTY_NAME:-$id_val}"

    case "$id_val" in
      ubuntu|debian|linuxmint|pop|raspbian)
        OS_FAMILY="debian"
        ;;
      arch|manjaro|endeavouros|artix)
        OS_FAMILY="arch"
        ;;
      fedora|rhel|centos|rocky|almalinux|ol)
        OS_FAMILY="fedora"
        ;;
      alpine)
        OS_FAMILY="alpine"
        ;;
      *)
        case "$id_like_val" in
          *debian*) OS_FAMILY="debian" ;;
          *arch*) OS_FAMILY="arch" ;;
          *rhel*|*fedora*) OS_FAMILY="fedora" ;;
          *) OS_FAMILY="unknown" ;;
        esac
        ;;
    esac

    if [ "$IS_WSL" -eq 1 ]; then
      OS_PRETTY="${pretty_val} (WSL2)"
    else
      OS_PRETTY="$pretty_val"
    fi
  else
    if [ "$IS_WSL" -eq 1 ]; then
      OS_FAMILY="wsl2"
      OS_PRETTY="WSL2 (unknown distro)"
    else
      OS_FAMILY="unknown"
      OS_PRETTY="unknown ($uname_s)"
    fi
  fi
}

# Verify detected OS is supported; honor --force to bypass unknown.
check_supported_os() {
  log_step "Detecting Operating System"
  log_info "OS family : $OS_FAMILY"
  log_info "OS detail : $OS_PRETTY"
  if [ "$IS_WSL" -eq 1 ]; then
    log_info "Environment: WSL2"
  fi

  case "$OS_FAMILY" in
    darwin|debian|arch|fedora|alpine)
      log_success "Operating system is supported"
      ;;
    wsl2)
      if [ "$FORCE" = true ]; then
        log_warning "WSL2 detected but distro unknown; continuing due to --force"
      else
        log_error "WSL2 detected but distro unknown; re-run with --force to override"
        exit 1
      fi
      ;;
    unknown|*)
      if [ "$FORCE" = true ]; then
        log_warning "Unknown OS family; continuing due to --force"
      else
        log_error "Unsupported OS ($OS_PRETTY). Re-run with --force to override."
        exit 1
      fi
      ;;
  esac
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
    log_error "Docker is not installed. Please install Docker (Desktop on macOS/Windows; engine on Linux) first."
    exit 1
  fi
  log_success "Docker is installed"

  if [ "$IS_WSL" -eq 1 ]; then
    log_info "WSL2: make sure Docker Desktop's WSL2 integration is enabled for this distro."
  fi

  # Check if Docker is running
  if ! docker info &> /dev/null; then
    log_error "Docker is not running. Please start the Docker daemon/Desktop first."
    exit 1
  fi
  log_success "Docker is running"

  # On Linux (not WSL), require docker compose v2 plugin
  if [ "$OS_FAMILY" != "darwin" ] && [ "$IS_WSL" -eq 0 ]; then
    if ! docker compose version &> /dev/null; then
      log_error "docker compose v2 plugin not found."
      log_error "Install the 'docker-compose-plugin' package (or 'docker-compose-v2') and retry."
      exit 1
    fi
    log_success "docker compose v2 plugin detected"
  fi
}

# Step 1: Clone Devilbox repository
clone_devilbox() {
  log_step "Step 1: Cloning Devilbox Repository"

  if [ -d "$WORKSPACE_DIR" ] && [ "$FORCE" = false ]; then
    log_warning "Directory $WORKSPACE_DIR already exists"
    if [ "$NONINTERACTIVE" = true ]; then
      log_error "Non-interactive mode: refusing to overwrite. Re-run with --force to overwrite."
      exit 1
    fi
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

  local current_uid
  local current_gid
  current_uid=$(id -u)
  current_gid=$(id -g)

  log_info "Current UID: $current_uid"
  log_info "Current GID: $current_gid"

  # Update .env file with current UID and GID
  # Use a more portable approach that works reliably across BSD/GNU sed.
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

# Load CONTAINERS_CONFIG from the cloned env-example (source-of-truth).
_load_containers_from_env_example() {
  log_step "Loading CONTAINERS_CONFIG from env-example"

  local envfile="$WORKSPACE_DIR/env-example"
  if [ ! -r "$envfile" ]; then
    log_error "Cannot read $envfile to load CONTAINERS_CONFIG"
    exit 1
  fi

  local default_line
  local optional_line
  default_line=$(grep -E '^CONTAINERS_CONFIG_DEFAULT=' "$envfile" | head -n 1 || true)
  optional_line=$(grep -E '^CONTAINERS_CONFIG_OPTIONAL=' "$envfile" | head -n 1 || true)

  if [ -z "$default_line" ]; then
    log_error "CONTAINERS_CONFIG_DEFAULT not found in $envfile"
    log_error "Restore the CONTAINERS CONFIG banner near the top of env-example."
    exit 1
  fi
  if [ -z "$optional_line" ]; then
    log_error "CONTAINERS_CONFIG_OPTIONAL not found in $envfile"
    log_error "Restore the CONTAINERS CONFIG banner near the top of env-example."
    exit 1
  fi

  local default_val optional_val
  default_val=${default_line#CONTAINERS_CONFIG_DEFAULT=}
  optional_val=${optional_line#CONTAINERS_CONFIG_OPTIONAL=}
  # Strip surrounding single or double quotes
  default_val=${default_val%\"}; default_val=${default_val#\"}
  default_val=${default_val%\'}; default_val=${default_val#\'}
  optional_val=${optional_val%\"}; optional_val=${optional_val#\"}
  optional_val=${optional_val%\'}; optional_val=${optional_val#\'}

  CONTAINERS_CONFIG="${default_val} ${optional_val}"
  log_verbose "Default : $default_val"
  log_verbose "Optional: $optional_val"
  log_success "CONTAINERS_CONFIG resolved (${CONTAINERS_CONFIG})"
}

# Step 4: Setup shell profile
setup_shell_profile() {
  log_step "Step 4: Setting up Shell Profile"

  detect_shell_profile
  log_info "Using shell profile: $SHELL_PROFILE"

  # Ensure parent dir exists (fish lives under ~/.config/fish)
  mkdir -p "$(dirname "$SHELL_PROFILE")"
  # Create profile file if it doesn't exist
  touch "$SHELL_PROFILE"

  local user_shell
  user_shell=$(basename "${SHELL:-/bin/sh}")

  if [ "$user_shell" = "fish" ]; then
    # Fish syntax: `set -gx VAR value`
    if ! grep -q "DEVILBOX_CONTAINERS" "$SHELL_PROFILE"; then
      log_info "Adding DEVILBOX_CONTAINERS to $SHELL_PROFILE"
      {
        echo ""
        echo "# Devilbox configuration"
        echo "set -gx DEVILBOX_CONTAINERS \"$CONTAINERS_CONFIG\""
      } >> "$SHELL_PROFILE"
    else
      log_info "DEVILBOX_CONTAINERS already exists in $SHELL_PROFILE"
    fi

    if ! grep -q "DEVILBOX_PATH" "$SHELL_PROFILE"; then
      log_info "Adding DEVILBOX_PATH to $SHELL_PROFILE"
      echo "set -gx DEVILBOX_PATH \"$WORKSPACE_DIR\"" >> "$SHELL_PROFILE"
    else
      log_info "DEVILBOX_PATH already exists in $SHELL_PROFILE"
    fi
  else
    # POSIX `export VAR=value`
    if ! grep -q "DEVILBOX_CONTAINERS" "$SHELL_PROFILE"; then
      log_info "Adding DEVILBOX_CONTAINERS to $SHELL_PROFILE"
      {
        echo ""
        echo "# Devilbox configuration"
        echo "export DEVILBOX_CONTAINERS=\"$CONTAINERS_CONFIG\""
      } >> "$SHELL_PROFILE"
    else
      log_info "DEVILBOX_CONTAINERS already exists in $SHELL_PROFILE"
    fi

    if ! grep -q "DEVILBOX_PATH" "$SHELL_PROFILE"; then
      log_info "Adding DEVILBOX_PATH to $SHELL_PROFILE"
      echo "export DEVILBOX_PATH=\"$WORKSPACE_DIR\"" >> "$SHELL_PROFILE"
    else
      log_info "DEVILBOX_PATH already exists in $SHELL_PROFILE"
    fi
  fi

  log_success "Shell profile configured"
}

# Step 5: Verify (and on macOS install) the system package manager
install_package_manager() {
  log_step "Step 5: Verifying Package Manager"

  case "$OS_FAMILY" in
    darwin)
      if command -v brew &> /dev/null; then
        log_success "Homebrew is already installed"
      else
        log_info "Homebrew not found, installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
          export PATH="/opt/homebrew/bin:$PATH"
        elif [[ -f "/usr/local/bin/brew" ]]; then
          export PATH="/usr/local/bin:$PATH"
        fi
        log_success "Homebrew installed successfully"
      fi
      ;;
    debian)
      _require_pkg_manager apt-get "apt-get install -y git curl make"
      _require_tools_linux "apt-get install -y"
      ;;
    arch)
      _require_pkg_manager pacman "pacman -S --noconfirm git curl make"
      _require_tools_linux "pacman -S --noconfirm"
      ;;
    fedora)
      if command -v dnf &> /dev/null; then
        _require_tools_linux "dnf install -y"
      elif command -v yum &> /dev/null; then
        _require_tools_linux "yum install -y"
      else
        log_error "Neither dnf nor yum was found. Please install one of them and retry."
        exit 1
      fi
      ;;
    alpine)
      _require_pkg_manager apk "apk add git curl make"
      _require_tools_linux "apk add"
      ;;
    wsl2|unknown|*)
      log_warning "Skipping package-manager checks for OS family '$OS_FAMILY'"
      ;;
  esac
}

# Helper: ensure a given package manager binary exists.
_require_pkg_manager() {
  local pm="$1"
  local install_hint="$2"
  if ! command -v "$pm" &> /dev/null; then
    log_error "Required package manager '$pm' was not found on PATH."
    log_error "Install it via your distro, then retry. Hint: $install_hint"
    exit 1
  fi
  log_success "Package manager '$pm' detected"
}

# Helper: ensure baseline build tools exist on Linux; INSTRUCT, never auto-sudo.
_require_tools_linux() {
  local install_cmd="$1"
  local missing=()
  for tool in git curl make; do
    if ! command -v "$tool" &> /dev/null; then
      missing+=("$tool")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    log_error "Missing required tools: ${missing[*]}"
    log_error "Please run (as root): sudo $install_cmd ${missing[*]}"
    exit 1
  fi
  log_success "Baseline tools present (git, curl, make)"
}

# Step 6: Create symlink to dvl command
create_symlink() {
  log_step "Step 6: Creating DVL Command Symlink"

  local dvl_script="$WORKSPACE_DIR/dvl.sh"
  local dvl_symlink=""
  local target_bin_dir=""

  # Check if dvl.sh exists
  if [[ ! -f "$dvl_script" ]]; then
    log_error "dvl.sh not found in $WORKSPACE_DIR"
    exit 1
  fi

  case "$OS_FAMILY" in
    darwin)
      if [[ -d "/opt/homebrew/bin" ]]; then
        target_bin_dir="/opt/homebrew/bin"
      elif [[ -d "/usr/local/bin" ]]; then
        target_bin_dir="/usr/local/bin"
      else
        log_error "Cannot find Homebrew bin directory"
        exit 1
      fi
      ;;
    alpine)
      target_bin_dir="$HOME/.local/bin"
      mkdir -p "$target_bin_dir"
      ;;
    debian|arch|fedora|wsl2|unknown|*)
      if [ -w "/usr/local/bin" ]; then
        target_bin_dir="/usr/local/bin"
      else
        target_bin_dir="$HOME/.local/bin"
        mkdir -p "$target_bin_dir"
        log_info "Using $target_bin_dir (no write access to /usr/local/bin)."
        log_info "Ensure \$HOME/.local/bin is on your PATH (e.g. add to $SHELL_PROFILE)."
      fi
      ;;
  esac

  dvl_symlink="$target_bin_dir/dvl"

  # Create symlink
  log_info "Creating symlink: $dvl_symlink -> $dvl_script"
  ln -snf "$dvl_script" "$dvl_symlink"

  # Make sure the script is executable
  chmod +x "$dvl_script"

  # Expose for final_setup
  DVL_BIN_DIR="$target_bin_dir"

  log_success "DVL command symlink created"
}

# Final setup and instructions
final_setup() {
  log_step "Installation Complete!"

  echo ""
  echo "${GREEN}${BOLD}Devilbox has been successfully installed!${NORMAL}"
  echo ""
  echo "${CYAN}Detected environment:${NORMAL}"
  echo "  OS:        ${YELLOW}${OS_PRETTY}${NORMAL}"
  echo "  Family:    ${YELLOW}${OS_FAMILY}${NORMAL}"
  echo "  Workspace: ${YELLOW}${WORKSPACE_DIR}${NORMAL}"
  echo "  Profile:   ${YELLOW}${SHELL_PROFILE}${NORMAL}"
  echo "  DVL bin:   ${YELLOW}${DVL_BIN_DIR:-unknown}${NORMAL}"
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
  echo "${CYAN}New flags (for automation):${NORMAL}"
  echo "  ${YELLOW}--non-interactive${NORMAL}  Never prompt (env: DEVILBOX_NONINTERACTIVE=1)"
  echo "  ${YELLOW}--workspace <path>${NORMAL} Override target dir (env: DEVILBOX_WORKSPACE=<path>)"
  echo ""
}

# Main function
main() {
  echo "${CYAN}${BOLD}Devilbox Automated Installation Script${NORMAL}"
  echo ""

  parse_args "$@"
  detect_os
  check_supported_os
  check_prerequisites
  clone_devilbox
  setup_configuration
  configure_uid_gid
  _load_containers_from_env_example
  setup_shell_profile
  install_package_manager
  create_symlink
  final_setup

  log_success "Installation completed successfully!"
}

# Run main function with all arguments
main "$@"
