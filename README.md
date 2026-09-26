# raylibz

raylibz is the Zig++-sanctioned wrapper for [raylib](https://github.com/raysan5/raylib):
a thin, 1:1 Zig face on raylib's *own* translated headers. It ships as a package,
not in the standard library.

## Thank you, raysan

To Ramon Santamaria ([@raysan5](https://github.com/raysan5)) and raylib's
contributors: thank you. raylib has taught a great many people to program, and it
keeps the promise its README makes: *raylib is a simple and easy-to-use library
to enjoy videogames programming.* It has done that since 2013, under the zlib
license, given away.

raylib is sustained by its users. If raylibz gets you a window, please consider
[sponsoring raysan](https://github.com/sponsors/raysan5) or supporting raylib on
[Patreon](https://www.patreon.com/raylib).

## What raylibz is

raylibz adds nothing raylib does not have, renames nothing beyond Zig casing,
hides nothing, and never forks raylib.

* **raylib's declarations are the source of truth.** raylib's own `build.zig`
  builds raylib and translates `raylib.h`, `rcamera.h`, `raymath.h` and `rlgl.h`.
  raylibz depends on that, imports those translations, and puts a Zig face on
  them. The C declarations raylibz wraps are exactly the ones raylib's own users
  get.
* **Nothing is hidden.** `raylibz.c`, `raylibz.raymath` and `raylibz.rlgl` are
  raylib's translated modules, raw; a program can always drop to raylib's own
  declarations.
* **The wrapper is proved at compile time.** Every mirrored struct asserts its
  size, alignment, field names, offsets and field sizes against the translation;
  every enum value and flag bit asserts against the translated constant; and
  `tests/parity.zig` fails if any raylib function is neither wrapped nor
  explicitly listed with a reason. A drift in raylib's header is a build error
  here, not a surprise at runtime.

## Depending on raylibz

raylibz is Live at Head: nothing is tagged, anywhere. A consumer pins a commit.

```sh
zig fetch --save https://github.com/mattneel/raylibz/archive/<commit>.tar.gz
```

That records the tarball URL and its hash in your `build.zig.zon`
(`zig fetch` prints the hash if you would rather write the entry by hand).
Then, in your `build.zig`:

```zig
const raylibz = b.dependency("raylibz", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("raylibz", raylibz.module("raylibz"));
```

raylib itself arrives as raylibz's own dependency, built by raylib's build
script, and the module carries that link: an executable needs nothing else. Every
raylib build option is raylibz's too, with raylib's names and defaults, so
`-Dplatform=rgfw`, `-Dopengl_version=gl_4_3`, `-Drtextures=false` and the rest
work in your tree as they do in raylib's.

The package names the Zig++ release it is verified with as its
`minimum_zig_version`, and Zig++'s version dispatch runs that release for it.

## A minimal program

```zig
const raylibz = @import("raylibz");

pub fn main() void {
    raylibz.initWindow(800, 450, "hello, raylibz");
    raylibz.setTargetFPS(60);

    while (!raylibz.windowShouldClose()) {
        raylibz.beginDrawing();
        raylibz.clearBackground(raylibz.Color.raywhite);
        raylibz.drawText("Congrats! You created your first window!", 190, 200, 20, raylibz.Color.lightgray);
        raylibz.endDrawing();
    }

    raylibz.closeWindow();
}
```

This repository's own version of that program is `examples/basic_window.zig`, a
port of raylib's `examples/core/core_basic_window.c`:

```sh
zig build examples
zig build run-basic_window              # until you close the window
zig build run-basic_window -- --frames 60   # 60 frames, then exit (for CI)
```

## The blessed workflow

raylibz is also the reference example of the workflow Zig++ blesses for consuming
*any* C library:

1. **Fetch the pinned release.** `zig fetch --save <tarball url>` records the URL
   and the hash of the unpacked package in `build.zig.zon`. raylibz pins raylib
   by commit, because raylib is Live at Head.
2. **Build the library with its own build script.** raylibz calls
   `b.dependency("raylib", ...)` and links `dependency.artifact("raylib")`.
   raylib's build script owns every platform choice.
3. **Translate the headers.** raylib's own `build.zig` runs `addTranslateC` over
   its four public headers and publishes the translations as modules. raylibz
   takes those modules as they are. A library whose build script does not
   translate its headers gets the same `addTranslateC` call in its consumer.
4. **Put the wrapper on top.** raylibz is a Zig module that imports the
   translation and re-exposes it under the rules below. Nothing else.

## The rules, in brief

* **Names**: raylib's, first letter lowercased (`InitWindow` → `initWindow`,
  `GetFPS` → `getFPS`). Types and struct fields keep raylib's names, so anyone
  porting raylib C keeps every field access as written.
* **Structs**: an `extern struct` per raylib struct, raylib's fields in raylib's
  order, with a compile-time layout assertion.
* **Text**: `const char *` in is `[:0]const u8`; text out is `[:0]const u8`, or
  `?[:0]u8` where the caller must release it, and the matching unload takes that
  slice back.
* **Buffers**: a pointer-and-count pair is a slice, in and out.
* **Loading**: a `Load*` that raylib pairs with an `Is*Valid` check returns
  `error{LoadFailed}!T`, having made that check.
* **Enums**: raylib's enums as Zig enums with raylib's values; `ConfigFlags` and
  `Gesture` as packed structs of bools, a bit each; the 26 colours as decls on
  `Color` (`Color.raywhite`, `Color.lightgray`).
* **raymath**: methods on the vector and matrix types, named without the type
  prefix (`Vector2Add(a, b)` → `a.add(b)`); `Quaternion` is `Vector4`, so its
  family stays free functions in `math.zig`.
* **Coverage**: every raylib function is wrapped, re-exported unchanged, or
  listed in `not_wrapped` with a reason. Silently dropping one is a test failure.

The full design, and the reasons for each rule, is the proposal that started
this: [`doc/proposals/raylibz.md`](https://github.com/mattneel/zigpp/blob/master/doc/proposals/raylibz.md)
in the Zig++ repository.

## In the steps of raylib-zig

[raylib-zig](https://github.com/raylib-zig/raylib-zig), by Nikolas Wipper
(Not-Nik) and its contributors, MIT-licensed, came first and does most of this
well. raylibz owes it the shape of nearly every rule above. The difference is
where the C declarations come from: raylib-zig keeps its own generated extern
declarations, while raylibz keeps none and wraps raylib's own translation,
proving the wrapper against it at compile time. raylib-zig's users have no reason
to switch.

## Status

Working now:

* the package, its raw layer (`raylibz.c`, `raylibz.raymath`, `raylibz.rlgl`),
  and the build steps `test`, `parity`, `examples` and `run-<example>`;
* all 35 mirrored structs with their layout assertions, the six typedef
  aliases, `Color`'s 26 colours, all 21 enums, and the `ConfigFlags` and
  `Gesture` flag sets;
* the parity machinery: `tests/functions.zig` (every RLAPI function of the
  pinned raylib.h with its module, and raymath's 146 RMAPI names) and
  `tests/parity.zig`, which fails, per module, listing what is left;
* `examples/basic_window.zig`, which runs.

In progress: **the function wrappers.** Only the ones `basic_window` needs are
written so far (`initWindow`, `closeWindow`, `windowShouldClose`, `setTargetFPS`,
`beginDrawing`, `endDrawing`, `clearBackground`, `drawText`). The rest are being
written module by module, and `zig build parity` (or
`zig build parity -Dmodule=textures`, one module at a time) prints exactly what
each one owes. raymath's methods land the same way. Until the wrappers are done,
`zig build parity` fails on purpose; `zig build test` and `zig build examples`
pass.

## License

zlib, like raylib: see [LICENSE](LICENSE). raylib's own notice and license text,
and what raylibz takes from raylib, are in [NOTICE](NOTICE).
