#!/usr/bin/env -S usage bash
#USAGE flag "-n --name <name>" help="Module name (must contain a hostname and a path) (for example: 'github.com/your-username/your-repo-name')"
#USAGE arg "<dir>"

set -xeuo pipefail

dir=$(realpath "${usage_dir:?}")
name="${usage_name:-}"

function validate_name() {
  local name_to_validate="${1:-}" # Use default empty string if no arg passed

  # Check 1: Not empty
  if [[ -z "$name_to_validate" ]]; then
    echo "Module name cannot be empty." >&2
  elif [[ ! "$name_to_validate" =~ ^[a-z0-9]+(\.[a-z0-9]+)+\/.+$ ]]; then
    echo "Invalid format." >&2
    echo "Name must contain a hostname and a path separated by a slash." >&2
    echo "Name must contain only lower case ASCII letters, ASCII digits, and limited ASCII punctuation (-, _, .)." >&2
    echo "Name cannot be empty before or after the first slash." >&2
    echo "Example: github.com/your-username/your-repo-name" >&2
    return 1
  fi

  return 0
}

echo "Validating Cue module name..."
while ! validate_name "$name"; do
  read -r -p "Cue module name (format: {hostname}/{path}) (example: \"github.com/your-username/your-repo-name\"): " name
done

name="${name}@v0"

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
