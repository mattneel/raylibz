// /*******************************************************************************************
// *
// *   raylib [core] example - basic window
// *
// *   Example complexity rating: [★☆☆☆] 1/4
// *
// *   Welcome to raylib!
// *
// *   To test examples, just press F6 and execute 'raylib_compile_execute' script
// *   Note that compiled executable is placed in the same folder as .c file
// *
// *   To test the examples on Web, press F6 and execute 'raylib_compile_execute_web' script
// *   Web version of the program is generated in the same folder as .c file
// *
// *   You can find all basic examples on C:\raylib\raylib\examples folder or
// *   raylib official webpage: www.raylib.com
// *
// *   Enjoy using raylib. :)
// *
// *   Example originally created with raylib 1.0, last time updated with raylib 1.0
// *
// *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
// *   BSD-like license that allows static linking with closed source software
// *
// *   Copyright (c) 2013-2026 Ramon Santamaria (@raysan5)
// *
// ********************************************************************************************/

//! raylibz's port of raylib's `examples/core/core_basic_window.c`, in the
//! raylibz spelling of the same calls, plus one addition: an optional
//! `--frames N` argument that closes the window after N frames, so that a
//! machine can run a real window for a fixed number of frames and check that
//! it exited cleanly.
//!
//!     zig build run-basic_window                run until the window closes
//!     zig build run-basic_window -- --frames 60 draw 60 frames and exit

const std = @import("std");
const raylibz = @import("raylibz");

pub fn main(init: std.process.Init) !void {
    const frames_to_draw = try framesArgument(init);

    // Initialization
    const screenWidth = 800;
    const screenHeight = 450;

    raylibz.initWindow(screenWidth, screenHeight, "raylibz [core] example - basic window");

    raylibz.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    // Main game loop
    var frames: u64 = 0;
    while (!raylibz.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        // TODO: Update your variables here

        // Draw
        raylibz.beginDrawing();

        raylibz.clearBackground(raylibz.Color.raywhite);

        raylibz.drawText("Congrats! You created your first window!", 190, 200, 20, raylibz.Color.lightgray);

        raylibz.endDrawing();

        frames += 1;
        if (frames_to_draw) |limit| {
            if (frames >= limit) break;
        }
    }

    // De-Initialization
    raylibz.closeWindow(); // Close window and OpenGL context

    // CI reads this line: it is the only thing a headless run can be asked for.
    if (frames_to_draw != null) std.debug.print("basic_window: drew {d} frame(s)\n", .{frames});
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
