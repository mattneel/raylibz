//! raylibz's build script.
//!
//! raylibz is a thin Zig face on raylib's own translated headers. raylib is a
//! dependency, pinned by commit (Live at Head: nothing is tagged anywhere), and
//! raylib's own build script builds it and publishes the translations of
//! `raylib.h`, `rcamera.h`, `raymath.h` and `rlgl.h` as the modules `raylib`,
//! `rcamera`, `raymath` and `rlgl`. raylibz imports them, links the `raylib`
//! artifact, and forwards every raylib build option unchanged.
//!
//! Steps:
//!
//!   `zig build`                       build the examples (the default step)
//!   `zig build test`                  unit tests, the layout assertions, the
//!                                     root re-export test
//!   `zig build parity`                every raylib function is wrapped,
//!                                     re-exported or listed in `not_wrapped`
//!   `zig build parity -Dmodule=core`  one module's functions, checked against
//!                                     that module's file
//!   `zig build examples`              build every example
//!   `zig build run-<example> -- ...`  run one example, passing it `--` args

const std = @import("std");
// raylib's own build script, for its option types: the options raylibz declares
// below are raylib's, with raylib's names, values and defaults, not copies.
const raylib = @import("raylib");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // raylib's build options, declared here exactly as raylib declares them, so
    // that `-Dplatform=rgfw`, `-Dopengl_version=gl_4_3`, `-Dconfig=-DXXX`,
    // `-Drtextures=false` and the rest work in this tree as they do in raylib's.
    const raylib_options: raylib.Options = .getOptions(b);
    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
        .raudio = raylib_options.raudio,
        .rmodels = raylib_options.rmodels,
        .rshapes = raylib_options.rshapes,
        .rtext = raylib_options.rtext,
        .rtextures = raylib_options.rtextures,
        .raygui = raylib_options.raygui,
        .platform = raylib_options.platform,
        .linkage = raylib_options.linkage,
        .linux_display_backend = raylib_options.linux_display_backend,
        .opengl_version = raylib_options.opengl_version,
        .android_ndk = raylib_options.android_ndk,
        .android_api_version = raylib_options.android_api_version,
        .config = raylib_options.config,
    });
    const raylib_artifact = raylib_dep.artifact("raylib");

    // The package: raylibz, over raylib's translated declarations.
    const module = b.addModule("raylibz", .{
        .root_source_file = b.path("src/raylibz.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    module.addImport("raylib", raylib_dep.module("raylib"));
    module.addImport("raymath", raylib_dep.module("raymath"));
    module.addImport("rlgl", raylib_dep.module("rlgl"));
    module.linkLibrary(raylib_artifact);

    // `zig build test`: the unit tests of every file in src/ (the root's test
    // pulls them in), the layout assertion of every mirror, the root re-export
    // test, and tests/raymath.zig, which compares every raymath wrapper against
    // raylib's own function on the same inputs. tests/parity.zig is not here: it
    // fails on purpose until every function is accounted for, and `zig build
    // parity` runs it.
    const test_step = b.step("test", "Run the unit, layout, raymath and re-export tests");
    const unit_tests = b.addTest(.{ .name = "raylibz", .root_module = module });
    test_step.dependOn(&b.addRunArtifact(unit_tests).step);
    const layout_tests = b.addTest(.{
        .name = "layout",
        .root_module = testsModule(b, module, raylib_artifact, target, optimize, "tests/layout.zig"),
    });
    test_step.dependOn(&b.addRunArtifact(layout_tests).step);
    const raymath_tests = b.addTest(.{
        .name = "raymath",
        .root_module = testsModule(b, module, raylib_artifact, target, optimize, "tests/raymath.zig"),
    });
    test_step.dependOn(&b.addRunArtifact(raymath_tests).step);

    // `zig build parity` (`-Dmodule=<file>` to check one module on its own).
    const module_option = b.option(
        []const u8,
        "module",
        "check one module file only: core, files, input, shapes, textures, text, models, audio or raymath",
    ) orelse "";
    const parity_options = b.addOptions();
    parity_options.addOption([]const u8, "module", module_option);
    const parity_module = testsModule(b, module, raylib_artifact, target, optimize, "tests/parity.zig");
    parity_module.addImport("build_options", parity_options.createModule());
    const parity_tests = b.addTest(.{ .name = "parity", .root_module = parity_module });
    const parity_step = b.step("parity", "Every raylib function is wrapped, re-exported or listed in not_wrapped");
    parity_step.dependOn(&b.addRunArtifact(parity_tests).step);

    // `zig build examples`, and a `run-<example>` step for each one: every
    // `examples/*.zig` is a program, and `zig build run-<name> -- args` passes
    // it the arguments after `--`.
    const examples_step = b.step("examples", "Build every example");
    // The build graph is cached, and the list of examples is read from the
    // directory: without this, an example added or removed is not seen until
    // the cache is cleared.
    b.dependOnDirectoryMetadata(b.path("examples"));
    var examples_dir = try b.root.openDir(b.graph.io, "examples", .{ .iterate = true });
    defer examples_dir.close(b.graph.io);
    var examples_iter = examples_dir.iterate();
    while (try examples_iter.next(b.graph.io)) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.eql(u8, std.fs.path.extension(entry.name), ".zig")) continue;
        const name = std.fs.path.stem(entry.name);

        const example_module = b.createModule(.{
            .root_source_file = b.path(b.pathJoin(&.{ "examples", entry.name })),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        example_module.addImport("raylibz", module);
        example_module.linkLibrary(raylib_artifact);

        const example = b.addExecutable(.{ .name = name, .root_module = example_module });
        const install_example = b.addInstallArtifact(example, .{});
        b.getInstallStep().dependOn(&install_example.step);
        examples_step.dependOn(&install_example.step);

        const run_example = b.addRunArtifact(example);
        run_example.addPassthruArgs();
        // An example finds its resources as raylib's own examples do, relative
        // to examples/: `run-texture` loads `resources/raybunny.png`. Without
        // this, the example would inherit whatever directory `zig build` was
        // run from.
        run_example.setCwd(b.path("examples"));
        const run_step = b.step(b.fmt("run-{s}", .{name}), b.fmt("Build and run the {s} example", .{name}));
        run_step.dependOn(&run_example.step);
    }
}

/// A test module rooted at one of this package's `tests/` files: it imports the
/// package as `raylibz` and links raylib, like any consumer does.
fn testsModule(
    b: *std.Build,
    module: *std.Build.Module,
    raylib_artifact: *std.Build.Step.Compile,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    path: []const u8,
) *std.Build.Module {
    const test_module = b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    test_module.addImport("raylibz", module);
    test_module.linkLibrary(raylib_artifact);
    return test_module;
}
