//! raylib's `Vector4` (and therefore `Quaternion`), mirrored, and the `Vector4*`
//! family of raymath methods.
//!
//! The mirror carries raymath's own functions for the type as methods, named
//! without the type prefix: `Vector4Add(v1, v2)` is `v1.add(v2)`,
//! `Vector4Length(v)` is `v.length()`. The two that take no vector
//! (`Vector4Zero`, `Vector4One`) are plain declarations on the type:
//! `Vector4.zero()`, `Vector4.one()`. Every one calls the translated raymath
//! function through `cast.as`, so the result is raymath's own, bit for bit, and
//! the layout assertion in the struct body keeps this mirror and raylib's
//! `Vector4` in step.
//!
//! A few of raylib's parameter names cannot survive here: Zig rejects a
//! parameter or a local that shadows a declaration in scope, and this type's own
//! methods are declarations of it (`add` versus `addValue` and `subtractValue`,
//! `scale` versus `scale()`). Each such function's doc comment names the
//! parameter raylib spells differently.
//!
//! `Quaternion` is raylib's `typedef Vector4 Quaternion`, so it is an alias for
//! this type and the `Quaternion*` family of raymath functions stays free
//! functions in `math.zig`, not methods here.
//!
//! `tests/raymath.zig` holds the table that maps every raymath function to the
//! method that wraps it, and calls both sides on the same inputs.

const c = @import("raylib");
const cast = @import("cast.zig");
const raymath = @import("raymath");

pub const Quaternion = Vector4;

/// Vector4, 4 components
///
/// raylib.h's `Vector4`.
pub const Vector4 = extern struct {
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,
    /// Vector z component
    z: f32,
    /// Vector w component
    w: f32,

    comptime {
        cast.assertLayout(@This(), c.Vector4);
    }

    /// Get  vector zero
    pub fn zero() Vector4 {
        return cast.as(Vector4, raymath.Vector4Zero());
    }

    /// Get vector one
    pub fn one() Vector4 {
        return cast.as(Vector4, raymath.Vector4One());
    }

    /// Add two vectors
    pub fn add(self: Vector4, v2: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Add(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        ));
    }

    /// Add value to vector components
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `add` is `addend` here.
    pub fn addValue(self: Vector4, addend: f32) Vector4 {
        return cast.as(Vector4, raymath.Vector4AddValue(cast.as(raymath.Vector4, self), addend));
    }

    /// Substract vectors
    pub fn subtract(self: Vector4, v2: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Subtract(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        ));
    }

    /// Substract value from vector components
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `add` is `sub` here.
    pub fn subtractValue(self: Vector4, sub: f32) Vector4 {
        return cast.as(Vector4, raymath.Vector4SubtractValue(cast.as(raymath.Vector4, self), sub));
    }

    /// Vector length
    pub fn length(self: Vector4) f32 {
        return raymath.Vector4Length(cast.as(raymath.Vector4, self));
    }

    /// Vector square length
    pub fn lengthSqr(self: Vector4) f32 {
        return raymath.Vector4LengthSqr(cast.as(raymath.Vector4, self));
    }

    /// Vectors dot product
    pub fn dotProduct(self: Vector4, v2: Vector4) f32 {
        return raymath.Vector4DotProduct(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        );
    }

    /// Calculate distance between two vectors
    pub fn distance(self: Vector4, v2: Vector4) f32 {
        return raymath.Vector4Distance(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        );
    }

    /// Calculate square distance between two vectors
    pub fn distanceSqr(self: Vector4, v2: Vector4) f32 {
        return raymath.Vector4DistanceSqr(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        );
    }

    /// Scale vector components by value (multiply)
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `scale` is `scalar` here.
    pub fn scale(self: Vector4, scalar: f32) Vector4 {
        return cast.as(Vector4, raymath.Vector4Scale(cast.as(raymath.Vector4, self), scalar));
    }

    /// Multiply vector by vector
    pub fn multiply(self: Vector4, v2: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Multiply(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        ));
    }

    /// Negate vector
    pub fn negate(self: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Negate(cast.as(raymath.Vector4, self)));
    }

    /// Divide vector by vector
    pub fn divide(self: Vector4, v2: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Divide(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        ));
    }

    /// Normalize provided vector
    pub fn normalize(self: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Normalize(cast.as(raymath.Vector4, self)));
    }

    /// Get min value for each pair of components
    pub fn min(self: Vector4, v2: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Min(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        ));
    }

    /// Get max value for each pair of components
    pub fn max(self: Vector4, v2: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Max(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
        ));
    }

    /// Calculate linear interpolation between two vectors
    pub fn lerp(self: Vector4, v2: Vector4, amount: f32) Vector4 {
        return cast.as(Vector4, raymath.Vector4Lerp(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, v2),
            amount,
        ));
    }

    /// Move Vector towards target
    pub fn moveTowards(self: Vector4, target: Vector4, maxDistance: f32) Vector4 {
        return cast.as(Vector4, raymath.Vector4MoveTowards(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, target),
            maxDistance,
        ));
    }

    /// Invert the given vector
    pub fn invert(self: Vector4) Vector4 {
        return cast.as(Vector4, raymath.Vector4Invert(cast.as(raymath.Vector4, self)));
    }

    /// Check whether two given vectors are almost equal
    ///
    /// raylib returns an `int`; raylibz returns the `bool` it means.
    pub fn equals(self: Vector4, q: Vector4) bool {
        return raymath.Vector4Equals(
            cast.as(raymath.Vector4, self),
            cast.as(raymath.Vector4, q),
        ) != 0;
    }
};
