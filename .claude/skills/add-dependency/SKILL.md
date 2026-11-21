---
name: add-dependency
description: Add a Zig package dependency.
---

Run `zig fetch --save <url>` (ask first: it downloads), then in `build.zig` get it with `b.dependency(...)` and add it to the module `imports`. Commit the updated `build.zig.zon`.
