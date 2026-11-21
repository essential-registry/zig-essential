# Zig Essential

A Zig starter with the essentials already set up: a library module, a thin CLI, tests that catch leaks, formatting, docs generation, cross-compile checks, CI and an agent guide.

## Layout

```text
src/root.zig       library entry (@import("essential")) and the shared Error set
src/greeting.zig   example feature
src/todo.zig       example feature (owns its memory)
src/main.zig       CLI, a thin layer over the library
build.zig          run, test, fmt, fmt-check, docs steps
.zigversion        pinned Zig version (also in build.zig.zon)
docs/              architecture, style, errors and memory, testing, tooling, release
scripts/prepare.sh the quality gate
```

## Run

```bash
zig build run -- greet Ada
zig build run -- todo
zig build test --summary all
```

## Quality gate

```bash
./scripts/prepare.sh            # fix: zig fmt, then every check
./scripts/prepare.sh --check    # what CI runs
```

The gate formats, lints (zlint when installed), tests, builds ReleaseSafe and cross-compiles for four targets.

## Zig version

Pinned to the version in `.zigversion` (currently 0.15.2). Zig is pre-1.0: upgrade deliberately.

## Working with AI agents

`AGENTS.md` is the guide agents follow (`CLAUDE.md` points to it). `.claude/` has permissions, a formatter hook, a reviewer agent and skills.

## License

MIT.
