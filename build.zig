const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // The library other projects import: `@import("essential")`.
    const lib_mod = b.addModule("essential", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // The command line app, a thin layer over the library.
    const exe = b.addExecutable(.{
        .name = "essential",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "essential", .module = lib_mod }},
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    b.step("run", "Run the app: zig build run -- greet Ada").dependOn(&run_cmd.step);

    // Tests: library and executable. std.testing.allocator fails a test that leaks.
    const test_step = b.step("test", "Run all tests");
    for ([_]*std.Build.Module{ lib_mod, exe.root_module }) |module| {
        const tests = b.addTest(.{ .root_module = module });
        test_step.dependOn(&b.addRunArtifact(tests).step);
    }

    // Formatting: `zig build fmt` rewrites, `zig build fmt-check` only checks.
    const fmt_paths: []const []const u8 = &.{ "src", "build.zig", "build.zig.zon" };
    b.step("fmt", "Format the sources").dependOn(&b.addFmt(.{ .paths = fmt_paths }).step);
    b.step("fmt-check", "Check formatting").dependOn(&b.addFmt(.{ .paths = fmt_paths, .check = true }).step);

    // API documentation for the library.
    const docs = b.addObject(.{ .name = "essential", .root_module = lib_mod });
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    b.step("docs", "Generate API docs into zig-out/docs").dependOn(&install_docs.step);
}
