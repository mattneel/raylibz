//! Crossing the boundary between raylibz's mirrored types and raylib's own
//! translated declarations, and the compile-time assertions that keep the two
//! in step.
//!
//! Nothing here allocates, and nothing here is a wrapper: these are the small
//! helpers every wrapper in `core.zig`, `text.zig` and friends uses to hand
//! raylib exactly the value it asked for.

const std = @import("std");

/// A raylib function raylibz does not wrap, and why.
///
/// Every RLAPI function of the pinned `raylib.h` is wrapped, re-exported
/// unchanged, or listed as one of these in its module's `not_wrapped` array;
/// `tests/parity.zig` fails if a function is in none of the three, or if a name
/// listed here is not a function of the translated module at all.
pub const NotWrapped = struct {
    /// The C name, exactly as `raylib.h` spells it, e.g. `"TextFormat"`.
    name: []const u8,
    /// Why raylibz does not wrap it, in one line.
    reason: []const u8,
};

/// Reinterprets `value` as `T`, a pointer reinterpretation of the same bytes.
///
/// Zig rejects `@bitCast` to and from extern structs, so a mirror crosses the
/// boundary as `as(c.Image, image)` / `as(Image, c_image)`. The two types must
/// have the same size and alignment; the layout assertions in the mirror's body
/// (`assertLayout`) prove that field by field, so this cannot drift silently.
pub fn as(comptime T: type, value: anytype) T {
    const U = @TypeOf(value);
    comptime {
        if (@sizeOf(U) != @sizeOf(T)) @compileError(std.fmt.comptimePrint(
            "cast.as: size mismatch, " ++ @typeName(U) ++ " is {d} bytes but " ++ @typeName(T) ++ " is {d}",
            .{ @sizeOf(U), @sizeOf(T) },
        ));
        if (@alignOf(U) != @alignOf(T)) @compileError(std.fmt.comptimePrint(
            "cast.as: alignment mismatch, " ++ @typeName(U) ++ " is {d}-aligned but " ++ @typeName(T) ++ " is {d}",
            .{ @alignOf(U), @alignOf(T) },
        ));
    }
    return @as(*const T, @ptrCast(&value)).*;
}

/// The pointer raylib wants for a pointer to a mirror: `asPtr(c.Image, image)`
/// is the `&image` argument of `LoadImageColors(Image *image)` and the like.
pub fn asPtr(comptime T: type, value: anytype) *T {
    const P = @TypeOf(value);
    comptime {
        if (@typeInfo(P) != .pointer) @compileError("cast.asPtr: " ++ @typeName(P) ++ " is not a pointer");
        if (@typeInfo(P).pointer.size != .one)
            @compileError("cast.asPtr: " ++ @typeName(P) ++ " is not a single-item pointer");
    }
    return @ptrCast(value);
}

/// The `const` pointer raylib wants for a pointer to a mirror, e.g.
/// `asConstPtr(c.Camera, camera)` for a function that only reads the camera.
pub fn asConstPtr(comptime T: type, value: anytype) *const T {
    const P = @TypeOf(value);
    comptime {
        if (@typeInfo(P) != .pointer) @compileError("cast.asConstPtr: " ++ @typeName(P) ++ " is not a pointer");
        if (@typeInfo(P).pointer.size != .one)
            @compileError("cast.asConstPtr: " ++ @typeName(P) ++ " is not a single-item pointer");
    }
    return @ptrCast(value);
}

/// The many-pointer raylib wants for a slice of mirrors it only reads, e.g.
/// `asArrayPtr(c.Vector2, points)` for `const Vector2 *points`.
pub fn asArrayPtr(comptime T: type, slice: anytype) [*]const T {
    return @ptrCast(slice.ptr);
}

/// The many-pointer raylib wants for a slice of mirrors it writes to, e.g. for
/// a caller-owned buffer a `Load*` function fills.
pub fn asArrayPtrMut(comptime T: type, slice: anytype) [*]T {
    return @ptrCast(slice.ptr);
}

/// The `int` raylib wants for a slice's length. A slice longer than an `int`
/// can hold is a bug in the caller, not a truncation to hide.
pub fn asLen(slice: anytype) i32 {
    return @intCast(slice.len);
}

/// The slice raylib's pointer-and-count pair describes, for an array it
/// returned: `LoadFileData`'s `unsigned char *` plus `int dataSize` becomes
/// `asSlice(u8, data, size)`, and `null` when raylib returned `NULL`.
pub fn asSlice(comptime T: type, data: ?[*]T, len: i32) ?[]T {
    const ptr = data orelse return null;
    if (len <= 0) return &.{};
    return ptr[0..@intCast(len)];
}

/// The `const` slice raylib's pointer-and-count pair describes, for an array it
/// returned and the caller may not modify.
pub fn asConstSlice(comptime T: type, data: ?[*]const T, len: i32) ?[]const T {
    const ptr = data orelse return null;
    if (len <= 0) return &.{};
    return ptr[0..@intCast(len)];
}

/// A `const char *` parameter: a Zig string literal as raylib wants it.
pub fn cstr(s: [:0]const u8) [*:0]const u8 {
    return s.ptr;
}

/// A `const char *` parameter raylib documents or handles as nullable, e.g.
/// `LoadShader`'s file names.
pub fn optCstr(s: ?[:0]const u8) ?[*:0]const u8 {
    return if (s) |str| str.ptr else null;
}

/// A `const char *` raylib owns: a static buffer or its own internal storage,
/// so the slice is valid until raylib overwrites it (see each function's docs).
pub fn span(s: [*:0]const u8) [:0]const u8 {
    return std.mem.span(s);
}

/// A `const char *` raylib owns and may return as `NULL`.
pub fn optSpan(s: ?[*:0]const u8) ?[:0]const u8 {
    return if (s) |str| std.mem.span(str) else null;
}

/// A `char *` the caller must release: raylib's NUL-terminated allocation, as
/// the slice the matching unload function takes back.
pub fn ownedSpan(s: [*:0]u8) [:0]u8 {
    return std.mem.span(s);
}

/// A `char *` the caller must release and raylib may return as `NULL`.
pub fn optOwnedSpan(s: ?[*:0]u8) ?[:0]u8 {
    return if (s) |str| std.mem.span(str) else null;
}

/// Asserts at compile time that `Mirror` has raylib's translated `C`'s layout
/// exactly: the same size, the same alignment, the same number of fields, and,
/// for every field of `C`, a `Mirror` field of the same name, at the same
/// offset, with the same size.
///
/// A drift in raylib's header, or a typo in a mirror, is then a compile error
/// rather than a crash at runtime.
pub fn assertLayout(comptime Mirror: type, comptime C: type) void {
    @setEvalBranchQuota(100_000);
    if (@sizeOf(Mirror) != @sizeOf(C)) @compileError(std.fmt.comptimePrint(
        "assertLayout: " ++ @typeName(Mirror) ++ " is {d} bytes, " ++ @typeName(C) ++ " is {d}",
        .{ @sizeOf(Mirror), @sizeOf(C) },
    ));
    if (@alignOf(Mirror) != @alignOf(C)) @compileError(std.fmt.comptimePrint(
        "assertLayout: " ++ @typeName(Mirror) ++ " is {d}-aligned, " ++ @typeName(C) ++ " is {d}",
        .{ @alignOf(Mirror), @alignOf(C) },
    ));

    const mirror_info = @typeInfo(Mirror).@"struct";
    const c_info = @typeInfo(C).@"struct";
    if (mirror_info.field_names.len != c_info.field_names.len) @compileError(std.fmt.comptimePrint(
        "assertLayout: " ++ @typeName(Mirror) ++ " has {d} fields, " ++ @typeName(C) ++ " has {d}",
        .{ mirror_info.field_names.len, c_info.field_names.len },
    ));

    for (c_info.field_names, c_info.field_types) |c_name, c_type| {
        const index = fieldIndex(mirror_info, c_name) orelse @compileError(
            "assertLayout: " ++ @typeName(Mirror) ++ " has no field named " ++ c_name,
        );
        const mirror_type = mirror_info.field_types[index];
        if (@offsetOf(Mirror, c_name) != @offsetOf(C, c_name)) @compileError(std.fmt.comptimePrint(
            "assertLayout: " ++ @typeName(Mirror) ++ "." ++ c_name ++ " is at offset {d}, " ++
                @typeName(C) ++ "." ++ c_name ++ " is at {d}",
            .{ @offsetOf(Mirror, c_name), @offsetOf(C, c_name) },
        ));
        if (@sizeOf(mirror_type) != @sizeOf(c_type)) @compileError(std.fmt.comptimePrint(
            "assertLayout: " ++ @typeName(Mirror) ++ "." ++ c_name ++ " is {d} bytes, " ++
                @typeName(C) ++ "." ++ c_name ++ " is {d}",
            .{ @sizeOf(mirror_type), @sizeOf(c_type) },
        ));
    }
}

/// The index of the field named `name` in a struct's type info, or `null`.
fn fieldIndex(comptime info: std.builtin.Type.Struct, comptime name: []const u8) ?usize {
    for (info.field_names, 0..) |field_name, index| {
        if (std.mem.eql(u8, field_name, name)) return index;
    }
    return null;
}

/// Asserts at compile time that every field of the enum `E` carries the value of
/// the translated constant whose name is the field's name in upper case:
/// `.key_a` against `c.KEY_A`, `.log_all` against `c.LOG_ALL`.
///
/// The C names and the Zig names are then one table, not two that can drift.
pub fn assertEnumValues(comptime E: type, comptime c: type) void {
    // A long enum (`KeyboardKey` has 110 fields, each a name to upper-case) is
    // more comptime work than the default branch quota allows.
    @setEvalBranchQuota(1_000_000);
    const info = @typeInfo(E).@"enum";
    if (@sizeOf(info.tag_type) != @sizeOf(c_int)) @compileError(std.fmt.comptimePrint(
        "assertEnumValues: " ++ @typeName(E) ++ " is backed by " ++ @typeName(info.tag_type) ++
            ", raylib's enums are int",
        .{},
    ));
    inline for (info.field_names, info.field_values) |name, value| {
        const c_name = constantNamed(c, name) orelse @compileError(std.fmt.comptimePrint(
            "assertEnumValues: " ++ @typeName(c) ++ " has no constant named " ++ name ++
                " (ignoring case) for " ++ @typeName(E) ++ "." ++ name,
            .{},
        ));
        if (@as(c_int, @intCast(value)) != @field(c, c_name)) @compileError(std.fmt.comptimePrint(
            "assertEnumValues: " ++ @typeName(E) ++ "." ++ name ++ " is {d}, " ++
                @typeName(c) ++ "." ++ c_name ++ " is {d}",
            .{ value, @field(c, c_name) },
        ));
    }
}

/// The constant of `c` that belongs to the enum field named `name`: the decl
/// whose name is the field name, ignoring case. Case is not a reliable
/// direction, because raylib spells two of its constants
/// (`PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA`) with a lower-case `x`.
fn constantNamed(comptime c: type, comptime name: [:0]const u8) ?[:0]const u8 {
    @setEvalBranchQuota(1_000_000);
    for (@typeInfo(c).@"struct".decl_names) |decl_name| {
        if (decl_name.len != name.len) continue;
        if (std.ascii.eqlIgnoreCase(decl_name, name)) return decl_name;
    }
    return null;
}

/// Asserts at compile time that every boolean field of the packed struct
/// `Flags` sits at the bit the translated constant of the field's name in upper
/// case sets: `.flag_vsync_hint` against `c.FLAG_VSYNC_HINT`.
///
/// Padding fields (whose names start with `_`) and non-boolean fields are
/// skipped; the C constants are the flags raylib defines.
pub fn assertFlagBits(comptime Flags: type, comptime c: type) void {
    @setEvalBranchQuota(1_000_000);
    const info = @typeInfo(Flags).@"struct";
    inline for (info.field_names, info.field_types) |name, FieldType| {
        if (name[0] == '_') continue;
        if (FieldType != bool) continue;
        const c_name = constantNamed(c, name) orelse @compileError(std.fmt.comptimePrint(
            "assertFlagBits: " ++ @typeName(c) ++ " has no constant named " ++ name ++
                " (ignoring case) for " ++ @typeName(Flags) ++ "." ++ name,
            .{},
        ));
        const value: u32 = @intCast(@field(c, c_name));
        if (@bitOffsetOf(Flags, name) != @ctz(value)) @compileError(std.fmt.comptimePrint(
            "assertFlagBits: " ++ @typeName(Flags) ++ "." ++ name ++ " is bit {d}, " ++
                @typeName(c) ++ "." ++ c_name ++ " is bit {d}",
            .{ @bitOffsetOf(Flags, name), @ctz(value) },
        ));
    }
}

const Point = extern struct {
    x: f32,
    y: f32,
};

test "cast.as reinterprets a mirrored value as the translated type" {
    const CPoint = extern struct {
        x: f32,
        y: f32,
    };

    try std.testing.expectEqual(@as(usize, 8), @sizeOf(Point));
    var translated: CPoint = as(CPoint, Point{ .x = 1.5, .y = -2.25 });
    try std.testing.expectEqual(@as(f32, 1.5), translated.x);
    try std.testing.expectEqual(@as(f32, -2.25), translated.y);

    translated.y = 3.0;
    const mirrored: Point = as(Point, translated);
    try std.testing.expectEqual(@as(f32, 3.0), mirrored.y);
}

test "cast.asPtr and cast.asConstPtr point at the same bytes" {
    const CPoint = extern struct {
        x: f32,
        y: f32,
    };

    var point = Point{ .x = 4, .y = 5 };
    const c_point: *CPoint = asPtr(CPoint, &point);
    try std.testing.expectEqual(@as(f32, 4), c_point.x);
    c_point.y = 6;
    try std.testing.expectEqual(@as(f32, 6), point.y);

    const const_point: *const CPoint = asConstPtr(CPoint, &point);
    try std.testing.expectEqual(@as(f32, 6), const_point.y);
}

test "cast.asArrayPtr, asArrayPtrMut and asLen describe the same slice" {
    const CPoint = extern struct {
        x: f32,
        y: f32,
    };

    var points = [_]Point{ .{ .x = 1, .y = 2 }, .{ .x = 3, .y = 4 } };
    const read: [*]const CPoint = asArrayPtr(CPoint, &points);
    try std.testing.expectEqual(@as(f32, 3), read[1].x);
    try std.testing.expectEqual(@as(i32, 2), asLen(&points));

    const written: [*]CPoint = asArrayPtrMut(CPoint, &points);
    written[0].y = 7;
    try std.testing.expectEqual(@as(f32, 7), points[0].y);
}

test "cast.asSlice turns raylib's pointer-and-count pair into a slice" {
    var buffer = [_]u8{ 1, 2, 3 };
    const slice = asSlice(u8, &buffer, 3) orelse return error.ExpectedSlice;
    try std.testing.expectEqual(@as(usize, 3), slice.len);
    try std.testing.expectEqual(@as(u8, 2), slice[1]);

    try std.testing.expect(asSlice(u8, null, 0) == null);
    try std.testing.expectEqual(@as(usize, 0), asSlice(u8, &buffer, 0).?.len);
}

test "cast text helpers pass Zig strings and read raylib's back" {
    const hello: [:0]const u8 = "hello";
    try std.testing.expectEqualStrings("hello", std.mem.span(cstr(hello)));
    try std.testing.expect(optCstr(null) == null);
    try std.testing.expectEqualStrings("hello", std.mem.span(optCstr(hello).?));
    try std.testing.expectEqualStrings("hello", span(@ptrCast(hello.ptr)));
    try std.testing.expect(optSpan(null) == null);
    try std.testing.expectEqualStrings("hello", optSpan(@ptrCast(hello.ptr)).?);

    var owned: [6:0]u8 = "hello".* ++ .{0};
    const released: [:0]u8 = ownedSpan(&owned);
    try std.testing.expectEqualStrings("hello", released);
    try std.testing.expect(optOwnedSpan(null) == null);
}

test "cast.assertLayout accepts a mirror that matches its translated type" {
    const CMirror = extern struct {
        flag: bool,
        count: c_int,
        name: [8]u8,
        values: [2]f32,
        data: ?*anyopaque,
    };
    const Mirror = extern struct {
        flag: bool,
        count: i32,
        name: [8]u8,
        values: [2]f32,
        data: ?*anyopaque,

        comptime {
            assertLayout(@This(), CMirror);
        }
    };

    try std.testing.expectEqual(@sizeOf(CMirror), @sizeOf(Mirror));
}

test "cast.assertEnumValues checks an enum against the translated constants" {
    const C = struct {
        pub const THING_ONE: c_int = 1;
        pub const THING_TWO: c_int = 4;
    };
    const Thing = enum(c_int) {
        thing_one = 1,
        thing_two = 4,
        _,

        comptime {
            assertEnumValues(@This(), C);
        }
    };

    try std.testing.expectEqual(@as(c_int, 1), @backingInt(Thing.thing_one));
}

test "cast.assertFlagBits checks a flag set against the translated constants" {
    const C = struct {
        pub const FLAG_TWO: c_int = 0b10;
        pub const FLAG_THREE: c_int = 0b100;
    };
    const Flags = packed struct(u4) {
        _0: u1 = 0,
        flag_two: bool = false,
        flag_three: bool = false,
        _1: u1 = 0,

        comptime {
            assertFlagBits(@This(), C);
        }
    };

    try std.testing.expectEqual(@as(u4, 0b110), @as(u4, @bitCast(Flags{ .flag_two = true, .flag_three = true })));
}
