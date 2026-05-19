#!/usr/bin/env bash
set -uo pipefail

ALL_TYPES=(solved simplified default)
ALL_LABS=(testing exploratory clustering omics ML regression randomness multivariate)
DEFAULT_ONLY_LABS=(exploratory randomness)

usage() {
  echo "Usage: $(basename "$0") --type <type|all> [--lab <labs|all>]

  Available options:
    type: solved simplified default
    labs: testing exploratory clustering omics ML regression randomness multivariate"
}

die() { echo "Error: $*" >&2; usage; exit 1; }
[[ $# -eq 0 ]] && { usage; exit 1; }

QUARTO=$(command -v quarto || true)
if [[ -z $QUARTO ]]; then
  for c in \
    "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto" \
    "/Applications/quarto/bin/quarto" \
    "/usr/local/bin/quarto" \
    "/opt/homebrew/bin/quarto"; do
    [[ -x $c ]] && { QUARTO=$c; break; }
  done
fi
[[ -z $QUARTO ]] && die "quarto not found on PATH or in known locations"

types=() labs=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) shift; while [[ $# -gt 0 && $1 != --* ]]; do types+=("$1"); shift; done ;;
    --lab)  shift; while [[ $# -gt 0 && $1 != --* ]]; do labs+=("$1");  shift; done ;;
    *) die "Unknown option $1" ;;
  esac
done
[[ ${#types[@]} -eq 0 ]] && die "--type needs at least one value"

valid_or_die() { local v=$1; shift
  [[ " $* " == *" $v "* ]] || die "Invalid value $v"
}
expand() { local name=$1; shift; local full=("$@") cur v
  eval "cur=(\"\${${name}[@]}\")"
  [[ " ${cur[*]} " == *" all "* ]] && cur=("${full[@]}")
  for v in "${cur[@]}"; do valid_or_die "$v" "${full[@]}"; done
  eval "${name}=(\"\${cur[@]}\")"
}
expand types "${ALL_TYPES[@]}"
[[ ${#labs[@]} -eq 0 ]] && labs=("${ALL_LABS[@]}")
expand labs "${ALL_LABS[@]}"

render() {
  local qmd=$1
  local type=$2
  local base=${qmd%.qmd}
  local html="${base}.html"

  echo "Rendering $qmd ($type)"
  case $type in
    solved)     "$QUARTO" render "$qmd" -P answers:true ;;
    simplified) "$QUARTO" render "$qmd" -P simplified:true ;;
    default)    "$QUARTO" render "$qmd" ;;
  esac

  [[ -f $html ]] || die "Render failed: $html not found"
  [[ $type != default ]] && mv "$html" "${base}.${type}.html"
}

shopt -s nullglob
for lab in "${labs[@]}"; do
  qmd_files=(labs/"$lab"/*.qmd)
  [[ ${#qmd_files[@]} -eq 0 ]] && { echo "Skip: no .qmd in $lab"; continue; }

  if [[ " ${DEFAULT_ONLY_LABS[*]} " == *" $lab "* ]]; then
    for qmd in "${qmd_files[@]}"; do render "$qmd" default; done
  else
    for type in "${types[@]}"; do
      for qmd in "${qmd_files[@]}"; do render "$qmd" "$type"; done
    done
  fi
done
shopt -u nullglob
