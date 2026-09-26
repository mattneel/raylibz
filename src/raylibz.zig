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

// raylib's shapes module.

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
