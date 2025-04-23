#!/usr/bin/env -S usage bash
#USAGE flag "-n --name <name>" help="Module name (must contain a hostname and a path) (for example: 'example.com/my/module')"
#USAGE arg "<dir>"

set -xeuo pipefail

dir=$(realpath "${usage_dir:?}")
name="${usage_name:-}"

function validate_name() {
  local name_to_validate="${1:-}" # Use default empty string if no arg passed

  # Check 1: Not empty
  if [[ -z "$name_to_validate" ]]; then
    echo "Module name cannot be empty." >&2
  elif [[ ! "$name_to_validate" =~ ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+\/.+$ ]]; then
    echo "Invalid format. Name must contain a hostname and a path separated by a slash (e.g., 'example.com/my/module'). Cannot be empty before or after the first slash." >&2
    return 1
  fi

  return 0
}

echo "Validating Cue module name..."
while ! validate_name "$name"; do
  read -r -p "Cue module name (format: {hostname}/{path}) (example: \"example.com/my/module\"): " name
done

(
  cd "$dir"

  files=("README.md" "LICENSE-APACHE" "LICENSE-MIT")
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      rm "$file"
    fi
  done

  mise trust
  mise exec -- sd "module: \"cue.example\"" "module: \"$name\"" "cue.mod/module.cue"
  mise exec -- lefthook install
  mise run test

  # remove .repoconf just before the final commit
  rm -r ".repoconf"

  git add .
  git commit -a -m "chore: update package details"
)
