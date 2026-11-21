# 3. Errors and memory

## Errors

The library exposes one error set, `essential.Error`. Functions return `Error!T` (or a subset). Callers `try`, or `catch |err| switch (err) { ... }` to handle specific cases. Do not return `anyerror` from public functions, and never `@panic` for failures a caller can recover from.

## Memory

- Allocators are explicit parameters: `fn greet(allocator: std.mem.Allocator, ...)`. There is no global allocator in library code.
- Document ownership: "the caller owns the returned slice and frees it with `allocator`".
- Pair every allocation with a `defer`/`errdefer` on the next line so early returns do not leak.
- Create the allocator at the edge (`main`) and pass it down. In `main` use `std.heap.GeneralPurposeAllocator` in debug (it reports leaks), an arena for short-lived command-line tools.
- Tests use `std.testing.allocator`, which fails the test on any leak or double free. `std.testing.FailingAllocator` forces allocation failures to test `errdefer` paths (see `todo.zig`).
