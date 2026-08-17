const zflecs = @import("zflecs");
const components = @import("../components.zig");
const std = @import("std");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const query = iter.query;
    var query_iter = zflecs.query_iter(iter.world, query);

    while (zflecs.query_next(&query_iter) == true) {
        const position = zflecs.field(&query_iter, components.Position, 1) orelse continue;

        for (0..query_iter.count()) |entity_index| {
            position[entity_index].x = position[entity_index].x - 1.0;
        }
    }
}

pub fn init(world: *zflecs.world_t) void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Enemy),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };

    const entity = zflecs.entity_init(
        world,
        &zflecs.entity_desc_t{
            .name = "enemy",
            .add = &.{
                zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
            },
        },
    );

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .query = query_description,
    };

    _ = zflecs.system_init(world, &system_description);
}
