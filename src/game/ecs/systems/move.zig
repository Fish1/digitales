const zflecs = @import("zflecs");

const components = @import("../components.zig");

fn system(positions: []components.Position) void {
    for (positions) |*p| {
        p.x = p.x - 1.0;
        p.y = p.y + 1.0;
    }
}

pub fn init(world: *zflecs.world_t) void {
    _ = zflecs.ADD_SYSTEM(world, "move", zflecs.OnUpdate, system);
}
