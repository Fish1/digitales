const std = @import("std");
const raylib = @import("raylib");
const zflecs = @import("zflecs");

pub const Position = raylib.Vector2;
pub const Entity = struct {};

pub fn moveSystem(positions: []Position) void {
    for (positions) |*p| {
        p.x = p.x - 1.0;
        p.y = p.y - 1.0;
    }
}

pub const Ecs = struct {
    world: zflecs.world_t,

    pub fn init() @This() {
        const world = zflecs.init();
        zflecs.COMPONENT(world, Position);
        zflecs.ADD_SYSTEM(world, "move", zflecs.OnUpdate, moveSystem);
        return .{
            .world = world,
        };
    }
};
