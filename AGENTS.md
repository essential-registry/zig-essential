# Zig Essential: guide for AI agents

Zig 0.15 starter: a library module, a thin CLI, tests that fail on leaks, `zig fmt`, optional zlint, docs generation, cross-compile checks, one quality gate. The Zig version is pinned in `.zigversion` and `build.zig.zon`.

## Commands

```bash
zig build run -- greet Ada         # run the CLI
zig build test --summary all        # all tests (std.testing.allocator fails a test that leaks)
zig build fmt / fmt-check           # format / check formatting
zig build docs                      # API docs into zig-out/docs
zig build -Doptimize=ReleaseSafe -Dtarget=x86_64-linux-gnu   # cross-compile
./scripts/prepare.sh                # fix mode: zig fmt, then every check
./scripts/prepare.sh --check        # the CI gate (non-mutating)
```

The gate is `./scripts/prepare.sh --check`. CI runs the same thing, so a change that passes locally passes in CI.

## Layout

```text
build.zig build.zig.zon .zigversion
src/
  root.zig      library entry (`@import("essential")`): re-exports modules and the `Error` set
  greeting.zig  todo.zig   feature modules, each with `test` blocks
  main.zig      CLI: parses args and prints; logic stays in the library
scripts/prepare.sh  docs/  examples/
```

## Conventions

- Allocators are passed in, never global. A function that allocates takes `allocator: std.mem.Allocator` first and documents who owns the result and frees it. Create arenas at the edge (in `main`) and pass them down.
- Pair every allocation with `defer`/`errdefer` on the next line. Tests use `std.testing.allocator`, which fails on leaks; keep it that way.
- Errors are error sets. The library exposes one `Error` set in `root.zig`; return specific errors, do not use `anyerror` in public signatures.
- Naming (std style): functions `camelCase`, types `PascalCase`, variables and fields `snake_case`, files `snake_case.zig`. Public items have `///` doc comments; files start with `//!`.
- No hidden global state. No `@panic` for recoverable failures.
- Tests sit beside the code in `test` blocks. Add new files to `root.zig` (re-export) so `refAllDecls` runs their tests.
- Pin the compiler: `.zigversion` and `minimum_zig_version` in `build.zig.zon` must match. The language still changes between minor versions, so upgrade deliberately.

## Rules (all Essential templates)

- **Git:** commits and pushes use the user's own git identity. Never set a Claude identity and never add `Co-Authored-By` or "Generated with" lines. Do not commit unless asked.
- Never read or print `.env` files or secrets. Every setting has an entry in `.env.example`.
- Conventional commits (`feat(scope): ...`). Feature branch, then pull request.
- Business numbers (limits, durations, thresholds) are configuration, never constants in code.
- If a rule is missing, stop and ask. Do not invent one.
- Run the gate before saying "done".

## Never

- Use a global allocator or `std.heap.page_allocator` in library code.
- Return `anyerror` from public functions.
- Change `.fingerprint` in `build.zig.zon` casually (it identifies the package).
- Disable leak checks or skip tests to make the gate pass.
- Commit `.zig-cache/` or `zig-out/`.

## Read next

- `docs/01-architecture.md`, `docs/02-naming-and-style.md`, `docs/03-errors-and-memory.md`, `docs/04-testing.md`, `docs/05-tooling.md`, `docs/06-release.md`
