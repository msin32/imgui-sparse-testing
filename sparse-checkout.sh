#!/usr/bin/env sh
set -e

DEF_FILE="${1:-sparse-definitions}"

current_module=""
paths=""

apply_sparse() {
    mod="$1"
    shift
    if [ -z "$mod" ] || [ $# -eq 0 ]; then
        return
    fi
    echo "Applying sparse-checkout for $mod"
    git -C "$mod" sparse-checkout init --cone 2>/dev/null || true
    git -C "$mod" sparse-checkout set "$@"
    git -C "$mod" sparse-checkout reapply
}

while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        \#*|"") # comment or empty
            continue
            ;;
        

\[*\]

)
            # new module block
            # flush previous
            if [ -n "$current_module" ] && [ -n "$paths" ]; then
                # shellsplit paths into args
                set -- $paths
                apply_sparse "$current_module" "$@"
            fi
            current_module="${line#[}"
            current_module="${current_module%]}"
            paths=""
            ;;
        *)
            # path line
            paths="$paths $line"
            ;;
    esac
done < "$DEF_FILE"

# flush last block
if [ -n "$current_module" ] && [ -n "$paths" ]; then
    set -- $paths
    apply_sparse "$current_module" "$@"
fi
