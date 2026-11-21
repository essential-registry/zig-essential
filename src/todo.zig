//! Todo feature: an in-memory list that owns its strings.

const std = @import("std");
const Error = @import("root.zig").Error;

/// One todo entry.
pub const Todo = struct {
    id: u32,
    /// Owned by the list; valid until the todo is removed or the list is deinitialised.
    title: []u8,
    done: bool = false,
};

/// An in-memory todo list. Create with `init`, release with `deinit`.
pub const TodoList = struct {
    allocator: std.mem.Allocator,
    items: std.ArrayList(Todo) = .empty,
    next_id: u32 = 1,

    pub fn init(allocator: std.mem.Allocator) TodoList {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *TodoList) void {
        for (self.items.items) |todo| self.allocator.free(todo.title);
        self.items.deinit(self.allocator);
    }

    /// Add a todo (the title is copied) and return its id. Ids start at 1.
    pub fn add(self: *TodoList, title: []const u8) Error!u32 {
        const trimmed = std.mem.trim(u8, title, &std.ascii.whitespace);
        if (trimmed.len == 0) return error.InvalidInput;

        const owned = try self.allocator.dupe(u8, trimmed);
        errdefer self.allocator.free(owned);

        const id = self.next_id;
        try self.items.append(self.allocator, .{ .id = id, .title = owned });
        self.next_id += 1;
        return id;
    }

    /// Mark a todo as done. Returns `error.NotFound` for an unknown id.
    pub fn complete(self: *TodoList, id: u32) Error!void {
        for (self.items.items) |*todo| {
            if (todo.id == id) {
                todo.done = true;
                return;
            }
        }
        return error.NotFound;
    }
};

test "adds and completes" {
    var list = TodoList.init(std.testing.allocator);
    defer list.deinit();
    const id = try list.add("write docs");
    try list.complete(id);
    try std.testing.expect(list.items.items[0].done);
}

test "ids increase" {
    var list = TodoList.init(std.testing.allocator);
    defer list.deinit();
    try std.testing.expectEqual(@as(u32, 1), try list.add("a"));
    try std.testing.expectEqual(@as(u32, 2), try list.add("b"));
}

test "rejects empty titles" {
    var list = TodoList.init(std.testing.allocator);
    defer list.deinit();
    try std.testing.expectError(error.InvalidInput, list.add("  "));
}

test "completing an unknown id fails" {
    var list = TodoList.init(std.testing.allocator);
    defer list.deinit();
    try std.testing.expectError(error.NotFound, list.complete(9));
}

test "no leaks when add fails part-way" {
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    var list = TodoList.init(failing.allocator());
    defer list.deinit();
    try std.testing.expectError(error.OutOfMemory, list.add("x"));
}
