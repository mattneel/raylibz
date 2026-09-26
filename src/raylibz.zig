//! raylibz: the Zig++-sanctioned wrapper for [raylib](https://github.com/raysan5/raylib).
//!
//! raylibz is a thin, 1:1 Zig face on raylib's *own* translated headers. It
//! wraps none of raylib's declarations itself: raylib's build script translates
//! `raylib.h`, `rcamera.h`, `raymath.h` and `rlgl.h` and publishes them as
//! modules, raylibz imports those, and everything below is either a flat
//! re-export of them, a wrapper that spells raylib's C types the Zig way, or a
//! name listed in `not_wrapped`.
//!
//! # The raw layer
//!
//! `raylibz.c` is raylib's translated `raylib` module, exactly as raylib built
//! it, and `raylibz.raymath` and `raylibz.rlgl` are its `raymath` and `rlgl`
//! modules. Nothing is hidden: a program can always drop to raylib's own
//! declarations. rlgl is not wrapped; it is re-exported raw, for the programs
//! that need it.
//!
//! # The shape of the wrapper
//!
//! * Names: raylib's, with the first letter lowercased (`InitWindow` →
//!   `initWindow`). Types and struct fields keep raylib's names.
//! * Mirrors: every raylib struct is an `extern struct` with raylib's fields in
//!   raylib's order, asserted field for field against the translated type at
//!   compile time, so a drift in raylib's header is a build error.
//! * Text: `const char *` in is `[:0]const u8`; text out is `[:0]const u8`, or
//!   `?[:0]u8` where the caller must release it.
//! * Buffers: a pointer-and-count pair is a slice, in and out.
//! * Loading: a `Load*` that raylib pairs with an `Is*Valid` check returns
//!   `error{LoadFailed}!T`, having made that check.
//! * Enums: raylib's 21 C enums as Zig enums with raylib's values; `ConfigFlags`
//!   and `Gesture` as `packed struct`s of bools, one bit each.
//! * Colours: raylib's 26 colour macros as decls on `Color`.
//!
//! Every wrapper in a module file (`core.zig`, `text.zig`, ...) is re-exported
//! here flatly, and the test at the bottom of this file fails if a module file
//! declares something the root does not publish.

const std = @import("std");

/// raylib's translated `raylib.h`, raw and complete.
pub const c = @import("raylib");
/// raylib's translated `raymath.h`, raw and complete.
pub const raymath = @import("raymath");
/// raylib's translated `rlgl.h`, raw. raylibz does not wrap rlgl.
pub const rlgl = @import("rlgl");

/// The helpers that cross the boundary, and `cast.NotWrapped`.
pub const cast = @import("cast.zig");
/// raylib's 21 enums, and `ConfigFlags` and `Gesture` as flag sets.
pub const enums = @import("enums.zig");
/// Every mirrored struct except the vectors and the matrix.
pub const types = @import("types.zig");
/// `Vector2` and its raymath methods.
pub const vector2 = @import("vector2.zig");
/// `Vector3` and its raymath methods.
pub const vector3 = @import("vector3.zig");
/// `Vector4` (and therefore `Quaternion`) and its raymath methods.
pub const vector4 = @import("vector4.zig");
/// `Matrix` and raymath's `Matrix*` functions as methods.
pub const matrix = @import("matrix.zig");

/// raylib's core module, up to its file system functions.
pub const core = @import("core.zig");
/// raylib's core module from its file system functions on: files, compression, automation events.
pub const files = @import("files.zig");
/// raylib's input handling, with `rgestures` and `rcamera`.
pub const input = @import("input.zig");
/// raylib's shapes module.
pub const shapes = @import("shapes.zig");
/// raylib's textures module.
pub const textures = @import("textures.zig");
/// raylib's text module.
pub const text = @import("text.zig");
/// raylib's models module.
pub const models = @import("models.zig");
/// raylib's audio module.
pub const audio = @import("audio.zig");
/// raymath's free functions.
pub const math = @import("math.zig");

/// Every function raylibz does not wrap, and why.
pub const not_wrapped = @import("not_wrapped.zig");

// The vectors and the matrix, from the files that carry their methods.

/// Vector2, 2 components.
pub const Vector2 = vector2.Vector2;
/// Vector3, 3 components.
pub const Vector3 = vector3.Vector3;
/// Vector4, 4 components.
pub const Vector4 = vector4.Vector4;
/// Quaternion, raylib's `typedef Vector4 Quaternion`.
pub const Quaternion = vector4.Quaternion;
/// Matrix, 4x4 components, column major, OpenGL style, right-handed.
pub const Matrix = matrix.Matrix;

// Every other mirrored struct.

/// Color, 4 components, R8G8B8A8 (32bit), with raylib's colours as decls.
pub const Color = types.Color;
/// Rectangle, 4 components.
pub const Rectangle = types.Rectangle;
/// Image, pixel data stored in CPU memory (RAM).
pub const Image = types.Image;
/// Texture, tex data stored in GPU memory (VRAM).
pub const Texture = types.Texture;
/// Texture2D, same as `Texture`.
pub const Texture2D = types.Texture2D;
/// TextureCubemap, same as `Texture`.
pub const TextureCubemap = types.TextureCubemap;
/// RenderTexture, fbo for texture rendering.
pub const RenderTexture = types.RenderTexture;
/// RenderTexture2D, same as `RenderTexture`.
pub const RenderTexture2D = types.RenderTexture2D;
/// NPatchInfo, n-patch layout info.
pub const NPatchInfo = types.NPatchInfo;
/// GlyphInfo, font characters glyphs info.
pub const GlyphInfo = types.GlyphInfo;
/// Font, font texture and GlyphInfo array data.
pub const Font = types.Font;
/// Camera3D, defines position/orientation in 3d space.
pub const Camera3D = types.Camera3D;
/// Camera, raylib's fallback typedef for `Camera3D`.
pub const Camera = types.Camera;
/// Camera2D, defines position/orientation in 2d space.
pub const Camera2D = types.Camera2D;
/// Mesh, vertex data and vao/vbo.
pub const Mesh = types.Mesh;
/// Shader.
pub const Shader = types.Shader;
/// MaterialMap.
pub const MaterialMap = types.MaterialMap;
/// Material, includes shader and maps.
pub const Material = types.Material;
/// Transform, vertex transformation data.
pub const Transform = types.Transform;
/// BoneInfo, skeletal animation bone.
pub const BoneInfo = types.BoneInfo;
/// ModelSkeleton, animation bones hierarchy.
pub const ModelSkeleton = types.ModelSkeleton;
/// Model, meshes, materials and animation data.
pub const Model = types.Model;
/// ModelAnimation, contains a full animation sequence.
pub const ModelAnimation = types.ModelAnimation;
/// ModelAnimPose, raylib's `typedef Transform *ModelAnimPose`.
pub const ModelAnimPose = types.ModelAnimPose;
/// Ray, ray for raycasting.
pub const Ray = types.Ray;
/// RayCollision, ray hit information.
pub const RayCollision = types.RayCollision;
/// BoundingBox.
pub const BoundingBox = types.BoundingBox;
/// Wave, audio wave data.
pub const Wave = types.Wave;
/// AudioStream, custom audio stream.
pub const AudioStream = types.AudioStream;
/// Sound.
pub const Sound = types.Sound;
/// Music, audio stream, anything longer than ~10 seconds should be streamed.
pub const Music = types.Music;
/// VrDeviceInfo, Head-Mounted-Display device parameters.
pub const VrDeviceInfo = types.VrDeviceInfo;
/// VrStereoConfig, VR stereo rendering configuration for simulator.
pub const VrStereoConfig = types.VrStereoConfig;
/// FilePathList.
pub const FilePathList = types.FilePathList;
/// AutomationEvent.
pub const AutomationEvent = types.AutomationEvent;
/// AutomationEventList.
pub const AutomationEventList = types.AutomationEventList;

// raylib's enums, and its two flag sets.

/// System/Window config flags, a bit each.
pub const ConfigFlags = enums.ConfigFlags;
/// Trace log level.
pub const TraceLogLevel = enums.TraceLogLevel;
/// Keyboard keys (US keyboard layout).
pub const KeyboardKey = enums.KeyboardKey;
/// Mouse buttons.
pub const MouseButton = enums.MouseButton;
/// Mouse cursor.
pub const MouseCursor = enums.MouseCursor;
/// Gamepad buttons.
pub const GamepadButton = enums.GamepadButton;
/// Gamepad axes.
pub const GamepadAxis = enums.GamepadAxis;
/// Material map index.
pub const MaterialMapIndex = enums.MaterialMapIndex;
/// Shader location index.
pub const ShaderLocationIndex = enums.ShaderLocationIndex;
/// Shader uniform data type.
pub const ShaderUniformDataType = enums.ShaderUniformDataType;
/// Shader attribute data types.
pub const ShaderAttributeDataType = enums.ShaderAttributeDataType;
/// Pixel formats.
pub const PixelFormat = enums.PixelFormat;
/// Texture parameters: filter mode.
pub const TextureFilter = enums.TextureFilter;
/// Texture parameters: wrap mode.
pub const TextureWrap = enums.TextureWrap;
/// Cubemap layouts.
pub const CubemapLayout = enums.CubemapLayout;
/// Font type, defines generation method.
pub const FontType = enums.FontType;
/// Color blending modes (pre-defined).
pub const BlendMode = enums.BlendMode;
/// Gestures, a bit each.
pub const Gesture = enums.Gesture;
/// Camera system modes.
pub const CameraMode = enums.CameraMode;
/// Camera projection.
pub const CameraProjection = enums.CameraProjection;
/// N-patch layout.
pub const NPatchLayout = enums.NPatchLayout;

// raylib's core module.

/// Initialize window and OpenGL context.
pub const initWindow = core.initWindow;
/// Close window and unload OpenGL context.
pub const closeWindow = core.closeWindow;
/// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked).
pub const windowShouldClose = core.windowShouldClose;
/// Check if window has been initialized successfully.
pub const isWindowReady = core.isWindowReady;
/// Check if window is currently fullscreen.
pub const isWindowFullscreen = core.isWindowFullscreen;
/// Check if window is currently hidden.
pub const isWindowHidden = core.isWindowHidden;
/// Check if window is currently minimized.
pub const isWindowMinimized = core.isWindowMinimized;
/// Check if window is currently maximized.
pub const isWindowMaximized = core.isWindowMaximized;
/// Check if window is currently focused.
pub const isWindowFocused = core.isWindowFocused;
/// Check if window has been resized last frame.
pub const isWindowResized = core.isWindowResized;
/// Check if one specific window flag is enabled.
pub const isWindowState = core.isWindowState;
/// Set window configuration state using flags.
pub const setWindowState = core.setWindowState;
/// Clear window configuration state flags.
pub const clearWindowState = core.clearWindowState;
/// Toggle window state: fullscreen/windowed, resizes monitor to match window resolution.
pub const toggleFullscreen = core.toggleFullscreen;
/// Toggle window state: borderless windowed, resizes window to match monitor resolution.
pub const toggleBorderlessWindowed = core.toggleBorderlessWindowed;
/// Set window state: maximized, if resizable.
pub const maximizeWindow = core.maximizeWindow;
/// Set window state: minimized, if resizable.
pub const minimizeWindow = core.minimizeWindow;
/// Restore window from being minimized/maximized.
pub const restoreWindow = core.restoreWindow;
/// Set icon for window (single image, RGBA 32bit).
pub const setWindowIcon = core.setWindowIcon;
/// Set icon for window (multiple images, RGBA 32bit).
pub const setWindowIcons = core.setWindowIcons;
/// Set title for window.
pub const setWindowTitle = core.setWindowTitle;
/// Set window position on screen.
pub const setWindowPosition = core.setWindowPosition;
/// Set monitor for the current window.
pub const setWindowMonitor = core.setWindowMonitor;
/// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE).
pub const setWindowMinSize = core.setWindowMinSize;
/// Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE).
pub const setWindowMaxSize = core.setWindowMaxSize;
/// Set window dimensions.
pub const setWindowSize = core.setWindowSize;
/// Set window opacity [0.0f..1.0f].
pub const setWindowOpacity = core.setWindowOpacity;
/// Set window focused.
pub const setWindowFocused = core.setWindowFocused;
/// Get native window handle.
pub const getWindowHandle = core.getWindowHandle;
/// Get current screen width.
pub const getScreenWidth = core.getScreenWidth;
/// Get current screen height.
pub const getScreenHeight = core.getScreenHeight;
/// Get current render width (it considers HiDPI).
pub const getRenderWidth = core.getRenderWidth;
/// Get current render height (it considers HiDPI).
pub const getRenderHeight = core.getRenderHeight;
/// Get number of connected monitors.
pub const getMonitorCount = core.getMonitorCount;
/// Get current monitor where window is placed.
pub const getCurrentMonitor = core.getCurrentMonitor;
/// Get specified monitor position.
pub const getMonitorPosition = core.getMonitorPosition;
/// Get specified monitor width (current video mode used by monitor).
pub const getMonitorWidth = core.getMonitorWidth;
/// Get specified monitor height (current video mode used by monitor).
pub const getMonitorHeight = core.getMonitorHeight;
/// Get specified monitor physical width in millimetres.
pub const getMonitorPhysicalWidth = core.getMonitorPhysicalWidth;
/// Get specified monitor physical height in millimetres.
pub const getMonitorPhysicalHeight = core.getMonitorPhysicalHeight;
/// Get specified monitor refresh rate.
pub const getMonitorRefreshRate = core.getMonitorRefreshRate;
/// Get window position XY on monitor.
pub const getWindowPosition = core.getWindowPosition;
/// Get window scale DPI factor.
pub const getWindowScaleDPI = core.getWindowScaleDPI;
/// Get the human-readable, UTF-8 encoded name of the specified monitor.
pub const getMonitorName = core.getMonitorName;
/// Set clipboard text content.
pub const setClipboardText = core.setClipboardText;
/// Get clipboard text content.
pub const getClipboardText = core.getClipboardText;
/// Get clipboard image content.
pub const getClipboardImage = core.getClipboardImage;
/// Enable waiting for events on EndDrawing(), no automatic event polling.
pub const enableEventWaiting = core.enableEventWaiting;
/// Disable waiting for events on EndDrawing(), automatic events polling.
pub const disableEventWaiting = core.disableEventWaiting;
/// Show cursor.
pub const showCursor = core.showCursor;
/// Hide cursor.
pub const hideCursor = core.hideCursor;
/// Check if cursor is not visible.
pub const isCursorHidden = core.isCursorHidden;
/// Enable cursor (unlock cursor).
pub const enableCursor = core.enableCursor;
/// Disable cursor (lock cursor).
pub const disableCursor = core.disableCursor;
/// Check if cursor is on the screen.
pub const isCursorOnScreen = core.isCursorOnScreen;
/// Set background color (framebuffer clear color).
pub const clearBackground = core.clearBackground;
/// Setup drawing canvas to start drawing.
pub const beginDrawing = core.beginDrawing;
/// End canvas drawing and swap buffers (double buffering).
pub const endDrawing = core.endDrawing;
/// Begin 2D mode with custom camera (2D).
pub const beginMode2D = core.beginMode2D;
/// End 2D mode with custom camera.
pub const endMode2D = core.endMode2D;
/// Begin 3D mode with custom camera (3D).
pub const beginMode3D = core.beginMode3D;
/// End 3D mode and returns to default 2D orthographic mode.
pub const endMode3D = core.endMode3D;
/// Begin drawing to render texture.
pub const beginTextureMode = core.beginTextureMode;
/// End drawing to render texture.
pub const endTextureMode = core.endTextureMode;
/// Begin custom shader drawing.
pub const beginShaderMode = core.beginShaderMode;
/// End custom shader drawing (use default shader).
pub const endShaderMode = core.endShaderMode;
/// Begin blending mode (alpha, additive, multiplied, subtract, custom).
pub const beginBlendMode = core.beginBlendMode;
/// End blending mode (reset to default: alpha blending).
pub const endBlendMode = core.endBlendMode;
/// Begin scissor mode (define screen area for following drawing).
pub const beginScissorMode = core.beginScissorMode;
/// End scissor mode.
pub const endScissorMode = core.endScissorMode;
/// Begin stereo rendering (requires VR simulator).
pub const beginVrStereoMode = core.beginVrStereoMode;
/// End stereo rendering (requires VR simulator).
pub const endVrStereoMode = core.endVrStereoMode;
/// Load VR stereo config for VR simulator device parameters.
pub const loadVrStereoConfig = core.loadVrStereoConfig;
/// Unload VR stereo config.
pub const unloadVrStereoConfig = core.unloadVrStereoConfig;
/// Load shader from files and bind default locations.
pub const loadShader = core.loadShader;
/// Load shader from code strings and bind default locations.
pub const loadShaderFromMemory = core.loadShaderFromMemory;
/// Check if shader is valid (loaded on GPU).
pub const isShaderValid = core.isShaderValid;
/// Get shader uniform location.
pub const getShaderLocation = core.getShaderLocation;
/// Get shader attribute location.
pub const getShaderLocationAttrib = core.getShaderLocationAttrib;
/// Set shader uniform value.
pub const setShaderValue = core.setShaderValue;
/// Set shader uniform value vector.
pub const setShaderValueV = core.setShaderValueV;
/// Set shader uniform value (matrix 4x4).
pub const setShaderValueMatrix = core.setShaderValueMatrix;
/// Set shader uniform value and bind the texture (sampler2d).
pub const setShaderValueTexture = core.setShaderValueTexture;
/// Unload shader from GPU memory (VRAM).
pub const unloadShader = core.unloadShader;
/// Get a ray trace from screen position (i.e mouse).
pub const getScreenToWorldRay = core.getScreenToWorldRay;
/// Get a ray trace from screen position (i.e mouse) in a viewport.
pub const getScreenToWorldRayEx = core.getScreenToWorldRayEx;
/// Get screen space position for a 3d world space position.
pub const getWorldToScreen = core.getWorldToScreen;
/// Get sized screen space position for a 3d world space position.
pub const getWorldToScreenEx = core.getWorldToScreenEx;
/// Get screen space position for a 2d camera world space position.
pub const getWorldToScreen2D = core.getWorldToScreen2D;
/// Get world space position for a 2d camera screen space position.
pub const getScreenToWorld2D = core.getScreenToWorld2D;
/// Get camera transform matrix (view matrix).
pub const getCameraMatrix = core.getCameraMatrix;
/// Get camera 2d transform matrix.
pub const getCameraMatrix2D = core.getCameraMatrix2D;
/// Set target FPS (maximum).
pub const setTargetFPS = core.setTargetFPS;
/// Get time in seconds for last frame drawn (delta time).
pub const getFrameTime = core.getFrameTime;
/// Get elapsed time in seconds since InitWindow().
pub const getTime = core.getTime;
/// Get current FPS.
pub const getFPS = core.getFPS;
/// Swap back buffer with front buffer (screen drawing).
pub const swapScreenBuffer = core.swapScreenBuffer;
/// Register all input events.
pub const pollInputEvents = core.pollInputEvents;
/// Wait for some time (halt program execution).
pub const waitTime = core.waitTime;
/// Set the seed for the random number generator.
pub const setRandomSeed = core.setRandomSeed;
/// Get a random value between min and max (both included).
pub const getRandomValue = core.getRandomValue;
/// Load random values sequence, no values repeated.
pub const loadRandomSequence = core.loadRandomSequence;
/// Unload random values sequence.
pub const unloadRandomSequence = core.unloadRandomSequence;
/// Takes a screenshot of current screen (filename extension defines format).
pub const takeScreenshot = core.takeScreenshot;
/// Set up init configuration flags (view FLAGS).
pub const setConfigFlags = core.setConfigFlags;
/// Open URL with default system browser (if available).
pub const openURL = core.openURL;
/// Set the current threshold (minimum) log level.
pub const setTraceLogLevel = core.setTraceLogLevel;
/// Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...).
pub const traceLog = core.traceLog;
/// Set custom trace log.
pub const setTraceLogCallback = core.setTraceLogCallback;
/// Internal memory allocator.
pub const memAlloc = core.memAlloc;
/// Internal memory reallocator.
pub const memRealloc = core.memRealloc;
/// Internal memory free.
pub const memFree = core.memFree;

// raylib's core module: files, compression, automation events.

// raylib's input handling, gestures and camera.

// raylib's shapes module.

// raylib's textures module.

// raylib's text module.

/// Draw text (using default font).
pub const drawText = text.drawText;

// raylib's models module.

// raylib's audio module.

// raymath's free functions.

// Everything `zig build test` runs here: this file's re-export test, and the
// unit tests of every file the package publishes.
test {
    std.testing.refAllDecls(@This());
}

/// The module files whose declarations the root publishes flatly.
const module_files = .{ core, files, input, shapes, textures, text, models, audio, math };

test "every declaration of every module file is re-exported by the root" {
    // `not_wrapped` cannot be flat: every module file has one, and the root
    // publishes them together as `raylibz.not_wrapped`. `internal` is each module
    // file's namespace of private helpers, which nothing re-exports.
    const missing = comptime blk: {
        var missing_names: []const []const u8 = &.{};
        for (module_files) |module_file| {
            for (@typeInfo(module_file).@"struct".decl_names) |name| {
                if (std.mem.eql(u8, name, "not_wrapped") or std.mem.eql(u8, name, "internal")) continue;
                if (!@hasDecl(@This(), name)) missing_names = missing_names ++ .{name};
            }
        }
        break :blk missing_names;
    };

    try std.testing.expectEqualSlices([]const u8, &.{}, missing);
}
