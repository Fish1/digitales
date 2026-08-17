const zflecs = @import("zflecs");
const components = @import("../components.zig");
const raylib = @import("raylib");

const std = @import("std");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const query: *zflecs.query_t = @ptrCast(@alignCast(iter.ctx));
    const delta = raylib.getFrameTime();

    var query_iter = zflecs.query_iter(iter.world, query);

    while (zflecs.query_next(&query_iter) == true) {
        const field_position = zflecs.field(&query_iter, components.Position, 1) orelse continue;
        const timer = zflecs.field(&query_iter, components.Timer, 2) orelse continue;
        for (0..query_iter.count()) |entity_index| {
            const position = field_position[entity_index];
            timer[entity_index].current_time = timer[entity_index].current_time + delta;
            if (timer[entity_index].current_time >= timer[entity_index].max_time) {
                timer[entity_index].current_time = 0;
                addEnemy(iter.world, position);
            }
        }
    }
}

pub fn addEnemy(world: *zflecs.world_t, position: components.Position) void {
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.Enemy);
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    const texture_manager = zflecs.singleton_get(world, components.TextureManager) orelse return;
    const texture = texture_manager.data.get(.Enemy) orelse unreachable;
    _ = zflecs.set(
        world,
        entity,
        components.Texture,
        texture,
    );
    const health: components.Health = .{
        .current = 10,
        .max = 10,
    };
    _ = zflecs.set(
        world,
        entity,
        components.Health,
        health,
    );
}

pub fn init(world: *zflecs.world_t) void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.EnemySpawner),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    query_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Timer),
    };
    const query = zflecs.query_init(
        world,
        &query_description,
    ) catch unreachable;

    const entity = zflecs.entity_init(
        world,
        &zflecs.entity_desc_t{
            .name = "enemy_selector",
            .add = &.{
                zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
            },
        },
    );

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .ctx = query,
    };

    _ = zflecs.system_init(world, &system_description);
}
