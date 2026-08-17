const zflecs = @import("zflecs");
const components = @import("../components.zig");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    var health_iter = zflecs.query_iter(iter.world, iter.query);
    var economy = zflecs.singleton_get_mut(iter.world, components.Economy) orelse return;

    while (zflecs.query_next(&health_iter) == true) {
        const health_field = zflecs.field(&health_iter, components.Health, 0) orelse continue;
        for (health_iter.entities(), 0..) |entity, index| {
            const health = health_field[index];
            if (health.current <= 0) {
                zflecs.delete(iter.world, entity);
                economy.build = economy.build + 1;
            }
        }
    }
}

pub fn init(world: *zflecs.world_t) void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Health),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Enemy),
    };

    const entity = zflecs.entity_init(world, &zflecs.entity_desc_t{
        .name = "remove_no_health_enemies",
        .add = &.{
            zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
        },
    });

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .query = query_description,
    };

    _ = zflecs.system_init(world, &system_description);
}
