const zflecs = @import("zflecs");
const components = @import("../components.zig");

fn system(iter: *zflecs.iter_t, healths: []components.Health) void {
    var economy = zflecs.singleton_get_mut(iter.world, components.Economy) orelse return;

    for (healths, iter.entities()) |health, entity| {
        if (health.current > 0) continue;
        zflecs.delete(iter.world, entity);
        economy.build = economy.build + 1;
    }
}

pub fn init(world: *zflecs.world_t) void {
    _ = zflecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "remove_no_health_enemies",
        zflecs.OnUpdate,
        system,
        &.{
            .{ .id = zflecs.id(components.Enemy) },
        },
    );
}
