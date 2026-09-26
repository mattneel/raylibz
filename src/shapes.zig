//! raylib's shapes module: pixel and line drawing, circles, ellipses, rings,
//! rectangles, triangles and polygons.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, and raylib's own one-line comment
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
const vector2 = @import("vector2.zig");

const Color = types.Color;
const Rectangle = types.Rectangle;
const Texture2D = types.Texture2D;
const Vector2 = vector2.Vector2;

/// The functions of raylib.h's `shapes` module that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

/// Private helpers, for this file's tests only. The root's re-export test skips
/// this name, exactly because nothing here is part of the package's face.
const internal = struct {
    const std = @import("std");
    const testing = std.testing;

    /// Asserts a returned point, component by component.
    fn expectPoint(actual: Vector2, expected_x: f32, expected_y: f32) !void {
        try testing.expectApproxEqAbs(expected_x, actual.x, 0.0001);
        try testing.expectApproxEqAbs(expected_y, actual.y, 0.0001);
    }

    /// Asserts a returned rectangle, component by component.
    fn expectRectangle(actual: Rectangle, expected_x: f32, expected_y: f32, expected_width: f32, expected_height: f32) !void {
        try testing.expectApproxEqAbs(expected_x, actual.x, 0.0001);
        try testing.expectApproxEqAbs(expected_y, actual.y, 0.0001);
        try testing.expectApproxEqAbs(expected_width, actual.width, 0.0001);
        try testing.expectApproxEqAbs(expected_height, actual.height, 0.0001);
    }

    /// Asserts that a wrapper's point is the point raylib's own function
    /// computes for the same input, bit for bit, so a conversion that mangles
    /// an argument or a result cannot pass.
    fn expectSamePoint(actual: Vector2, expected: c.Vector2) !void {
        try testing.expectEqual(@as(u32, @bitCast(expected.x)), @as(u32, @bitCast(actual.x)));
        try testing.expectEqual(@as(u32, @bitCast(expected.y)), @as(u32, @bitCast(actual.y)));
    }
};

/// Set texture and rectangle to be used on shapes drawing
pub fn setShapesTexture(texture: Texture2D, rec: Rectangle) void {
    c.SetShapesTexture(cast.as(c.Texture2D, texture), cast.as(c.Rectangle, rec));
}

/// Get texture that is used for shapes drawing
pub fn getShapesTexture() Texture2D {
    return cast.as(Texture2D, c.GetShapesTexture());
}

/// Get texture source rectangle that is used for shapes drawing
pub fn getShapesTextureRectangle() Rectangle {
    return cast.as(Rectangle, c.GetShapesTextureRectangle());
}

/// Draw a pixel using geometry [Can be slow, use with care]
pub fn drawPixel(posX: i32, posY: i32, color: Color) void {
    c.DrawPixel(posX, posY, cast.as(c.Color, color));
}

/// Draw a pixel using geometry (Vector version) [Can be slow, use with care]
pub fn drawPixelV(position: Vector2, color: Color) void {
    c.DrawPixelV(cast.as(c.Vector2, position), cast.as(c.Color, color));
}

/// Draw a line
pub fn drawLine(startPosX: i32, startPosY: i32, endPosX: i32, endPosY: i32, color: Color) void {
    c.DrawLine(startPosX, startPosY, endPosX, endPosY, cast.as(c.Color, color));
}

/// Draw a line (using gl lines)
pub fn drawLineV(startPos: Vector2, endPos: Vector2, color: Color) void {
    c.DrawLineV(cast.as(c.Vector2, startPos), cast.as(c.Vector2, endPos), cast.as(c.Color, color));
}

/// Draw a line (using triangles/quads)
pub fn drawLineEx(startPos: Vector2, endPos: Vector2, thick: f32, color: Color) void {
    c.DrawLineEx(cast.as(c.Vector2, startPos), cast.as(c.Vector2, endPos), thick, cast.as(c.Color, color));
}

/// Draw lines sequence (using gl lines)
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawLineStrip(points: []const Vector2, color: Color) void {
    c.DrawLineStrip(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), cast.as(c.Color, color));
}

/// Draw line segment cubic-bezier in-out interpolation
pub fn drawLineBezier(startPos: Vector2, endPos: Vector2, thick: f32, color: Color) void {
    c.DrawLineBezier(cast.as(c.Vector2, startPos), cast.as(c.Vector2, endPos), thick, cast.as(c.Color, color));
}

/// Draw a dashed line
pub fn drawLineDashed(startPos: Vector2, endPos: Vector2, dashSize: i32, spaceSize: i32, color: Color) void {
    c.DrawLineDashed(cast.as(c.Vector2, startPos), cast.as(c.Vector2, endPos), dashSize, spaceSize, cast.as(c.Color, color));
}

/// Draw a color-filled triangle, counter-clockwise vertex order
pub fn drawTriangle(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) void {
    c.DrawTriangle(cast.as(c.Vector2, v1), cast.as(c.Vector2, v2), cast.as(c.Vector2, v3), cast.as(c.Color, color));
}

/// Draw triangle with interpolated colors, counter-clockwise vertex/color order
pub fn drawTriangleGradient(v1: Vector2, v2: Vector2, v3: Vector2, c1: Color, c2: Color, c3: Color) void {
    c.DrawTriangleGradient(cast.as(c.Vector2, v1), cast.as(c.Vector2, v2), cast.as(c.Vector2, v3), cast.as(c.Color, c1), cast.as(c.Color, c2), cast.as(c.Color, c3));
}

/// Draw triangle outline, counter-clockwise vertex order
pub fn drawTriangleLines(v1: Vector2, v2: Vector2, v3: Vector2, color: Color) void {
    c.DrawTriangleLines(cast.as(c.Vector2, v1), cast.as(c.Vector2, v2), cast.as(c.Vector2, v3), cast.as(c.Color, color));
}

/// Draw triangle outline with line thickness, counter-clockwise vertex order
pub fn drawTriangleLinesEx(v1: Vector2, v2: Vector2, v3: Vector2, thick: f32, color: Color) void {
    c.DrawTriangleLinesEx(cast.as(c.Vector2, v1), cast.as(c.Vector2, v2), cast.as(c.Vector2, v3), thick, cast.as(c.Color, color));
}

/// Draw a triangle fan defined by points (first vertex is the center)
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawTriangleFan(points: []const Vector2, color: Color) void {
    c.DrawTriangleFan(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), cast.as(c.Color, color));
}

/// Draw a triangle strip defined by points
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawTriangleStrip(points: []const Vector2, color: Color) void {
    c.DrawTriangleStrip(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), cast.as(c.Color, color));
}

/// Draw a color-filled rectangle
pub fn drawRectangle(posX: i32, posY: i32, width: i32, height: i32, color: Color) void {
    c.DrawRectangle(posX, posY, width, height, cast.as(c.Color, color));
}

/// Draw a color-filled rectangle (Vector version)
pub fn drawRectangleV(position: Vector2, size: Vector2, color: Color) void {
    c.DrawRectangleV(cast.as(c.Vector2, position), cast.as(c.Vector2, size), cast.as(c.Color, color));
}

/// Draw a color-filled rectangle
pub fn drawRectangleRec(rec: Rectangle, color: Color) void {
    c.DrawRectangleRec(cast.as(c.Rectangle, rec), cast.as(c.Color, color));
}

/// Draw a color-filled rectangle with pro parameters
pub fn drawRectanglePro(rec: Rectangle, origin: Vector2, rotation: f32, color: Color) void {
    c.DrawRectanglePro(cast.as(c.Rectangle, rec), cast.as(c.Vector2, origin), rotation, cast.as(c.Color, color));
}

/// Draw a vertical-gradient-filled rectangle
pub fn drawRectangleGradientV(posX: i32, posY: i32, width: i32, height: i32, top: Color, bottom: Color) void {
    c.DrawRectangleGradientV(posX, posY, width, height, cast.as(c.Color, top), cast.as(c.Color, bottom));
}

/// Draw a horizontal-gradient-filled rectangle
pub fn drawRectangleGradientH(posX: i32, posY: i32, width: i32, height: i32, left: Color, right: Color) void {
    c.DrawRectangleGradientH(posX, posY, width, height, cast.as(c.Color, left), cast.as(c.Color, right));
}

/// Draw a gradient-filled rectangle with custom vertex colors, counter-clockwise color order
pub fn drawRectangleGradientEx(rec: Rectangle, col1: Color, col2: Color, col3: Color, col4: Color) void {
    c.DrawRectangleGradientEx(cast.as(c.Rectangle, rec), cast.as(c.Color, col1), cast.as(c.Color, col2), cast.as(c.Color, col3), cast.as(c.Color, col4));
}

/// Draw rectangle outline
pub fn drawRectangleLines(posX: i32, posY: i32, width: i32, height: i32, color: Color) void {
    c.DrawRectangleLines(posX, posY, width, height, cast.as(c.Color, color));
}

/// Draw rectangle outline with line thickness
pub fn drawRectangleLinesEx(rec: Rectangle, thick: f32, color: Color) void {
    c.DrawRectangleLinesEx(cast.as(c.Rectangle, rec), thick, cast.as(c.Color, color));
}

/// Draw rectangle with rounded edges
pub fn drawRectangleRounded(rec: Rectangle, roundness: f32, segments: i32, color: Color) void {
    c.DrawRectangleRounded(cast.as(c.Rectangle, rec), roundness, segments, cast.as(c.Color, color));
}

/// Draw rectangle lines with rounded edges
pub fn drawRectangleRoundedLines(rec: Rectangle, roundness: f32, segments: i32, color: Color) void {
    c.DrawRectangleRoundedLines(cast.as(c.Rectangle, rec), roundness, segments, cast.as(c.Color, color));
}

/// Draw rectangle lines with rounded edges outline and line thickness
pub fn drawRectangleRoundedLinesEx(rec: Rectangle, roundness: f32, segments: i32, thick: f32, color: Color) void {
    c.DrawRectangleRoundedLinesEx(cast.as(c.Rectangle, rec), roundness, segments, thick, cast.as(c.Color, color));
}

/// Draw a polygon of n sides
pub fn drawPoly(center: Vector2, sides: i32, radius: f32, rotation: f32, color: Color) void {
    c.DrawPoly(cast.as(c.Vector2, center), sides, radius, rotation, cast.as(c.Color, color));
}

/// Draw a polygon outline of n sides
pub fn drawPolyLines(center: Vector2, sides: i32, radius: f32, rotation: f32, color: Color) void {
    c.DrawPolyLines(cast.as(c.Vector2, center), sides, radius, rotation, cast.as(c.Color, color));
}

/// Draw a polygon outline of n sides with line thickness
pub fn drawPolyLinesEx(center: Vector2, sides: i32, radius: f32, rotation: f32, thick: f32, color: Color) void {
    c.DrawPolyLinesEx(cast.as(c.Vector2, center), sides, radius, rotation, thick, cast.as(c.Color, color));
}

/// Draw a color-filled circle
pub fn drawCircle(centerX: i32, centerY: i32, radius: f32, color: Color) void {
    c.DrawCircle(centerX, centerY, radius, cast.as(c.Color, color));
}

/// Draw a color-filled circle (Vector version)
pub fn drawCircleV(center: Vector2, radius: f32, color: Color) void {
    c.DrawCircleV(cast.as(c.Vector2, center), radius, cast.as(c.Color, color));
}

/// Draw a gradient-filled circle
pub fn drawCircleGradient(center: Vector2, radius: f32, inner: Color, outer: Color) void {
    c.DrawCircleGradient(cast.as(c.Vector2, center), radius, cast.as(c.Color, inner), cast.as(c.Color, outer));
}

/// Draw a piece of a circle
pub fn drawCircleSector(center: Vector2, radius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) void {
    c.DrawCircleSector(cast.as(c.Vector2, center), radius, startAngle, endAngle, segments, cast.as(c.Color, color));
}

/// Draw circle sector outline
pub fn drawCircleSectorLines(center: Vector2, radius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) void {
    c.DrawCircleSectorLines(cast.as(c.Vector2, center), radius, startAngle, endAngle, segments, cast.as(c.Color, color));
}

/// Draw circle sector outline with thickness
pub fn drawCircleSectorLinesEx(center: Vector2, radius: f32, startAngle: f32, endAngle: f32, segments: i32, thick: f32, color: Color) void {
    c.DrawCircleSectorLinesEx(cast.as(c.Vector2, center), radius, startAngle, endAngle, segments, thick, cast.as(c.Color, color));
}

/// Draw circle outline
pub fn drawCircleLines(centerX: i32, centerY: i32, radius: f32, color: Color) void {
    c.DrawCircleLines(centerX, centerY, radius, cast.as(c.Color, color));
}

/// Draw circle outline (Vector version)
pub fn drawCircleLinesV(center: Vector2, radius: f32, color: Color) void {
    c.DrawCircleLinesV(cast.as(c.Vector2, center), radius, cast.as(c.Color, color));
}

/// Draw circle outline with line thickness
pub fn drawCircleLinesEx(center: Vector2, radius: f32, thick: f32, color: Color) void {
    c.DrawCircleLinesEx(cast.as(c.Vector2, center), radius, thick, cast.as(c.Color, color));
}

/// Draw ellipse
pub fn drawEllipse(centerX: i32, centerY: i32, radiusH: f32, radiusV: f32, color: Color) void {
    c.DrawEllipse(centerX, centerY, radiusH, radiusV, cast.as(c.Color, color));
}

/// Draw ellipse (Vector version)
pub fn drawEllipseV(center: Vector2, radiusH: f32, radiusV: f32, color: Color) void {
    c.DrawEllipseV(cast.as(c.Vector2, center), radiusH, radiusV, cast.as(c.Color, color));
}

/// Draw ellipse outline
pub fn drawEllipseLines(centerX: i32, centerY: i32, radiusH: f32, radiusV: f32, color: Color) void {
    c.DrawEllipseLines(centerX, centerY, radiusH, radiusV, cast.as(c.Color, color));
}

/// Draw ellipse outline (Vector version)
pub fn drawEllipseLinesV(center: Vector2, radiusH: f32, radiusV: f32, color: Color) void {
    c.DrawEllipseLinesV(cast.as(c.Vector2, center), radiusH, radiusV, cast.as(c.Color, color));
}

/// Draw ellipse outline with line thickness
pub fn drawEllipseLinesEx(center: Vector2, radiusH: f32, radiusV: f32, thick: f32, color: Color) void {
    c.DrawEllipseLinesEx(cast.as(c.Vector2, center), radiusH, radiusV, thick, cast.as(c.Color, color));
}

/// Draw ring
pub fn drawRing(center: Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) void {
    c.DrawRing(cast.as(c.Vector2, center), innerRadius, outerRadius, startAngle, endAngle, segments, cast.as(c.Color, color));
}

/// Draw ring outline
pub fn drawRingLines(center: Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, segments: i32, color: Color) void {
    c.DrawRingLines(cast.as(c.Vector2, center), innerRadius, outerRadius, startAngle, endAngle, segments, cast.as(c.Color, color));
}

/// Draw ring outline with line thickness
pub fn drawRingLinesEx(center: Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, segments: i32, thick: f32, color: Color) void {
    c.DrawRingLinesEx(cast.as(c.Vector2, center), innerRadius, outerRadius, startAngle, endAngle, segments, thick, cast.as(c.Color, color));
}

/// Draw spline: Linear, minimum 2 points
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawSplineLinear(points: []const Vector2, thick: f32, color: Color) void {
    c.DrawSplineLinear(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), thick, cast.as(c.Color, color));
}

/// Draw spline: B-Spline, minimum 4 points
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawSplineBasis(points: []const Vector2, thick: f32, color: Color) void {
    c.DrawSplineBasis(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), thick, cast.as(c.Color, color));
}

/// Draw spline: Catmull-Rom, minimum 4 points
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawSplineCatmullRom(points: []const Vector2, thick: f32, color: Color) void {
    c.DrawSplineCatmullRom(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), thick, cast.as(c.Color, color));
}

/// Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...]
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawSplineBezierQuadratic(points: []const Vector2, thick: f32, color: Color) void {
    c.DrawSplineBezierQuadratic(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), thick, cast.as(c.Color, color));
}

/// Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...]
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn drawSplineBezierCubic(points: []const Vector2, thick: f32, color: Color) void {
    c.DrawSplineBezierCubic(cast.asArrayPtr(c.Vector2, points), cast.asLen(points), thick, cast.as(c.Color, color));
}

/// Draw spline segment: Linear, 2 points
pub fn drawSplineSegmentLinear(p1: Vector2, p2: Vector2, thick: f32, color: Color) void {
    c.DrawSplineSegmentLinear(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), thick, cast.as(c.Color, color));
}

/// Draw spline segment: B-Spline, 4 points
pub fn drawSplineSegmentBasis(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: f32, color: Color) void {
    c.DrawSplineSegmentBasis(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), cast.as(c.Vector2, p4), thick, cast.as(c.Color, color));
}

/// Draw spline segment: Catmull-Rom, 4 points
pub fn drawSplineSegmentCatmullRom(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: f32, color: Color) void {
    c.DrawSplineSegmentCatmullRom(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), cast.as(c.Vector2, p4), thick, cast.as(c.Color, color));
}

/// Draw spline segment: Quadratic Bezier, 2 points, 1 control point
pub fn drawSplineSegmentBezierQuadratic(p1: Vector2, c2: Vector2, p3: Vector2, thick: f32, color: Color) void {
    c.DrawSplineSegmentBezierQuadratic(cast.as(c.Vector2, p1), cast.as(c.Vector2, c2), cast.as(c.Vector2, p3), thick, cast.as(c.Color, color));
}

/// Draw spline segment: Cubic Bezier, 2 points, 2 control points
pub fn drawSplineSegmentBezierCubic(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, thick: f32, color: Color) void {
    c.DrawSplineSegmentBezierCubic(cast.as(c.Vector2, p1), cast.as(c.Vector2, c2), cast.as(c.Vector2, c3), cast.as(c.Vector2, p4), thick, cast.as(c.Color, color));
}

/// Get (evaluate) spline point: Linear
pub fn getSplinePointLinear(startPos: Vector2, endPos: Vector2, t: f32) Vector2 {
    return cast.as(Vector2, c.GetSplinePointLinear(cast.as(c.Vector2, startPos), cast.as(c.Vector2, endPos), t));
}

/// Get (evaluate) spline point: B-Spline
pub fn getSplinePointBasis(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: f32) Vector2 {
    return cast.as(Vector2, c.GetSplinePointBasis(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), cast.as(c.Vector2, p4), t));
}

/// Get (evaluate) spline point: Catmull-Rom
pub fn getSplinePointCatmullRom(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: f32) Vector2 {
    return cast.as(Vector2, c.GetSplinePointCatmullRom(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), cast.as(c.Vector2, p4), t));
}

/// Get (evaluate) spline point: Quadratic Bezier
pub fn getSplinePointBezierQuadratic(p1: Vector2, c2: Vector2, p3: Vector2, t: f32) Vector2 {
    return cast.as(Vector2, c.GetSplinePointBezierQuadratic(cast.as(c.Vector2, p1), cast.as(c.Vector2, c2), cast.as(c.Vector2, p3), t));
}

/// Get (evaluate) spline point: Cubic Bezier
pub fn getSplinePointBezierCubic(p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, t: f32) Vector2 {
    return cast.as(Vector2, c.GetSplinePointBezierCubic(cast.as(c.Vector2, p1), cast.as(c.Vector2, c2), cast.as(c.Vector2, c3), cast.as(c.Vector2, p4), t));
}

/// Check collision between two rectangles
pub fn checkCollisionRecs(rec1: Rectangle, rec2: Rectangle) bool {
    return c.CheckCollisionRecs(cast.as(c.Rectangle, rec1), cast.as(c.Rectangle, rec2));
}

/// Check collision between two circles
pub fn checkCollisionCircles(center1: Vector2, radius1: f32, center2: Vector2, radius2: f32) bool {
    return c.CheckCollisionCircles(cast.as(c.Vector2, center1), radius1, cast.as(c.Vector2, center2), radius2);
}

/// Check collision between circle and rectangle
pub fn checkCollisionCircleRec(center: Vector2, radius: f32, rec: Rectangle) bool {
    return c.CheckCollisionCircleRec(cast.as(c.Vector2, center), radius, cast.as(c.Rectangle, rec));
}

/// Check if circle collides with a line created between two points [p1] and [p2]
pub fn checkCollisionCircleLine(center: Vector2, radius: f32, p1: Vector2, p2: Vector2) bool {
    return c.CheckCollisionCircleLine(cast.as(c.Vector2, center), radius, cast.as(c.Vector2, p1), cast.as(c.Vector2, p2));
}

/// Check if point is inside rectangle
pub fn checkCollisionPointRec(point: Vector2, rec: Rectangle) bool {
    return c.CheckCollisionPointRec(cast.as(c.Vector2, point), cast.as(c.Rectangle, rec));
}

/// Check if point is inside circle
pub fn checkCollisionPointCircle(point: Vector2, center: Vector2, radius: f32) bool {
    return c.CheckCollisionPointCircle(cast.as(c.Vector2, point), cast.as(c.Vector2, center), radius);
}

/// Check if point is inside a triangle
pub fn checkCollisionPointTriangle(point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) bool {
    return c.CheckCollisionPointTriangle(cast.as(c.Vector2, point), cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3));
}

/// Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
pub fn checkCollisionPointLine(point: Vector2, p1: Vector2, p2: Vector2, threshold: i32) bool {
    return c.CheckCollisionPointLine(cast.as(c.Vector2, point), cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), threshold);
}

/// Check if point is within a polygon described by array of vertices
///
/// raylib takes a pointer and a count; raylibz takes the slice they describe.
pub fn checkCollisionPointPoly(point: Vector2, points: []const Vector2) bool {
    return c.CheckCollisionPointPoly(cast.as(c.Vector2, point), cast.asArrayPtr(c.Vector2, points), cast.asLen(points));
}

/// Check the collision between two lines defined by two points each, returns collision point by reference
///
/// raylib reports the crossing through an out-parameter; raylibz returns the
/// point itself, or `null` when the segments do not cross.
pub fn checkCollisionLines(startPos1: Vector2, endPos1: Vector2, startPos2: Vector2, endPos2: Vector2) ?Vector2 {
    var collision_point: c.Vector2 = undefined;
    const collided = c.CheckCollisionLines(
        cast.as(c.Vector2, startPos1),
        cast.as(c.Vector2, endPos1),
        cast.as(c.Vector2, startPos2),
        cast.as(c.Vector2, endPos2),
        &collision_point,
    );

    if (!collided) return null;
    return cast.as(Vector2, collision_point);
}

/// Get collision rectangle for two rectangles collision
pub fn getCollisionRec(rec1: Rectangle, rec2: Rectangle) Rectangle {
    return cast.as(Rectangle, c.GetCollisionRec(cast.as(c.Rectangle, rec1), cast.as(c.Rectangle, rec2)));
}

// The collision functions and the spline point evaluators are arithmetic over
// mirrored structs, so they run headless and can be checked against known
// answers. The spline evaluators are also checked against raylib's own result
// for the same input, which is what a mangled conversion would change.

test "checkCollisionLines: a crossing gives the point, no crossing gives null" {
    const crossing = checkCollisionLines(
        .{ .x = 0, .y = 0 },
        .{ .x = 10, .y = 10 },
        .{ .x = 0, .y = 10 },
        .{ .x = 10, .y = 0 },
    );
    const point = crossing orelse return error.TestUnexpectedResult;
    try internal.expectPoint(point, 5, 5);

    // The same segments through the raw layer: raylib's own answer, bit for bit.
    var expected: c.Vector2 = undefined;
    try internal.testing.expect(c.CheckCollisionLines(
        .{ .x = 0, .y = 0 },
        .{ .x = 10, .y = 10 },
        .{ .x = 0, .y = 10 },
        .{ .x = 10, .y = 0 },
        &expected,
    ));
    try internal.expectSamePoint(point, expected);

    // Parallel segments meet only at infinity.
    try internal.testing.expect(checkCollisionLines(
        .{ .x = 0, .y = 0 },
        .{ .x = 1, .y = 1 },
        .{ .x = 0, .y = 1 },
        .{ .x = 1, .y = 2 },
    ) == null);

    // The lines cross, but beyond the end of the first segment.
    try internal.testing.expect(checkCollisionLines(
        .{ .x = 0, .y = 0 },
        .{ .x = 1, .y = 1 },
        .{ .x = 2, .y = 0 },
        .{ .x = 2, .y = 5 },
    ) == null);
}

test "collision: rectangles, circles and points against known answers" {
    const ten_by_ten = Rectangle{ .x = 0, .y = 0, .width = 10, .height = 10 };

    // Overlapping rectangles collide, and their collision rectangle is the overlap.
    try internal.testing.expect(checkCollisionRecs(ten_by_ten, .{ .x = 5, .y = 5, .width = 10, .height = 10 }));
    try internal.expectRectangle(getCollisionRec(ten_by_ten, .{ .x = 5, .y = 5, .width = 10, .height = 10 }), 5, 5, 5, 5);
    // raylib's rectangle test is strict: edges that only touch do not collide,
    // and the collision rectangle of separate rectangles is empty.
    try internal.testing.expect(!checkCollisionRecs(ten_by_ten, .{ .x = 10, .y = 0, .width = 5, .height = 5 }));
    try internal.expectRectangle(getCollisionRec(ten_by_ten, .{ .x = 20, .y = 20, .width = 5, .height = 5 }), 0, 0, 0, 0);

    // Circles collide when the distance between the centers is at most the sum
    // of the radii, so tangent circles do.
    try internal.testing.expect(checkCollisionCircles(.{ .x = 0, .y = 0 }, 1, .{ .x = 2, .y = 0 }, 1));
    try internal.testing.expect(!checkCollisionCircles(.{ .x = 0, .y = 0 }, 1, .{ .x = 3, .y = 0 }, 1));

    try internal.testing.expect(checkCollisionCircleRec(.{ .x = 5, .y = 5 }, 0.5, ten_by_ten));
    try internal.testing.expect(!checkCollisionCircleRec(.{ .x = 11, .y = 11 }, 1, ten_by_ten));
    try internal.testing.expect(checkCollisionCircleRec(.{ .x = 11, .y = 11 }, 2, ten_by_ten)); // reaches the corner, sqrt(2) away

    try internal.testing.expect(checkCollisionCircleLine(.{ .x = 0, .y = 0 }, 1, .{ .x = 0.5, .y = -2 }, .{ .x = 0.5, .y = 2 }));
    try internal.testing.expect(!checkCollisionCircleLine(.{ .x = 0, .y = 0 }, 1, .{ .x = 2, .y = -2 }, .{ .x = 2, .y = 2 }));
    // A segment whose ends meet is a point.
    try internal.testing.expect(checkCollisionCircleLine(.{ .x = 0, .y = 0 }, 1, .{ .x = 0.5, .y = 0 }, .{ .x = 0.5, .y = 0 }));

    // Points: the right and bottom edges of a rectangle are outside it.
    try internal.testing.expect(checkCollisionPointRec(.{ .x = 9.5, .y = 9.5 }, ten_by_ten));
    try internal.testing.expect(!checkCollisionPointRec(.{ .x = 10, .y = 5 }, ten_by_ten));
    try internal.testing.expect(checkCollisionPointCircle(.{ .x = 3, .y = 4 }, .{ .x = 0, .y = 0 }, 5));
    try internal.testing.expect(!checkCollisionPointCircle(.{ .x = 3, .y = 4 }, .{ .x = 0, .y = 0 }, 4.9));

    // raylib's triangle test is strict about the edges, so a vertex is outside.
    try internal.testing.expect(checkCollisionPointTriangle(.{ .x = 1, .y = 1 }, .{ .x = 0, .y = 0 }, .{ .x = 10, .y = 0 }, .{ .x = 0, .y = 10 }));
    try internal.testing.expect(!checkCollisionPointTriangle(.{ .x = 9, .y = 9 }, .{ .x = 0, .y = 0 }, .{ .x = 10, .y = 0 }, .{ .x = 0, .y = 10 }));
    try internal.testing.expect(!checkCollisionPointTriangle(.{ .x = 0, .y = 0 }, .{ .x = 0, .y = 0 }, .{ .x = 10, .y = 0 }, .{ .x = 0, .y = 10 }));

    // The line margin is raylib's: a cross product against the segment's longest axis.
    try internal.testing.expect(checkCollisionPointLine(.{ .x = 5, .y = 3 }, .{ .x = 0, .y = 0 }, .{ .x = 10, .y = 0 }, 4));
    try internal.testing.expect(!checkCollisionPointLine(.{ .x = 5, .y = 3 }, .{ .x = 0, .y = 0 }, .{ .x = 10, .y = 0 }, 2));
    try internal.testing.expect(!checkCollisionPointLine(.{ .x = -5, .y = 0 }, .{ .x = 0, .y = 0 }, .{ .x = 10, .y = 0 }, 4)); // past the first endpoint
}

test "checkCollisionPointPoly: the slice's pointer and length both reach raylib" {
    // The polygon is the slice, not the array: the leading vertex is not part
    // of it, and taking the array's address instead would change every answer.
    const points = [_]Vector2{
        .{ .x = 100, .y = 100 },
        .{ .x = 0, .y = 0 },
        .{ .x = 10, .y = 0 },
        .{ .x = 10, .y = 10 },
        .{ .x = 0, .y = 10 },
    };

    const square = points[1..5];
    try internal.testing.expect(checkCollisionPointPoly(.{ .x = 5, .y = 5 }, square));
    try internal.testing.expect(!checkCollisionPointPoly(.{ .x = 15, .y = 5 }, square));

    // The first four vertices are a triangle: (7.5, 2.5) is inside it, and
    // (2.5, 7.5) is inside the square but outside the triangle.
    const triangle = points[1..4];
    try internal.testing.expect(checkCollisionPointPoly(.{ .x = 7.5, .y = 2.5 }, triangle));
    try internal.testing.expect(!checkCollisionPointPoly(.{ .x = 2.5, .y = 7.5 }, triangle));

    // raylib needs three vertices: two are not a polygon, and neither is none.
    try internal.testing.expect(!checkCollisionPointPoly(.{ .x = 5, .y = 5 }, points[1..3]));
    try internal.testing.expect(!checkCollisionPointPoly(.{ .x = 5, .y = 5 }, points[0..0]));
}

test "setShapesTexture: the texture and its source rectangle come back whole" {
    const texture = Texture2D{
        .id = 7,
        .width = 4,
        .height = 4,
        .mipmaps = 1,
        .format = .pixelformat_uncompressed_r8g8b8a8,
    };
    const rec = Rectangle{ .x = 1, .y = 2, .width = 3, .height = 4 };

    setShapesTexture(texture, rec);
    const got = getShapesTexture();
    try internal.testing.expectEqual(texture.id, got.id);
    try internal.testing.expectEqual(texture.width, got.width);
    try internal.testing.expectEqual(texture.height, got.height);
    try internal.testing.expectEqual(texture.mipmaps, got.mipmaps);
    try internal.testing.expectEqual(texture.format, got.format);
    try internal.expectRectangle(getShapesTextureRectangle(), rec.x, rec.y, rec.width, rec.height);

    // raylib's own reset: a zero-sized source rectangle restores its default pixel.
    setShapesTexture(texture, .{ .x = 0, .y = 0, .width = 0, .height = 0 });
    try internal.testing.expectEqual(@as(u32, 1), getShapesTexture().id);
}

test "spline points: the known answer of every curve" {
    try internal.expectPoint(getSplinePointLinear(.{ .x = 0, .y = 0 }, .{ .x = 10, .y = 20 }, 0), 0, 0);
    try internal.expectPoint(getSplinePointLinear(.{ .x = 0, .y = 0 }, .{ .x = 10, .y = 20 }, 0.5), 5, 10);
    try internal.expectPoint(getSplinePointLinear(.{ .x = 0, .y = 0 }, .{ .x = 10, .y = 20 }, 1), 10, 20);

    const p1 = Vector2{ .x = 0, .y = 0 };
    const p2 = Vector2{ .x = 1, .y = 2 };
    const p3 = Vector2{ .x = 3, .y = 4 };
    const p4 = Vector2{ .x = 6, .y = 8 };

    // Catmull-Rom runs through its two middle points.
    try internal.expectPoint(getSplinePointCatmullRom(p1, p2, p3, p4, 0), p2.x, p2.y);
    try internal.expectPoint(getSplinePointCatmullRom(p1, p2, p3, p4, 1), p3.x, p3.y);

    // The uniform cubic B-spline's own endpoints: (p1 + 4*p2 + p3)/6 and
    // (p2 + 4*p3 + p4)/6.
    try internal.expectPoint(getSplinePointBasis(p1, p2, p3, p4, 0), (p1.x + 4 * p2.x + p3.x) / 6, (p1.y + 4 * p2.y + p3.y) / 6);
    try internal.expectPoint(getSplinePointBasis(p1, p2, p3, p4, 1), (p2.x + 4 * p3.x + p4.x) / 6, (p2.y + 4 * p3.y + p4.y) / 6);

    // Quadratic Bezier: halfway along the (0,0)-(0,10)-(10,0) arc.
    try internal.expectPoint(getSplinePointBezierQuadratic(.{ .x = 0, .y = 0 }, .{ .x = 0, .y = 10 }, .{ .x = 10, .y = 0 }, 0.5), 2.5, 5);

    // Cubic Bezier: halfway along the classic S-curve.
    try internal.expectPoint(getSplinePointBezierCubic(.{ .x = 0, .y = 0 }, .{ .x = 0, .y = 10 }, .{ .x = 10, .y = 10 }, .{ .x = 10, .y = 0 }, 0.5), 5, 7.5);
}

test "spline points: the wrappers hand raylib the values it takes raw" {
    const p1 = Vector2{ .x = -1.5, .y = 2.25 };
    const p2 = Vector2{ .x = 0.5, .y = -3.75 };
    const p3 = Vector2{ .x = 4.25, .y = 1.5 };
    const p4 = Vector2{ .x = 7.75, .y = -0.25 };

    try internal.expectSamePoint(
        getSplinePointLinear(p1, p2, 0.375),
        c.GetSplinePointLinear(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), 0.375),
    );
    try internal.expectSamePoint(
        getSplinePointBasis(p1, p2, p3, p4, 0.375),
        c.GetSplinePointBasis(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), cast.as(c.Vector2, p4), 0.375),
    );
    try internal.expectSamePoint(
        getSplinePointCatmullRom(p1, p2, p3, p4, 0.375),
        c.GetSplinePointCatmullRom(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), cast.as(c.Vector2, p4), 0.375),
    );
    try internal.expectSamePoint(
        getSplinePointBezierQuadratic(p1, p2, p3, 0.375),
        c.GetSplinePointBezierQuadratic(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), 0.375),
    );
    try internal.expectSamePoint(
        getSplinePointBezierCubic(p1, p2, p3, p4, 0.375),
        c.GetSplinePointBezierCubic(cast.as(c.Vector2, p1), cast.as(c.Vector2, p2), cast.as(c.Vector2, p3), cast.as(c.Vector2, p4), 0.375),
    );
}
