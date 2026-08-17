const zflecs = @import("zflecs");
const components = @import("../components.zig");
const std = @import("std");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    var bullet_iter = zflecs.query_iter(iter.world, iter.query);
    const enemy_query: *zflecs.query_t = @ptrCast(@alignCast(iter.ctx));

    while (zflecs.query_next(&bullet_iter) == true) {
        const bullet_position_field = zflecs.field(&bullet_iter, components.Position, 1) orelse continue;
        const bullet_health_field = zflecs.field(&bullet_iter, components.Health, 2) orelse continue;

        for (0..bullet_iter.count()) |bullet_index| {
            const bullet_position = bullet_position_field[bullet_index];
            const bullet_health = &bullet_health_field[bullet_index];

            if (bullet_health.current <= 0) {
                continue;
            }

            var enemy_iter = zflecs.query_iter(iter.world, enemy_query);
            while (zflecs.query_next(&enemy_iter) == true) {
                const enemy_position_field = zflecs.field(&enemy_iter, components.Position, 1) orelse continue;
                const enemy_health_field = zflecs.field(&enemy_iter, components.Health, 2) orelse continue;

                for (0..enemy_iter.count()) |enemy_index| {
                    const enemy_position = enemy_position_field[enemy_index];
                    var enemy_health = &enemy_health_field[enemy_index];

                    if (enemy_position.distance(bullet_position) <= 64.0) {
                        enemy_health.current = enemy_health.current - 1;
                        bullet_health.current = bullet_health.current - 1;
                        std.debug.print("{any} {any}\n", .{ enemy_health, bullet_health });
                    }
                }
            }
        }
    }
}

pub fn init(world: *zflecs.world_t) void {
    var bullet_description: zflecs.query_desc_t = .{};
    bullet_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Bullet),
    };
    bullet_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    bullet_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Health),
    };

    var enemy_description: zflecs.query_desc_t = .{};
    enemy_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Enemy),
    };
    enemy_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    enemy_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Health),
    };
    const enemy_query = zflecs.query_init(world, &enemy_description) catch unreachable;

    const entity = zflecs.entity_init(world, &zflecs.entity_desc_t{
        .name = "bullet_collider",
        .add = &.{
            zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
        },
    });

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .query = bullet_description,
        .ctx = enemy_query,
    };

    _ = zflecs.system_init(world, &system_description);
}
