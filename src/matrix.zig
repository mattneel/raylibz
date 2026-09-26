//! raylib's `Matrix`, mirrored, and raymath's `Matrix*` functions as methods.
//!
//! The mirror only: raymath's `Matrix*` methods land here in the raymath slice,
//! named without the type prefix (`MatrixRotateX(angle)` → `Matrix.rotateX(angle)`,
//! `MatrixIdentity()` → `Matrix.identity()`), each one calling the translated
//! raymath function through `cast.as`.

const c = @import("raylib");
const cast = @import("cast.zig");

/// Matrix, 4x4 components, column major, OpenGL style, right-handed
///
/// raylib.h's `Matrix`.
pub const Matrix = extern struct {
    /// Matrix first row (4 components)
    m0: f32,
    /// Matrix first row (4 components)
    m4: f32,
    /// Matrix first row (4 components)
    m8: f32,
    /// Matrix first row (4 components)
    m12: f32,
    /// Matrix second row (4 components)
    m1: f32,
    /// Matrix second row (4 components)
    m5: f32,
    /// Matrix second row (4 components)
    m9: f32,
    /// Matrix second row (4 components)
    m13: f32,
    /// Matrix third row (4 components)
    m2: f32,
    /// Matrix third row (4 components)
    m6: f32,
    /// Matrix third row (4 components)
    m10: f32,
    /// Matrix third row (4 components)
    m14: f32,
    /// Matrix fourth row (4 components)
    m3: f32,
    /// Matrix fourth row (4 components)
    m7: f32,
    /// Matrix fourth row (4 components)
    m11: f32,
    /// Matrix fourth row (4 components)
    m15: f32,

    comptime {
        cast.assertLayout(@This(), c.Matrix);
    }
};
