# 6. Release

- Bump `.version` in `build.zig.zon` and add a `CHANGELOG.md` entry.
- Run `./scripts/prepare.sh --check`.
- Tag `vX.Y.Z`. Consumers depend on the tag: `zig fetch --save https://github.com/<you>/<repo>/archive/refs/tags/vX.Y.Z.tar.gz`.
- Build release binaries per target: `zig build -Doptimize=ReleaseSafe -Dtarget=<triple> --prefix dist/<triple>`.
