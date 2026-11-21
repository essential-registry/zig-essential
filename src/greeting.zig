//! Greeting feature.

const std = @import("std");
const Error = @import("root.zig").Error;

/// Build a greeting for `name`, signed by `app_name`.
///
/// The caller owns the returned slice and frees it with `allocator`.
/// Returns `error.InvalidInput` when `name` is empty or only whitespace.
pub fn greet(allocator: std.mem.Allocator, name: []const u8, app_name: []const u8) Error![]u8 {
    const trimmed = std.mem.trim(u8, name, &std.ascii.whitespace);
    if (trimmed.len == 0) return error.InvalidInput;
    return std.fmt.allocPrint(allocator, "Hello, {s}! Welcome to {s}.", .{ trimmed, app_name });
}

test "greets by name" {
    const text = try greet(std.testing.allocator, "  Ada ", "Essential");
    defer std.testing.allocator.free(text);
    try std.testing.expectEqualStrings("Hello, Ada! Welcome to Essential.", text);
}

test "rejects blank names" {
    try std.testing.expectError(error.InvalidInput, greet(std.testing.allocator, "   ", "Essential"));
}
