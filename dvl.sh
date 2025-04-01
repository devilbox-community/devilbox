#!/usr/bin/env bash

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  PURPLE=$(tput setaf 5)
  CYAN=$(tput setaf 6)
  LIGHT_GRAY=$(tput setaf 7)
  DARK_GRAY=$(tput setaf 0)
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  PURPLE=""
  CYAN=""
  LIGHT_GRAY=""
  DARK_GRAY=""
  BOLD=""
  NORMAL=""
fi

## Basic wrappers around exit codes

OK_CODE=0
KO_CODE=1

was_success() {
  local exit_code=$?
  [ "$exit_code" -eq "$OK_CODE" ]
}

was_error() {
  local exit_code=$?
  [ "$exit_code" -eq "$KO_CODE" ]
}

die() {
  local exit_code=$1
  if [ -n "$exit_code" ]; then
    exit "$exit_code"
  else
    exit "$?"
  fi
}

error() {
  local message=$1
  printf "%s %s\n" "${RED}[✘]" "${NORMAL}$message" >&2
  die "$KO_CODE"
}

success() {
  local message=$1
  printf "%s %s\n" "${GREEN}[✔]" "${NORMAL}$message"
}

info() {
  local message=$1
  printf "%s %s\n" "${YELLOW}[!]" "${NORMAL}$message"
}

question() {
  local message=$1
  printf "%s %s\n" "${CYAN}[?]" "${NORMAL}$message"
}

safe_cd() {
  local path=$1
  local error_msg=$2
  if [[ ! -d "$path" ]]; then
    error "$error_msg"
  fi
  cd "$path" >/dev/null || error "$error_msg"
}

function get_workspace_path() {
  if [[ ! -z "$DEVILBOX_PATH" ]]; then
    printf %s "${DEVILBOX_PATH}"
  else
    printf %s "$HOME/.devilbox"
  fi
}

function get_yq_version() {
  printf %s "$( \
    curl -sS 'https://github.com/mikefarah/yq/releases' \
    | grep -Eo '/mikefarah/yq/releases/tag/v?[.0-9]+"' \
    | grep -Eo 'v?[.0-9]+' \
    | sort -V \
    | tail -1 \
  )"
}

function download_yq() {
  echo -ne "${YELLOW}${BOLD}[!] Downloading YQ binary..."

  local uname
  local aarch
  local DEB_HOST_ARCH

  uname="$(uname)"
  aarch="$(uname -m)"

  if [ "${uname}" = "Linux" ]; then
    if ! command -v dpkg-architecture 2>&1 >/dev/null; then
      DEB_HOST_ARCH="$aarch"
    else
      DEB_HOST_ARCH="$( dpkg-architecture --query DEB_HOST_ARCH )"
    fi
  elif [ "${uname}" = "Darwin" ]; then
    DEB_HOST_ARCH="$aarch"
  fi

  if [ "${aarch}" = "i386" ] || [ "$aarch" = "x86_64" ]; then
    DEB_HOST_ARCH="amd64"
  fi

  if [ "${DEB_HOST_ARCH}" = "amd64" ] || [ "${DEB_HOST_ARCH}" = "arm64" ]; then
    YQ_UNAME=$(echo "$uname" | tr '[:upper:]' '[:lower:]')
    if [[ ! -d "$DEVILBOX_PATH/.tests/binaries/" ]]; then
      mkdir -p "$DEVILBOX_PATH/.tests/binaries/"
    fi

    # Set up the URL
    YQ_URL="https://github.com/mikefarah/yq/releases/download/$(get_yq_version)/yq_${YQ_UNAME}_${DEB_HOST_ARCH}"

    # Download in background with spinner
    (curl -sS -L --fail "${YQ_URL}" > "$DEVILBOX_PATH/.tests/binaries/yq") &
    spinner
  else
    # No supported architecture found
    echo -ne "...${NORMAL} ${RED}FAILED ✘${NORMAL}"
    echo ""
    echo "${RED}Unsupported architecture: ${aarch}${NORMAL}"
    return 1
  fi

  # Set permissions after download is complete
  chmod +x "$DEVILBOX_PATH/.tests/binaries/yq"

  echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
  echo ""
}

# Checker
if [[ -z "$DEVILBOX_PATH" ]]; then
  error "Devilbox not found, please make sure it is installed in your home directory or use DEVILBOX_PATH in your profile."
fi
#safe_cd "$(get_workspace_path)" "Devilbox not found, please make sure it is installed in your home directory or use DEVILBOX_PATH in your profile."

DVLBOX_PATH="$( cd "${DEVILBOX_PATH}" && pwd -P )"
SCRIPT_PATH="$( cd "${DVLBOX_PATH}/.tests/scripts" && pwd -P )"
# shellcheck disable=SC1090
source "${SCRIPT_PATH}/.lib.sh"

# Check and download yq binary
if [[ ! -f "$DEVILBOX_PATH/.tests/binaries/yq" ]]; then
  download_yq
fi

# -------------------------------------------------------------------------------------------------
# ENTRYPOINT
# -------------------------------------------------------------------------------------------------

###
### Get required env values
###
HTTPD_SERVER="$( "${SCRIPT_PATH}/env-getvar.sh" "HTTPD_SERVER" )"
HTTPD_TEMPLATE_DIR="$( "${SCRIPT_PATH}/env-getvar.sh" "HTTPD_TEMPLATE_DIR" )"
HTTPD_DOCROOT_DIR="$( "${SCRIPT_PATH}/env-getvar.sh" "HTTPD_DOCROOT_DIR" )"
TLD_SUFFIX="$( "${SCRIPT_PATH}/env-getvar.sh" "TLD_SUFFIX" )"
MYSQL_ROOT_PASSWORD="$( "${SCRIPT_PATH}/env-getvar.sh" "MYSQL_ROOT_PASSWORD" )"
WEBAPP_DIR="$(get_workspace_path)/data/www"
HTTPD_WORKDIR="/shared/httpd"
BACKUP_WORKDIR="/shared/backups"
AWS_BASEDIR="src"
WEBAPP_STACK=""
MAGE_MODE=""
MAGE_INFRA=""
WEB_MULTI="N"
APPNAME="$$$"
PARENT_APPNAME="$$$"
APPREPOSITORY=""
DBNAME="$$$"
APPDOMAINS=""
APPDOMAINS_CRT=""
PUBLICPATH="current"
PHP_VERSION=""
PROXY_PORT="3000"
CURRENT_DIR="$(pwd)"
PROJECT_DIR="${CURRENT_DIR/$WEBAPP_DIR\///}"
TARGET_WORKDIR="$HTTPD_WORKDIR$PROJECT_DIR"
CONFIG_FILE=".devilbox.yaml"
TEMPLATE_CONFIG="$DEVILBOX_PATH/.tests/devilbox-template-config.yaml"
YQ_BINARY="$DEVILBOX_PATH/.tests/binaries/yq"

# Read-only variables
readonly VERSION="1.2.4"

function main {
  if [[ $# -eq 0 ]] ; then
      Usage --ansi
      echo "${BOLD}"
      $YQ_BINARY --version
      echo "${NORMAL}"
  else
    case "$1" in
      up|start)
        shift;
        StartServices "$@"
      ;;
      down|stop)
        shift;
        StopServices "$@"
      ;;
      restart)
        shift;
        RestartServices "$@"
      ;;
      reset)
        ResetServices "$@"
      ;;
      doctor)
        DoctorForBox "$@"
      ;;
      init)
        shift;
        InitializeProject "$@"
      ;;
      exec)
        shift;
        ExecShell "$@"
      ;;
      db:import|db-import)
        shift;
        DatabaseImport "$@"
      ;;
      magento)
        shift;
        MagentoCommand "$@"
      ;;
      magerun)
        shift;
        MagerunCommand "$@"
      ;;
      composer)
        shift;
        ComposerCommand "$@"
      ;;
      ece-tools|ecetools)
        shift;
        EceToolsCommand "$@"
      ;;
      cloud-patches|ece-patches|ecepatches)
        shift;
        EcePatchesCommand "$@"
      ;;
      shell)
        shift;
        OpenShell "$@"
      ;;
      generate-yaml)
        shift;
        CreateYamlConf "$@"
      ;;
      sync-httpd)
        shift;
        SyncHttpdConf "$@"
      ;;
      sync-env)
        shift;
        SyncEnvConf "$@"
      ;;
      update:docroot|update-docroot)
        shift;
        UpdateDocRoots "$@"
      ;;
      --no-ansi)
        Usage --no-ansi
      ;;
      help|-h|--help|--ansi)
        Usage --ansi
      ;;
      *)
        error "Unknown command $1, see -h for help."
      ;;
    esac
  fi
}

function __get_default_containers {
  if [[ ! -z "$DEVILBOX_CONTAINERS" ]]; then
    printf %s "${DEVILBOX_CONTAINERS}"
  else
    printf %s "bind httpd php php74 php81 php82 php83 mysql redis opensearch mailhog"
  fi
}

function BaseCommand {
  (cd "$DEVILBOX_PATH"; docker "$@")
}

function BaseComposeCommand {
  if hash docker-compose 2>/dev/null; then
    (cd "$DEVILBOX_PATH"; docker-compose "$@")
  else
    (cd "$DEVILBOX_PATH"; docker compose "$@")
  fi
}

function StartServices {
  BaseComposeCommand up $(__get_default_containers) -d
}

function StopServices {
  BaseComposeCommand down && BaseComposeCommand rm -f
}

function RestartServices {
  if [[ -n "$*" ]]; then
    BaseCommand restart "$@"
  else
    StopServices && StartServices
  fi
}

function GetPhpVersionFromYaml {
  local debug_mode=${1:-false}
  
  # Check in current directory first
  local yaml_file="$CURRENT_DIR/$CONFIG_FILE"
  
  # If not found, check parent directory (common for Magento AWS projects)
  if [[ ! -f "$yaml_file" ]]; then
    yaml_file="$(dirname "$CURRENT_DIR")/$CONFIG_FILE"
  fi
  
  # If still not found and we're in htdocs or a subdirectory
  if [[ ! -f "$yaml_file" ]]; then
    # Check if current dir matches htdocs name
    if [[ "$(basename "$CURRENT_DIR")" == "$HTTPD_DOCROOT_DIR" ]]; then
      # We're in htdocs, try the parent directory
      yaml_file="$(dirname "$CURRENT_DIR")/$CONFIG_FILE"
    elif [[ "$(basename "$(dirname "$CURRENT_DIR")")" == "$HTTPD_DOCROOT_DIR" ]]; then
      # We're in a subdirectory of htdocs, try going up two levels
      yaml_file="$(dirname "$(dirname "$CURRENT_DIR")")/$CONFIG_FILE"
    fi
  fi
  
  # Debug mode to help troubleshoot version detection
  if [[ "$debug_mode" == "true" ]]; then
    echo "Current directory: $CURRENT_DIR" >&2
    echo "Document root dir: $HTTPD_DOCROOT_DIR" >&2
    echo "Checking multiple locations for YAML file" >&2
    echo "1. Current directory: $CURRENT_DIR/$CONFIG_FILE" >&2
    echo "2. Parent directory: $(dirname "$CURRENT_DIR")/$CONFIG_FILE" >&2
    
    if [[ -f "$yaml_file" ]]; then
      echo "Found YAML file at: $yaml_file" >&2
      echo "PHP version in YAML: $("$YQ_BINARY" '.php.version' "$yaml_file")" >&2
    else
      echo "YAML file not found in any of the checked locations" >&2
    fi
  fi

  # First check if we're in a project with a yaml file
  if [[ -f "$yaml_file" ]]; then
    local php_version=$("$YQ_BINARY" '.php.version' "$yaml_file")
    
    # If we have a valid PHP version in the yaml file
    if [[ -n "$php_version" && "$php_version" != "null" ]]; then
      # Get the PHP_SERVER from .env file (default PHP version)
      local php_server="$( "${SCRIPT_PATH}/env-getvar.sh" "PHP_SERVER" )"
      
      if [[ "$debug_mode" == "true" ]]; then
        echo "Default PHP server from .env: $php_server" >&2
      fi

      # If php_version matches the pattern phpXX
      if [[ "$php_version" =~ ^php[0-9]{2}$ ]]; then
        # Extract numeric part from php_version (e.g., "74" from "php74")
        local yaml_version_num="${php_version#php}"
        
        # Convert env PHP version to same format (e.g., "7.4" to "74")
        local env_version_num=$(echo "$php_server" | sed 's/\.//g')

        if [[ "$debug_mode" == "true" ]]; then
          echo "YAML PHP version num: $yaml_version_num" >&2
          echo "ENV PHP version num: $env_version_num" >&2
        fi

        # If versions match, use default "php" container
        if [[ "$yaml_version_num" == "$env_version_num" ]]; then
          echo "php"
        else
          echo "$php_version"
        fi
        return 0
      else
        # Invalid PHP version format in yaml
        if [[ "$debug_mode" == "true" ]]; then
          echo "Invalid PHP version format in YAML" >&2
        fi
        echo "php"
        return 1
      fi
    fi
  fi

  # Default fallback
  echo "php"
  return 1
}

function CheckPhpContainerFlavor {
  local php_container="$1"
  local debug=${2:-false}

  if [[ "$debug" == "true" ]]; then
    echo "Checking flavor for container: $php_container" >&2
  fi

  # Skip check for default php container
  if [[ "$php_container" == "php" ]]; then
    if [[ "$debug" == "true" ]]; then
      echo "Default PHP container, assuming work flavor" >&2
    fi
    echo "work"
    return 0
  fi

  # Get current container image from docker-compose config
  local container_image=""
  local config_output=""
  
  if hash docker-compose 2>/dev/null; then
    if [[ "$debug" == "true" ]]; then
      echo "Using docker-compose to get config" >&2
    fi
    config_output=$(cd "$DEVILBOX_PATH" && docker-compose config)
  else
    if [[ "$debug" == "true" ]]; then
      echo "Using docker compose to get config" >&2
    fi
    config_output=$(cd "$DEVILBOX_PATH" && docker compose config)
  fi
  
  # First, try to extract service and image using a different pattern
  if [[ "$debug" == "true" ]]; then
    echo "Trying to find $php_container in docker-compose config" >&2
  fi
  
  # Save the config to a temp file for easier debugging
  local temp_config=$(mktemp)
  echo "$config_output" > "$temp_config"
  
  if [[ "$debug" == "true" ]]; then
    echo "Docker compose config written to temp file at: $temp_config" >&2
    echo "Checking with grep -A 20 '$php_container:'" >&2
  fi
  
  # Try various patterns to match the container
  container_image=$(grep -A 20 "$php_container:" "$temp_config" | grep -m 1 "image:" | sed 's/image://g' | sed 's/^[[:space:]]*//g')
  
  if [[ -z "$container_image" ]]; then
    if [[ "$debug" == "true" ]]; then
      echo "First attempt failed, trying with different pattern" >&2
    fi
    container_image=$(grep -A 20 "  $php_container:" "$temp_config" | grep -m 1 "image:" | sed 's/image://g' | sed 's/^[[:space:]]*//g')
  fi
  
  if [[ -z "$container_image" ]]; then
    if [[ "$debug" == "true" ]]; then
      echo "Second attempt failed, trying with looser pattern" >&2
    fi
    # More aggressive pattern
    container_image=$(grep -A 50 -i "$php_container" "$temp_config" | grep -m 1 "image:" | sed 's/image://g' | sed 's/^[[:space:]]*//g')
  fi
  
  # Clean up
  rm -f "$temp_config"

  if [[ "$debug" == "true" ]]; then
    echo "Found container image: $container_image" >&2
  fi

  # Still no image found
  if [[ -z "$container_image" ]]; then
    if [[ "$debug" == "true" ]]; then
      echo "Could not determine container image for $php_container" >&2
    fi
    echo "unknown"
    return 2  # Could not determine image
  fi

  # Check if container is using work or slim flavor
  if [[ "$container_image" == *"-slim-"* ]]; then
    if [[ "$debug" == "true" ]]; then
      echo "Container using slim flavor" >&2
    fi
    echo "slim"
    return 1  # Not work flavor - THIS IS CRITICAL: must return 1 for slim
  elif [[ "$container_image" == *"-work-"* ]]; then
    if [[ "$debug" == "true" ]]; then
      echo "Container using work flavor" >&2
    fi
    echo "work"
    return 0  # Is work flavor - returning 0 for work
  fi

  # Default response for unknown flavor
  if [[ "$debug" == "true" ]]; then
    echo "Unknown container flavor" >&2
  fi
  echo "unknown"
  return 2  # Unknown flavor
}

function UpdateContainerFlavor {
  local php_container="$1"
  local target_flavor="$2"
  
  # Use get_workspace_path to get the correct path
  local devilbox_path=$(get_workspace_path)
  local override_file="$devilbox_path/docker-compose.override.yml"

  echo "Updating container flavor for $php_container to $target_flavor" >&2
  echo "Using Devilbox path: $devilbox_path" >&2
  echo "Override file: $override_file" >&2

  # Create the override file if it doesn't exist
  if [[ ! -f "$override_file" ]]; then
    echo "Override file not found. Creating minimal override file..." >&2
    
    # Create a minimal docker-compose.override.yml file
    cat > "$override_file" <<EOL
version: '2.3'
services:
EOL
    
    echo "Created new override file" >&2
  fi

  # Get current container image using more robust pattern matching
  local current_image=""
  local config_output=""
  
  if hash docker-compose 2>/dev/null; then
    config_output=$(cd "$devilbox_path" && docker-compose config 2>/dev/null)
  else
    config_output=$(cd "$devilbox_path" && docker compose config 2>/dev/null)
  fi
  
  # Save the config to a temp file for easier debugging
  local temp_config=$(mktemp)
  echo "$config_output" > "$temp_config"
  
  # Try various patterns to match the container image
  current_image=$(grep -A 20 "$php_container:" "$temp_config" | grep -m 1 "image:" | sed 's/image://g' | sed 's/^[[:space:]]*//g')
  
  if [[ -z "$current_image" ]]; then
    current_image=$(grep -A 20 "  $php_container:" "$temp_config" | grep -m 1 "image:" | sed 's/image://g' | sed 's/^[[:space:]]*//g')
  fi
  
  if [[ -z "$current_image" ]]; then
    # More aggressive pattern
    current_image=$(grep -A 50 -i "$php_container" "$temp_config" | grep -m 1 "image:" | sed 's/image://g' | sed 's/^[[:space:]]*//g')
  fi
  
  # Clean up
  rm -f "$temp_config"

  echo "Current image from config: $current_image" >&2

  if [[ -z "$current_image" ]]; then
    echo "Could not find image for $php_container in docker-compose config" >&2
    # Try to extract information from container name
    local version_num=${php_container#php}
    if [[ "$version_num" =~ ^[0-9]{2}$ ]]; then
      # Convert to decimal format (74 -> 7.4)
      local major="${version_num:0:1}"
      local minor="${version_num:1:1}"
      local version="$major.$minor"
      echo "Using version $version derived from container name" >&2
      current_image="devilboxcommunity/php-fpm:$version-slim-0.155"
    else
      # Get default PHP version if container name doesn't contain version
      local default_php="$( "${SCRIPT_PATH}/env-getvar.sh" "PHP_SERVER" )"
      echo "Using default PHP version: $default_php" >&2
      current_image="devilboxcommunity/php-fpm:$default_php-slim-0.155"
    fi
    echo "Using derived image: $current_image" >&2
  fi

  # Extract version and build number
  local version_build=$(echo "$current_image" | sed -E 's/.*:([0-9.]+)-[a-z]+-([0-9.]+)/\1-\2/')
  local version=$(echo "$version_build" | cut -d'-' -f1)
  local build=$(echo "$version_build" | cut -d'-' -f2)

  echo "Extracted version: $version, build: $build" >&2

  # Create new image name
  local new_image="devilboxcommunity/php-fpm:$version-$target_flavor-$build"

  echo "New image will be: $new_image" >&2
  echo -ne "${YELLOW}Updating $php_container image to $target_flavor flavor..."

  # Make a backup of the original file
  if [[ -f "$override_file" && -s "$override_file" ]]; then
    cp "$override_file" "${override_file}.bak"
  fi
  
  # Process YAML with careful line-by-line approach to maintain structure
  local temp_file=$(mktemp)
  local in_container_section=0
  local image_line_found=0
  local indent_level=""
  
  while IFS= read -r line; do
    # Detect if we're entering the container section
    if [[ "$line" =~ ^[[:space:]]*"$php_container:"($|[[:space:]]) ]]; then
      in_container_section=1
      # Capture the indent level for this section
      indent_level=$(echo "$line" | sed -E 's/^([[:space:]]*)'"$php_container"'.*/\1/')
      echo "$line" >> "$temp_file"
      continue
    fi
    
    # If we're in the container section and find an image line, replace it
    if [[ $in_container_section -eq 1 && "$line" =~ ^[[:space:]]*image: ]]; then
      # Maintain the existing indentation
      local img_indent=$(echo "$line" | sed -E 's/^([[:space:]]*)image:.*/\1/')
      echo "${img_indent}image: $new_image" >> "$temp_file"
      image_line_found=1
      continue
    fi
    
    # If we encounter another service or the end of the services section, we're exiting our container section
    if [[ $in_container_section -eq 1 && ( "$line" =~ ^[[:space:]]*[a-zA-Z0-9_-]+:($|[[:space:]]) || "$line" =~ ^[^[:space:]#] ) ]]; then
      # If we didn't find an image line, add it before moving on
      if [[ $image_line_found -eq 0 ]]; then
        # Use parent indentation plus 2 spaces for the image line
        echo "${indent_level}  image: $new_image" >> "$temp_file"
        image_line_found=1
      fi
      in_container_section=0
    fi
    
    # Write the current line to the output file
    echo "$line" >> "$temp_file"
  done < "$override_file"
  
  # If we're still in the container section at the end of the file and haven't added an image line
  if [[ $in_container_section -eq 1 && $image_line_found -eq 0 ]]; then
    echo "${indent_level}  image: $new_image" >> "$temp_file"
  fi
  
  # If we never found the container section, add it at the end of the file
  if [[ $in_container_section -eq 0 && $image_line_found -eq 0 ]]; then
    # Check if there's a services: line
    if grep -q "^services:" "$override_file"; then
      # Add to existing services section
      echo "  $php_container:" >> "$temp_file"
      echo "    <<: *default-php" >> "$temp_file"
      echo "    image: $new_image" >> "$temp_file"
    else
      # Create a completely new section
      echo "services:" >> "$temp_file"
      echo "  $php_container:" >> "$temp_file"
      echo "    <<: *default-php" >> "$temp_file"
      echo "    image: $new_image" >> "$temp_file"
    fi
  fi
  
  # Replace the original file with our new one
  mv "$temp_file" "$override_file"

  echo -e "...${NORMAL} ${GREEN}DONE ✔${NORMAL}\n"
  echo -ne "${YELLOW}Pulling new image: $new_image..."

  # Pull the new image with error handling
  if hash docker-compose 2>/dev/null; then
    if ! (cd "$devilbox_path" && docker-compose pull "$php_container"); then
      echo -e "...${NORMAL} ${RED}FAILED ✘${NORMAL}\n"
      echo "Warning: Failed to pull new image. Check Docker connectivity." >&2
      # Continue anyway - don't return error
    fi
  else
    if ! (cd "$devilbox_path" && docker compose pull "$php_container"); then
      echo -e "...${NORMAL} ${RED}FAILED ✘${NORMAL}\n"
      echo "Warning: Failed to pull new image. Check Docker connectivity." >&2
      # Continue anyway - don't return error
    fi
  fi

  echo -e "...${NORMAL} ${GREEN}DONE ✔${NORMAL}\n"
  echo "${YELLOW}Restarting $php_container container...${NORMAL}"

  # Restart the container with error handling
  if hash docker-compose 2>/dev/null; then
    if ! (cd "$devilbox_path" && docker-compose up -d "$php_container"); then
      echo -e "${RED}FAILED ✘${NORMAL}\n"
      echo "Warning: Failed to restart container $php_container." >&2
      # Continue anyway - don't return error
    fi
  else
    if ! (cd "$devilbox_path" && docker compose up -d "$php_container"); then
      echo -e "${RED}FAILED ✘${NORMAL}\n"
      echo "Warning: Failed to restart container $php_container." >&2
      # Continue anyway - don't return error
    fi
  fi

  echo "${GREEN}Successfully updated container settings${NORMAL}"
  
  # Wait for container to be ready
  echo "${YELLOW}Waiting for $php_container container to be ready...${NORMAL}"
  sleep 5

  # Clean up backup file if it exists
  if [[ -f "${override_file}.bak" ]]; then
    rm -f "${override_file}.bak"
  fi

  return 0
}

function CommandRequiringWorkFlavor {
  local command_type="$1"
  local php_version="$2"
  local args="${@:3}"

  # Check if container has work flavor
  local flavor=$(CheckPhpContainerFlavor "$php_version")
  local has_work_flavor=$?

  # Debug output
  echo "Detected PHP container: $php_version with flavor: $flavor (return code: $has_work_flavor)" >&2

  # Fixed condition - check actual flavor string instead of relying only on return code
  if [[ "$flavor" == "slim" ]] || [[ "$flavor" == "unknown" ]]; then
    echo -ne "${YELLOW}$command_type requires 'work' flavor, but $php_version is using $flavor flavor.${NORMAL}\n"
    read -r -p "${CYAN}Would you like to update $php_version to 'work' flavor? [Y/n]${NORMAL} " response
    case "$response" in
      [nN][oO]|[nN])
        error "$command_type requires work flavor. Command aborted."
        return 1
        ;;
      *)
        # Update container flavor and continue if successful
        if ! UpdateContainerFlavor "$php_version" "work"; then
          error "Failed to update container flavor. Command aborted."
          return 1
        fi
        # Additional debug output to confirm flavor was updated
        echo "Container flavor updated successfully, proceeding with command" >&2
        ;;
    esac
  fi

  case "$command_type" in
    "magento")
      BaseComposeCommand exec --workdir "$TARGET_WORKDIR" --user devilbox "$php_version" bash -c "php -dmemory_limit=-1 bin/magento $args"
      ;;
    "magerun")
      BaseComposeCommand exec --workdir "$TARGET_WORKDIR" --user devilbox "$php_version" bash -c "php -dmemory_limit=-1 /usr/local/bin/magerun $args"
      ;;
    "composer")
      BaseComposeCommand exec --workdir "$TARGET_WORKDIR" --user devilbox "$php_version" bash -c "composer $args"
      ;;
    "ece-tools")
      BaseComposeCommand exec --workdir "$TARGET_WORKDIR" --user devilbox "$php_version" bash -c "php -dmemory_limit=-1 ./vendor/bin/ece-tools $args"
      ;;
    "ece-patches")
      BaseComposeCommand exec --workdir "$TARGET_WORKDIR" --user devilbox "$php_version" bash -c "php -dmemory_limit=-1 ./vendor/bin/ece-patches $args"
      ;;
    *)
      error "Unknown command type: $command_type"
      return 1
      ;;
  esac
}

function OpenShell {
  if [[ -z "$*" ]]; then
    local php_version=$(GetPhpVersionFromYaml)

    if [[ "$php_version" != "php" ]]; then
      read -r -p "${CYAN}Use detected PHP version $php_version instead of default PHP? [Y/n]${NORMAL} " response
      case "$response" in
        [nN][oO]|[nN])
          php_version="php"
          ;;
        *)
          ;;
      esac
    fi

    echo "${YELLOW}Opening shell with $php_version${NORMAL}"
    BaseComposeCommand exec --user devilbox "$php_version" bash -l
  else
    BaseComposeCommand exec --user devilbox "$1" bash -l
  fi
}

function ExecShell {
  local php_version=$(GetPhpVersionFromYaml)

  if [[ "$php_version" != "php" ]]; then
    read -r -p "${CYAN}Use detected PHP version $php_version instead of default PHP? [Y/n]${NORMAL} " response
    case "$response" in
      [nN][oO]|[nN])
        php_version="php"
        ;;
      *)
        ;;
    esac
  fi

  info "Workdir: $TARGET_WORKDIR using $php_version"
  BaseComposeCommand exec --user devilbox "$php_version" bash -c "cd $TARGET_WORKDIR; $*"
}

function ExecShellTTY {
  BaseComposeCommand exec --no-TTY --user devilbox php bash -c "$@"
}

function MagentoCommand {
  local php_version=$(GetPhpVersionFromYaml)

  if [[ "$php_version" != "php" ]]; then
    read -r -p "${CYAN}Use detected PHP version $php_version instead of default PHP? [Y/n]${NORMAL} " response
    case "$response" in
      [nN][oO]|[nN])
        php_version="php"
        ;;
      *)
        ;;
    esac
  fi

  CommandRequiringWorkFlavor "magento" "$php_version" "$@"
}

function MagerunCommand {
  local php_version=$(GetPhpVersionFromYaml)

  if [[ "$php_version" != "php" ]]; then
    read -r -p "${CYAN}Use detected PHP version $php_version instead of default PHP? [Y/n]${NORMAL} " response
    case "$response" in
      [nN][oO]|[nN])
        php_version="php"
        ;;
      *)
        ;;
    esac
  fi

  CommandRequiringWorkFlavor "magerun" "$php_version" "$@"
}

function ComposerCommand {
  local php_version=$(GetPhpVersionFromYaml)

  if [[ "$php_version" != "php" ]]; then
    read -r -p "${CYAN}Use detected PHP version $php_version instead of default PHP? [Y/n]${NORMAL} " response
    case "$response" in
      [nN][oO]|[nN])
        php_version="php"
        ;;
      *)
        ;;
    esac
  fi

  CommandRequiringWorkFlavor "composer" "$php_version" "$@"
}

function EceToolsCommand {
  local php_version=$(GetPhpVersionFromYaml)

  if [[ "$php_version" != "php" ]]; then
    read -r -p "${CYAN}Use detected PHP version $php_version instead of default PHP? [Y/n]${NORMAL} " response
    case "$response" in
      [nN][oO]|[nN])
        php_version="php"
        ;;
      *)
        ;;
    esac
  fi

  CommandRequiringWorkFlavor "ece-tools" "$php_version" "$@"
}

function EcePatchesCommand {
  local php_version=$(GetPhpVersionFromYaml)

  if [[ "$php_version" != "php" ]]; then
    read -r -p "${CYAN}Use detected PHP version $php_version instead of default PHP? [Y/n]${NORMAL} " response
    case "$response" in
      [nN][oO]|[nN])
        php_version="php"
        ;;
      *)
        ;;
    esac
  fi

  CommandRequiringWorkFlavor "ece-patches" "$php_version" "$@"
}

function DatabaseImport {
  if [[ "$#" -lt 2 ]]; then
    info "Ensure your backup file exists in ./backups directory on host machine."
    error "Missing required arguments filename /or database name. E.g dvl db:import <filename> <database_name>"
  fi

  local filename="$1"
  local dbname="$2"

  if [[ "$filename" == *.sql ]]; then
    echo -ne "${YELLOW}${BOLD}[!] Importing $filename into $dbname..."
    (ExecShellTTY "mysql --host=mysql --user=root --password='$MYSQL_ROOT_PASSWORD' -e 'CREATE DATABASE IF NOT EXISTS ${dbname}'" && ExecShellTTY "mysql --host=mysql --user=root --password='$MYSQL_ROOT_PASSWORD' --default-character-set=utf8 --force $dbname < $BACKUP_WORKDIR/$filename") &
    spinner
    echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
    echo ""
  elif [[ "$filename" == *.sql.gz ]]; then
    echo -ne "${YELLOW}${BOLD}[!] Extracting $filename and importing it into $dbname..."
    (ExecShellTTY "mysql --host=mysql --user=root --password='$MYSQL_ROOT_PASSWORD' -e 'CREATE DATABASE IF NOT EXISTS ${dbname}'" && ExecShellTTY "zcat $BACKUP_WORKDIR/$filename | mysql --host=mysql --user=root --password='$MYSQL_ROOT_PASSWORD' --default-character-set=utf8 --force $dbname") &
    spinner
    echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
    echo ""
  else
    error "File type (name: ${filename}) does not supported yet."
  fi
}

function InteractiveQuestions {
  # Define the app name
  while [[ $APPNAME =~ [^-.a-z0-9] ]] || [[ $APPNAME == '' ]]
  do
    read -r -p "${CYAN}Please enter your webapp name (lowercase, alphanumeric):${NORMAL} " APPNAME
  done
  APPDOMAINS="https://$APPNAME.$TLD_SUFFIX"
  echo -ne "${YELLOW}Your webapp name set to: $APPNAME"
  echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
  echo ""

  echo -ne "${YELLOW}Domain of webapp set to: $APPDOMAINS"
  echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
  echo ""

  # Choose a web application stack
  read -r -p "${CYAN}Please choose web application stack (magento, nodejs, laravel, shopify, bigcommerce, phpweb)? [magento]${NORMAL} " response
  case "$response" in
    nodejs)
      WEBAPP_STACK="nodejs"
      echo -ne "${YELLOW}Node.js General Application"
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
    laravel)
      WEBAPP_STACK="laravel"
      echo -ne "${YELLOW}Laravel"
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
    shopify)
      WEBAPP_STACK="shopify"
      echo -ne "${YELLOW}Shopify"
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
    bigcommerce)
      WEBAPP_STACK="bigcommerce"
      echo -ne "${YELLOW}BigCommerce"
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
    phpweb)
      WEBAPP_STACK="phpweb"
      echo -ne "${YELLOW}General PHP Application"
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
    magento|*)
      WEBAPP_STACK="magento"
      echo -ne "${YELLOW}Magento 2 (Pre-configured for production-grade Magento 2 application)"
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
  esac

  # Setup subdomain configuration
  read -r -p "${CYAN}Is this webapp a sub-domain of another web application (Y/N)? [N]${NORMAL} " response
  case "$response" in
    [yY][eE][sS]|[yY])
      WEB_MULTI="Y"
      echo -ne "${YELLOW}Your current webapp is configured to be a sub-domain of another web application."
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
    [nN][oO]|[nN]|*)
      WEB_MULTI="N"
      echo -ne "${YELLOW}Your current webapp is not configured to be a sub-domain of another web application."
      echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
      echo ""
      ;;
  esac
  if [[ "$WEB_MULTI" == "Y" ]]; then
    while [[ $PARENT_APPNAME =~ [^-.a-z0-9] ]] || [[ $PARENT_APPNAME == '' ]]
    do
      read -r -p "${CYAN}What is the main-entry webapp name?${NORMAL} " PARENT_APPNAME
    done
    echo -ne "${YELLOW}Your parent webapp name set to: $PARENT_APPNAME"
    echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
    echo ""
  fi

  if [[ "$WEBAPP_STACK" == "magento" ]]; then
    # Set Magento Mode
    read -r -p "${CYAN}Which deploy mode you would like to setup (developer, production)? [production]${NORMAL} " response
    case "$response" in
      developer|dev)
        MAGE_MODE="developer"
        echo -ne "${YELLOW}Your Magento application mode has been set to ${MAGE_MODE}"
        echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
        echo ""
        ;;
      production|prod|*)
        MAGE_MODE="production"
        echo -ne "${YELLOW}Your Magento application mode has been set to ${MAGE_MODE}"
        echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
        echo ""
        ;;
    esac
  fi

  if [[ "$WEBAPP_STACK" != "bigcommerce" ]] && [[ "$WEBAPP_STACK" != "nodejs" ]] && [[ "$WEBAPP_STACK" != "shopify" ]] && [[ "$WEBAPP_STACK" != "laravel" ]]; then
    # Set Infra Mode
    read -r -p "${CYAN}What is the infrastructure of your Magento project (aws, cloud)? [cloud]${NORMAL} " response
    case "$response" in
      aws)
        MAGE_INFRA="aws"
        echo -ne "${YELLOW}Your infrastructure type has been set to ${MAGE_INFRA}"
        echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
        echo ""
        ;;
      cloud|*)
        MAGE_INFRA="cloud"
        echo -ne "${YELLOW}Your infrastructure type has been set to ${MAGE_INFRA}"
        echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
        echo ""
        ;;
    esac
  fi

  if [[ "$WEB_MULTI" == "N" ]]; then
    # Define the app repository
    while [[ $APPREPOSITORY == '' ]]
    do
      read -r -p "${CYAN}Please enter your webapp repository (git@github.com:org/repo.git):${NORMAL} " APPREPOSITORY
    done
    APPREPOSITORY=${APPREPOSITORY//"git clone "}
    echo -ne "${YELLOW}Your webapp repository set to: $APPREPOSITORY"
    echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
    echo ""
  fi

  # Choose PHP version
  read -r -p "${CYAN}Please choose PHP version of your webapp? [8.1]${NORMAL} " response
  case "$response" in
    5.2|52|5.3|53|5.4|54|5.5|55|5.6|56)
      PHP_VERSION=$(awk '{gsub(/[.]/,"");print $NF}' <<< "php$response")
      ;;
    7.0|70|7.1|71|7.2|72|7.3|73|7.4|74)
      PHP_VERSION=$(awk '{gsub(/[.]/,"");print $NF}' <<< "php$response")
      ;;
    8.0|80|8.2|82|8.3|83)
      PHP_VERSION=$(awk '{gsub(/[.]/,"");print $NF}' <<< "php$response")
      ;;
    8.1|81|*)
      PHP_VERSION="php81"
      ;;
  esac

  echo -ne "${YELLOW}PHP version of webapp set to $PHP_VERSION"
  echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
  echo ""

  if [[ "$WEBAPP_STACK" != "magento" ]] && [[ "$WEBAPP_STACK" != "phpweb" ]] && [[ "$WEBAPP_STACK" != "laravel" ]]; then
    # Define port proxy
    read -r -p "${CYAN}Please choose port proxy of your webapp? [3000]${NORMAL} " response
    PROXY_PORT=$response

    echo -ne "${YELLOW}Proxy port of webapp set to $PROXY_PORT"
    echo -ne "...${NORMAL} ${GREEN}DONE${NORMAL}"
    echo ""
  fi
}

function InitializeProject {
  local yaml_file="$CURRENT_DIR/$CONFIG_FILE"
  local apps_to_bootstrap=()

  # Check if yaml file exists
  if [[ -f "$yaml_file" ]]; then
    echo "${YELLOW}Found existing .devilbox.yaml configuration file.${NORMAL}"

    # Check if we need to add a new app or bootstrap existing apps
    read -r -p "${CYAN}Do you want to (a)dd a new app or (b)ootstrap existing apps? [b]${NORMAL} " response

    case "$response" in
      [aA])
        # Scenario 3 - Add new app to existing configuration
        InteractiveQuestions
        UpdateYamlWithNewApp "$yaml_file"
        BootstrapWebApplication "$WEBAPP_STACK"
        ;;

      [bB]|*)
        # Scenario 2 - Bootstrap existing apps
        ReadYamlConfiguration "$yaml_file"
        BootstrapExistingApps "$yaml_file"
        ;;
    esac
  else
    # Scenario 1 - No yaml file exists
    InteractiveQuestions
    BootstrapWebApplication "$WEBAPP_STACK"
    GenerateYamlConf "$WEBAPP_STACK" "$APPNAME" "$APPDOMAINS" "$WEB_MULTI" "$MAGE_INFRA" "$APPREPOSITORY" "$PHP_VERSION" "$PROXY_PORT"
  fi
}

function UpdateConfig {
  local filePath="${@: -1}"
  local nullInput=""

  if [[ ! -f "$filePath" ]]; then
    nullInput=" --null-input"
  fi

  "$YQ_BINARY$nullInput" "$@"
}

function ReadYamlConfiguration {
  local yaml_file="$1"

  # Read stack, infra type, PHP version, etc.
  WEBAPP_STACK=$("$YQ_BINARY" '.stack' "$yaml_file")
  MAGE_INFRA=$("$YQ_BINARY" '.infra' "$yaml_file")
  APPREPOSITORY=$("$YQ_BINARY" '.repo' "$yaml_file")
  PHP_VERSION=$("$YQ_BINARY" '.php.version' "$yaml_file")
  PROXY_PORT=$("$YQ_BINARY" '.proxy.port' "$yaml_file")

  echo "${YELLOW}Loaded configuration from yaml file:${NORMAL}"
  echo "Stack: ${GREEN}$WEBAPP_STACK${NORMAL}"
  echo "Infrastructure: ${GREEN}$MAGE_INFRA${NORMAL}"
  echo "PHP Version: ${GREEN}$PHP_VERSION${NORMAL}"
  echo "Repository: ${GREEN}$APPREPOSITORY${NORMAL}"
}

function GenerateYamlConf {
  local baseAppDir="$WEBAPP_DIR/$2"
  local filePath="$baseAppDir/$HTTPD_DOCROOT_DIR/$CONFIG_FILE"

  if [[ "$1" == "magento" ]] && [[ "$5" == "aws" ]]; then
    filePath="$baseAppDir/$CONFIG_FILE"
  fi

  if [[ ! -f "$filePath" ]]; then
    \cp "$TEMPLATE_CONFIG" "$filePath"
    current_stack="$1" \
    app_name="$2" \
    domain="$3" \
    is_subdomain="$4" \
    infra_type="${5:-generic}" \
    repo_url="${6:-N/A}" \
    php_version="$7" \
    proxy_port="$8" \
    UpdateConfig '(.. | select(tag == "!!str")) |= envsubst(ne, ff)' "$TEMPLATE_CONFIG" > "$filePath"
  fi
}

function UpdateYamlWithNewApp {
  local yaml_file="$1"

  # Check if app already exists in yaml
  local app_exists=$("$YQ_BINARY" ".apps[] | select(.name == \"$APPNAME\") | .name" "$yaml_file")

  if [[ -n "$app_exists" ]]; then
    echo "${YELLOW}App ${GREEN}$APPNAME${YELLOW} already exists in configuration file.${NORMAL}"
    return
  fi

  # Add new app to yaml
  "$YQ_BINARY" -i ".apps += [{\"name\": \"$APPNAME\", \"is_subdomain\": \"$WEB_MULTI\"}]" "$yaml_file"

  echo "${GREEN}Added new app ${BOLD}$APPNAME${NORMAL}${GREEN} to configuration file.${NORMAL}"
}

function BootstrapExistingApps {
  local yaml_file="$1"
  local apps_count=$("$YQ_BINARY" '.apps | length' "$yaml_file")

  echo "${YELLOW}Found ${apps_count} application(s) defined in configuration.${NORMAL}"

  for ((i=0; i<apps_count; i++)); do
    local app_name=$("$YQ_BINARY" ".apps[$i].name" "$yaml_file")
    local is_subdomain=$("$YQ_BINARY" ".apps[$i].is_subdomain" "$yaml_file")

    # Skip empty app names
    if [[ -z "$app_name" || "$app_name" == "null" ]]; then
      echo "${YELLOW}Skipping empty app name entry in configuration file.${NORMAL}"
      continue
    fi

    echo "${CYAN}Processing application: ${GREEN}$app_name${NORMAL} (Subdomain: $is_subdomain)"

    APPNAME="$app_name"
    WEB_MULTI="$is_subdomain"

    if [[ "$is_subdomain" == "Y" ]]; then
      # For subdomains, we need to find the parent app
      PARENT_APPNAME=$("$YQ_BINARY" '.apps[] | select(.is_subdomain == "N") | .name' "$yaml_file" | head -1)
      if [[ -n "$PARENT_APPNAME" && "$PARENT_APPNAME" != "null" ]]; then
        echo "${YELLOW}Using parent application: ${GREEN}$PARENT_APPNAME${NORMAL}"
      else
        echo "${RED}Warning: No parent application found for subdomain $app_name${NORMAL}"
        PARENT_APPNAME="unknown_parent"
      fi
    fi

    # Check if directory exists but with different name (from git clone)
    local repo_name=$(basename "$APPREPOSITORY" .git | sed 's/\.git$//')
    local repo_dir="$WEBAPP_DIR/$repo_name"
    local app_dir="$WEBAPP_DIR/$APPNAME"

    if [[ -n "$APPREPOSITORY" ]] && [[ "$WEB_MULTI" == "N" ]]; then
      if [[ -d "$repo_dir" ]] && [[ "$repo_name" != "$APPNAME" ]]; then
        echo -ne "${YELLOW}Found repository directory with different name: $repo_name"
        echo -ne "\n${YELLOW}Renaming to match app name: $APPNAME"
        mv "$repo_dir" "$app_dir"
        echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}\n"

        # If the yaml file was in the renamed directory, update its path
        if [[ "$yaml_file" == "$repo_dir"* ]]; then
          local rel_path="${yaml_file#$repo_dir}"
          yaml_file="$app_dir$rel_path"
          echo "${YELLOW}Updated YAML file path to: $yaml_file${NORMAL}"
        fi
      fi
    fi

    BootstrapWebApplication "$WEBAPP_STACK"
  done
}

function BootstrapWebApplication {
  # Start configuring everything
  echo -ne "${YELLOW}Please wait, we are configuring your web application"
  local currentStack="$1"
  local devilboxConfDir="$WEBAPP_DIR/$APPNAME/$HTTPD_TEMPLATE_DIR"
  local templateType

  # Creating dirs
  if [[ ! -d "$WEBAPP_DIR" ]]; then
    mkdir -p "$WEBAPP_DIR"
  fi

  # Check if directory exists but with different name (from git clone)
  if [[ -n "$APPREPOSITORY" ]] && [[ "$WEB_MULTI" == "N" ]]; then
    local repo_name=$(basename "$APPREPOSITORY" .git | sed 's/\.git$//')
    local repo_dir="$WEBAPP_DIR/$repo_name"

    if [[ -d "$repo_dir" ]] && [[ "$repo_name" != "$APPNAME" ]]; then
      echo -ne "\n${YELLOW}Found repository directory with different name: $repo_name"
      echo -ne "\n${YELLOW}Renaming to match app name: $APPNAME"
      mv "$repo_dir" "$WEBAPP_DIR/$APPNAME"
      echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}\n"
    fi
  fi

  # If directory already exists
  if [[ -d "$WEBAPP_DIR/$APPNAME" ]]; then
    echo -ne "\n${YELLOW}Directory $APPNAME already exists"

    # Always ensure the template directory exists regardless of subdomain status
    mkdir -p "$devilboxConfDir"

    # For subdomains, we ensure the symbolic link exists
    if [[ "$WEB_MULTI" == "Y" ]]; then
      echo -ne "\n${YELLOW}Ensuring subdomain configuration exists"

      # Setup symbolic link to parent app if not already set
      if [[ ! -L "$WEBAPP_DIR/$APPNAME/$HTTPD_DOCROOT_DIR" ]]; then
        (cd "$WEBAPP_DIR/$APPNAME" || exit; ln -snf "../$PARENT_APPNAME/$HTTPD_DOCROOT_DIR" "$HTTPD_DOCROOT_DIR" > /dev/null)
      fi
    fi

    # For Magento AWS infrastructure, ensure symlinks are correct
    if [[ "$currentStack" == "magento" ]] && [[ "$MAGE_INFRA" == "aws" ]]; then
      if [[ ! -L "$WEBAPP_DIR/$APPNAME/$HTTPD_DOCROOT_DIR" ]] && [[ -d "$WEBAPP_DIR/$APPNAME/$AWS_BASEDIR" ]]; then
        echo -ne "\n${YELLOW}Setting up AWS infrastructure symlinks"
        (cd "$WEBAPP_DIR/$APPNAME" || exit; ln -snf "$AWS_BASEDIR" "$HTTPD_DOCROOT_DIR" > /dev/null)
      fi
    fi
  else
    # Create new directory structure
    mkdir -p "$WEBAPP_DIR/$APPNAME"
    mkdir -p "$devilboxConfDir"

    # For non-subdomains, clone repository if provided
    if [[ "$WEB_MULTI" == "N" ]]; then
      if [[ "$MAGE_INFRA" == "aws" ]]; then
        git clone --quiet "$APPREPOSITORY" "$WEBAPP_DIR/$APPNAME" > /dev/null
        if [[ "$AWS_BASEDIR" != "$HTTPD_DOCROOT_DIR" ]]; then
          (cd "$WEBAPP_DIR/$APPNAME" || exit; ln -snf "$AWS_BASEDIR" "$HTTPD_DOCROOT_DIR" > /dev/null)
        fi
      elif [[ "$MAGE_INFRA" == "cloud" ]] || [[ "$MAGE_INFRA" == "" ]]; then
        git clone --quiet "$APPREPOSITORY" "$WEBAPP_DIR/$APPNAME/$HTTPD_DOCROOT_DIR" > /dev/null
      fi
    elif [[ "$WEB_MULTI" == "Y" ]]; then
      # For subdomains, create symbolic link to parent app
      (cd "$WEBAPP_DIR/$APPNAME" || exit; ln -snf "../$PARENT_APPNAME/$HTTPD_DOCROOT_DIR" "$HTTPD_DOCROOT_DIR" > /dev/null)
    fi
  fi

  # Configure based on stack type
  case "$currentStack" in
    magento)
      templateType="magento2"
      ;;
    nodejs)
      templateType="rproxy"
      ;;
    shopify)
      templateType="rproxy"
      ;;
    bigcommerce)
      templateType="rproxy"
      ;;
    laravel)
      templateType="vhost"
      ;;
    phpweb|*)
      templateType="vhost"
      ;;
  esac

  # Ensure template directory exists before writing config files
  if [[ ! -d "$devilboxConfDir" ]]; then
    mkdir -p "$devilboxConfDir"
  fi

  # General Configuration
  if [[ -f "$DEVILBOX_PATH/cfg/vhost-gen/backend.cfg-example-php-multi" ]] && [[ $currentStack != "nodejs" ]] && [[ $currentStack != "bigcommerce" ]] && [[ $currentStack != "shopify" ]]; then
    cat "$DEVILBOX_PATH/cfg/vhost-gen/backend.cfg-example-php-multi" | sed "s/PHP_VERSION/$PHP_VERSION/g" > "$devilboxConfDir/backend.cfg"
  fi

  if [[ -f "$DEVILBOX_PATH/cfg/vhost-gen/backend.cfg-example-rproxy-multi" ]] && [[ $currentStack != "magento" ]] && [[ $currentStack != "laravel" ]] && [[ $currentStack != "phpweb" ]]; then
    cat "$DEVILBOX_PATH/cfg/vhost-gen/backend.cfg-example-rproxy-multi" | sed "s/PHP_VERSION/php/g" | sed "s/PROXY_PORT/$PROXY_PORT/g" > "$devilboxConfDir/backend.cfg"
  fi

  # Setup web server configuration
  if [[ "$HTTPD_SERVER" =~ "nginx" ]]; then
    cp "$DEVILBOX_PATH/cfg/vhost-gen/nginx.yml-example-$templateType" "$devilboxConfDir/nginx.yml"
  elif [[ "$HTTPD_SERVER" = "apache-2.2" ]]; then
    cp "$DEVILBOX_PATH/cfg/vhost-gen/apache22.yml-example-$templateType" "$devilboxConfDir/apache22.yml"
  elif [[ "$HTTPD_SERVER" = "apache-2.4" ]]; then
    cp "$DEVILBOX_PATH/cfg/vhost-gen/apache24.yml-example-$templateType" "$devilboxConfDir/apache24.yml"
  fi

  echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
  echo ""
}

function CreateYamlConf {
  if [[ -f "$CURRENT_DIR/$CONFIG_FILE" ]]; then
    error "File $CONFIG_FILE already exists in current directory!"
  fi

  local checkForGitDir
  checkForGitDir=$(find "$CURRENT_DIR" -maxdepth 1 -type d -name '*.git*' -print -quit)
  if [[ -z "$checkForGitDir" ]]; then
    error "Please ensure you are on root of project directory (where exists .git directory)"
  fi

  InteractiveQuestions
  GenerateYamlConf "$WEBAPP_STACK" "$APPNAME" "$APPDOMAINS" "$WEB_MULTI" "$MAGE_INFRA" "$APPREPOSITORY" "$PHP_VERSION" "$PROXY_PORT"
}

function UpdateDocRoots {
  if [[ "$#" -lt 1 ]]; then
    error "Missing required argument: old document root dir. E.g dvl update:docroot <old_htdoc_root_dir>"
  fi

  local oldHttpdDocRoot="$1"
  local hasEnvDir

  echo "${YELLOW}${BOLD}Please wait, we are update your document roots..."
  echo ""

  for appName in "$WEBAPP_DIR"/*; do
    hasEnvDir=$(find "$appName" -maxdepth 1 -type d -name '*env*' -print -quit)
    for fileOrDir in "$appName"/*; do
      if [[ -L "$fileOrDir" ]] || [[ -d "$fileOrDir" ]]; then
        if [[ $(basename "$fileOrDir") == "$oldHttpdDocRoot" ]] && [[ $(basename "$fileOrDir") != "$HTTPD_DOCROOT_DIR" ]]; then
          echo -ne "${YELLOW}${BOLD}[!] Update symbolic links for $appName..."
          if [[ "$hasEnvDir" =~ "env" ]]; then
            (cd "$appName" || exit; ln -snf "$AWS_BASEDIR" "$HTTPD_DOCROOT_DIR" > /dev/null) &
            spinner
          else
            (cd "$appName" || exit; mv "$(basename "$fileOrDir")" "$HTTPD_DOCROOT_DIR" > /dev/null) &
            spinner
          fi
          echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
          echo ""
        fi
      fi

# TODO: Update content of symbolic links - planned for 1.2.2
#      if [[ -L "$fileOrDir" ]]; then
#        echo $fileOrDir
#        echo "$(readlink "$fileOrDir")"
#      fi
    done
  done
}

function SyncHttpdConf {
  echo "${YELLOW}${BOLD}Syncing Httpd configuration for all webapps${NORMAL}"
  echo "Using web server: ${GREEN}$HTTPD_SERVER${NORMAL}"
  echo ""

  # Track statistics
  local updated_count=0
  local skipped_count=0
  local error_count=0
  local processed_count=0

  # Iterate through all webapps
  for appName in "$WEBAPP_DIR"/*; do
    if [[ ! -d "$appName" ]]; then
      continue
    fi

    local app_basename=$(basename "$appName")
    processed_count=$((processed_count+1))
    echo "${YELLOW}${BOLD}Processing webapp: $app_basename${NORMAL}"

    # Ensure the template directory exists
    local template_dir="$appName/$HTTPD_TEMPLATE_DIR"
    if [[ ! -d "$template_dir" ]]; then
      echo -ne "${YELLOW}[!] Creating template directory..."
      mkdir -p "$template_dir"
      echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
      echo ""
    fi

    # Determine webapp stack from .devilbox.yaml if it exists
    local webapp_stack="phpweb"  # Default stack
    local yaml_file="$appName/.devilbox.yaml"

    # Check in htdocs directory if main .devilbox.yaml not found
    if [[ ! -f "$yaml_file" ]]; then
      yaml_file="$appName/$HTTPD_DOCROOT_DIR/.devilbox.yaml"
    fi

    if [[ -f "$yaml_file" ]]; then
      local detected_stack=$("$YQ_BINARY" '.stack' "$yaml_file")
      if [[ -n "$detected_stack" && "$detected_stack" != "null" ]]; then
        webapp_stack="$detected_stack"
      fi
    fi

    echo "Detected stack: ${GREEN}$webapp_stack${NORMAL}"

    # Determine template type based on webapp stack
    local template_type
    case "$webapp_stack" in
      magento)
        template_type="magento2"
        ;;
      nodejs|shopify|bigcommerce)
        template_type="rproxy"
        ;;
      laravel|phpweb|*)
        template_type="vhost"
        ;;
    esac

    # Sync vhost configuration
    local vhost_source
    local vhost_target

    if [[ "$HTTPD_SERVER" =~ "nginx" ]]; then
      vhost_source="$DEVILBOX_PATH/cfg/vhost-gen/nginx.yml-example-$template_type"
      vhost_target="$template_dir/nginx.yml"
    elif [[ "$HTTPD_SERVER" = "apache-2.2" ]]; then
      vhost_source="$DEVILBOX_PATH/cfg/vhost-gen/apache22.yml-example-$template_type"
      vhost_target="$template_dir/apache22.yml"
    elif [[ "$HTTPD_SERVER" = "apache-2.4" ]]; then
      vhost_source="$DEVILBOX_PATH/cfg/vhost-gen/apache24.yml-example-$template_type"
      vhost_target="$template_dir/apache24.yml"
    fi

    # Sync vhost configuration
    if [[ -f "$vhost_source" ]]; then
      if [[ -f "$vhost_target" ]]; then
        echo "Checking vhost configuration differences..."

        # Check if files are different
        if ! diff -q "$vhost_source" "$vhost_target" >/dev/null; then
          # Show differences
          diff -u "$vhost_target" "$vhost_source" || true
          echo ""

          # Prompt user for action
          read -r -p "${CYAN}Apply these changes to $app_basename vhost configuration? (y/n): ${NORMAL}" response
          case "$response" in
            [yY][eE][sS]|[yY])
              echo -ne "${YELLOW}[!] Updating vhost configuration..."
              cp "$vhost_source" "$vhost_target"
              updated_count=$((updated_count+1))
              echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
              echo ""
              ;;
            *)
              skipped_count=$((skipped_count+1))
              echo -ne "${YELLOW}[!] Skipping vhost configuration update..."
              echo -ne "...${NORMAL} ${CYAN}SKIPPED${NORMAL}"
              echo ""
              ;;
          esac
        else
          echo -ne "${YELLOW}[!] No differences in vhost configuration..."
          echo -ne "...${NORMAL} ${GREEN}UP-TO-DATE ✔${NORMAL}"
          echo ""
        fi
      else
        echo -ne "${YELLOW}[!] Creating new vhost configuration..."
        cp "$vhost_source" "$vhost_target"
        updated_count=$((updated_count+1))
        echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
        echo ""
      fi
    else
      echo -ne "${YELLOW}[!] Template file not found: $vhost_source..."
      echo -ne "...${NORMAL} ${RED}ERROR ✘${NORMAL}"
      echo ""
      error_count=$((error_count+1))
    fi

    # Sync backend configuration
    local backend_source
    local backend_target="$template_dir/backend.cfg"

    if [[ "$webapp_stack" = "nodejs" || "$webapp_stack" = "bigcommerce" || "$webapp_stack" = "shopify" ]]; then
      backend_source="$DEVILBOX_PATH/cfg/vhost-gen/backend.cfg-example-rproxy-multi"
    else
      backend_source="$DEVILBOX_PATH/cfg/vhost-gen/backend.cfg-example-php-multi"
    fi

    if [[ -f "$backend_source" ]]; then
      local tmp_backend_source=$(mktemp)

      # Create a modified copy with variables substituted
      if [[ "$webapp_stack" = "nodejs" || "$webapp_stack" = "bigcommerce" || "$webapp_stack" = "shopify" ]]; then
        # Get proxy port from yaml if available
        local proxy_port="3000"
        if [[ -f "$yaml_file" ]]; then
          local yaml_port=$("$YQ_BINARY" '.proxy.port' "$yaml_file")
          if [[ -n "$yaml_port" && "$yaml_port" != "null" ]]; then
            proxy_port="$yaml_port"
          fi
        fi
        cat "$backend_source" | sed "s/PHP_VERSION/php/g" | sed "s/PROXY_PORT/$proxy_port/g" > "$tmp_backend_source"
      else
        # Get PHP version from yaml if available
        local php_version="php"
        if [[ -f "$yaml_file" ]]; then
          local yaml_php=$("$YQ_BINARY" '.php.version' "$yaml_file")
          if [[ -n "$yaml_php" && "$yaml_php" != "null" ]]; then
            php_version="$yaml_php"
          fi
        fi
        cat "$backend_source" | sed "s/PHP_VERSION/$php_version/g" > "$tmp_backend_source"
      fi

      if [[ -f "$backend_target" ]]; then
        echo "Checking backend configuration differences..."

        # Check if files are different
        if ! diff -q "$tmp_backend_source" "$backend_target" >/dev/null; then
          # Show differences
          diff -u "$backend_target" "$tmp_backend_source" || true
          echo ""

          # Prompt user for action
          read -r -p "${CYAN}Apply these changes to $app_basename backend configuration? (y/n): ${NORMAL}" response
          case "$response" in
            [yY][eE][sS]|[yY])
              echo -ne "${YELLOW}[!] Updating backend configuration..."
              cp "$tmp_backend_source" "$backend_target"
              updated_count=$((updated_count+1))
              echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
              echo ""
              ;;
            *)
              skipped_count=$((skipped_count+1))
              echo -ne "${YELLOW}[!] Skipping backend configuration update..."
              echo -ne "...${NORMAL} ${CYAN}SKIPPED${NORMAL}"
              echo ""
              ;;
          esac
        else
          echo -ne "${YELLOW}[!] No differences in backend configuration..."
          echo -ne "...${NORMAL} ${GREEN}UP-TO-DATE ✔${NORMAL}"
          echo ""
        fi
      else
        echo -ne "${YELLOW}[!] Creating new backend configuration..."
        cp "$tmp_backend_source" "$backend_target"
        updated_count=$((updated_count+1))
        echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
        echo ""
      fi

      # Clean up temp file
      rm -f "$tmp_backend_source"
    else
      echo -ne "${YELLOW}[!] Backend template file not found: $backend_source..."
      echo -ne "...${NORMAL} ${RED}ERROR ✘${NORMAL}"
      echo ""
      error_count=$((error_count+1))
    fi

    echo ""
  done

  # Print summary
  echo "${YELLOW}${BOLD}Sync Summary:${NORMAL}"
  echo "Processed: ${GREEN}$processed_count${NORMAL} webapps"
  echo "Updated: ${GREEN}$updated_count${NORMAL} configurations"
  echo "Skipped: ${CYAN}$skipped_count${NORMAL} configurations"

  if [[ $error_count -gt 0 ]]; then
    echo "Errors: ${RED}$error_count${NORMAL} configurations"
    return 1
  else
    success "Httpd configuration sync complete!"
    return 0
  fi
}

function SyncEnvConf {
  # STEP 1: Handle docker-compose.override.yml synchronization
  local DOCKER_OVERRIDE_SOURCE="$DEVILBOX_PATH/compose/docker-compose.override.yml-magento2"
  local DOCKER_OVERRIDE_TARGET="$DEVILBOX_PATH/docker-compose.override.yml"

  if [[ -f "$DOCKER_OVERRIDE_SOURCE" ]] && [[ -f "$DOCKER_OVERRIDE_TARGET" ]]; then
    echo "${YELLOW}${BOLD}Step 1: Checking docker-compose.override.yml differences${NORMAL}"
    echo "Comparing $DOCKER_OVERRIDE_SOURCE with $DOCKER_OVERRIDE_TARGET"
    echo ""

    # Check if files are different
    if ! diff -q "$DOCKER_OVERRIDE_SOURCE" "$DOCKER_OVERRIDE_TARGET" >/dev/null; then
      # Show differences
      diff -u "$DOCKER_OVERRIDE_TARGET" "$DOCKER_OVERRIDE_SOURCE" || true
      echo ""

      # Prompt user for action
      read -r -p "${CYAN}Would you like to apply these changes to your docker-compose.override.yml? (y/n): ${NORMAL}" response
      case "$response" in
        [yY][eE][sS]|[yY])
          echo -ne "${YELLOW}[!] Updating docker-compose.override.yml..."
          cp "$DOCKER_OVERRIDE_SOURCE" "$DOCKER_OVERRIDE_TARGET"
          echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
          echo ""
          ;;
        *)
          echo -ne "${YELLOW}[!] Skipping docker-compose.override.yml update..."
          echo -ne "...${NORMAL} ${CYAN}SKIPPED${NORMAL}"
          echo ""
          ;;
      esac
    else
      echo -ne "${YELLOW}[!] No differences found in docker-compose.override.yml..."
      echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
      echo ""
    fi
  elif [[ -f "$DOCKER_OVERRIDE_SOURCE" ]] && [[ ! -f "$DOCKER_OVERRIDE_TARGET" ]]; then
    echo -ne "${YELLOW}[!] Creating new docker-compose.override.yml..."
    cp "$DOCKER_OVERRIDE_SOURCE" "$DOCKER_OVERRIDE_TARGET"
    echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
    echo ""
  fi

  # STEP 2: Handle .env synchronization
  local ENV_SOURCE="$DEVILBOX_PATH/env-example"
  local ENV_TARGET="$DEVILBOX_PATH/.env"

  echo ""
  echo "${YELLOW}${BOLD}Step 2: Checking .env file differences${NORMAL}"
  echo "Comparing $ENV_SOURCE with $ENV_TARGET"
  echo ""

  if [[ -f "$ENV_SOURCE" ]] && [[ -f "$ENV_TARGET" ]]; then
    # Create temporary files for comparison with normalized preserved variables
    local TMP_SOURCE=$(mktemp)
    local TMP_TARGET=$(mktemp)

    # Copy original files to temp files
    cp "$ENV_SOURCE" "$TMP_SOURCE"
    cp "$ENV_TARGET" "$TMP_TARGET"

    # Normalize preserved variables to same values in both files
    for var in "TLD_SUFFIX" "NEW_UID" "NEW_GID" "HOST_PORT_BIND"; do
      sed -i.bak "s/^$var=.*/$var=NORMALIZED_VALUE/" "$TMP_SOURCE" && rm -f "${TMP_SOURCE}.bak"
      sed -i.bak "s/^$var=.*/$var=NORMALIZED_VALUE/" "$TMP_TARGET" && rm -f "${TMP_TARGET}.bak"
    done

    # Check if files are different (ignoring the preserved variables)
    if ! diff -q "$TMP_SOURCE" "$TMP_TARGET" >/dev/null; then
      # Show differences in original files
      diff -u "$ENV_TARGET" "$ENV_SOURCE" || true
      echo ""

      # Prompt user for action
      read -r -p "${CYAN}Would you like to apply these changes to your .env file? (y/n): ${NORMAL}" response
      case "$response" in
        [yY][eE][sS]|[yY])
          echo -ne "${YELLOW}[!] Updating .env file while preserving key variables..."

          # Backup the current values of preserved variables
          local tld_suffix=$(grep -E "^TLD_SUFFIX=" "$ENV_TARGET" | cut -d '=' -f2-)
          local new_uid=$(grep -E "^NEW_UID=" "$ENV_TARGET" | cut -d '=' -f2-)
          local new_gid=$(grep -E "^NEW_GID=" "$ENV_TARGET" | cut -d '=' -f2-)
          local host_port_bind=$(grep -E "^HOST_PORT_BIND=" "$ENV_TARGET" | cut -d '=' -f2-)

          # Copy the new env file
          cp "$ENV_SOURCE" "$ENV_TARGET"

          # Restore preserved variables if they were found
          if [[ ! -z "$tld_suffix" ]]; then
            sed -i.bak "s/^TLD_SUFFIX=.*/TLD_SUFFIX=${tld_suffix}/" "$ENV_TARGET" && rm -f "${ENV_TARGET}.bak"
          fi

          if [[ ! -z "$new_uid" ]]; then
            sed -i.bak "s/^NEW_UID=.*/NEW_UID=${new_uid}/" "$ENV_TARGET" && rm -f "${ENV_TARGET}.bak"
          fi

          if [[ ! -z "$new_gid" ]]; then
            sed -i.bak "s/^NEW_GID=.*/NEW_GID=${new_gid}/" "$ENV_TARGET" && rm -f "${ENV_TARGET}.bak"
          fi

          if [[ ! -z "$host_port_bind" ]]; then
            sed -i.bak "s/^HOST_PORT_BIND=.*/HOST_PORT_BIND=${host_port_bind}/" "$ENV_TARGET" && rm -f "${ENV_TARGET}.bak"
          fi

          echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
          echo ""
          ;;
        *)
          echo -ne "${YELLOW}[!] Aborting environment synchronization..."
          echo -ne "...${NORMAL} ${RED}ABORTED${NORMAL}"
          echo ""
          ;;
      esac
    else
      echo -ne "${YELLOW}[!] No meaningful differences found in .env file (ignoring preserved variables)..."
      echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
      echo ""
    fi

    # Clean up temporary files
    rm -f "$TMP_SOURCE" "$TMP_TARGET"
    
  elif [[ -f "$ENV_SOURCE" ]] && [[ ! -f "$ENV_TARGET" ]]; then
    echo -ne "${YELLOW}[!] Creating new .env file..."
    cp "$ENV_SOURCE" "$ENV_TARGET"
    echo -ne "...${NORMAL} ${GREEN}DONE ✔${NORMAL}"
    echo ""
  fi

  success "Environment configuration synchronization complete!"
}

function DoctorForBox {
  /bin/bash "$DEVILBOX_PATH/check-config.sh"
}

function Usage {
  case "$1" in
    --ansi)
      echo "${YELLOW}DevilBox v${VERSION}${NORMAL}"

      echo

      echo "${YELLOW}Usage:"
      echo "${NORMAL}" "dvl [commands] [options]"

      echo

      echo "${YELLOW}Options:${NORMAL}"
      echo "${GREEN}" "--version${NORMAL}(-v)    Display current version."
      echo "${GREEN}" "--help${NORMAL}(-h)       Display this help message."
      echo "${GREEN}" "--quiet${NORMAL}(-q)      Do not output any message."
      echo "${GREEN}" "--ansi${NORMAL}           Force ANSI output."
      echo "${GREEN}" "--no-ansi${NORMAL}        Disable ANSI output."

      echo

      echo "${YELLOW}Available commands:${NORMAL}"
      echo "${GREEN}" "up${NORMAL}(start)        Start designated devilbox services."
      echo "${GREEN}" "down${NORMAL}(stop)       Stop all Devilbox services."
      echo "${GREEN}" "restart${NORMAL}          Restart Devilbox service(s). Leave empty to restart all."
      echo "${GREEN}" "doctor${NORMAL}           Check your system for potential problems. Will exit with a non-zero status if any potential problems are found."
      echo "${GREEN}" "reset${NORMAL}            Shutdown and reset everyhing (USE with CAUTION)."
      echo "${GREEN}" "init${NORMAL}             Initialize a new project using DevilBox."
      echo "${GREEN}" "shell${NORMAL}            Open shell (php version as args)"
      echo "${GREEN}" "exec${NORMAL}             Exec a command directly from shell (command executed on main PHP container)"
      echo "${GREEN}" "db-import${NORMAL}        Restore a backup to database from ./backups directory"
      echo "${GREEN}" "magento${NORMAL}          Run Magento command from the current project directory"
      echo "${GREEN}" "magerun${NORMAL}          Run Magerun2 command from the current project directory"
      echo "${GREEN}" "composer${NORMAL}         Run Composer command from the current project directory"
      echo "${GREEN}" "ece-tools${NORMAL}        Run EceTools command from the current project directory"
      echo "${GREEN}" "cloud-patches${NORMAL}    Run EcePatches command from the current project directory"
      echo "${GREEN}" "update-docroot${NORMAL}   Update new document root for all current webapps"
      echo "${GREEN}" "sync-httpd${NORMAL}       Sync Httpd configuration to all current webapps"
      echo "${GREEN}" "sync-env${NORMAL}         Sync current .env from default env file (prompting for changes)"
    ;;
    --no-ansi)
      echo "DevilBox v${VERSION}"

      echo

      echo "Usage:"
      echo " dvl [commands] [options]"

      echo

      echo "Options:"
      echo " --version${NORMAL}(-v)    Display current version."
      echo " --help${NORMAL}(-h)       Display this help message."
      echo " --quiet${NORMAL}(-q)      Do not output any message."
      echo " --ansi${NORMAL}           Force ANSI output."
      echo " --no-ansi${NORMAL}        Disable ANSI output."

      echo

      echo "Available commands:"
      echo " up${NORMAL}(start)        Start designated devilbox services."
      echo " down${NORMAL}(stop)       Stop all Devilbox services."
      echo " restart${NORMAL}          Restart Devilbox service(s). Leave empty to restart all."
      echo " doctor${NORMAL}           Check your system for potential problems. Will exit with a non-zero status if any potential problems are found."
      echo " reset${NORMAL}            Shutdown and reset everyhing (USE with CAUTION)."
      echo " init${NORMAL}             Initialize a new project using DevilBox."
      echo " shell${NORMAL}            Open shell (php version as args)"
      echo " exec${NORMAL}             Exec a command directly from shell (command executed on main PHP container)"
      echo " db-import${NORMAL}        Restore a backup to database from ./backups directory"
      echo " magento${NORMAL}          Run Magento command from the current project directory"
      echo " magerun${NORMAL}          Run Magerun2 command from the current project directory"
      echo " composer${NORMAL}         Run Composer command from the current project directory"
      echo " ece-tools${NORMAL}        Run EceTools command from the current project directory"
      echo " cloud-patches${NORMAL}    Run EcePatches command from the current project directory"
      echo " update-docroot${NORMAL}   Update new document root for all current webapps"
      echo " sync-httpd${NORMAL}       Sync Httpd configuration to all current webapps"
      echo " sync-env${NORMAL}         Sync current .env from default env file & docker-compose.override.yml (prompting for changes)"
    ;;
  esac
}

main "$@"
