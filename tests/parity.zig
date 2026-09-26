//! Parity: raylib's own API is the spec, and this test is what keeps raylibz
//! honest about it.
//!
//! Every one of the pinned raylib.h's RLAPI functions is exactly one of:
//!
//!   * **wrapped** — a `pub fn` (or a `pub const` re-export of raylib's own
//!     declaration) with raylib's name and the first letter lowercased, in the
//!     module file `tests/functions.zig` names for it;
//!   * **listed** — an entry in that module file's `not_wrapped`, with a reason.
//!
//! Anything else fails, listing every function that is in neither place, per
//! module file, so that each module can be finished on its own with
//! `zig build parity -Dmodule=<core|files|input|shapes|textures|text|models|audio>`. A name
//! in `not_wrapped` that raylib's translated module has no function for fails
//! too, so a stale line cannot linger.
//!
//! raymath gets the same treatment: every RMAPI function is a free function in
//! `math.zig`, a method on `Vector2`, `Vector3`, `Vector4` or `Matrix` (named
//! without the type prefix, per the conventions), or listed in
//! `not_wrapped.raymath`.
//!
//! The failure report goes to stderr through `std.log` on the failing path only:
//! a passing run writes nothing at all, as the test runner requires.

const std = @import("std");
const raylibz = @import("raylibz");
const build_options = @import("build_options");
const functions = @import("functions.zig");

const cast = raylibz.cast;
const c = raylibz.c;
const log = std.log.scoped(.parity);

/// One of raylibz's module files, and the list it is checked against.
const Module = struct {
    /// The file's name, as `tests/functions.zig` spells it.
    name: []const u8,
    /// The file itself: its declarations are the wrappers.
    file: type,
    /// The translated raylib module its functions come from.
    translated: type,
    /// The file's `not_wrapped` list.
    not_wrapped: []const cast.NotWrapped,
};

/// Every module file raylibz has, with the translated module each wraps.
const modules = [_]Module{
    .{ .name = "core", .file = raylibz.core, .translated = c, .not_wrapped = &raylibz.core.not_wrapped },
    .{ .name = "files", .file = raylibz.files, .translated = c, .not_wrapped = &raylibz.files.not_wrapped },
    .{ .name = "input", .file = raylibz.input, .translated = c, .not_wrapped = &raylibz.input.not_wrapped },
    .{ .name = "shapes", .file = raylibz.shapes, .translated = c, .not_wrapped = &raylibz.shapes.not_wrapped },
    .{ .name = "textures", .file = raylibz.textures, .translated = c, .not_wrapped = &raylibz.textures.not_wrapped },
    .{ .name = "text", .file = raylibz.text, .translated = c, .not_wrapped = &raylibz.text.not_wrapped },
    .{ .name = "models", .file = raylibz.models, .translated = c, .not_wrapped = &raylibz.models.not_wrapped },
    .{ .name = "audio", .file = raylibz.audio, .translated = c, .not_wrapped = &raylibz.audio.not_wrapped },
};

/// The types raymath's methods land on, and the prefixes their names carry.
const method_owners = [_]struct { prefix: []const u8, owner: type }{
    .{ .prefix = "Vector2", .owner = raylibz.Vector2 },
    .{ .prefix = "Vector3", .owner = raylibz.Vector3 },
    .{ .prefix = "Vector4", .owner = raylibz.Vector4 },
    .{ .prefix = "Matrix", .owner = raylibz.Matrix },
};

test "parity: every raylib function is wrapped, re-exported or listed in not_wrapped" {
    const wanted = build_options.module;
    var failures: usize = 0;

    if (wanted.len != 0 and !knownModule(wanted)) {
        log.err(
            "parity: -Dmodule={s} is not a module file; expected core, files, input, shapes, textures, text, models, audio or raymath",
            .{wanted},
        );
        failures += 1;
    }

    inline for (modules) |module| {
        if (wanted.len == 0 or std.mem.eql(u8, wanted, module.name)) {
            const names = comptime functionsOf(module.name);
            const missing_names = comptime missing(module.file, names, module.not_wrapped);
            const stale_names = comptime stale(module.translated, module.not_wrapped);

            if (missing_names.len != 0) {
                failures += missing_names.len;
                log.err("{s}.zig: {d} of {d} raylib functions are neither wrapped nor listed:", .{
                    module.name, missing_names.len, names.len,
                });
                for (missing_names) |name| log.err("    {s}", .{name});
            }
            if (stale_names.len != 0) {
                failures += stale_names.len;
                log.err("{s}.zig: not_wrapped lists {d} name(s) raylib has no function for:", .{
                    module.name, stale_names.len,
                });
                for (stale_names) |name| log.err("    {s}", .{name});
            }
        }
    }

    if (wanted.len == 0 or std.mem.eql(u8, wanted, "raymath")) failures += raymathFailures();

    try std.testing.expectEqual(@as(usize, 0), failures);
}

/// raymath's half of the parity check: every RMAPI function is a free function
/// in `math.zig`, a method on the type its name names, or listed in
/// `not_wrapped.raymath`. Returns how many are in none of the three, after
/// reporting them.
fn raymathFailures() usize {
    var failures: usize = 0;
    const missing_functions = comptime raymathMissing();
    const stale_names = comptime stale(raylibz.raymath, &raylibz.math.not_wrapped);
    if (missing_functions.len != 0) {
        failures += missing_functions.len;
        log.err("raymath: {d} of {d} functions are neither a method, a free function in math.zig, nor listed:", .{
            missing_functions.len, functions.raymath.len,
        });
        for (missing_functions) |missing_function| {
            log.err("    {s} (expected: {s})", .{ missing_function.name, missing_function.expected });
        }
    }
    if (stale_names.len != 0) {
        failures += stale_names.len;
        log.err("math.zig: not_wrapped lists {d} name(s) raymath has no function for:", .{stale_names.len});
        for (stale_names) |name| log.err("    {s}", .{name});
    }
    return failures;
}

test "parity: the generated function list is raylib's own" {
    // Every name in tests/functions.zig is a function of the translated module,
    // named by the pin. This catches a generator that drifted from the pin.
    const wrong = comptime blk: {
        @setEvalBranchQuota(1_000_000);
        var wrong_names: []const []const u8 = &.{};
        for (functions.raylib) |function| {
            if (!isFunction(c, function.name)) wrong_names = wrong_names ++ .{function.name};
        }
        for (functions.raymath) |name| {
            if (!isFunction(raylibz.raymath, name)) wrong_names = wrong_names ++ .{name};
        }
        break :blk wrong_names;
    };

    try std.testing.expectEqualSlices([]const u8, &.{}, wrong);
}

test "parity logic self-check: a tiny fake module file" {
    const Translated = struct {
        pub fn Wrapped() void {}
        pub fn Listed() void {}
    };
    const Wrappers = struct {
        pub fn wrapped() void {}
    };
    const not_wrapped = [_]cast.NotWrapped{
        .{ .name = "Listed", .reason = "the fake module lists it" },
    };

    const names = [_][]const u8{ "Wrapped", "Listed", "Absent" };
    try std.testing.expectEqualSlices([]const u8, &.{"Absent"}, comptime missing(Wrappers, &names, &not_wrapped));
    try std.testing.expectEqualSlices([]const u8, &.{}, comptime stale(Translated, &not_wrapped));

    const other_names = [_][]const u8{"Wrapped"};
    try std.testing.expectEqualSlices([]const u8, &.{}, comptime missing(Wrappers, &other_names, &not_wrapped));

    const stale_list = [_]cast.NotWrapped{
        .{ .name = "NoSuchFunction", .reason = "a line nobody deleted" },
    };
    try std.testing.expectEqualSlices([]const u8, &.{"NoSuchFunction"}, comptime stale(Translated, &stale_list));
}

test "parity logic self-check: the name and the method mapping" {
    try std.testing.expectEqualStrings("initWindow", comptime &zigName("InitWindow"));
    try std.testing.expectEqualStrings("getFPS", comptime &zigName("GetFPS"));
    try std.testing.expectEqualStrings("loadUTF8", comptime &zigName("LoadUTF8"));
    try std.testing.expectEqualStrings("loadImageAnim", comptime &zigName("LoadImageAnim"));

    // A name with a type prefix maps to that type's method, without the prefix.
    try std.testing.expectEqualStrings("Vector2.add", comptime methodHint("Vector2Add"));
    try std.testing.expectEqualStrings("Matrix.rotateX", comptime methodHint("MatrixRotateX"));
    // Anything else is a free function in math.zig.
    try std.testing.expectEqualStrings("math.quaternionSlerp", comptime methodHint("QuaternionSlerp"));
    try std.testing.expectEqualStrings("math.clamp", comptime methodHint("Clamp"));
}

/// The `-Dmodule` values this test accepts: every module file, and raymath.
const module_names: []const []const u8 = blk: {
    var names: []const []const u8 = &.{"raymath"};
    for (modules) |module| names = names ++ .{module.name};
    break :blk names;
};

/// Whether `wanted` names one of the module files this test knows.
fn knownModule(wanted: []const u8) bool {
    for (module_names) |name| {
        if (std.mem.eql(u8, wanted, name)) return true;
    }
    return false;
}

/// The names of raylib's functions that `file` must hold, in raylib.h order.
fn functionsOf(comptime file: []const u8) []const []const u8 {
    comptime {
        @setEvalBranchQuota(1_000_000);
        var names: []const []const u8 = &.{};
        for (functions.raylib) |function| {
            if (std.mem.eql(u8, function.file, file)) names = names ++ .{function.name};
        }
        return names;
    }
}

/// The names in `names` that `namespace` neither declares (raylib's name, first
/// letter lowercased) nor `not_wrapped` lists. Comptime, so the result is a
/// fixed list the test can report or assert on.
fn missing(
    comptime namespace: type,
    comptime names: []const []const u8,
    comptime not_wrapped: []const cast.NotWrapped,
) []const []const u8 {
    comptime {
        @setEvalBranchQuota(1_000_000);
        var missing_names: []const []const u8 = &.{};
        for (names) |name| {
            if (@hasDecl(namespace, &zigName(name))) continue;
            if (lists(not_wrapped, name)) continue;
            missing_names = missing_names ++ .{name};
        }
        return missing_names;
    }
}

/// The names in `not_wrapped` that `translated` has no function by.
fn stale(comptime translated: type, comptime not_wrapped: []const cast.NotWrapped) []const []const u8 {
    comptime {
        @setEvalBranchQuota(1_000_000);
        var stale_names: []const []const u8 = &.{};
        for (not_wrapped) |entry| {
            if (!isFunction(translated, entry.name)) stale_names = stale_names ++ .{entry.name};
        }
        return stale_names;
    }
}

/// One raymath function that has to be written, and where it has to go.
const MissingRaymath = struct {
    /// raymath's name for it, e.g. `Vector2Add`.
    name: []const u8,
    /// Where it has to land, e.g. `the method Vector2.add`.
    expected: []const u8,
};

/// raymath's functions that are in none of the three places they may be, with
/// the place each one belongs in.
fn raymathMissing() []const MissingRaymath {
    comptime {
        @setEvalBranchQuota(1_000_000);
        var missing_functions: []const MissingRaymath = &.{};
        for (functions.raymath) |name| {
            if (@hasDecl(raylibz.math, &zigName(name))) continue;
            if (hasMethod(name)) continue;
            if (lists(&raylibz.math.not_wrapped, name)) continue;
            missing_functions = missing_functions ++ .{MissingRaymath{
                .name = name,
                .expected = raymathExpectation(name),
            }};
        }
        return missing_functions;
    }
}

/// Whether the type raymath's `name` names carries the method it maps to, e.g.
/// `Vector2Add` against `Vector2.add`.
fn hasMethod(comptime name: []const u8) bool {
    comptime {
        for (method_owners) |entry| {
            if (!std.mem.startsWith(u8, name, entry.prefix)) continue;
            if (@hasDecl(entry.owner, &zigName(name[entry.prefix.len..]))) return true;
        }
        return false;
    }
}

/// Where raymath's `name` has to land, in one line, for the failure report.
fn raymathExpectation(comptime name: []const u8) []const u8 {
    comptime {
        for (method_owners) |entry| {
            if (std.mem.startsWith(u8, name, entry.prefix)) {
                return std.fmt.comptimePrint("the method {s}.{s}", .{
                    entry.prefix,
                    &zigName(name[entry.prefix.len..]),
                });
            }
        }
        return std.fmt.comptimePrint("the free function math.{s}", .{&zigName(name)});
    }
}

/// `Vector2Add` → `"Vector2.add"`, `QuaternionSlerp` → `"math.quaternionSlerp"`.
fn methodHint(comptime name: []const u8) []const u8 {
    comptime {
        for (method_owners) |entry| {
            if (std.mem.startsWith(u8, name, entry.prefix)) {
                return std.fmt.comptimePrint("{s}.{s}", .{ entry.prefix, &zigName(name[entry.prefix.len..]) });
            }
        }
        return std.fmt.comptimePrint("math.{s}", .{&zigName(name)});
    }
}

/// Whether `not_wrapped` lists `name`.
fn lists(comptime not_wrapped: []const cast.NotWrapped, comptime name: []const u8) bool {
    comptime {
        for (not_wrapped) |entry| {
            if (std.mem.eql(u8, entry.name, name)) return true;
        }
        return false;
    }
}

/// Whether `namespace` declares `name` as a function.
fn isFunction(comptime namespace: type, comptime name: []const u8) bool {
    comptime {
        @setEvalBranchQuota(1_000_000);
        if (!@hasDecl(namespace, name)) return false;
        return switch (@typeInfo(@TypeOf(@field(namespace, name)))) {
            .@"fn" => true,
            else => false,
        };
    }
}

/// `InitWindow` → `"initWindow"`, as a NUL-terminated array so that it can be
/// used with `@hasDecl` and friends.
fn zigName(comptime name: []const u8) [name.len:0]u8 {
    @setEvalBranchQuota(1_000_000);
    comptime var result: [name.len:0]u8 = undefined;
    inline for (name, 0..) |char, index| {
        result[index] = if (index == 0) std.ascii.toLower(char) else char;
    }
    result[name.len] = 0;
    return result;
}
