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

/// Load file data as byte array (read)
pub const loadFileData = files.loadFileData;
/// Unload file data allocated by `loadFileData`
pub const unloadFileData = files.unloadFileData;
/// Save data to file from byte array (write), returns true on success
pub const saveFileData = files.saveFileData;
/// Export data to code (.h), returns true on success
pub const exportDataAsCode = files.exportDataAsCode;
/// Load text data from file (read), returns a '\0' terminated string
pub const loadFileText = files.loadFileText;
/// Unload file text data allocated by `loadFileText`
pub const unloadFileText = files.unloadFileText;
/// Save text data to file (write), string must be '\0' terminated, returns true on success
pub const saveFileText = files.saveFileText;
/// Set custom file binary data loader
pub const setLoadFileDataCallback = files.setLoadFileDataCallback;
/// Set custom file binary data saver
pub const setSaveFileDataCallback = files.setSaveFileDataCallback;
/// Set custom file text data loader
pub const setLoadFileTextCallback = files.setLoadFileTextCallback;
/// Set custom file text data saver
pub const setSaveFileTextCallback = files.setSaveFileTextCallback;
/// Rename file (if exists), returns 0 on success
pub const fileRename = files.fileRename;
/// Remove file (if exists), returns 0 on success
pub const fileRemove = files.fileRemove;
/// Copy file from one path to another, dstPath created if it doesn't exist, returns 0 on success
pub const fileCopy = files.fileCopy;
/// Move file from one directory to another, dstPath created if it doesn't exist, returns 0 on success
pub const fileMove = files.fileMove;
/// Replace text in an existing file, returns 0 on success
pub const fileTextReplace = files.fileTextReplace;
/// Find text in existing file, returns -1 if index not found or index otherwise
pub const fileTextFindIndex = files.fileTextFindIndex;
/// Check if file exists
pub const fileExists = files.fileExists;
/// Check if directory path exists
pub const directoryExists = files.directoryExists;
/// Check file extension (recommended include point: .png, .wav)
pub const isFileExtension = files.isFileExtension;
/// Check if file path (file or directory) is hidden by OS
pub const isFileHidden = files.isFileHidden;
/// Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
pub const getFileLength = files.getFileLength;
/// Get file modification time (last write time)
pub const getFileModTime = files.getFileModTime;
/// Get pointer to extension for a filename string (includes dot: '.png')
pub const getFileExtension = files.getFileExtension;
/// Get pointer to filename for a path string
pub const getFileName = files.getFileName;
/// Get filename string without extension (uses static string)
pub const getFileNameWithoutExt = files.getFileNameWithoutExt;
/// Get full path for a provided fileName with path (uses static string)
pub const getDirectoryPath = files.getDirectoryPath;
/// Get previous directory path for a provided path (uses static string)
pub const getPrevDirectoryPath = files.getPrevDirectoryPath;
/// Get current working directory (uses static string)
pub const getWorkingDirectory = files.getWorkingDirectory;
/// Get the directory of the running application (uses static string)
pub const getApplicationDirectory = files.getApplicationDirectory;
/// Create directories (including full path requested), returns 0 on success
pub const makeDirectory = files.makeDirectory;
/// Change working directory, returns 0 on success
pub const changeDirectory = files.changeDirectory;
/// Check if provided path points to a file
pub const isPathFile = files.isPathFile;
/// Check if provided path points to a directory
pub const isPathDirectory = files.isPathDirectory;
/// Check if provided path is an absolute path
pub const isPathAbsolute = files.isPathAbsolute;
/// Check if fileName is valid for the platform/OS
pub const isFileNameValid = files.isFileNameValid;
/// Load directory filepaths, files and directories, no subdirs scan
pub const loadDirectoryFiles = files.loadDirectoryFiles;
/// Load directory filepaths with extension filtering and subdir scan; some filters available: '*.*','FILES*','DIRS*'
pub const loadDirectoryFilesEx = files.loadDirectoryFilesEx;
/// Unload filepaths
pub const unloadDirectoryFiles = files.unloadDirectoryFiles;
/// Check if file has been dropped into window
pub const isFileDropped = files.isFileDropped;
/// Load dropped filepaths
pub const loadDroppedFiles = files.loadDroppedFiles;
/// Unload dropped filepaths
pub const unloadDroppedFiles = files.unloadDroppedFiles;
/// Get the file count in a directory
pub const getDirectoryFileCount = files.getDirectoryFileCount;
/// Get the file count in a directory with extension filtering and recursive directory scan. Use 'DIR' in the filter string to include directories in the result
pub const getDirectoryFileCountEx = files.getDirectoryFileCountEx;
/// Compress data (DEFLATE algorithm), memory must be MemFree()
pub const compressData = files.compressData;
/// Decompress data (DEFLATE algorithm), memory must be MemFree()
pub const decompressData = files.decompressData;
/// Encode data to Base64 string (includes NULL terminator), memory must be MemFree()
pub const encodeDataBase64 = files.encodeDataBase64;
/// Decode Base64 string (expected NULL terminated), memory must be MemFree()
pub const decodeDataBase64 = files.decodeDataBase64;
/// Compute CRC32 hash code
pub const computeCRC32 = files.computeCRC32;
/// Compute MD5 hash code, returns static int[4] (16 bytes)
pub const computeMD5 = files.computeMD5;
/// Compute SHA1 hash code, returns static int[5] (20 bytes)
pub const computeSHA1 = files.computeSHA1;
/// Compute SHA256 hash code, returns static int[8] (32 bytes)
pub const computeSHA256 = files.computeSHA256;
/// Load automation events list from file, NULL for empty list, capacity = MAX_AUTOMATION_EVENTS
pub const loadAutomationEventList = files.loadAutomationEventList;
/// Unload automation events list from file
pub const unloadAutomationEventList = files.unloadAutomationEventList;
/// Export automation events list as text file
pub const exportAutomationEventList = files.exportAutomationEventList;
/// Set automation event list to record to
pub const setAutomationEventList = files.setAutomationEventList;
/// Set automation event internal base frame to start recording
pub const setAutomationEventBaseFrame = files.setAutomationEventBaseFrame;
/// Start recording automation events (AutomationEventList must be set)
pub const startAutomationEventRecording = files.startAutomationEventRecording;
/// Stop recording automation events
pub const stopAutomationEventRecording = files.stopAutomationEventRecording;
/// Play a recorded automation event
pub const playAutomationEvent = files.playAutomationEvent;

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
