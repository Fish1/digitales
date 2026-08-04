const std = @import("std");

const zflecs = @import("zflecs");
const raylib = @import("raylib");
const components = @import("../components.zig");

fn system(iter: *zflecs.iter_t) void {
    var camera = zflecs.singleton_get_mut(iter.world, components.Camera2D) orelse return;

    if (raylib.isKeyPressed(.space)) {
        addEnemy(iter.world);
    }

    if (raylib.isKeyDown(.right)) {
        camera.target.x = camera.target.x + 1.0;
    }

    if (raylib.isKeyDown(.left)) {
        camera.target.x = camera.target.x - 1.0;
    }
}

fn addEnemy(world: *zflecs.world_t) void {
    const entity = zflecs.new_entity(world, "");
    _ = zflecs.set(world, entity, components.Position, .{
        .x = 500.0,
        .y = 0.0,
    });
    zflecs.add(world, entity, components.Renderable);
}

pub fn init(world: *zflecs.world_t) void {
    _ = zflecs.ADD_SYSTEM(world, "", zflecs.PreUpdate, system);
}
