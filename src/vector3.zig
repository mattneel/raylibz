//! raylib's `Vector3`, mirrored, and the `Vector3*` family of raymath methods.
//!
//! The mirror only: raymath's methods for this type land here in the raymath
//! slice, named without the type prefix (`Vector3CrossProduct(a, b)` →
//! `a.crossProduct(b)`), each one calling the translated raymath function
//! through `cast.as`.

const c = @import("raylib");
const cast = @import("cast.zig");

/// Vector3, 3 components
///
/// raylib.h's `Vector3`.
pub const Vector3 = extern struct {
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,
    /// Vector z component
    z: f32,

    comptime {
        cast.assertLayout(@This(), c.Vector3);
    }
};
