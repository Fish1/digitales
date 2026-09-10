const zflecs = @import("zflecs");
const raylib = @import("raylib");
const components = @import("../components.zig");

fn system(iter: *zflecs.iter_t, positions: []const components.Position, targets: []components.Target) void {
    const texture_manager = zflecs.singleton_get(iter.world, components.TextureManager) orelse return;
    const bullet_texture = texture_manager.getTexture(.Bullet);
    const dt = raylib.getFrameTime();

    for (positions, targets) |position, *target| {
        if (target.current_time < target.max_time) {
            target.current_time += dt;
            continue;
        }
        target.current_time = 0.0;

        const target_position = target.position orelse continue;
        createBullet(iter.world, position, .{
            .direction = target_position.subtract(position),
            .speed = 25.0,
        }, bullet_texture);
    }
}

fn createBullet(world: *zflecs.world_t, position: components.Position, directionMovement: components.DirectionMovement, texture: components.Texture) void {
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.Bullet);
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.DirectionMovement, directionMovement);
    _ = zflecs.set(world, entity, components.Health, components.Health{
        .max = 1,
        .current = 1,
    });
    _ = zflecs.set(world, entity, components.Texture, texture);
}

pub fn init(world: *zflecs.world_t) void {
    _ = zflecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "tower_shooter",
        zflecs.OnUpdate,
        system,
        &.{
            .{ .id = zflecs.id(components.Tower) },
        },
    );
}
