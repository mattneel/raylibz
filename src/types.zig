//! Every raylib struct raylibz mirrors, except `Vector2`, `Vector3`, `Vector4`
//! (and `Quaternion`) and `Matrix`, which live in their own files because
//! raymath's methods belong beside them.
//!
//! Each mirror is an `extern struct` with raylib's fields, raylib's field names
//! and raylib's layout, asserted field for field against the translated type by
//! `cast.assertLayout` in its body: a drift in raylib's header is a compile
//! error here, not a surprise at runtime. Fields carry no default values; Zig
//! makes you say what every field is, and `undefined` where raylib will fill it.
//!
//! raylib's `typedef` aliases are Zig aliases, in this file or the vector files:
//! `Texture2D`, `TextureCubemap`, `RenderTexture2D`, `Camera`, `Quaternion`,
//! `ModelAnimPose`.

const std = @import("std");
const c = @import("raylib");
const cast = @import("cast.zig");
const enums = @import("enums.zig");
const vector2 = @import("vector2.zig");
const vector3 = @import("vector3.zig");
const vector4 = @import("vector4.zig");
const matrix = @import("matrix.zig");

const Vector2 = vector2.Vector2;
const Vector3 = vector3.Vector3;
const Quaternion = vector4.Quaternion;
const Matrix = matrix.Matrix;
const PixelFormat = enums.PixelFormat;
const CameraProjection = enums.CameraProjection;
const NPatchLayout = enums.NPatchLayout;

/// Color, 4 components, R8G8B8A8 (32bit)
///
/// raylib.h's `Color`. raylib's 26 colour macros are decls on this type,
/// lower-cased (`Color.lightgray`, `Color.raywhite`, `Color.blank`), each one
/// asserted below against raylib's translated macro of the same name.
pub const Color = extern struct {
    /// Color red value
    r: u8,
    /// Color green value
    g: u8,
    /// Color blue value
    b: u8,
    /// Color alpha value
    a: u8,

    /// Light Gray
    pub const lightgray: Color = .{ .r = 200, .g = 200, .b = 200, .a = 255 };
    /// Gray
    pub const gray: Color = .{ .r = 130, .g = 130, .b = 130, .a = 255 };
    /// Dark Gray
    pub const darkgray: Color = .{ .r = 80, .g = 80, .b = 80, .a = 255 };
    /// Yellow
    pub const yellow: Color = .{ .r = 253, .g = 249, .b = 0, .a = 255 };
    /// Gold
    pub const gold: Color = .{ .r = 255, .g = 203, .b = 0, .a = 255 };
    /// Orange
    pub const orange: Color = .{ .r = 255, .g = 161, .b = 0, .a = 255 };
    /// Pink
    pub const pink: Color = .{ .r = 255, .g = 109, .b = 194, .a = 255 };
    /// Red
    pub const red: Color = .{ .r = 230, .g = 41, .b = 55, .a = 255 };
    /// Maroon
    pub const maroon: Color = .{ .r = 190, .g = 33, .b = 55, .a = 255 };
    /// Green
    pub const green: Color = .{ .r = 0, .g = 228, .b = 48, .a = 255 };
    /// Lime
    pub const lime: Color = .{ .r = 0, .g = 158, .b = 47, .a = 255 };
    /// Dark Green
    pub const darkgreen: Color = .{ .r = 0, .g = 117, .b = 44, .a = 255 };
    /// Sky Blue
    pub const skyblue: Color = .{ .r = 102, .g = 191, .b = 255, .a = 255 };
    /// Blue
    pub const blue: Color = .{ .r = 0, .g = 121, .b = 241, .a = 255 };
    /// Dark Blue
    pub const darkblue: Color = .{ .r = 0, .g = 82, .b = 172, .a = 255 };
    /// Purple
    pub const purple: Color = .{ .r = 200, .g = 122, .b = 255, .a = 255 };
    /// Violet
    pub const violet: Color = .{ .r = 135, .g = 60, .b = 190, .a = 255 };
    /// Dark Purple
    pub const darkpurple: Color = .{ .r = 112, .g = 31, .b = 126, .a = 255 };
    /// Beige
    pub const beige: Color = .{ .r = 211, .g = 176, .b = 131, .a = 255 };
    /// Brown
    pub const brown: Color = .{ .r = 127, .g = 106, .b = 79, .a = 255 };
    /// Dark Brown
    pub const darkbrown: Color = .{ .r = 76, .g = 63, .b = 47, .a = 255 };
    /// White
    pub const white: Color = .{ .r = 255, .g = 255, .b = 255, .a = 255 };
    /// Black
    pub const black: Color = .{ .r = 0, .g = 0, .b = 0, .a = 255 };
    /// Blank (Transparent)
    pub const blank: Color = .{ .r = 0, .g = 0, .b = 0, .a = 0 };
    /// Magenta
    pub const magenta: Color = .{ .r = 255, .g = 0, .b = 255, .a = 255 };
    /// My own White (raylib logo)
    pub const raywhite: Color = .{ .r = 245, .g = 245, .b = 245, .a = 255 };

    comptime {
        cast.assertLayout(@This(), c.Color);
        assertColor(lightgray, c.LIGHTGRAY);
        assertColor(gray, c.GRAY);
        assertColor(darkgray, c.DARKGRAY);
        assertColor(yellow, c.YELLOW);
        assertColor(gold, c.GOLD);
        assertColor(orange, c.ORANGE);
        assertColor(pink, c.PINK);
        assertColor(red, c.RED);
        assertColor(maroon, c.MAROON);
        assertColor(green, c.GREEN);
        assertColor(lime, c.LIME);
        assertColor(darkgreen, c.DARKGREEN);
        assertColor(skyblue, c.SKYBLUE);
        assertColor(blue, c.BLUE);
        assertColor(darkblue, c.DARKBLUE);
        assertColor(purple, c.PURPLE);
        assertColor(violet, c.VIOLET);
        assertColor(darkpurple, c.DARKPURPLE);
        assertColor(beige, c.BEIGE);
        assertColor(brown, c.BROWN);
        assertColor(darkbrown, c.DARKBROWN);
        assertColor(white, c.WHITE);
        assertColor(black, c.BLACK);
        assertColor(blank, c.BLANK);
        assertColor(magenta, c.MAGENTA);
        assertColor(raywhite, c.RAYWHITE);
    }
};

/// Asserts one of `Color`'s decls against raylib's translated macro of the
/// same name: `Color.lightgray` against `c.LIGHTGRAY`.
fn assertColor(comptime color: Color, comptime translated: anytype) void {
    if (color.r != translated.r or color.g != translated.g or
        color.b != translated.b or color.a != translated.a)
    {
        @compileError(std.fmt.comptimePrint(
            "Color decl {d},{d},{d},{d} does not match raylib's macro {d},{d},{d},{d}",
            .{ color.r, color.g, color.b, color.a, translated.r, translated.g, translated.b, translated.a },
        ));
    }
}

/// Rectangle, 4 components
///
/// raylib.h's `Rectangle`.
pub const Rectangle = extern struct {
    /// Rectangle top-left corner position x
    x: f32,
    /// Rectangle top-left corner position y
    y: f32,
    /// Rectangle width
    width: f32,
    /// Rectangle height
    height: f32,

    comptime {
        cast.assertLayout(@This(), c.Rectangle);
    }
};
/// Image, pixel data stored in CPU memory (RAM)
///
/// raylib.h's `Image`.
pub const Image = extern struct {
    /// Image raw data
    data: ?*anyopaque,
    /// Image base width
    width: i32,
    /// Image base height
    height: i32,
    /// Mipmap levels, 1 by default
    mipmaps: i32,
    /// Data format (PixelFormat type)
    format: PixelFormat,

    comptime {
        cast.assertLayout(@This(), c.Image);
    }
};
/// Texture, tex data stored in GPU memory (VRAM)
///
/// raylib.h's `Texture`.
/// Texture2D, same as `Texture`; TextureCubemap, same as `Texture`.
pub const Texture = extern struct {
    /// OpenGL texture id
    id: u32,
    /// Texture base width
    width: i32,
    /// Texture base height
    height: i32,
    /// Mipmap levels, 1 by default
    mipmaps: i32,
    /// Data format (PixelFormat type)
    format: PixelFormat,

    comptime {
        cast.assertLayout(@This(), c.Texture);
    }
};
/// RenderTexture, fbo for texture rendering
///
/// raylib.h's `RenderTexture`.
/// RenderTexture2D, same as `RenderTexture`.
pub const RenderTexture = extern struct {
    /// OpenGL framebuffer object id
    id: u32,
    /// Color buffer attachment texture
    texture: Texture,
    /// Depth buffer attachment texture
    depth: Texture,

    comptime {
        cast.assertLayout(@This(), c.RenderTexture);
    }
};
/// NPatchInfo, n-patch layout info
///
/// raylib.h's `NPatchInfo`.
pub const NPatchInfo = extern struct {
    /// Texture source rectangle
    source: Rectangle,
    /// Left border offset
    left: i32,
    /// Top border offset
    top: i32,
    /// Right border offset
    right: i32,
    /// Bottom border offset
    bottom: i32,
    /// Layout of the n-patch: 3x3, 1x3 or 3x1
    layout: NPatchLayout,

    comptime {
        cast.assertLayout(@This(), c.NPatchInfo);
    }
};
/// GlyphInfo, font characters glyphs info
///
/// raylib.h's `GlyphInfo`.
pub const GlyphInfo = extern struct {
    /// Character value (Unicode)
    value: i32,
    /// Character offset X when drawing
    offsetX: i32,
    /// Character offset Y when drawing
    offsetY: i32,
    /// Character advance position X
    advanceX: i32,
    /// Character image data
    image: Image,

    comptime {
        cast.assertLayout(@This(), c.GlyphInfo);
    }
};
/// Font, font texture and GlyphInfo array data
///
/// raylib.h's `Font`.
pub const Font = extern struct {
    /// Base size (default chars height)
    baseSize: i32,
    /// Number of glyph characters
    glyphCount: i32,
    /// Padding around the glyph characters
    glyphPadding: i32,
    /// Texture atlas containing the glyphs
    texture: Texture2D,
    /// Rectangles in texture for the glyphs
    recs: ?[*]Rectangle,
    /// Glyphs info data
    glyphs: ?[*]GlyphInfo,

    comptime {
        cast.assertLayout(@This(), c.Font);
    }
};
/// Camera, defines position/orientation in 3d space
///
/// raylib.h's `Camera3D`.
/// Camera, raylib's fallback typedef for `Camera3D`.
pub const Camera3D = extern struct {
    /// Camera position
    position: Vector3,
    /// Camera target it looks-at
    target: Vector3,
    /// Camera up vector (rotation over its axis)
    up: Vector3,
    /// Camera field-of-view aperture in Y (degrees) in perspective, used as near plane height in world units in orthographic
    fovy: f32,
    /// Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
    projection: CameraProjection,

    comptime {
        cast.assertLayout(@This(), c.Camera3D);
    }
};
/// Camera2D, defines position/orientation in 2d space
///
/// raylib.h's `Camera2D`.
pub const Camera2D = extern struct {
    /// Camera offset (screen space offset from window origin)
    offset: Vector2,
    /// Camera target (world space target point that is mapped to screen space offset)
    target: Vector2,
    /// Camera rotation in degrees (pivots around target)
    rotation: f32,
    /// Camera zoom (scaling around target), must not be set to 0, set to 1.0f for no scale
    zoom: f32,

    comptime {
        cast.assertLayout(@This(), c.Camera2D);
    }
};
/// Mesh, vertex data and vao/vbo
///
/// raylib.h's `Mesh`.
pub const Mesh = extern struct {
    /// Number of vertices stored in arrays
    vertexCount: i32,
    /// Number of triangles stored (indexed or not)
    triangleCount: i32,
    /// Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    vertices: ?[*]f32,
    /// Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords: ?[*]f32,
    /// Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
    texcoords2: ?[*]f32,
    /// Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    normals: ?[*]f32,
    /// Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    tangents: ?[*]f32,
    /// Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    colors: ?[*]u8,
    /// Vertex indices (in case vertex data comes indexed)
    indices: ?[*]u16,
    /// Number of bones (MAX: 256 bones)
    boneCount: i32,
    /// Vertex bone indices, up to 4 bones influence by vertex (skinning) (shader-location = 6)
    boneIndices: ?[*]u8,
    /// Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
    boneWeights: ?[*]f32,
    /// Animated vertex positions (after bones transformations)
    animVertices: ?[*]f32,
    /// Animated normals (after bones transformations)
    animNormals: ?[*]f32,
    /// OpenGL Vertex Array Object id
    vaoId: u32,
    /// OpenGL Vertex Buffer Objects id (default vertex data)
    vboId: ?[*]u32,

    comptime {
        cast.assertLayout(@This(), c.Mesh);
    }
};
/// Shader
///
/// raylib.h's `Shader`.
pub const Shader = extern struct {
    /// Shader program id
    id: u32,
    /// Shader locations array (RL_MAX_SHADER_LOCATIONS)
    locs: ?[*]i32,

    comptime {
        cast.assertLayout(@This(), c.Shader);
    }
};
/// MaterialMap
///
/// raylib.h's `MaterialMap`.
pub const MaterialMap = extern struct {
    /// Material map texture
    texture: Texture2D,
    /// Material map color
    color: Color,
    /// Material map value
    value: f32,

    comptime {
        cast.assertLayout(@This(), c.MaterialMap);
    }
};
/// Material, includes shader and maps
///
/// raylib.h's `Material`.
pub const Material = extern struct {
    /// Material shader
    shader: Shader,
    /// Material maps array (MAX_MATERIAL_MAPS)
    maps: ?[*]MaterialMap,
    /// Material generic parameters (if required)
    params: [4]f32,

    comptime {
        cast.assertLayout(@This(), c.Material);
    }
};
/// Transform, vertex transformation data
///
/// raylib.h's `Transform`.
/// The `Quaternion` field is `Vector4`; ModelAnimPose is `[*]Transform`.
pub const Transform = extern struct {
    /// Translation
    translation: Vector3,
    /// Rotation
    rotation: Quaternion,
    /// Scale
    scale: Vector3,

    comptime {
        cast.assertLayout(@This(), c.Transform);
    }
};
/// Bone, skeletal animation bone
///
/// raylib.h's `BoneInfo`.
pub const BoneInfo = extern struct {
    /// Bone name
    name: [32]u8,
    /// Bone parent
    parent: i32,

    comptime {
        cast.assertLayout(@This(), c.BoneInfo);
    }
};
/// Skeleton, animation bones hierarchy
///
/// raylib.h's `ModelSkeleton`.
pub const ModelSkeleton = extern struct {
    /// Number of bones
    boneCount: u32,
    /// Bones information (skeleton)
    bones: ?[*]BoneInfo,
    /// Bones base transformation (Transform[])
    bindPose: ModelAnimPose,

    comptime {
        cast.assertLayout(@This(), c.ModelSkeleton);
    }
};
/// Model, meshes, materials and animation data
///
/// raylib.h's `Model`.
pub const Model = extern struct {
    /// Local transform matrix
    transform: Matrix,
    /// Number of meshes
    meshCount: i32,
    /// Number of materials
    materialCount: i32,
    /// Meshes array
    meshes: ?[*]Mesh,
    /// Materials array
    materials: ?[*]Material,
    /// Mesh material number
    meshMaterial: ?[*]i32,
    /// Skeleton for animation
    skeleton: ModelSkeleton,
    /// Current animation pose (Transform[])
    currentPose: ModelAnimPose,
    /// Bones animated transformation matrices
    boneMatrices: ?[*]Matrix,

    comptime {
        cast.assertLayout(@This(), c.Model);
    }
};
/// ModelAnimation, contains a full animation sequence
///
/// raylib.h's `ModelAnimation`.
/// keyframePoses is `[keyframe][pose]`: a pointer to an array of `ModelAnimPose`.
pub const ModelAnimation = extern struct {
    /// Animation name
    name: [32]u8,
    /// Number of bones (per pose)
    boneCount: u32,
    /// Number of animation key frames
    keyframeCount: i32,
    /// Animation sequence keyframe poses [keyframe][pose]
    keyframePoses: ?[*]ModelAnimPose,

    comptime {
        cast.assertLayout(@This(), c.ModelAnimation);
    }
};
/// Ray, ray for raycasting
///
/// raylib.h's `Ray`.
pub const Ray = extern struct {
    /// Ray position (origin)
    position: Vector3,
    /// Ray direction (normalized)
    direction: Vector3,

    comptime {
        cast.assertLayout(@This(), c.Ray);
    }
};
/// RayCollision, ray hit information
///
/// raylib.h's `RayCollision`.
pub const RayCollision = extern struct {
    /// Did the ray hit something?
    hit: bool,
    /// Distance to the nearest hit
    distance: f32,
    /// Point of the nearest hit
    point: Vector3,
    /// Surface normal of hit
    normal: Vector3,

    comptime {
        cast.assertLayout(@This(), c.RayCollision);
    }
};
/// BoundingBox
///
/// raylib.h's `BoundingBox`.
pub const BoundingBox = extern struct {
    /// Minimum vertex box-corner
    min: Vector3,
    /// Maximum vertex box-corner
    max: Vector3,

    comptime {
        cast.assertLayout(@This(), c.BoundingBox);
    }
};
/// Wave, audio wave data
///
/// raylib.h's `Wave`.
pub const Wave = extern struct {
    /// Total number of frames (considering channels)
    frameCount: u32,
    /// Frequency (samples per second)
    sampleRate: u32,
    /// Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    sampleSize: u32,
    /// Number of channels (1-mono, 2-stereo, ...)
    channels: u32,
    /// Buffer data pointer
    data: ?*anyopaque,

    comptime {
        cast.assertLayout(@This(), c.Wave);
    }
};
/// AudioStream, custom audio stream
///
/// raylib.h's `AudioStream`.
/// raylib's `rAudioBuffer` and `rAudioProcessor` are private to its audio module, so both fields are opaque pointers.
pub const AudioStream = extern struct {
    /// Pointer to internal data used by the audio system
    buffer: ?*anyopaque,
    /// Pointer to internal data processor, useful for audio effects
    processor: ?*anyopaque,
    /// Frequency (samples per second)
    sampleRate: u32,
    /// Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    sampleSize: u32,
    /// Number of channels (1-mono, 2-stereo, ...)
    channels: u32,

    comptime {
        cast.assertLayout(@This(), c.AudioStream);
    }
};
/// Sound
///
/// raylib.h's `Sound`.
pub const Sound = extern struct {
    /// Audio stream
    stream: AudioStream,
    /// Total number of frames (considering channels)
    frameCount: u32,

    comptime {
        cast.assertLayout(@This(), c.Sound);
    }
};
/// Music, audio stream, anything longer than ~10 seconds should be streamed
///
/// raylib.h's `Music`.
pub const Music = extern struct {
    /// Audio stream
    stream: AudioStream,
    /// Total number of frames (considering channels)
    frameCount: u32,
    /// Music looping enable
    looping: bool,
    /// Type of music context (audio filetype)
    ctxType: i32,
    /// Audio context data, depends on type
    ctxData: ?*anyopaque,

    comptime {
        cast.assertLayout(@This(), c.Music);
    }
};
/// VrDeviceInfo, Head-Mounted-Display device parameters
///
/// raylib.h's `VrDeviceInfo`.
pub const VrDeviceInfo = extern struct {
    /// Horizontal resolution in pixels
    hResolution: i32,
    /// Vertical resolution in pixels
    vResolution: i32,
    /// Horizontal size in meters
    hScreenSize: f32,
    /// Vertical size in meters
    vScreenSize: f32,
    /// Distance between eye and display in meters
    eyeToScreenDistance: f32,
    /// Lens separation distance in meters
    lensSeparationDistance: f32,
    /// IPD (distance between pupils) in meters
    interpupillaryDistance: f32,
    /// Lens distortion constant parameters
    lensDistortionValues: [4]f32,
    /// Chromatic aberration correction parameters
    chromaAbCorrection: [4]f32,

    comptime {
        cast.assertLayout(@This(), c.VrDeviceInfo);
    }
};
/// VrStereoConfig, VR stereo rendering configuration for simulator
///
/// raylib.h's `VrStereoConfig`.
pub const VrStereoConfig = extern struct {
    /// VR projection matrices (per eye)
    projection: [2]Matrix,
    /// VR view offset matrices (per eye)
    viewOffset: [2]Matrix,
    /// VR left lens center
    leftLensCenter: [2]f32,
    /// VR right lens center
    rightLensCenter: [2]f32,
    /// VR left screen center
    leftScreenCenter: [2]f32,
    /// VR right screen center
    rightScreenCenter: [2]f32,
    /// VR distortion scale
    scale: [2]f32,
    /// VR distortion scale in
    scaleIn: [2]f32,

    comptime {
        cast.assertLayout(@This(), c.VrStereoConfig);
    }
};
/// File path list
///
/// raylib.h's `FilePathList`.
/// paths is a `char **`: an array of NUL-terminated strings.
pub const FilePathList = extern struct {
    /// Filepaths entries count
    count: u32,
    /// Filepaths entries
    paths: ?[*][*:0]u8,

    comptime {
        cast.assertLayout(@This(), c.FilePathList);
    }
};
/// Automation event
///
/// raylib.h's `AutomationEvent`.
pub const AutomationEvent = extern struct {
    /// Event frame
    frame: u32,
    /// Event type (AutomationEventType)
    type: u32,
    /// Event parameters (if required)
    params: [4]i32,

    comptime {
        cast.assertLayout(@This(), c.AutomationEvent);
    }
};
/// Automation event list
///
/// raylib.h's `AutomationEventList`.
pub const AutomationEventList = extern struct {
    /// Events max entries (MAX_AUTOMATION_EVENTS)
    capacity: u32,
    /// Events entries count
    count: u32,
    /// Events entries
    events: ?[*]AutomationEvent,

    comptime {
        cast.assertLayout(@This(), c.AutomationEventList);
    }
};
/// Texture2D, same as `Texture`.
pub const Texture2D = Texture;

/// TextureCubemap, same as `Texture`.
pub const TextureCubemap = Texture;

/// RenderTexture2D, same as `RenderTexture`.
pub const RenderTexture2D = RenderTexture;

/// Camera, raylib's fallback typedef for `Camera3D`.
pub const Camera = Camera3D;

/// Anim pose, raylib's `typedef Transform *ModelAnimPose`: an array of `Transform[]`.
pub const ModelAnimPose = [*]Transform;
