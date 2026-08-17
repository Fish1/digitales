const zflecs = @import("zflecs");
const raylib = @import("raylib");
const components = @import("../components.zig");
const std = @import("std");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    var query_iter = zflecs.query_iter(iter.world, iter.query);

    while (zflecs.query_next(&query_iter) == true) {
        const position_field = zflecs.field(&query_iter, components.Position, 1) orelse continue;
        const target_field = zflecs.field(&query_iter, components.Target, 2) orelse continue;
        for (0..query_iter.count()) |tower_index| {
            const position = position_field[tower_index];
            const target = target_field[tower_index];
            if (target.current_time >= target.max_time) {
                if (target.position) |target_position| {
                    const direction = target_position.subtract(position);
                    createBullet(iter.world, position, .{
                        .direction = direction,
                        .speed = 25.0,
                    });
                }
                target_field[tower_index].current_time = 0.0;
            } else {
                target_field[tower_index].current_time += raylib.getFrameTime();
            }
        }
    }
}

fn createBullet(world: *zflecs.world_t, position: components.Position, directionMovement: components.DirectionMovement) void {
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.Bullet);
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.DirectionMovement, directionMovement);
    _ = zflecs.set(world, entity, components.Health, components.Health{
        .max = 1,
        .current = 1,
    });
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
    };

    const entity = zflecs.entity_init(world, &zflecs.entity_desc_t{
        .name = "tower_shooter",
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
