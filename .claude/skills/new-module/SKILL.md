---
name: new-module
description: Add a module to the library with tests.
---

Create `src/<name>.zig` with a `//!` header, `///` docs and `test` blocks, re-export it from `src/root.zig` (`pub const <name> = @import("<name>.zig");`), return errors from the shared `Error` set, run `./scripts/prepare.sh`.
