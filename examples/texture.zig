// /*******************************************************************************************
// *
// *   raylib [textures] example - logo raylib
// *
// *   Example complexity rating: [★☆☆☆] 1/4
// *
// *   Example originally created with raylib 1.0, last time updated with raylib 1.0
// *
// *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
// *   BSD-like license that allows static linking with closed source software
// *
// *   Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
// *
// ********************************************************************************************/

//! raylibz's port of raylib's `examples/textures/textures_logo_raylib.c`, in the
//! raylibz spelling of the same calls, with raylib's own notice above kept as it
//! is. One thing differs: raylib's example loads `resources/raylib_logo.png`,
//! raylibz loads the equally CC0 `resources/raybunny.png` from raylib's texture
//! examples (see `resources/LICENSE.md`), so the window title and the notice
//! name the example this is a port of rather than the picture it shows.
//!
//! `loadTexture` is the error union raylibz gives a load that raylib pairs with
//! `IsTextureValid`, so a missing or unreadable file is a Zig error rather than
//! a texture raylib draws nothing with.
//!
//! Like `basic_window`, the example takes an optional `--frames N` argument
//! that closes the window after N frames, so that a machine can run a real
//! window for a fixed number of frames and check that it exited cleanly.
//!
//!     zig build run-texture                run until the window closes
//!     zig build run-texture -- --frames 60 draw 60 frames and exit

const std = @import("std");
const raylibz = @import("raylibz");

pub fn main(init: std.process.Init) !void {
    const frames_to_draw = try framesArgument(init);

    // Initialization
    const screenWidth = 800;
    const screenHeight = 450;

    raylibz.initWindow(screenWidth, screenHeight, "raylib [textures] example - logo raylib");

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    const texture = try raylibz.loadTexture("resources/raybunny.png"); // Texture loading

    raylibz.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    // Main game loop
    var frames: u64 = 0;
    while (!raylibz.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        // TODO: Update your variables here

        // Draw
        raylibz.beginDrawing();

        raylibz.clearBackground(raylibz.Color.raywhite);

        raylibz.drawTexture(
            texture,
            screenWidth / 2 - @divTrunc(texture.width, 2),
            screenHeight / 2 - @divTrunc(texture.height, 2),
            raylibz.Color.white,
        );

        raylibz.drawText("this IS a texture!", 360, 370, 10, raylibz.Color.gray);

        raylibz.endDrawing();

        frames += 1;
        if (frames_to_draw) |limit| {
            if (frames >= limit) break;
        }
    }

    // De-Initialization
    raylibz.unloadTexture(texture); // Texture unloading
    raylibz.closeWindow(); // Close window and OpenGL context

    // CI reads this line: it is the only thing a headless run can be asked for.
    if (frames_to_draw != null) std.debug.print("texture: drew {d} frame(s) of a {d}x{d} texture\n", .{
        frames,
        texture.width,
        texture.height,
    });
}

/// `--frames N`, or `null` when the argument is absent: the number of frames to
/// draw before closing the window, for a machine that cannot close a window.
fn framesArgument(init: std.process.Init) !?u64 {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    var index: usize = 1;
    while (index < args.len) : (index += 1) {
        if (!std.mem.eql(u8, args[index], "--frames")) continue;
        if (index + 1 >= args.len) return error.MissingFrameCount;
        return std.fmt.parseInt(u64, args[index + 1], 10) catch error.BadFrameCount;
    }
    return null;
}
