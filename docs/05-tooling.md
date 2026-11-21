# 5. Tooling

| Task | Command | Tool |
| --- | --- | --- |
| Build / run | `zig build`, `zig build run -- ...` | Zig build system (`build.zig`) |
| Test | `zig build test --summary all` | built in |
| Format | `zig fmt` (`zig build fmt`, `fmt-check`) | built in |
| Lint | `zlint` | [zlint](https://github.com/DonIsaac/zlint), optional |
| Docs | `zig build docs` | built in autodoc |
| Cross-compile | `zig build -Dtarget=aarch64-linux-gnu` | built in |

## Zig version

The version is pinned in `.zigversion` and `minimum_zig_version` in `build.zig.zon`; CI installs exactly `.zigversion`. Zig is pre-1.0 and changes between minor versions, so upgrade on purpose: change both files, fix the build, run the gate.

## The gate

`./scripts/prepare.sh` formats the sources, lints (when zlint is installed), runs the tests, builds ReleaseSafe and cross-compiles for Linux (x86_64, aarch64), Windows (x86_64) and macOS (aarch64). `--check` changes nothing and is what CI runs.

If `zig build` cannot run on your machine (for example a Zig release older than your macOS), the script falls back to `zig test` for the library and the CLI and says it skipped the rest.
