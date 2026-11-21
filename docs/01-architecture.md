# 1. Architecture

```text
src/main.zig (CLI)  ->  src/root.zig (library)  ->  greeting.zig, todo.zig
```

- **Library** (`src/root.zig`): the importable module `essential`. It re-exports feature modules and defines the shared `Error` set. Other projects depend on it through `build.zig.zon`.
- **Features**: one file per topic (`greeting.zig`, `todo.zig`), each with its own `test` blocks.
- **CLI** (`src/main.zig`): parses arguments, creates the allocator, prints. It calls the library and holds no logic of its own, so it is easy to test and replace.

Add a module: create the file, re-export it from `root.zig`, write tests in it.

`build.zig` defines: `run`, `test`, `fmt`, `fmt-check`, `docs`, and the install step for the `essential` executable.
