const zflecs = @import("zflecs");
const components = @import("../components.zig");

const std = @import("std");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    var query_iter = zflecs.query_iter(iter.world, iter.query);

    const enemy_query: *zflecs.query_t = @ptrCast(@alignCast(iter.ctx));

    while (zflecs.query_next(&query_iter) == true) {
        const tower_position_field = zflecs.field(&query_iter, components.Position, 1) orelse continue;
        const tower_target_position_field = zflecs.field(&query_iter, components.Target, 2) orelse continue;

        for (0..query_iter.count()) |tower_index| {
            const tower_position = tower_position_field[tower_index];
            // var tower_target_position = tower_target_position_field[tower_index];

            var close_position: ?components.Position = null;
            var close_distance: ?f32 = null;

            var enemy_query_iter = zflecs.query_iter(iter.world, enemy_query);
            while (zflecs.query_next(&enemy_query_iter) == true) {
                const enemy_position_field = zflecs.field(&enemy_query_iter, components.Position, 1) orelse continue;

                for (0..enemy_query_iter.count()) |enemy_index| {
                    const enemy_position = enemy_position_field[enemy_index];
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
            }

            tower_target_position_field[tower_index].position = close_position;
        }
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
