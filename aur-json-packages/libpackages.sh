#!/usr/bin/env bash


ARGS=()
FILTER=".packages"

INPUT_ACTION="$1"
INPUT_PKGNAMES="$2"
INPUT_KEYS="$3"

readarray -t INPUT_KEYS < <(printf '%s\n' "$INPUT_KEYS")
readarray -t INPUT_PKGNAMES < <(printf '%s\n' "$INPUT_PKGNAMES")
if [[ -n "$4" ]]; then
  INPUT_VALUES=()
  for x in $4; do INPUT_VALUES+=("$x"); done
fi


if [[ "$INPUT_ACTION" =~ ^(add|update|remove|delete)$ ]]; then
  ARGS+=(set)
fi

array_contains_not() {
  local search="$1"; shift
  local item
  for item in "$@"; do
    [[ "$item" == "$search" ]] && return 1
  done
  return 0
}

is_json() {
  local input="$1"
  [[ -z "$input" ]] && return 1
  echo "$input" | jq -e . >/dev/null 2>&1
}

get_all_packages() {
  local filter="$FILTER"
  printf '%s\n' "$filter"
}

get_all_packages_with_keys() {
  local filter="$FILTER | map_values({"
  local args=()
  for ((n=0; n<${#INPUT_KEYS[@]}; n++)); do
    [[ -z "${INPUT_KEYS[n]}" ]] && continue
    key="${INPUT_KEYS[n]}"
    args+=(--arg "key$n" "$key")
    filter+="\$key$n: .[\$key$n],"
  done
  filter="${filter%,}})"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

get_packages_with_pkgnames() {
  local filter="$FILTER | {"
  local args=()
  for ((i=0; i<${#INPUT_PKGNAMES[@]}; i++)); do
    [[ -z "${INPUT_PKGNAMES[i]}" ]] && continue
    pkgname="${INPUT_PKGNAMES[i]}"
    args+=(--arg "pkg$i" "$pkgname")
    filter+="\$pkg$i: .[\$pkg$i],"
  done
  filter="${filter%,}}"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

get_packages_with_pkgname_and_keys() {
  local filter="$FILTER | {"
  local args=()
  local i=0 n=0
  for ((i=0; i<${#INPUT_PKGNAMES[@]}; i++)); do
    [[ -z "${INPUT_PKGNAMES[i]}" ]] && continue
    pkgname="${INPUT_PKGNAMES[i]}"
    args+=(--arg "pkg$i" "$pkgname")
    filter+="\$pkg$i: {"
    for ((n=0; n<${#INPUT_KEYS[@]}; n++)); do
      [[ -z "${INPUT_KEYS[n]}" ]] && continue
      key="${INPUT_KEYS[n]}"
      args+=(--arg "key$n" "$key")
      filter+="\$key$n: .[\$pkg$i][\$key$n],"
    done
    filter="${filter%,}},"
  done
  filter="${filter%,}}"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

add_package_with_multiple_pkgnames_and_multiple_values_and_no_keys() {
  local args=()
  local filter="$FILTER + {"
  for ((i=0; i<${#INPUT_PKGNAMES[@]}; i++)); do
    [[ -z "${INPUT_PKGNAMES[i]}" || -z "${INPUT_VALUES[i]}" ]] && continue
    value="${INPUT_VALUES[i]}"
    args+=(--arg "pkg$i" "${INPUT_PKGNAMES[i]}")
    args+=(--argjson "val$i" "$value")
    filter+="\$pkg$i: \$val$i,"
  done
  filter="${filter%,}}"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

add_package_with_one_pkgname_and_multiple_keys_and_multiple_values() {
  local args=()
  local filter="$FILTER + {"
  pkgname="${INPUT_PKGNAMES[0]}"
  args+=(--arg "pkg" "$pkgname")
  filter+="\$pkg: {"
  for ((i=0; i<${#INPUT_KEYS[@]}; i++)); do
    [[ -z "${INPUT_KEYS[i]}" || -z "${INPUT_VALUES[i]}" ]] && continue
    key="${INPUT_KEYS[i]}"
    value="${INPUT_VALUES[i]}"
    args+=(--arg "key$i" "$key")
    args+=(--arg "val$i" "$value")
    filter+="\$key$i: \$val$i,"
  done
  filter="${filter%,}}}"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

add_package_with_no_pkgname_and_multiple_values_and_no_keys() {
  local args=()
  local filter="$FILTER + "
  for ((i=0; i<${#INPUT_VALUES[@]}; i++)); do
    [[ -z "${INPUT_VALUES[i]}" ]] && continue
    value="${INPUT_VALUES[i]}"
    args+=(--argjson "val$i" "$value")
    filter+="\$val$i,"
  done
  filter="${filter%,}"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

remove_packages_with_multiple_pkgnames() {
  local args=()
  local filter="$FILTER | del("
  for ((i=0; i<${#INPUT_PKGNAMES[@]}; i++)); do
    [[ -z "${INPUT_PKGNAMES[i]}" ]] && continue
    args+=(--arg "pkg$i" "${INPUT_PKGNAMES[i]}")
    filter+=".[\$pkg$i],"
  done
  filter="${filter%,})"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

remove_from_one_package_multiple_keys() {
  local args=()
  local filter="$FILTER |= (.[\$pkg] |= del("
  pkgname="${INPUT_PKGNAMES[0]}"
  args+=(--arg "pkg" "$pkgname")
  for ((i=0; i<${#INPUT_KEYS[@]}; i++)); do
    [[ -z "${INPUT_KEYS[i]}" ]] && continue
    key="${INPUT_KEYS[i]}"
    args+=(--arg "key$i" "$key")
    filter+=".[\$key$i],"
  done
  filter="${filter%,}))"
  printf '%s\n' "${args[@]}"
  printf '%s\n' "$filter"
}

action_get() {
  if [[ -z "$1" && -z "$2" ]]; then
    get_all_packages
  elif [[ -z "$1" && -n "$2" ]]; then
    get_all_packages_with_keys
  elif [[ -n "$1" && -z "$2" ]]; then
    get_packages_with_pkgnames
  elif [[ -n "$1" && -n "$2" ]]; then
    get_packages_with_pkgname_and_keys
  else
    echo "Invalid input combination for 'get' action." >&2
    exit 1
  fi
}

action_update() {
  if [[ -n "$1" && -n "$2" && -n "$3" ]]; then
    add_package_with_one_pkgname_and_multiple_keys_and_multiple_values
  elif [[ -z "$1" && -z "$2" && -n "$3" ]]; then
    add_package_with_no_pkgname_and_multiple_values_and_no_keys
  elif [[ -n "$1" && -z "$2" && -n "$3" ]]; then
    add_package_with_multiple_pkgnames_and_multiple_values_and_no_keys
  else
    echo "Invalid input combination for 'update' action." >&2
    exit 1
  fi
}

action_remove() {
  if [[ -n "$1" && -z "$2" ]]; then
    remove_packages_with_multiple_pkgnames
  elif [[ -n "$1" && -n "$2" ]]; then
    remove_from_one_package_multiple_keys
  else
    echo "Invalid input combination for 'remove' action." >&2
    exit 1
  fi
}

case "$INPUT_ACTION" in
  get) action_get "$INPUT_PKGNAMES" "$INPUT_KEYS";;
  update|add) action_update "$INPUT_PKGNAMES" "$INPUT_KEYS" "$INPUT_VALUES";;
  remove|delete) action_remove "$INPUT_PKGNAMES" "$INPUT_KEYS";;
  *)
    echo "Invalid action: $INPUT_ACTION. Supported actions are: get, add, update, remove, delete." >&2
    exit 1
    ;;
esac
