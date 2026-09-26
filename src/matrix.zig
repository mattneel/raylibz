//! raylib's `Matrix`, mirrored, and raymath's `Matrix*` functions as methods.
//!
//! The mirror carries raymath's own functions for the type as methods, named
//! without the type prefix: `MatrixMultiply(left, right)` is `left.multiply(right)`,
//! `MatrixDeterminant(mat)` is `mat.determinant()`. The ones that take no matrix
//! (`MatrixIdentity`, `MatrixTranslate`, `MatrixRotateX`, `MatrixScale`,
//! `MatrixFrustum`, `MatrixPerspective`, `MatrixOrtho`) are plain declarations
//! on the type: `Matrix.identity()`, `Matrix.rotateX(angle)`, as is
//! `MatrixCompose`, which takes the three components instead of a matrix. Every
//! one calls the translated raymath function through `cast.as`, so the result is
//! raymath's own, bit for bit, and the layout assertion in the struct body keeps
//! this mirror and raylib's `Matrix` in step.
//!
//! Two of raylib's parameter names cannot survive here: Zig rejects a parameter
//! or a local that shadows a declaration in scope, and `scale` is one of this
//! type's methods (`Matrix.rotate`'s `scale`, `MatrixCompose`'s and
//! `MatrixDecompose`'s locals). Those doc comments name the parameters raylib
//! spells differently.
//!
//! `tests/raymath.zig` holds the table that maps every raymath function to the
//! method that wraps it, and calls both sides on the same inputs.

const c = @import("raylib");
const cast = @import("cast.zig");
const raymath = @import("raymath");
const vector3 = @import("vector3.zig");
const vector4 = @import("vector4.zig");

const Quaternion = vector4.Quaternion;
const Vector3 = vector3.Vector3;

/// Matrix, 4x4 components, column major, OpenGL style, right-handed
///
/// raylib.h's `Matrix`.
pub const Matrix = extern struct {
    /// Matrix first row (4 components)
    m0: f32,
    /// Matrix first row (4 components)
    m4: f32,
    /// Matrix first row (4 components)
    m8: f32,
    /// Matrix first row (4 components)
    m12: f32,
    /// Matrix second row (4 components)
    m1: f32,
    /// Matrix second row (4 components)
    m5: f32,
    /// Matrix second row (4 components)
    m9: f32,
    /// Matrix second row (4 components)
    m13: f32,
    /// Matrix third row (4 components)
    m2: f32,
    /// Matrix third row (4 components)
    m6: f32,
    /// Matrix third row (4 components)
    m10: f32,
    /// Matrix third row (4 components)
    m14: f32,
    /// Matrix fourth row (4 components)
    m3: f32,
    /// Matrix fourth row (4 components)
    m7: f32,
    /// Matrix fourth row (4 components)
    m11: f32,
    /// Matrix fourth row (4 components)
    m15: f32,

    comptime {
        cast.assertLayout(@This(), c.Matrix);
    }

    /// Compute matrix determinant
    pub fn determinant(self: Matrix) f32 {
        return raymath.MatrixDeterminant(cast.as(raymath.Matrix, self));
    }

    /// Get the trace of the matrix (sum of the values along the diagonal)
    pub fn trace(self: Matrix) f32 {
        return raymath.MatrixTrace(cast.as(raymath.Matrix, self));
    }

    /// Transposes provided matrix
    pub fn transpose(self: Matrix) Matrix {
        return cast.as(Matrix, raymath.MatrixTranspose(cast.as(raymath.Matrix, self)));
    }

    /// Invert provided matrix
    pub fn invert(self: Matrix) Matrix {
        return cast.as(Matrix, raymath.MatrixInvert(cast.as(raymath.Matrix, self)));
    }

    /// Get identity matrix
    pub fn identity() Matrix {
        return cast.as(Matrix, raymath.MatrixIdentity());
    }

    /// Add two matrices
    pub fn add(self: Matrix, right: Matrix) Matrix {
        return cast.as(Matrix, raymath.MatrixAdd(
            cast.as(raymath.Matrix, self),
            cast.as(raymath.Matrix, right),
        ));
    }

    /// Subtract two matrices (left - right)
    pub fn subtract(self: Matrix, right: Matrix) Matrix {
        return cast.as(Matrix, raymath.MatrixSubtract(
            cast.as(raymath.Matrix, self),
            cast.as(raymath.Matrix, right),
        ));
    }

    /// Get two matrix multiplication
    /// NOTE: When multiplying matrices... the order matters!
    pub fn multiply(self: Matrix, right: Matrix) Matrix {
        return cast.as(Matrix, raymath.MatrixMultiply(
            cast.as(raymath.Matrix, self),
            cast.as(raymath.Matrix, right),
        ));
    }

    /// Multiply matrix components by value
    pub fn multiplyValue(self: Matrix, value: f32) Matrix {
        return cast.as(Matrix, raymath.MatrixMultiplyValue(cast.as(raymath.Matrix, self), value));
    }

    /// Get translation matrix
    pub fn translate(x: f32, y: f32, z: f32) Matrix {
        return cast.as(Matrix, raymath.MatrixTranslate(x, y, z));
    }

    /// Create rotation matrix from axis and angle
    /// NOTE: Angle should be provided in radians
    pub fn rotate(axis: Vector3, angle: f32) Matrix {
        return cast.as(Matrix, raymath.MatrixRotate(cast.as(raymath.Vector3, axis), angle));
    }

    /// Get x-rotation matrix
    /// NOTE: Angle must be provided in radians
    pub fn rotateX(angle: f32) Matrix {
        return cast.as(Matrix, raymath.MatrixRotateX(angle));
    }

    /// Get y-rotation matrix
    /// NOTE: Angle must be provided in radians
    pub fn rotateY(angle: f32) Matrix {
        return cast.as(Matrix, raymath.MatrixRotateY(angle));
    }

    /// Get z-rotation matrix
    /// NOTE: Angle must be provided in radians
    pub fn rotateZ(angle: f32) Matrix {
        return cast.as(Matrix, raymath.MatrixRotateZ(angle));
    }

    /// Get xyz-rotation matrix
    /// NOTE: Angle must be provided in radians
    pub fn rotateXYZ(angle: Vector3) Matrix {
        return cast.as(Matrix, raymath.MatrixRotateXYZ(cast.as(raymath.Vector3, angle)));
    }

    /// Get zyx-rotation matrix
    /// NOTE: Angle must be provided in radians
    pub fn rotateZYX(angle: Vector3) Matrix {
        return cast.as(Matrix, raymath.MatrixRotateZYX(cast.as(raymath.Vector3, angle)));
    }

    /// Get scaling matrix
    pub fn scale(x: f32, y: f32, z: f32) Matrix {
        return cast.as(Matrix, raymath.MatrixScale(x, y, z));
    }

    /// Get perspective projection matrix
    pub fn frustum(left: f64, right: f64, bottom: f64, top: f64, nearPlane: f64, farPlane: f64) Matrix {
        return cast.as(Matrix, raymath.MatrixFrustum(
            left,
            right,
            bottom,
            top,
            nearPlane,
            farPlane,
        ));
    }

    /// Get perspective projection matrix
    /// NOTE: Fovy angle must be provided in radians
    pub fn perspective(fovY: f64, aspect: f64, nearPlane: f64, farPlane: f64) Matrix {
        return cast.as(Matrix, raymath.MatrixPerspective(fovY, aspect, nearPlane, farPlane));
    }

    /// Get orthographic projection matrix
    pub fn ortho(left: f64, right: f64, bottom: f64, top: f64, nearPlane: f64, farPlane: f64) Matrix {
        return cast.as(Matrix, raymath.MatrixOrtho(left, right, bottom, top, nearPlane, farPlane));
    }

    /// Get camera look-at matrix (view matrix)
    pub fn lookAt(eye: Vector3, target: Vector3, up: Vector3) Matrix {
        return cast.as(Matrix, raymath.MatrixLookAt(
            cast.as(raymath.Vector3, eye),
            cast.as(raymath.Vector3, target),
            cast.as(raymath.Vector3, up),
        ));
    }

    /// Get float array of matrix data
    ///
    /// raylib returns a `float16`, a struct holding the same array; raylibz returns the array.
    pub fn toFloatV(self: Matrix) [16]f32 {
        return cast.as([16]f32, raymath.MatrixToFloatV(cast.as(raymath.Matrix, self)));
    }

    /// Compose a transformation matrix from rotational, translational and scaling components
    ///
    /// Zig rejects a parameter that shadows a declaration of the same type, so raylib's `scale` is `scaling` here.
    pub fn compose(translation: Vector3, rotation: Quaternion, scaling: Vector3) Matrix {
        return cast.as(Matrix, raymath.MatrixCompose(
            cast.as(raymath.Vector3, translation),
            cast.as(raymath.Quaternion, rotation),
            cast.as(raymath.Vector3, scaling),
        ));
    }

    /// Decompose a transformation matrix into its rotational, translational and scaling components and remove shear
    /// TODO: WARNING: Following raymath convention and make the function self-contained
    ///
    /// raylib writes the three components through pointers; raylibz returns
    /// them, named as raylib's parameters are.
    pub fn decompose(self: Matrix) struct { translation: Vector3, rotation: Quaternion, scale: Vector3 } {
        var out_translation: raymath.Vector3 = .{};
        var out_rotation: raymath.Quaternion = .{};
        var out_scale: raymath.Vector3 = .{};
        raymath.MatrixDecompose(cast.as(raymath.Matrix, self), &out_translation, &out_rotation, &out_scale);
        return .{
            .translation = cast.as(Vector3, out_translation),
            .rotation = cast.as(Quaternion, out_rotation),
            .scale = cast.as(Vector3, out_scale),
        };
    }
};
