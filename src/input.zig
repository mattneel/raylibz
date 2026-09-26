//! raylib's input handling (keyboard, gamepads, mouse, touch), from raylib.h's
//! core module, with its rgestures and rcamera sections.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, and raylib's own one-line comment
//! copied above the wrapper. What is not wrapped is listed in `not_wrapped`.
//!
//! The keyboard, mouse, gamepad and gesture state lives in raylib's core, not in
//! a window: raylib's functions here read and write it and never touch the
//! window handle, so the wrappers are testable without a display. The two
//! exceptions raylibz's tests stay away from are `SetGamepadMappings` (GLFW
//! parses the SDL mappings and needs `glfwInit`) and the cursor and mouse
//! position setters (GLFW dereferences the window handle).
//!
//! This file imports only names the root also publishes (`c`, `cast`, `types`,
//! the vector files, `enums` and the type names they hold), because the root's
//! re-export test requires every top-level declaration here to exist in
//! `raylibz` too. Private helpers go in a `const internal = struct { ... };`,
//! which that test skips.

const c = @import("raylib");
const cast = @import("cast.zig");
const types = @import("types.zig");
const enums = @import("enums.zig");
const vector2 = @import("vector2.zig");
const vector3 = @import("vector3.zig");

const Camera = types.Camera;
const Vector2 = vector2.Vector2;
const Vector3 = vector3.Vector3;
const KeyboardKey = enums.KeyboardKey;
const MouseButton = enums.MouseButton;
const MouseCursor = enums.MouseCursor;
const GamepadButton = enums.GamepadButton;
const GamepadAxis = enums.GamepadAxis;
const Gesture = enums.Gesture;
const CameraMode = enums.CameraMode;

/// The functions of raylib.h's input handling, rgestures and rcamera sections that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

// Input-related functions: keyboard

/// Check if key has been pressed once
///
/// `key` is raylib's `KeyboardKey`, which raylib's C takes as an `int` key code.
pub fn isKeyPressed(key: KeyboardKey) bool {
    return c.IsKeyPressed(@backingInt(key));
}

/// Check if key has been pressed again
///
/// `key` is raylib's `KeyboardKey`, which raylib's C takes as an `int` key code.
pub fn isKeyPressedRepeat(key: KeyboardKey) bool {
    return c.IsKeyPressedRepeat(@backingInt(key));
}

/// Check if key is being pressed
///
/// `key` is raylib's `KeyboardKey`, which raylib's C takes as an `int` key code.
pub fn isKeyDown(key: KeyboardKey) bool {
    return c.IsKeyDown(@backingInt(key));
}

/// Check if key has been released once
///
/// `key` is raylib's `KeyboardKey`, which raylib's C takes as an `int` key code.
pub fn isKeyReleased(key: KeyboardKey) bool {
    return c.IsKeyReleased(@backingInt(key));
}

/// Check if key is NOT being pressed
///
/// `key` is raylib's `KeyboardKey`, which raylib's C takes as an `int` key code.
pub fn isKeyUp(key: KeyboardKey) bool {
    return c.IsKeyUp(@backingInt(key));
}

/// Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
///
/// The key code is a raylib `KeyboardKey`, never a Zig enum ordinal; the enum is
/// non-exhaustive, so a key raylibz has no name for still crosses. `.key_null`
/// is raylib's "the queue is empty".
pub fn getKeyPressed() KeyboardKey {
    return @fromBackingInt(@intCast(c.GetKeyPressed()));
}

/// Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
///
/// The codepoint is a plain `i32`, not a raylib type, so raylibz keeps raylib's
/// signature as it is.
pub const getCharPressed = c.GetCharPressed;

/// Get name of a QWERTY key on the current keyboard layout (eg returns string 'q' for KEY_A on an AZERTY keyboard)
///
/// `key` is raylib's `KeyboardKey`. `null` when the key has no name (or the
/// keyboard layout is not known yet), as raylib's GLFW backend returns `NULL`
/// for every key that is not printable. The slice is raylib's own storage, not a
/// copy: it lives until GLFW writes that key's name again.
pub fn getKeyName(key: KeyboardKey) ?[:0]const u8 {
    return cast.optSpan(c.GetKeyName(@backingInt(key)));
}

/// Set a custom key to exit program (default is ESC)
///
/// `key` is raylib's `KeyboardKey`, which raylib's C takes as an `int` key code.
pub fn setExitKey(key: KeyboardKey) void {
    c.SetExitKey(@backingInt(key));
}

// Input-related functions: gamepads

/// Check if gamepad is available
///
/// `gamepad` is a slot index in raylib's own range, not a raylib type.
pub const isGamepadAvailable = c.IsGamepadAvailable;

/// Get gamepad internal name id
///
/// `gamepad` is a slot index in raylib's own range, not a raylib type. `null`
/// when the index is outside raylib's range; an empty string when that slot
/// holds no gamepad. The slice is raylib's own storage, not a copy: raylib
/// rewrites it when a gamepad is plugged in or out.
pub fn getGamepadName(gamepad: i32) ?[:0]const u8 {
    return cast.optSpan(c.GetGamepadName(gamepad));
}

/// Check if gamepad button has been pressed once
///
/// `button` is raylib's `GamepadButton`, which raylib's C takes as an `int`.
pub fn isGamepadButtonPressed(gamepad: i32, button: GamepadButton) bool {
    return c.IsGamepadButtonPressed(gamepad, @backingInt(button));
}

/// Check if gamepad button is being pressed
///
/// `button` is raylib's `GamepadButton`, which raylib's C takes as an `int`.
pub fn isGamepadButtonDown(gamepad: i32, button: GamepadButton) bool {
    return c.IsGamepadButtonDown(gamepad, @backingInt(button));
}

/// Check if gamepad button has been released once
///
/// `button` is raylib's `GamepadButton`, which raylib's C takes as an `int`.
pub fn isGamepadButtonReleased(gamepad: i32, button: GamepadButton) bool {
    return c.IsGamepadButtonReleased(gamepad, @backingInt(button));
}

/// Check if gamepad button is NOT being pressed
///
/// `button` is raylib's `GamepadButton`, which raylib's C takes as an `int`.
pub fn isGamepadButtonUp(gamepad: i32, button: GamepadButton) bool {
    return c.IsGamepadButtonUp(gamepad, @backingInt(button));
}

/// Get the last gamepad button pressed
///
/// The button is a raylib `GamepadButton`; `.gamepad_button_unknown` is raylib's
/// "nothing has been pressed" (and the value raylib resets it to every frame).
/// The enum is non-exhaustive, so a button raylibz has no name for still crosses.
pub fn getGamepadButtonPressed() GamepadButton {
    return @fromBackingInt(@intCast(c.GetGamepadButtonPressed()));
}

/// Get axis count for a gamepad
///
/// `gamepad` is a slot index in raylib's own range, not a raylib type.
pub const getGamepadAxisCount = c.GetGamepadAxisCount;

/// Get movement value for a gamepad axis
///
/// `axis` is raylib's `GamepadAxis`, which raylib's C takes as an `int`.
pub fn getGamepadAxisMovement(gamepad: i32, axis: GamepadAxis) f32 {
    return c.GetGamepadAxisMovement(gamepad, @backingInt(axis));
}

/// Set internal gamepad mappings (SDL_GameControllerDB)
///
/// raylib's C takes a `const char *` of SDL game controller mappings, one per
/// line; the Zig string is passed through as its bytes.
pub fn setGamepadMappings(mappings: [:0]const u8) i32 {
    return c.SetGamepadMappings(cast.cstr(mappings));
}

/// Set gamepad vibration for both motors (duration in seconds)
///
/// `gamepad` is a slot index in raylib's own range, and the motors and duration
/// are plain `f32`, so raylibz keeps raylib's signature as it is.
pub const setGamepadVibration = c.SetGamepadVibration;

// Input-related functions: mouse

/// Check if mouse button has been pressed once
///
/// `button` is raylib's `MouseButton`, which raylib's C takes as an `int`.
pub fn isMouseButtonPressed(button: MouseButton) bool {
    return c.IsMouseButtonPressed(@backingInt(button));
}

/// Check if mouse button is being pressed
///
/// `button` is raylib's `MouseButton`, which raylib's C takes as an `int`.
pub fn isMouseButtonDown(button: MouseButton) bool {
    return c.IsMouseButtonDown(@backingInt(button));
}

/// Check if mouse button has been released once
///
/// `button` is raylib's `MouseButton`, which raylib's C takes as an `int`.
pub fn isMouseButtonReleased(button: MouseButton) bool {
    return c.IsMouseButtonReleased(@backingInt(button));
}

/// Check if mouse button is NOT being pressed
///
/// `button` is raylib's `MouseButton`, which raylib's C takes as an `int`.
pub fn isMouseButtonUp(button: MouseButton) bool {
    return c.IsMouseButtonUp(@backingInt(button));
}

/// Get mouse position X
pub const getMouseX = c.GetMouseX;

/// Get mouse position Y
pub const getMouseY = c.GetMouseY;

/// Get mouse position XY
///
/// raylib's own `Vector2`, raylibz's mirror of it.
pub fn getMousePosition() Vector2 {
    return cast.as(Vector2, c.GetMousePosition());
}

/// Get mouse delta between frames
///
/// raylib's own `Vector2`, raylibz's mirror of it.
pub fn getMouseDelta() Vector2 {
    return cast.as(Vector2, c.GetMouseDelta());
}

/// Set mouse position XY
///
/// The coordinates are plain `int`s, so raylibz keeps raylib's signature as it
/// is. raylib moves the real cursor, so this needs a window.
pub const setMousePosition = c.SetMousePosition;

/// Set mouse offset
///
/// The offsets are plain `int`s, so raylibz keeps raylib's signature as it is.
pub const setMouseOffset = c.SetMouseOffset;

/// Set mouse scaling
///
/// The scales are plain `f32`s, so raylibz keeps raylib's signature as it is.
pub const setMouseScale = c.SetMouseScale;

/// Get mouse wheel movement for X or Y, whichever is larger
pub const getMouseWheelMove = c.GetMouseWheelMove;

/// Get mouse wheel movement for both X and Y
///
/// raylib's own `Vector2`, raylibz's mirror of it.
pub fn getMouseWheelMoveV() Vector2 {
    return cast.as(Vector2, c.GetMouseWheelMoveV());
}

/// Set mouse cursor
///
/// `cursor` is raylib's `MouseCursor`, which raylib's C takes as an `int`.
pub fn setMouseCursor(cursor: MouseCursor) void {
    c.SetMouseCursor(@backingInt(cursor));
}

// Input-related functions: touch

/// Get touch position X for touch point 0 (relative to screen size)
pub const getTouchX = c.GetTouchX;

/// Get touch position Y for touch point 0 (relative to screen size)
pub const getTouchY = c.GetTouchY;

/// Get touch position XY for a touch point index (relative to screen size)
///
/// `index` is a touch point index bounded by raylib's own `MAX_TOUCH_POINTS`,
/// not a raylib type. raylib's own `Vector2`, raylibz's mirror of it.
pub fn getTouchPosition(index: i32) Vector2 {
    return cast.as(Vector2, c.GetTouchPosition(index));
}

/// Get touch point identifier for provided index
///
/// `index` is a touch point index bounded by raylib's own `MAX_TOUCH_POINTS`,
/// not a raylib type.
pub const getTouchPointId = c.GetTouchPointId;

/// Get number of touch points
pub const getTouchPointCount = c.GetTouchPointCount;

// Gestures and touch handling functions (Module: rgestures)

/// Enable a set of gestures using flags
///
/// `flags` is raylib's `Gesture` flag set; raylib's C takes the same bits as an
/// `unsigned int`.
pub fn setGesturesEnabled(flags: Gesture) void {
    c.SetGesturesEnabled(@as(u32, @bitCast(flags)));
}

/// Check if gesture has been detected
///
/// raylib's C takes the gesture as an `unsigned int` and compares the whole mask
/// raylib enabled and detected against it, so a set of several gestures here is
/// true only while exactly that set is current; the usual argument is one
/// gesture flag.
pub fn isGestureDetected(gesture: Gesture) bool {
    return c.IsGestureDetected(@as(u32, @bitCast(gesture)));
}

/// Get latest detected gesture
///
/// The gesture(s) detected this frame, limited to the enabled set: a `Gesture`
/// flag set, which raylib's C returns as an `int` of the same bits. Empty
/// (`.{}`, raylib's `gesture_none`) when nothing has been detected.
pub fn getGestureDetected() Gesture {
    return @bitCast(@as(u32, @bitCast(c.GetGestureDetected())));
}

/// Get gesture hold time in seconds
pub const getGestureHoldDuration = c.GetGestureHoldDuration;

/// Get gesture drag vector
///
/// raylib's own `Vector2`, raylibz's mirror of it.
pub fn getGestureDragVector() Vector2 {
    return cast.as(Vector2, c.GetGestureDragVector());
}

/// Get gesture drag angle
pub const getGestureDragAngle = c.GetGestureDragAngle;

/// Get gesture pinch delta
///
/// raylib's own `Vector2`, raylibz's mirror of it.
pub fn getGesturePinchVector() Vector2 {
    return cast.as(Vector2, c.GetGesturePinchVector());
}

/// Get gesture pinch angle
pub const getGesturePinchAngle = c.GetGesturePinchAngle;

// Camera system functions (Module: rcamera)

/// Update camera position for selected mode
///
/// `camera` is updated in place. `mode` is raylib's `CameraMode`, which raylib's
/// C takes as an `int`; raylib's `CAMERA_CUSTOM` (`.camera_custom`) leaves the
/// camera alone, for a program that moves it itself.
pub fn updateCamera(camera: *Camera, mode: CameraMode) void {
    c.UpdateCamera(cast.asPtr(c.Camera, camera), @backingInt(mode));
}

/// Update camera movement/rotation
///
/// `camera` is updated in place. raylib's own axes: `movement.x` moves forward
/// and backward, `movement.y` right and left, `movement.z` up and down;
/// `rotation.x` is yaw, `rotation.y` pitch and `rotation.z` roll, in degrees;
/// `zoom` moves the camera towards its target. The vectors are raylibz's
/// `Vector3` mirrors of raylib's own.
pub fn updateCameraPro(camera: *Camera, movement: Vector3, rotation: Vector3, zoom: f32) void {
    c.UpdateCameraPro(
        cast.asPtr(c.Camera, camera),
        cast.as(c.Vector3, movement),
        cast.as(c.Vector3, rotation),
        zoom,
    );
}

test "input: the keyboard wrappers reach raylib as its own key codes" {
    const std = @import("std");

    // raylib's state is raylibz's state: nothing has been pressed, so the key
    // queue is empty and raylib's own answer is 0, raylibz's `.key_null`.
    try std.testing.expectEqual(KeyboardKey.key_null, getKeyPressed());
    // Every key code is raylib's own (`KEY_A` is 65, not the enum's 4th field).
    try std.testing.expectEqual(@as(i32, 65), c.KEY_A);
    try std.testing.expectEqual(@as(i32, 65), @backingInt(KeyboardKey.key_a));
    // Unpressed keys are unpressed whatever the conversion, but the call has to
    // reach raylib's implementation and read its state, not a raylibz copy.
    try std.testing.expect(!isKeyDown(.key_a));
    try std.testing.expect(isKeyUp(.key_a));
    try std.testing.expect(!isKeyPressed(.key_a));
    try std.testing.expect(!isKeyPressedRepeat(.key_a));
    try std.testing.expect(!isKeyReleased(.key_a));
    setExitKey(.key_space);
}

test "input: getKeyName is raylib's nullable, raylib-owned text" {
    const std = @import("std");

    // Before GLFW is initialized, raylib's own error callback (installed by
    // InitWindow, and still installed after CloseWindow) turns GLFW's "not
    // initialized" into a TRACELOG warning. raylib writes its log to stdout, and
    // under the build runner a test binary's stdout is the runner's protocol
    // pipe, so a stray warning desyncs it and hangs `zig build test`. raylib's
    // default level is c.LOG_INFO; put it back with the defer.
    c.SetTraceLogLevel(c.LOG_NONE);
    defer c.SetTraceLogLevel(c.LOG_INFO);

    // A printable key: GLFW answers `NULL` before `InitWindow` (there is no
    // layout yet) and a name after it, and raylib hands the pointer through
    // either way. What the wrapper owes the caller is a slice raylib owns, or
    // `null` — never a dangling one.
    const name: ?[:0]const u8 = getKeyName(.key_a);
    if (name) |text| try std.testing.expect(text.len > 0);

    // A key no layout names: raylib's GLFW backend answers `NULL` for any key
    // that is not printable, with or without a window, and that has to reach the
    // caller as `null`.
    try std.testing.expectEqual(null, getKeyName(.key_escape));
}

test "input: the gamepad wrappers read raylib's gamepad slots" {
    const std = @import("std");

    // No gamepad is plugged in, in raylib's own view and in raylibz's.
    try std.testing.expect(!isGamepadAvailable(0));
    try std.testing.expectEqual(@as(i32, 0), getGamepadAxisCount(0));
    try std.testing.expect(!isGamepadButtonDown(0, .gamepad_button_right_face_down));
    try std.testing.expect(!isGamepadButtonPressed(0, .gamepad_button_right_face_down));
    try std.testing.expect(!isGamepadButtonReleased(0, .gamepad_button_right_face_down));
    try std.testing.expect(!isGamepadButtonUp(0, .gamepad_button_right_face_down));

    // The button raylib resets every frame is its own `GAMEPAD_BUTTON_UNKNOWN`.
    try std.testing.expectEqual(GamepadButton.gamepad_button_unknown, getGamepadButtonPressed());
    try std.testing.expectEqual(@as(i32, 0), c.GAMEPAD_BUTTON_UNKNOWN);

    // The axis reaches raylib as its own number: raylib's implementation answers
    // -1.0 for a trigger axis and 0.0 for the rest while no gamepad is ready, so
    // a conversion that lost the axis would show here.
    try std.testing.expectEqual(@as(f32, -1.0), getGamepadAxisMovement(0, .gamepad_axis_left_trigger));
    try std.testing.expectEqual(@as(f32, -1.0), getGamepadAxisMovement(0, .gamepad_axis_right_trigger));
    try std.testing.expectEqual(@as(f32, 0.0), getGamepadAxisMovement(0, .gamepad_axis_left_x));
    try std.testing.expectEqual(@as(f32, 0.0), getGamepadAxisMovement(0, .gamepad_axis_right_y));

    // An index outside raylib's range is raylib's `NULL` name.
    try std.testing.expectEqual(null, getGamepadName(64));
    // A slot in raylib's range that holds no gamepad is raylib's empty name.
    const empty = getGamepadName(0) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqualStrings("", empty);
}

test "input: the mouse wrappers read raylib's mouse state" {
    const std = @import("std");

    try std.testing.expect(!isMouseButtonDown(.mouse_button_left));
    try std.testing.expect(!isMouseButtonPressed(.mouse_button_left));
    try std.testing.expect(!isMouseButtonReleased(.mouse_button_left));
    // Nothing is pressed, so raylib's own answer for "is the button up" is yes.
    try std.testing.expect(isMouseButtonUp(.mouse_button_left));

    // Offset and scale are raylib's own state, and the position raylib reports
    // is the scaled sum of them: the `Vector2` that crosses back is raylib's.
    setMouseOffset(3, 4);
    setMouseScale(2, 2);
    defer {
        setMouseOffset(0, 0);
        setMouseScale(1, 1);
    }
    const position = getMousePosition();
    try std.testing.expectEqual(@as(f32, 6), position.x);
    try std.testing.expectEqual(@as(f32, 8), position.y);

    // raylib's own answer, bit for bit, from raylib's own implementation.
    const from_c = c.GetMousePosition();
    try std.testing.expectEqual(from_c.x, position.x);
    try std.testing.expectEqual(from_c.y, position.y);

    const delta = getMouseDelta();
    const wheel = getMouseWheelMoveV();
    try std.testing.expectEqual(c.GetMouseDelta().x, delta.x);
    try std.testing.expectEqual(c.GetMouseWheelMoveV().y, wheel.y);
    try std.testing.expectEqual(c.GetMouseX(), getMouseX());
    try std.testing.expectEqual(c.GetMouseY(), getMouseY());
}

test "input: the touch wrappers read raylib's touch points" {
    const std = @import("std");

    // No finger on the screen: raylib's own coordinates for point 0.
    try std.testing.expectEqual(c.GetTouchX(), getTouchX());
    try std.testing.expectEqual(c.GetTouchY(), getTouchY());
    try std.testing.expectEqual(@as(i32, 0), getTouchPointCount());

    const point = getTouchPosition(0);
    try std.testing.expectEqual(c.GetTouchPosition(0).x, point.x);
    try std.testing.expectEqual(c.GetTouchPosition(0).y, point.y);
    try std.testing.expectEqual(c.GetTouchPointId(0), getTouchPointId(0));
}

test "input: a Gesture flag set crosses as raylib's own bit mask" {
    const std = @import("std");

    // The flag set's bits are raylib's constants, not the struct's field order.
    const both = Gesture{ .gesture_tap = true, .gesture_swipe_left = true };
    try std.testing.expectEqual(@as(u32, 1), @as(u32, @bitCast(Gesture{ .gesture_tap = true })));
    try std.testing.expectEqual(@as(u32, 32), @as(u32, @bitCast(Gesture{ .gesture_swipe_left = true })));
    try std.testing.expectEqual(@as(u32, 1 | 32), @as(u32, @bitCast(both)));
    try std.testing.expectEqual(0, @as(u32, @bitCast(Gesture.gesture_none)));

    // raylib keeps the enabled set and reports the detected one; with no window
    // nothing is detected, so the mask raylib hands back is the empty set.
    setGesturesEnabled(both);
    defer setGesturesEnabled(Gesture.gesture_none);
    try std.testing.expectEqual(Gesture.gesture_none, getGestureDetected());
    try std.testing.expect(isGestureDetected(Gesture.gesture_none));
    try std.testing.expect(!isGestureDetected(both));

    // The gesture readers answer raylib's own zeros while nothing is detected.
    try std.testing.expectEqual(@as(f32, 0), getGestureHoldDuration());
    try std.testing.expectEqual(c.GetGestureDragVector().x, getGestureDragVector().x);
    try std.testing.expectEqual(c.GetGestureDragAngle(), getGestureDragAngle());
    try std.testing.expectEqual(c.GetGesturePinchVector().y, getGesturePinchVector().y);
    try std.testing.expectEqual(c.GetGesturePinchAngle(), getGesturePinchAngle());
}

test "input: the camera wrappers update the caller's camera" {
    const std = @import("std");

    var camera = Camera{
        .position = .{ .x = 0, .y = 0, .z = 10 },
        .target = .{ .x = 0, .y = 0, .z = 0 },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45,
        .projection = enums.CameraProjection.camera_perspective,
    };

    // `Camera *camera` crosses as a pointer to the same bytes: raylib's own
    // function has to write back into the caller's camera, and the value it
    // writes has to be exactly what it writes for the raw translated camera.
    var raw = cast.as(c.Camera, camera);
    updateCameraPro(&camera, .{ .x = 1, .y = 0.5, .z = -0.25 }, .{ .x = 10, .y = -5, .z = 1 }, 0.5);
    c.UpdateCameraPro(&raw, cast.as(c.Vector3, Vector3{ .x = 1, .y = 0.5, .z = -0.25 }), cast.as(c.Vector3, Vector3{ .x = 10, .y = -5, .z = 1 }), 0.5);
    try std.testing.expectEqual(raw.position.x, camera.position.x);
    try std.testing.expectEqual(raw.position.y, camera.position.y);
    try std.testing.expectEqual(raw.position.z, camera.position.z);
    try std.testing.expectEqual(raw.target.x, camera.target.x);
    try std.testing.expectEqual(raw.up.z, camera.up.z);
    try std.testing.expectEqual(raw.fovy, camera.fovy);
    try std.testing.expectEqual(@as(c_int, @backingInt(camera.projection)), raw.projection);

    // The camera has moved: `UpdateCameraPro` reached raylib's implementation.
    try std.testing.expect(camera.position.z != 10 or camera.target.z != 0);

    // `.camera_custom` is raylib's own no-op mode, whatever the camera holds.
    const before = camera;
    updateCamera(&camera, .camera_custom);
    try std.testing.expectEqual(before.position.x, camera.position.x);
    try std.testing.expectEqual(before.position.y, camera.position.y);
    try std.testing.expectEqual(before.position.z, camera.position.z);
    try std.testing.expectEqual(before.target.z, camera.target.z);
    try std.testing.expectEqual(before.fovy, camera.fovy);
    try std.testing.expectEqual(before.projection, camera.projection);
}
