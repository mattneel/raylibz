//! raylib's text module: font loading, glyphs, codepoints, drawing text, and
//! the text file and string helpers (including the ones whose memory the caller
//! must release).
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text in as `[:0]const u8`, text out as `[:0]const u8` (or `?[:0]u8` where
//! the caller must release it), buffers as slices, a load that raylib pairs with
//! an `Is*Valid` check as `error{LoadFailed}!T`, and raylib's own one-line
//! comment copied above the wrapper. What is not wrapped is listed in
//! `not_wrapped`.
//!
//! This file imports only names the root also publishes (`c`, `cast`, `types`,
//! the vector files and the type names they hold), because the root's re-export
//! test requires every top-level declaration here to exist in `raylibz` too.

const c = @import("raylib");
const cast = @import("cast.zig");
const types = @import("types.zig");

const Color = types.Color;

/// The functions of raylib.h's `text` section that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

/// Draw text (using default font)
///
/// raylib takes `const char *text` and a `Color`; both cross as written.
pub fn drawText(text: [:0]const u8, posX: i32, posY: i32, fontSize: i32, color: Color) void {
    c.DrawText(cast.cstr(text), posX, posY, fontSize, cast.as(c.Color, color));
}
