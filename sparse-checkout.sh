#!/usr/bin/env bash
set -euo pipefail

DEF_FILE="${1:-sparse-definitions}"

current_module=""
paths=()

flush_module() {
    if [[ -z "$current_module" || ${#paths[@]} -eq 0 ]]; then
        return
    fi

    if [[ ! -d "$current_module" ]]; then
        echo "Skipping $current_module (directory does not exist)"
        paths=()
        return
    fi

    echo "Applying sparse-checkout for $current_module"

    # Ensure non-cone mode so file paths are allowed
    git -C "$current_module" sparse-checkout init --no-cone 2>/dev/null || true

    # Apply patterns
    git -C "$current_module" sparse-checkout set "${paths[@]}"
    git -C "$current_module" sparse-checkout reapply

    paths=()
}

while IFS= read -r line || [[ -n "$line" ]]; do
    # trim leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # skip empty or comment
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi

    # section header: [lib/imgui]
    if [[ "${line:0:1}" == "[" && "${line: -1}" == "]" ]]; then
        flush_module
        current_module="${line:1:${#line}-2}"
    else
        # ensure leading slash for non-cone correctness
        if [[ "${line:0:1}" != "/" ]]; then
            line="/$line"
        fi
        paths+=("$line")
    fi
done < "$DEF_FILE"

flush_module
