#!/usr/bin/env bats
# Wave 8E0 — AgentCommand multi-stack layering tests.
# Sources dvl.sh in a sandboxed DEVILBOX_PATH so the script's heavy bootstrap
# (yq download, .lib.sh, env-getvar.sh) is bypassed.

setup() {
  export DEVILBOX_PATH="${BATS_TEST_TMPDIR}/devilbox"
  mkdir -p \
    "${DEVILBOX_PATH}/compose" \
    "${DEVILBOX_PATH}/.tests/scripts" \
    "${DEVILBOX_PATH}/.tests/binaries" \
    "${DEVILBOX_PATH}/bin"

  # Fake compose overrides for known slugs.
  for slug in agentic hermes-workspace multica; do
    cat > "${DEVILBOX_PATH}/compose/docker-compose.override.yml-${slug}" <<EOF
version: '2.3'
services:
  ${slug}:
    image: busybox
EOF
  done

  # Stub heavy bootstrap pieces so we can source dvl.sh directly.
  cat > "${DEVILBOX_PATH}/.tests/scripts/.lib.sh" <<'EOF'
spinner() { :; }
EOF
  cat > "${DEVILBOX_PATH}/.tests/scripts/env-getvar.sh" <<'EOF'
#!/usr/bin/env bash
echo ""
EOF
  chmod +x "${DEVILBOX_PATH}/.tests/scripts/env-getvar.sh"
  : > "${DEVILBOX_PATH}/.tests/binaries/yq"
  chmod +x "${DEVILBOX_PATH}/.tests/binaries/yq"

  # Stub `docker` so tests never invoke real docker. Always exits 0; if asked
  # for `config --services`, echoes the slug derived from the -f argument.
  cat > "${DEVILBOX_PATH}/bin/docker" <<'EOF'
#!/usr/bin/env bash
# Find -f <path> if present, derive slug from filename.
fpath=""
for ((i=1; i<=$#; i++)); do
  if [[ "${!i}" == "-f" ]]; then
    j=$((i+1)); fpath="${!j}"
  fi
done
if [[ "$*" == *"config --services"* && -n "$fpath" ]]; then
  base="${fpath##*/docker-compose.override.yml-}"
  echo "$base"
fi
exit 0
EOF
  chmod +x "${DEVILBOX_PATH}/bin/docker"
  export PATH="${DEVILBOX_PATH}/bin:${PATH}"

  # A minimal docker-compose.yml at the root so the layering target exists.
  cat > "${DEVILBOX_PATH}/docker-compose.yml" <<'EOF'
version: '2.3'
services: {}
EOF

  # Source dvl.sh — bypassing the yq downloader (the binary stub exists).
  # shellcheck disable=SC1090
  source "${BATS_TEST_DIRNAME}/../dvl.sh" >/dev/null 2>&1 || true
}

teardown() {
  unset COMPOSE_FILE
}

@test "enable single stack: list contains slug" {
  run _agent_stacks_list_add "agentic"
  [ "$status" -eq 0 ]
  run _agent_stacks_list_read
  [ "$status" -eq 0 ]
  [ "$output" = "agentic" ]
}

@test "_agent_compose_files emits absolute path for enabled stack" {
  _agent_stacks_list_add "agentic"
  run _agent_compose_files
  [ "$status" -eq 0 ]
  [ "$output" = "${DEVILBOX_PATH}/compose/docker-compose.override.yml-agentic" ]
}

@test "enable multiple stacks: list ordered as added" {
  _agent_stacks_list_add "agentic"
  _agent_stacks_list_add "hermes-workspace"
  _agent_stacks_list_add "multica"
  run _agent_stacks_list_read
  [ "$status" -eq 0 ]
  expected=$'agentic\nhermes-workspace\nmultica'
  [ "$output" = "$expected" ]
}

@test "_agent_compose_files emits colon-separated paths in order" {
  _agent_stacks_list_add "agentic"
  _agent_stacks_list_add "multica"
  run _agent_compose_files
  expected="${DEVILBOX_PATH}/compose/docker-compose.override.yml-agentic:${DEVILBOX_PATH}/compose/docker-compose.override.yml-multica"
  [ "$output" = "$expected" ]
}

@test "enable duplicate slug is idempotent" {
  _agent_stacks_list_add "agentic"
  _agent_stacks_list_add "agentic"
  _agent_stacks_list_add "agentic"
  run _agent_stacks_list_read
  [ "$output" = "agentic" ]
}

@test "disable removes from list" {
  _agent_stacks_list_add "agentic"
  _agent_stacks_list_add "multica"
  run _agent_stacks_list_remove "agentic"
  [ "$status" -eq 0 ]
  run _agent_stacks_list_read
  [ "$output" = "multica" ]
}

@test "invalid slug 'Foo BAR' rejected (validate helper)" {
  run _agent_validate_slug "Foo BAR"
  [ "$status" -ne 0 ]
}

@test "AgentCommand enable rejects invalid slug" {
  run AgentCommand enable "Foo BAR"
  [ "$status" -ne 0 ]
}

@test "AgentCommand enable rejects unknown stack (no override file)" {
  run AgentCommand enable "xyz"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown stack 'xyz'"* ]]
}

@test "AgentCommand list prints enabled + available" {
  _agent_stacks_list_add "agentic"
  run AgentCommand list
  [ "$status" -eq 0 ]
  [[ "$output" == *"agentic"* ]]
  [[ "$output" == *"hermes-workspace"* ]]
  [[ "$output" == *"multica"* ]]
  [[ "$output" == *"enabled"* ]]
  [[ "$output" == *"disabled"* ]]
}

@test "_agent_export_compose_file sets COMPOSE_FILE with base + overrides" {
  _agent_stacks_list_add "agentic"
  _agent_export_compose_file
  [ "$COMPOSE_FILE" = "${DEVILBOX_PATH}/docker-compose.yml:${DEVILBOX_PATH}/compose/docker-compose.override.yml-agentic" ]
}

@test "_agent_export_compose_file falls back to base only when list empty" {
  _agent_export_compose_file
  [ "$COMPOSE_FILE" = "${DEVILBOX_PATH}/docker-compose.yml" ]
}

@test "legacy migration: root override copy seeds list and is removed" {
  cp "${DEVILBOX_PATH}/compose/docker-compose.override.yml-agentic" \
     "${DEVILBOX_PATH}/docker-compose.override.yml"
  run _agent_migrate_legacy
  [ "$status" -eq 0 ]
  [ ! -f "${DEVILBOX_PATH}/docker-compose.override.yml" ]
  run _agent_stacks_list_read
  [ "$output" = "agentic" ]
}

@test "legacy migration is a no-op when list already exists" {
  _agent_stacks_list_add "agentic"
  cp "${DEVILBOX_PATH}/compose/docker-compose.override.yml-agentic" \
     "${DEVILBOX_PATH}/docker-compose.override.yml"
  run _agent_migrate_legacy
  [ "$status" -eq 0 ]
  # Should NOT have removed the root override (list pre-existed)
  [ -f "${DEVILBOX_PATH}/docker-compose.override.yml" ]
}

@test "AgentCommand enable agentic + up exports correct COMPOSE_FILE" {
  run AgentCommand enable agentic
  [ "$status" -eq 0 ]
  run AgentCommand up
  [ "$status" -eq 0 ]
}

# -----------------------------------------------------------------------------
# Wave 8E1 — hermes-workspace stack discovery + enable
# -----------------------------------------------------------------------------

@test "Wave 8E1: _agent_available_stacks enumerates hermes-workspace" {
  run _agent_available_stacks
  [ "$status" -eq 0 ]
  [[ "$output" == *"hermes-workspace"* ]]
}

@test "Wave 8E1: AgentCommand enable hermes-workspace + list contains slug" {
  run AgentCommand enable hermes-workspace
  [ "$status" -eq 0 ]
  run _agent_stacks_list_read
  [ "$status" -eq 0 ]
  [[ "$output" == *"hermes-workspace"* ]]
}

@test "Wave 8E1: _agent_compose_files emits hermes-workspace path when enabled" {
  _agent_stacks_list_add "hermes-workspace"
  run _agent_compose_files
  [ "$status" -eq 0 ]
  expected="${DEVILBOX_PATH}/compose/docker-compose.override.yml-hermes-workspace"
  [ "$output" = "$expected" ]
}

@test "Wave 8E1: layered enable (agentic + hermes-workspace) exports both paths" {
  _agent_stacks_list_add "agentic"
  _agent_stacks_list_add "hermes-workspace"
  _agent_export_compose_file
  expected="${DEVILBOX_PATH}/docker-compose.yml:${DEVILBOX_PATH}/compose/docker-compose.override.yml-agentic:${DEVILBOX_PATH}/compose/docker-compose.override.yml-hermes-workspace"
  [ "$COMPOSE_FILE" = "$expected" ]
}

# -----------------------------------------------------------------------------
# Wave 8F1 — multica stack discovery + enable
# -----------------------------------------------------------------------------

@test "Wave 8F1: _agent_available_stacks enumerates multica" {
  run _agent_available_stacks
  [ "$status" -eq 0 ]
  [[ "$output" == *"multica"* ]]
}

@test "Wave 8F1: AgentCommand enable multica + list contains slug" {
  run AgentCommand enable multica
  [ "$status" -eq 0 ]
  run _agent_stacks_list_read
  [ "$status" -eq 0 ]
  [[ "$output" == *"multica"* ]]
}

@test "Wave 8F1: _agent_compose_files emits multica path when enabled" {
  _agent_stacks_list_add "multica"
  run _agent_compose_files
  [ "$status" -eq 0 ]
  expected="${DEVILBOX_PATH}/compose/docker-compose.override.yml-multica"
  [ "$output" = "$expected" ]
}

@test "Wave 8F1: triple-stack enable (agentic + hermes-workspace + multica) exports all three paths" {
  _agent_stacks_list_add "agentic"
  _agent_stacks_list_add "hermes-workspace"
  _agent_stacks_list_add "multica"
  _agent_export_compose_file
  expected="${DEVILBOX_PATH}/docker-compose.yml:${DEVILBOX_PATH}/compose/docker-compose.override.yml-agentic:${DEVILBOX_PATH}/compose/docker-compose.override.yml-hermes-workspace:${DEVILBOX_PATH}/compose/docker-compose.override.yml-multica"
  [ "$COMPOSE_FILE" = "$expected" ]
}
