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
/// Set target FPS (maximum).
pub const setTargetFPS = core.setTargetFPS;
/// Setup drawing canvas to start drawing.
pub const beginDrawing = core.beginDrawing;
/// End canvas drawing and swap buffers (double buffering).
pub const endDrawing = core.endDrawing;
/// Set background color (framebuffer clear color).
pub const clearBackground = core.clearBackground;

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

// raylib's text module.

/// Draw text (using default font).
pub const drawText = text.drawText;

// raylib's models module.

// raylib's audio module.

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
