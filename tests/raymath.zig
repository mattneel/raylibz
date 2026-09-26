//! raymath's half of raylibz's tests: the table that says where each of
//! raymath.h's 146 functions lives in raylibz, and the test that calls raylibz's
//! wrapper and raylib's own translated function on the same inputs and compares
//! their results bit for bit.
//!
//! The table is the mapping `tests/parity.zig` checks raymath against, so a
//! raymath function with no entry, and an entry whose wrapper is missing, both
//! fail the parity test. This file walks the same table, so the mapping cannot
//! drift from what it names: every entry is called on both sides.
//!
//! Three functions write their extra results through pointers
//! (`Vector3OrthoNormalize`, `QuaternionToAxisAngle` and `MatrixDecompose`), and
//! raylibz returns them instead; those three calls are written out. Every other
//! function is called generically, from the types raylib's own declaration takes.

const std = @import("std");
const raylibz = @import("raylibz");

const cast = raylibz.cast;
const math = raylibz.math;
/// raylib's own translated `raymath.h`: the other side of every comparison.
const c = raylibz.raymath;

const Matrix = raylibz.Matrix;
const Quaternion = raylibz.Quaternion;
const Vector2 = raylibz.Vector2;
const Vector3 = raylibz.Vector3;
const Vector4 = raylibz.Vector4;

/// The declaration that holds a raymath function in raylibz.
pub const Owner = enum {
    /// A method on `raylibz.Vector2`.
    vector2,
    /// A method on `raylibz.Vector3`.
    vector3,
    /// A method on `raylibz.Vector4`, and so on `raylibz.Quaternion`.
    vector4,
    /// A method on `raylibz.Matrix`.
    matrix,
    /// A free function in `raylibz.math`.
    math,

    /// The declaration that holds a name this owner maps: the type for a
    /// method, the `math` file for a free function.
    pub fn holder(owner: Owner) type {
        return switch (owner) {
            .vector2 => Vector2,
            .vector3 => Vector3,
            .vector4 => Vector4,
            .matrix => Matrix,
            .math => math,
        };
    }
};

/// One raymath function and where raylibz puts it.
pub const Mapping = struct {
    /// raymath.h's name, exactly as the header spells it, e.g. `"Vector2Add"`.
    c_name: []const u8,
    /// The declaration that holds it.
    owner: Owner,
    /// raylibz's name for it: a method's name without its type prefix
    /// (`"add"`), or a free function's whole name (`"quaternionSlerp"`).
    zig_name: []const u8,
};

/// Every one of raymath.h's 146 functions, in raymath.h order.
pub const mappings = [_]Mapping{
    .{ .c_name = "Clamp", .owner = .math, .zig_name = "clamp" },
    .{ .c_name = "Lerp", .owner = .math, .zig_name = "lerp" },
    .{ .c_name = "Normalize", .owner = .math, .zig_name = "normalize" },
    .{ .c_name = "Remap", .owner = .math, .zig_name = "remap" },
    .{ .c_name = "Wrap", .owner = .math, .zig_name = "wrap" },
    .{ .c_name = "FloatEquals", .owner = .math, .zig_name = "floatEquals" },
    .{ .c_name = "Vector2Zero", .owner = .vector2, .zig_name = "zero" },
    .{ .c_name = "Vector2One", .owner = .vector2, .zig_name = "one" },
    .{ .c_name = "Vector2Add", .owner = .vector2, .zig_name = "add" },
    .{ .c_name = "Vector2AddValue", .owner = .vector2, .zig_name = "addValue" },
    .{ .c_name = "Vector2Subtract", .owner = .vector2, .zig_name = "subtract" },
    .{ .c_name = "Vector2SubtractValue", .owner = .vector2, .zig_name = "subtractValue" },
    .{ .c_name = "Vector2Length", .owner = .vector2, .zig_name = "length" },
    .{ .c_name = "Vector2LengthSqr", .owner = .vector2, .zig_name = "lengthSqr" },
    .{ .c_name = "Vector2DotProduct", .owner = .vector2, .zig_name = "dotProduct" },
    .{ .c_name = "Vector2CrossProduct", .owner = .vector2, .zig_name = "crossProduct" },
    .{ .c_name = "Vector2Distance", .owner = .vector2, .zig_name = "distance" },
    .{ .c_name = "Vector2DistanceSqr", .owner = .vector2, .zig_name = "distanceSqr" },
    .{ .c_name = "Vector2Angle", .owner = .vector2, .zig_name = "angle" },
    .{ .c_name = "Vector2LineAngle", .owner = .vector2, .zig_name = "lineAngle" },
    .{ .c_name = "Vector2Scale", .owner = .vector2, .zig_name = "scale" },
    .{ .c_name = "Vector2Multiply", .owner = .vector2, .zig_name = "multiply" },
    .{ .c_name = "Vector2Negate", .owner = .vector2, .zig_name = "negate" },
    .{ .c_name = "Vector2Divide", .owner = .vector2, .zig_name = "divide" },
    .{ .c_name = "Vector2Normalize", .owner = .vector2, .zig_name = "normalize" },
    .{ .c_name = "Vector2Transform", .owner = .vector2, .zig_name = "transform" },
    .{ .c_name = "Vector2Lerp", .owner = .vector2, .zig_name = "lerp" },
    .{ .c_name = "Vector2Reflect", .owner = .vector2, .zig_name = "reflect" },
    .{ .c_name = "Vector2Min", .owner = .vector2, .zig_name = "min" },
    .{ .c_name = "Vector2Max", .owner = .vector2, .zig_name = "max" },
    .{ .c_name = "Vector2Rotate", .owner = .vector2, .zig_name = "rotate" },
    .{ .c_name = "Vector2MoveTowards", .owner = .vector2, .zig_name = "moveTowards" },
    .{ .c_name = "Vector2Invert", .owner = .vector2, .zig_name = "invert" },
    .{ .c_name = "Vector2Clamp", .owner = .vector2, .zig_name = "clamp" },
    .{ .c_name = "Vector2ClampValue", .owner = .vector2, .zig_name = "clampValue" },
    .{ .c_name = "Vector2Equals", .owner = .vector2, .zig_name = "equals" },
    .{ .c_name = "Vector2Refract", .owner = .vector2, .zig_name = "refract" },
    .{ .c_name = "Vector3Zero", .owner = .vector3, .zig_name = "zero" },
    .{ .c_name = "Vector3One", .owner = .vector3, .zig_name = "one" },
    .{ .c_name = "Vector3Add", .owner = .vector3, .zig_name = "add" },
    .{ .c_name = "Vector3AddValue", .owner = .vector3, .zig_name = "addValue" },
    .{ .c_name = "Vector3Subtract", .owner = .vector3, .zig_name = "subtract" },
    .{ .c_name = "Vector3SubtractValue", .owner = .vector3, .zig_name = "subtractValue" },
    .{ .c_name = "Vector3Scale", .owner = .vector3, .zig_name = "scale" },
    .{ .c_name = "Vector3Multiply", .owner = .vector3, .zig_name = "multiply" },
    .{ .c_name = "Vector3CrossProduct", .owner = .vector3, .zig_name = "crossProduct" },
    .{ .c_name = "Vector3Perpendicular", .owner = .vector3, .zig_name = "perpendicular" },
    .{ .c_name = "Vector3Length", .owner = .vector3, .zig_name = "length" },
    .{ .c_name = "Vector3LengthSqr", .owner = .vector3, .zig_name = "lengthSqr" },
    .{ .c_name = "Vector3DotProduct", .owner = .vector3, .zig_name = "dotProduct" },
    .{ .c_name = "Vector3Distance", .owner = .vector3, .zig_name = "distance" },
    .{ .c_name = "Vector3DistanceSqr", .owner = .vector3, .zig_name = "distanceSqr" },
    .{ .c_name = "Vector3Angle", .owner = .vector3, .zig_name = "angle" },
    .{ .c_name = "Vector3Negate", .owner = .vector3, .zig_name = "negate" },
    .{ .c_name = "Vector3Divide", .owner = .vector3, .zig_name = "divide" },
    .{ .c_name = "Vector3Normalize", .owner = .vector3, .zig_name = "normalize" },
    .{ .c_name = "Vector3Project", .owner = .vector3, .zig_name = "project" },
    .{ .c_name = "Vector3Reject", .owner = .vector3, .zig_name = "reject" },
    .{ .c_name = "Vector3OrthoNormalize", .owner = .vector3, .zig_name = "orthoNormalize" },
    .{ .c_name = "Vector3Transform", .owner = .vector3, .zig_name = "transform" },
    .{ .c_name = "Vector3RotateByQuaternion", .owner = .vector3, .zig_name = "rotateByQuaternion" },
    .{ .c_name = "Vector3RotateByAxisAngle", .owner = .vector3, .zig_name = "rotateByAxisAngle" },
    .{ .c_name = "Vector3MoveTowards", .owner = .vector3, .zig_name = "moveTowards" },
    .{ .c_name = "Vector3Lerp", .owner = .vector3, .zig_name = "lerp" },
    .{ .c_name = "Vector3CubicHermite", .owner = .vector3, .zig_name = "cubicHermite" },
    .{ .c_name = "Vector3Reflect", .owner = .vector3, .zig_name = "reflect" },
    .{ .c_name = "Vector3Min", .owner = .vector3, .zig_name = "min" },
    .{ .c_name = "Vector3Max", .owner = .vector3, .zig_name = "max" },
    .{ .c_name = "Vector3Barycenter", .owner = .vector3, .zig_name = "barycenter" },
    .{ .c_name = "Vector3Unproject", .owner = .vector3, .zig_name = "unproject" },
    .{ .c_name = "Vector3ToFloatV", .owner = .vector3, .zig_name = "toFloatV" },
    .{ .c_name = "Vector3Invert", .owner = .vector3, .zig_name = "invert" },
    .{ .c_name = "Vector3Clamp", .owner = .vector3, .zig_name = "clamp" },
    .{ .c_name = "Vector3ClampValue", .owner = .vector3, .zig_name = "clampValue" },
    .{ .c_name = "Vector3Equals", .owner = .vector3, .zig_name = "equals" },
    .{ .c_name = "Vector3Refract", .owner = .vector3, .zig_name = "refract" },
    .{ .c_name = "Vector4Zero", .owner = .vector4, .zig_name = "zero" },
    .{ .c_name = "Vector4One", .owner = .vector4, .zig_name = "one" },
    .{ .c_name = "Vector4Add", .owner = .vector4, .zig_name = "add" },
    .{ .c_name = "Vector4AddValue", .owner = .vector4, .zig_name = "addValue" },
    .{ .c_name = "Vector4Subtract", .owner = .vector4, .zig_name = "subtract" },
    .{ .c_name = "Vector4SubtractValue", .owner = .vector4, .zig_name = "subtractValue" },
    .{ .c_name = "Vector4Length", .owner = .vector4, .zig_name = "length" },
    .{ .c_name = "Vector4LengthSqr", .owner = .vector4, .zig_name = "lengthSqr" },
    .{ .c_name = "Vector4DotProduct", .owner = .vector4, .zig_name = "dotProduct" },
    .{ .c_name = "Vector4Distance", .owner = .vector4, .zig_name = "distance" },
    .{ .c_name = "Vector4DistanceSqr", .owner = .vector4, .zig_name = "distanceSqr" },
    .{ .c_name = "Vector4Scale", .owner = .vector4, .zig_name = "scale" },
    .{ .c_name = "Vector4Multiply", .owner = .vector4, .zig_name = "multiply" },
    .{ .c_name = "Vector4Negate", .owner = .vector4, .zig_name = "negate" },
    .{ .c_name = "Vector4Divide", .owner = .vector4, .zig_name = "divide" },
    .{ .c_name = "Vector4Normalize", .owner = .vector4, .zig_name = "normalize" },
    .{ .c_name = "Vector4Min", .owner = .vector4, .zig_name = "min" },
    .{ .c_name = "Vector4Max", .owner = .vector4, .zig_name = "max" },
    .{ .c_name = "Vector4Lerp", .owner = .vector4, .zig_name = "lerp" },
    .{ .c_name = "Vector4MoveTowards", .owner = .vector4, .zig_name = "moveTowards" },
    .{ .c_name = "Vector4Invert", .owner = .vector4, .zig_name = "invert" },
    .{ .c_name = "Vector4Equals", .owner = .vector4, .zig_name = "equals" },
    .{ .c_name = "MatrixDeterminant", .owner = .matrix, .zig_name = "determinant" },
    .{ .c_name = "MatrixTrace", .owner = .matrix, .zig_name = "trace" },
    .{ .c_name = "MatrixTranspose", .owner = .matrix, .zig_name = "transpose" },
    .{ .c_name = "MatrixInvert", .owner = .matrix, .zig_name = "invert" },
    .{ .c_name = "MatrixIdentity", .owner = .matrix, .zig_name = "identity" },
    .{ .c_name = "MatrixAdd", .owner = .matrix, .zig_name = "add" },
    .{ .c_name = "MatrixSubtract", .owner = .matrix, .zig_name = "subtract" },
    .{ .c_name = "MatrixMultiply", .owner = .matrix, .zig_name = "multiply" },
    .{ .c_name = "MatrixMultiplyValue", .owner = .matrix, .zig_name = "multiplyValue" },
    .{ .c_name = "MatrixTranslate", .owner = .matrix, .zig_name = "translate" },
    .{ .c_name = "MatrixRotate", .owner = .matrix, .zig_name = "rotate" },
    .{ .c_name = "MatrixRotateX", .owner = .matrix, .zig_name = "rotateX" },
    .{ .c_name = "MatrixRotateY", .owner = .matrix, .zig_name = "rotateY" },
    .{ .c_name = "MatrixRotateZ", .owner = .matrix, .zig_name = "rotateZ" },
    .{ .c_name = "MatrixRotateXYZ", .owner = .matrix, .zig_name = "rotateXYZ" },
    .{ .c_name = "MatrixRotateZYX", .owner = .matrix, .zig_name = "rotateZYX" },
    .{ .c_name = "MatrixScale", .owner = .matrix, .zig_name = "scale" },
    .{ .c_name = "MatrixFrustum", .owner = .matrix, .zig_name = "frustum" },
    .{ .c_name = "MatrixPerspective", .owner = .matrix, .zig_name = "perspective" },
    .{ .c_name = "MatrixOrtho", .owner = .matrix, .zig_name = "ortho" },
    .{ .c_name = "MatrixLookAt", .owner = .matrix, .zig_name = "lookAt" },
    .{ .c_name = "MatrixToFloatV", .owner = .matrix, .zig_name = "toFloatV" },
    .{ .c_name = "QuaternionAdd", .owner = .math, .zig_name = "quaternionAdd" },
    .{ .c_name = "QuaternionAddValue", .owner = .math, .zig_name = "quaternionAddValue" },
    .{ .c_name = "QuaternionSubtract", .owner = .math, .zig_name = "quaternionSubtract" },
    .{ .c_name = "QuaternionSubtractValue", .owner = .math, .zig_name = "quaternionSubtractValue" },
    .{ .c_name = "QuaternionIdentity", .owner = .math, .zig_name = "quaternionIdentity" },
    .{ .c_name = "QuaternionLength", .owner = .math, .zig_name = "quaternionLength" },
    .{ .c_name = "QuaternionNormalize", .owner = .math, .zig_name = "quaternionNormalize" },
    .{ .c_name = "QuaternionInvert", .owner = .math, .zig_name = "quaternionInvert" },
    .{ .c_name = "QuaternionMultiply", .owner = .math, .zig_name = "quaternionMultiply" },
    .{ .c_name = "QuaternionScale", .owner = .math, .zig_name = "quaternionScale" },
    .{ .c_name = "QuaternionDivide", .owner = .math, .zig_name = "quaternionDivide" },
    .{ .c_name = "QuaternionLerp", .owner = .math, .zig_name = "quaternionLerp" },
    .{ .c_name = "QuaternionNlerp", .owner = .math, .zig_name = "quaternionNlerp" },
    .{ .c_name = "QuaternionSlerp", .owner = .math, .zig_name = "quaternionSlerp" },
    .{ .c_name = "QuaternionCubicHermiteSpline", .owner = .math, .zig_name = "quaternionCubicHermiteSpline" },
    .{ .c_name = "QuaternionFromVector3ToVector3", .owner = .math, .zig_name = "quaternionFromVector3ToVector3" },
    .{ .c_name = "QuaternionFromMatrix", .owner = .math, .zig_name = "quaternionFromMatrix" },
    .{ .c_name = "QuaternionToMatrix", .owner = .math, .zig_name = "quaternionToMatrix" },
    .{ .c_name = "QuaternionFromAxisAngle", .owner = .math, .zig_name = "quaternionFromAxisAngle" },
    .{ .c_name = "QuaternionToAxisAngle", .owner = .math, .zig_name = "quaternionToAxisAngle" },
    .{ .c_name = "QuaternionFromEuler", .owner = .math, .zig_name = "quaternionFromEuler" },
    .{ .c_name = "QuaternionToEuler", .owner = .math, .zig_name = "quaternionToEuler" },
    .{ .c_name = "QuaternionTransform", .owner = .math, .zig_name = "quaternionTransform" },
    .{ .c_name = "QuaternionEquals", .owner = .math, .zig_name = "quaternionEquals" },
    .{ .c_name = "MatrixCompose", .owner = .matrix, .zig_name = "compose" },
    .{ .c_name = "MatrixDecompose", .owner = .matrix, .zig_name = "decompose" },
};

/// How many rounds of inputs each check runs, drawing fresh values each round,
/// so that every check sees the fixed edge cases and the pseudo-random values
/// both.
const rounds = 8;

test "raymath: raylibz's wrapper and raylib's own function agree, bit for bit" {
    var sampler = Sampler.init();
    inline for (mappings) |mapping| try check(mapping, &sampler);
}

/// Calls both sides of one mapping on the same inputs and compares the results:
/// the written-out check for the three functions that write through pointers,
/// the generic one for every other function.
fn check(comptime mapping: Mapping, sampler: *Sampler) !void {
    if (comptime pointerResults(mapping.c_name)) |pointer_check| {
        return pointer_check(sampler);
    } else {
        return compareWithRaylib(mapping, sampler);
    }
}

/// Calls raylib's own function and raylibz's wrapper with the same arguments,
/// `rounds` times, and compares the two results bit for bit.
fn compareWithRaylib(comptime mapping: Mapping, sampler: *Sampler) !void {
    const theirs_fn = @field(c, mapping.c_name);
    const mine_fn = @field(mapping.owner.holder(), mapping.zig_name);
    const param_types = @typeInfo(@TypeOf(theirs_fn)).@"fn".param_types;

    for (0..rounds) |_| {
        var theirs_args: std.meta.ArgsTuple(@TypeOf(theirs_fn)) = undefined;
        var mine_args: std.meta.ArgsTuple(@TypeOf(mine_fn)) = undefined;
        inline for (param_types, 0..) |param_type, index| {
            const Translated = param_type.?;
            const Mirrored = Mirror(Translated);
            const value: Mirrored = sampler.value(Mirrored);
            mine_args[index] = value;
            theirs_args[index] = cast.as(Translated, value);
        }
        try same(@call(.auto, mine_fn, mine_args), @call(.auto, theirs_fn, theirs_args));
    }
}

/// The mirrored type raylibz spells a translated raymath parameter type with.
fn Mirror(comptime Translated: type) type {
    return switch (Translated) {
        c.Vector2 => Vector2,
        c.Vector3 => Vector3,
        c.Vector4 => Vector4,
        c.Matrix => Matrix,
        else => Translated,
    };
}

/// Asserts that raylibz's result is raylib's, bit for bit, by comparing the
/// bytes of the two values.
///
/// `bool` is the one spelling raylib does not have: it answers `FloatEquals` and
/// the `*Equals` family with an `int`, so a `bool` is widened to the `int`
/// raylib returns before the comparison.
fn same(mine: anytype, theirs: anytype) !void {
    if (comptime @TypeOf(mine) == bool) {
        return same(@as(c_int, @intFromBool(mine)), theirs);
    }
    const mine_bytes = std.mem.asBytes(&mine);
    const theirs_bytes = std.mem.asBytes(&theirs);
    try std.testing.expectEqual(theirs_bytes.len, mine_bytes.len);
    try std.testing.expectEqualSlices(u8, theirs_bytes, mine_bytes);
}

/// The checks for the three raymath functions that write their extra results
/// through pointers, where raylibz returns them instead.
const pointer_results = [_]struct { c_name: []const u8, check: *const fn (*Sampler) anyerror!void }{
    .{ .c_name = "Vector3OrthoNormalize", .check = checkOrthoNormalize },
    .{ .c_name = "QuaternionToAxisAngle", .check = checkQuaternionToAxisAngle },
    .{ .c_name = "MatrixDecompose", .check = checkMatrixDecompose },
};

/// The written-out check for a raymath function that writes through pointers,
/// or `null` for the functions that are called generically.
fn pointerResults(comptime c_name: []const u8) ?*const fn (*Sampler) anyerror!void {
    comptime {
        for (pointer_results) |entry| {
            if (std.mem.eql(u8, entry.c_name, c_name)) return entry.check;
        }
        return null;
    }
}

/// `Vector3OrthoNormalize(Vector3 *v1, Vector3 *v2)`: raylib writes both vectors
/// through pointers, raylibz returns the pair.
fn checkOrthoNormalize(sampler: *Sampler) !void {
    const v1 = sampler.vector3();
    const v2 = sampler.vector3();
    const mine = v1.orthoNormalize(v2);
    var theirs_v1 = cast.as(c.Vector3, v1);
    var theirs_v2 = cast.as(c.Vector3, v2);
    c.Vector3OrthoNormalize(&theirs_v1, &theirs_v2);
    try same(mine.v1, theirs_v1);
    try same(mine.v2, theirs_v2);
}

/// `QuaternionToAxisAngle(Quaternion q, Vector3 *outAxis, float *outAngle)`.
fn checkQuaternionToAxisAngle(sampler: *Sampler) !void {
    const q = sampler.vector4();
    const mine = math.quaternionToAxisAngle(q);
    var theirs_axis: c.Vector3 = .{};
    var theirs_angle: f32 = 0;
    c.QuaternionToAxisAngle(cast.as(c.Quaternion, q), &theirs_axis, &theirs_angle);
    try same(mine.outAxis, theirs_axis);
    try same(mine.outAngle, theirs_angle);
}

/// `MatrixDecompose(Matrix mat, Vector3 *translation, Quaternion *rotation,
/// Vector3 *scale)`.
fn checkMatrixDecompose(sampler: *Sampler) !void {
    const mat = sampler.matrix();
    const mine = mat.decompose();
    var theirs_translation: c.Vector3 = .{};
    var theirs_rotation: c.Quaternion = .{};
    var theirs_scale: c.Vector3 = .{};
    c.MatrixDecompose(cast.as(c.Matrix, mat), &theirs_translation, &theirs_rotation, &theirs_scale);
    try same(mine.translation, theirs_translation);
    try same(mine.rotation, theirs_rotation);
    try same(mine.scale, theirs_scale);
}

/// The inputs every check draws from: a pool of fixed edge cases each generator
/// walks through (the zero and unit vectors, the identity and the zero matrix,
/// halves, tiny and huge values), and pseudo-random values from a fixed seed in
/// between. One `Sampler` is shared by every check, so the sequence of inputs is
/// fixed and a failure reproduces exactly.
const Sampler = struct {
    /// The seed for the pseudo-random half of the inputs.
    const seed: u64 = 0x5eed_2026_c0ffee;

    /// How many draws there are between one pseudo-random value and the next:
    /// the other draws in the cycle are the edge cases.
    const cycle = 8;

    prng: std.Random.DefaultPrng,
    /// How many values have been drawn, which picks the next edge case.
    draw: usize = 0,

    fn init() Sampler {
        return .{ .prng = std.Random.DefaultPrng.init(seed) };
    }

    /// The next `f32`: zero, one, minus one, a half, minus two and a half, a
    /// tiny value, a huge value, and then a pseudo-random one in [-2, 2).
    ///
    /// `float` and not `f32`: a declaration may not shadow a primitive type.
    fn float(self: *Sampler) f32 {
        self.draw += 1;
        return switch (self.draw % cycle) {
            0 => 0.0,
            1 => 1.0,
            2 => -1.0,
            3 => 0.5,
            4 => -2.5,
            5 => 1.0e-7,
            6 => 1.0e7,
            else => (self.prng.random().float(f32) - 0.5) * 4.0,
        };
    }

    /// The next `f64`, what raylib spells `double` in the projection matrices.
    fn double(self: *Sampler) f64 {
        return self.float();
    }

    /// The next `Vector2`: the zero vector, the unit vectors, the two diagonals,
    /// an axis vector, and pseudo-random ones.
    fn vector2(self: *Sampler) Vector2 {
        self.draw += 1;
        return switch (self.draw % cycle) {
            0 => .{ .x = 0, .y = 0 },
            1 => .{ .x = 1, .y = 0 },
            2 => .{ .x = 0, .y = 1 },
            3 => .{ .x = -1, .y = 1 },
            4 => .{ .x = 1, .y = -1 },
            5 => .{ .x = self.float(), .y = 0 },
            else => .{ .x = self.float(), .y = self.float() },
        };
    }

    /// The next `Vector3`: the zero vector, the unit vectors, a negative corner,
    /// an axis vector, one axis plane, and pseudo-random ones.
    fn vector3(self: *Sampler) Vector3 {
        self.draw += 1;
        return switch (self.draw % cycle) {
            0 => .{ .x = 0, .y = 0, .z = 0 },
            1 => .{ .x = 1, .y = 0, .z = 0 },
            2 => .{ .x = 0, .y = 1, .z = 0 },
            3 => .{ .x = 0, .y = 0, .z = 1 },
            4 => .{ .x = -1, .y = 1, .z = -1 },
            5 => .{ .x = self.float(), .y = 0, .z = 0 },
            6 => .{ .x = self.float(), .y = self.float(), .z = 0 },
            else => .{ .x = self.float(), .y = self.float(), .z = self.float() },
        };
    }

    /// The next `Vector4`, which is also `Quaternion`: the zero and the identity
    /// quaternion, half turns about the axes, a quarter turn, a small rotation,
    /// and pseudo-random ones.
    fn vector4(self: *Sampler) Vector4 {
        self.draw += 1;
        return switch (self.draw % cycle) {
            0 => .{ .x = 0, .y = 0, .z = 0, .w = 0 },
            1 => .{ .x = 0, .y = 0, .z = 0, .w = 1 },
            2 => .{ .x = 1, .y = 0, .z = 0, .w = 0 },
            3 => .{ .x = 0, .y = 1, .z = 0, .w = 0 },
            4 => .{ .x = 0.70710677, .y = 0, .z = 0, .w = 0.70710677 },
            5 => .{ .x = 0.1, .y = -0.2, .z = 0.3, .w = 0.9 },
            6 => .{ .x = self.float(), .y = self.float(), .z = 0, .w = 1 },
            else => .{ .x = self.float(), .y = self.float(), .z = self.float(), .w = self.float() },
        };
    }

    /// The next `Matrix`: the identity, the zero matrix (singular), a scale, a
    /// translation, a rotation about x, a sheared transform, a partial scale,
    /// and pseudo-random ones.
    fn matrix(self: *Sampler) Matrix {
        self.draw += 1;
        return switch (self.draw % cycle) {
            0 => diagonal(1, 1, 1),
            1 => std.mem.zeroes(Matrix),
            2 => diagonal(2, 3, 4),
            3 => translation(1, 2, -3),
            4 => rotationAboutX(1.0),
            5 => sheared(),
            6 => diagonal(self.float(), self.float(), 1),
            else => randomMatrix(self),
        };
    }

    /// A matrix with the given diagonal and a homogeneous 1.
    fn diagonal(x: f32, y: f32, z: f32) Matrix {
        var m = std.mem.zeroes(Matrix);
        m.m0 = x;
        m.m5 = y;
        m.m10 = z;
        m.m15 = 1;
        return m;
    }

    /// A translation matrix: the top three entries of the fourth column.
    fn translation(x: f32, y: f32, z: f32) Matrix {
        var m = diagonal(1, 1, 1);
        m.m12 = x;
        m.m13 = y;
        m.m14 = z;
        return m;
    }

    /// A rotation matrix about x, in raymath's `MatrixRotateX` arrangement,
    /// spelled out here so that the sampler does not depend on the wrapper it
    /// feeds.
    fn rotationAboutX(angle: f32) Matrix {
        var m = diagonal(1, 1, 1);
        const cos = @cos(angle);
        const sin = @sin(angle);
        m.m5 = cos;
        m.m6 = sin;
        m.m9 = -sin;
        m.m10 = cos;
        return m;
    }

    /// A matrix whose xy component is sheared, so that `MatrixDecompose` has
    /// shear to remove.
    fn sheared() Matrix {
        var m = diagonal(1, 1, 1);
        m.m1 = 0.5;
        m.m4 = 0.25;
        return m;
    }

    /// A matrix of pseudo-random values.
    fn randomMatrix(self: *Sampler) Matrix {
        var m: Matrix = undefined;
        inline for (@typeInfo(Matrix).@"struct".field_names) |name| {
            @field(m, name) = self.float();
        }
        return m;
    }

    /// The next value of the mirrored type `T`, which is what a raylibz wrapper
    /// takes where raylib's own function takes `Translated`.
    fn value(self: *Sampler, comptime T: type) T {
        return switch (T) {
            f32 => self.float(),
            f64 => self.double(),
            Vector2 => self.vector2(),
            Vector3 => self.vector3(),
            Vector4 => self.vector4(),
            Matrix => self.matrix(),
            else => @compileError("tests/raymath.zig has no sampler for " ++ @typeName(T)),
        };
    }
};
