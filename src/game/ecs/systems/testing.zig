const zflecs = @import("zflecs");
const components = @import("../components.zig");
const std = @import("std");

fn system1(iter: *zflecs.iter_t) callconv(.c) void {
    var tower_iter = zflecs.query_iter(iter.world, iter.query);

    while (zflecs.query_next(&tower_iter) == true) {
        const tower_target_field = zflecs.field(&tower_iter, components.Target, 1) orelse continue;
        for (0..tower_iter.count()) |tower_index| {
            const tower_target = tower_target_field[tower_index];
            std.debug.print("{any}\n", .{tower_target});
        }
    }
}

fn system2(iter: *zflecs.iter_t) callconv(.c) void {
    var tower_iter = zflecs.query_iter(iter.world, iter.query);

    while (zflecs.query_next(&tower_iter) == true) {
        for (tower_iter.entities()) |tower_entity| {
            const tower_target = zflecs.get_mut(iter.world, tower_entity, components.Target) orelse continue;
            std.debug.print("{any}\n", .{tower_target});
        }
    }
}

pub fn init(world: *zflecs.world_t) void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Tower),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Target),
    };

    const entity = zflecs.entity_init(world, &zflecs.entity_desc_t{
        .name = "testing",
        .add = &.{
            zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
        },
    });

    const system_description: zflecs.system_desc_t = .{
        .callback = system2,
        .entity = entity,
        .query = query_description,
    };

    _ = zflecs.system_init(world, &system_description);
}
