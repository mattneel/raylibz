//! raylib's `Vector4` (and therefore `Quaternion`), mirrored, and the `Vector4*`
//! family of raymath methods.
//!
//! `Quaternion` is raylib's `typedef Vector4 Quaternion`, so it is an alias for
//! this type and the `Quaternion*` family of raymath functions stays free
//! functions in `math.zig`, not methods here.
//!
//! The mirror only: raymath's `Vector4*` methods land here in the raymath slice,
//! named without the type prefix (`Vector4Add(a, b)` → `a.add(b)`), each one
//! calling the translated raymath function through `cast.as`.

const c = @import("raylib");
const cast = @import("cast.zig");

pub const Quaternion = Vector4;

/// Vector4, 4 components
///
/// raylib.h's `Vector4`.
pub const Vector4 = extern struct {
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,
    /// Vector z component
    z: f32,
    /// Vector w component
    w: f32,

    comptime {
        cast.assertLayout(@This(), c.Vector4);
    }
};
