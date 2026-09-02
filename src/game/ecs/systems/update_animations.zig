const components = @import("../components.zig");
const zflecs = @import("zflecs");
const raylib = @import("raylib");

fn system(animations: []components.Animation) void {
    const delta = raylib.getFrameTime();
    for (animations) |*animation| {
        animation.update(delta);
    }
}

pub fn init(world: *zflecs.world_t) void {
    _ = zflecs.ADD_SYSTEM(world, "update_animations", zflecs.OnUpdate, system);
}
