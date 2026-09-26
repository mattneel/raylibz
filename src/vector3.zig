//! raylib's `Vector3`, mirrored, and the `Vector3*` family of raymath methods.
//!
//! The mirror carries raymath's own functions for the type as methods, named
//! without the type prefix: `Vector3CrossProduct(v1, v2)` is `v1.crossProduct(v2)`,
//! `Vector3Length(v)` is `v.length()`. The two that take no vector
//! (`Vector3Zero`, `Vector3One`) are plain declarations on the type:
//! `Vector3.zero()`, `Vector3.one()`. Every one calls the translated raymath
//! function through `cast.as`, so the result is raymath's own, bit for bit, and
//! the layout assertion in the struct body keeps this mirror and raylib's
//! `Vector3` in step.
//!
//! A few of raylib's parameter names cannot survive here: Zig rejects a
//! parameter or a local that shadows a declaration in scope, and this type's own
//! methods are declarations of it (`add` versus `addValue`, `c` versus the
//! file's raylib import, `min`, `max` and `angle` versus `min()`, `max()` and
//! `angle()`). Each such function's doc comment names the parameter raylib
//! spells differently.
//!
//! `tests/raymath.zig` holds the table that maps every raymath function to the
//! method that wraps it, and calls both sides on the same inputs.

const c = @import("raylib");
const cast = @import("cast.zig");
const matrix = @import("matrix.zig");
const raymath = @import("raymath");
const vector4 = @import("vector4.zig");

const Matrix = matrix.Matrix;
const Quaternion = vector4.Quaternion;

/// Vector3, 3 components
///
/// raylib.h's `Vector3`.
pub const Vector3 = extern struct {
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,
    /// Vector z component
    z: f32,

    comptime {
        cast.assertLayout(@This(), c.Vector3);
    }

    /// Vector with components value 0.0f
    pub fn zero() Vector3 {
        return cast.as(Vector3, raymath.Vector3Zero());
    }

    /// Vector with components value 1.0f
    pub fn one() Vector3 {
        return cast.as(Vector3, raymath.Vector3One());
    }

    /// Add two vectors
    pub fn add(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Add(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Add vector and float value
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `add` is `addend` here.
    pub fn addValue(self: Vector3, addend: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3AddValue(cast.as(raymath.Vector3, self), addend));
    }

    /// Subtract two vectors
    pub fn subtract(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Subtract(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Subtract vector by float value
    pub fn subtractValue(self: Vector3, sub: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3SubtractValue(cast.as(raymath.Vector3, self), sub));
    }

    /// Multiply vector by scalar
    pub fn scale(self: Vector3, scalar: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3Scale(cast.as(raymath.Vector3, self), scalar));
    }

    /// Multiply vector by vector
    pub fn multiply(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Multiply(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Calculate two vectors cross product
    pub fn crossProduct(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3CrossProduct(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Calculate one vector perpendicular vector
    pub fn perpendicular(self: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Perpendicular(cast.as(raymath.Vector3, self)));
    }

    /// Calculate vector length
    pub fn length(self: Vector3) f32 {
        return raymath.Vector3Length(cast.as(raymath.Vector3, self));
    }

    /// Calculate vector square length
    pub fn lengthSqr(self: Vector3) f32 {
        return raymath.Vector3LengthSqr(cast.as(raymath.Vector3, self));
    }

    /// Calculate two vectors dot product
    pub fn dotProduct(self: Vector3, v2: Vector3) f32 {
        return raymath.Vector3DotProduct(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        );
    }

    /// Calculate distance between two vectors
    pub fn distance(self: Vector3, v2: Vector3) f32 {
        return raymath.Vector3Distance(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        );
    }

    /// Calculate square distance between two vectors
    pub fn distanceSqr(self: Vector3, v2: Vector3) f32 {
        return raymath.Vector3DistanceSqr(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        );
    }

    /// Calculate angle between two vectors
    pub fn angle(self: Vector3, v2: Vector3) f32 {
        return raymath.Vector3Angle(cast.as(raymath.Vector3, self), cast.as(raymath.Vector3, v2));
    }

    /// Negate provided vector (invert direction)
    pub fn negate(self: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Negate(cast.as(raymath.Vector3, self)));
    }

    /// Divide vector by vector
    pub fn divide(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Divide(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Normalize provided vector
    pub fn normalize(self: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Normalize(cast.as(raymath.Vector3, self)));
    }

    /// Calculate the projection of the vector v1 on to v2
    pub fn project(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Project(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Calculate the rejection of the vector v1 on to v2
    pub fn reject(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Reject(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Orthonormalize provided vectors
    /// Makes vectors normalized and orthogonal to each other
    /// Gram-Schmidt function implementation
    ///
    /// raylib writes both vectors through pointers; raylibz returns the
    /// orthonormalized pair, in raylib's `v1`, `v2` order, and leaves the
    /// values the caller passed in untouched.
    pub fn orthoNormalize(self: Vector3, v2: Vector3) struct { v1: Vector3, v2: Vector3 } {
        var out_v1 = cast.as(raymath.Vector3, self);
        var out_v2 = cast.as(raymath.Vector3, v2);
        raymath.Vector3OrthoNormalize(&out_v1, &out_v2);
        return .{ .v1 = cast.as(Vector3, out_v1), .v2 = cast.as(Vector3, out_v2) };
    }

    /// Transforms a Vector3 by a given Matrix
    pub fn transform(self: Vector3, mat: Matrix) Vector3 {
        return cast.as(Vector3, raymath.Vector3Transform(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Matrix, mat),
        ));
    }

    /// Transform a vector by quaternion rotation
    pub fn rotateByQuaternion(self: Vector3, q: Quaternion) Vector3 {
        return cast.as(Vector3, raymath.Vector3RotateByQuaternion(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Quaternion, q),
        ));
    }

    /// Rotates a vector around an axis
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `angle` is `radians` here.
    pub fn rotateByAxisAngle(self: Vector3, axis: Vector3, radians: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3RotateByAxisAngle(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, axis),
            radians,
        ));
    }

    /// Move Vector towards target
    pub fn moveTowards(self: Vector3, target: Vector3, maxDistance: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3MoveTowards(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, target),
            maxDistance,
        ));
    }

    /// Calculate linear interpolation between two vectors
    pub fn lerp(self: Vector3, v2: Vector3, amount: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3Lerp(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
            amount,
        ));
    }

    /// Calculate cubic hermite interpolation between two vectors and their tangents
    /// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
    pub fn cubicHermite(self: Vector3, tangent1: Vector3, v2: Vector3, tangent2: Vector3, amount: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3CubicHermite(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, tangent1),
            cast.as(raymath.Vector3, v2),
            cast.as(raymath.Vector3, tangent2),
            amount,
        ));
    }

    /// Calculate reflected vector to normal
    pub fn reflect(self: Vector3, normal: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Reflect(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, normal),
        ));
    }

    /// Get min value for each pair of components
    pub fn min(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Min(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Get max value for each pair of components
    pub fn max(self: Vector3, v2: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Max(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, v2),
        ));
    }

    /// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
    /// NOTE: Assumes P is on the plane of the triangle
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `a` and `b` and `c` are `vertexA` and `vertexB` and `vertexC` here.
    pub fn barycenter(self: Vector3, vertexA: Vector3, vertexB: Vector3, vertexC: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Barycenter(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, vertexA),
            cast.as(raymath.Vector3, vertexB),
            cast.as(raymath.Vector3, vertexC),
        ));
    }

    /// Projects a Vector3 from screen space into object space
    /// NOTE: Self-contained function, no other raymath functions are called
    pub fn unproject(self: Vector3, projection: Matrix, view: Matrix) Vector3 {
        return cast.as(Vector3, raymath.Vector3Unproject(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Matrix, projection),
            cast.as(raymath.Matrix, view),
        ));
    }

    /// Get Vector3 as float array
    ///
    /// raylib returns a `float3`, a struct holding the same array; raylibz returns the array.
    pub fn toFloatV(self: Vector3) [3]f32 {
        return cast.as([3]f32, raymath.Vector3ToFloatV(cast.as(raymath.Vector3, self)));
    }

    /// Invert the given vector
    pub fn invert(self: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Invert(cast.as(raymath.Vector3, self)));
    }

    /// Clamp the components of the vector between
    /// min and max values specified by the given vectors
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `min` and `max` are `lower` and `upper` here.
    pub fn clamp(self: Vector3, lower: Vector3, upper: Vector3) Vector3 {
        return cast.as(Vector3, raymath.Vector3Clamp(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, lower),
            cast.as(raymath.Vector3, upper),
        ));
    }

    /// Clamp the magnitude of the vector between two values
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `min` and `max` are `lower` and `upper` here.
    pub fn clampValue(self: Vector3, lower: f32, upper: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3ClampValue(
            cast.as(raymath.Vector3, self),
            lower,
            upper,
        ));
    }

    /// Check whether two given vectors are almost equal
    ///
    /// raylib returns an `int`; raylibz returns the `bool` it means.
    pub fn equals(self: Vector3, q: Vector3) bool {
        return raymath.Vector3Equals(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, q),
        ) != 0;
    }

    /// Compute the direction of a refracted ray
    /// v: normalized direction of the incoming ray
    /// n: normalized normal vector of the interface of two optical media
    /// r: ratio of the refractive index of the medium from where the ray comes
    /// to the refractive index of the medium on the other side of the surface
    pub fn refract(self: Vector3, n: Vector3, r: f32) Vector3 {
        return cast.as(Vector3, raymath.Vector3Refract(
            cast.as(raymath.Vector3, self),
            cast.as(raymath.Vector3, n),
            r,
        ));
    }
};
