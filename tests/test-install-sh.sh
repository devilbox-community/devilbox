#!/usr/bin/env bash
#
# Static-check suite for devilbox/install.sh and devilbox/env-example.
# Pure static checks — NO Docker, NO network, NO host filesystem mutation.
# Runs from any working directory. Exits 0 on success.
#
set -e -u -o pipefail
IFS=$'\n'

REPO_ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_SH="${REPO_ROOT}/install.sh"
ENV_EXAMPLE="${REPO_ROOT}/env-example"

# ---------------------------------------------------------------------------
# Minimal helpers (style matches docker-agentic/tests/.lib.sh)
# ---------------------------------------------------------------------------
_C_RED=$'\033[0;31m'
_C_GREEN=$'\033[0;32m'
_C_YELLOW=$'\033[0;33m'
_C_RESET=$'\033[0m'

PASS_COUNT=0

print_h_main() {
	printf '\n%s================================================================%s\n' "${_C_YELLOW}" "${_C_RESET}"
	printf '%s  %s%s\n' "${_C_YELLOW}" "$1" "${_C_RESET}"
	printf '%s================================================================%s\n' "${_C_YELLOW}" "${_C_RESET}"
}

print_h_sub() {
	printf '\n%s--- %s ---%s\n' "${_C_YELLOW}" "$1" "${_C_RESET}"
}

pass() {
	PASS_COUNT=$((PASS_COUNT + 1))
	printf '  %s[PASS]%s %s\n' "${_C_GREEN}" "${_C_RESET}" "$1"
}

fail() {
	printf '  %s[FAIL]%s %s\n' "${_C_RED}" "${_C_RESET}" "$1" >&2
	exit 1
}

assert_file_exists() {
	local path="$1"
	local msg="$2"
	if [ -f "${path}" ]; then
		pass "${msg}"
	else
		fail "${msg} — missing file: ${path}"
	fi
}

# assert_grep_count <pattern> <file> <expected_min_count> <msg>
# Uses grep -cE (extended regex). 0-match returns count 0 (no error abort).
assert_grep_count() {
	local pattern="$1"
	local file="$2"
	local min="$3"
	local msg="$4"
	local count
	count="$(grep -cE -- "${pattern}" "${file}" || true)"
	if [ "${count}" -ge "${min}" ]; then
		pass "${msg} (matches=${count} >= ${min})"
	else
		fail "${msg} — pattern '${pattern}' matched ${count} times in ${file}, expected >= ${min}"
	fi
}

# assert_grep_count_iE <pattern> <file> <expected_min_count> <msg>  (case-insensitive)
assert_grep_count_iE() {
	local pattern="$1"
	local file="$2"
	local min="$3"
	local msg="$4"
	local count
	count="$(grep -ciE -- "${pattern}" "${file}" || true)"
	if [ "${count}" -ge "${min}" ]; then
		pass "${msg} (matches=${count} >= ${min})"
	else
		fail "${msg} — pattern '${pattern}' matched ${count} times in ${file}, expected >= ${min}"
	fi
}

# ---------------------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------------------
print_h_main "devilbox/install.sh static-check suite"

# 1. install.sh exists + syntactically valid
print_h_sub "1. install.sh present and syntactically valid"
assert_file_exists "${INSTALL_SH}" "install.sh exists"
if bash -n "${INSTALL_SH}"; then
	pass "bash -n install.sh exits 0"
else
	fail "bash -n install.sh syntax check failed"
fi

# 2. env-example CONTAINERS_CONFIG vars present
print_h_sub "2. env-example CONTAINERS_CONFIG vars present"
assert_file_exists "${ENV_EXAMPLE}" "env-example exists"
assert_grep_count '^CONTAINERS_CONFIG_DEFAULT=' "${ENV_EXAMPLE}" 1 "CONTAINERS_CONFIG_DEFAULT defined"
assert_grep_count '^CONTAINERS_CONFIG_OPTIONAL=' "${ENV_EXAMPLE}" 1 "CONTAINERS_CONFIG_OPTIONAL defined"

# 3. Container roster parity (12 legacy tokens)
print_h_sub "3. Container roster parity (12 legacy tokens)"
_default_line="$(grep -E '^CONTAINERS_CONFIG_DEFAULT=' "${ENV_EXAMPLE}" | head -n1)"
_optional_line="$(grep -E '^CONTAINERS_CONFIG_OPTIONAL=' "${ENV_EXAMPLE}" | head -n1)"
_default_val="${_default_line#CONTAINERS_CONFIG_DEFAULT=}"
_optional_val="${_optional_line#CONTAINERS_CONFIG_OPTIONAL=}"
# strip surrounding double or single quotes
_default_val="${_default_val%\"}"; _default_val="${_default_val#\"}"
_default_val="${_default_val%\'}"; _default_val="${_default_val#\'}"
_optional_val="${_optional_val%\"}"; _optional_val="${_optional_val#\"}"
_optional_val="${_optional_val%\'}"; _optional_val="${_optional_val#\'}"

_combined="${_default_val} ${_optional_val}"
# tokenize on whitespace, sort unique
_actual_sorted="$(printf '%s\n' ${_combined} | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ')"
_expected_sorted="$(printf '%s\n' bind httpd php mysql php74 php81 php82 php83 php84 redis opensearch buggregator | sort -u | tr '\n' ' ')"

if [ "${_actual_sorted}" = "${_expected_sorted}" ]; then
	pass "Container roster matches exactly (12 unique tokens)"
else
	fail "Container roster mismatch.
  expected: ${_expected_sorted}
  actual:   ${_actual_sorted}"
fi

# 4. OS branches present in install.sh
print_h_sub "4. OS detection branches present in install.sh"
assert_grep_count 'Darwin' "${INSTALL_SH}" 1 "Darwin (macOS) detection"
assert_grep_count 'debian\)' "${INSTALL_SH}" 1 "debian) case branch"
assert_grep_count 'arch\)' "${INSTALL_SH}" 1 "arch) case branch"
assert_grep_count 'fedora\)' "${INSTALL_SH}" 1 "fedora) case branch"
assert_grep_count 'alpine\)' "${INSTALL_SH}" 1 "alpine) case branch"
assert_grep_count_iE 'microsoft|wsl' "${INSTALL_SH}" 1 "WSL2/microsoft detection"

# 5. New flags + env vars present
print_h_sub "5. New flags and env vars present"
assert_grep_count '\-\-non-interactive' "${INSTALL_SH}" 2 "--non-interactive flag (parse_args + usage)"
assert_grep_count '\-\-workspace' "${INSTALL_SH}" 2 "--workspace flag (parse_args + usage)"
assert_grep_count 'DEVILBOX_NONINTERACTIVE' "${INSTALL_SH}" 1 "DEVILBOX_NONINTERACTIVE env var"
assert_grep_count 'DEVILBOX_WORKSPACE' "${INSTALL_SH}" 1 "DEVILBOX_WORKSPACE env var"

# 6. Legacy flags preserved
print_h_sub "6. Legacy flags preserved"
assert_grep_count '\-h\|--help' "${INSTALL_SH}" 1 "-h|--help preserved"
assert_grep_count '\-f\|--force' "${INSTALL_SH}" 1 "-f|--force preserved"
assert_grep_count '\-v\|--verbose' "${INSTALL_SH}" 1 "-v|--verbose preserved"

# 7. Loader function defined + called
print_h_sub "7. _load_containers_from_env_example defined and invoked"
assert_grep_count '_load_containers_from_env_example' "${INSTALL_SH}" 2 "_load_containers_from_env_example appears (def + call)"

# 8. No accidental sudo command invocations
print_h_sub "8. No bare 'sudo ' command invocations"
_sudo_count="$(grep -cE '^\s*sudo ' "${INSTALL_SH}" || true)"
if [ "${_sudo_count}" -eq 0 ]; then
	pass "No bare 'sudo ' command lines found"
else
	fail "Found ${_sudo_count} bare 'sudo ' command line(s) in install.sh"
fi

# 9. Bash shebang preserved (first line)
print_h_sub "9. Bash shebang preserved"
_first_line="$(head -n1 "${INSTALL_SH}")"
if [ "${_first_line}" = "#!/usr/bin/env bash" ]; then
	pass "First line is '#!/usr/bin/env bash'"
else
	fail "First line is '${_first_line}', expected '#!/usr/bin/env bash'"
fi

# 10. Idempotency guards intact (grep -q DEVILBOX_CONTAINERS / DEVILBOX_PATH)
print_h_sub "10. Shell-profile idempotency guards intact"
assert_grep_count 'grep -q "DEVILBOX_CONTAINERS"' "${INSTALL_SH}" 1 "grep -q DEVILBOX_CONTAINERS guard present"
assert_grep_count 'grep -q "DEVILBOX_PATH"' "${INSTALL_SH}" 1 "grep -q DEVILBOX_PATH guard present"

# ---------------------------------------------------------------------------
# Final report
# ---------------------------------------------------------------------------
print_h_main "ALL CHECKS PASSED"
printf '  %sTotal pass assertions:%s %d\n\n' "${_C_GREEN}" "${_C_RESET}" "${PASS_COUNT}"
exit 0
