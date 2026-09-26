//! raylib's 21 C enums, as Zig enums with raylib's own values, and its two flag
//! sets (`ConfigFlags`, `Gesture`) as packed structs of bools.
//!
//! An enum is non-exhaustive where raylib hands its values back as an `int` (a
//! return value, a struct field, a callback argument), so any value raylib
//! stores is representable; the rest are exhaustive, so a `switch` over them
//! needs no `else`. Every value is raylib's: the `comptime` block after each
//! enum asserts, field for field, that it equals the translated constant of the
//! same name in upper case (`c.KEY_A` for `.key_a`), and each flag's bit against
//! the constant that sets it.

const c = @import("raylib");
const cast = @import("cast.zig");

/// Trace log level
/// NOTE: Organized by priority level
///
/// raylib.h's `TraceLogLevel`.
pub const TraceLogLevel = enum(c_int) {
    /// Display all logs
    log_all = 0,
    /// Trace logging, intended for internal use only
    log_trace = 1,
    /// Debug logging, used for internal debugging, it should be disabled on release builds
    log_debug = 2,
    /// Info logging, used for program execution info
    log_info = 3,
    /// Warning logging, used on recoverable failures
    log_warning = 4,
    /// Error logging, used on unrecoverable failures
    log_error = 5,
    /// Fatal logging, used to abort program: exit(EXIT_FAILURE)
    log_fatal = 6,
    /// Disable logging
    log_none = 7,
    /// Any value raylib hands back, as an `int`.
    _,
};

comptime {
    cast.assertEnumValues(TraceLogLevel, c);
}

/// Keyboard keys (US keyboard layout)
/// NOTE: Use GetKeyPressed() to allow redefining required keys for alternative layouts
///
/// raylib.h's `KeyboardKey`.
pub const KeyboardKey = enum(c_int) {
    /// Key: NULL, used for no key pressed
    key_null = 0,
    /// Key: '
    key_apostrophe = 39,
    /// Key: ,
    key_comma = 44,
    /// Key: -
    key_minus = 45,
    /// Key: .
    key_period = 46,
    /// Key: /
    key_slash = 47,
    /// Key: 0
    key_zero = 48,
    /// Key: 1
    key_one = 49,
    /// Key: 2
    key_two = 50,
    /// Key: 3
    key_three = 51,
    /// Key: 4
    key_four = 52,
    /// Key: 5
    key_five = 53,
    /// Key: 6
    key_six = 54,
    /// Key: 7
    key_seven = 55,
    /// Key: 8
    key_eight = 56,
    /// Key: 9
    key_nine = 57,
    /// Key: ;
    key_semicolon = 59,
    /// Key: =
    key_equal = 61,
    /// Key: A | a
    key_a = 65,
    /// Key: B | b
    key_b = 66,
    /// Key: C | c
    key_c = 67,
    /// Key: D | d
    key_d = 68,
    /// Key: E | e
    key_e = 69,
    /// Key: F | f
    key_f = 70,
    /// Key: G | g
    key_g = 71,
    /// Key: H | h
    key_h = 72,
    /// Key: I | i
    key_i = 73,
    /// Key: J | j
    key_j = 74,
    /// Key: K | k
    key_k = 75,
    /// Key: L | l
    key_l = 76,
    /// Key: M | m
    key_m = 77,
    /// Key: N | n
    key_n = 78,
    /// Key: O | o
    key_o = 79,
    /// Key: P | p
    key_p = 80,
    /// Key: Q | q
    key_q = 81,
    /// Key: R | r
    key_r = 82,
    /// Key: S | s
    key_s = 83,
    /// Key: T | t
    key_t = 84,
    /// Key: U | u
    key_u = 85,
    /// Key: V | v
    key_v = 86,
    /// Key: W | w
    key_w = 87,
    /// Key: X | x
    key_x = 88,
    /// Key: Y | y
    key_y = 89,
    /// Key: Z | z
    key_z = 90,
    /// Key: [
    key_left_bracket = 91,
    /// Key: '\'
    key_backslash = 92,
    /// Key: ]
    key_right_bracket = 93,
    /// Key: `
    key_grave = 96,
    /// Key: Space
    key_space = 32,
    /// Key: Esc
    key_escape = 256,
    /// Key: Enter
    key_enter = 257,
    /// Key: Tab
    key_tab = 258,
    /// Key: Backspace
    key_backspace = 259,
    /// Key: Ins
    key_insert = 260,
    /// Key: Del
    key_delete = 261,
    /// Key: Cursor right
    key_right = 262,
    /// Key: Cursor left
    key_left = 263,
    /// Key: Cursor down
    key_down = 264,
    /// Key: Cursor up
    key_up = 265,
    /// Key: Page up
    key_page_up = 266,
    /// Key: Page down
    key_page_down = 267,
    /// Key: Home
    key_home = 268,
    /// Key: End
    key_end = 269,
    /// Key: Caps lock
    key_caps_lock = 280,
    /// Key: Scroll down
    key_scroll_lock = 281,
    /// Key: Num lock
    key_num_lock = 282,
    /// Key: Print screen
    key_print_screen = 283,
    /// Key: Pause
    key_pause = 284,
    /// Key: F1
    key_f1 = 290,
    /// Key: F2
    key_f2 = 291,
    /// Key: F3
    key_f3 = 292,
    /// Key: F4
    key_f4 = 293,
    /// Key: F5
    key_f5 = 294,
    /// Key: F6
    key_f6 = 295,
    /// Key: F7
    key_f7 = 296,
    /// Key: F8
    key_f8 = 297,
    /// Key: F9
    key_f9 = 298,
    /// Key: F10
    key_f10 = 299,
    /// Key: F11
    key_f11 = 300,
    /// Key: F12
    key_f12 = 301,
    /// Key: Shift left
    key_left_shift = 340,
    /// Key: Control left
    key_left_control = 341,
    /// Key: Alt left
    key_left_alt = 342,
    /// Key: Super left
    key_left_super = 343,
    /// Key: Shift right
    key_right_shift = 344,
    /// Key: Control right
    key_right_control = 345,
    /// Key: Alt right
    key_right_alt = 346,
    /// Key: Super right
    key_right_super = 347,
    /// Key: KB menu
    key_kb_menu = 348,
    /// Key: Keypad 0
    key_kp_0 = 320,
    /// Key: Keypad 1
    key_kp_1 = 321,
    /// Key: Keypad 2
    key_kp_2 = 322,
    /// Key: Keypad 3
    key_kp_3 = 323,
    /// Key: Keypad 4
    key_kp_4 = 324,
    /// Key: Keypad 5
    key_kp_5 = 325,
    /// Key: Keypad 6
    key_kp_6 = 326,
    /// Key: Keypad 7
    key_kp_7 = 327,
    /// Key: Keypad 8
    key_kp_8 = 328,
    /// Key: Keypad 9
    key_kp_9 = 329,
    /// Key: Keypad .
    key_kp_decimal = 330,
    /// Key: Keypad /
    key_kp_divide = 331,
    /// Key: Keypad *
    key_kp_multiply = 332,
    /// Key: Keypad -
    key_kp_subtract = 333,
    /// Key: Keypad +
    key_kp_add = 334,
    /// Key: Keypad Enter
    key_kp_enter = 335,
    /// Key: Keypad =
    key_kp_equal = 336,
    /// Key: Android back button
    key_back = 4,
    /// Key: Android menu button
    key_menu = 5,
    /// Key: Android volume up button
    key_volume_up = 24,
    /// Key: Android volume down button
    key_volume_down = 25,
    /// Any value raylib hands back, as an `int`.
    _,
};

comptime {
    cast.assertEnumValues(KeyboardKey, c);
}

/// Mouse buttons
///
/// raylib.h's `MouseButton`.
pub const MouseButton = enum(c_int) {
    /// Mouse button left
    mouse_button_left = 0,
    /// Mouse button right
    mouse_button_right = 1,
    /// Mouse button middle (pressed wheel)
    mouse_button_middle = 2,
    /// Mouse button side (advanced mouse device)
    mouse_button_side = 3,
    /// Mouse button extra (advanced mouse device)
    mouse_button_extra = 4,
    /// Mouse button forward (advanced mouse device)
    mouse_button_forward = 5,
    /// Mouse button back (advanced mouse device)
    mouse_button_back = 6,
};

comptime {
    cast.assertEnumValues(MouseButton, c);
}

/// Mouse cursor
///
/// raylib.h's `MouseCursor`.
pub const MouseCursor = enum(c_int) {
    /// Default pointer shape
    mouse_cursor_default = 0,
    /// Arrow shape
    mouse_cursor_arrow = 1,
    /// Text writing cursor shape
    mouse_cursor_ibeam = 2,
    /// Cross shape
    mouse_cursor_crosshair = 3,
    /// Pointing hand cursor
    mouse_cursor_pointing_hand = 4,
    /// Horizontal resize/move arrow shape
    mouse_cursor_resize_ew = 5,
    /// Vertical resize/move arrow shape
    mouse_cursor_resize_ns = 6,
    /// Top-left to bottom-right diagonal resize/move arrow shape
    mouse_cursor_resize_nwse = 7,
    /// The top-right to bottom-left diagonal resize/move arrow shape
    mouse_cursor_resize_nesw = 8,
    /// The omnidirectional resize/move cursor shape
    mouse_cursor_resize_all = 9,
    /// The operation-not-allowed shape
    mouse_cursor_not_allowed = 10,
};

comptime {
    cast.assertEnumValues(MouseCursor, c);
}

/// Gamepad buttons
///
/// raylib.h's `GamepadButton`.
pub const GamepadButton = enum(c_int) {
    /// Unknown button, for error checking
    gamepad_button_unknown = 0,
    /// Gamepad left DPAD up button
    gamepad_button_left_face_up = 1,
    /// Gamepad left DPAD right button
    gamepad_button_left_face_right = 2,
    /// Gamepad left DPAD down button
    gamepad_button_left_face_down = 3,
    /// Gamepad left DPAD left button
    gamepad_button_left_face_left = 4,
    /// Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
    gamepad_button_right_face_up = 5,
    /// Gamepad right button right (i.e. PS3: Circle, Xbox: B)
    gamepad_button_right_face_right = 6,
    /// Gamepad right button down (i.e. PS3: Cross, Xbox: A)
    gamepad_button_right_face_down = 7,
    /// Gamepad right button left (i.e. PS3: Square, Xbox: X)
    gamepad_button_right_face_left = 8,
    /// Gamepad top/back trigger left (first), it could be a trailing button
    gamepad_button_left_trigger_1 = 9,
    /// Gamepad top/back trigger left (second), it could be a trailing button
    gamepad_button_left_trigger_2 = 10,
    /// Gamepad top/back trigger right (first), it could be a trailing button
    gamepad_button_right_trigger_1 = 11,
    /// Gamepad top/back trigger right (second), it could be a trailing button
    gamepad_button_right_trigger_2 = 12,
    /// Gamepad center buttons, left one (i.e. PS3: Select)
    gamepad_button_middle_left = 13,
    /// Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
    gamepad_button_middle = 14,
    /// Gamepad center buttons, right one (i.e. PS3: Start)
    gamepad_button_middle_right = 15,
    /// Gamepad joystick pressed button left
    gamepad_button_left_thumb = 16,
    /// Gamepad joystick pressed button right
    gamepad_button_right_thumb = 17,
    /// Any value raylib hands back, as an `int`.
    _,
};

comptime {
    cast.assertEnumValues(GamepadButton, c);
}

/// Gamepad axes
///
/// raylib.h's `GamepadAxis`.
pub const GamepadAxis = enum(c_int) {
    /// Gamepad left stick X axis
    gamepad_axis_left_x = 0,
    /// Gamepad left stick Y axis
    gamepad_axis_left_y = 1,
    /// Gamepad right stick X axis
    gamepad_axis_right_x = 2,
    /// Gamepad right stick Y axis
    gamepad_axis_right_y = 3,
    /// Gamepad back trigger left, pressure level: [1..-1]
    gamepad_axis_left_trigger = 4,
    /// Gamepad back trigger right, pressure level: [1..-1]
    gamepad_axis_right_trigger = 5,
};

comptime {
    cast.assertEnumValues(GamepadAxis, c);
}

/// Material map index
///
/// raylib.h's `MaterialMapIndex`.
pub const MaterialMapIndex = enum(c_int) {
    /// Albedo material (same as: MATERIAL_MAP_DIFFUSE)
    material_map_albedo = 0,
    /// Metalness material (same as: MATERIAL_MAP_SPECULAR)
    material_map_metalness = 1,
    /// Normal material
    material_map_normal = 2,
    /// Roughness material
    material_map_roughness = 3,
    /// Ambient occlusion material
    material_map_occlusion = 4,
    /// Emission material
    material_map_emission = 5,
    /// Heightmap material
    material_map_height = 6,
    /// Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    material_map_cubemap = 7,
    /// Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    material_map_irradiance = 8,
    /// Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    material_map_prefilter = 9,
    /// Brdf material
    material_map_brdf = 10,
};

comptime {
    cast.assertEnumValues(MaterialMapIndex, c);
}

/// Shader location index
/// NOTE: Some locations are tried to be set automatically on shader loading,
/// but only if default attributes/uniforms names are found, check config.h for names
///
/// raylib.h's `ShaderLocationIndex`.
pub const ShaderLocationIndex = enum(c_int) {
    /// Shader location: vertex attribute: position
    shader_loc_vertex_position = 0,
    /// Shader location: vertex attribute: texcoord01
    shader_loc_vertex_texcoord01 = 1,
    /// Shader location: vertex attribute: texcoord02
    shader_loc_vertex_texcoord02 = 2,
    /// Shader location: vertex attribute: normal
    shader_loc_vertex_normal = 3,
    /// Shader location: vertex attribute: tangent
    shader_loc_vertex_tangent = 4,
    /// Shader location: vertex attribute: color
    shader_loc_vertex_color = 5,
    /// Shader location: matrix uniform: model-view-projection
    shader_loc_matrix_mvp = 6,
    /// Shader location: matrix uniform: view (camera transform)
    shader_loc_matrix_view = 7,
    /// Shader location: matrix uniform: projection
    shader_loc_matrix_projection = 8,
    /// Shader location: matrix uniform: model (transform)
    shader_loc_matrix_model = 9,
    /// Shader location: matrix uniform: normal
    shader_loc_matrix_normal = 10,
    /// Shader location: vector uniform: view
    shader_loc_vector_view = 11,
    /// Shader location: vector uniform: diffuse color
    shader_loc_color_diffuse = 12,
    /// Shader location: vector uniform: specular color
    shader_loc_color_specular = 13,
    /// Shader location: vector uniform: ambient color
    shader_loc_color_ambient = 14,
    /// Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
    shader_loc_map_albedo = 15,
    /// Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
    shader_loc_map_metalness = 16,
    /// Shader location: sampler2d texture: normal
    shader_loc_map_normal = 17,
    /// Shader location: sampler2d texture: roughness
    shader_loc_map_roughness = 18,
    /// Shader location: sampler2d texture: occlusion
    shader_loc_map_occlusion = 19,
    /// Shader location: sampler2d texture: emission
    shader_loc_map_emission = 20,
    /// Shader location: sampler2d texture: heightmap
    shader_loc_map_height = 21,
    /// Shader location: samplerCube texture: cubemap
    shader_loc_map_cubemap = 22,
    /// Shader location: samplerCube texture: irradiance
    shader_loc_map_irradiance = 23,
    /// Shader location: samplerCube texture: prefilter
    shader_loc_map_prefilter = 24,
    /// Shader location: sampler2d texture: brdf
    shader_loc_map_brdf = 25,
    /// Shader location: vertex attribute: bone indices
    shader_loc_vertex_boneids = 26,
    /// Shader location: vertex attribute: bone weights
    shader_loc_vertex_boneweights = 27,
    /// Shader location: matrix attribute: bone transforms (animation)
    shader_loc_matrix_bonetransforms = 28,
    /// Shader location: vertex attribute: instance transforms
    shader_loc_vertex_instancetransform = 29,
};

comptime {
    cast.assertEnumValues(ShaderLocationIndex, c);
}

/// Shader uniform data type
///
/// raylib.h's `ShaderUniformDataType`.
pub const ShaderUniformDataType = enum(c_int) {
    /// Shader uniform type: float
    shader_uniform_float = 0,
    /// Shader uniform type: vec2 (2 float)
    shader_uniform_vec2 = 1,
    /// Shader uniform type: vec3 (3 float)
    shader_uniform_vec3 = 2,
    /// Shader uniform type: vec4 (4 float)
    shader_uniform_vec4 = 3,
    /// Shader uniform type: int
    shader_uniform_int = 4,
    /// Shader uniform type: ivec2 (2 int)
    shader_uniform_ivec2 = 5,
    /// Shader uniform type: ivec3 (3 int)
    shader_uniform_ivec3 = 6,
    /// Shader uniform type: ivec4 (4 int)
    shader_uniform_ivec4 = 7,
    /// Shader uniform type: unsigned int
    shader_uniform_uint = 8,
    /// Shader uniform type: uivec2 (2 unsigned int)
    shader_uniform_uivec2 = 9,
    /// Shader uniform type: uivec3 (3 unsigned int)
    shader_uniform_uivec3 = 10,
    /// Shader uniform type: uivec4 (4 unsigned int)
    shader_uniform_uivec4 = 11,
    /// Shader uniform type: sampler2d
    shader_uniform_sampler2d = 12,
};

comptime {
    cast.assertEnumValues(ShaderUniformDataType, c);
}

/// Shader attribute data types
///
/// raylib.h's `ShaderAttributeDataType`.
pub const ShaderAttributeDataType = enum(c_int) {
    /// Shader attribute type: float
    shader_attrib_float = 0,
    /// Shader attribute type: vec2 (2 float)
    shader_attrib_vec2 = 1,
    /// Shader attribute type: vec3 (3 float)
    shader_attrib_vec3 = 2,
    /// Shader attribute type: vec4 (4 float)
    shader_attrib_vec4 = 3,
};

comptime {
    cast.assertEnumValues(ShaderAttributeDataType, c);
}

/// Pixel formats
/// NOTE: Support depends on OpenGL version and platform
///
/// raylib.h's `PixelFormat`.
pub const PixelFormat = enum(c_int) {
    /// 8 bit per pixel (no alpha)
    pixelformat_uncompressed_grayscale = 1,
    /// 8*2 bpp (2 channels)
    pixelformat_uncompressed_gray_alpha = 2,
    /// 16 bpp
    pixelformat_uncompressed_r5g6b5 = 3,
    /// 24 bpp
    pixelformat_uncompressed_r8g8b8 = 4,
    /// 16 bpp (1 bit alpha)
    pixelformat_uncompressed_r5g5b5a1 = 5,
    /// 16 bpp (4 bit alpha)
    pixelformat_uncompressed_r4g4b4a4 = 6,
    /// 32 bpp
    pixelformat_uncompressed_r8g8b8a8 = 7,
    /// 32 bpp (1 channel - float)
    pixelformat_uncompressed_r32 = 8,
    /// 32*3 bpp (3 channels - float)
    pixelformat_uncompressed_r32g32b32 = 9,
    /// 32*4 bpp (4 channels - float)
    pixelformat_uncompressed_r32g32b32a32 = 10,
    /// 16 bpp (1 channel - half float)
    pixelformat_uncompressed_r16 = 11,
    /// 16*3 bpp (3 channels - half float)
    pixelformat_uncompressed_r16g16b16 = 12,
    /// 16*4 bpp (4 channels - half float)
    pixelformat_uncompressed_r16g16b16a16 = 13,
    /// 4 bpp (no alpha)
    pixelformat_compressed_dxt1_rgb = 14,
    /// 4 bpp (1 bit alpha)
    pixelformat_compressed_dxt1_rgba = 15,
    /// 8 bpp
    pixelformat_compressed_dxt3_rgba = 16,
    /// 8 bpp
    pixelformat_compressed_dxt5_rgba = 17,
    /// 4 bpp
    pixelformat_compressed_etc1_rgb = 18,
    /// 4 bpp
    pixelformat_compressed_etc2_rgb = 19,
    /// 8 bpp
    pixelformat_compressed_etc2_eac_rgba = 20,
    /// 4 bpp
    pixelformat_compressed_pvrt_rgb = 21,
    /// 4 bpp
    pixelformat_compressed_pvrt_rgba = 22,
    /// 8 bpp
    pixelformat_compressed_astc_4x4_rgba = 23,
    /// 2 bpp
    pixelformat_compressed_astc_8x8_rgba = 24,
    /// Any value raylib hands back, as an `int`.
    _,
};

comptime {
    cast.assertEnumValues(PixelFormat, c);
}

/// Texture parameters: filter mode
/// NOTE 1: Filtering considers mipmaps if available in the texture
/// NOTE 2: Filter is accordingly set for minification and magnification
///
/// raylib.h's `TextureFilter`.
pub const TextureFilter = enum(c_int) {
    /// No filter, pixel approximation
    texture_filter_point = 0,
    /// Linear filtering
    texture_filter_bilinear = 1,
    /// Trilinear filtering (linear with mipmaps)
    texture_filter_trilinear = 2,
    /// Anisotropic filtering 4x
    texture_filter_anisotropic_4x = 3,
    /// Anisotropic filtering 8x
    texture_filter_anisotropic_8x = 4,
    /// Anisotropic filtering 16x
    texture_filter_anisotropic_16x = 5,
};

comptime {
    cast.assertEnumValues(TextureFilter, c);
}

/// Texture parameters: wrap mode
///
/// raylib.h's `TextureWrap`.
pub const TextureWrap = enum(c_int) {
    /// Repeats texture in tiled mode
    texture_wrap_repeat = 0,
    /// Clamps texture to edge pixel in tiled mode
    texture_wrap_clamp = 1,
    /// Mirrors and repeats the texture in tiled mode
    texture_wrap_mirror_repeat = 2,
    /// Mirrors and clamps to border the texture in tiled mode
    texture_wrap_mirror_clamp = 3,
};

comptime {
    cast.assertEnumValues(TextureWrap, c);
}

/// Cubemap layouts
///
/// raylib.h's `CubemapLayout`.
pub const CubemapLayout = enum(c_int) {
    /// Automatically detect layout type
    cubemap_layout_auto_detect = 0,
    /// Layout is defined by a vertical line with faces
    cubemap_layout_line_vertical = 1,
    /// Layout is defined by a horizontal line with faces
    cubemap_layout_line_horizontal = 2,
    /// Layout is defined by a 3x4 cross with cubemap faces
    cubemap_layout_cross_three_by_four = 3,
    /// Layout is defined by a 4x3 cross with cubemap faces
    cubemap_layout_cross_four_by_three = 4,
};

comptime {
    cast.assertEnumValues(CubemapLayout, c);
}

/// Font type, defines generation method
///
/// raylib.h's `FontType`.
pub const FontType = enum(c_int) {
    /// Default font generation, anti-aliased
    font_default = 0,
    /// Bitmap font generation, no anti-aliasing
    font_bitmap = 1,
    /// SDF font generation, requires external shader
    font_sdf = 2,
};

comptime {
    cast.assertEnumValues(FontType, c);
}

/// Color blending modes (pre-defined)
///
/// raylib.h's `BlendMode`.
pub const BlendMode = enum(c_int) {
    /// Blend textures considering alpha (default)
    blend_alpha = 0,
    /// Blend textures adding colors
    blend_additive = 1,
    /// Blend textures multiplying colors
    blend_multiplied = 2,
    /// Blend textures adding colors (alternative)
    blend_add_colors = 3,
    /// Blend textures subtracting colors (alternative)
    blend_subtract_colors = 4,
    /// Blend premultiplied textures considering alpha
    blend_alpha_premultiply = 5,
    /// Blend textures using custom src/dst factors (use rlSetBlendFactors())
    blend_custom = 6,
    /// Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
    blend_custom_separate = 7,
};

comptime {
    cast.assertEnumValues(BlendMode, c);
}

/// Camera system modes
///
/// raylib.h's `CameraMode`.
pub const CameraMode = enum(c_int) {
    /// Camera custom, controlled by user (UpdateCamera() does nothing)
    camera_custom = 0,
    /// Camera free mode
    camera_free = 1,
    /// Camera orbital, around target, zoom supported
    camera_orbital = 2,
    /// Camera first person
    camera_first_person = 3,
    /// Camera third person
    camera_third_person = 4,
};

comptime {
    cast.assertEnumValues(CameraMode, c);
}

/// Camera projection
///
/// raylib.h's `CameraProjection`.
pub const CameraProjection = enum(c_int) {
    /// Perspective projection
    camera_perspective = 0,
    /// Orthographic projection
    camera_orthographic = 1,
    /// Any value raylib hands back, as an `int`.
    _,
};

comptime {
    cast.assertEnumValues(CameraProjection, c);
}

/// N-patch layout
///
/// raylib.h's `NPatchLayout`.
pub const NPatchLayout = enum(c_int) {
    /// Npatch layout: 3x3 tiles
    npatch_nine_patch = 0,
    /// Npatch layout: 1x3 tiles
    npatch_three_patch_vertical = 1,
    /// Npatch layout: 3x1 tiles
    npatch_three_patch_horizontal = 2,
    /// Any value raylib hands back, as an `int`.
    _,
};

comptime {
    cast.assertEnumValues(NPatchLayout, c);
}

/// ----------------------------------------------------------------------------------
/// Enumerators Definition
/// ----------------------------------------------------------------------------------
/// System/Window config flags
/// NOTE: Every bit registers one state (use it with bit masks)
/// By default all flags are set to 0
///
/// raylib.h's `ConfigFlags`: a bit each, padding fields cover the bits raylib does not use, so that the set crosses the boundary with `@bitCast` to `u32`.
pub const ConfigFlags = packed struct(u32) {
    /// Bit 0: not used by raylib.
    _0: u1 = 0,
    /// Set to run program in fullscreen
    flag_fullscreen_mode: bool = false,
    /// Set to allow resizable window
    flag_window_resizable: bool = false,
    /// Set to disable window decoration (frame and buttons)
    flag_window_undecorated: bool = false,
    /// Set to allow transparent framebuffer
    flag_window_transparent: bool = false,
    /// Set to try enabling MSAA 4X
    flag_msaa_4x_hint: bool = false,
    /// Set to try enabling V-Sync on GPU
    flag_vsync_hint: bool = false,
    /// Set to hide window
    flag_window_hidden: bool = false,
    /// Set to allow windows running while minimized
    flag_window_always_run: bool = false,
    /// Set to minimize window (iconify)
    flag_window_minimized: bool = false,
    /// Set to maximize window (expanded to monitor)
    flag_window_maximized: bool = false,
    /// Set to window non focused
    flag_window_unfocused: bool = false,
    /// Set to window always on top
    flag_window_topmost: bool = false,
    /// Set to support HighDPI
    flag_window_highdpi: bool = false,
    /// Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    flag_window_mouse_passthrough: bool = false,
    /// Set to run program in borderless windowed mode
    flag_borderless_windowed_mode: bool = false,
    /// Set to try enabling interlaced video format (for V3D)
    flag_interlaced_hint: bool = false,
    /// Bits 17-31: not used by raylib.
    _1: u15 = 0,

    comptime {
        cast.assertFlagBits(@This(), c);
    }
};

/// Gesture
/// NOTE: Provided as bit-wise flags to enable only desired gestures
///
/// raylib.h's `Gesture`: a bit each, padding fields cover the bits raylib does not use, so that the set crosses the boundary with `@bitCast` to `u32`.
pub const Gesture = packed struct(u32) {
    /// Tap gesture
    gesture_tap: bool = false,
    /// Double tap gesture
    gesture_doubletap: bool = false,
    /// Hold gesture
    gesture_hold: bool = false,
    /// Drag gesture
    gesture_drag: bool = false,
    /// Swipe right gesture
    gesture_swipe_right: bool = false,
    /// Swipe left gesture
    gesture_swipe_left: bool = false,
    /// Swipe up gesture
    gesture_swipe_up: bool = false,
    /// Swipe down gesture
    gesture_swipe_down: bool = false,
    /// Pinch in gesture
    gesture_pinch_in: bool = false,
    /// Pinch out gesture
    gesture_pinch_out: bool = false,
    /// Bits 10-31: not used by raylib.
    _0: u22 = 0,
    /// raylib.h's `GESTURE_NONE`: no gesture at all
    pub const gesture_none: Gesture = .{};

    comptime {
        cast.assertFlagBits(@This(), c);
    }
};
