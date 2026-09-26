//! raymath's free functions: the scalar helpers (`clamp`, `lerp`, `normalize`,
//! `remap`, `wrap`, `floatEquals`) and the whole `Quaternion*` family.
//!
//! The `Vector2*`, `Vector3*`, `Vector4*` and `Matrix*` families are methods on
//! those types, not free functions, because raymath's own names read that way
//! (`Vector2Add(a, b)` → `a.add(b)`). `Quaternion` is raylib's `typedef Vector4
//! Quaternion`, so the `Quaternion*` family cannot be a method without being
//! ambiguous with `Vector4`'s own; it stays here, with raylib's names
//! lowercased (`quaternionAdd`, `quaternionSlerp`).
//!
//! Every function here calls the translated raymath function through `cast.as`
//! conversions, so the result is raymath's own, bit for bit.
//!
//! The wrappers are not written yet: this is the file the raymath slice fills,
//! and `zig build parity -Dmodule=raymath` lists exactly what it must do. This
//! file imports only names the root also publishes (`raymath`, `cast`, the
//! vector files), because the root's re-export test requires every top-level
//! declaration here to exist in `raylibz` too.

const raymath = @import("raymath");
const cast = @import("cast.zig");

/// The functions of raymath.h that raylibz does not wrap, and why. One line
/// each.
pub const not_wrapped = [_]cast.NotWrapped{};
