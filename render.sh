#!/usr/bin/env bash
set -uo pipefail

ALL_TYPES=(solved simplified default public)
ALL_LABS=(testing exploratory clustering omics ML regression randomness multivariate)
DEFAULT_ONLY_LABS=(exploratory randomness)

usage() {
  echo "Usage: $(basename "$0") --type <type|all> [--lab <labs|all>]

  Available options:
    type: solved simplified default public
    labs: testing exploratory clustering omics ML regression randomness multivariate"
}

die() { echo "Error: $*" >&2; usage; exit 1; }
[[ $# -eq 0 ]] && { usage; exit 1; }

QUARTO=$(command -v quarto) || die "quarto not found on PATH. Install quarto-cli or add it to PATH."

types=() labs=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) shift; while [[ $# -gt 0 && $1 != --* ]]; do types+=("$1"); shift; done ;;
    --lab)  shift; while [[ $# -gt 0 && $1 != --* ]]; do labs+=("$1");  shift; done ;;
    *) die "Unknown option $1" ;;
  esac
done
[[ ${#types[@]} -eq 0 ]] && die "--type needs at least one value"
[[ ${#labs[@]}  -eq 0 ]] && labs=("${ALL_LABS[@]}")

contains() { local v=$1; shift; [[ " $* " == *" $v "* ]]; }

[[ " ${types[*]} " == *" all "* ]] && types=("${ALL_TYPES[@]}")
for t in "${types[@]}"; do contains "$t" "${ALL_TYPES[@]}" || die "Invalid type $t"; done

[[ " ${labs[*]} " == *" all "* ]] && labs=("${ALL_LABS[@]}")
for l in "${labs[@]}"; do contains "$l" "${ALL_LABS[@]}" || die "Invalid lab $l"; done

render() {
  local qmd=$1
  local type=$2
  local base=${qmd%.qmd}
  local html="${base}.html"

  if [[ $type == public ]] && ! grep -q '^[[:space:]]*include_answers:' "$qmd"; then
    echo "Skip: no include_answers param in $qmd"
    return
  fi

  echo "Rendering $qmd ($type)"
  case $type in
    solved)
      if grep -q '^[[:space:]]*include_answers:' "$qmd"; then
        "$QUARTO" render "$qmd" -P include_answers:true
      else
        "$QUARTO" render "$qmd" -P answers:true
      fi
      ;;
    simplified) "$QUARTO" render "$qmd" -P simplified:true ;;
    default)    "$QUARTO" render "$qmd" ;;
    public)     "$QUARTO" render "$qmd" -P include_answers:false ;;
  esac || die "quarto render failed for $qmd ($type) -- see error above"

  [[ -f $html ]] || die "quarto reported success but $html was not produced"
  if [[ $type == public ]]; then
    local lab_dir
    lab_dir=$(basename "$(dirname "$qmd")")
    mkdir -p "docs/$lab_dir"
    mv "$html" "docs/$lab_dir/index.html"
  elif [[ $type != default ]]; then
    mv "$html" "${base}.${type}.html"
  fi
}

shopt -s nullglob
for lab in "${labs[@]}"; do
  qmd_files=(labs/"$lab"/*.qmd)
  [[ ${#qmd_files[@]} -eq 0 ]] && { echo "Skip: no .qmd in $lab"; continue; }

  if [[ " ${DEFAULT_ONLY_LABS[*]} " == *" $lab "* ]]; then
    if [[ " ${types[*]} " == *" public "* ]]; then
      echo "Skip: $lab has no include_answers param (default-only lab)"
    else
      for qmd in "${qmd_files[@]}"; do render "$qmd" default; done
    fi
  else
    for type in "${types[@]}"; do
      for qmd in "${qmd_files[@]}"; do render "$qmd" "$type"; done
    done
  fi
done
shopt -u nullglob
