# 4. Testing

```bash
zig build test --summary all
```

- Tests are `test "name" { ... }` blocks next to the code. `root.zig` runs `refAllDecls` so tests in re-exported files are included.
- Use `std.testing.allocator` so leaks fail tests; use `std.testing.expectError` for error cases.
- The CLI's `run` function writes to any `std.Io.Writer`, so tests capture output with a fixed buffer instead of spawning a process.
- Fuzz tests: `std.testing.fuzz` (see the Zig docs), run with `zig build test --fuzz`.
