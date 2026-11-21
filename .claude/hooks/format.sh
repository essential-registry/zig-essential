#!/bin/sh
# Format the file Claude just edited. Reads the hook payload on stdin; never fails the edit.
file=$(sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -n "$file" ] && [ -f "$file" ] || exit 0
case "$file" in
  *.zig) zig fmt "$file" >/dev/null 2>&1 ;;
esac
exit 0
