# Zig Essential

[![CI](https://github.com/essential-registry/zig-essential/actions/workflows/ci.yml/badge.svg)](https://github.com/essential-registry/zig-essential/actions/workflows/ci.yml) ![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)

A Zig starter: an importable library module, a thin CLI, tests that fail on memory leaks, formatting, docs generation, cross-compile checks, CI and an agent guide.

Part of [Essential](https://github.com/essential-registry): starter templates with the tooling, structure, docs and AI-agent guide already in place.

## What you get

- **Library module** (`@import("essential")`) with one shared `Error` set, and a **thin CLI** over it
- **Explicit allocators** everywhere; tests use `std.testing.allocator`, so a leak fails the test
- **`zig build` steps:** `run`, `test`, `fmt`, `fmt-check`, `docs`
- **Pinned toolchain:** `.zigversion` and `minimum_zig_version` in `build.zig.zon`
- **Quality gate** script: `zig fmt`, optional zlint, tests, ReleaseSafe build and cross-compiles (Linux x86_64 and aarch64, Windows x86_64, macOS aarch64)
- **GitHub Actions** on Linux and macOS, installing exactly the pinned Zig
- **Docs and AGENTS.md** for people and coding agents

## Requirements

- [Zig](https://ziglang.org/download/) 0.15.2 (the version in `.zigversion`)
- Optional: [zlint](https://github.com/DonIsaac/zlint)

## Quick start

Click **Use this template** on GitHub (or run `gh repo create my-project --template essential-registry/zig-essential`), then:

```bash
zig build run -- greet Ada
zig build run -- todo
zig build test --summary all
```

Zig is pre-1.0 and changes between minor versions, so the compiler version is pinned. If `zig build` cannot run on your machine (for example a Zig release older than your macOS), `./scripts/prepare.sh` falls back to `zig test` and says what it skipped.

## Commands

| Command | What it does |
| --- | --- |
| `zig build run -- <command>` | Run the CLI (`greet <name>`, `todo`) |
| `zig build test --summary all` | Run all tests |
| `zig build fmt` / `zig build fmt-check` | Format / check formatting |
| `zig build docs` | Generate API docs into `zig-out/docs` |
| `zig build -Doptimize=ReleaseSafe -Dtarget=<triple>` | Release or cross-compile |
| `./scripts/prepare.sh` | Fix mode: `zig fmt`, then every check |
| `./scripts/prepare.sh --check` | The non-mutating gate CI runs |

## Project structure

```text
src/
  root.zig       library entry and the shared Error set
  greeting.zig   example feature
  todo.zig       example feature (owns its memory)
  main.zig       CLI: parses arguments and prints
build.zig  build.zig.zon  .zigversion
docs/            architecture, style, errors and memory, testing, tooling, release
examples/        small programs using the library
scripts/prepare.sh   the quality gate
```

## Architecture

The CLI calls the library and holds no logic; the library re-exports one module per feature and defines a single error set. Allocators are passed in by the caller and ownership of returned memory is documented on every function.

Full details: [`docs/01-architecture.md`](docs/01-architecture.md).

## Documentation

- [`docs/01-architecture.md`](docs/01-architecture.md): layers, folders and how the pieces fit
- [`docs/02-naming-and-style.md`](docs/02-naming-and-style.md): naming and code style
- [`docs/03-errors-and-memory.md`](docs/03-errors-and-memory.md): error sets and memory management
- [`docs/04-testing.md`](docs/04-testing.md): how to test and what the gate checks
- [`docs/05-tooling.md`](docs/05-tooling.md): tools, presets and the quality gate
- [`docs/06-release.md`](docs/06-release.md): versioning and releasing

## Quality gate and CI

`./scripts/prepare.sh --check` checks formatting, lints with zlint when installed, runs the tests, builds ReleaseSafe and cross-compiles for four targets. GitHub Actions runs it on Ubuntu and macOS for every push and pull request.

## Working with AI agents

[`AGENTS.md`](AGENTS.md) is the guide coding agents follow: commands, layout, conventions and a "never" list (`CLAUDE.md` points to it). `.claude/` adds safe permissions, a formatter hook, a read-only reviewer agent and task skills. Commits always use your own git identity; the guide tells agents not to add attribution lines and not to commit unless asked.

## Make it yours

1. Generate a new package fingerprint: delete `.fingerprint` in `build.zig.zon` and run `zig build`, which prints a fresh value.
2. Rename the package, the module and the executable.
3. Replace the example modules and re-export new ones from `src/root.zig`.
4. Upgrade the pinned Zig version deliberately (`.zigversion` and `build.zig.zon`).

## License

MIT. See [LICENSE](LICENSE).
