//! Compiles every mirrored struct's layout assertion, and checks the aliases.
//!
//! The assertions themselves live in each mirror's body (`cast.assertLayout`
//! against raylib's translated type), so this test's job is to name every
//! mirror: a mirror nobody references is a mirror nobody checks.

const std = @import("std");
const raylibz = @import("raylibz");

/// Every mirror raylibz defines, in the order raylib.h declares them.
const mirrors = [_]type{
    raylibz.Vector2,
    raylibz.Vector3,
    raylibz.Vector4,
    raylibz.Matrix,
    raylibz.Rectangle,
    raylibz.Image,
    raylibz.Texture,
    raylibz.RenderTexture,
    raylibz.NPatchInfo,
    raylibz.GlyphInfo,
    raylibz.Font,
    raylibz.Camera3D,
    raylibz.Camera2D,
    raylibz.Mesh,
    raylibz.Shader,
    raylibz.MaterialMap,
    raylibz.Material,
    raylibz.Transform,
    raylibz.BoneInfo,
    raylibz.ModelSkeleton,
    raylibz.Model,
    raylibz.ModelAnimation,
    raylibz.Ray,
    raylibz.RayCollision,
    raylibz.BoundingBox,
    raylibz.Wave,
    raylibz.AudioStream,
    raylibz.Sound,
    raylibz.Music,
    raylibz.VrDeviceInfo,
    raylibz.VrStereoConfig,
    raylibz.FilePathList,
    raylibz.AutomationEvent,
    raylibz.AutomationEventList,
};

test "every mirrored struct asserts its layout against raylib's translated type" {
    inline for (mirrors) |Mirror| {
        // The assertion runs when the type is analyzed; naming its size is
        // enough to force that, and it fails loudly if the mirror is empty.
        try std.testing.expect(@sizeOf(Mirror) > 0);
    }
}

test "raylib's typedef aliases are Zig aliases" {
    try std.testing.expect(raylibz.Texture2D == raylibz.Texture);
    try std.testing.expect(raylibz.TextureCubemap == raylibz.Texture);
    try std.testing.expect(raylibz.RenderTexture2D == raylibz.RenderTexture);
    try std.testing.expect(raylibz.Camera == raylibz.Camera3D);
    try std.testing.expect(raylibz.Quaternion == raylibz.Vector4);
    try std.testing.expect(raylibz.ModelAnimPose == [*]raylibz.Transform);
}
