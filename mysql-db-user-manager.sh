#!/usr/bin/env bash
# =============================================================================
# DevilBox — MySQL Database & User Management
# =============================================================================
# Interactive script for managing MySQL databases and users inside DevilBox.
# =============================================================================
#
# ENVIRONMENT VARIABLES:
#   DEVILBOX_PATH         - Absolute path to the DevilBox installation directory.
#                           Used to locate docker-compose.yml and helper scripts.
#                           Must be set before running this script.
#
#   MYSQL_ROOT_PASSWORD   - Root password for the MySQL server inside DevilBox.
#                           Automatically fetched from DevilBox .env via
#                           env-getvar.sh. Do not set manually unless necessary.
#
# =============================================================================

set -euo pipefail

# ── Colors & Formatting ──────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helper Functions ──────────────────────────────────────────────────────────
info()    { printf "%b\n" "${CYAN}ℹ  ${NC}$*"; }
success() { printf "%b\n" "${GREEN}✔  ${NC}$*"; }
warn()    { printf "%b\n" "${YELLOW}⚠  ${NC}$*"; }
error()   { printf "%b\n" "${RED}✘  ${NC}$*" >&2; }
fatal()   { error "$@"; exit 1; }

separator() {
    printf "%b\n" "${BOLD}─────────────────────────────────────────────────────────────${NC}"
}

header() {
    echo
    separator
    printf "%b\n" "${BOLD}  $*${NC}"
    separator
    echo
}

# ── DevilBox Environment ─────────────────────────────────────────────────────
if [[ -z "${DEVILBOX_PATH:-}" ]]; then
    fatal "Devilbox not found. Please make sure it is installed and DEVILBOX_PATH is set."
fi

DVLBOX_PATH="$(cd "${DEVILBOX_PATH}" && pwd -P)"
SCRIPT_PATH="$(cd "${DVLBOX_PATH}/.tests/scripts" && pwd -P)"

if [[ ! -x "${SCRIPT_PATH}/env-getvar.sh" ]]; then
    fatal "Cannot find env-getvar.sh at ${SCRIPT_PATH}"
fi

MYSQL_ROOT_PASSWORD="$( "${SCRIPT_PATH}/env-getvar.sh" "MYSQL_ROOT_PASSWORD" )"

if [[ -z "${MYSQL_ROOT_PASSWORD}" ]]; then
    fatal "MYSQL_ROOT_PASSWORD is empty. Check your DevilBox .env file."
fi

# ── Detect working Docker Compose command ─────────────────────────────────────
DOCKER_COMPOSE_CMD=()
TEST_QUERY="SELECT 1;"

info "Detecting Docker Compose command…"

if docker compose \
    --project-directory "${DVLBOX_PATH}" \
    exec --user devilbox -T php \
    bash -c "mysql --host=mysql --user=root --password='${MYSQL_ROOT_PASSWORD}' -N -B -e '${TEST_QUERY}'" &>/dev/null; then
    DOCKER_COMPOSE_CMD=(docker compose)
    success "Using: docker compose"
elif docker-compose \
    --project-directory "${DVLBOX_PATH}" \
    exec --user devilbox -T php \
    bash -c "mysql --host=mysql --user=root --password='${MYSQL_ROOT_PASSWORD}' -N -B -e '${TEST_QUERY}'" &>/dev/null; then
    DOCKER_COMPOSE_CMD=(docker-compose)
    success "Using: docker-compose"
else
    fatal "Cannot connect to MySQL. Ensure DevilBox containers are running."
fi

# ── MySQL execution helper ────────────────────────────────────────────────────
# Runs a MySQL command inside the DevilBox php container.
# SQL is passed via stdin to avoid backtick/quote escaping issues.
# Usage: mysql_exec "SQL_QUERY"
mysql_exec() {
    local query="$1"
    "${DOCKER_COMPOSE_CMD[@]}" \
        --project-directory "${DVLBOX_PATH}" \
        exec --user devilbox -T php \
        bash -c "mysql --host=mysql --user=root --password='${MYSQL_ROOT_PASSWORD}' -N -B" <<< "${query}"
}

# ── Validation Helpers ────────────────────────────────────────────────────────
validate_identifier() {
    local name="$1"
    local label="$2"

    if [[ -z "${name}" ]]; then
        fatal "${label} cannot be empty."
    fi

    if [[ ${#name} -gt 64 ]]; then
        fatal "${label} is too long (max 64 characters)."
    fi

    if [[ ! "${name}" =~ ^[A-Za-z0-9_\$]+$ ]]; then
        fatal "${label} contains invalid characters. Only letters, digits, underscores and dollar signs are allowed."
    fi
}

is_system_db() {
    case "$1" in
        information_schema|mysql|performance_schema|sys) return 0 ;;
        *) return 1 ;;
    esac
}

is_system_user() {
    [[ "$1" == "root" || "$1" == mysql* ]]
}

sql_escape() {
    local val="$1"
    printf "%s" "${val//\'/\'\'}"
}

# =============================================================================
#  MAIN
# =============================================================================

header "🗄️  DEVILBOX MYSQL MANAGER"

# ── Scenario Selection ────────────────────────────────────────────────────────
printf "%b\n" "${BOLD}Select a scenario:${NC}"
printf "  %b Create new Database + User\n" "${CYAN}1)${NC}"
printf "  %b Grant privileges to existing User on existing Database\n" "${CYAN}2)${NC}"
printf "  %b Create new User (without Database)\n" "${CYAN}3)${NC}"
printf "  %b Change password for existing User\n" "${CYAN}4)${NC}"
echo
echo
printf "  %b Press Any other key for exit\n" "${CYAN}ANY)${NC}"
echo

read -rp "$(printf "%b" "${BOLD}Enter choice [1-4]: ${NC}")" SCENARIO

case "${SCENARIO}" in
    1|2|3|4) ;;
    *) fatal "Invalid choice. Aborting." ;;
esac

# ──────────────────────────────────────────────────────────────────────────────
#  SCENARIO 1: Create DB + User
# ──────────────────────────────────────────────────────────────────────────────
if [[ "${SCENARIO}" == "1" ]]; then
    header "📋  SCENARIO 1 — Create Database + User"

    info "Fetching existing databases…"
    EXISTING_DBS="$(mysql_exec "SHOW DATABASES;")" || fatal "Failed to connect to MySQL."
    if [[ -n "${EXISTING_DBS}" ]]; then
        printf "%b\n" "${BOLD}Existing databases:${NC}"
        while IFS= read -r db; do
            printf "  %b %s\n" "${CYAN}•${NC}" "${db}"
        done <<< "${EXISTING_DBS}"
        echo
    fi

    read -rp "$(printf "%b" "${BOLD}Enter new database name: ${NC}")" DB_NAME
    DB_NAME="$(printf "%s" "${DB_NAME}" | xargs)"
    validate_identifier "${DB_NAME}" "Database name"

    if printf "%s" "${EXISTING_DBS}" | grep -qix "${DB_NAME}"; then
        fatal "Database '${DB_NAME}' already exists. Aborting."
    fi

    success "Database name '${DB_NAME}' is available."
    echo

    info "Fetching existing MySQL users…"
    EXISTING_USERS="$(mysql_exec "SELECT user FROM mysql.user WHERE host='%';")" || fatal "Failed to fetch users."
    if [[ -n "${EXISTING_USERS}" ]]; then
        printf "%b\n" "${BOLD}Existing MySQL users (host=%):${NC}"
        while IFS= read -r usr; do
            printf "  %b %s\n" "${CYAN}•${NC}" "${usr}"
        done <<< "${EXISTING_USERS}"
        echo
    fi

    read -rp "$(printf "%b" "${BOLD}Enter database username: ${NC}")" DB_USER
    DB_USER="$(printf "%s" "${DB_USER}" | xargs)"
    validate_identifier "${DB_USER}" "Username"

    USER_EXISTS=false
    if [[ -n "${EXISTING_USERS}" ]] && printf "%s" "${EXISTING_USERS}" | grep -qix "${DB_USER}"; then
        USER_EXISTS=true
    fi

    if [[ "${USER_EXISTS}" == true ]]; then
        warn "User '${DB_USER}' already exists."
        read -rp "$(printf "%b" "${BOLD}Grant this existing user access to '${DB_NAME}'? [y/N]: ${NC}")" GRANT_ANSWER
        GRANT_ANSWER="$(printf "%s" "${GRANT_ANSWER}" | xargs | tr '[:upper:]' '[:lower:]')"
        if [[ "${GRANT_ANSWER}" != "y" && "${GRANT_ANSWER}" != "yes" ]]; then
            info "Aborting — no changes made."
            exit 0
        fi
        CREATE_NEW_USER=false
    else
        CREATE_NEW_USER=true
    fi

    DB_PASS=""
    if [[ "${CREATE_NEW_USER}" == true ]]; then
        header "🔑  Set Password for '${DB_USER}'"
        while true; do
            read -rsp "$(printf "%b" "${BOLD}Enter password: ${NC}")" DB_PASS
            echo
            read -rsp "$(printf "%b" "${BOLD}Confirm password: ${NC}")" DB_PASS_CONFIRM
            echo
            if [[ "${DB_PASS}" != "${DB_PASS_CONFIRM}" ]]; then
                warn "Passwords do not match. Try again."
                continue
            fi
            if [[ -z "${DB_PASS}" ]]; then
                warn "Password cannot be empty. Try again."
                continue
            fi
            break
        done
        success "Password confirmed."
        echo
    fi

    header "🚀  Applying Changes"
    info "Creating database '${DB_NAME}'…"
    mysql_exec "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` COLLATE 'utf8mb4_unicode_ci';" || fatal "Failed to create database."
    success "Database '${DB_NAME}' created."

    if [[ "${CREATE_NEW_USER}" == true ]]; then
        DB_PASS_ESC="$(sql_escape "${DB_PASS}")"
        info "Creating user '${DB_USER}'@'%'…"
        mysql_exec "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS_ESC}';" || fatal "Failed to create user."
        success "User '${DB_USER}' created."
    fi

    info "Granting ALL PRIVILEGES on '${DB_NAME}' to '${DB_USER}'@'%'…"
    mysql_exec "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';" || fatal "Failed to grant privileges."
    success "Privileges granted."

    info "Flushing privileges…"
    mysql_exec "FLUSH PRIVILEGES;" || warn "FLUSH PRIVILEGES failed (may be non-critical)."
    success "Privileges flushed."

    header "✅  DONE"
    printf "  %bDatabase:%b  %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_NAME}" "${NC}"
    printf "  %bUser:%b      %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_USER}" "${NC}"
    if [[ "${CREATE_NEW_USER}" == true ]]; then
        printf "  %bPassword:%b  %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_PASS}" "${NC}"
    else
        printf "  %bPassword:%b  %b(unchanged — existing user)%b\n" "${GREEN}" "${NC}" "${BOLD}" "${NC}"
    fi
    echo
    separator
    printf "%b\n" "${GREEN}  All done! 🎉${NC}"
    separator
    echo

# ──────────────────────────────────────────────────────────────────────────────
#  SCENARIO 2: Grant privileges to existing User on existing DB
# ──────────────────────────────────────────────────────────────────────────────
elif [[ "${SCENARIO}" == "2" ]]; then
    header "🔐  SCENARIO 2 — Grant Privileges to Existing User"

    info "Fetching existing databases…"
    EXISTING_DBS="$(mysql_exec "SHOW DATABASES;")" || fatal "Failed to connect to MySQL."
    printf "%b\n" "${BOLD}Existing databases:${NC}"
    while IFS= read -r db; do
        if is_system_db "${db}"; then
            printf "  %b %s %b(system — skipped)%b\n" "${RED}✘${NC}" "${db}" "${YELLOW}" "${NC}"
        else
            printf "  %b %s\n" "${CYAN}•${NC}" "${db}"
        fi
    done <<< "${EXISTING_DBS}"
    echo

    read -rp "$(printf "%b" "${BOLD}Enter database name: ${NC}")" DB_NAME
    DB_NAME="$(printf "%s" "${DB_NAME}" | xargs)"
    validate_identifier "${DB_NAME}" "Database name"

    if ! printf "%s" "${EXISTING_DBS}" | grep -qix "${DB_NAME}"; then
        fatal "Database '${DB_NAME}' does not exist. Aborting."
    fi
    if is_system_db "${DB_NAME}"; then
        fatal "Cannot modify privileges for system database '${DB_NAME}'. Aborting."
    fi
    success "Database '${DB_NAME}' selected."
    echo

    info "Fetching existing MySQL users…"
    EXISTING_USERS="$(mysql_exec "SELECT user FROM mysql.user WHERE host='%';")" || fatal "Failed to fetch users."
    printf "%b\n" "${BOLD}Existing MySQL users (host=%):${NC}"
    while IFS= read -r usr; do
        if is_system_user "${usr}"; then
            printf "  %b %s %b(system — skipped)%b\n" "${RED}✘${NC}" "${usr}" "${YELLOW}" "${NC}"
        else
            printf "  %b %s\n" "${CYAN}•${NC}" "${usr}"
        fi
    done <<< "${EXISTING_USERS}"
    echo

    read -rp "$(printf "%b" "${BOLD}Enter username: ${NC}")" DB_USER
    DB_USER="$(printf "%s" "${DB_USER}" | xargs)"
    validate_identifier "${DB_USER}" "Username"

    if ! printf "%s" "${EXISTING_USERS}" | grep -qix "${DB_USER}"; then
        fatal "User '${DB_USER}' does not exist. Aborting."
    fi
    if is_system_user "${DB_USER}"; then
        fatal "Cannot modify privileges for system user '${DB_USER}'. Aborting."
    fi
    success "User '${DB_USER}' selected."
    echo

    header "🚀  Applying Changes"
    info "Granting ALL PRIVILEGES on '${DB_NAME}' to '${DB_USER}'@'%'…"
    mysql_exec "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';" || fatal "Failed to grant privileges."
    success "Privileges granted."

    info "Flushing privileges…"
    mysql_exec "FLUSH PRIVILEGES;" || warn "FLUSH PRIVILEGES failed (may be non-critical)."
    success "Privileges flushed."

    header "✅  DONE"
    printf "  %bDatabase:%b  %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_NAME}" "${NC}"
    printf "  %bUser:%b      %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_USER}" "${NC}"
    echo
    separator
    printf "%b\n" "${GREEN}  All done! 🎉${NC}"
    separator
    echo

# ──────────────────────────────────────────────────────────────────────────────
#  SCENARIO 3: Create new User (without DB)
# ──────────────────────────────────────────────────────────────────────────────
elif [[ "${SCENARIO}" == "3" ]]; then
    header "👤  SCENARIO 3 — Create New User"

    info "Fetching existing MySQL users…"
    EXISTING_USERS="$(mysql_exec "SELECT user FROM mysql.user WHERE host='%';")" || fatal "Failed to fetch users."
    if [[ -n "${EXISTING_USERS}" ]]; then
        printf "%b\n" "${BOLD}Existing MySQL users (host=%):${NC}"
        while IFS= read -r usr; do
            printf "  %b %s\n" "${CYAN}•${NC}" "${usr}"
        done <<< "${EXISTING_USERS}"
        echo
    fi

    read -rp "$(printf "%b" "${BOLD}Enter new username: ${NC}")" DB_USER
    DB_USER="$(printf "%s" "${DB_USER}" | xargs)"
    validate_identifier "${DB_USER}" "Username"

    if [[ -n "${EXISTING_USERS}" ]] && printf "%s" "${EXISTING_USERS}" | grep -qix "${DB_USER}"; then
        fatal "User '${DB_USER}' already exists. Aborting."
    fi
    success "Username '${DB_USER}' is available."
    echo

    header "🔑  Set Password"
    while true; do
        read -rsp "$(printf "%b" "${BOLD}Enter password: ${NC}")" DB_PASS
        echo
        read -rsp "$(printf "%b" "${BOLD}Confirm password: ${NC}")" DB_PASS_CONFIRM
        echo
        if [[ "${DB_PASS}" != "${DB_PASS_CONFIRM}" ]]; then
            warn "Passwords do not match. Try again."
            continue
        fi
        if [[ -z "${DB_PASS}" ]]; then
            warn "Password cannot be empty. Try again."
            continue
        fi
        break
    done
    success "Password confirmed."
    echo

    header "🚀  Applying Changes"
    DB_PASS_ESC="$(sql_escape "${DB_PASS}")"
    info "Creating user '${DB_USER}'@'%'…"
    mysql_exec "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS_ESC}';" || fatal "Failed to create user."
    success "User '${DB_USER}' created."

    info "Flushing privileges…"
    mysql_exec "FLUSH PRIVILEGES;" || warn "FLUSH PRIVILEGES failed (may be non-critical)."
    success "Privileges flushed."

    header "✅  DONE"
    printf "  %bUser:%b      %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_USER}" "${NC}"
    printf "  %bPassword:%b  %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_PASS}" "${NC}"
    echo
    separator
    printf "%b\n" "${GREEN}  All done! 🎉${NC}"
    separator
    echo

# ──────────────────────────────────────────────────────────────────────────────
#  SCENARIO 4: Change password for existing User
# ──────────────────────────────────────────────────────────────────────────────
elif [[ "${SCENARIO}" == "4" ]]; then
    header "🔑  SCENARIO 4 — Change User Password"

    info "Fetching existing MySQL users…"
    EXISTING_USERS="$(mysql_exec "SELECT user FROM mysql.user WHERE host='%';")" || fatal "Failed to fetch users."
    printf "%b\n" "${BOLD}Existing MySQL users (host=%):${NC}"
    while IFS= read -r usr; do
        if is_system_user "${usr}"; then
            printf "  %b %s %b(protected — cannot change password)%b\n" "${RED}✘${NC}" "${usr}" "${YELLOW}" "${NC}"
        else
            printf "  %b %s\n" "${CYAN}•${NC}" "${usr}"
        fi
    done <<< "${EXISTING_USERS}"
    echo

    read -rp "$(printf "%b" "${BOLD}Enter username: ${NC}")" DB_USER
    DB_USER="$(printf "%s" "${DB_USER}" | xargs)"
    validate_identifier "${DB_USER}" "Username"

    if ! printf "%s" "${EXISTING_USERS}" | grep -qix "${DB_USER}"; then
        fatal "User '${DB_USER}' does not exist. Aborting."
    fi
    if is_system_user "${DB_USER}"; then
        fatal "Cannot change password for system user '${DB_USER}'. Aborting."
    fi
    success "User '${DB_USER}' selected."
    echo

    header "🔒  Set New Password"
    while true; do
        read -rsp "$(printf "%b" "${BOLD}Enter new password: ${NC}")" DB_PASS
        echo
        read -rsp "$(printf "%b" "${BOLD}Confirm new password: ${NC}")" DB_PASS_CONFIRM
        echo
        if [[ "${DB_PASS}" != "${DB_PASS_CONFIRM}" ]]; then
            warn "Passwords do not match. Try again."
            continue
        fi
        if [[ -z "${DB_PASS}" ]]; then
            warn "Password cannot be empty. Try again."
            continue
        fi
        break
    done
    success "Password confirmed."
    echo

    header "🚀  Applying Changes"
    DB_PASS_ESC="$(sql_escape "${DB_PASS}")"
    info "Updating password for '${DB_USER}'@'%'…"
    mysql_exec "ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS_ESC}';" || fatal "Failed to update password."
    success "Password updated."

    info "Flushing privileges…"
    mysql_exec "FLUSH PRIVILEGES;" || warn "FLUSH PRIVILEGES failed (may be non-critical)."
    success "Privileges flushed."

    header "✅  DONE"
    printf "  %bUser:%b      %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_USER}" "${NC}"
    printf "  %bPassword:%b  %b%s%b\n" "${GREEN}" "${NC}" "${BOLD}" "${DB_PASS}" "${NC}"
    echo
    separator
    printf "%b\n" "${GREEN}  All done! 🎉${NC}"
    separator
    echo
fi
