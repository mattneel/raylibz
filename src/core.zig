//! raylib's core module up to its file system functions: window and graphics
//! device, cursor, drawing modes, VR, shaders, screen space, timing, frame
//! control, random values, and the misc, logging and memory functions. The rest
//! of core is in files.zig and input.zig.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, a load that raylib pairs with an
//! `Is*Valid` check as `error{LoadFailed}!T`, and raylib's own one-line comment
//! copied above the wrapper. What is not wrapped is listed in `not_wrapped`.
//!
//! This file imports only names the root also publishes (`c`, `cast`, `types`,
//! the vector files and the type names they hold), because the root's re-export
//! test requires every top-level declaration here to exist in `raylibz` too.
//! Private helpers go in a `const internal = struct { ... };`, which that test
//! skips.

const c = @import("raylib");
const cast = @import("cast.zig");
const types = @import("types.zig");

const Color = types.Color;

/// The functions of raylib.h's core module, up to its file system functions,
/// that raylibz does not wrap, and why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

/// Initialize window and OpenGL context
///
/// raylib takes `const char *title`; a Zig string literal passes as is.
pub fn initWindow(width: i32, height: i32, title: [:0]const u8) void {
    c.InitWindow(width, height, cast.cstr(title));
}

/// Close window and unload OpenGL context
///
/// There is no argument to take ownership of, so raylibz keeps raylib's
/// signature as it is.
pub const closeWindow = c.CloseWindow;

/// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
pub const windowShouldClose = c.WindowShouldClose;

/// Set target FPS (maximum)
pub const setTargetFPS = c.SetTargetFPS;

/// Setup drawing canvas to start drawing
pub const beginDrawing = c.BeginDrawing;

/// End canvas drawing and swap buffers (double buffering)
pub const endDrawing = c.EndDrawing;

/// Set background color (framebuffer clear color)
pub fn clearBackground(color: Color) void {
    c.ClearBackground(cast.as(c.Color, color));
}
