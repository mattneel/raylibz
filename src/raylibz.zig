//! raylibz: the Zig++-sanctioned wrapper for [raylib](https://github.com/raysan5/raylib).
//!
//! raylibz is a thin, 1:1 Zig face on raylib's *own* translated headers. It
//! wraps none of raylib's declarations itself: raylib's build script translates
//! `raylib.h`, `rcamera.h`, `raymath.h` and `rlgl.h` and publishes them as
//! modules, raylibz imports those, and everything below is either a flat
//! re-export of them, a wrapper that spells raylib's C types the Zig way, or a
//! name listed in `not_wrapped`.
//!
//! # The raw layer
//!
//! `raylibz.c` is raylib's translated `raylib` module, exactly as raylib built
//! it, and `raylibz.raymath` and `raylibz.rlgl` are its `raymath` and `rlgl`
//! modules. Nothing is hidden: a program can always drop to raylib's own
//! declarations. rlgl is not wrapped; it is re-exported raw, for the programs
//! that need it.
//!
//! # The shape of the wrapper
//!
//! * Names: raylib's, with the first letter lowercased (`InitWindow` →
//!   `initWindow`). Types and struct fields keep raylib's names.
//! * Mirrors: every raylib struct is an `extern struct` with raylib's fields in
//!   raylib's order, asserted field for field against the translated type at
//!   compile time, so a drift in raylib's header is a build error.
//! * Text: `const char *` in is `[:0]const u8`; text out is `[:0]const u8`, or
//!   `?[:0]u8` where the caller must release it.
//! * Buffers: a pointer-and-count pair is a slice, in and out.
//! * Loading: a `Load*` that raylib pairs with an `Is*Valid` check returns
//!   `error{LoadFailed}!T`, having made that check.
//! * Enums: raylib's 21 C enums as Zig enums with raylib's values; `ConfigFlags`
//!   and `Gesture` as `packed struct`s of bools, one bit each.
//! * Colours: raylib's 26 colour macros as decls on `Color`.
//!
//! Every wrapper in a module file (`core.zig`, `text.zig`, ...) is re-exported
//! here flatly, and the test at the bottom of this file fails if a module file
//! declares something the root does not publish.

const std = @import("std");

/// raylib's translated `raylib.h`, raw and complete.
pub const c = @import("raylib");
/// raylib's translated `raymath.h`, raw and complete.
pub const raymath = @import("raymath");
/// raylib's translated `rlgl.h`, raw. raylibz does not wrap rlgl.
pub const rlgl = @import("rlgl");

/// The helpers that cross the boundary, and `cast.NotWrapped`.
pub const cast = @import("cast.zig");
/// raylib's 21 enums, and `ConfigFlags` and `Gesture` as flag sets.
pub const enums = @import("enums.zig");
/// Every mirrored struct except the vectors and the matrix.
pub const types = @import("types.zig");
/// `Vector2` and its raymath methods.
pub const vector2 = @import("vector2.zig");
/// `Vector3` and its raymath methods.
pub const vector3 = @import("vector3.zig");
/// `Vector4` (and therefore `Quaternion`) and its raymath methods.
pub const vector4 = @import("vector4.zig");
/// `Matrix` and raymath's `Matrix*` functions as methods.
pub const matrix = @import("matrix.zig");

/// raylib's core module, up to its file system functions.
pub const core = @import("core.zig");
/// raylib's core module from its file system functions on: files, compression, automation events.
pub const files = @import("files.zig");
/// raylib's input handling, with `rgestures` and `rcamera`.
pub const input = @import("input.zig");
/// raylib's shapes module.
pub const shapes = @import("shapes.zig");
/// raylib's textures module.
pub const textures = @import("textures.zig");
/// raylib's text module.
pub const text = @import("text.zig");
/// raylib's models module.
pub const models = @import("models.zig");
/// raylib's audio module.
pub const audio = @import("audio.zig");
/// raymath's free functions.
pub const math = @import("math.zig");

/// Every function raylibz does not wrap, and why.
pub const not_wrapped = @import("not_wrapped.zig");

// The vectors and the matrix, from the files that carry their methods.

/// Vector2, 2 components.
pub const Vector2 = vector2.Vector2;
/// Vector3, 3 components.
pub const Vector3 = vector3.Vector3;
/// Vector4, 4 components.
pub const Vector4 = vector4.Vector4;
/// Quaternion, raylib's `typedef Vector4 Quaternion`.
pub const Quaternion = vector4.Quaternion;
/// Matrix, 4x4 components, column major, OpenGL style, right-handed.
pub const Matrix = matrix.Matrix;

// Every other mirrored struct.

/// Color, 4 components, R8G8B8A8 (32bit), with raylib's colours as decls.
pub const Color = types.Color;
/// Rectangle, 4 components.
pub const Rectangle = types.Rectangle;
/// Image, pixel data stored in CPU memory (RAM).
pub const Image = types.Image;
/// Texture, tex data stored in GPU memory (VRAM).
pub const Texture = types.Texture;
/// Texture2D, same as `Texture`.
pub const Texture2D = types.Texture2D;
/// TextureCubemap, same as `Texture`.
pub const TextureCubemap = types.TextureCubemap;
/// RenderTexture, fbo for texture rendering.
pub const RenderTexture = types.RenderTexture;
/// RenderTexture2D, same as `RenderTexture`.
pub const RenderTexture2D = types.RenderTexture2D;
/// NPatchInfo, n-patch layout info.
pub const NPatchInfo = types.NPatchInfo;
/// GlyphInfo, font characters glyphs info.
pub const GlyphInfo = types.GlyphInfo;
/// Font, font texture and GlyphInfo array data.
pub const Font = types.Font;
/// Camera3D, defines position/orientation in 3d space.
pub const Camera3D = types.Camera3D;
/// Camera, raylib's fallback typedef for `Camera3D`.
pub const Camera = types.Camera;
/// Camera2D, defines position/orientation in 2d space.
pub const Camera2D = types.Camera2D;
/// Mesh, vertex data and vao/vbo.
pub const Mesh = types.Mesh;
/// Shader.
pub const Shader = types.Shader;
/// MaterialMap.
pub const MaterialMap = types.MaterialMap;
/// Material, includes shader and maps.
pub const Material = types.Material;
/// Transform, vertex transformation data.
pub const Transform = types.Transform;
/// BoneInfo, skeletal animation bone.
pub const BoneInfo = types.BoneInfo;
/// ModelSkeleton, animation bones hierarchy.
pub const ModelSkeleton = types.ModelSkeleton;
/// Model, meshes, materials and animation data.
pub const Model = types.Model;
/// ModelAnimation, contains a full animation sequence.
pub const ModelAnimation = types.ModelAnimation;
/// ModelAnimPose, raylib's `typedef Transform *ModelAnimPose`.
pub const ModelAnimPose = types.ModelAnimPose;
/// Ray, ray for raycasting.
pub const Ray = types.Ray;
/// RayCollision, ray hit information.
pub const RayCollision = types.RayCollision;
/// BoundingBox.
pub const BoundingBox = types.BoundingBox;
/// Wave, audio wave data.
pub const Wave = types.Wave;
/// AudioStream, custom audio stream.
pub const AudioStream = types.AudioStream;
/// Sound.
pub const Sound = types.Sound;
/// Music, audio stream, anything longer than ~10 seconds should be streamed.
pub const Music = types.Music;
/// VrDeviceInfo, Head-Mounted-Display device parameters.
pub const VrDeviceInfo = types.VrDeviceInfo;
/// VrStereoConfig, VR stereo rendering configuration for simulator.
pub const VrStereoConfig = types.VrStereoConfig;
/// FilePathList.
pub const FilePathList = types.FilePathList;
/// AutomationEvent.
pub const AutomationEvent = types.AutomationEvent;
/// AutomationEventList.
pub const AutomationEventList = types.AutomationEventList;

// raylib's enums, and its two flag sets.

/// System/Window config flags, a bit each.
pub const ConfigFlags = enums.ConfigFlags;
/// Trace log level.
pub const TraceLogLevel = enums.TraceLogLevel;
/// Keyboard keys (US keyboard layout).
pub const KeyboardKey = enums.KeyboardKey;
/// Mouse buttons.
pub const MouseButton = enums.MouseButton;
/// Mouse cursor.
pub const MouseCursor = enums.MouseCursor;
/// Gamepad buttons.
pub const GamepadButton = enums.GamepadButton;
/// Gamepad axes.
pub const GamepadAxis = enums.GamepadAxis;
/// Material map index.
pub const MaterialMapIndex = enums.MaterialMapIndex;
/// Shader location index.
pub const ShaderLocationIndex = enums.ShaderLocationIndex;
/// Shader uniform data type.
pub const ShaderUniformDataType = enums.ShaderUniformDataType;
/// Shader attribute data types.
pub const ShaderAttributeDataType = enums.ShaderAttributeDataType;
/// Pixel formats.
pub const PixelFormat = enums.PixelFormat;
/// Texture parameters: filter mode.
pub const TextureFilter = enums.TextureFilter;
/// Texture parameters: wrap mode.
pub const TextureWrap = enums.TextureWrap;
/// Cubemap layouts.
pub const CubemapLayout = enums.CubemapLayout;
/// Font type, defines generation method.
pub const FontType = enums.FontType;
/// Color blending modes (pre-defined).
pub const BlendMode = enums.BlendMode;
/// Gestures, a bit each.
pub const Gesture = enums.Gesture;
/// Camera system modes.
pub const CameraMode = enums.CameraMode;
/// Camera projection.
pub const CameraProjection = enums.CameraProjection;
/// N-patch layout.
pub const NPatchLayout = enums.NPatchLayout;

// raylib's core module.

/// Initialize window and OpenGL context.
pub const initWindow = core.initWindow;
/// Close window and unload OpenGL context.
pub const closeWindow = core.closeWindow;
/// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked).
pub const windowShouldClose = core.windowShouldClose;
/// Set target FPS (maximum).
pub const setTargetFPS = core.setTargetFPS;
/// Setup drawing canvas to start drawing.
pub const beginDrawing = core.beginDrawing;
/// End canvas drawing and swap buffers (double buffering).
pub const endDrawing = core.endDrawing;
/// Set background color (framebuffer clear color).
pub const clearBackground = core.clearBackground;

// raylib's core module: files, compression, automation events.

// raylib's input handling, gestures and camera.

// raylib's shapes module.

// raylib's textures module.

// raylib's text module.

/// Draw text (using default font).
pub const drawText = text.drawText;

// raylib's models module.

/// Draw a line in 3D world space
pub const drawLine3D = models.drawLine3D;
/// Draw a point in 3D space, actually a small line
pub const drawPoint3D = models.drawPoint3D;
/// Draw a circle in 3D world space
pub const drawCircle3D = models.drawCircle3D;
/// Draw a color-filled triangle, counter-clockwise vertex order
pub const drawTriangle3D = models.drawTriangle3D;
/// Draw a triangle strip defined by points
pub const drawTriangleStrip3D = models.drawTriangleStrip3D;
/// Draw cube
pub const drawCube = models.drawCube;
/// Draw cube (Vector version)
pub const drawCubeV = models.drawCubeV;
/// Draw cube wires
pub const drawCubeWires = models.drawCubeWires;
/// Draw cube wires (Vector version)
pub const drawCubeWiresV = models.drawCubeWiresV;
/// Draw sphere
pub const drawSphere = models.drawSphere;
/// Draw sphere with defined rings and slices
pub const drawSphereEx = models.drawSphereEx;
/// Draw sphere wires
pub const drawSphereWires = models.drawSphereWires;
/// Draw a cylinder/cone
pub const drawCylinder = models.drawCylinder;
/// Draw a cylinder with base at startPos and top at endPos
pub const drawCylinderEx = models.drawCylinderEx;
/// Draw a cylinder/cone wires
pub const drawCylinderWires = models.drawCylinderWires;
/// Draw a cylinder wires with base at startPos and top at endPos
pub const drawCylinderWiresEx = models.drawCylinderWiresEx;
/// Draw a capsule with the center of its sphere caps at startPos and endPos
pub const drawCapsule = models.drawCapsule;
/// Draw capsule wireframe with the center of its sphere caps at startPos and endPos
pub const drawCapsuleWires = models.drawCapsuleWires;
/// Draw a plane XZ
pub const drawPlane = models.drawPlane;
/// Draw a ray line
pub const drawRay = models.drawRay;
/// Draw a grid (centered at (0, 0, 0))
pub const drawGrid = models.drawGrid;
/// Load model from files (meshes and materials)
pub const loadModel = models.loadModel;
/// Load model from generated mesh (default material)
pub const loadModelFromMesh = models.loadModelFromMesh;
/// Check if model is valid (loaded in GPU, VAO/VBOs)
pub const isModelValid = models.isModelValid;
/// Unload model (including meshes) from memory (RAM and/or VRAM)
pub const unloadModel = models.unloadModel;
/// Compute model bounding box limits (considers all meshes)
pub const getModelBoundingBox = models.getModelBoundingBox;
/// Draw a model (with texture if set)
pub const drawModel = models.drawModel;
/// Draw a model with custom transform
pub const drawModelEx = models.drawModelEx;
/// Draw a model wires (with texture if set)
pub const drawModelWires = models.drawModelWires;
/// Draw a model wires with custom transform
pub const drawModelWiresEx = models.drawModelWiresEx;
/// Draw bounding box (wires)
pub const drawBoundingBox = models.drawBoundingBox;
/// Draw a billboard texture
pub const drawBillboard = models.drawBillboard;
/// Draw a billboard texture defined by rectangle
pub const drawBillboardRec = models.drawBillboardRec;
/// Draw a billboard texture defined by source rectangle with scaling and rotation
pub const drawBillboardPro = models.drawBillboardPro;
/// Upload mesh vertex data in GPU and provide VAO/VBO ids
pub const uploadMesh = models.uploadMesh;
/// Update mesh vertex data in GPU for a specific buffer index
pub const updateMeshBuffer = models.updateMeshBuffer;
/// Unload mesh data from CPU and GPU
pub const unloadMesh = models.unloadMesh;
/// Draw a 3d mesh with material and transform
pub const drawMesh = models.drawMesh;
/// Draw multiple mesh instances with material and different transforms
pub const drawMeshInstanced = models.drawMeshInstanced;
/// Compute mesh bounding box limits
pub const getMeshBoundingBox = models.getMeshBoundingBox;
/// Compute mesh tangents
pub const genMeshTangents = models.genMeshTangents;
/// Export mesh data to file, returns true on success
pub const exportMesh = models.exportMesh;
/// Export mesh as code file (.h) defining multiple arrays of vertex attributes
pub const exportMeshAsCode = models.exportMeshAsCode;
/// Generate polygonal mesh
pub const genMeshPoly = models.genMeshPoly;
/// Generate plane mesh (with subdivisions)
pub const genMeshPlane = models.genMeshPlane;
/// Generate cuboid mesh
pub const genMeshCube = models.genMeshCube;
/// Generate sphere mesh (standard sphere)
pub const genMeshSphere = models.genMeshSphere;
/// Generate half-sphere mesh (no bottom cap)
pub const genMeshHemiSphere = models.genMeshHemiSphere;
/// Generate cylinder mesh
pub const genMeshCylinder = models.genMeshCylinder;
/// Generate cone/pyramid mesh
pub const genMeshCone = models.genMeshCone;
/// Generate torus mesh
pub const genMeshTorus = models.genMeshTorus;
/// Generate trefoil knot mesh
pub const genMeshKnot = models.genMeshKnot;
/// Generate heightmap mesh from image data
pub const genMeshHeightmap = models.genMeshHeightmap;
/// Generate cubes-based map mesh from image data
pub const genMeshCubicmap = models.genMeshCubicmap;
/// Load materials from model file
pub const loadMaterials = models.loadMaterials;
/// Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
pub const loadMaterialDefault = models.loadMaterialDefault;
/// Check if material is valid (shader assigned, map textures loaded in GPU)
pub const isMaterialValid = models.isMaterialValid;
/// Unload material from GPU memory (VRAM)
pub const unloadMaterial = models.unloadMaterial;
/// Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
pub const setMaterialTexture = models.setMaterialTexture;
/// Set material for a mesh
pub const setModelMeshMaterial = models.setModelMeshMaterial;
/// Load model animations from file
pub const loadModelAnimations = models.loadModelAnimations;
/// Update model animation pose (vertex buffers and bone matrices)
pub const updateModelAnimation = models.updateModelAnimation;
/// Update model animation pose, blending two animations
pub const updateModelAnimationEx = models.updateModelAnimationEx;
/// Unload animation array data
pub const unloadModelAnimations = models.unloadModelAnimations;
/// Check model animation skeleton match
pub const isModelAnimationValid = models.isModelAnimationValid;
/// Check collision between two spheres
pub const checkCollisionSpheres = models.checkCollisionSpheres;
/// Check collision between two bounding boxes
pub const checkCollisionBoxes = models.checkCollisionBoxes;
/// Check collision between box and sphere
pub const checkCollisionBoxSphere = models.checkCollisionBoxSphere;
/// Get collision info between ray and sphere
pub const getRayCollisionSphere = models.getRayCollisionSphere;
/// Get collision info between ray and box
pub const getRayCollisionBox = models.getRayCollisionBox;
/// Get collision info between ray and mesh
pub const getRayCollisionMesh = models.getRayCollisionMesh;
/// Get collision info between ray and triangle
pub const getRayCollisionTriangle = models.getRayCollisionTriangle;
/// Get collision info between ray and quad
pub const getRayCollisionQuad = models.getRayCollisionQuad;

// raylib's audio module.

// raymath's free functions.

// Everything `zig build test` runs here: this file's re-export test, and the
// unit tests of every file the package publishes.
test {
    std.testing.refAllDecls(@This());
}

/// The module files whose declarations the root publishes flatly.
const module_files = .{ core, files, input, shapes, textures, text, models, audio, math };

test "every declaration of every module file is re-exported by the root" {
    // `not_wrapped` cannot be flat: every module file has one, and the root
    // publishes them together as `raylibz.not_wrapped`. `internal` is each module
    // file's namespace of private helpers, which nothing re-exports.
    const missing = comptime blk: {
        var missing_names: []const []const u8 = &.{};
        for (module_files) |module_file| {
            for (@typeInfo(module_file).@"struct".decl_names) |name| {
                if (std.mem.eql(u8, name, "not_wrapped") or std.mem.eql(u8, name, "internal")) continue;
                if (!@hasDecl(@This(), name)) missing_names = missing_names ++ .{name};
            }
        }
        break :blk missing_names;
    };

    try std.testing.expectEqualSlices([]const u8, &.{}, missing);
}
