//! The Essential library: a greeting and an in-memory todo list.
//!
//! Everything public is re-exported here; import it as `@import("essential")`.

pub const greeting = @import("greeting.zig");
pub const todo = @import("todo.zig");

/// Errors the library can return, as one set callers can switch on.
pub const Error = error{
    /// The caller supplied invalid input (for example an empty name).
    InvalidInput,
    /// A requested item does not exist.
    NotFound,
    OutOfMemory,
};

test {
    // Run the tests in the imported files too.
    @import("std").testing.refAllDecls(@This());
}
