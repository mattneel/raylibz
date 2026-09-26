//! raylib's `Vector2`, mirrored, and the `Vector2*` family of raymath methods.
//!
//! The mirror only: raymath's methods for this type land here in the raymath
//! slice, named without the type prefix (`Vector2Add(a, b)` → `a.add(b)`), each
//! one calling the translated raymath function through `cast.as`.

const c = @import("raylib");
const cast = @import("cast.zig");

/// Vector2, 2 components
///
/// raylib.h's `Vector2`.
pub const Vector2 = extern struct {
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,

    comptime {
        cast.assertLayout(@This(), c.Vector2);
    }
};
