//! raylib's input handling (keyboard, gamepads, mouse, touch), from raylib.h's
//! core module, with its rgestures and rcamera sections.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, and raylib's own one-line comment
//! copied above the wrapper. What is not wrapped is listed in `not_wrapped`.
//!
//! The wrappers are not written yet: this is one of the files the parallel
//! slices fill, and `zig build parity -Dmodule=input` lists exactly what that
//! slice must do. This file imports only names the root also publishes (`c`,
//! `cast`, `types`, the vector files and the type names they hold), because the
//! root's re-export test requires every top-level declaration here to exist in
//! `raylibz` too.
//! Private helpers go in a `const internal = struct { ... };`, which that test
//! skips.

const c = @import("raylib");
const cast = @import("cast.zig");

/// The functions of raylib.h's input handling, rgestures and rcamera sections that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};
