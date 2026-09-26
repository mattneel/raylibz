//! Every raylib function raylibz does not wrap, gathered from the module files
//! that own them.
//!
//! `raylib` holds raylib.h's functions, by module file; `raymath` holds
//! raymath.h's. `tests/parity.zig` fails if a name here is not a function of the
//! translated module, so a stale entry cannot linger, and fails if a function is
//! neither wrapped, nor re-exported flatly by the root, nor listed here.

const cast = @import("cast.zig");

const audio = @import("audio.zig");
const core = @import("core.zig");
const math = @import("math.zig");
const models = @import("models.zig");
const shapes = @import("shapes.zig");
const text = @import("text.zig");
const textures = @import("textures.zig");

/// raylib.h's functions that raylibz does not wrap, in module order.
pub const raylib: []const cast.NotWrapped = core.not_wrapped ++
    shapes.not_wrapped ++
    textures.not_wrapped ++
    text.not_wrapped ++
    models.not_wrapped ++
    audio.not_wrapped;

/// raymath.h's functions that raylibz does not wrap.
pub const raymath: []const cast.NotWrapped = math.not_wrapped;
