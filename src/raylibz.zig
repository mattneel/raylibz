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
/// Clear background (framebuffer) to color.
pub const clearBackground = core.clearBackground;
/// Begin canvas (framebuffer) drawing.
pub const beginDrawing = core.beginDrawing;
/// End canvas (framebuffer) drawing and swap buffers (double buffering).
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

/// Check if key has been pressed once.
pub const isKeyPressed = input.isKeyPressed;
/// Check if key has been pressed again.
pub const isKeyPressedRepeat = input.isKeyPressedRepeat;
/// Check if key is being pressed.
pub const isKeyDown = input.isKeyDown;
/// Check if key has been released once.
pub const isKeyReleased = input.isKeyReleased;
/// Check if key is NOT being pressed.
pub const isKeyUp = input.isKeyUp;
/// Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty.
pub const getKeyPressed = input.getKeyPressed;
/// Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty.
pub const getCharPressed = input.getCharPressed;
/// Get name of a QWERTY key on the current keyboard layout (eg returns string 'q' for KEY_A on an AZERTY keyboard).
pub const getKeyName = input.getKeyName;
/// Set a custom key to exit program (default is ESC).
pub const setExitKey = input.setExitKey;
/// Check if gamepad is available.
pub const isGamepadAvailable = input.isGamepadAvailable;
/// Get gamepad internal name id.
pub const getGamepadName = input.getGamepadName;
/// Check if gamepad button has been pressed once.
pub const isGamepadButtonPressed = input.isGamepadButtonPressed;
/// Check if gamepad button is being pressed.
pub const isGamepadButtonDown = input.isGamepadButtonDown;
/// Check if gamepad button has been released once.
pub const isGamepadButtonReleased = input.isGamepadButtonReleased;
/// Check if gamepad button is NOT being pressed.
pub const isGamepadButtonUp = input.isGamepadButtonUp;
/// Get the last gamepad button pressed.
pub const getGamepadButtonPressed = input.getGamepadButtonPressed;
/// Get axis count for a gamepad.
pub const getGamepadAxisCount = input.getGamepadAxisCount;
/// Get movement value for a gamepad axis.
pub const getGamepadAxisMovement = input.getGamepadAxisMovement;
/// Set internal gamepad mappings (SDL_GameControllerDB).
pub const setGamepadMappings = input.setGamepadMappings;
/// Set gamepad vibration for both motors (duration in seconds).
pub const setGamepadVibration = input.setGamepadVibration;
/// Check if mouse button has been pressed once.
pub const isMouseButtonPressed = input.isMouseButtonPressed;
/// Check if mouse button is being pressed.
pub const isMouseButtonDown = input.isMouseButtonDown;
/// Check if mouse button has been released once.
pub const isMouseButtonReleased = input.isMouseButtonReleased;
/// Check if mouse button is NOT being pressed.
pub const isMouseButtonUp = input.isMouseButtonUp;
/// Get mouse position X.
pub const getMouseX = input.getMouseX;
/// Get mouse position Y.
pub const getMouseY = input.getMouseY;
/// Get mouse position XY.
pub const getMousePosition = input.getMousePosition;
/// Get mouse delta between frames.
pub const getMouseDelta = input.getMouseDelta;
/// Set mouse position XY.
pub const setMousePosition = input.setMousePosition;
/// Set mouse offset.
pub const setMouseOffset = input.setMouseOffset;
/// Set mouse scaling.
pub const setMouseScale = input.setMouseScale;
/// Get mouse wheel movement for X or Y, whichever is larger.
pub const getMouseWheelMove = input.getMouseWheelMove;
/// Get mouse wheel movement for both X and Y.
pub const getMouseWheelMoveV = input.getMouseWheelMoveV;
/// Set mouse cursor.
pub const setMouseCursor = input.setMouseCursor;
/// Get touch position X for touch point 0 (relative to screen size).
pub const getTouchX = input.getTouchX;
/// Get touch position Y for touch point 0 (relative to screen size).
pub const getTouchY = input.getTouchY;
/// Get touch position XY for a touch point index (relative to screen size).
pub const getTouchPosition = input.getTouchPosition;
/// Get touch point identifier for provided index.
pub const getTouchPointId = input.getTouchPointId;
/// Get number of touch points.
pub const getTouchPointCount = input.getTouchPointCount;
/// Enable a set of gestures using flags.
pub const setGesturesEnabled = input.setGesturesEnabled;
/// Check if gesture has been detected.
pub const isGestureDetected = input.isGestureDetected;
/// Get latest detected gesture.
pub const getGestureDetected = input.getGestureDetected;
/// Get gesture hold time in seconds.
pub const getGestureHoldDuration = input.getGestureHoldDuration;
/// Get gesture drag vector.
pub const getGestureDragVector = input.getGestureDragVector;
/// Get gesture drag angle.
pub const getGestureDragAngle = input.getGestureDragAngle;
/// Get gesture pinch delta.
pub const getGesturePinchVector = input.getGesturePinchVector;
/// Get gesture pinch angle.
pub const getGesturePinchAngle = input.getGesturePinchAngle;
/// Update camera position for selected mode.
pub const updateCamera = input.updateCamera;
/// Update camera movement/rotation.
pub const updateCameraPro = input.updateCameraPro;

// raylib's shapes module.

/// Set texture and rectangle to be used on shapes drawing.
pub const setShapesTexture = shapes.setShapesTexture;
/// Get texture that is used for shapes drawing.
pub const getShapesTexture = shapes.getShapesTexture;
/// Get texture source rectangle that is used for shapes drawing.
pub const getShapesTextureRectangle = shapes.getShapesTextureRectangle;
/// Draw a pixel using geometry [Can be slow, use with care].
pub const drawPixel = shapes.drawPixel;
/// Draw a pixel using geometry (Vector version) [Can be slow, use with care].
pub const drawPixelV = shapes.drawPixelV;
/// Draw a line.
pub const drawLine = shapes.drawLine;
/// Draw a line (using gl lines).
pub const drawLineV = shapes.drawLineV;
/// Draw a line (using triangles/quads).
pub const drawLineEx = shapes.drawLineEx;
/// Draw lines sequence (using gl lines).
pub const drawLineStrip = shapes.drawLineStrip;
/// Draw line segment cubic-bezier in-out interpolation.
pub const drawLineBezier = shapes.drawLineBezier;
/// Draw a dashed line.
pub const drawLineDashed = shapes.drawLineDashed;
/// Draw a color-filled triangle, counter-clockwise vertex order.
pub const drawTriangle = shapes.drawTriangle;
/// Draw triangle with interpolated colors, counter-clockwise vertex/color order.
pub const drawTriangleGradient = shapes.drawTriangleGradient;
/// Draw triangle outline, counter-clockwise vertex order.
pub const drawTriangleLines = shapes.drawTriangleLines;
/// Draw triangle outline with line thickness, counter-clockwise vertex order.
pub const drawTriangleLinesEx = shapes.drawTriangleLinesEx;
/// Draw a triangle fan defined by points (first vertex is the center).
pub const drawTriangleFan = shapes.drawTriangleFan;
/// Draw a triangle strip defined by points.
pub const drawTriangleStrip = shapes.drawTriangleStrip;
/// Draw a color-filled rectangle.
pub const drawRectangle = shapes.drawRectangle;
/// Draw a color-filled rectangle (Vector version).
pub const drawRectangleV = shapes.drawRectangleV;
/// Draw a color-filled rectangle.
pub const drawRectangleRec = shapes.drawRectangleRec;
/// Draw a color-filled rectangle with pro parameters.
pub const drawRectanglePro = shapes.drawRectanglePro;
/// Draw a vertical-gradient-filled rectangle.
pub const drawRectangleGradientV = shapes.drawRectangleGradientV;
/// Draw a horizontal-gradient-filled rectangle.
pub const drawRectangleGradientH = shapes.drawRectangleGradientH;
/// Draw a gradient-filled rectangle with custom vertex colors, counter-clockwise color order.
pub const drawRectangleGradientEx = shapes.drawRectangleGradientEx;
/// Draw rectangle outline.
pub const drawRectangleLines = shapes.drawRectangleLines;
/// Draw rectangle outline with line thickness.
pub const drawRectangleLinesEx = shapes.drawRectangleLinesEx;
/// Draw rectangle with rounded edges.
pub const drawRectangleRounded = shapes.drawRectangleRounded;
/// Draw rectangle lines with rounded edges.
pub const drawRectangleRoundedLines = shapes.drawRectangleRoundedLines;
/// Draw rectangle lines with rounded edges outline and line thickness.
pub const drawRectangleRoundedLinesEx = shapes.drawRectangleRoundedLinesEx;
/// Draw a polygon of n sides.
pub const drawPoly = shapes.drawPoly;
/// Draw a polygon outline of n sides.
pub const drawPolyLines = shapes.drawPolyLines;
/// Draw a polygon outline of n sides with line thickness.
pub const drawPolyLinesEx = shapes.drawPolyLinesEx;
/// Draw a color-filled circle.
pub const drawCircle = shapes.drawCircle;
/// Draw a color-filled circle (Vector version).
pub const drawCircleV = shapes.drawCircleV;
/// Draw a gradient-filled circle.
pub const drawCircleGradient = shapes.drawCircleGradient;
/// Draw a piece of a circle.
pub const drawCircleSector = shapes.drawCircleSector;
/// Draw circle sector outline.
pub const drawCircleSectorLines = shapes.drawCircleSectorLines;
/// Draw circle sector outline with thickness.
pub const drawCircleSectorLinesEx = shapes.drawCircleSectorLinesEx;
/// Draw circle outline.
pub const drawCircleLines = shapes.drawCircleLines;
/// Draw circle outline (Vector version).
pub const drawCircleLinesV = shapes.drawCircleLinesV;
/// Draw circle outline with line thickness.
pub const drawCircleLinesEx = shapes.drawCircleLinesEx;
/// Draw ellipse.
pub const drawEllipse = shapes.drawEllipse;
/// Draw ellipse (Vector version).
pub const drawEllipseV = shapes.drawEllipseV;
/// Draw ellipse outline.
pub const drawEllipseLines = shapes.drawEllipseLines;
/// Draw ellipse outline (Vector version).
pub const drawEllipseLinesV = shapes.drawEllipseLinesV;
/// Draw ellipse outline with line thickness.
pub const drawEllipseLinesEx = shapes.drawEllipseLinesEx;
/// Draw ring.
pub const drawRing = shapes.drawRing;
/// Draw ring outline.
pub const drawRingLines = shapes.drawRingLines;
/// Draw ring outline with line thickness.
pub const drawRingLinesEx = shapes.drawRingLinesEx;
/// Draw spline: Linear, minimum 2 points.
pub const drawSplineLinear = shapes.drawSplineLinear;
/// Draw spline: B-Spline, minimum 4 points.
pub const drawSplineBasis = shapes.drawSplineBasis;
/// Draw spline: Catmull-Rom, minimum 4 points.
pub const drawSplineCatmullRom = shapes.drawSplineCatmullRom;
/// Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...].
pub const drawSplineBezierQuadratic = shapes.drawSplineBezierQuadratic;
/// Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...].
pub const drawSplineBezierCubic = shapes.drawSplineBezierCubic;
/// Draw spline segment: Linear, 2 points.
pub const drawSplineSegmentLinear = shapes.drawSplineSegmentLinear;
/// Draw spline segment: B-Spline, 4 points.
pub const drawSplineSegmentBasis = shapes.drawSplineSegmentBasis;
/// Draw spline segment: Catmull-Rom, 4 points.
pub const drawSplineSegmentCatmullRom = shapes.drawSplineSegmentCatmullRom;
/// Draw spline segment: Quadratic Bezier, 2 points, 1 control point.
pub const drawSplineSegmentBezierQuadratic = shapes.drawSplineSegmentBezierQuadratic;
/// Draw spline segment: Cubic Bezier, 2 points, 2 control points.
pub const drawSplineSegmentBezierCubic = shapes.drawSplineSegmentBezierCubic;
/// Get (evaluate) spline point: Linear.
pub const getSplinePointLinear = shapes.getSplinePointLinear;
/// Get (evaluate) spline point: B-Spline.
pub const getSplinePointBasis = shapes.getSplinePointBasis;
/// Get (evaluate) spline point: Catmull-Rom.
pub const getSplinePointCatmullRom = shapes.getSplinePointCatmullRom;
/// Get (evaluate) spline point: Quadratic Bezier.
pub const getSplinePointBezierQuadratic = shapes.getSplinePointBezierQuadratic;
/// Get (evaluate) spline point: Cubic Bezier.
pub const getSplinePointBezierCubic = shapes.getSplinePointBezierCubic;
/// Check collision between two rectangles.
pub const checkCollisionRecs = shapes.checkCollisionRecs;
/// Check collision between two circles.
pub const checkCollisionCircles = shapes.checkCollisionCircles;
/// Check collision between circle and rectangle.
pub const checkCollisionCircleRec = shapes.checkCollisionCircleRec;
/// Check if circle collides with a line created between two points [p1] and [p2].
pub const checkCollisionCircleLine = shapes.checkCollisionCircleLine;
/// Check if point is inside rectangle.
pub const checkCollisionPointRec = shapes.checkCollisionPointRec;
/// Check if point is inside circle.
pub const checkCollisionPointCircle = shapes.checkCollisionPointCircle;
/// Check if point is inside a triangle.
pub const checkCollisionPointTriangle = shapes.checkCollisionPointTriangle;
/// Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold].
pub const checkCollisionPointLine = shapes.checkCollisionPointLine;
/// Check if point is within a polygon described by array of vertices.
pub const checkCollisionPointPoly = shapes.checkCollisionPointPoly;
/// Check the collision between two lines defined by two points each, returns collision point by reference.
pub const checkCollisionLines = shapes.checkCollisionLines;
/// Get collision rectangle for two rectangles collision.
pub const getCollisionRec = shapes.getCollisionRec;

// raylib's textures module.

/// Load image from file into CPU memory (RAM)
pub const loadImage = textures.loadImage;
/// Load image from RAW file data
pub const loadImageRaw = textures.loadImageRaw;
/// Load image sequence from file (frames appended to image.data)
pub const loadImageAnim = textures.loadImageAnim;
/// Load image sequence from memory buffer
pub const loadImageAnimFromMemory = textures.loadImageAnimFromMemory;
/// Load image from memory buffer, fileType refers to extension: i.e. '.png'
pub const loadImageFromMemory = textures.loadImageFromMemory;
/// Load image from GPU texture data
pub const loadImageFromTexture = textures.loadImageFromTexture;
/// Load image from screen buffer (screenshot)
pub const loadImageFromScreen = textures.loadImageFromScreen;
/// Check if an image is valid (data and parameters)
pub const isImageValid = textures.isImageValid;
/// Unload image from CPU memory (RAM)
pub const unloadImage = textures.unloadImage;
/// Export image data to file, returns true on success
pub const exportImage = textures.exportImage;
/// Export image to memory buffer, memory must be MemFree()
pub const exportImageToMemory = textures.exportImageToMemory;
/// Export image as code file defining an array of bytes, returns true on success
pub const exportImageAsCode = textures.exportImageAsCode;
/// Generate image: plain color
pub const genImageColor = textures.genImageColor;
/// Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient
pub const genImageGradientLinear = textures.genImageGradientLinear;
/// Generate image: radial gradient
pub const genImageGradientRadial = textures.genImageGradientRadial;
/// Generate image: square gradient
pub const genImageGradientSquare = textures.genImageGradientSquare;
/// Generate image: checked
pub const genImageChecked = textures.genImageChecked;
/// Generate image: white noise
pub const genImageWhiteNoise = textures.genImageWhiteNoise;
/// Generate image: perlin noise
pub const genImagePerlinNoise = textures.genImagePerlinNoise;
/// Generate image: cellular algorithm, bigger tileSize means bigger cells
pub const genImageCellular = textures.genImageCellular;
/// Generate image: grayscale image from text data
pub const genImageText = textures.genImageText;
/// Create an image duplicate (useful for transformations)
pub const imageCopy = textures.imageCopy;
/// Create an image from another image piece
pub const imageFromImage = textures.imageFromImage;
/// Create an image from a selected channel of another image (GRAYSCALE)
pub const imageFromChannel = textures.imageFromChannel;
/// Create an image from text (default font)
pub const imageText = textures.imageText;
/// Create an image from text (custom sprite font)
pub const imageTextEx = textures.imageTextEx;
/// Convert image data to desired format
pub const imageFormat = textures.imageFormat;
/// Convert image to POT (power-of-two)
pub const imageToPOT = textures.imageToPOT;
/// Crop an image to a defined rectangle
pub const imageCrop = textures.imageCrop;
/// Crop image depending on alpha value
pub const imageAlphaCrop = textures.imageAlphaCrop;
/// Clear alpha channel to desired color
pub const imageAlphaClear = textures.imageAlphaClear;
/// Apply alpha mask to image
pub const imageAlphaMask = textures.imageAlphaMask;
/// Premultiply alpha channel
pub const imageAlphaPremultiply = textures.imageAlphaPremultiply;
/// Apply Gaussian blur using a box blur approximation
pub const imageBlurGaussian = textures.imageBlurGaussian;
/// Apply custom square convolution kernel to image
pub const imageKernelConvolution = textures.imageKernelConvolution;
/// Resize image (Bicubic scaling algorithm)
pub const imageResize = textures.imageResize;
/// Resize image (Nearest-Neighbor scaling algorithm)
pub const imageResizeNN = textures.imageResizeNN;
/// Resize canvas and fill with color
pub const imageResizeCanvas = textures.imageResizeCanvas;
/// Compute all mipmap levels for a provided image
pub const imageMipmaps = textures.imageMipmaps;
/// Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
pub const imageDither = textures.imageDither;
/// Flip image vertically
pub const imageFlipVertical = textures.imageFlipVertical;
/// Flip image horizontally
pub const imageFlipHorizontal = textures.imageFlipHorizontal;
/// Rotate image by input angle in degrees (-359 to 359)
pub const imageRotate = textures.imageRotate;
/// Rotate image clockwise 90deg
pub const imageRotateCW = textures.imageRotateCW;
/// Rotate image counter-clockwise 90deg
pub const imageRotateCCW = textures.imageRotateCCW;
/// Modify image color: tint
pub const imageColorTint = textures.imageColorTint;
/// Modify image color: invert
pub const imageColorInvert = textures.imageColorInvert;
/// Modify image color: grayscale
pub const imageColorGrayscale = textures.imageColorGrayscale;
/// Modify image color: contrast (-100 to 100)
pub const imageColorContrast = textures.imageColorContrast;
/// Modify image color: brightness (-255 to 255)
pub const imageColorBrightness = textures.imageColorBrightness;
/// Modify image color: replace color
pub const imageColorReplace = textures.imageColorReplace;
/// Load color data from image as a Color array (RGBA - 32bit)
pub const loadImageColors = textures.loadImageColors;
/// Load colors palette from image as a Color array (RGBA - 32bit)
pub const loadImagePalette = textures.loadImagePalette;
/// Unload color data loaded with LoadImageColors()
pub const unloadImageColors = textures.unloadImageColors;
/// Unload colors palette loaded with LoadImagePalette()
pub const unloadImagePalette = textures.unloadImagePalette;
/// Get image alpha border rectangle
pub const getImageAlphaBorder = textures.getImageAlphaBorder;
/// Get image pixel color at (x, y) position
pub const getImageColor = textures.getImageColor;
/// Clear image background with provided color
pub const imageClearBackground = textures.imageClearBackground;
/// Draw pixel within an image
pub const imageDrawPixel = textures.imageDrawPixel;
/// Draw pixel within an image (Vector version)
pub const imageDrawPixelV = textures.imageDrawPixelV;
/// Draw line within an image
pub const imageDrawLine = textures.imageDrawLine;
/// Draw line within an image (Vector version)
pub const imageDrawLineV = textures.imageDrawLineV;
/// Draw a line defining thickness within an image
pub const imageDrawLineEx = textures.imageDrawLineEx;
/// Draw a lines sequence within an image
pub const imageDrawLineStrip = textures.imageDrawLineStrip;
/// Draw triangle within an image
pub const imageDrawTriangle = textures.imageDrawTriangle;
/// Draw triangle with interpolated colors within an image
pub const imageDrawTriangleGradient = textures.imageDrawTriangleGradient;
/// Draw triangle outline within an image
pub const imageDrawTriangleLines = textures.imageDrawTriangleLines;
/// Draw a triangle fan defined by points within an image (first vertex is the center)
pub const imageDrawTriangleFan = textures.imageDrawTriangleFan;
/// Draw a triangle strip defined by points within an image
pub const imageDrawTriangleStrip = textures.imageDrawTriangleStrip;
/// Draw rectangle within an image
pub const imageDrawRectangle = textures.imageDrawRectangle;
/// Draw rectangle within an image (Vector version)
pub const imageDrawRectangleV = textures.imageDrawRectangleV;
/// Draw rectangle within an image
pub const imageDrawRectangleRec = textures.imageDrawRectangleRec;
/// Draw a color-filled rectangle with pro parameters within and image
pub const imageDrawRectanglePro = textures.imageDrawRectanglePro;
/// Draw rectangle lines within an image
pub const imageDrawRectangleLines = textures.imageDrawRectangleLines;
/// Draw rectangle lines within an image with line thickness
pub const imageDrawRectangleLinesEx = textures.imageDrawRectangleLinesEx;
/// Draw rectangle with gradient colors within an image, counter-clockwise color order
pub const imageDrawRectangleGradientEx = textures.imageDrawRectangleGradientEx;
/// Draw a filled circle within an image
pub const imageDrawCircle = textures.imageDrawCircle;
/// Draw a filled circle within an image (Vector version)
pub const imageDrawCircleV = textures.imageDrawCircleV;
/// Draw circle outline within an image
pub const imageDrawCircleLines = textures.imageDrawCircleLines;
/// Draw circle outline within an image (Vector version)
pub const imageDrawCircleLinesV = textures.imageDrawCircleLinesV;
/// Draw a gradient-filled circle within an image
pub const imageDrawCircleGradient = textures.imageDrawCircleGradient;
/// Draw an image within an image
pub const imageDrawImage = textures.imageDrawImage;
/// Draw an image with scaling and rotation within an image
pub const imageDrawImageEx = textures.imageDrawImageEx;
/// Draw a part of an image defined by a rectangle within an image
pub const imageDrawImageRec = textures.imageDrawImageRec;
/// Draw a part of an image defined by a rectangle into destination rectangle, with scaling and rotation, within an image
pub const imageDrawImagePro = textures.imageDrawImagePro;
/// Draw text (using default font) within an image (destination)
pub const imageDrawText = textures.imageDrawText;
/// Draw text (custom sprite font) within an image (destination)
pub const imageDrawTextEx = textures.imageDrawTextEx;
/// Draw text using Font and pro parameters (rotation)
pub const imageDrawTextPro = textures.imageDrawTextPro;
/// Load texture from file into GPU memory (VRAM)
pub const loadTexture = textures.loadTexture;
/// Load texture from image data
pub const loadTextureFromImage = textures.loadTextureFromImage;
/// Load cubemap from image, multiple image cubemap layouts supported
pub const loadTextureCubemap = textures.loadTextureCubemap;
/// Load texture for rendering (framebuffer)
pub const loadRenderTexture = textures.loadRenderTexture;
/// Load texture for rendering (framebuffer), with specific format
pub const loadRenderTextureEx = textures.loadRenderTextureEx;
/// Check if texture is valid (loaded in GPU)
pub const isTextureValid = textures.isTextureValid;
/// Unload texture from GPU memory (VRAM)
pub const unloadTexture = textures.unloadTexture;
/// Check if render texture is valid (loaded in GPU)
pub const isRenderTextureValid = textures.isRenderTextureValid;
/// Unload render texture from GPU memory (VRAM)
pub const unloadRenderTexture = textures.unloadRenderTexture;
/// Update GPU texture with new data (pixels should be able to fill texture)
pub const updateTexture = textures.updateTexture;
/// Update GPU texture rectangle with new data (pixels and rec should fit in texture)
pub const updateTextureRec = textures.updateTextureRec;
/// Generate GPU mipmaps for a texture
pub const genTextureMipmaps = textures.genTextureMipmaps;
/// Set texture scaling filter mode
pub const setTextureFilter = textures.setTextureFilter;
/// Set texture wrapping mode
pub const setTextureWrap = textures.setTextureWrap;
/// Draw a Texture2D
pub const drawTexture = textures.drawTexture;
/// Draw a Texture2D with position defined as Vector2
pub const drawTextureV = textures.drawTextureV;
/// Draw a Texture2D with rotation and scale
pub const drawTextureEx = textures.drawTextureEx;
/// Draw a part of a texture defined by a rectangle
pub const drawTextureRec = textures.drawTextureRec;
/// Draw a part of a texture defined by a source rectangle to destination rectangle, with scaling and rotation
pub const drawTexturePro = textures.drawTexturePro;
/// Draw a texture (or part of it) that stretches or shrinks nicely
pub const drawTextureNPatch = textures.drawTextureNPatch;
/// Check if two colors are equal
pub const colorIsEqual = textures.colorIsEqual;
/// Get color with alpha applied, alpha goes from 0.0f to 1.0f
pub const fade = textures.fade;
/// Get hexadecimal value for a Color (0xRRGGBBAA)
pub const colorToInt = textures.colorToInt;
/// Get Color normalized as float [0..1]
pub const colorNormalize = textures.colorNormalize;
/// Get Color from normalized values [0..1]
pub const colorFromNormalized = textures.colorFromNormalized;
/// Get HSV values for a Color, hue [0..360], saturation/value [0..1]
pub const colorToHSV = textures.colorToHSV;
/// Get a Color from HSV values, hue [0..360], saturation/value [0..1]
pub const colorFromHSV = textures.colorFromHSV;
/// Get color multiplied with another color
pub const colorTint = textures.colorTint;
/// Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
pub const colorBrightness = textures.colorBrightness;
/// Get color with contrast correction, contrast values between -1.0f and 1.0f
pub const colorContrast = textures.colorContrast;
/// Get color with alpha applied, alpha goes from 0.0f to 1.0f
pub const colorAlpha = textures.colorAlpha;
/// Get src alpha-blended into dst color with tint
pub const colorAlphaBlend = textures.colorAlphaBlend;
/// Get color lerp interpolation between two colors, factor [0.0f..1.0f]
pub const colorLerp = textures.colorLerp;
/// Get Color structure from hexadecimal value
pub const getColor = textures.getColor;
/// Get Color from a source pixel pointer of certain format
pub const getPixelColor = textures.getPixelColor;
/// Set color formatted into destination pixel pointer
pub const setPixelColor = textures.setPixelColor;
/// Get pixel data size in bytes for certain format
pub const getPixelDataSize = textures.getPixelDataSize;

// raylib's text module.

/// Get the default Font.
pub const getFontDefault = text.getFontDefault;
/// Load font from file into GPU memory (VRAM).
pub const loadFont = text.loadFont;
/// Load font from file with defined codepoints and generation size, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height.
pub const loadFontEx = text.loadFontEx;
/// Load font from Image (XNA style).
pub const loadFontFromImage = text.loadFontFromImage;
/// Load font from memory buffer, fileType refers to extension: i.e. '.ttf'.
pub const loadFontFromMemory = text.loadFontFromMemory;
/// Check if font is valid (font data loaded, WARNING: GPU texture not checked).
pub const isFontValid = text.isFontValid;
/// Load font data for further use.
pub const loadFontData = text.loadFontData;
/// Generate image font atlas using chars info.
pub const genImageFontAtlas = text.genImageFontAtlas;
/// Unload font chars info data (RAM).
pub const unloadFontData = text.unloadFontData;
/// Unload font from GPU memory (VRAM).
pub const unloadFont = text.unloadFont;
/// Export font as code file, returns true on success.
pub const exportFontAsCode = text.exportFontAsCode;
/// Draw current FPS.
pub const drawFPS = text.drawFPS;
/// Draw text (using default font).
pub const drawText = text.drawText;
/// Draw text using font and additional parameters.
pub const drawTextEx = text.drawTextEx;
/// Draw text using Font and pro parameters (rotation).
pub const drawTextPro = text.drawTextPro;
/// Draw one character (codepoint).
pub const drawTextCodepoint = text.drawTextCodepoint;
/// Draw multiple characters (codepoint).
pub const drawTextCodepoints = text.drawTextCodepoints;
/// Set vertical line spacing when drawing with line-breaks.
pub const setTextLineSpacing = text.setTextLineSpacing;
/// Measure string width for default font.
pub const measureText = text.measureText;
/// Measure string size for Font.
pub const measureTextEx = text.measureTextEx;
/// Measure string size for an existing array of codepoints for Font.
pub const measureTextCodepoints = text.measureTextCodepoints;
/// Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found.
pub const getGlyphIndex = text.getGlyphIndex;
/// Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found.
pub const getGlyphInfo = text.getGlyphInfo;
/// Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found.
pub const getGlyphAtlasRec = text.getGlyphAtlasRec;
/// Load UTF-8 text encoded from codepoints array.
pub const loadUTF8 = text.loadUTF8;
/// Unload UTF-8 text encoded from codepoints array.
pub const unloadUTF8 = text.unloadUTF8;
/// Load all codepoints from a UTF-8 text string, codepoints count returned by parameter.
pub const loadCodepoints = text.loadCodepoints;
/// Unload codepoints data from memory.
pub const unloadCodepoints = text.unloadCodepoints;
/// Get total number of codepoints in a UTF-8 encoded string.
pub const getCodepointCount = text.getCodepointCount;
/// Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure.
pub const getCodepoint = text.getCodepoint;
/// Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure.
pub const getCodepointNext = text.getCodepointNext;
/// Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure.
pub const getCodepointPrevious = text.getCodepointPrevious;
/// Encode one codepoint into UTF-8 byte array (array length returned as parameter).
pub const codepointToUTF8 = text.codepointToUTF8;
/// Load text as separate lines ('\n').
pub const loadTextLines = text.loadTextLines;
/// Unload text lines.
pub const unloadTextLines = text.unloadTextLines;
/// Copy one string to another, returns bytes copied.
pub const textCopy = text.textCopy;
/// Check if two text strings are equal.
pub const textIsEqual = text.textIsEqual;
/// Get text length, checks for '\0' ending.
pub const textLength = text.textLength;
/// Text formatting with variables (sprintf() style).
pub const textFormat = text.textFormat;
/// Get a piece of a text string.
pub const textSubtext = text.textSubtext;
/// Remove text spaces, concat words.
pub const textRemoveSpaces = text.textRemoveSpaces;
/// Get text between two strings.
pub const getTextBetween = text.getTextBetween;
/// Replace text string with new string.
pub const textReplace = text.textReplace;
/// Replace text string with new string, memory must be MemFree().
pub const textReplaceAlloc = text.textReplaceAlloc;
/// Replace text between two specific strings.
pub const textReplaceBetween = text.textReplaceBetween;
/// Replace text between two specific strings, memory must be MemFree().
pub const textReplaceBetweenAlloc = text.textReplaceBetweenAlloc;
/// Insert text in a defined byte position.
pub const textInsert = text.textInsert;
/// Insert text in a defined byte position, memory must be MemFree().
pub const textInsertAlloc = text.textInsertAlloc;
/// Join text strings with delimiter.
pub const textJoin = text.textJoin;
/// Split text into multiple strings, using MAX_TEXTSPLIT_COUNT static strings.
pub const textSplit = text.textSplit;
/// Append text at specific position and move cursor.
pub const textAppend = text.textAppend;
/// Find first text occurrence within a string, -1 if not found.
pub const textFindIndex = text.textFindIndex;
/// Get upper case version of provided string.
pub const textToUpper = text.textToUpper;
/// Get lower case version of provided string.
pub const textToLower = text.textToLower;
/// Get Pascal case notation version of provided string.
pub const textToPascal = text.textToPascal;
/// Get Snake case notation version of provided string.
pub const textToSnake = text.textToSnake;
/// Get Camel case notation version of provided string.
pub const textToCamel = text.textToCamel;
/// Get integer value from text.
pub const textToInteger = text.textToInteger;
/// Get float value from text.
pub const textToFloat = text.textToFloat;

// raylib's models module.

// raylib's audio module.

/// Initialize audio device and context.
pub const initAudioDevice = audio.initAudioDevice;
/// Close the audio device and context.
pub const closeAudioDevice = audio.closeAudioDevice;
/// Check if audio device has been initialized successfully.
pub const isAudioDeviceReady = audio.isAudioDeviceReady;
/// Set master volume (listener).
pub const setMasterVolume = audio.setMasterVolume;
/// Get master volume (listener).
pub const getMasterVolume = audio.getMasterVolume;
/// Load wave data from file.
pub const loadWave = audio.loadWave;
/// Load wave from memory buffer, fileType refers to extension: i.e. '.wav'.
pub const loadWaveFromMemory = audio.loadWaveFromMemory;
/// Check if wave data is valid (data loaded and parameters).
pub const isWaveValid = audio.isWaveValid;
/// Load sound from file.
pub const loadSound = audio.loadSound;
/// Load sound from wave data.
pub const loadSoundFromWave = audio.loadSoundFromWave;
/// Load sound alias, new sound that shares the same sample data as the source sound, does not own the sound data.
pub const loadSoundAlias = audio.loadSoundAlias;
/// Check if sound is valid (context and buffers initialized).
pub const isSoundValid = audio.isSoundValid;
/// Update sound buffer with new data (default data format: 32 bit float, stereo).
pub const updateSound = audio.updateSound;
/// Unload wave data.
pub const unloadWave = audio.unloadWave;
/// Unload sound.
pub const unloadSound = audio.unloadSound;
/// Unload sound alias (does not deallocate sample data).
pub const unloadSoundAlias = audio.unloadSoundAlias;
/// Export wave data to file, returns true on success.
pub const exportWave = audio.exportWave;
/// Export wave sample data to code (.h), returns true on success.
pub const exportWaveAsCode = audio.exportWaveAsCode;
/// Play a sound.
pub const playSound = audio.playSound;
/// Stop playing a sound.
pub const stopSound = audio.stopSound;
/// Pause a sound.
pub const pauseSound = audio.pauseSound;
/// Resume a paused sound.
pub const resumeSound = audio.resumeSound;
/// Check if sound is currently playing.
pub const isSoundPlaying = audio.isSoundPlaying;
/// Set volume for a sound (1.0 is max level).
pub const setSoundVolume = audio.setSoundVolume;
/// Set pitch for a sound (1.0 is base level).
pub const setSoundPitch = audio.setSoundPitch;
/// Set pan for a sound (-1.0 left, 0.0 center, 1.0 right).
pub const setSoundPan = audio.setSoundPan;
/// Copy a wave to a new wave.
pub const waveCopy = audio.waveCopy;
/// Crop a wave to defined frames range.
pub const waveCrop = audio.waveCrop;
/// Convert wave data to desired format.
pub const waveFormat = audio.waveFormat;
/// Load samples data from wave as a 32bit float data array.
pub const loadWaveSamples = audio.loadWaveSamples;
/// Unload samples data loaded with LoadWaveSamples().
pub const unloadWaveSamples = audio.unloadWaveSamples;
/// Load music stream from file.
pub const loadMusicStream = audio.loadMusicStream;
/// Load music stream from data.
pub const loadMusicStreamFromMemory = audio.loadMusicStreamFromMemory;
/// Check if music stream is valid (context and buffers initialized).
pub const isMusicValid = audio.isMusicValid;
/// Unload music stream.
pub const unloadMusicStream = audio.unloadMusicStream;
/// Start music playing.
pub const playMusicStream = audio.playMusicStream;
/// Check if music is playing.
pub const isMusicStreamPlaying = audio.isMusicStreamPlaying;
/// Update buffers for music streaming.
pub const updateMusicStream = audio.updateMusicStream;
/// Stop music playing.
pub const stopMusicStream = audio.stopMusicStream;
/// Pause music playing.
pub const pauseMusicStream = audio.pauseMusicStream;
/// Resume playing paused music.
pub const resumeMusicStream = audio.resumeMusicStream;
/// Seek music to a position (in seconds).
pub const seekMusicStream = audio.seekMusicStream;
/// Set volume for music (1.0 is max level).
pub const setMusicVolume = audio.setMusicVolume;
/// Set pitch for music (1.0 is base level).
pub const setMusicPitch = audio.setMusicPitch;
/// Set pan for music (-1.0 left, 0.0 center, 1.0 right).
pub const setMusicPan = audio.setMusicPan;
/// Get music time length (in seconds).
pub const getMusicTimeLength = audio.getMusicTimeLength;
/// Get current music time played (in seconds).
pub const getMusicTimePlayed = audio.getMusicTimePlayed;
/// Load audio stream (to stream raw audio pcm data).
pub const loadAudioStream = audio.loadAudioStream;
/// Check if an audio stream is valid (buffers initialized).
pub const isAudioStreamValid = audio.isAudioStreamValid;
/// Unload audio stream and free memory.
pub const unloadAudioStream = audio.unloadAudioStream;
/// Update audio stream buffers with data.
pub const updateAudioStream = audio.updateAudioStream;
/// Check if any audio stream buffers requires refill.
pub const isAudioStreamProcessed = audio.isAudioStreamProcessed;
/// Play audio stream.
pub const playAudioStream = audio.playAudioStream;
/// Pause audio stream.
pub const pauseAudioStream = audio.pauseAudioStream;
/// Resume audio stream.
pub const resumeAudioStream = audio.resumeAudioStream;
/// Check if audio stream is playing.
pub const isAudioStreamPlaying = audio.isAudioStreamPlaying;
/// Stop audio stream.
pub const stopAudioStream = audio.stopAudioStream;
/// Set volume for audio stream (1.0 is max level).
pub const setAudioStreamVolume = audio.setAudioStreamVolume;
/// Set pitch for audio stream (1.0 is base level).
pub const setAudioStreamPitch = audio.setAudioStreamPitch;
/// Set pan for audio stream (-1.0 left, 0.0 center, 1.0 right).
pub const setAudioStreamPan = audio.setAudioStreamPan;
/// Default size for new audio streams.
pub const setAudioStreamBufferSizeDefault = audio.setAudioStreamBufferSizeDefault;
/// Audio thread callback to request new data.
pub const setAudioStreamCallback = audio.setAudioStreamCallback;
/// Attach audio stream processor to stream, receives frames x 2 samples as 'float' (stereo).
pub const attachAudioStreamProcessor = audio.attachAudioStreamProcessor;
/// Detach audio stream processor from stream.
pub const detachAudioStreamProcessor = audio.detachAudioStreamProcessor;
/// Attach audio stream processor to the entire audio pipeline, receives frames x 2 samples as 'float' (stereo).
pub const attachAudioMixedProcessor = audio.attachAudioMixedProcessor;
/// Detach audio stream processor from the entire audio pipeline.
pub const detachAudioMixedProcessor = audio.detachAudioMixedProcessor;

// raymath's free functions.

/// Clamp float value
pub const clamp = math.clamp;

/// Calculate linear interpolation between two floats
pub const lerp = math.lerp;

/// Normalize input value within input range
pub const normalize = math.normalize;

/// Remap input value within input range to output range
pub const remap = math.remap;

/// Wrap input value from min to max
pub const wrap = math.wrap;

/// Check whether two given floats are almost equal
pub const floatEquals = math.floatEquals;

/// Add two quaternions
pub const quaternionAdd = math.quaternionAdd;

/// Add quaternion and float value
pub const quaternionAddValue = math.quaternionAddValue;

/// Subtract two quaternions
pub const quaternionSubtract = math.quaternionSubtract;

/// Subtract quaternion and float value
pub const quaternionSubtractValue = math.quaternionSubtractValue;

/// Get identity quaternion
pub const quaternionIdentity = math.quaternionIdentity;

/// Computes the length of a quaternion
pub const quaternionLength = math.quaternionLength;

/// Normalize provided quaternion
pub const quaternionNormalize = math.quaternionNormalize;

/// Invert provided quaternion
pub const quaternionInvert = math.quaternionInvert;

/// Calculate two quaternion multiplication
pub const quaternionMultiply = math.quaternionMultiply;

/// Scale quaternion by float value
pub const quaternionScale = math.quaternionScale;

/// Divide two quaternions
pub const quaternionDivide = math.quaternionDivide;

/// Calculate linear interpolation between two quaternions
pub const quaternionLerp = math.quaternionLerp;

/// Calculate slerp-optimized interpolation between two quaternions
pub const quaternionNlerp = math.quaternionNlerp;

/// Calculates spherical linear interpolation between two quaternions
pub const quaternionSlerp = math.quaternionSlerp;

/// Calculate quaternion cubic spline interpolation using Cubic Hermite Spline algorithm
/// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
pub const quaternionCubicHermiteSpline = math.quaternionCubicHermiteSpline;

/// Calculate quaternion based on the rotation from one vector to another
pub const quaternionFromVector3ToVector3 = math.quaternionFromVector3ToVector3;

/// Get a quaternion for a given rotation matrix
pub const quaternionFromMatrix = math.quaternionFromMatrix;

/// Get a matrix for a given quaternion
pub const quaternionToMatrix = math.quaternionToMatrix;

/// Get rotation quaternion for an angle and axis
/// NOTE: Angle must be provided in radians
pub const quaternionFromAxisAngle = math.quaternionFromAxisAngle;

/// Get the rotation angle and axis for a given quaternion
pub const quaternionToAxisAngle = math.quaternionToAxisAngle;

/// Get the quaternion equivalent to Euler angles
/// NOTE: Rotation order is ZYX
pub const quaternionFromEuler = math.quaternionFromEuler;

/// Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
/// NOTE: Angles are returned in a Vector3 struct in radians
pub const quaternionToEuler = math.quaternionToEuler;

/// Transform a quaternion given a transformation matrix
pub const quaternionTransform = math.quaternionTransform;

/// Check whether two given quaternions are almost equal
pub const quaternionEquals = math.quaternionEquals;

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
        // Every declaration of nine files, each compared by name: well past the default
        // budget of 1000 backward branches once the wrappers are in.
        @setEvalBranchQuota(200_000);
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
