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
const enums = @import("enums.zig");
const vector2 = @import("vector2.zig");
const vector3 = @import("vector3.zig");
const matrix = @import("matrix.zig");

const BlendMode = enums.BlendMode;
const Camera2D = types.Camera2D;
const Camera3D = types.Camera3D;
const Color = types.Color;
const ConfigFlags = enums.ConfigFlags;
const Image = types.Image;
const Matrix = matrix.Matrix;
const Ray = types.Ray;
const RenderTexture2D = types.RenderTexture2D;
const Shader = types.Shader;
const ShaderUniformDataType = enums.ShaderUniformDataType;
const Texture2D = types.Texture2D;
const TraceLogLevel = enums.TraceLogLevel;
const Vector2 = vector2.Vector2;
const Vector3 = vector3.Vector3;
const VrDeviceInfo = types.VrDeviceInfo;
const VrStereoConfig = types.VrStereoConfig;

/// The functions of raylib.h's core module, up to its file system functions,
/// that raylibz does not wrap, and why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

// Window-related functions

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

/// Check if window has been initialized successfully
pub const isWindowReady = c.IsWindowReady;

/// Check if window is currently fullscreen
pub const isWindowFullscreen = c.IsWindowFullscreen;

/// Check if window is currently hidden
pub const isWindowHidden = c.IsWindowHidden;

/// Check if window is currently minimized
pub const isWindowMinimized = c.IsWindowMinimized;

/// Check if window is currently maximized
pub const isWindowMaximized = c.IsWindowMaximized;

/// Check if window is currently focused
pub const isWindowFocused = c.IsWindowFocused;

/// Check if window has been resized last frame
pub const isWindowResized = c.IsWindowResized;

/// Check if one specific window flag is enabled
///
/// raylib takes an `unsigned int`; raylibz takes the flag set. raylib's own
/// check is `(flags & flag) == flag`, so a value with several flags set asks
/// for all of them: pass one flag for one flag's answer.
pub fn isWindowState(flag: ConfigFlags) bool {
    return c.IsWindowState(@bitCast(flag));
}

/// Set window configuration state using flags
///
/// raylib takes an `unsigned int`; raylibz takes the flag set.
pub fn setWindowState(flags: ConfigFlags) void {
    c.SetWindowState(@bitCast(flags));
}

/// Clear window configuration state flags
///
/// raylib takes an `unsigned int`; raylibz takes the flag set.
pub fn clearWindowState(flags: ConfigFlags) void {
    c.ClearWindowState(@bitCast(flags));
}

/// Toggle window state: fullscreen/windowed, resizes monitor to match window resolution
pub const toggleFullscreen = c.ToggleFullscreen;

/// Toggle window state: borderless windowed, resizes window to match monitor resolution
pub const toggleBorderlessWindowed = c.ToggleBorderlessWindowed;

/// Set window state: maximized, if resizable
pub const maximizeWindow = c.MaximizeWindow;

/// Set window state: minimized, if resizable
pub const minimizeWindow = c.MinimizeWindow;

/// Restore window from being minimized/maximized
pub const restoreWindow = c.RestoreWindow;

/// Set icon for window (single image, RGBA 32bit)
///
/// The image is raylib's `Image`, and raylib copies its pixels before it
/// returns; the image stays the caller's.
pub fn setWindowIcon(image: Image) void {
    c.SetWindowIcon(cast.as(c.Image, image));
}

/// Set icon for window (multiple images, RGBA 32bit)
///
/// raylib takes `Image *images, int count`; raylibz takes the slice. raylib only
/// reads the images, and an empty slice reverts to the default window icon.
pub fn setWindowIcons(images: []const Image) void {
    // raylib spells the parameter `Image *`, but only reads it, so the slice
    // stands as `[]const Image` and crosses with a const cast.
    c.SetWindowIcons(@constCast(cast.asArrayPtr(c.Image, images)), cast.asLen(images));
}

/// Set title for window
pub fn setWindowTitle(title: [:0]const u8) void {
    c.SetWindowTitle(cast.cstr(title));
}

/// Set window position on screen
pub const setWindowPosition = c.SetWindowPosition;

/// Set monitor for the current window
pub const setWindowMonitor = c.SetWindowMonitor;

/// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
pub const setWindowMinSize = c.SetWindowMinSize;

/// Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
pub const setWindowMaxSize = c.SetWindowMaxSize;

/// Set window dimensions
pub const setWindowSize = c.SetWindowSize;

/// Set window opacity [0.0f..1.0f]
pub const setWindowOpacity = c.SetWindowOpacity;

/// Set window focused
pub const setWindowFocused = c.SetWindowFocused;

/// Get native window handle
///
/// An untyped handle: a `HWND` on Windows, a `struct wl_surface *` or a
/// pointer to the `Window` id on Linux, an `NSWindow *` on macOS. Null where
/// raylib's platform layer does not have one.
pub const getWindowHandle = c.GetWindowHandle;

/// Get current screen width
pub const getScreenWidth = c.GetScreenWidth;

/// Get current screen height
pub const getScreenHeight = c.GetScreenHeight;

/// Get current render width (it considers HiDPI)
pub const getRenderWidth = c.GetRenderWidth;

/// Get current render height (it considers HiDPI)
pub const getRenderHeight = c.GetRenderHeight;

/// Get number of connected monitors
pub const getMonitorCount = c.GetMonitorCount;

/// Get current monitor where window is placed
pub const getCurrentMonitor = c.GetCurrentMonitor;

/// Get specified monitor position
pub fn getMonitorPosition(monitor: i32) Vector2 {
    return cast.as(Vector2, c.GetMonitorPosition(monitor));
}

/// Get specified monitor width (current video mode used by monitor)
pub const getMonitorWidth = c.GetMonitorWidth;

/// Get specified monitor height (current video mode used by monitor)
pub const getMonitorHeight = c.GetMonitorHeight;

/// Get specified monitor physical width in millimetres
pub const getMonitorPhysicalWidth = c.GetMonitorPhysicalWidth;

/// Get specified monitor physical height in millimetres
pub const getMonitorPhysicalHeight = c.GetMonitorPhysicalHeight;

/// Get specified monitor refresh rate
pub const getMonitorRefreshRate = c.GetMonitorRefreshRate;

/// Get window position XY on monitor
pub fn getWindowPosition() Vector2 {
    return cast.as(Vector2, c.GetWindowPosition());
}

/// Get window scale DPI factor
pub fn getWindowScaleDPI() Vector2 {
    return cast.as(Vector2, c.GetWindowScaleDPI());
}

/// Get the human-readable, UTF-8 encoded name of the specified monitor
///
/// The slice points into the platform's own string (GLFW's monitor name), so it
/// is valid until that monitor is gone or raylib is closed; raylibz does not
/// copy it. Null where the platform backend does not implement the call, which
/// the Win32 backend does not; the GLFW backend answers with an empty string
/// for a monitor that does not exist.
pub fn getMonitorName(monitor: i32) ?[:0]const u8 {
    return cast.optSpan(c.GetMonitorName(monitor));
}

/// Set clipboard text content
pub fn setClipboardText(text: [:0]const u8) void {
    c.SetClipboardText(cast.cstr(text));
}

/// Get clipboard text content
///
/// The slice points into the platform's clipboard string, which the backend
/// keeps and replaces (GLFW keeps one buffer): it is valid until the next call,
/// and raylibz does not copy it. Null when the clipboard holds no text or the
/// platform backend does not implement the call.
pub fn getClipboardText() ?[:0]const u8 {
    return cast.optSpan(c.GetClipboardText());
}

/// Get clipboard image content
///
/// Needs an initialized window: raylib's desktop backend asks the platform's
/// display, and the GLFW/X11 backend segfaults without one. It also needs a
/// clipboard owner: on X11 raylib waits for the selection's owner to answer, so
/// a headless X server with nothing owning the clipboard leaves raylib waiting.
/// The image is raylib's own load, so the caller owns it and must release it
/// with `unloadImage`. It is zeroed where the clipboard holds no image or the
/// platform backend does not implement the call; raylib's own example checks it
/// with `isImageValid`.
pub fn getClipboardImage() Image {
    return cast.as(Image, c.GetClipboardImage());
}

/// Enable waiting for events on EndDrawing(), no automatic event polling
pub const enableEventWaiting = c.EnableEventWaiting;

/// Disable waiting for events on EndDrawing(), automatic events polling
pub const disableEventWaiting = c.DisableEventWaiting;

// Cursor-related functions

/// Show cursor
pub const showCursor = c.ShowCursor;

/// Hide cursor
pub const hideCursor = c.HideCursor;

/// Check if cursor is not visible
pub const isCursorHidden = c.IsCursorHidden;

/// Enable cursor (unlock cursor)
pub const enableCursor = c.EnableCursor;

/// Disable cursor (lock cursor)
pub const disableCursor = c.DisableCursor;

/// Check if cursor is on the screen
pub const isCursorOnScreen = c.IsCursorOnScreen;

// Drawing-related functions

/// Clear background (framebuffer) to color
pub fn clearBackground(color: Color) void {
    c.ClearBackground(cast.as(c.Color, color));
}

/// Begin canvas (framebuffer) drawing
pub const beginDrawing = c.BeginDrawing;

/// End canvas (framebuffer) drawing and swap buffers (double buffering)
pub const endDrawing = c.EndDrawing;

/// Begin 2D mode with custom camera (2D)
pub fn beginMode2D(camera: Camera2D) void {
    c.BeginMode2D(cast.as(c.Camera2D, camera));
}

/// End 2D mode with custom camera
pub const endMode2D = c.EndMode2D;

/// Begin 3D mode with custom camera (3D)
pub fn beginMode3D(camera: Camera3D) void {
    c.BeginMode3D(cast.as(c.Camera3D, camera));
}

/// End 3D mode and returns to default 2D orthographic mode
pub const endMode3D = c.EndMode3D;

/// Begin drawing to render texture
pub fn beginTextureMode(target: RenderTexture2D) void {
    c.BeginTextureMode(cast.as(c.RenderTexture2D, target));
}

/// End drawing to render texture
pub const endTextureMode = c.EndTextureMode;

/// Begin custom shader drawing
pub fn beginShaderMode(shader: Shader) void {
    c.BeginShaderMode(cast.as(c.Shader, shader));
}

/// End custom shader drawing (use default shader)
pub const endShaderMode = c.EndShaderMode;

/// Begin blending mode (alpha, additive, multiplied, subtract, custom)
///
/// raylib takes an `int`; raylibz takes the `BlendMode` enum.
pub fn beginBlendMode(mode: BlendMode) void {
    c.BeginBlendMode(@backingInt(mode));
}

/// End blending mode (reset to default: alpha blending)
pub const endBlendMode = c.EndBlendMode;

/// Begin scissor mode (define screen area for following drawing)
pub const beginScissorMode = c.BeginScissorMode;

/// End scissor mode
pub const endScissorMode = c.EndScissorMode;

/// Begin stereo rendering (requires VR simulator)
pub fn beginVrStereoMode(config: VrStereoConfig) void {
    c.BeginVrStereoMode(cast.as(c.VrStereoConfig, config));
}

/// End stereo rendering (requires VR simulator)
pub const endVrStereoMode = c.EndVrStereoMode;

// VR stereo config functions for VR simulator

/// Load VR stereo config for VR simulator device parameters
///
/// raylib computes the config from the device's numbers with raymath and its
/// own backend's version, so it needs no OpenGL context. Where the backend is
/// OpenGL 1.1 it returns a zeroed config with a warning.
pub fn loadVrStereoConfig(device: VrDeviceInfo) VrStereoConfig {
    return cast.as(VrStereoConfig, c.LoadVrStereoConfig(cast.as(c.VrDeviceInfo, device)));
}

/// Unload VR stereo config
///
/// raylib's own implementation only logs: the config holds no allocation raylib
/// releases, so nothing dies at this call.
pub fn unloadVrStereoConfig(config: VrStereoConfig) void {
    c.UnloadVrStereoConfig(cast.as(c.VrStereoConfig, config));
}

// Shader management functions

/// Load shader from files and bind default locations
///
/// `null` for a file name means raylib's default shader for that stage. Returns
/// `error.LoadFailed` where raylib's `isShaderValid` says the shader did not
/// load. The caller owns the shader and must release it with `unloadShader`.
pub fn loadShader(vsFileName: ?[:0]const u8, fsFileName: ?[:0]const u8) error{LoadFailed}!Shader {
    const shader = cast.as(Shader, c.LoadShader(cast.optCstr(vsFileName), cast.optCstr(fsFileName)));
    if (!isShaderValid(shader)) return error.LoadFailed;
    return shader;
}

/// Load shader from code strings and bind default locations
///
/// `null` for a code string means raylib's default shader for that stage.
/// Returns `error.LoadFailed` where raylib's `isShaderValid` says the shader did
/// not load. The caller owns the shader and must release it with `unloadShader`.
pub fn loadShaderFromMemory(vsCode: ?[:0]const u8, fsCode: ?[:0]const u8) error{LoadFailed}!Shader {
    const shader = cast.as(Shader, c.LoadShaderFromMemory(cast.optCstr(vsCode), cast.optCstr(fsCode)));
    if (!isShaderValid(shader)) return error.LoadFailed;
    return shader;
}

/// Check if shader is valid (loaded on GPU)
pub fn isShaderValid(shader: Shader) bool {
    return c.IsShaderValid(cast.as(c.Shader, shader));
}

/// Get shader uniform location
///
/// -1 where the uniform is not in the shader, as raylib answers.
pub fn getShaderLocation(shader: Shader, uniformName: [:0]const u8) i32 {
    return c.GetShaderLocation(cast.as(c.Shader, shader), cast.cstr(uniformName));
}

/// Get shader attribute location
///
/// -1 where the attribute is not in the shader, as raylib answers.
pub fn getShaderLocationAttrib(shader: Shader, attribName: [:0]const u8) i32 {
    return c.GetShaderLocationAttrib(cast.as(c.Shader, shader), cast.cstr(attribName));
}

/// Set shader uniform value
///
/// `value` points to one value of the type `uniformType` names. It stays an
/// untyped pointer because only the run-time `uniformType` says what the bytes
/// mean: `var f: f32 = 1; setShaderValue(shader, loc, &f, .shader_uniform_float);`.
/// raylib ignores the call where `locIndex` is negative.
pub fn setShaderValue(
    shader: Shader,
    locIndex: i32,
    value: *const anyopaque,
    uniformType: ShaderUniformDataType,
) void {
    c.SetShaderValue(cast.as(c.Shader, shader), locIndex, value, @backingInt(uniformType));
}

/// Set shader uniform value vector
///
/// `value` points to `count` values of the type `uniformType` names, as in
/// `setShaderValue`: the element type is only known at run time, so the array
/// stays an untyped pointer and an explicit length. raylib ignores the call
/// where `locIndex` is negative.
pub fn setShaderValueV(
    shader: Shader,
    locIndex: i32,
    value: *const anyopaque,
    uniformType: ShaderUniformDataType,
    count: i32,
) void {
    c.SetShaderValueV(cast.as(c.Shader, shader), locIndex, value, @backingInt(uniformType), count);
}

/// Set shader uniform value (matrix 4x4)
pub fn setShaderValueMatrix(shader: Shader, locIndex: i32, mat: Matrix) void {
    c.SetShaderValueMatrix(cast.as(c.Shader, shader), locIndex, cast.as(c.Matrix, mat));
}

/// Set shader uniform value and bind the texture (sampler2d)
pub fn setShaderValueTexture(shader: Shader, locIndex: i32, texture: Texture2D) void {
    c.SetShaderValueTexture(cast.as(c.Shader, shader), locIndex, cast.as(c.Texture2D, texture));
}

/// Unload shader from GPU memory (VRAM)
///
/// Takes ownership of the shader the loaders returned, its GPU program and its
/// location array, and releases them; it dies at this call.
pub fn unloadShader(shader: Shader) void {
    c.UnloadShader(cast.as(c.Shader, shader));
}

// Screen-space-related functions

/// Get a ray trace from screen position (i.e mouse)
pub fn getScreenToWorldRay(position: Vector2, camera: Camera3D) Ray {
    return cast.as(Ray, c.GetScreenToWorldRay(cast.as(c.Vector2, position), cast.as(c.Camera3D, camera)));
}

/// Get a ray trace from screen position (i.e mouse) in a viewport
pub fn getScreenToWorldRayEx(position: Vector2, camera: Camera3D, width: i32, height: i32) Ray {
    return cast.as(Ray, c.GetScreenToWorldRayEx(
        cast.as(c.Vector2, position),
        cast.as(c.Camera3D, camera),
        width,
        height,
    ));
}

/// Get screen space position for a 3d world space position
pub fn getWorldToScreen(position: Vector3, camera: Camera3D) Vector2 {
    return cast.as(Vector2, c.GetWorldToScreen(cast.as(c.Vector3, position), cast.as(c.Camera3D, camera)));
}

/// Get sized screen space position for a 3d world space position
pub fn getWorldToScreenEx(position: Vector3, camera: Camera3D, width: i32, height: i32) Vector2 {
    return cast.as(Vector2, c.GetWorldToScreenEx(
        cast.as(c.Vector3, position),
        cast.as(c.Camera3D, camera),
        width,
        height,
    ));
}

/// Get screen space position for a 2d camera world space position
pub fn getWorldToScreen2D(position: Vector2, camera: Camera2D) Vector2 {
    return cast.as(Vector2, c.GetWorldToScreen2D(cast.as(c.Vector2, position), cast.as(c.Camera2D, camera)));
}

/// Get world space position for a 2d camera screen space position
pub fn getScreenToWorld2D(position: Vector2, camera: Camera2D) Vector2 {
    return cast.as(Vector2, c.GetScreenToWorld2D(cast.as(c.Vector2, position), cast.as(c.Camera2D, camera)));
}

/// Get camera transform matrix (view matrix)
pub fn getCameraMatrix(camera: Camera3D) Matrix {
    return cast.as(Matrix, c.GetCameraMatrix(cast.as(c.Camera3D, camera)));
}

/// Get camera 2d transform matrix
pub fn getCameraMatrix2D(camera: Camera2D) Matrix {
    return cast.as(Matrix, c.GetCameraMatrix2D(cast.as(c.Camera2D, camera)));
}

// Timing-related functions

/// Set target FPS (maximum)
pub const setTargetFPS = c.SetTargetFPS;

/// Get time in seconds for last frame drawn (delta time)
pub const getFrameTime = c.GetFrameTime;

/// Get elapsed time in seconds since InitWindow()
pub const getTime = c.GetTime;

/// Get current FPS
pub const getFPS = c.GetFPS;

// Custom frame control functions
//
// NOTE: Those functions are intended for advanced users that want full control over the frame processing
// By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
// To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL

/// Swap back buffer with front buffer (screen drawing)
pub const swapScreenBuffer = c.SwapScreenBuffer;

/// Register all input events
pub const pollInputEvents = c.PollInputEvents;

/// Wait for some time (halt program execution)
pub const waitTime = c.WaitTime;

// Random values generation functions

/// Set the seed for the random number generator
pub const setRandomSeed = c.SetRandomSeed;

/// Get a random value between min and max (both included)
pub const getRandomValue = c.GetRandomValue;

/// Load random values sequence, no values repeated
///
/// raylib takes `unsigned int count, int min, int max` and answers with an
/// `int *` whose length is that same count; raylibz takes the count and answers
/// with the slice. Null where the range holds fewer than `count` values or the
/// allocation fails, which is raylib's own answer. The caller owns the
/// sequence and must release it with `unloadRandomSequence`.
pub fn loadRandomSequence(count: u32, min: i32, max: i32) ?[]i32 {
    const values = c.LoadRandomSequence(count, min, max) orelse return null;
    return values[0..count];
}

/// Unload random values sequence
///
/// Takes ownership of the sequence `loadRandomSequence` returned and releases
/// it; it dies at this call.
pub fn unloadRandomSequence(sequence: []i32) void {
    c.UnloadRandomSequence(cast.asArrayPtrMut(i32, sequence));
}

// Misc. functions

/// Takes a screenshot of current screen (filename extension defines format)
///
/// Needs an OpenGL context: raylib reads the framebuffer. A relative name is
/// taken from raylib's base path, and raylib refuses a name containing `'`.
pub fn takeScreenshot(fileName: [:0]const u8) void {
    c.TakeScreenshot(cast.cstr(fileName));
}

/// Set up init configuration flags (view FLAGS)
///
/// raylib takes an `unsigned int`; raylibz takes the flag set. raylib sets the
/// flags without evaluating them: they are read by `initWindow`, so call this
/// before it.
pub fn setConfigFlags(flags: ConfigFlags) void {
    c.SetConfigFlags(@bitCast(flags));
}

/// Open URL with default system browser (if available)
///
/// Only safe if you control the URL: raylib's own warning is that a user could
/// craft a malicious string to perform an undesired action.
pub fn openURL(url: [:0]const u8) void {
    c.OpenURL(cast.cstr(url));
}

// Logging system

/// Set the current threshold (minimum) log level
///
/// raylib takes an `int`; raylibz takes the `TraceLogLevel` enum.
pub fn setTraceLogLevel(logLevel: TraceLogLevel) void {
    c.SetTraceLogLevel(@backingInt(logLevel));
}

/// Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
///
/// raylib's variadic function, forwarded as it is: `args` is the tuple of C
/// arguments the format string in `text` asks for. Zig requires those arguments
/// to have fixed-size types, so a literal is cast against the C type it stands
/// for: `traceLog(.log_info, "value %d", .{@as(c_int, 42)});`.
pub fn traceLog(logLevel: TraceLogLevel, text: [:0]const u8, args: anytype) void {
    @call(.auto, c.TraceLog, .{ @backingInt(logLevel), cast.cstr(text) } ++ args);
}

/// Set custom trace log
///
/// raylib's `TraceLogCallback` crosses unchanged: the variadic callback is
/// raylib's own type, `raylibz.c.TraceLogCallback`, and raylibz does not
/// re-spell it.
pub const setTraceLogCallback = c.SetTraceLogCallback;

// Memory management, using internal allocators

/// Internal memory allocator
///
/// raylib's allocator, not Zig's: the block is untyped (cast the `*anyopaque`),
/// raylib's implementation zeroes it, and it comes back `null` where the
/// allocation fails. Release it with `memFree`.
pub const memAlloc = c.MemAlloc;

/// Internal memory reallocator
///
/// raylib's allocator, not Zig's: the block is reallocated, its contents up to
/// `size` bytes stay, and its address may change. Null where the allocation
/// fails, and then the original block is still live. `ptr` may be null, as C's
/// `realloc` takes it.
pub const memRealloc = c.MemRealloc;

/// Internal memory free
///
/// Takes ownership of the block `memAlloc` or `memRealloc` returned and
/// releases it; it dies at this call. Null is ignored, as raylib's `free` is.
pub const memFree = c.MemFree;

// Tests.
//
// A window needs a display, so these exercise what raylib can answer without
// one: the random values, the memory allocators, the window flags and the
// strings raylib owns.

test "loadRandomSequence crosses the count it was given" {
    const std = @import("std");

    setRandomSeed(4);
    const sequence = loadRandomSequence(10, 1, 10) orelse return error.NoRandomSequence;
    defer unloadRandomSequence(sequence);

    try std.testing.expectEqual(@as(usize, 10), sequence.len);
    for (sequence) |value| try std.testing.expect(value >= 1 and value <= 10);

    // "no values repeated", raylib's own promise.
    for (sequence, 0..) |value, index| {
        for (sequence[index + 1 ..]) |other| try std.testing.expect(value != other);
    }
}

test "loadRandomSequence answers null where the range is too small" {
    const std = @import("std");

    // raylib's guard: a range of 10 values cannot hold a sequence of 11.
    try std.testing.expectEqual(@as(?[]i32, null), loadRandomSequence(11, 1, 10));
}

test "memAlloc, memRealloc and memFree move one block" {
    const std = @import("std");

    const first = memAlloc(16) orelse return error.NoMemory;
    const bytes: [*]u8 = @ptrCast(first);
    bytes[0] = 0xab;
    bytes[15] = 0xcd;

    const second = memRealloc(first, 64) orelse return error.NoMemory;
    const grown: [*]u8 = @ptrCast(second);
    try std.testing.expectEqual(@as(u8, 0xab), grown[0]);
    try std.testing.expectEqual(@as(u8, 0xcd), grown[15]);
    memFree(second);

    // raylib's memory free is C's free, which takes null.
    memFree(null);
}

test "the window flag set crosses as the bits raylib keeps" {
    const std = @import("std");

    setConfigFlags(.{ .flag_vsync_hint = true });
    try std.testing.expect(isWindowState(.{ .flag_vsync_hint = true }));
    try std.testing.expect(!isWindowState(.{ .flag_msaa_4x_hint = true }));

    // Clears the bit again, so that the flags this binary runs with are the ones
    // it started with.
    clearWindowState(.{ .flag_vsync_hint = true });
    try std.testing.expect(!isWindowState(.{ .flag_vsync_hint = true }));
}

test "the text raylib owns crosses as a slice" {
    const std = @import("std");

    // raylib's GLFW backend answers with an empty monitor name where there is
    // no such monitor, and it has no monitors before a window exists. (Its
    // Win32 backend does not implement the call and answers null, which the
    // optional return carries.)
    if (@import("builtin").os.tag == .windows) return error.SkipZigTest;

    // Quietens raylib's "Failed to find selected monitor" warning below, and
    // exercises the log level's own crossing.
    setTraceLogLevel(.log_none);
    defer setTraceLogLevel(.log_info);

    try std.testing.expectEqualStrings("", getMonitorName(0) orelse return error.NoMonitorName);
}
