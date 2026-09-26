//! raymath's free functions: the scalar helpers (`clamp`, `lerp`, `normalize`,
//! `remap`, `wrap`, `floatEquals`) and the whole `Quaternion*` family.
//!
//! The `Vector2*`, `Vector3*`, `Vector4*` and `Matrix*` families are methods on
//! those types, not free functions, because raymath's own names read that way
//! (`Vector2Add(a, b)` → `a.add(b)`). `Quaternion` is raylib's `typedef Vector4
//! Quaternion`, so the `Quaternion*` family cannot be a method without being
//! ambiguous with `Vector4`'s own; it stays here, with raylib's names
//! lowercased (`quaternionAdd`, `quaternionSlerp`).
//!
//! Every function here calls the translated raymath function through `cast.as`
//! conversions, so the result is raymath's own, bit for bit.
//!
//! `tests/raymath.zig` holds the table that maps every raymath function to the
//! free function that wraps it, and calls both sides on the same inputs.
//!
//! This file imports only names the root also publishes (`raymath`, `cast`, the
//! vector files, the matrix file and the type names they hold), because the
//! root's re-export test requires every top-level declaration here to exist in
//! `raylibz` too. Private helpers go in a `const internal = struct { ... };`,
//! which that test skips.

const cast = @import("cast.zig");
const raymath = @import("raymath");
const vector3 = @import("vector3.zig");
const vector4 = @import("vector4.zig");
const matrix = @import("matrix.zig");

const Matrix = matrix.Matrix;
const Quaternion = vector4.Quaternion;
const Vector3 = vector3.Vector3;

/// The functions of raymath.h that raylibz does not wrap, and why. One line
/// each.
pub const not_wrapped = [_]cast.NotWrapped{};

/// Clamp float value
pub fn clamp(value: f32, min: f32, max: f32) f32 {
    return raymath.Clamp(value, min, max);
}

/// Calculate linear interpolation between two floats
pub fn lerp(start: f32, end: f32, amount: f32) f32 {
    return raymath.Lerp(start, end, amount);
}

/// Normalize input value within input range
pub fn normalize(value: f32, start: f32, end: f32) f32 {
    return raymath.Normalize(value, start, end);
}

/// Remap input value within input range to output range
pub fn remap(value: f32, inputStart: f32, inputEnd: f32, outputStart: f32, outputEnd: f32) f32 {
    return raymath.Remap(value, inputStart, inputEnd, outputStart, outputEnd);
}

/// Wrap input value from min to max
pub fn wrap(value: f32, min: f32, max: f32) f32 {
    return raymath.Wrap(value, min, max);
}

/// Check whether two given floats are almost equal
///
/// raylib returns an `int`; raylibz returns the `bool` it means.
pub fn floatEquals(x: f32, y: f32) bool {
    return raymath.FloatEquals(x, y) != 0;
}

/// Add two quaternions
pub fn quaternionAdd(q1: Quaternion, q2: Quaternion) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionAdd(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, q2),
    ));
}

/// Add quaternion and float value
pub fn quaternionAddValue(q: Quaternion, add: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionAddValue(cast.as(raymath.Quaternion, q), add));
}

/// Subtract two quaternions
pub fn quaternionSubtract(q1: Quaternion, q2: Quaternion) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionSubtract(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, q2),
    ));
}

/// Subtract quaternion and float value
pub fn quaternionSubtractValue(q: Quaternion, sub: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionSubtractValue(
        cast.as(raymath.Quaternion, q),
        sub,
    ));
}

/// Get identity quaternion
pub fn quaternionIdentity() Quaternion {
    return cast.as(Quaternion, raymath.QuaternionIdentity());
}

/// Computes the length of a quaternion
pub fn quaternionLength(q: Quaternion) f32 {
    return raymath.QuaternionLength(cast.as(raymath.Quaternion, q));
}

/// Normalize provided quaternion
pub fn quaternionNormalize(q: Quaternion) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionNormalize(cast.as(raymath.Quaternion, q)));
}

/// Invert provided quaternion
pub fn quaternionInvert(q: Quaternion) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionInvert(cast.as(raymath.Quaternion, q)));
}

/// Calculate two quaternion multiplication
pub fn quaternionMultiply(q1: Quaternion, q2: Quaternion) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionMultiply(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, q2),
    ));
}

/// Scale quaternion by float value
pub fn quaternionScale(q: Quaternion, mul: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionScale(cast.as(raymath.Quaternion, q), mul));
}

/// Divide two quaternions
pub fn quaternionDivide(q1: Quaternion, q2: Quaternion) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionDivide(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, q2),
    ));
}

/// Calculate linear interpolation between two quaternions
pub fn quaternionLerp(q1: Quaternion, q2: Quaternion, amount: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionLerp(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, q2),
        amount,
    ));
}

/// Calculate slerp-optimized interpolation between two quaternions
pub fn quaternionNlerp(q1: Quaternion, q2: Quaternion, amount: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionNlerp(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, q2),
        amount,
    ));
}

/// Calculates spherical linear interpolation between two quaternions
pub fn quaternionSlerp(q1: Quaternion, q2: Quaternion, amount: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionSlerp(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, q2),
        amount,
    ));
}

/// Calculate quaternion cubic spline interpolation using Cubic Hermite Spline algorithm
/// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
pub fn quaternionCubicHermiteSpline(q1: Quaternion, outTangent1: Quaternion, q2: Quaternion, inTangent2: Quaternion, t: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionCubicHermiteSpline(
        cast.as(raymath.Quaternion, q1),
        cast.as(raymath.Quaternion, outTangent1),
        cast.as(raymath.Quaternion, q2),
        cast.as(raymath.Quaternion, inTangent2),
        t,
    ));
}

/// Calculate quaternion based on the rotation from one vector to another
pub fn quaternionFromVector3ToVector3(from: Vector3, to: Vector3) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionFromVector3ToVector3(
        cast.as(raymath.Vector3, from),
        cast.as(raymath.Vector3, to),
    ));
}

/// Get a quaternion for a given rotation matrix
pub fn quaternionFromMatrix(mat: Matrix) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionFromMatrix(cast.as(raymath.Matrix, mat)));
}

/// Get a matrix for a given quaternion
pub fn quaternionToMatrix(q: Quaternion) Matrix {
    return cast.as(Matrix, raymath.QuaternionToMatrix(cast.as(raymath.Quaternion, q)));
}

/// Get rotation quaternion for an angle and axis
/// NOTE: Angle must be provided in radians
pub fn quaternionFromAxisAngle(axis: Vector3, angle: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionFromAxisAngle(
        cast.as(raymath.Vector3, axis),
        angle,
    ));
}

/// Get the rotation angle and axis for a given quaternion
///
/// raylib writes the axis and the angle through pointers; raylibz returns them,
/// named as raylib's parameters are.
pub fn quaternionToAxisAngle(q: Quaternion) struct { outAxis: Vector3, outAngle: f32 } {
    var out_axis: raymath.Vector3 = .{};
    var out_angle: f32 = 0;
    raymath.QuaternionToAxisAngle(cast.as(raymath.Quaternion, q), &out_axis, &out_angle);
    return .{ .outAxis = cast.as(Vector3, out_axis), .outAngle = out_angle };
}

/// Get the quaternion equivalent to Euler angles
/// NOTE: Rotation order is ZYX
pub fn quaternionFromEuler(pitch: f32, yaw: f32, roll: f32) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionFromEuler(pitch, yaw, roll));
}

/// Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
/// NOTE: Angles are returned in a Vector3 struct in radians
pub fn quaternionToEuler(q: Quaternion) Vector3 {
    return cast.as(Vector3, raymath.QuaternionToEuler(cast.as(raymath.Quaternion, q)));
}

/// Transform a quaternion given a transformation matrix
pub fn quaternionTransform(q: Quaternion, mat: Matrix) Quaternion {
    return cast.as(Quaternion, raymath.QuaternionTransform(
        cast.as(raymath.Quaternion, q),
        cast.as(raymath.Matrix, mat),
    ));
}

/// Check whether two given quaternions are almost equal
///
/// raylib returns an `int`; raylibz returns the `bool` it means.
pub fn quaternionEquals(p: Quaternion, q: Quaternion) bool {
    return raymath.QuaternionEquals(
        cast.as(raymath.Quaternion, p),
        cast.as(raymath.Quaternion, q),
    ) != 0;
}
