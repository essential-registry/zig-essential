//! Command line front end. Logic lives in the library; this file only parses arguments and prints.

const std = @import("std");
const essential = @import("essential");

const usage = "usage: essential greet <name> | essential todo\n";

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit(); // reports leaks in debug builds
    const allocator = gpa.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const code = try run(allocator, args[1..], stdout);
    try stdout.flush();
    if (code != 0) std.process.exit(code);
}

/// Run a command and return the process exit code.
fn run(allocator: std.mem.Allocator, args: []const []const u8, out: *std.Io.Writer) !u8 {
    if (args.len == 2 and std.mem.eql(u8, args[0], "greet")) {
        const text = essential.greeting.greet(allocator, args[1], "Zig Essential") catch |err| switch (err) {
            error.InvalidInput => {
                try out.writeAll("error: name must not be empty\n");
                return 1;
            },
            else => return err,
        };
        defer allocator.free(text);
        try out.print("{s}\n", .{text});
        return 0;
    }
    if (args.len == 1 and std.mem.eql(u8, args[0], "todo")) {
        var list = essential.todo.TodoList.init(allocator);
        defer list.deinit();
        const id = try list.add("ship the template");
        try list.complete(id);
        for (list.items.items) |todo| {
            try out.print("[{c}] {d} {s}\n", .{ @as(u8, if (todo.done) 'x' else ' '), todo.id, todo.title });
        }
        return 0;
    }
    try out.writeAll(usage);
    return 2;
}

test "greet prints a greeting" {
    var buffer: [128]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buffer);
    const code = try run(std.testing.allocator, &.{ "greet", "Ada" }, &writer);
    try std.testing.expectEqual(@as(u8, 0), code);
    try std.testing.expectEqualStrings("Hello, Ada! Welcome to Zig Essential.\n", writer.buffered());
}

test "unknown command prints usage" {
    var buffer: [128]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buffer);
    const code = try run(std.testing.allocator, &.{"nope"}, &writer);
    try std.testing.expectEqual(@as(u8, 2), code);
    try std.testing.expectEqualStrings(usage, writer.buffered());
}

test "blank name is an error" {
    var buffer: [128]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buffer);
    const code = try run(std.testing.allocator, &.{ "greet", " " }, &writer);
    try std.testing.expectEqual(@as(u8, 1), code);
}
