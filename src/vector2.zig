//! raylib's `Vector2`, mirrored, and the `Vector2*` family of raymath methods.
//!
//! The mirror carries raymath's own functions for the type as methods, named
//! without the type prefix: `Vector2Add(a, b)` is `a.add(b)`, `Vector2Length(v)`
//! is `v.length()`. The two that take no vector (`Vector2Zero`, `Vector2One`)
//! are plain declarations on the type: `Vector2.zero()`, `Vector2.one()`. Every
//! one calls the translated raymath function through `cast.as`, so the result is
//! raymath's own, bit for bit, and the layout assertion in the struct body keeps
//! this mirror and raylib's `Vector2` in step.
//!
//! A few of raylib's parameter names cannot survive here: Zig rejects a
//! parameter or a local that shadows a declaration in scope, and this type's own
//! methods are declarations of it (`add` versus `addValue`, `min` and `max`
//! versus `min()` and `max()`). Each such function's doc comment names the
//! parameter raylib spells differently.
//!
//! `tests/raymath.zig` holds the table that maps every raymath function to the
//! method that wraps it, and calls both sides on the same inputs.

const c = @import("raylib");
const cast = @import("cast.zig");
const matrix = @import("matrix.zig");
const raymath = @import("raymath");

const Matrix = matrix.Matrix;

/// Vector2, 2 components
///
/// raylib.h's `Vector2`.
pub const Vector2 = extern struct {
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,

    comptime {
        cast.assertLayout(@This(), c.Vector2);
    }

    /// Vector with components value 0.0f
    pub fn zero() Vector2 {
        return cast.as(Vector2, raymath.Vector2Zero());
    }

    /// Vector with components value 1.0f
    pub fn one() Vector2 {
        return cast.as(Vector2, raymath.Vector2One());
    }

    /// Add two vectors (v1 + v2)
    pub fn add(self: Vector2, v2: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Add(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        ));
    }

    /// Add vector and float value
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `add` is `addend` here.
    pub fn addValue(self: Vector2, addend: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2AddValue(cast.as(raymath.Vector2, self), addend));
    }

    /// Subtract two vectors (v1 - v2)
    pub fn subtract(self: Vector2, v2: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Subtract(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        ));
    }

    /// Subtract vector by float value
    pub fn subtractValue(self: Vector2, sub: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2SubtractValue(cast.as(raymath.Vector2, self), sub));
    }

    /// Calculate vector length
    pub fn length(self: Vector2) f32 {
        return raymath.Vector2Length(cast.as(raymath.Vector2, self));
    }

    /// Calculate vector square length
    pub fn lengthSqr(self: Vector2) f32 {
        return raymath.Vector2LengthSqr(cast.as(raymath.Vector2, self));
    }

    /// Calculate two vectors dot product
    pub fn dotProduct(self: Vector2, v2: Vector2) f32 {
        return raymath.Vector2DotProduct(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        );
    }

    /// Calculate two vectors cross product
    pub fn crossProduct(self: Vector2, v2: Vector2) f32 {
        return raymath.Vector2CrossProduct(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        );
    }

    /// Calculate distance between two vectors
    pub fn distance(self: Vector2, v2: Vector2) f32 {
        return raymath.Vector2Distance(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        );
    }

    /// Calculate square distance between two vectors
    pub fn distanceSqr(self: Vector2, v2: Vector2) f32 {
        return raymath.Vector2DistanceSqr(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        );
    }

    /// Calculate the signed angle from v1 to v2, relative to the origin (0, 0)
    /// NOTE: Coordinate system convention: positive X right, positive Y down
    /// positive angles appear clockwise, and negative angles appear counterclockwise
    pub fn angle(self: Vector2, v2: Vector2) f32 {
        return raymath.Vector2Angle(cast.as(raymath.Vector2, self), cast.as(raymath.Vector2, v2));
    }

    /// Calculate angle defined by a two vectors line
    /// NOTE: Parameters need to be normalized
    /// Current implementation should be aligned with glm::angle
    pub fn lineAngle(self: Vector2, end: Vector2) f32 {
        return raymath.Vector2LineAngle(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, end),
        );
    }

    /// Scale vector (multiply by value)
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `scale` is `scalar` here.
    pub fn scale(self: Vector2, scalar: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2Scale(cast.as(raymath.Vector2, self), scalar));
    }

    /// Multiply vector by vector
    pub fn multiply(self: Vector2, v2: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Multiply(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        ));
    }

    /// Negate vector
    pub fn negate(self: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Negate(cast.as(raymath.Vector2, self)));
    }

    /// Divide vector by vector
    pub fn divide(self: Vector2, v2: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Divide(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        ));
    }

    /// Normalize provided vector
    pub fn normalize(self: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Normalize(cast.as(raymath.Vector2, self)));
    }

    /// Transforms a Vector2 by a given Matrix
    pub fn transform(self: Vector2, mat: Matrix) Vector2 {
        return cast.as(Vector2, raymath.Vector2Transform(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Matrix, mat),
        ));
    }

    /// Calculate linear interpolation between two vectors
    pub fn lerp(self: Vector2, v2: Vector2, amount: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2Lerp(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
            amount,
        ));
    }

    /// Calculate reflected vector to normal
    pub fn reflect(self: Vector2, normal: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Reflect(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, normal),
        ));
    }

    /// Get min value for each pair of components
    pub fn min(self: Vector2, v2: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Min(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        ));
    }

    /// Get max value for each pair of components
    pub fn max(self: Vector2, v2: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Max(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, v2),
        ));
    }

    /// Rotate vector by angle
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `angle` is `radians` here.
    pub fn rotate(self: Vector2, radians: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2Rotate(cast.as(raymath.Vector2, self), radians));
    }

    /// Move Vector towards target
    pub fn moveTowards(self: Vector2, target: Vector2, maxDistance: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2MoveTowards(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, target),
            maxDistance,
        ));
    }

    /// Invert the given vector
    pub fn invert(self: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Invert(cast.as(raymath.Vector2, self)));
    }

    /// Clamp the components of the vector between
    /// min and max values specified by the given vectors
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `min` and `max` are `lower` and `upper` here.
    pub fn clamp(self: Vector2, lower: Vector2, upper: Vector2) Vector2 {
        return cast.as(Vector2, raymath.Vector2Clamp(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, lower),
            cast.as(raymath.Vector2, upper),
        ));
    }

    /// Clamp the magnitude of the vector between two min and max values
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `min` and `max` are `lower` and `upper` here.
    pub fn clampValue(self: Vector2, lower: f32, upper: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2ClampValue(
            cast.as(raymath.Vector2, self),
            lower,
            upper,
        ));
    }

    /// Check whether two given vectors are almost equal
    ///
    /// raylib returns an `int`; raylibz returns the `bool` it means.
    pub fn equals(self: Vector2, q: Vector2) bool {
        return raymath.Vector2Equals(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, q),
        ) != 0;
    }

    /// Compute the direction of a refracted ray
    /// v: normalized direction of the incoming ray
    /// n: normalized normal vector of the interface of two optical media
    /// r: ratio of the refractive index of the medium from where the ray comes
    /// to the refractive index of the medium on the other side of the surface
    pub fn refract(self: Vector2, n: Vector2, r: f32) Vector2 {
        return cast.as(Vector2, raymath.Vector2Refract(
            cast.as(raymath.Vector2, self),
            cast.as(raymath.Vector2, n),
            r,
        ));
    }
};
