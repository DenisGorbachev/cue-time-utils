#!/usr/bin/env -S usage bash
#USAGE flag "-n --name <name>" help="Package name (if this flag is not provided, then the package name is inferred from the directory name)"
#USAGE arg "<dir>"

set -xeuo pipefail

dir=$(realpath "${usage_dir:?}")
name_new_default="${usage_name:-$(basename "$dir")}"

read -r -p "Cue module name (default: $name_new_default): " name_new

if [[ -z $name_new ]]; then
  name_new=$name_new_default
fi

(
  cd "$dir"

  mise trust
  mise install

  rm "README.md"
  rm "LICENSE-APACHE"
  rm "LICENSE-MIT"

  sd "module: \"cue.example\"" "module: \"$name_new\"" "cue.mod/module.cue"

  mise exec "npm:lefthook" -- lefthook install
  mise run test

  # remove .repoconf just before the final commit
  rm -r ".repoconf"

  git add .
  git commit -a -m "chore: update package details"
)
