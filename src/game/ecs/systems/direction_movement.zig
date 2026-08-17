const zflecs = @import("zflecs");
const components = @import("../components.zig");
const std = @import("std");

fn system(positions: []components.Position, directions: []components.DirectionMovement) void {
    const length = positions.len;
    for (0..length) |index| {
        positions[index] = positions[index].add(
            directions[index].direction.normalize().scale(
                directions[index].speed,
            ),
        );
    }
}

pub fn init(world: *zflecs.world_t) void {
    _ = zflecs.ADD_SYSTEM(world, "move_direction", zflecs.OnUpdate, system);
}
