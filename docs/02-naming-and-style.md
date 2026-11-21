# 2. Naming and style

Follow the standard library's conventions.

| Thing | Style | Example |
| --- | --- | --- |
| Functions | `camelCase` | `greet`, `addItem` |
| Types and error sets | `PascalCase` | `TodoList`, `Error` |
| Variables, fields, constants of non-type value | `snake_case` | `next_id` |
| Files | `snake_case.zig` | `todo.zig` |

Documentation: `//!` at the top of each file, `///` on every public declaration (what it does, who owns returned memory, which errors it returns). Format with `zig fmt`; the gate fails on unformatted code.
