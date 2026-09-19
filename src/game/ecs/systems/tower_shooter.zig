const zflecs = @import("zflecs");
const raylib = @import("raylib");
const components = @import("../components.zig");

fn system(iter: *zflecs.iter_t, positions: []components.Position, targets: []components.Target) void {
    const delta = raylib.getFrameTime();
    for (0..iter.count()) |index| {
        targets[index].current_time = targets[index].current_time + delta;
        if (targets[index].current_time < targets[index].max_time) {
            continue;
        }
        const position = positions[index];
        const target = targets[index];
        const target_position = target.position orelse continue;

        const direction = target_position.subtract(position);
        createBullet(iter.world, position, .{
            .direction = direction,
            .speed = 25.0,
        });

        targets[index].current_time = 0.0;
    }
}

fn createBullet(world: *zflecs.world_t, position: components.Position, directionMovement: components.DirectionMovement) void {
    const entity = zflecs.new_entity(world, "");
    const textureManager = zflecs.singleton_get(world, components.TextureManager) orelse return;
    zflecs.add(world, entity, components.Bullet);
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.DirectionMovement, directionMovement);
    _ = zflecs.set(world, entity, components.Health, components.Health{
        .max = 1,
        .current = 1,
    });
    _ = zflecs.set(world, entity, components.Texture, textureManager.getTexture(.Bullet));
}

pub fn init(world: *zflecs.world_t) void {
    _ = zflecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "tower shooter",
        zflecs.OnUpdate,
        system,
        &.{
            zflecs.term_t{
                .id = zflecs.id(components.Tower),
            },
        },
    );
}
