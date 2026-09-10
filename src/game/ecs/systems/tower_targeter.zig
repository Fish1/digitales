const zflecs = @import("zflecs");
const components = @import("../components.zig");

const std = @import("std");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const enemy_query: *zflecs.query_t = @ptrCast(@alignCast(iter.ctx));

    const positions = zflecs.field(iter, components.Position, 1) orelse return;
    var targets = zflecs.field(iter, components.Target, 2) orelse return;

    for (positions[0..iter.count()], targets[0..iter.count()], 0..) |tower_position, _, index| {
        var enemy_iter = zflecs.query_iter(iter.world, enemy_query);
        var enemy_positions = zflecs.field(&enemy_iter, components.Position, 1) orelse return;

        var close_position: ?components.Position = null;
        var close_distance: ?f32 = null;

        for (enemy_positions[0..enemy_iter.count()]) |enemy_position| {
            const distance = tower_position.distanceSqr(enemy_position);

            if (close_distance) |cd| {
                if (distance <= cd) {
                    close_position = enemy_position;
                    close_distance = distance;
                }
            } else {
                close_position = enemy_position;
                close_distance = distance;
            }
        }

        targets[index].position = close_position;
    }
}

pub fn init(world: *zflecs.world_t) void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Tower),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    query_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Target),
        .inout = .Out,
    };

    var enemy_query_description: zflecs.query_desc_t = .{};
    enemy_query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Enemy),
    };
    enemy_query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    const enemy_query = zflecs.query_init(world, &enemy_query_description) catch unreachable;

    const entity = zflecs.entity_init(world, &zflecs.entity_desc_t{
        .name = "tower_targeter",
        .add = &.{
            zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
        },
    });

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .query = query_description,
        .ctx = enemy_query,
    };

    _ = zflecs.system_init(world, &system_description);
}
