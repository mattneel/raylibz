//! raylib's text module: font loading, glyphs, codepoints, drawing text, and
//! the text string helpers, including the ones whose memory the caller must
//! release.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text in as `[:0]const u8`, text out as `[:0]const u8` (or `?[:0]u8` where
//! the caller must release it), buffers as slices, a load that raylib pairs with
//! an `Is*Valid` check as `error{LoadFailed}!T`, and raylib's own one-line
//! comment copied above the wrapper. What is not wrapped is listed in
//! `not_wrapped`.
//!
//! Two things are worth knowing before reading on. Most of raylib's string
//! helpers answer with a pointer into a static buffer of raylib's own, so the
//! slice this file returns is valid until the next call to that same function,
//! and `textFormat` alone rotates four buffers, so its result stays valid for
//! the next four calls. The loads, on the other hand, answer with memory raylib
//! allocated and the caller owns: `loadUTF8`, `loadCodepoints`, `loadFontData`,
//! `loadTextLines`, `genImageFontAtlas`'s rectangle array and the `*Alloc`
//! string helpers. Each one's doc comment names the function that releases it.
//!
//! This file imports only names the root also publishes (`c`, `cast`, `types`,
//! the vector files and the type names they hold), because the root's re-export
//! test requires every top-level declaration here to exist in `raylibz` too.
//! Private helpers go in a `const internal = struct { ... };`, which that test
//! skips.

const std = @import("std");

const c = @import("raylib");
const cast = @import("cast.zig");
const enums = @import("enums.zig");
const types = @import("types.zig");
const vector2 = @import("vector2.zig");

const Color = types.Color;
const FontType = enums.FontType;
const Font = types.Font;
const GlyphInfo = types.GlyphInfo;
const Image = types.Image;
const Rectangle = types.Rectangle;
const Vector2 = vector2.Vector2;

/// The functions of raylib.h's `text` section that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

// Font loading/unloading functions

/// Get the default Font
///
/// raylib builds the default font when the window is created, so before
/// `initWindow` this is an empty font that fails `isFontValid`.
pub fn getFontDefault() Font {
    return cast.as(Font, c.GetFontDefault());
}

/// Load font from file into GPU memory (VRAM)
///
/// The atlas is uploaded to the GPU, so this needs an initialized window. A
/// file raylib cannot read falls back to the default font (see `loadFont`'s C),
/// so this fails only when the result is not a valid font at all, as before
/// `initWindow`.
pub fn loadFont(fileName: [:0]const u8) error{LoadFailed}!Font {
    const font = cast.as(Font, c.LoadFont(cast.cstr(fileName)));
    if (!isFontValid(font)) return error.LoadFailed;
    return font;
}

/// Load font from file with defined codepoints and generation size, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height
///
/// raylibz takes the codepoints as a slice: `null` is raylib's `NULL` and loads
/// its default character set (32..126), while an empty slice is not the same
/// thing, because raylib then reads 95 codepoints from it.
pub fn loadFontEx(fileName: [:0]const u8, fontSize: i32, codepoints: ?[]const i32) error{LoadFailed}!Font {
    const font = cast.as(Font, c.LoadFontEx(
        cast.cstr(fileName),
        fontSize,
        internal.codepointsPtr(codepoints),
        internal.codepointsLen(codepoints),
    ));
    if (!isFontValid(font)) return error.LoadFailed;
    return font;
}

/// Load font from Image (XNA style)
///
/// The image's pixel data is read and the font is uploaded to the GPU, so this
/// needs an initialized window.
pub fn loadFontFromImage(image: Image, key: Color, firstChar: i32) error{LoadFailed}!Font {
    const font = cast.as(Font, c.LoadFontFromImage(cast.as(c.Image, image), cast.as(c.Color, key), firstChar));
    if (!isFontValid(font)) return error.LoadFailed;
    return font;
}

/// Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
///
/// raylibz takes the font file as a byte slice. The codepoints follow
/// `loadFontEx`: `null` is raylib's default character set, an empty slice is
/// not. Needs an initialized window for the atlas upload.
pub fn loadFontFromMemory(
    fileType: [:0]const u8,
    fileData: []const u8,
    fontSize: i32,
    codepoints: ?[]const i32,
) error{LoadFailed}!Font {
    const font = cast.as(Font, c.LoadFontFromMemory(
        cast.cstr(fileType),
        fileData.ptr,
        cast.asLen(fileData),
        fontSize,
        internal.codepointsPtr(codepoints),
        internal.codepointsLen(codepoints),
    ));
    if (!isFontValid(font)) return error.LoadFailed;
    return font;
}

/// Check if font is valid (font data loaded, WARNING: GPU texture not checked)
pub fn isFontValid(font: Font) bool {
    return c.IsFontValid(cast.as(c.Font, font));
}

/// Load font data for further use
///
/// raylibz returns the glyphs raylib allocated as a slice, `null` when raylib
/// could not read the font data at all; an empty slice means the data held none
/// of the requested codepoints. The memory is the caller's: release it with
/// `unloadFontData`. No window is needed: this is the CPU half of font loading,
/// and `genImageFontAtlas` turns the glyphs into an atlas image.
///
/// The codepoints follow `loadFontEx`: `null` loads raylib's default character
/// set (95 codepoints from 32), and an empty slice is not the same thing.
pub fn loadFontData(
    fileData: []const u8,
    fontSize: i32,
    codepoints: ?[]const i32,
    fontType: FontType,
) ?[]GlyphInfo {
    var glyphCount: c_int = 0;
    const glyphs = c.LoadFontData(
        fileData.ptr,
        cast.asLen(fileData),
        fontSize,
        internal.codepointsPtr(codepoints),
        internal.codepointsLen(codepoints),
        @backingInt(fontType),
        &glyphCount,
    );
    return internal.ownedSlice(GlyphInfo, internal.mirrorPointer(GlyphInfo, glyphs), glyphCount);
}

/// Generate image font atlas using chars info
///
/// The atlas image and the glyph rectangles are raylib's allocations: the
/// rectangles are `glyphRecs`, one per glyph, and the caller must release them
/// with `memFree` (or hand them to a `Font` as its `recs`). `glyphs` must not
/// be empty, because raylib takes an empty glyph count as its default of 95 and
/// reads that many entries from the slice. Packing method: 0-Default,
/// 1-Skyline.
pub fn genImageFontAtlas(
    glyphs: []const GlyphInfo,
    fontSize: i32,
    padding: i32,
    packMethod: i32,
) struct { image: Image, glyphRecs: []Rectangle } {
    var recs: [*c]c.Rectangle = null;
    const image = cast.as(Image, c.GenImageFontAtlas(
        cast.asArrayPtr(c.GlyphInfo, glyphs),
        &recs,
        cast.asLen(glyphs),
        fontSize,
        padding,
        packMethod,
    ));
    const count: i32 = if (glyphs.len > 0) cast.asLen(glyphs) else 95;
    const rectangles = internal.mirrorPointer(Rectangle, recs);
    return .{
        .image = image,
        .glyphRecs = if (rectangles) |pointer| pointer[0..@intCast(count)] else &.{},
    };
}

/// Unload font chars info data (RAM)
///
/// Takes ownership of every glyph image and of the array itself, and releases
/// them; they die at this call. `glyphs` is what `loadFontData` returned.
pub fn unloadFontData(glyphs: []GlyphInfo) void {
    const pointer: [*c]c.GlyphInfo = @ptrCast(glyphs.ptr);
    c.UnloadFontData(pointer, cast.asLen(glyphs));
}

/// Unload font from GPU memory (VRAM)
///
/// Takes ownership of the font's glyphs, its atlas rectangles and its atlas
/// texture and releases them; it dies at this call. raylib leaves the default
/// font alone, so unloading it is a no-op.
pub fn unloadFont(font: Font) void {
    c.UnloadFont(cast.as(c.Font, font));
}

/// Export font as code file, returns true on success
///
/// Reads the font's atlas back from the GPU, so it needs an initialized window.
pub fn exportFontAsCode(font: Font, fileName: [:0]const u8) bool {
    return c.ExportFontAsCode(cast.as(c.Font, font), cast.cstr(fileName));
}

// Text drawing functions

/// Draw current FPS
pub const drawFPS = c.DrawFPS;

/// Draw text (using default font)
///
/// raylib takes `const char *text` and a `Color`; both cross as written.
pub fn drawText(text: [:0]const u8, posX: i32, posY: i32, fontSize: i32, color: Color) void {
    c.DrawText(cast.cstr(text), posX, posY, fontSize, cast.as(c.Color, color));
}

/// Draw text using font and additional parameters
pub fn drawTextEx(font: Font, text: [:0]const u8, position: Vector2, fontSize: f32, spacing: f32, tint: Color) void {
    c.DrawTextEx(
        cast.as(c.Font, font),
        cast.cstr(text),
        cast.as(c.Vector2, position),
        fontSize,
        spacing,
        cast.as(c.Color, tint),
    );
}

/// Draw text using Font and pro parameters (rotation)
pub fn drawTextPro(
    font: Font,
    text: [:0]const u8,
    position: Vector2,
    origin: Vector2,
    rotation: f32,
    fontSize: f32,
    spacing: f32,
    tint: Color,
) void {
    c.DrawTextPro(
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

/// Draw one character (codepoint)
pub fn drawTextCodepoint(font: Font, codepoint: i32, position: Vector2, fontSize: f32, tint: Color) void {
    c.DrawTextCodepoint(
        cast.as(c.Font, font),
        codepoint,
        cast.as(c.Vector2, position),
        fontSize,
        cast.as(c.Color, tint),
    );
}

/// Draw multiple characters (codepoint)
///
/// raylibz takes the codepoints as a slice and derives its count from the
/// slice's length.
pub fn drawTextCodepoints(
    font: Font,
    codepoints: []const i32,
    position: Vector2,
    fontSize: f32,
    spacing: f32,
    tint: Color,
) void {
    c.DrawTextCodepoints(
        cast.as(c.Font, font),
        codepoints.ptr,
        cast.asLen(codepoints),
        cast.as(c.Vector2, position),
        fontSize,
        spacing,
        cast.as(c.Color, tint),
    );
}

// Text font info functions

/// Set vertical line spacing when drawing with line-breaks
pub const setTextLineSpacing = c.SetTextLineSpacing;

/// Measure string width for default font
pub fn measureText(text: [:0]const u8, fontSize: i32) i32 {
    return c.MeasureText(cast.cstr(text), fontSize);
}

/// Measure string size for Font
pub fn measureTextEx(font: Font, text: [:0]const u8, fontSize: f32, spacing: f32) Vector2 {
    return cast.as(Vector2, c.MeasureTextEx(cast.as(c.Font, font), cast.cstr(text), fontSize, spacing));
}

/// Measure string size for an existing array of codepoints for Font
///
/// raylibz takes the codepoints as a slice and derives its length from the
/// slice's length.
pub fn measureTextCodepoints(font: Font, codepoints: []const i32, fontSize: f32, spacing: f32) Vector2 {
    return cast.as(Vector2, c.MeasureTextCodepoints(
        cast.as(c.Font, font),
        codepoints.ptr,
        cast.asLen(codepoints),
        fontSize,
        spacing,
    ));
}

/// Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
pub fn getGlyphIndex(font: Font, codepoint: i32) i32 {
    return c.GetGlyphIndex(cast.as(c.Font, font), codepoint);
}

/// Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
pub fn getGlyphInfo(font: Font, codepoint: i32) GlyphInfo {
    return cast.as(GlyphInfo, c.GetGlyphInfo(cast.as(c.Font, font), codepoint));
}

/// Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found
pub fn getGlyphAtlasRec(font: Font, codepoint: i32) Rectangle {
    return cast.as(Rectangle, c.GetGlyphAtlasRec(cast.as(c.Font, font), codepoint));
}

// Text codepoints management functions (unicode characters)

/// Load UTF-8 text encoded from codepoints array
///
/// `null` when raylib did not allocate, which its C does for an empty
/// `codepoints` slice. The memory is the caller's: release it with
/// `unloadUTF8`.
pub fn loadUTF8(codepoints: []const i32) ?[:0]u8 {
    return cast.optOwnedSpan(c.LoadUTF8(codepoints.ptr, cast.asLen(codepoints)));
}

/// Unload UTF-8 text encoded from codepoints array
///
/// Takes ownership of the memory `text` points into and releases it; it dies at
/// this call. `text` is what `loadUTF8` returned.
pub fn unloadUTF8(text: [:0]u8) void {
    c.UnloadUTF8(text.ptr);
}

/// Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
///
/// raylibz returns raylib's allocation as a slice, `null` where raylib returned
/// `NULL`; release it with `unloadCodepoints`.
pub fn loadCodepoints(text: [:0]const u8) ?[]i32 {
    var count: c_int = 0;
    const codepoints = c.LoadCodepoints(cast.cstr(text), &count);
    return internal.ownedSlice(i32, codepoints, count);
}

/// Unload codepoints data from memory
///
/// Takes ownership of the memory `codepoints` points into and releases it; it
/// dies at this call. `codepoints` is what `loadCodepoints` returned.
pub fn unloadCodepoints(codepoints: []i32) void {
    c.UnloadCodepoints(codepoints.ptr);
}

/// Get total number of codepoints in a UTF-8 encoded string
pub fn getCodepointCount(text: [:0]const u8) i32 {
    return c.GetCodepointCount(cast.cstr(text));
}

/// Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
///
/// raylibz returns raylib's `codepointSize` out-parameter in the struct, with
/// the codepoint: how many bytes of `text` the codepoint took.
pub fn getCodepoint(text: [:0]const u8) struct { codepoint: i32, codepointSize: i32 } {
    var size: c_int = 0;
    const codepoint = c.GetCodepoint(cast.cstr(text), &size);
    return .{ .codepoint = codepoint, .codepointSize = size };
}

/// Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
///
/// `text` is raylib's cursor into a NUL-terminated UTF-8 string, not a slice:
/// step it forward by the returned `codepointSize`.
pub fn getCodepointNext(text: [*:0]const u8) struct { codepoint: i32, codepointSize: i32 } {
    var size: c_int = 0;
    const codepoint = c.GetCodepointNext(text, &size);
    return .{ .codepoint = codepoint, .codepointSize = size };
}

/// Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
///
/// `text` is raylib's cursor: it must point just past the codepoint to read
/// back to, so it is a pointer into a string the caller owns, and raylib reads
/// the bytes before it.
pub fn getCodepointPrevious(text: [*:0]const u8) struct { codepoint: i32, codepointSize: i32 } {
    var size: c_int = 0;
    const codepoint = c.GetCodepointPrevious(text, &size);
    return .{ .codepoint = codepoint, .codepointSize = size };
}

/// Encode one codepoint into UTF-8 byte array (array length returned as parameter)
///
/// The bytes are raylib's static buffer: the slice is valid until the next call
/// to this function. Its length is the byte size raylib encoded, 1 for a
/// codepoint of 0 (so it is a slice, not a `std.mem.span` of the buffer) and 0
/// for a codepoint above U+10FFFF, which raylib does not encode.
pub fn codepointToUTF8(codepoint: i32) [:0]const u8 {
    var size: c_int = 0;
    const utf8 = c.CodepointToUTF8(codepoint, &size);
    const bytes: [*:0]const u8 = utf8;
    return bytes[0..@intCast(size) :0];
}

// Text strings management functions (no UTF-8 strings, only byte chars)
// WARNING 1: Most of these functions use internal static buffers[], it's recommended to store returned data on user-side for re-use
// WARNING 2: Some functions allocate memory internally for the returned strings, those strings must be freed by user using MemFree()

/// Load text as separate lines ('\n')
///
/// raylibz returns the lines as a slice of NUL-terminated pointers, `null`
/// where raylib returned `NULL`. raylib allocated each line and the array of
/// pointers: release both with `unloadTextLines`.
pub fn loadTextLines(text: [:0]const u8) ?[][*:0]u8 {
    var count: c_int = 0;
    const lines = c.LoadTextLines(cast.cstr(text), &count);
    if (lines == null) return null;
    return internal.ownedPointers(lines, count);
}

/// Unload text lines
///
/// Takes ownership of the lines `lines` points into and of the array itself,
/// and releases them; they die at this call. `lines` is what `loadTextLines`
/// returned.
pub fn unloadTextLines(lines: [][*:0]u8) void {
    c.UnloadTextLines(internal.pointerArray(lines), cast.asLen(lines));
}

/// Copy one string to another, returns bytes copied
///
/// raylibz takes `dst` as a slice, and raylib writes the text and its `'\0'`
/// into it: `dst` must have room for all of `src` and one more byte.
pub fn textCopy(dst: []u8, src: [:0]const u8) i32 {
    return c.TextCopy(dst.ptr, cast.cstr(src));
}

/// Check if two text strings are equal
pub fn textIsEqual(text1: [:0]const u8, text2: [:0]const u8) bool {
    return c.TextIsEqual(cast.cstr(text1), cast.cstr(text2));
}

/// Get text length, checks for '\0' ending
pub fn textLength(text: [:0]const u8) u32 {
    return c.TextLength(cast.cstr(text));
}

/// Text formatting with variables (sprintf() style)
///
/// raylibz forwards Zig's `args` tuple, so the format string and the arguments
/// follow C's, not Zig's: the variadic arguments are `c_int`, `f64`, `[*:0]const u8`
/// and the other C types a `printf` conversion expects, and a `float` must be
/// passed as an `f64` because C promotes it.
///
/// The text lands in one of four static buffers raylib rotates, so the result
/// is valid for the next four calls to `textFormat`; a result longer than 1023
/// bytes is truncated by raylib, with `...` at the end.
pub fn textFormat(text: [:0]const u8, args: anytype) [:0]const u8 {
    return cast.span(@call(.auto, c.TextFormat, .{cast.cstr(text)} ++ args));
}

/// Get a piece of a text string
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textSubtext`.
pub fn textSubtext(text: [:0]const u8, position: i32, length: i32) [:0]const u8 {
    return cast.span(c.TextSubtext(cast.cstr(text), position, length));
}

/// Remove text spaces, concat words
///
/// raylib removes `' '` and nothing else: a tab or a newline stays. The text is
/// raylib's static buffer: the slice is valid until the next call to
/// `textRemoveSpaces`.
pub fn textRemoveSpaces(text: [:0]const u8) [:0]const u8 {
    return cast.span(c.TextRemoveSpaces(cast.cstr(text)));
}

/// Get text between two strings
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `getTextBetween`, and raylib leaves it empty when it finds no `begin` or
/// no `end` in `text`.
pub fn getTextBetween(text: [:0]const u8, begin: [:0]const u8, end: [:0]const u8) [:0]const u8 {
    return cast.span(c.GetTextBetween(cast.cstr(text), cast.cstr(begin), cast.cstr(end)));
}

/// Replace text string with new string
///
/// raylib's limited version: the result lives in its static buffer, so the
/// slice is valid until the next call to `textReplace`, and a replacement that
/// does not fit raylib's 1024-byte buffer is refused (the result is empty).
/// Use `textReplaceAlloc` for the version that allocates. A `null`
/// `replacement` is raylib's, and removes `search`.
pub fn textReplace(text: [:0]const u8, search: [:0]const u8, replacement: ?[:0]const u8) [:0]const u8 {
    return cast.span(c.TextReplace(cast.cstr(text), cast.cstr(search), cast.optCstr(replacement)));
}

/// Replace text string with new string, memory must be MemFree()
///
/// raylib allocates the result: release it with `memFree`. `null` where raylib
/// allocated nothing, which its C does for an empty `search`; a `text` without
/// `search` in it still gets a copy. A `null` `replacement` is raylib's, and
/// removes `search`.
pub fn textReplaceAlloc(text: [:0]const u8, search: [:0]const u8, replacement: ?[:0]const u8) ?[:0]u8 {
    return cast.optOwnedSpan(c.TextReplaceAlloc(cast.cstr(text), cast.cstr(search), cast.optCstr(replacement)));
}

/// Replace text between two specific strings
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textReplaceBetween`, and raylib leaves it empty when it finds no `begin`
/// or no `end` in `text`. A `null` `replacement` is raylib's, and removes the
/// text between `begin` and `end`.
pub fn textReplaceBetween(
    text: [:0]const u8,
    begin: [:0]const u8,
    end: [:0]const u8,
    replacement: ?[:0]const u8,
) [:0]const u8 {
    return cast.span(c.TextReplaceBetween(
        cast.cstr(text),
        cast.cstr(begin),
        cast.cstr(end),
        cast.optCstr(replacement),
    ));
}

/// Replace text between two specific strings, memory must be MemFree()
///
/// raylib allocates the result: release it with `memFree`. `null` where raylib
/// allocated nothing (`begin` or `end` not found in `text`). A `null`
/// `replacement` is raylib's, and removes the text between `begin` and `end`.
pub fn textReplaceBetweenAlloc(
    text: [:0]const u8,
    begin: [:0]const u8,
    end: [:0]const u8,
    replacement: ?[:0]const u8,
) ?[:0]u8 {
    return cast.optOwnedSpan(c.TextReplaceBetweenAlloc(
        cast.cstr(text),
        cast.cstr(begin),
        cast.cstr(end),
        cast.optCstr(replacement),
    ));
}

/// Insert text in a defined byte position
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textInsert`, and an insert that does not fit raylib's 1024-byte buffer
/// is refused (the result is empty). Use `textInsertAlloc` for the version that
/// allocates.
pub fn textInsert(text: [:0]const u8, insert: [:0]const u8, position: i32) [:0]const u8 {
    return cast.span(c.TextInsert(cast.cstr(text), cast.cstr(insert), position));
}

/// Insert text in a defined byte position, memory must be MemFree()
///
/// raylib allocates the result: release it with `memFree`. `null` where raylib
/// allocated nothing (`position` was negative). raylib clamps a position past
/// the end of `text` to the end.
pub fn textInsertAlloc(text: [:0]const u8, insert: [:0]const u8, position: i32) ?[:0]u8 {
    return cast.optOwnedSpan(c.TextInsertAlloc(cast.cstr(text), cast.cstr(insert), position));
}

/// Join text strings with delimiter
///
/// raylibz takes the list as a slice of NUL-terminated pointers and derives its
/// count from the slice's length. The text is raylib's static buffer: the slice
/// is valid until the next call to `textJoin`, and raylib stops joining when
/// the result no longer fits its 1024-byte buffer.
pub fn textJoin(textList: []const [*:0]const u8, delimiter: [:0]const u8) [:0]const u8 {
    return cast.span(c.TextJoin(internal.pointerArray(textList), cast.asLen(textList), cast.cstr(delimiter)));
}

/// Split text into multiple strings, using MAX_TEXTSPLIT_COUNT static strings
///
/// raylibz returns raylib's pointers as a slice and drops the count raylib
/// reports: it is the slice's length. Both the pointers and the strings they
/// point into live in raylib's static buffers, so the slice is valid until the
/// next call to `textSplit`, and raylib's limits apply: at most 128 pieces,
/// from at most 1023 bytes of text.
pub fn textSplit(text: [:0]const u8, delimiter: u8) []const [*:0]const u8 {
    var count: c_int = 0;
    return internal.staticPointers(c.TextSplit(cast.cstr(text), delimiter, &count), count);
}

/// Append text at specific position and move cursor
///
/// raylibz takes the buffer as a slice and `position` as a pointer: raylib
/// appends `append` at `text[position.*]` and moves `position.*` past it. The
/// caller's buffer must have room for `append` and its `'\0'`.
pub fn textAppend(text: []u8, append: [:0]const u8, position: *i32) void {
    c.TextAppend(text.ptr, cast.cstr(append), position);
}

/// Find first text occurrence within a string, -1 if not found
pub fn textFindIndex(text: [:0]const u8, search: [:0]const u8) i32 {
    return c.TextFindIndex(cast.cstr(text), cast.cstr(search));
}

/// Get upper case version of provided string
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textToUpper`. raylib's own warning applies: only the basic character set
/// is handled.
pub fn textToUpper(text: [:0]const u8) [:0]const u8 {
    return cast.span(c.TextToUpper(cast.cstr(text)));
}

/// Get lower case version of provided string
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textToLower`. raylib's own warning applies: only the basic character set
/// is handled.
pub fn textToLower(text: [:0]const u8) [:0]const u8 {
    return cast.span(c.TextToLower(cast.cstr(text)));
}

/// Get Pascal case notation version of provided string
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textToPascal`. raylib's own warning applies: only the basic character
/// set is handled.
pub fn textToPascal(text: [:0]const u8) [:0]const u8 {
    return cast.span(c.TextToPascal(cast.cstr(text)));
}

/// Get Snake case notation version of provided string
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textToSnake`. raylib's own warning applies: only the basic character set
/// is handled.
pub fn textToSnake(text: [:0]const u8) [:0]const u8 {
    return cast.span(c.TextToSnake(cast.cstr(text)));
}

/// Get Camel case notation version of provided string
///
/// The text is raylib's static buffer: the slice is valid until the next call
/// to `textToCamel`. raylib's own warning applies: only the basic character set
/// is handled.
pub fn textToCamel(text: [:0]const u8) [:0]const u8 {
    return cast.span(c.TextToCamel(cast.cstr(text)));
}

/// Get integer value from text
///
/// raylib's own parser: an optional leading `+` or `-`, then digits until the
/// first non-digit. It does not skip leading spaces, and it ignores whatever
/// follows the digits.
pub fn textToInteger(text: [:0]const u8) i32 {
    return c.TextToInteger(cast.cstr(text));
}

/// Get float value from text
///
/// raylib's own parser, like `textToInteger` with one optional fraction.
pub fn textToFloat(text: [:0]const u8) f32 {
    return c.TextToFloat(cast.cstr(text));
}

/// The private helpers this file's wrappers share: the pointer-and-count
/// conversions raylib's signatures need, and the nullable codepoints pair.
const internal = struct {
    /// raylib's pointer-and-count pair as a slice, keeping raylib's own pointer
    /// even when the count is zero, because the release function frees exactly
    /// that pointer. `null` where raylib returned `NULL`.
    fn ownedSlice(comptime T: type, ptr: ?[*]T, count: i32) ?[]T {
        const pointer = ptr orelse return null;
        return pointer[0..@intCast(@max(count, 0))];
    }

    /// raylib's pointer to its translated type as a pointer to the mirror of the
    /// same type, `null` where raylib returned `NULL`. The mirrors' layout
    /// assertions make the reinterpretation sound (see `cast.as`).
    fn mirrorPointer(comptime T: type, ptr: anytype) ?[*]T {
        if (ptr == null) return null;
        const pointer: [*]T = @ptrCast(ptr);
        return pointer;
    }

    /// raylib's `char **` as the slice of NUL-terminated pointers it describes:
    /// pointers the caller may modify and must release, with the length raylib
    /// reported.
    fn ownedPointers(array: [*c][*c]u8, count: i32) [][*:0]u8 {
        const first: [*][*:0]u8 = @ptrCast(array);
        return first[0..@intCast(@max(count, 0))];
    }

    /// raylib's `char **` as the slice of NUL-terminated pointers it describes:
    /// strings in raylib's static buffers, so the slice is read-only.
    fn staticPointers(array: [*c][*c]u8, count: i32) []const [*:0]const u8 {
        const first: [*]const [*:0]const u8 = @ptrCast(array);
        return first[0..@intCast(@max(count, 0))];
    }

    /// raylib's `char **` argument for a slice of NUL-terminated pointers.
    fn pointerArray(list: anytype) [*c][*c]u8 {
        return @ptrCast(@constCast(list.ptr));
    }

    /// raylib's `const int *codepoints` for a slice raylibz takes as optional:
    /// `null` is raylib's `NULL`, its default character set.
    fn codepointsPtr(codepoints: ?[]const i32) [*c]const i32 {
        return if (codepoints) |points| points.ptr else null;
    }

    /// raylib's `int codepointCount` for the same slice: raylib's own default
    /// when there are none.
    fn codepointsLen(codepoints: ?[]const i32) i32 {
        return if (codepoints) |points| cast.asLen(points) else 0;
    }
};

// Everything `zig build test` runs here: the conversions that can go wrong,
// called against raylib's own implementation. Nothing here needs a window (the
// font tests read a font file if the system has one) and nothing tests a plain
// forwarding of arguments.

test "textCopy fills the caller's buffer and reports the bytes copied" {
    var buffer: [32]u8 = @splat(0);
    const copied = textCopy(&buffer, "hello");
    try std.testing.expectEqual(@as(i32, 5), copied);
    try std.testing.expectEqualStrings("hello", std.mem.sliceTo(buffer[0..], 0));
}

test "textLength and textIsEqual read C strings" {
    try std.testing.expectEqual(@as(u32, 0), textLength(""));
    try std.testing.expectEqual(@as(u32, 5), textLength("hello"));
    try std.testing.expect(textIsEqual("hello", "hello"));
    try std.testing.expect(!textIsEqual("hello", "hello!"));
}

test "textFormat forwards a Zig argument tuple and rotates four buffers" {
    const first = textFormat("%d and %s", .{ @as(c_int, 42), "a string" });
    const second = textFormat("[%.2f]", .{@as(f64, 1.5)});
    const third = textFormat("%s%s", .{ "a", "b" });
    const fourth = textFormat("d", .{});

    // raylib keeps four buffers, so the first four results are all alive after
    // the fourth call: only a fifth call overwrites the first buffer.
    try std.testing.expectEqualStrings("42 and a string", first);
    try std.testing.expectEqualStrings("[1.50]", second);
    try std.testing.expectEqualStrings("ab", third);
    try std.testing.expectEqualStrings("d", fourth);
    try std.testing.expectEqual(@as(usize, 15), first.len);

    const fifth = textFormat("%%", .{});
    try std.testing.expectEqualStrings("%", fifth);
}

test "the static-buffer helpers answer from raylib's own buffers" {
    const subtext = textSubtext("Hello World", 6, 5);
    try std.testing.expectEqualStrings("World", subtext);
    // raylib's buffer is raylib's: the next call rewrites those same bytes, so
    // the slice the first call returned now reads the second call's text.
    _ = textSubtext("abcdefg", 0, 5);
    try std.testing.expectEqualStrings("abcde", subtext);

    // raylib removes spaces only, and leaves other whitespace alone.
    try std.testing.expectEqualStrings("ab\tc", textRemoveSpaces(" a b\tc "));
    try std.testing.expectEqualStrings("hi", getTextBetween("<a>hi</a>", "<a>", "</a>"));
    try std.testing.expectEqualStrings("", getTextBetween("nothing", "<a>", "</a>"));
}

test "textReplace, textReplaceBetween and textInsert use static buffers" {
    try std.testing.expectEqualStrings("Hello, Zig!", textReplace("Hello, world!", "world", "Zig"));
    try std.testing.expectEqualStrings("abc", textReplace("axbxc", "x", null));

    try std.testing.expectEqualStrings("Keep <new> tail", textReplaceBetween("Keep <old> tail", "<", ">", "new"));
    try std.testing.expectEqualStrings("Keep <> tail", textReplaceBetween("Keep <old> tail", "<", ">", null));
    // raylib fills its buffer only when it finds both strings: no match, no text.
    try std.testing.expectEqualStrings("", textReplaceBetween("no match here", "<", ">", "new"));

    try std.testing.expectEqualStrings("Hello there world", textInsert("Hello world", "there ", 6));
    // raylib clamps a position past the end of the text to the end.
    try std.testing.expectEqualStrings("Hello world!", textInsert("Hello world", "!", 99));
}

test "the *Alloc helpers return the caller's own memory" {
    const replaced = textReplaceAlloc("Hello, world!", "world", "Zig") orelse return error.TestUnexpectedResult;
    defer c.MemFree(@ptrCast(replaced.ptr));
    try std.testing.expectEqual(@as(usize, 11), replaced.len);
    try std.testing.expectEqualStrings("Hello, Zig!", replaced);

    const between = textReplaceBetweenAlloc("Keep <old> tail", "<", ">", "new") orelse return error.TestUnexpectedResult;
    defer c.MemFree(@ptrCast(between.ptr));
    try std.testing.expectEqualStrings("Keep <new> tail", between);

    const inserted = textInsertAlloc("Hello world", "there ", 6) orelse return error.TestUnexpectedResult;
    defer c.MemFree(@ptrCast(inserted.ptr));
    try std.testing.expectEqualStrings("Hello there world", inserted);

    // raylib still allocates a copy when there is nothing to replace, and
    // allocates nothing only when `begin` or `end` is missing.
    const untouched = textReplaceAlloc("Hello", "absent", "x") orelse return error.TestUnexpectedResult;
    defer c.MemFree(@ptrCast(untouched.ptr));
    try std.testing.expectEqualStrings("Hello", untouched);
    try std.testing.expectEqual(@as(?[:0]u8, null), textReplaceBetweenAlloc("Hello", "<", ">", "x"));
}

test "textJoin joins a slice of pointers and textSplit splits into one" {
    const list = [_][*:0]const u8{ "a", "b", "c" };
    try std.testing.expectEqualStrings("a, b, c", textJoin(&list, ", "));
    try std.testing.expectEqualStrings("abc", textJoin(&list, ""));
    try std.testing.expectEqualStrings("a,b,c", textJoin(&list, ","));

    const parts = textSplit("one,two,,three", ',');
    try std.testing.expectEqual(@as(usize, 4), parts.len);
    try std.testing.expectEqualStrings("one", std.mem.span(parts[0]));
    try std.testing.expectEqualStrings("two", std.mem.span(parts[1]));
    try std.testing.expectEqualStrings("", std.mem.span(parts[2]));
    try std.testing.expectEqualStrings("three", std.mem.span(parts[3]));

    // One piece when there is no delimiter, and the split buffer is static too.
    const single = textSplit("alone", ',');
    try std.testing.expectEqual(@as(usize, 1), single.len);
    try std.testing.expectEqualStrings("alone", std.mem.span(single[0]));
}

test "textAppend moves the cursor it is given" {
    var buffer: [32]u8 = @splat(0);
    var position: i32 = 0;
    textAppend(&buffer, "Hello", &position);
    textAppend(&buffer, ", world", &position);
    try std.testing.expectEqual(@as(i32, 12), position);
    try std.testing.expectEqualStrings("Hello, world", std.mem.sliceTo(buffer[0..], 0));
}

test "textFindIndex finds the first occurrence or -1" {
    try std.testing.expectEqual(@as(i32, 7), textFindIndex("Hello, world!", "world"));
    try std.testing.expectEqual(@as(i32, -1), textFindIndex("Hello, world!", "Zig"));
}

test "the case helpers rewrite the basic character set" {
    try std.testing.expectEqualStrings("HELLO, WORLD! 123", textToUpper("Hello, World! 123"));
    try std.testing.expectEqualStrings("hello, world! 123", textToLower("Hello, World! 123"));
    try std.testing.expectEqualStrings("HelloWorld", textToPascal("hello_world"));
    // raylib skips the separators between words, not a leading one.
    try std.testing.expectEqualStrings("_helloWorld", textToPascal("_hello__world"));
    try std.testing.expectEqualStrings("http_request", textToSnake("HTTPRequest"));
    try std.testing.expectEqualStrings("hello_world", textToSnake("hello world"));
    try std.testing.expectEqualStrings("helloWorld", textToCamel("hello_world"));
}

test "textToInteger and textToFloat parse raylib's way" {
    try std.testing.expectEqual(@as(i32, 42), textToInteger("42"));
    try std.testing.expectEqual(@as(i32, -42), textToInteger("-42abc"));
    try std.testing.expectEqual(@as(i32, 7), textToInteger("+7"));
    try std.testing.expectEqual(@as(i32, 0), textToInteger("no digits"));

    try std.testing.expectEqual(@as(f32, 3.5), textToFloat("3.5"));
    try std.testing.expectEqual(@as(f32, -2.5), textToFloat("-2.5"));
    try std.testing.expectEqual(@as(f32, 12), textToFloat("12"));
}

test "loadUTF8 encodes codepoints and unloadUTF8 releases them" {
    const text = loadUTF8(&[_]i32{ 'H', 0xe9, 0x263a }) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(@as(usize, 6), text.len);
    try std.testing.expectEqualStrings("H\u{e9}\u{263a}", text);
    unloadUTF8(text);

    // raylib allocates nothing for no codepoints.
    try std.testing.expectEqual(@as(?[:0]u8, null), loadUTF8(&.{}));
}

test "loadCodepoints and unloadCodepoints round-trip UTF-8 through codepoints" {
    const codepoints = loadCodepoints("H\u{e9}\u{263a}") orelse return error.TestUnexpectedResult;
    defer unloadCodepoints(codepoints);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 'H', 0xe9, 0x263a }, codepoints);

    const text = loadUTF8(codepoints) orelse return error.TestUnexpectedResult;
    defer unloadUTF8(text);
    try std.testing.expectEqualStrings("H\u{e9}\u{263a}", text);
}

test "the codepoint readers report the bytes they consumed" {
    const text: [:0]const u8 = "a\u{e9}\u{263a}";
    try std.testing.expectEqual(@as(i32, 3), getCodepointCount(text));

    const first = getCodepoint(text);
    try std.testing.expectEqual(@as(i32, 'a'), first.codepoint);
    try std.testing.expectEqual(@as(i32, 1), first.codepointSize);

    const second = getCodepointNext(text.ptr + 1);
    try std.testing.expectEqual(@as(i32, 0xe9), second.codepoint);
    try std.testing.expectEqual(@as(i32, 2), second.codepointSize);

    const third = getCodepointNext(text.ptr + 3);
    try std.testing.expectEqual(@as(i32, 0x263a), third.codepoint);
    try std.testing.expectEqual(@as(i32, 3), third.codepointSize);

    // raylib's cursor walks back to the start of the codepoint before it.
    const back = getCodepointPrevious(text.ptr + 6);
    try std.testing.expectEqual(@as(i32, 0x263a), back.codepoint);
    try std.testing.expectEqual(@as(i32, 3), back.codepointSize);

    // An invalid continuation byte is a failure: '?' and one byte.
    const broken = getCodepointNext("\x80x");
    try std.testing.expectEqual(@as(i32, 0x3f), broken.codepoint);
    try std.testing.expectEqual(@as(i32, 1), broken.codepointSize);
}

test "codepointToUTF8 encodes one codepoint into raylib's static buffer" {
    try std.testing.expectEqualStrings("a", codepointToUTF8('a'));
    try std.testing.expectEqualStrings("\u{e9}", codepointToUTF8(0xe9));
    try std.testing.expectEqualStrings("\u{263a}", codepointToUTF8(0x263a));
    try std.testing.expectEqual(@as(usize, 4), codepointToUTF8(0x1f600).len);

    // A codepoint of 0 is one zero byte, and one above U+10FFFF is nothing.
    const zero = codepointToUTF8(0);
    try std.testing.expectEqual(@as(usize, 1), zero.len);
    try std.testing.expectEqual(@as(u8, 0), zero[0]);
    try std.testing.expectEqual(@as(usize, 0), codepointToUTF8(0x110000).len);
}

test "loadTextLines and unloadTextLines own every line and the array" {
    const lines = loadTextLines("first\nsecond\n\nfourth") orelse return error.TestUnexpectedResult;
    defer unloadTextLines(lines);
    try std.testing.expectEqual(@as(usize, 4), lines.len);
    try std.testing.expectEqualStrings("first", std.mem.span(lines[0]));
    try std.testing.expectEqualStrings("second", std.mem.span(lines[1]));
    try std.testing.expectEqualStrings("", std.mem.span(lines[2]));
    try std.testing.expectEqualStrings("fourth", std.mem.span(lines[3]));
}

test "loadFontData and genImageFontAtlas describe one owned array each" {
    // The CPU half of font loading needs a font file and nothing else; the
    // system's DejaVu is a stand-in for the resources a package does not ship.
    const path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf";
    const data = std.Io.Dir.readFileAlloc(
        std.Io.Dir.cwd(),
        std.testing.io,
        path,
        std.testing.allocator,
        .limited(8 << 20),
    ) catch return error.SkipZigTest;
    defer std.testing.allocator.free(data);

    const glyphs = loadFontData(data, 32, null, .font_default) orelse return error.TestUnexpectedResult;
    const atlas = genImageFontAtlas(glyphs, 32, 4, 0);
    defer c.MemFree(@ptrCast(atlas.glyphRecs.ptr));
    defer unloadFontData(glyphs);

    // 95 glyphs is raylib's default character set, and the atlas has one
    // rectangle per glyph, in the same order.
    try std.testing.expectEqual(@as(usize, 95), glyphs.len);
    try std.testing.expectEqual(glyphs.len, atlas.glyphRecs.len);
    try std.testing.expectEqual(@as(i32, '!'), glyphs[1].value);
    try std.testing.expect(atlas.image.data != null);
    try std.testing.expect(atlas.image.width > 0);
    try std.testing.expect(atlas.image.height > 0);
    try std.testing.expect(atlas.glyphRecs[1].width > 0);

    // An explicit codepoint list loads exactly those glyphs.
    const two = loadFontData(data, 32, &[_]i32{ 'A', 'B' }, .font_default) orelse return error.TestUnexpectedResult;
    defer unloadFontData(two);
    try std.testing.expectEqual(@as(usize, 2), two.len);
    try std.testing.expectEqual(@as(i32, 'A'), two[0].value);
    try std.testing.expectEqual(@as(i32, 'B'), two[1].value);

    c.UnloadImage(cast.as(c.Image, atlas.image));
}
