#!/usr/bin/env sh
# The one quality gate. CI and developers run the same script.
#
#   ./scripts/prepare.sh          fix mode (default locally): zig fmt in place, then every check
#   ./scripts/prepare.sh --check  check mode (default when CI=true): changes nothing
#
# zlint runs when installed (set REQUIRE_TOOLS=1 to require it).
#
# If `zig build` cannot run on this machine (for example a Zig release older than the host macOS),
# the gate falls back to `zig test` for the library and the CLI. The fallback skips the
# cross-compile and release steps and says so.
set -eu
cd -P "$(dirname "$0")/.."

mode=fix
[ "${CI:-}" = "true" ] && mode=check
for arg in "$@"; do
    case "$arg" in
    --check) mode=check ;;
    --fix) mode=fix ;;
    *) printf '%s\n' "Usage: scripts/prepare.sh [--check|--fix]" >&2; exit 2 ;;
    esac
done
require="${REQUIRE_TOOLS:-}"

step() {
    label=$1; shift
    printf '[gate] START %s\n' "$label"
    if "$@"; then printf '[gate] OK    %s\n' "$label"; else
        status=$?; printf '[gate] FAIL  %s (exit %s)\n' "$label" "$status" >&2; return "$status"
    fi
}

command -v zig >/dev/null 2>&1 || { printf '%s\n' "Error: zig is required (see .zigversion)." >&2; exit 1; }
want=$(cat .zigversion)
have=$(zig version)
[ "$have" = "$want" ] || printf '[gate] WARN  zig %s found, .zigversion pins %s\n' "$have" "$want"

if [ "$mode" = fix ]; then
    step "format (zig fmt)" zig fmt src build.zig build.zig.zon
else
    step "format check (zig fmt)" zig fmt --check src build.zig build.zig.zon
fi

if command -v zlint >/dev/null 2>&1; then
    step "lint (zlint)" zlint
elif [ -n "$require" ]; then
    printf '[gate] FAIL  lint: zlint is not installed\n' >&2; exit 1
else
    printf '[gate] SKIP  lint (install zlint to enable)\n'
fi

if zig build --help >/dev/null 2>&1; then
    step "tests (zig build test)" zig build test --summary all
    step "build ReleaseSafe" zig build -Doptimize=ReleaseSafe
    for target in x86_64-linux-gnu aarch64-linux-gnu x86_64-windows-gnu aarch64-macos; do
        step "cross-compile $target" zig build -Dtarget="$target" -Doptimize=ReleaseSafe --prefix "zig-out/$target"
    done
else
    printf '[gate] WARN  zig build does not run on this machine: using the zig test fallback\n'
    target=""
    if [ "$(uname -s)" = Darwin ]; then target="-target $(uname -m | sed 's/arm64/aarch64/')-macos.15.0"; fi
    # shellcheck disable=SC2086
    step "tests: library (zig test)" zig test $target src/root.zig
    # shellcheck disable=SC2086
    step "tests: cli (zig test)" zig test $target --dep essential -Mroot=src/main.zig -Messential=src/root.zig
    printf '[gate] SKIP  release build and cross-compiles (need a working zig build)\n'
fi
printf '[gate] all checks passed (%s mode)\n' "$mode"
