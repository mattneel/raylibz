//! raylib's models module: meshes, models, materials and shaders, animations and
//! the 3D collision stack (rays, bounding boxes), and the 3D drawing calls.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, a load that raylib pairs with an
//! `Is*Valid` check as `error{LoadFailed}!T`, and raylib's own one-line comment
//! copied above the wrapper. What is not wrapped is listed in `not_wrapped`.
//!
//! The wrappers are not written yet: this is one of the files the parallel
//! slices fill, and `zig build parity -Dmodule=models` lists exactly what that
//! slice must do. This file imports only names the root also publishes (`c`,
//! `cast`, `types`, the vector files and the type names they hold), because the
//! root's re-export test requires every top-level declaration here to exist in
//! `raylibz` too.

const c = @import("raylib");
const cast = @import("cast.zig");

/// The functions of raylib.h's `models` section that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};
