//! raylib's textures module: image and texture loading, pixel access, rendering
//! to a texture, image manipulation and drawing, and drawing a texture in every
//! shape raylib offers (npatch, nine-patch, billboard, triangles).
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
const Rectangle = types.Rectangle;
const Image = types.Image;
const Texture = types.Texture;
const Texture2D = types.Texture2D;
const TextureCubemap = types.TextureCubemap;
const RenderTexture = types.RenderTexture;
const RenderTexture2D = types.RenderTexture2D;
const NPatchInfo = types.NPatchInfo;
const Font = types.Font;
const Vector2 = @import("vector2.zig").Vector2;
const Vector3 = @import("vector3.zig").Vector3;
const Vector4 = @import("vector4.zig").Vector4;

const PixelFormat = @import("enums.zig").PixelFormat;
const TextureFilter = @import("enums.zig").TextureFilter;
const TextureWrap = @import("enums.zig").TextureWrap;
const CubemapLayout = @import("enums.zig").CubemapLayout;

/// The functions of raylib.h's `textures` section that raylibz does not wrap,
/// and why. One line each.
///
/// Empty: every one of the module's 125 functions is wrapped below.
pub const not_wrapped = [_]cast.NotWrapped{};

// Image loading functions
// NOTE: These functions do not require GPU access

/// Load image from file into CPU memory (RAM)
///
/// raylib's `Image` is checked with `IsImageValid`; a file raylib cannot read
/// or decode becomes `error.LoadFailed`. Release the image with `unloadImage`.
pub fn loadImage(fileName: [:0]const u8) error{LoadFailed}!Image {
    const image = c.LoadImage(cast.cstr(fileName));
    if (!c.IsImageValid(image)) return error.LoadFailed;
    return cast.as(Image, image);
}

/// Load image from RAW file data
///
/// raylib's `int format` is the `PixelFormat` of the raw pixels, and its
/// `int headerSize` is the number of header bytes to skip before them. A file
/// raylib cannot read, or one too short for `width`x`height` pixels, becomes
/// `error.LoadFailed`. Release the image with `unloadImage`.
pub fn loadImageRaw(
    fileName: [:0]const u8,
    width: i32,
    height: i32,
    format: PixelFormat,
    headerSize: i32,
) error{LoadFailed}!Image {
    const image = c.LoadImageRaw(cast.cstr(fileName), width, height, @backingInt(format), headerSize);
    if (!c.IsImageValid(image)) return error.LoadFailed;
    return cast.as(Image, image);
}

/// Load image sequence from file (frames appended to image.data)
///
/// raylib's `int *frames` out-parameter becomes the returned struct's `frames`
/// field: how many frames the image holds, with the first one appended to
/// `image.data` in the GPU-readable layout raylib uses for animated textures. A
/// file raylib cannot read or decode becomes `error.LoadFailed`. Release the
/// image with `unloadImage`.
pub fn loadImageAnim(fileName: [:0]const u8) error{LoadFailed}!struct { image: Image, frames: i32 } {
    var frames: i32 = 0;
    const image = c.LoadImageAnim(cast.cstr(fileName), &frames);
    if (!c.IsImageValid(image)) return error.LoadFailed;
    return .{ .image = cast.as(Image, image), .frames = frames };
}

/// Load image sequence from memory buffer
///
/// raylib's `const char *fileType` is the file extension `fileData` holds
/// (".gif" for an animation), and its `int dataSize` is `fileData`'s length.
/// raylib's `int *frames` out-parameter becomes the returned struct's `frames`
/// field. Data raylib cannot decode becomes `error.LoadFailed`. Release the
/// image with `unloadImage`.
pub fn loadImageAnimFromMemory(
    fileType: [:0]const u8,
    fileData: []const u8,
) error{LoadFailed}!struct { image: Image, frames: i32 } {
    var frames: i32 = 0;
    const image = c.LoadImageAnimFromMemory(cast.cstr(fileType), fileData.ptr, cast.asLen(fileData), &frames);
    if (!c.IsImageValid(image)) return error.LoadFailed;
    return .{ .image = cast.as(Image, image), .frames = frames };
}

/// Load image from memory buffer, fileType refers to extension: i.e. '.png'
///
/// raylib's `const unsigned char *fileData` and `int dataSize` become one
/// slice, `fileData`: raylib reads its length from it. Data raylib cannot
/// decode becomes `error.LoadFailed`. Release the image with `unloadImage`.
pub fn loadImageFromMemory(fileType: [:0]const u8, fileData: []const u8) error{LoadFailed}!Image {
    const image = c.LoadImageFromMemory(cast.cstr(fileType), fileData.ptr, cast.asLen(fileData));
    if (!c.IsImageValid(image)) return error.LoadFailed;
    return cast.as(Image, image);
}

/// Load image from GPU texture data
///
/// Requires an OpenGL context (a window, or a render texture raylib can read
/// back). A texture raylib cannot read becomes `error.LoadFailed`. Release the
/// image with `unloadImage`.
pub fn loadImageFromTexture(texture: Texture2D) error{LoadFailed}!Image {
    const image = c.LoadImageFromTexture(cast.as(c.Texture2D, texture));
    if (!c.IsImageValid(image)) return error.LoadFailed;
    return cast.as(Image, image);
}

/// Load image from screen buffer (screenshot)
///
/// Requires an OpenGL context (a window): the image is the framebuffer as it
/// stands. Release the image with `unloadImage`.
pub fn loadImageFromScreen() error{LoadFailed}!Image {
    const image = c.LoadImageFromScreen();
    if (!c.IsImageValid(image)) return error.LoadFailed;
    return cast.as(Image, image);
}

/// Check if an image is valid (data and parameters)
pub fn isImageValid(image: Image) bool {
    return c.IsImageValid(cast.as(c.Image, image));
}

/// Unload image from CPU memory (RAM)
///
/// Takes ownership of the image's pixel data and releases it; it dies at this
/// call.
pub fn unloadImage(image: Image) void {
    c.UnloadImage(cast.as(c.Image, image));
}

/// Export image data to file, returns true on success
///
/// raylib picks the file format from `fileName`'s extension (".png" by
/// default). `false` means raylib could not write the file.
pub fn exportImage(image: Image, fileName: [:0]const u8) bool {
    return c.ExportImage(cast.as(c.Image, image), cast.cstr(fileName));
}

/// Export image to memory buffer, memory must be MemFree()
///
/// raylib's `unsigned char *` return and `int *fileSize` out-parameter become
/// one slice: its length is the file's size, and `null` is raylib's `NULL`. The
/// buffer is raylib's own allocation: release it with `memFree` (raylib's
/// `MemFree`), not with `unloadFileData`. `fileType` is the file extension to
/// write, e.g. ".png".
pub fn exportImageToMemory(image: Image, fileType: [:0]const u8) ?[]u8 {
    var fileSize: i32 = 0;
    const fileData = c.ExportImageToMemory(cast.as(c.Image, image), cast.cstr(fileType), &fileSize);
    return cast.asSlice(u8, fileData, fileSize);
}

/// Export image as code file defining an array of bytes, returns true on success
///
/// raylib writes a C header at `fileName` holding the image's bytes. `false`
/// means raylib could not write the file.
pub fn exportImageAsCode(image: Image, fileName: [:0]const u8) bool {
    return c.ExportImageAsCode(cast.as(c.Image, image), cast.cstr(fileName));
}

// Image generation functions

/// Generate image: plain color
///
/// Release the image with `unloadImage`.
pub fn genImageColor(width: i32, height: i32, color: Color) Image {
    return cast.as(Image, c.GenImageColor(width, height, cast.as(c.Color, color)));
}

/// Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient
///
/// Release the image with `unloadImage`.
pub fn genImageGradientLinear(width: i32, height: i32, direction: i32, start: Color, end: Color) Image {
    return cast.as(Image, c.GenImageGradientLinear(width, height, direction, cast.as(c.Color, start), cast.as(c.Color, end)));
}

/// Generate image: radial gradient
///
/// Release the image with `unloadImage`.
pub fn genImageGradientRadial(width: i32, height: i32, density: f32, inner: Color, outer: Color) Image {
    return cast.as(Image, c.GenImageGradientRadial(width, height, density, cast.as(c.Color, inner), cast.as(c.Color, outer)));
}

/// Generate image: square gradient
///
/// Release the image with `unloadImage`.
pub fn genImageGradientSquare(width: i32, height: i32, density: f32, inner: Color, outer: Color) Image {
    return cast.as(Image, c.GenImageGradientSquare(width, height, density, cast.as(c.Color, inner), cast.as(c.Color, outer)));
}

/// Generate image: checked
///
/// Release the image with `unloadImage`.
pub fn genImageChecked(width: i32, height: i32, checksX: i32, checksY: i32, col1: Color, col2: Color) Image {
    return cast.as(Image, c.GenImageChecked(width, height, checksX, checksY, cast.as(c.Color, col1), cast.as(c.Color, col2)));
}

/// Generate image: white noise
///
/// Release the image with `unloadImage`.
pub fn genImageWhiteNoise(width: i32, height: i32, factor: f32) Image {
    return cast.as(Image, c.GenImageWhiteNoise(width, height, factor));
}

/// Generate image: perlin noise
///
/// Release the image with `unloadImage`.
pub fn genImagePerlinNoise(width: i32, height: i32, offsetX: i32, offsetY: i32, scale: f32) Image {
    return cast.as(Image, c.GenImagePerlinNoise(width, height, offsetX, offsetY, scale));
}

/// Generate image: cellular algorithm, bigger tileSize means bigger cells
///
/// Release the image with `unloadImage`.
pub fn genImageCellular(width: i32, height: i32, tileSize: i32) Image {
    return cast.as(Image, c.GenImageCellular(width, height, tileSize));
}

/// Generate image: grayscale image from text data
///
/// raylib copies at most `width*height` bytes of `text` into the image's
/// grayscale pixels, so a shorter `text` leaves the rest of the image zeroed.
/// Release the image with `unloadImage`.
pub fn genImageText(width: i32, height: i32, text: [:0]const u8) Image {
    return cast.as(Image, c.GenImageText(width, height, cast.cstr(text)));
}

// Image manipulation functions

/// Create an image duplicate (useful for transformations)
///
/// A new image with its own pixel data, which raylib copies; release it with
/// `unloadImage`. An image raylib cannot copy (no data, no size) comes back
/// with no data of its own.
pub fn imageCopy(image: Image) Image {
    return cast.as(Image, c.ImageCopy(cast.as(c.Image, image)));
}

/// Create an image from another image piece
///
/// A new image with its own pixel data, which raylib copies out of `rec`;
/// release it with `unloadImage`.
pub fn imageFromImage(image: Image, rec: Rectangle) Image {
    return cast.as(Image, c.ImageFromImage(cast.as(c.Image, image), cast.as(c.Rectangle, rec)));
}

/// Create an image from a selected channel of another image (GRAYSCALE)
///
/// `selectedChannel` is 0 for red, 1 for green, 2 for blue and 3 for alpha;
/// raylib clamps a value the image has no channel for. A new image with its own
/// pixel data; release it with `unloadImage`.
pub fn imageFromChannel(image: Image, selectedChannel: i32) Image {
    return cast.as(Image, c.ImageFromChannel(cast.as(c.Image, image), selectedChannel));
}

/// Create an image from text (default font)
///
/// Requires the default font, which raylib prepares when a window is created.
/// A new image with its own pixel data; release it with `unloadImage`.
pub fn imageText(text: [:0]const u8, fontSize: i32, color: Color) Image {
    return cast.as(Image, c.ImageText(cast.cstr(text), fontSize, cast.as(c.Color, color)));
}

/// Create an image from text (custom sprite font)
///
/// A new image with its own pixel data; release it with `unloadImage`.
pub fn imageTextEx(font: Font, text: [:0]const u8, fontSize: f32, spacing: f32, tint: Color) Image {
    return cast.as(Image, c.ImageTextEx(cast.as(c.Font, font), cast.cstr(text), fontSize, spacing, cast.as(c.Color, tint)));
}

/// Convert image data to desired format
///
/// raylib's `int newFormat` is a `PixelFormat`. The image is rewritten in
/// place: its old pixel data is released and its new data is raylib's own.
pub fn imageFormat(image: *Image, newFormat: PixelFormat) void {
    c.ImageFormat(cast.asPtr(c.Image, image), @backingInt(newFormat));
}

/// Convert image to POT (power-of-two)
pub fn imageToPOT(image: *Image, fill: Color) void {
    c.ImageToPOT(cast.asPtr(c.Image, image), cast.as(c.Color, fill));
}

/// Crop an image to a defined rectangle
pub fn imageCrop(image: *Image, crop: Rectangle) void {
    c.ImageCrop(cast.asPtr(c.Image, image), cast.as(c.Rectangle, crop));
}

/// Crop image depending on alpha value
pub fn imageAlphaCrop(image: *Image, threshold: f32) void {
    c.ImageAlphaCrop(cast.asPtr(c.Image, image), threshold);
}

/// Clear alpha channel to desired color
pub fn imageAlphaClear(image: *Image, color: Color, threshold: f32) void {
    c.ImageAlphaClear(cast.asPtr(c.Image, image), cast.as(c.Color, color), threshold);
}

/// Apply alpha mask to image
pub fn imageAlphaMask(image: *Image, alphaMask: Image) void {
    c.ImageAlphaMask(cast.asPtr(c.Image, image), cast.as(c.Image, alphaMask));
}

/// Premultiply alpha channel
pub fn imageAlphaPremultiply(image: *Image) void {
    c.ImageAlphaPremultiply(cast.asPtr(c.Image, image));
}

/// Apply Gaussian blur using a box blur approximation
pub fn imageBlurGaussian(image: *Image, blurSize: i32) void {
    c.ImageBlurGaussian(cast.asPtr(c.Image, image), blurSize);
}

/// Apply custom square convolution kernel to image
///
/// raylib's `const float *kernel` and `int kernelSize` become one slice:
/// `kernelSize` is the slice's length, which raylib requires to be a square
/// (4, 9, 16, ...).
pub fn imageKernelConvolution(image: *Image, kernel: []const f32) void {
    c.ImageKernelConvolution(cast.asPtr(c.Image, image), cast.asArrayPtr(f32, kernel), cast.asLen(kernel));
}

/// Resize image (Bicubic scaling algorithm)
pub fn imageResize(image: *Image, newWidth: i32, newHeight: i32) void {
    c.ImageResize(cast.asPtr(c.Image, image), newWidth, newHeight);
}

/// Resize image (Nearest-Neighbor scaling algorithm)
pub fn imageResizeNN(image: *Image, newWidth: i32, newHeight: i32) void {
    c.ImageResizeNN(cast.asPtr(c.Image, image), newWidth, newHeight);
}

/// Resize canvas and fill with color
pub fn imageResizeCanvas(image: *Image, newWidth: i32, newHeight: i32, offsetX: i32, offsetY: i32, fill: Color) void {
    c.ImageResizeCanvas(cast.asPtr(c.Image, image), newWidth, newHeight, offsetX, offsetY, cast.as(c.Color, fill));
}

/// Compute all mipmap levels for a provided image
pub fn imageMipmaps(image: *Image) void {
    c.ImageMipmaps(cast.asPtr(c.Image, image));
}

/// Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
pub fn imageDither(image: *Image, rBpp: i32, gBpp: i32, bBpp: i32, aBpp: i32) void {
    c.ImageDither(cast.asPtr(c.Image, image), rBpp, gBpp, bBpp, aBpp);
}

/// Flip image vertically
pub fn imageFlipVertical(image: *Image) void {
    c.ImageFlipVertical(cast.asPtr(c.Image, image));
}

/// Flip image horizontally
pub fn imageFlipHorizontal(image: *Image) void {
    c.ImageFlipHorizontal(cast.asPtr(c.Image, image));
}

/// Rotate image by input angle in degrees (-359 to 359)
pub fn imageRotate(image: *Image, degrees: i32) void {
    c.ImageRotate(cast.asPtr(c.Image, image), degrees);
}

/// Rotate image clockwise 90deg
pub fn imageRotateCW(image: *Image) void {
    c.ImageRotateCW(cast.asPtr(c.Image, image));
}

/// Rotate image counter-clockwise 90deg
pub fn imageRotateCCW(image: *Image) void {
    c.ImageRotateCCW(cast.asPtr(c.Image, image));
}

/// Modify image color: tint
pub fn imageColorTint(image: *Image, color: Color) void {
    c.ImageColorTint(cast.asPtr(c.Image, image), cast.as(c.Color, color));
}

/// Modify image color: invert
pub fn imageColorInvert(image: *Image) void {
    c.ImageColorInvert(cast.asPtr(c.Image, image));
}

/// Modify image color: grayscale
pub fn imageColorGrayscale(image: *Image) void {
    c.ImageColorGrayscale(cast.asPtr(c.Image, image));
}

/// Modify image color: contrast (-100 to 100)
pub fn imageColorContrast(image: *Image, contrast: i32) void {
    c.ImageColorContrast(cast.asPtr(c.Image, image), contrast);
}

/// Modify image color: brightness (-255 to 255)
pub fn imageColorBrightness(image: *Image, brightness: i32) void {
    c.ImageColorBrightness(cast.asPtr(c.Image, image), brightness);
}

/// Modify image color: replace color
pub fn imageColorReplace(image: *Image, color: Color, replace: Color) void {
    c.ImageColorReplace(cast.asPtr(c.Image, image), cast.as(c.Color, color), cast.as(c.Color, replace));
}

/// Load color data from image as a Color array (RGBA - 32bit)
///
/// raylib's `Color *` return and the count it implies become one slice: the
/// image's `width*height` pixels, row by row from the top, as RGBA colours, and
/// `null` is raylib's `NULL` (an image with no size). The colours are raylib's
/// own allocation: release them with `unloadImageColors`.
pub fn loadImageColors(image: Image) ?[]Color {
    const colors = c.LoadImageColors(cast.as(c.Image, image));
    if (colors == null) return null;
    const pixels: [*]Color = @ptrCast(colors);
    return pixels[0..@intCast(image.width * image.height)];
}

/// Load colors palette from image as a Color array (RGBA - 32bit)
///
/// raylib's `Color *` return and its `int *colorCount` out-parameter become one
/// slice: `colorCount` is the slice's length, and `null` is raylib's `NULL` (an
/// image with no size). At most `maxPaletteSize` colours come back, opaque ones
/// first seen, and transparent pixels are skipped. The colours are raylib's own
/// allocation: release them with `unloadImagePalette`.
pub fn loadImagePalette(image: Image, maxPaletteSize: i32) ?[]Color {
    var colorCount: i32 = 0;
    const colors = c.LoadImagePalette(cast.as(c.Image, image), maxPaletteSize, &colorCount);
    if (colors == null) return null;
    const palette: [*]Color = @ptrCast(colors);
    return palette[0..@intCast(colorCount)];
}

/// Unload color data loaded with LoadImageColors()
///
/// Takes ownership of the colours `loadImageColors` returned and releases them;
/// they die at this call.
pub fn unloadImageColors(colors: []Color) void {
    c.UnloadImageColors(@ptrCast(colors.ptr));
}

/// Unload colors palette loaded with LoadImagePalette()
///
/// Takes ownership of the palette `loadImagePalette` returned and releases it;
/// it dies at this call.
pub fn unloadImagePalette(colors: []Color) void {
    c.UnloadImagePalette(@ptrCast(colors.ptr));
}

/// Get image alpha border rectangle
pub fn getImageAlphaBorder(image: Image, threshold: f32) Rectangle {
    return cast.as(Rectangle, c.GetImageAlphaBorder(cast.as(c.Image, image), threshold));
}

/// Get image pixel color at (x, y) position
///
/// A position outside the image comes back as raylib's zeroed colour, `Color.blank`.
pub fn getImageColor(image: Image, x: i32, y: i32) Color {
    return cast.as(Color, c.GetImageColor(cast.as(c.Image, image), x, y));
}

// Image drawing functions
// NOTE: Image software-rendering functions (CPU)

/// Clear image background with provided color
pub fn imageClearBackground(dst: *Image, color: Color) void {
    c.ImageClearBackground(cast.asPtr(c.Image, dst), cast.as(c.Color, color));
}

/// Draw pixel within an image
pub fn imageDrawPixel(dst: *Image, posX: i32, posY: i32, color: Color) void {
    c.ImageDrawPixel(cast.asPtr(c.Image, dst), posX, posY, cast.as(c.Color, color));
}

/// Draw pixel within an image (Vector version)
pub fn imageDrawPixelV(dst: *Image, position: Vector2, color: Color) void {
    c.ImageDrawPixelV(cast.asPtr(c.Image, dst), cast.as(c.Vector2, position), cast.as(c.Color, color));
}

/// Draw line within an image
pub fn imageDrawLine(dst: *Image, startPosX: i32, startPosY: i32, endPosX: i32, endPosY: i32, color: Color) void {
    c.ImageDrawLine(cast.asPtr(c.Image, dst), startPosX, startPosY, endPosX, endPosY, cast.as(c.Color, color));
}

/// Draw line within an image (Vector version)
pub fn imageDrawLineV(dst: *Image, start: Vector2, end: Vector2, color: Color) void {
    c.ImageDrawLineV(cast.asPtr(c.Image, dst), cast.as(c.Vector2, start), cast.as(c.Vector2, end), cast.as(c.Color, color));
}

/// Draw a line defining thickness within an image
pub fn imageDrawLineEx(dst: *Image, start: Vector2, end: Vector2, thick: i32, color: Color) void {
    c.ImageDrawLineEx(cast.asPtr(c.Image, dst), cast.as(c.Vector2, start), cast.as(c.Vector2, end), thick, cast.as(c.Color, color));
}

/// Draw a lines sequence within an image
///
/// raylib's `const Vector2 *points` and `int pointCount` become one slice:
/// `pointCount` is the slice's length.
pub fn imageDrawLineStrip(dst: *Image, points: []const Vector2, color: Color) void {
    c.ImageDrawLineStrip(cast.asPtr(c.Image, dst), cast.asArrayPtr(c.Vector2, points), cast.asLen(points), cast.as(c.Color, color));
}

/// Draw triangle within an image
pub fn imageDrawTriangle(dst: *Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) void {
    c.ImageDrawTriangle(cast.asPtr(c.Image, dst), cast.as(c.Vector2, v1), cast.as(c.Vector2, v2), cast.as(c.Vector2, v3), cast.as(c.Color, color));
}

/// Draw triangle with interpolated colors within an image
pub fn imageDrawTriangleGradient(dst: *Image, v1: Vector2, v2: Vector2, v3: Vector2, c1: Color, c2: Color, c3: Color) void {
    c.ImageDrawTriangleGradient(
        cast.asPtr(c.Image, dst),
        cast.as(c.Vector2, v1),
        cast.as(c.Vector2, v2),
        cast.as(c.Vector2, v3),
        cast.as(c.Color, c1),
        cast.as(c.Color, c2),
        cast.as(c.Color, c3),
    );
}

/// Draw triangle outline within an image
pub fn imageDrawTriangleLines(dst: *Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) void {
    c.ImageDrawTriangleLines(cast.asPtr(c.Image, dst), cast.as(c.Vector2, v1), cast.as(c.Vector2, v2), cast.as(c.Vector2, v3), cast.as(c.Color, color));
}

/// Draw a triangle fan defined by points within an image (first vertex is the center)
///
/// raylib's `const Vector2 *points` and `int pointCount` become one slice:
/// `pointCount` is the slice's length.
pub fn imageDrawTriangleFan(dst: *Image, points: []const Vector2, color: Color) void {
    c.ImageDrawTriangleFan(cast.asPtr(c.Image, dst), cast.asArrayPtr(c.Vector2, points), cast.asLen(points), cast.as(c.Color, color));
}

/// Draw a triangle strip defined by points within an image
///
/// raylib's `const Vector2 *points` and `int pointCount` become one slice:
/// `pointCount` is the slice's length.
pub fn imageDrawTriangleStrip(dst: *Image, points: []const Vector2, color: Color) void {
    c.ImageDrawTriangleStrip(cast.asPtr(c.Image, dst), cast.asArrayPtr(c.Vector2, points), cast.asLen(points), cast.as(c.Color, color));
}

/// Draw rectangle within an image
pub fn imageDrawRectangle(dst: *Image, posX: i32, posY: i32, width: i32, height: i32, color: Color) void {
    c.ImageDrawRectangle(cast.asPtr(c.Image, dst), posX, posY, width, height, cast.as(c.Color, color));
}

/// Draw rectangle within an image (Vector version)
pub fn imageDrawRectangleV(dst: *Image, position: Vector2, size: Vector2, color: Color) void {
    c.ImageDrawRectangleV(cast.asPtr(c.Image, dst), cast.as(c.Vector2, position), cast.as(c.Vector2, size), cast.as(c.Color, color));
}

/// Draw rectangle within an image
pub fn imageDrawRectangleRec(dst: *Image, rec: Rectangle, color: Color) void {
    c.ImageDrawRectangleRec(cast.asPtr(c.Image, dst), cast.as(c.Rectangle, rec), cast.as(c.Color, color));
}

/// Draw a color-filled rectangle with pro parameters within and image
pub fn imageDrawRectanglePro(dst: *Image, rec: Rectangle, origin: Vector2, rotation: f32, color: Color) void {
    c.ImageDrawRectanglePro(cast.asPtr(c.Image, dst), cast.as(c.Rectangle, rec), cast.as(c.Vector2, origin), rotation, cast.as(c.Color, color));
}

/// Draw rectangle lines within an image
pub fn imageDrawRectangleLines(dst: *Image, posX: i32, posY: i32, width: i32, height: i32, color: Color) void {
    c.ImageDrawRectangleLines(cast.asPtr(c.Image, dst), posX, posY, width, height, cast.as(c.Color, color));
}

/// Draw rectangle lines within an image with line thickness
pub fn imageDrawRectangleLinesEx(dst: *Image, rec: Rectangle, thick: i32, color: Color) void {
    c.ImageDrawRectangleLinesEx(cast.asPtr(c.Image, dst), cast.as(c.Rectangle, rec), thick, cast.as(c.Color, color));
}

/// Draw rectangle with gradient colors within an image, counter-clockwise color order
pub fn imageDrawRectangleGradientEx(dst: *Image, rec: Rectangle, col1: Color, col2: Color, col3: Color, col4: Color) void {
    c.ImageDrawRectangleGradientEx(
        cast.asPtr(c.Image, dst),
        cast.as(c.Rectangle, rec),
        cast.as(c.Color, col1),
        cast.as(c.Color, col2),
        cast.as(c.Color, col3),
        cast.as(c.Color, col4),
    );
}

/// Draw a filled circle within an image
pub fn imageDrawCircle(dst: *Image, centerX: i32, centerY: i32, radius: i32, color: Color) void {
    c.ImageDrawCircle(cast.asPtr(c.Image, dst), centerX, centerY, radius, cast.as(c.Color, color));
}

/// Draw a filled circle within an image (Vector version)
pub fn imageDrawCircleV(dst: *Image, center: Vector2, radius: i32, color: Color) void {
    c.ImageDrawCircleV(cast.asPtr(c.Image, dst), cast.as(c.Vector2, center), radius, cast.as(c.Color, color));
}

/// Draw circle outline within an image
pub fn imageDrawCircleLines(dst: *Image, centerX: i32, centerY: i32, radius: i32, color: Color) void {
    c.ImageDrawCircleLines(cast.asPtr(c.Image, dst), centerX, centerY, radius, cast.as(c.Color, color));
}

/// Draw circle outline within an image (Vector version)
pub fn imageDrawCircleLinesV(dst: *Image, center: Vector2, radius: i32, color: Color) void {
    c.ImageDrawCircleLinesV(cast.asPtr(c.Image, dst), cast.as(c.Vector2, center), radius, cast.as(c.Color, color));
}

/// Draw a gradient-filled circle within an image
pub fn imageDrawCircleGradient(dst: *Image, center: Vector2, radius: f32, inner: Color, outer: Color) void {
    c.ImageDrawCircleGradient(cast.asPtr(c.Image, dst), cast.as(c.Vector2, center), radius, cast.as(c.Color, inner), cast.as(c.Color, outer));
}

/// Draw an image within an image
pub fn imageDrawImage(dst: *Image, src: Image, posX: i32, posY: i32, tint: Color) void {
    c.ImageDrawImage(cast.asPtr(c.Image, dst), cast.as(c.Image, src), posX, posY, cast.as(c.Color, tint));
}

/// Draw an image with scaling and rotation within an image
pub fn imageDrawImageEx(dst: *Image, src: Image, position: Vector2, rotation: f32, scale: f32, tint: Color) void {
    c.ImageDrawImageEx(cast.asPtr(c.Image, dst), cast.as(c.Image, src), cast.as(c.Vector2, position), rotation, scale, cast.as(c.Color, tint));
}

/// Draw a part of an image defined by a rectangle within an image
pub fn imageDrawImageRec(dst: *Image, src: Image, srcRec: Rectangle, position: Vector2, tint: Color) void {
    c.ImageDrawImageRec(cast.asPtr(c.Image, dst), cast.as(c.Image, src), cast.as(c.Rectangle, srcRec), cast.as(c.Vector2, position), cast.as(c.Color, tint));
}

/// Draw a part of an image defined by a rectangle into destination rectangle, with scaling and rotation, within an image
pub fn imageDrawImagePro(
    dst: *Image,
    src: Image,
    srcRec: Rectangle,
    dstRec: Rectangle,
    origin: Vector2,
    rotation: f32,
    tint: Color,
) void {
    c.ImageDrawImagePro(
        cast.asPtr(c.Image, dst),
        cast.as(c.Image, src),
        cast.as(c.Rectangle, srcRec),
        cast.as(c.Rectangle, dstRec),
        cast.as(c.Vector2, origin),
        rotation,
        cast.as(c.Color, tint),
    );
}

/// Draw text (using default font) within an image (destination)
///
/// Requires the default font, which raylib prepares when a window is created.
pub fn imageDrawText(dst: *Image, text: [:0]const u8, posX: i32, posY: i32, fontSize: i32, color: Color) void {
    c.ImageDrawText(cast.asPtr(c.Image, dst), cast.cstr(text), posX, posY, fontSize, cast.as(c.Color, color));
}

/// Draw text (custom sprite font) within an image (destination)
pub fn imageDrawTextEx(dst: *Image, font: Font, text: [:0]const u8, position: Vector2, fontSize: f32, spacing: f32, tint: Color) void {
    c.ImageDrawTextEx(
        cast.asPtr(c.Image, dst),
        cast.as(c.Font, font),
        cast.cstr(text),
        cast.as(c.Vector2, position),
        fontSize,
        spacing,
        cast.as(c.Color, tint),
    );
}

/// Draw text using Font and pro parameters (rotation)
pub fn imageDrawTextPro(
    dst: *Image,
    font: Font,
    text: [:0]const u8,
    position: Vector2,
    origin: Vector2,
    rotation: f32,
    fontSize: f32,
    spacing: f32,
    tint: Color,
) void {
    c.ImageDrawTextPro(
        cast.asPtr(c.Image, dst),
        cast.as(c.Font, font),
        cast.cstr(text),
        cast.as(c.Vector2, position),
        cast.as(c.Vector2, origin),
        rotation,
        fontSize,
        spacing,
        cast.as(c.Color, tint),
    );
}

// Texture loading functions
// NOTE: These functions require GPU access

/// Load texture from file into GPU memory (VRAM)
///
/// Requires an OpenGL context (a window). raylib's `Texture2D` is checked with
/// `IsTextureValid`; a file raylib cannot read or upload becomes
/// `error.LoadFailed`. Release the texture with `unloadTexture`.
pub fn loadTexture(fileName: [:0]const u8) error{LoadFailed}!Texture2D {
    const texture = c.LoadTexture(cast.cstr(fileName));
    if (!c.IsTextureValid(texture)) return error.LoadFailed;
    return cast.as(Texture, texture);
}

/// Load texture from image data
///
/// Requires an OpenGL context (a window). raylib uploads the image's pixels and
/// leaves the image the caller's to release. An image raylib cannot upload
/// becomes `error.LoadFailed`. Release the texture with `unloadTexture`.
pub fn loadTextureFromImage(image: Image) error{LoadFailed}!Texture2D {
    const texture = c.LoadTextureFromImage(cast.as(c.Image, image));
    if (!c.IsTextureValid(texture)) return error.LoadFailed;
    return cast.as(Texture, texture);
}

/// Load cubemap from image, multiple image cubemap layouts supported
///
/// Requires an OpenGL context (a window). raylib's `int layout` is a
/// `CubemapLayout`. An image raylib cannot upload becomes `error.LoadFailed`.
/// Release the cubemap with `unloadTexture`.
pub fn loadTextureCubemap(image: Image, layout: CubemapLayout) error{LoadFailed}!TextureCubemap {
    const texture = c.LoadTextureCubemap(cast.as(c.Image, image), @backingInt(layout));
    if (!c.IsTextureValid(texture)) return error.LoadFailed;
    return cast.as(Texture, texture);
}

/// Load texture for rendering (framebuffer)
///
/// Requires an OpenGL context (a window). raylib's `RenderTexture2D` is checked
/// with `IsRenderTextureValid`; a framebuffer raylib cannot create becomes
/// `error.LoadFailed`. Release it with `unloadRenderTexture`.
pub fn loadRenderTexture(width: i32, height: i32) error{LoadFailed}!RenderTexture2D {
    const target = c.LoadRenderTexture(width, height);
    if (!c.IsRenderTextureValid(target)) return error.LoadFailed;
    return cast.as(RenderTexture, target);
}

/// Load texture for rendering (framebuffer), with specific format
///
/// Requires an OpenGL context (a window). raylib's `int format` is the
/// `PixelFormat` of the colour buffer. A framebuffer raylib cannot create
/// becomes `error.LoadFailed`. Release it with `unloadRenderTexture`.
pub fn loadRenderTextureEx(width: i32, height: i32, format: PixelFormat) error{LoadFailed}!RenderTexture2D {
    const target = c.LoadRenderTextureEx(width, height, @backingInt(format));
    if (!c.IsRenderTextureValid(target)) return error.LoadFailed;
    return cast.as(RenderTexture, target);
}

/// Check if texture is valid (loaded in GPU)
pub fn isTextureValid(texture: Texture2D) bool {
    return c.IsTextureValid(cast.as(c.Texture2D, texture));
}

/// Unload texture from GPU memory (VRAM)
///
/// Takes ownership of the texture and releases it from the GPU; it dies at this
/// call. Requires an OpenGL context.
pub fn unloadTexture(texture: Texture2D) void {
    c.UnloadTexture(cast.as(c.Texture2D, texture));
}

/// Check if render texture is valid (loaded in GPU)
pub fn isRenderTextureValid(target: RenderTexture2D) bool {
    return c.IsRenderTextureValid(cast.as(c.RenderTexture2D, target));
}

/// Unload render texture from GPU memory (VRAM)
///
/// Takes ownership of the render texture and releases its framebuffer and both
/// attachment textures; they die at this call. Requires an OpenGL context.
pub fn unloadRenderTexture(target: RenderTexture2D) void {
    c.UnloadRenderTexture(cast.as(c.RenderTexture2D, target));
}

/// Update GPU texture with new data (pixels should be able to fill texture)
///
/// raylib's `const void *pixels` stays a pointer: how much of it raylib reads is
/// the texture's own size and format, not something a slice could say. It must
/// point at `width*height` pixels in the texture's format. Requires an OpenGL
/// context.
pub fn updateTexture(texture: Texture2D, pixels: *const anyopaque) void {
    c.UpdateTexture(cast.as(c.Texture2D, texture), pixels);
}

/// Update GPU texture rectangle with new data (pixels and rec should fit in texture)
///
/// raylib's `const void *pixels` stays a pointer: how much of it raylib reads is
/// `rec` and the texture's format, not something a slice could say. It must
/// point at `rec.width*rec.height` pixels in the texture's format. Requires an
/// OpenGL context.
pub fn updateTextureRec(texture: Texture2D, rec: Rectangle, pixels: *const anyopaque) void {
    c.UpdateTextureRec(cast.as(c.Texture2D, texture), cast.as(c.Rectangle, rec), pixels);
}

// Texture configuration functions

/// Generate GPU mipmaps for a texture
///
/// Requires an OpenGL context. The texture is updated in place, and raylib
/// records the new mipmap level count in `texture.mipmaps`.
pub fn genTextureMipmaps(texture: *Texture2D) void {
    c.GenTextureMipmaps(cast.asPtr(c.Texture2D, texture));
}

/// Set texture scaling filter mode
///
/// raylib's `int filter` is a `TextureFilter`. Requires an OpenGL context.
pub fn setTextureFilter(texture: Texture2D, filter: TextureFilter) void {
    c.SetTextureFilter(cast.as(c.Texture2D, texture), @backingInt(filter));
}

/// Set texture wrapping mode
///
/// raylib's `int wrap` is a `TextureWrap`. Requires an OpenGL context.
pub fn setTextureWrap(texture: Texture2D, wrap: TextureWrap) void {
    c.SetTextureWrap(cast.as(c.Texture2D, texture), @backingInt(wrap));
}

// Texture drawing functions
// NOTE: These functions require an OpenGL context (a window, or a render
// texture raylib is drawing into).

/// Draw a Texture2D
pub fn drawTexture(texture: Texture2D, posX: i32, posY: i32, tint: Color) void {
    c.DrawTexture(cast.as(c.Texture2D, texture), posX, posY, cast.as(c.Color, tint));
}

/// Draw a Texture2D with position defined as Vector2
pub fn drawTextureV(texture: Texture2D, position: Vector2, tint: Color) void {
    c.DrawTextureV(cast.as(c.Texture2D, texture), cast.as(c.Vector2, position), cast.as(c.Color, tint));
}

/// Draw a Texture2D with rotation and scale
pub fn drawTextureEx(texture: Texture2D, position: Vector2, rotation: f32, scale: f32, tint: Color) void {
    c.DrawTextureEx(cast.as(c.Texture2D, texture), cast.as(c.Vector2, position), rotation, scale, cast.as(c.Color, tint));
}

/// Draw a part of a texture defined by a rectangle
pub fn drawTextureRec(texture: Texture2D, rec: Rectangle, position: Vector2, tint: Color) void {
    c.DrawTextureRec(cast.as(c.Texture2D, texture), cast.as(c.Rectangle, rec), cast.as(c.Vector2, position), cast.as(c.Color, tint));
}

/// Draw a part of a texture defined by a source rectangle to destination rectangle, with scaling and rotation
pub fn drawTexturePro(texture: Texture2D, srcrec: Rectangle, dstrec: Rectangle, origin: Vector2, rotation: f32, tint: Color) void {
    c.DrawTexturePro(
        cast.as(c.Texture2D, texture),
        cast.as(c.Rectangle, srcrec),
        cast.as(c.Rectangle, dstrec),
        cast.as(c.Vector2, origin),
        rotation,
        cast.as(c.Color, tint),
    );
}

/// Draw a texture (or part of it) that stretches or shrinks nicely
pub fn drawTextureNPatch(texture: Texture2D, nPatchInfo: NPatchInfo, dstrec: Rectangle, origin: Vector2, rotation: f32, tint: Color) void {
    c.DrawTextureNPatch(
        cast.as(c.Texture2D, texture),
        cast.as(c.NPatchInfo, nPatchInfo),
        cast.as(c.Rectangle, dstrec),
        cast.as(c.Vector2, origin),
        rotation,
        cast.as(c.Color, tint),
    );
}

// Color/pixel related functions

/// Check if two colors are equal
pub fn colorIsEqual(col1: Color, col2: Color) bool {
    return c.ColorIsEqual(cast.as(c.Color, col1), cast.as(c.Color, col2));
}

/// Get color with alpha applied, alpha goes from 0.0f to 1.0f
pub fn fade(color: Color, alpha: f32) Color {
    return cast.as(Color, c.Fade(cast.as(c.Color, color), alpha));
}

/// Get hexadecimal value for a Color (0xRRGGBBAA)
pub fn colorToInt(color: Color) i32 {
    return c.ColorToInt(cast.as(c.Color, color));
}

/// Get Color normalized as float [0..1]
pub fn colorNormalize(color: Color) Vector4 {
    return cast.as(Vector4, c.ColorNormalize(cast.as(c.Color, color)));
}

/// Get Color from normalized values [0..1]
pub fn colorFromNormalized(normalized: Vector4) Color {
    return cast.as(Color, c.ColorFromNormalized(cast.as(c.Vector4, normalized)));
}

/// Get HSV values for a Color, hue [0..360], saturation/value [0..1]
pub fn colorToHSV(color: Color) Vector3 {
    return cast.as(Vector3, c.ColorToHSV(cast.as(c.Color, color)));
}

/// Get a Color from HSV values, hue [0..360], saturation/value [0..1]
pub fn colorFromHSV(hue: f32, saturation: f32, value: f32) Color {
    return cast.as(Color, c.ColorFromHSV(hue, saturation, value));
}

/// Get color multiplied with another color
pub fn colorTint(color: Color, tint: Color) Color {
    return cast.as(Color, c.ColorTint(cast.as(c.Color, color), cast.as(c.Color, tint)));
}

/// Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
pub fn colorBrightness(color: Color, factor: f32) Color {
    return cast.as(Color, c.ColorBrightness(cast.as(c.Color, color), factor));
}

/// Get color with contrast correction, contrast values between -1.0f and 1.0f
pub fn colorContrast(color: Color, contrast: f32) Color {
    return cast.as(Color, c.ColorContrast(cast.as(c.Color, color), contrast));
}

/// Get color with alpha applied, alpha goes from 0.0f to 1.0f
pub fn colorAlpha(color: Color, alpha: f32) Color {
    return cast.as(Color, c.ColorAlpha(cast.as(c.Color, color), alpha));
}

/// Get src alpha-blended into dst color with tint
pub fn colorAlphaBlend(dst: Color, src: Color, tint: Color) Color {
    return cast.as(Color, c.ColorAlphaBlend(cast.as(c.Color, dst), cast.as(c.Color, src), cast.as(c.Color, tint)));
}

/// Get color lerp interpolation between two colors, factor [0.0f..1.0f]
pub fn colorLerp(color1: Color, color2: Color, factor: f32) Color {
    return cast.as(Color, c.ColorLerp(cast.as(c.Color, color1), cast.as(c.Color, color2), factor));
}

/// Get Color structure from hexadecimal value
///
/// raylib's `unsigned int hexValue` is the usual 0xRRGGBBAA layout.
pub fn getColor(hexValue: u32) Color {
    return cast.as(Color, c.GetColor(hexValue));
}

/// Get Color from a source pixel pointer of certain format
///
/// raylib's `const void *srcPtr` stays a pointer: how much of it raylib reads
/// is `format` alone, not something a slice could say.
pub fn getPixelColor(srcPtr: *const anyopaque, format: PixelFormat) Color {
    return cast.as(Color, c.GetPixelColor(srcPtr, @backingInt(format)));
}

/// Set color formatted into destination pixel pointer
///
/// raylib's `void *dstPtr` stays a pointer: how much of it raylib writes is
/// `format` alone, not something a slice could say.
pub fn setPixelColor(dstPtr: *anyopaque, color: Color, format: PixelFormat) void {
    c.SetPixelColor(dstPtr, cast.as(c.Color, color), @backingInt(format));
}

/// Get pixel data size in bytes for certain format
///
/// raylib's `int format` is a `PixelFormat`.
pub fn getPixelDataSize(width: i32, height: i32, format: PixelFormat) i32 {
    return c.GetPixelDataSize(width, height, @backingInt(format));
}

// Tests
//
// The image functions that need no window and no audio device are called here
// against raylib's own implementation: the format and size conversions, the
// slice the image's pixel data becomes, the palette's count, the export/import
// round trip, and the colour conversions. The texture functions need an OpenGL
// context, so `zig build run-texture` is where they are exercised.

/// Only the tests below need these: the wrappers themselves allocate nothing
/// and call nothing but raylib.
const internal = struct {
    const std = @import("std");

    /// raylib's TraceLog writes to stdout, which under `zig build test` is the
    /// build runner's own protocol pipe: a test that lets raylib log hangs the
    /// build. Every test here that calls a raylib function that can log starts
    /// with this and puts the level back when it ends.
    fn silenceLog() void {
        c.SetTraceLogLevel(c.LOG_NONE);
    }

    /// raylib's level as it was found: its own default, `LOG_INFO`.
    fn restoreLog() void {
        c.SetTraceLogLevel(c.LOG_INFO);
    }
};

test "genImageColor: the image and its colours are the ones raylib builds" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    const image = genImageColor(8, 4, Color.red);
    defer unloadImage(image);

    try std.testing.expect(isImageValid(image));
    try std.testing.expectEqual(@as(i32, 8), image.width);
    try std.testing.expectEqual(@as(i32, 4), image.height);
    try std.testing.expectEqual(PixelFormat.pixelformat_uncompressed_r8g8b8a8, image.format);

    const colors = loadImageColors(image) orelse return error.TestUnexpectedResult;
    defer unloadImageColors(colors);
    try std.testing.expectEqual(@as(usize, 32), colors.len);
    for (colors) |color| try std.testing.expect(colorIsEqual(color, Color.red));

    try std.testing.expect(colorIsEqual(getImageColor(image, 7, 3), Color.red));
    // A position outside the image is raylib's zeroed colour, not `Color.black`.
    try std.testing.expect(colorIsEqual(getImageColor(image, 8, 3), Color.blank));
}

test "genImageText: text bytes become grayscale pixels" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    const image = genImageText(4, 2, "abcdefgh");
    defer unloadImage(image);

    try std.testing.expectEqual(PixelFormat.pixelformat_uncompressed_grayscale, image.format);
    const colors = loadImageColors(image) orelse return error.TestUnexpectedResult;
    defer unloadImageColors(colors);
    try std.testing.expectEqual(@as(usize, 8), colors.len);
    for (colors, 0..) |color, index| {
        const value: u8 = 'a' + @as(u8, @intCast(index));
        try std.testing.expectEqual(Color{ .r = value, .g = value, .b = value, .a = 255 }, color);
    }
}

test "imageResize, imageCrop and imageFlipVertical change the image in place" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    var image = genImageColor(4, 4, Color.red);
    defer unloadImage(image);

    imageResize(&image, 8, 2);
    try std.testing.expectEqual(@as(i32, 8), image.width);
    try std.testing.expectEqual(@as(i32, 2), image.height);

    imageCrop(&image, .{ .x = 1, .y = 0, .width = 2, .height = 2 });
    try std.testing.expectEqual(@as(i32, 2), image.width);
    try std.testing.expectEqual(@as(i32, 2), image.height);
    try std.testing.expect(colorIsEqual(getImageColor(image, 1, 1), Color.red));

    imageDrawRectangle(&image, 0, 1, 2, 1, Color.blue); // Bottom row blue.
    imageFlipVertical(&image);
    try std.testing.expect(colorIsEqual(getImageColor(image, 0, 0), Color.blue)); // It is the top row now.
    try std.testing.expect(colorIsEqual(getImageColor(image, 0, 1), Color.red));
}

test "imageDrawLineStrip: the slice is the point list raylib walks" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    var image = genImageColor(8, 8, Color.black);
    defer unloadImage(image);

    imageDrawLineStrip(&image, &.{
        Vector2{ .x = 1, .y = 1 },
        Vector2{ .x = 6, .y = 1 },
        Vector2{ .x = 6, .y = 6 },
    }, Color.white);

    try std.testing.expect(colorIsEqual(getImageColor(image, 6, 3), Color.white));
    try std.testing.expect(colorIsEqual(getImageColor(image, 1, 1), Color.white));
    try std.testing.expect(colorIsEqual(getImageColor(image, 0, 7), Color.black));
}

test "loadImagePalette: the slice is the colours raylib counted" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    const image = genImageChecked(8, 8, 4, 4, Color.red, Color.blue);
    defer unloadImage(image);

    const palette = loadImagePalette(image, 8) orelse return error.TestUnexpectedResult;
    defer unloadImagePalette(palette);

    try std.testing.expectEqual(@as(usize, 2), palette.len);
    var red_found = false;
    var blue_found = false;
    for (palette) |color| {
        if (colorIsEqual(color, Color.red)) red_found = true;
        if (colorIsEqual(color, Color.blue)) blue_found = true;
    }
    try std.testing.expect(red_found and blue_found);
}

test "exportImageToMemory round trips through loadImageFromMemory" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    const image = genImageChecked(16, 16, 4, 4, Color.red, Color.gold);
    defer unloadImage(image);

    const bytes = exportImageToMemory(image, ".png") orelse return error.TestUnexpectedResult;
    defer c.MemFree(bytes.ptr); // raylib's docs: the buffer is MemFree()'s, not unloadFileData's.
    try std.testing.expect(bytes.len > 0);

    const reloaded = try loadImageFromMemory(".png", bytes);
    defer unloadImage(reloaded);
    try std.testing.expectEqual(image.width, reloaded.width);
    try std.testing.expectEqual(image.height, reloaded.height);
    try std.testing.expectEqual(image.format, reloaded.format);

    const before = loadImageColors(image) orelse return error.TestUnexpectedResult;
    defer unloadImageColors(before);
    const after = loadImageColors(reloaded) orelse return error.TestUnexpectedResult;
    defer unloadImageColors(after);
    try std.testing.expectEqualSlices(Color, before, after);

    try std.testing.expectError(error.LoadFailed, loadImageFromMemory(".png", "not a png at all"));
    try std.testing.expectError(error.LoadFailed, loadImage("no/such/image.png"));
}

test "loadImageAnim's frames struct: a still image is one frame" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    // std.testing.tmpDir makes `.zig-cache/tmp/<random>` under the working
    // directory, so that relative path is the same file `tmp.dir` holds.
    var path_buffer: [160]u8 = undefined;
    const path_plain = try std.fmt.bufPrint(&path_buffer, ".zig-cache/tmp/{s}/textures.png", .{tmp.sub_path[0..]});
    path_buffer[path_plain.len] = 0;
    const path: [:0]const u8 = path_buffer[0..path_plain.len :0];

    const image = genImageChecked(8, 8, 2, 2, Color.red, Color.gold);
    defer unloadImage(image);
    try std.testing.expect(exportImage(image, path));

    const from_file = try loadImage(path);
    defer unloadImage(from_file);
    try std.testing.expectEqual(image.width, from_file.width);
    try std.testing.expectEqual(image.height, from_file.height);

    // raylib's LoadImageAnim falls back to LoadImage for a still image, and
    // counts the frames it appended: one.
    const animation = try loadImageAnim(path);
    defer unloadImage(animation.image);
    try std.testing.expectEqual(@as(i32, 1), animation.frames);
    try std.testing.expectEqual(@as(i32, 8), animation.image.width);
    try std.testing.expect(colorIsEqual(getImageColor(animation.image, 0, 0), Color.red));

    // The same bytes through the memory loader, whose dataSize is the slice's
    // length.
    const bytes = exportImageToMemory(image, ".png") orelse return error.TestUnexpectedResult;
    defer c.MemFree(bytes.ptr);
    const from_memory = try loadImageAnimFromMemory(".png", bytes);
    defer unloadImage(from_memory.image);
    try std.testing.expectEqual(@as(i32, 1), from_memory.frames);
    try std.testing.expectEqual(@as(i32, 8), from_memory.image.height);
}

test "getPixelDataSize: raylib's byte counts for a format" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    const rgba: PixelFormat = .pixelformat_uncompressed_r8g8b8a8;
    try std.testing.expectEqual(@as(i32, 4 * 4 * 4), getPixelDataSize(4, 4, rgba));
    try std.testing.expectEqual(@as(i32, 16), getPixelDataSize(4, 4, .pixelformat_uncompressed_grayscale));
    try std.testing.expectEqual(@as(i32, 4 * 4 * 2), getPixelDataSize(4, 4, .pixelformat_uncompressed_r5g6b5));
    try std.testing.expectEqual(@as(i32, 4 * 4 * 4), getPixelDataSize(4, 4, .pixelformat_uncompressed_r32));

    // Compressed formats work in 4x4 blocks: the smallest image costs one block.
    try std.testing.expectEqual(@as(i32, 8), getPixelDataSize(4, 4, .pixelformat_compressed_dxt1_rgb));
    try std.testing.expectEqual(@as(i32, 8), getPixelDataSize(2, 2, .pixelformat_compressed_dxt1_rgb));
    try std.testing.expectEqual(@as(i32, 16), getPixelDataSize(2, 2, .pixelformat_compressed_dxt3_rgba));
}

test "colour conversions: raylib's own arithmetic, through the mirror" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    try std.testing.expect(colorIsEqual(Color.red, Color.red));
    try std.testing.expect(!colorIsEqual(Color.red, Color.blue));

    try std.testing.expectEqual(Color{ .r = 0x12, .g = 0x34, .b = 0x56, .a = 0x78 }, getColor(0x12345678));
    try std.testing.expectEqual(@as(i32, 0x12345678), colorToInt(.{ .r = 0x12, .g = 0x34, .b = 0x56, .a = 0x78 }));

    const solid = Color{ .r = 255, .g = 0, .b = 128, .a = 255 };
    try std.testing.expectEqual(Vector4{
        .x = @as(f32, @floatFromInt(solid.r)) / 255.0,
        .y = @as(f32, @floatFromInt(solid.g)) / 255.0,
        .z = @as(f32, @floatFromInt(solid.b)) / 255.0,
        .w = @as(f32, @floatFromInt(solid.a)) / 255.0,
    }, colorNormalize(solid));
    try std.testing.expectEqual(Color{ .r = 255, .g = 127, .b = 0, .a = 255 }, colorFromNormalized(.{ .x = 1.0, .y = 0.5, .z = 0.0, .w = 1.0 }));

    const hsv = colorToHSV(.{ .r = 255, .g = 0, .b = 0, .a = 255 });
    try std.testing.expectEqual(@as(f32, 0), hsv.x);
    try std.testing.expectEqual(@as(f32, 1), hsv.y);
    try std.testing.expectEqual(@as(f32, 1), hsv.z);
    try std.testing.expectEqual(Color{ .r = 255, .g = 0, .b = 0, .a = 255 }, colorFromHSV(0, 1, 1));

    try std.testing.expectEqual(Color{ .r = 230, .g = 41, .b = 55, .a = 127 }, fade(Color.red, 0.5));
    try std.testing.expectEqual(Color{ .r = 230, .g = 41, .b = 55, .a = 127 }, colorAlpha(Color.red, 0.5));
    try std.testing.expect(colorIsEqual(colorTint(Color.red, Color.white), Color.red));
    try std.testing.expect(colorIsEqual(colorBrightness(Color.red, 0), Color.red));
    try std.testing.expectEqual(Color{ .r = 0, .g = 255, .b = 0, .a = 255 }, colorContrast(.{ .r = 0, .g = 255, .b = 0, .a = 255 }, 0));
    try std.testing.expect(colorIsEqual(colorLerp(Color.red, Color.blue, 0), Color.red));
    try std.testing.expect(colorIsEqual(colorLerp(Color.red, Color.blue, 1), Color.blue));

    // raylib's alpha blend: a clear source leaves the destination alone, an
    // opaque one replaces it.
    try std.testing.expect(colorIsEqual(colorAlphaBlend(Color.red, Color.blank, Color.white), Color.red));
    try std.testing.expect(colorIsEqual(colorAlphaBlend(Color.red, Color.blue, Color.white), Color.blue));
}

test "getPixelColor and setPixelColor: the pixel pointer crosses as it is" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.restoreLog();

    var pixel = [_]u8{ 0, 0, 0, 0 };
    setPixelColor(&pixel, Color.red, .pixelformat_uncompressed_r8g8b8a8);
    try std.testing.expectEqualSlices(u8, &.{ 230, 41, 55, 255 }, &pixel);
    try std.testing.expect(colorIsEqual(getPixelColor(&pixel, .pixelformat_uncompressed_r8g8b8a8), Color.red));

    var gray = [_]u8{ 0, 0 };
    setPixelColor(&gray, .{ .r = 255, .g = 255, .b = 255, .a = 40 }, .pixelformat_uncompressed_gray_alpha);
    try std.testing.expectEqualSlices(u8, &.{ 255, 40 }, &gray);
}
