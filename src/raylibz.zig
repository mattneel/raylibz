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
