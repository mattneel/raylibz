//! raylib's models module: meshes, models, materials and shaders, animations and
//! the 3D collision stack (rays, bounding boxes), and the 3D drawing calls.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, a load that raylib pairs with an
//! `Is*Valid` check as `error{LoadFailed}!T`, and raylib's own one-line comment
//! copied above the wrapper. What is not wrapped is listed in `not_wrapped`.
//!
//! This file imports only names the root also publishes (`c`, `cast`, `types`,
//! the vector files and the type names they hold), because the root's re-export
//! test requires every top-level declaration here to exist in `raylibz` too.
//! Private helpers go in a `const internal = struct { ... };`, which that test
//! skips.

const c = @import("raylib");
const cast = @import("cast.zig");
const enums = @import("enums.zig");
const matrix = @import("matrix.zig");
const types = @import("types.zig");
const vector2 = @import("vector2.zig");
const vector3 = @import("vector3.zig");

const BoundingBox = types.BoundingBox;
const Camera = types.Camera;
const Color = types.Color;
const Image = types.Image;
const Material = types.Material;
const MaterialMapIndex = enums.MaterialMapIndex;
const Matrix = matrix.Matrix;
const Mesh = types.Mesh;
const Model = types.Model;
const ModelAnimation = types.ModelAnimation;
const Ray = types.Ray;
const RayCollision = types.RayCollision;
const Rectangle = types.Rectangle;
const Texture2D = types.Texture2D;
const Vector2 = vector2.Vector2;
const Vector3 = vector3.Vector3;

/// The functions of raylib.h's models module that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

// raylib.h's "Basic geometric 3D shapes drawing functions".

/// Draw a line in 3D world space
pub fn drawLine3D(startPos: Vector3, endPos: Vector3, color: Color) void {
    c.DrawLine3D(cast.as(c.Vector3, startPos), cast.as(c.Vector3, endPos), cast.as(c.Color, color));
}

/// Draw a point in 3D space, actually a small line
pub fn drawPoint3D(position: Vector3, color: Color) void {
    c.DrawPoint3D(cast.as(c.Vector3, position), cast.as(c.Color, color));
}

/// Draw a circle in 3D world space
pub fn drawCircle3D(center: Vector3, radius: f32, rotationAxis: Vector3, rotationAngle: f32, color: Color) void {
    c.DrawCircle3D(
        cast.as(c.Vector3, center),
        radius,
        cast.as(c.Vector3, rotationAxis),
        rotationAngle,
        cast.as(c.Color, color),
    );
}

/// Draw a color-filled triangle, counter-clockwise vertex order
pub fn drawTriangle3D(v1: Vector3, v2: Vector3, v3: Vector3, color: Color) void {
    c.DrawTriangle3D(
        cast.as(c.Vector3, v1),
        cast.as(c.Vector3, v2),
        cast.as(c.Vector3, v3),
        cast.as(c.Color, color),
    );
}

/// Draw a triangle strip defined by points
///
/// raylib takes the points as a pointer plus a count; raylibz takes them as a
/// slice, whose length is raylib's point count.
pub fn drawTriangleStrip3D(points: []const Vector3, color: Color) void {
    c.DrawTriangleStrip3D(cast.asArrayPtr(c.Vector3, points), cast.asLen(points), cast.as(c.Color, color));
}

/// Draw cube
pub fn drawCube(position: Vector3, width: f32, height: f32, length: f32, color: Color) void {
    c.DrawCube(cast.as(c.Vector3, position), width, height, length, cast.as(c.Color, color));
}

/// Draw cube (Vector version)
pub fn drawCubeV(position: Vector3, size: Vector3, color: Color) void {
    c.DrawCubeV(cast.as(c.Vector3, position), cast.as(c.Vector3, size), cast.as(c.Color, color));
}

/// Draw cube wires
pub fn drawCubeWires(position: Vector3, width: f32, height: f32, length: f32, color: Color) void {
    c.DrawCubeWires(cast.as(c.Vector3, position), width, height, length, cast.as(c.Color, color));
}

/// Draw cube wires (Vector version)
pub fn drawCubeWiresV(position: Vector3, size: Vector3, color: Color) void {
    c.DrawCubeWiresV(cast.as(c.Vector3, position), cast.as(c.Vector3, size), cast.as(c.Color, color));
}

/// Draw sphere
pub fn drawSphere(centerPos: Vector3, radius: f32, color: Color) void {
    c.DrawSphere(cast.as(c.Vector3, centerPos), radius, cast.as(c.Color, color));
}

/// Draw sphere with defined rings and slices
pub fn drawSphereEx(centerPos: Vector3, radius: f32, rings: i32, slices: i32, color: Color) void {
    c.DrawSphereEx(cast.as(c.Vector3, centerPos), radius, rings, slices, cast.as(c.Color, color));
}

/// Draw sphere wires
pub fn drawSphereWires(centerPos: Vector3, radius: f32, rings: i32, slices: i32, color: Color) void {
    c.DrawSphereWires(cast.as(c.Vector3, centerPos), radius, rings, slices, cast.as(c.Color, color));
}

/// Draw a cylinder/cone
pub fn drawCylinder(position: Vector3, radiusTop: f32, radiusBottom: f32, height: f32, sides: i32, color: Color) void {
    c.DrawCylinder(
        cast.as(c.Vector3, position),
        radiusTop,
        radiusBottom,
        height,
        sides,
        cast.as(c.Color, color),
    );
}

/// Draw a cylinder with base at startPos and top at endPos
pub fn drawCylinderEx(startPos: Vector3, endPos: Vector3, startRadius: f32, endRadius: f32, sides: i32, color: Color) void {
    c.DrawCylinderEx(
        cast.as(c.Vector3, startPos),
        cast.as(c.Vector3, endPos),
        startRadius,
        endRadius,
        sides,
        cast.as(c.Color, color),
    );
}

/// Draw a cylinder/cone wires
pub fn drawCylinderWires(position: Vector3, radiusTop: f32, radiusBottom: f32, height: f32, sides: i32, color: Color) void {
    c.DrawCylinderWires(
        cast.as(c.Vector3, position),
        radiusTop,
        radiusBottom,
        height,
        sides,
        cast.as(c.Color, color),
    );
}

/// Draw a cylinder wires with base at startPos and top at endPos
pub fn drawCylinderWiresEx(startPos: Vector3, endPos: Vector3, startRadius: f32, endRadius: f32, sides: i32, color: Color) void {
    c.DrawCylinderWiresEx(
        cast.as(c.Vector3, startPos),
        cast.as(c.Vector3, endPos),
        startRadius,
        endRadius,
        sides,
        cast.as(c.Color, color),
    );
}

/// Draw a capsule with the center of its sphere caps at startPos and endPos
pub fn drawCapsule(startPos: Vector3, endPos: Vector3, radius: f32, rings: i32, slices: i32, color: Color) void {
    c.DrawCapsule(
        cast.as(c.Vector3, startPos),
        cast.as(c.Vector3, endPos),
        radius,
        rings,
        slices,
        cast.as(c.Color, color),
    );
}

/// Draw capsule wireframe with the center of its sphere caps at startPos and endPos
pub fn drawCapsuleWires(startPos: Vector3, endPos: Vector3, radius: f32, rings: i32, slices: i32, color: Color) void {
    c.DrawCapsuleWires(
        cast.as(c.Vector3, startPos),
        cast.as(c.Vector3, endPos),
        radius,
        rings,
        slices,
        cast.as(c.Color, color),
    );
}

/// Draw a plane XZ
pub fn drawPlane(centerPos: Vector3, size: Vector2, color: Color) void {
    c.DrawPlane(cast.as(c.Vector3, centerPos), cast.as(c.Vector2, size), cast.as(c.Color, color));
}

/// Draw a ray line
pub fn drawRay(ray: Ray, color: Color) void {
    c.DrawRay(cast.as(c.Ray, ray), cast.as(c.Color, color));
}

/// Draw a grid (centered at (0, 0, 0))
///
/// raylib's signature takes no mirrored type, enum, text or buffer, so raylibz
/// re-exports it unchanged.
pub const drawGrid = c.DrawGrid;

// raylib.h's "Model management functions".

/// Load model from files (meshes and materials)
///
/// raylib pairs the load with `isModelValid`; raylibz makes that check and
/// returns `error.LoadFailed` instead of an unusable model.
pub fn loadModel(fileName: [:0]const u8) error{LoadFailed}!Model {
    const model = cast.as(Model, c.LoadModel(cast.cstr(fileName)));
    if (!isModelValid(model)) return error.LoadFailed;
    return model;
}

/// Load model from generated mesh (default material)
///
/// raylib copies the mesh shallowly: the model's mesh points at the same vertex
/// data as `mesh`, so `mesh` must not be used (or unloaded) afterwards —
/// `unloadModel` releases that data. raylib pairs the load with
/// `isModelValid`; raylibz makes that check and returns `error.LoadFailed`
/// instead of an unusable model.
pub fn loadModelFromMesh(mesh: Mesh) error{LoadFailed}!Model {
    const model = cast.as(Model, c.LoadModelFromMesh(cast.as(c.Mesh, mesh)));
    if (!isModelValid(model)) return error.LoadFailed;
    return model;
}

/// Check if model is valid (loaded in GPU, VAO/VBOs)
pub fn isModelValid(model: Model) bool {
    return c.IsModelValid(cast.as(c.Model, model));
}

/// Unload model (including meshes) from memory (RAM and/or VRAM)
///
/// Takes ownership of the model — its meshes, its materials' maps, and its
/// skeleton, pose and bone-matrix arrays — and releases them; it dies at this
/// call. raylib leaves the shaders and textures those materials point at alone,
/// since the caller may share them between models.
pub fn unloadModel(model: Model) void {
    c.UnloadModel(cast.as(c.Model, model));
}

/// Compute model bounding box limits (considers all meshes)
pub fn getModelBoundingBox(model: Model) BoundingBox {
    return cast.as(BoundingBox, c.GetModelBoundingBox(cast.as(c.Model, model)));
}

// raylib.h's "Model drawing functions".

/// Draw a model (with texture if set)
pub fn drawModel(model: Model, position: Vector3, scale: f32, tint: Color) void {
    c.DrawModel(cast.as(c.Model, model), cast.as(c.Vector3, position), scale, cast.as(c.Color, tint));
}

/// Draw a model with custom transform
pub fn drawModelEx(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) void {
    c.DrawModelEx(
        cast.as(c.Model, model),
        cast.as(c.Vector3, position),
        cast.as(c.Vector3, rotationAxis),
        rotationAngle,
        cast.as(c.Vector3, scale),
        cast.as(c.Color, tint),
    );
}

/// Draw a model wires (with texture if set)
pub fn drawModelWires(model: Model, position: Vector3, scale: f32, tint: Color) void {
    c.DrawModelWires(cast.as(c.Model, model), cast.as(c.Vector3, position), scale, cast.as(c.Color, tint));
}

/// Draw a model wires with custom transform
pub fn drawModelWiresEx(model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: f32, scale: Vector3, tint: Color) void {
    c.DrawModelWiresEx(
        cast.as(c.Model, model),
        cast.as(c.Vector3, position),
        cast.as(c.Vector3, rotationAxis),
        rotationAngle,
        cast.as(c.Vector3, scale),
        cast.as(c.Color, tint),
    );
}

/// Draw bounding box (wires)
pub fn drawBoundingBox(box: BoundingBox, color: Color) void {
    c.DrawBoundingBox(cast.as(c.BoundingBox, box), cast.as(c.Color, color));
}

/// Draw a billboard texture
pub fn drawBillboard(camera: Camera, texture: Texture2D, position: Vector3, scale: f32, tint: Color) void {
    c.DrawBillboard(
        cast.as(c.Camera, camera),
        cast.as(c.Texture2D, texture),
        cast.as(c.Vector3, position),
        scale,
        cast.as(c.Color, tint),
    );
}

/// Draw a billboard texture defined by rectangle
pub fn drawBillboardRec(camera: Camera, texture: Texture2D, rec: Rectangle, position: Vector3, size: Vector2, tint: Color) void {
    c.DrawBillboardRec(
        cast.as(c.Camera, camera),
        cast.as(c.Texture2D, texture),
        cast.as(c.Rectangle, rec),
        cast.as(c.Vector3, position),
        cast.as(c.Vector2, size),
        cast.as(c.Color, tint),
    );
}

/// Draw a billboard texture defined by source rectangle with scaling and rotation
pub fn drawBillboardPro(camera: Camera, texture: Texture2D, rec: Rectangle, position: Vector3, up: Vector3, size: Vector2, origin: Vector2, rotation: f32, tint: Color) void {
    c.DrawBillboardPro(
        cast.as(c.Camera, camera),
        cast.as(c.Texture2D, texture),
        cast.as(c.Rectangle, rec),
        cast.as(c.Vector3, position),
        cast.as(c.Vector3, up),
        cast.as(c.Vector2, size),
        cast.as(c.Vector2, origin),
        rotation,
        cast.as(c.Color, tint),
    );
}

// raylib.h's "Mesh management functions".

/// Upload mesh vertex data in GPU and provide VAO/VBO ids
///
/// raylib takes `Mesh *` and fills in the mesh's VAO/VBO ids in place; raylibz
/// takes `*Mesh`.
pub fn uploadMesh(mesh: *Mesh, dynamic: bool) void {
    c.UploadMesh(cast.asPtr(c.Mesh, mesh), dynamic);
}

/// Update mesh vertex data in GPU for a specific buffer index
///
/// raylib takes the data as a pointer plus a byte count; raylibz takes it as a
/// byte slice, whose length is raylib's `dataSize`.
pub fn updateMeshBuffer(mesh: Mesh, index: i32, data: []const u8, offset: i32) void {
    c.UpdateMeshBuffer(cast.as(c.Mesh, mesh), index, @ptrCast(data.ptr), cast.asLen(data), offset);
}

/// Unload mesh data from CPU and GPU
///
/// Takes ownership of the mesh, its vertex data and its GPU buffers; it dies at
/// this call.
pub fn unloadMesh(mesh: Mesh) void {
    c.UnloadMesh(cast.as(c.Mesh, mesh));
}

/// Draw a 3d mesh with material and transform
pub fn drawMesh(mesh: Mesh, material: Material, transform: Matrix) void {
    c.DrawMesh(cast.as(c.Mesh, mesh), cast.as(c.Material, material), cast.as(c.Matrix, transform));
}

/// Draw multiple mesh instances with material and different transforms
///
/// raylib takes the transforms as a pointer plus a count; raylibz takes them as
/// a slice, whose length is raylib's instance count.
pub fn drawMeshInstanced(mesh: Mesh, material: Material, transforms: []const Matrix) void {
    c.DrawMeshInstanced(
        cast.as(c.Mesh, mesh),
        cast.as(c.Material, material),
        cast.asArrayPtr(c.Matrix, transforms),
        cast.asLen(transforms),
    );
}

/// Compute mesh bounding box limits
pub fn getMeshBoundingBox(mesh: Mesh) BoundingBox {
    return cast.as(BoundingBox, c.GetMeshBoundingBox(cast.as(c.Mesh, mesh)));
}

/// Compute mesh tangents
///
/// raylib takes `Mesh *` and fills the mesh's tangent data in place; raylibz
/// takes `*Mesh`.
pub fn genMeshTangents(mesh: *Mesh) void {
    c.GenMeshTangents(cast.asPtr(c.Mesh, mesh));
}

/// Export mesh data to file, returns true on success
///
/// raylibz keeps raylib's `bool`: the export either wrote the file or did not,
/// and there is no out-parameter to carry.
pub fn exportMesh(mesh: Mesh, fileName: [:0]const u8) bool {
    return c.ExportMesh(cast.as(c.Mesh, mesh), cast.cstr(fileName));
}

/// Export mesh as code file (.h) defining multiple arrays of vertex attributes
///
/// raylibz keeps raylib's `bool`: the export either wrote the file or did not,
/// and there is no out-parameter to carry.
pub fn exportMeshAsCode(mesh: Mesh, fileName: [:0]const u8) bool {
    return c.ExportMeshAsCode(cast.as(c.Mesh, mesh), cast.cstr(fileName));
}

// raylib.h's "Mesh generation functions".

/// Generate polygonal mesh
pub fn genMeshPoly(sides: i32, radius: f32) Mesh {
    return cast.as(Mesh, c.GenMeshPoly(sides, radius));
}

/// Generate plane mesh (with subdivisions)
pub fn genMeshPlane(width: f32, length: f32, resX: i32, resZ: i32) Mesh {
    return cast.as(Mesh, c.GenMeshPlane(width, length, resX, resZ));
}

/// Generate cuboid mesh
pub fn genMeshCube(width: f32, height: f32, length: f32) Mesh {
    return cast.as(Mesh, c.GenMeshCube(width, height, length));
}

/// Generate sphere mesh (standard sphere)
pub fn genMeshSphere(radius: f32, rings: i32, slices: i32) Mesh {
    return cast.as(Mesh, c.GenMeshSphere(radius, rings, slices));
}

/// Generate half-sphere mesh (no bottom cap)
pub fn genMeshHemiSphere(radius: f32, rings: i32, slices: i32) Mesh {
    return cast.as(Mesh, c.GenMeshHemiSphere(radius, rings, slices));
}

/// Generate cylinder mesh
pub fn genMeshCylinder(radius: f32, height: f32, slices: i32) Mesh {
    return cast.as(Mesh, c.GenMeshCylinder(radius, height, slices));
}

/// Generate cone/pyramid mesh
pub fn genMeshCone(radius: f32, height: f32, slices: i32) Mesh {
    return cast.as(Mesh, c.GenMeshCone(radius, height, slices));
}

/// Generate torus mesh
pub fn genMeshTorus(radius: f32, size: f32, radSeg: i32, sides: i32) Mesh {
    return cast.as(Mesh, c.GenMeshTorus(radius, size, radSeg, sides));
}

/// Generate trefoil knot mesh
pub fn genMeshKnot(radius: f32, size: f32, radSeg: i32, sides: i32) Mesh {
    return cast.as(Mesh, c.GenMeshKnot(radius, size, radSeg, sides));
}

/// Generate heightmap mesh from image data
pub fn genMeshHeightmap(heightmap: Image, size: Vector3) Mesh {
    return cast.as(Mesh, c.GenMeshHeightmap(cast.as(c.Image, heightmap), cast.as(c.Vector3, size)));
}

/// Generate cubes-based map mesh from image data
pub fn genMeshCubicmap(cubicmap: Image, cubeSize: Vector3) Mesh {
    return cast.as(Mesh, c.GenMeshCubicmap(cast.as(c.Image, cubicmap), cast.as(c.Vector3, cubeSize)));
}

// raylib.h's "Material loading/unloading functions".

/// Load materials from model file
///
/// raylib returns its own array plus a count; raylibz returns the array as a
/// slice, and `null` where raylib found none. raylib has no function that
/// releases this array — unload each material with `unloadMaterial`, then free
/// the array with `raylibz.memFree`.
pub fn loadMaterials(fileName: [:0]const u8) ?[]Material {
    var count: i32 = 0;
    const materials = c.LoadMaterials(cast.cstr(fileName), &count);
    return cast.asSlice(Material, @ptrCast(materials), count);
}

/// Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
///
/// raylib pairs the load with `isMaterialValid`; raylibz makes that check and
/// returns `error.LoadFailed` instead of an unusable material. The check asks
/// raylib for its default shader id, so a material loaded before the GPU
/// context exists is not valid.
pub fn loadMaterialDefault() error{LoadFailed}!Material {
    const material = cast.as(Material, c.LoadMaterialDefault());
    if (!isMaterialValid(material)) return error.LoadFailed;
    return material;
}

/// Check if material is valid (shader assigned, map textures loaded in GPU)
pub fn isMaterialValid(material: Material) bool {
    return c.IsMaterialValid(cast.as(c.Material, material));
}

/// Unload material from GPU memory (VRAM)
///
/// Takes ownership of the material's maps array, and of the shader and the map
/// textures it holds, and releases them; it dies at this call. raylib leaves
/// its own default shader and default texture alone.
pub fn unloadMaterial(material: Material) void {
    c.UnloadMaterial(cast.as(c.Material, material));
}

/// Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
///
/// `mapType` is raylib's `MATERIAL_MAP_*` value, raylibz's `MaterialMapIndex`.
/// The texture the map held before this call is the caller's to unload.
pub fn setMaterialTexture(material: *Material, mapType: MaterialMapIndex, texture: Texture2D) void {
    c.SetMaterialTexture(cast.asPtr(c.Material, material), @backingInt(mapType), cast.as(c.Texture2D, texture));
}

/// Set material for a mesh
///
/// raylib takes `Model *` and rewrites the model's mesh-material link in place;
/// raylibz takes `*Model`.
pub fn setModelMeshMaterial(model: *Model, meshId: i32, materialId: i32) void {
    c.SetModelMeshMaterial(cast.asPtr(c.Model, model), meshId, materialId);
}

// raylib.h's "Model animations loading/unloading functions".

/// Load model animations from file
///
/// raylib returns its own array plus a count; raylibz returns the array as a
/// slice, and `null` where raylib loaded none. Release the slice with
/// `unloadModelAnimations`.
pub fn loadModelAnimations(fileName: [:0]const u8) ?[]ModelAnimation {
    var count: i32 = 0;
    const animations = c.LoadModelAnimations(cast.cstr(fileName), &count);
    return cast.asSlice(ModelAnimation, @ptrCast(animations), count);
}

/// Update model animation pose (vertex buffers and bone matrices)
pub fn updateModelAnimation(model: Model, anim: ModelAnimation, frame: f32) void {
    c.UpdateModelAnimation(cast.as(c.Model, model), cast.as(c.ModelAnimation, anim), frame);
}

/// Update model animation pose, blending two animations
pub fn updateModelAnimationEx(model: Model, animA: ModelAnimation, frameA: f32, animB: ModelAnimation, frameB: f32, blend: f32) void {
    c.UpdateModelAnimationEx(
        cast.as(c.Model, model),
        cast.as(c.ModelAnimation, animA),
        frameA,
        cast.as(c.ModelAnimation, animB),
        frameB,
        blend,
    );
}

/// Unload animation array data
///
/// Takes ownership of the animation array, and of each animation's keyframe
/// poses and the frames they point at, and releases them; it dies at this call.
pub fn unloadModelAnimations(animations: []ModelAnimation) void {
    c.UnloadModelAnimations(cast.asArrayPtrMut(c.ModelAnimation, animations), cast.asLen(animations));
}

/// Check model animation skeleton match
pub fn isModelAnimationValid(model: Model, anim: ModelAnimation) bool {
    return c.IsModelAnimationValid(cast.as(c.Model, model), cast.as(c.ModelAnimation, anim));
}

// raylib.h's "Collision detection functions".

/// Check collision between two spheres
pub fn checkCollisionSpheres(center1: Vector3, radius1: f32, center2: Vector3, radius2: f32) bool {
    return c.CheckCollisionSpheres(
        cast.as(c.Vector3, center1),
        radius1,
        cast.as(c.Vector3, center2),
        radius2,
    );
}

/// Check collision between two bounding boxes
pub fn checkCollisionBoxes(box1: BoundingBox, box2: BoundingBox) bool {
    return c.CheckCollisionBoxes(cast.as(c.BoundingBox, box1), cast.as(c.BoundingBox, box2));
}

/// Check collision between box and sphere
pub fn checkCollisionBoxSphere(box: BoundingBox, center: Vector3, radius: f32) bool {
    return c.CheckCollisionBoxSphere(cast.as(c.BoundingBox, box), cast.as(c.Vector3, center), radius);
}

/// Get collision info between ray and sphere
pub fn getRayCollisionSphere(ray: Ray, center: Vector3, radius: f32) RayCollision {
    return cast.as(RayCollision, c.GetRayCollisionSphere(
        cast.as(c.Ray, ray),
        cast.as(c.Vector3, center),
        radius,
    ));
}

/// Get collision info between ray and box
///
/// raylib computes a hit point and a normal even for a ray that misses — it
/// divides by each direction component to do it — so a ray with a zero
/// component that misses reaches raylib's own `(int)` cast of a NaN, which a
/// debug build (the default) traps. On a miss, only `hit` is meaningful.
pub fn getRayCollisionBox(ray: Ray, box: BoundingBox) RayCollision {
    return cast.as(RayCollision, c.GetRayCollisionBox(cast.as(c.Ray, ray), cast.as(c.BoundingBox, box)));
}

/// Get collision info between ray and mesh
///
/// raylib casts its ray against the mesh's CPU vertex data, transformed by
/// `transform`; a mesh that has none is never hit.
pub fn getRayCollisionMesh(ray: Ray, mesh: Mesh, transform: Matrix) RayCollision {
    return cast.as(RayCollision, c.GetRayCollisionMesh(
        cast.as(c.Ray, ray),
        cast.as(c.Mesh, mesh),
        cast.as(c.Matrix, transform),
    ));
}

/// Get collision info between ray and triangle
pub fn getRayCollisionTriangle(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3) RayCollision {
    return cast.as(RayCollision, c.GetRayCollisionTriangle(
        cast.as(c.Ray, ray),
        cast.as(c.Vector3, p1),
        cast.as(c.Vector3, p2),
        cast.as(c.Vector3, p3),
    ));
}

/// Get collision info between ray and quad
pub fn getRayCollisionQuad(ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3) RayCollision {
    return cast.as(RayCollision, c.GetRayCollisionQuad(
        cast.as(c.Ray, ray),
        cast.as(c.Vector3, p1),
        cast.as(c.Vector3, p2),
        cast.as(c.Vector3, p3),
        cast.as(c.Vector3, p4),
    ));
}

/// The private helpers and the tests' conveniences: nothing here is part of the
/// package.
const internal = struct {
    const std = @import("std");

    /// A `Vector3` spelled out, for the tests.
    fn v3(x: f32, y: f32, z: f32) Vector3 {
        return .{ .x = x, .y = y, .z = z };
    }

    /// A `Ray` looking straight down +Z from the origin, for the tests.
    const forward = Ray{ .position = .{ .x = 0, .y = 0, .z = 0 }, .direction = .{ .x = 0, .y = 0, .z = 1 } };

    /// The identity `Matrix`, for the tests.
    fn identity() Matrix {
        var transform = std.mem.zeroes(Matrix);
        transform.m0 = 1;
        transform.m5 = 1;
        transform.m10 = 1;
        transform.m15 = 1;
        return transform;
    }

    /// Turns raylib's trace log off for a test that makes raylib log a failed
    /// load or an unload: raylib writes those to the test binary's own stdout,
    /// and a passing run writes nothing at all.
    fn silenceLog() void {
        c.SetTraceLogLevel(c.LOG_NONE);
    }

    /// raylib's own default trace log level, back after `silenceLog`.
    fn unsilenceLog() void {
        c.SetTraceLogLevel(c.LOG_INFO);
    }
};

test "collisions: two spheres against known answers" {
    const std = internal.std;
    const origin = internal.v3(0, 0, 0);
    const radius = 1.0;

    // Two unit spheres whose centres are 2 apart touch exactly.
    try std.testing.expect(checkCollisionSpheres(origin, radius, internal.v3(2, 0, 0), radius));
    try std.testing.expect(!checkCollisionSpheres(origin, radius, internal.v3(2.001, 0, 0), radius));
    // A sphere at the same point as the other always collides.
    try std.testing.expect(checkCollisionSpheres(origin, radius, origin, 0.5));
    // Radius 0 spheres only touch when their centres coincide.
    try std.testing.expect(checkCollisionSpheres(origin, 0, origin, 0));
    try std.testing.expect(!checkCollisionSpheres(origin, 0, internal.v3(1, 0, 0), 0));
}

test "collisions: two boxes against known answers" {
    const std = internal.std;
    const unit = BoundingBox{ .min = internal.v3(0, 0, 0), .max = internal.v3(1, 1, 1) };

    // Overlapping by half.
    const overlapping = BoundingBox{ .min = internal.v3(0.5, 0.5, 0.5), .max = internal.v3(1.5, 1.5, 1.5) };
    try std.testing.expect(checkCollisionBoxes(unit, overlapping));
    // Sharing only the x = 1 plane: raylib compares with >= and <=, so it collides.
    const touching = BoundingBox{ .min = internal.v3(1, 0, 0), .max = internal.v3(2, 1, 1) };
    try std.testing.expect(checkCollisionBoxes(unit, touching));
    try std.testing.expect(checkCollisionBoxes(touching, unit));
    // Overlapping in x, separated in y.
    const separated = BoundingBox{ .min = internal.v3(0.5, 1.5, 0), .max = internal.v3(1.5, 2.5, 1) };
    try std.testing.expect(!checkCollisionBoxes(unit, separated));
    // Same box, and a box entirely inside another.
    try std.testing.expect(checkCollisionBoxes(unit, unit));
    const inside = BoundingBox{ .min = internal.v3(0.25, 0.25, 0.25), .max = internal.v3(0.75, 0.75, 0.75) };
    try std.testing.expect(checkCollisionBoxes(unit, inside));
}

test "collisions: a box and a sphere against known answers" {
    const std = internal.std;
    const unit = BoundingBox{ .min = internal.v3(0, 0, 0), .max = internal.v3(1, 1, 1) };

    // The closest point of the box to (2, 0.5, 0.5) is (1, 0.5, 0.5), exactly 1 away.
    try std.testing.expect(checkCollisionBoxSphere(unit, internal.v3(2, 0.5, 0.5), 1.0));
    try std.testing.expect(!checkCollisionBoxSphere(unit, internal.v3(2.001, 0.5, 0.5), 1.0));
    // Centre inside the box: even a zero radius collides.
    try std.testing.expect(checkCollisionBoxSphere(unit, internal.v3(0.5, 0.5, 0.5), 0.0));
    // Corner distance: (1.5, 1.5, 1.5) is sqrt(0.75) ≈ 0.8660254 away from (1, 1, 1).
    try std.testing.expect(checkCollisionBoxSphere(unit, internal.v3(1.5, 1.5, 1.5), 0.8661));
    try std.testing.expect(!checkCollisionBoxSphere(unit, internal.v3(1.5, 1.5, 1.5), 0.866));
}

test "collisions: a ray against spheres" {
    const std = internal.std;

    // From (0, 0, 0) down +Z: the unit sphere at z = 5 is hit at z = 4, facing the ray.
    const hit = getRayCollisionSphere(internal.forward, internal.v3(0, 0, 5), 1.0);
    try std.testing.expect(hit.hit);
    try std.testing.expectEqual(@as(f32, 4.0), hit.distance);
    try std.testing.expectEqual(internal.v3(0, 0, 4), hit.point);
    try std.testing.expectEqual(internal.v3(0, 0, -1), hit.normal);

    // The ray origin inside the sphere: raylib reports the exit point, with the
    // normal pointing back at the origin.
    const exit = getRayCollisionSphere(internal.forward, internal.v3(0, 0, 0.5), 1.0);
    try std.testing.expect(exit.hit);
    try std.testing.expectEqual(@as(f32, 1.5), exit.distance);
    try std.testing.expectEqual(internal.v3(0, 0, 1.5), exit.point);
    try std.testing.expectEqual(internal.v3(0, 0, -1), exit.normal);

    // Off to the side: no hit.
    try std.testing.expect(!getRayCollisionSphere(internal.forward, internal.v3(2, 0, 5), 1.0).hit);
}

test "collisions: a ray against boxes" {
    const std = internal.std;
    const box = BoundingBox{ .min = internal.v3(-1, -1, 4), .max = internal.v3(1, 1, 6) };

    // Straight through the near face.
    const hit = getRayCollisionBox(internal.forward, box);
    try std.testing.expect(hit.hit);
    try std.testing.expectEqual(@as(f32, 4.0), hit.distance);
    try std.testing.expectEqual(internal.v3(0, 0, 4), hit.point);
    try std.testing.expectEqual(internal.v3(0, 0, -1), hit.normal);

    // Pointing past the box, and pointing away from it. raylib divides by each
    // direction component, so both have three non-zero ones: a zero would be an
    // infinity, and the debug build's float-cast check rejects the NaN normal
    // raylib computes from it on a miss.
    const past = Ray{ .position = .{ .x = 5, .y = 0, .z = 0 }, .direction = .{ .x = 1, .y = 0.5, .z = 1 } };
    try std.testing.expect(!getRayCollisionBox(past, box).hit);
    const away = Ray{ .position = .{ .x = 0, .y = 0, .z = 0 }, .direction = .{ .x = 1, .y = 1, .z = 1 } };
    try std.testing.expect(!getRayCollisionBox(away, box).hit);
}

test "collisions: a ray against a triangle and a quad" {
    const std = internal.std;
    const ray = internal.forward;

    // A triangle at z = 5 with (0, 0) inside it: the ray hits its middle.
    const p1 = internal.v3(-1, -1, 5);
    const p2 = internal.v3(1, -1, 5);
    const p3 = internal.v3(0, 1, 5);
    const hit = getRayCollisionTriangle(ray, p1, p2, p3);
    try std.testing.expect(hit.hit);
    try std.testing.expectEqual(@as(f32, 5.0), hit.distance);
    try std.testing.expectEqual(internal.v3(0, 0, 5), hit.point);
    try std.testing.expectEqual(internal.v3(0, 0, 1), hit.normal);

    // The same triangle behind the ray: the intersection is at t < 0, so no hit.
    const behind = Ray{ .position = .{ .x = 0, .y = 0, .z = 0 }, .direction = .{ .x = 0, .y = 0, .z = -1 } };
    const missed = getRayCollisionTriangle(behind, p1, p2, p3);
    try std.testing.expect(!missed.hit);
    try std.testing.expectEqual(@as(f32, 0.0), missed.distance);

    // A square with corners at z = 5, given to raylib as two triangles:
    // (p1, p2, p4) and (p2, p3, p4). (0.6, 0.2) is in the second one only, so
    // the quad's first test misses and its second hits.
    const p4 = internal.v3(-1, 1, 5);
    const aimed = Ray{ .position = .{ .x = 0.6, .y = 0.2, .z = 0 }, .direction = .{ .x = 0, .y = 0, .z = 1 } };
    const quad_hit = getRayCollisionQuad(aimed, p1, p2, internal.v3(1, 1, 5), p4);
    try std.testing.expect(quad_hit.hit);
    try std.testing.expectEqual(@as(f32, 5.0), quad_hit.distance);
    try std.testing.expectEqual(internal.v3(0.6, 0.2, 5), quad_hit.point);
    try std.testing.expectEqual(internal.v3(0, 0, 1), quad_hit.normal);

    // Outside the square entirely.
    const outside = Ray{ .position = .{ .x = 0, .y = 2, .z = 0 }, .direction = .{ .x = 0, .y = 0, .z = 1 } };
    try std.testing.expect(!getRayCollisionQuad(outside, p1, p2, internal.v3(1, 1, 5), p4).hit);
}

test "collisions: a ray against a mesh's CPU vertex data" {
    const std = internal.std;
    var vertices = [_]Vector3{
        internal.v3(-1, -1, 5),
        internal.v3(1, -1, 5),
        internal.v3(0, 1, 5),
    };
    var mesh = std.mem.zeroes(Mesh);
    mesh.vertexCount = vertices.len;
    mesh.triangleCount = 1;
    mesh.vertices = @ptrCast(&vertices);

    const hit = getRayCollisionMesh(internal.forward, mesh, internal.identity());
    try std.testing.expect(hit.hit);
    try std.testing.expectEqual(@as(f32, 5.0), hit.distance);
    try std.testing.expectEqual(internal.v3(0, 0, 5), hit.point);
    try std.testing.expectEqual(internal.v3(0, 0, 1), hit.normal);

    // A mesh with no CPU vertex data is never hit, whatever the transform.
    try std.testing.expect(!getRayCollisionMesh(internal.forward, std.mem.zeroes(Mesh), internal.identity()).hit);
}

test "isModelValid on a zeroed model, and loadModelFromMesh's success path" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.unsilenceLog();
    try std.testing.expect(!isModelValid(std.mem.zeroes(Model)));

    // raylib accepts an empty mesh: it only checks the model's own pointers and,
    // for each mesh, the VBOs of the vertex data that is there.
    const model = try loadModelFromMesh(std.mem.zeroes(Mesh));
    defer unloadModel(model);
    try std.testing.expect(isModelValid(model));
    try std.testing.expectEqual(@as(i32, 1), model.meshCount);
    try std.testing.expectEqual(@as(i32, 1), model.materialCount);
    try std.testing.expectEqual(@as(i32, 0), model.meshMaterial.?[0]);
}

test "loadModel reports raylib's IsModelValid as error.LoadFailed" {
    const std = internal.std;
    internal.silenceLog();
    defer internal.unsilenceLog();
    // A file that is not there, and a file type raylib has no loader for.
    try std.testing.expectError(error.LoadFailed, loadModel("raylibz-no-such-file.obj"));
    try std.testing.expectError(error.LoadFailed, loadModel("raylibz-no-such-file.xyz"));
}

test "loadMaterials turns raylib's array and count into a slice" {
    const std = internal.std;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const mtl = "newmtl raylibz_test\nKd 0.5 0.25 1.0\n";
    try tmp.dir.writeFile(std.testing.io, .{ .sub_path = "raylibz_test.mtl", .data = mtl });
    const path = try std.fs.path.join(std.testing.allocator, &.{
        ".zig-cache", "tmp", &tmp.sub_path, "raylibz_test.mtl",
    });
    defer std.testing.allocator.free(path);
    const path_z = try std.testing.allocator.dupeSentinel(u8, path, 0);
    defer std.testing.allocator.free(path_z);

    const materials = loadMaterials(path_z) orelse return error.TestUnexpectedResult;
    defer c.MemFree(@ptrCast(materials.ptr));
    defer for (materials) |material| unloadMaterial(material);

    try std.testing.expectEqual(@as(usize, 1), materials.len);
    const maps = materials[0].maps orelse return error.TestUnexpectedResult;
    // ProcessMaterialsOBJ copies Kd, scaled by 255 and truncated.
    const diffuse = maps[@intCast(c.MATERIAL_MAP_DIFFUSE)];
    try std.testing.expectEqual(@as(u8, 127), diffuse.color.r);
    try std.testing.expectEqual(@as(u8, 63), diffuse.color.g);
    try std.testing.expectEqual(@as(u8, 255), diffuse.color.b);
    try std.testing.expectEqual(@as(u8, 255), diffuse.color.a);

    // A file type raylib has no material loader for: raylib returns NULL.
    try std.testing.expect(loadMaterials("raylibz-no-such-file.xyz") == null);
}

test "loadModelAnimations returns null where raylib loaded none" {
    const std = internal.std;
    try std.testing.expect(loadModelAnimations("raylibz-no-such-file.xyz") == null);
}
