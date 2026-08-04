const std = @import("std");
const raylib = @import("raylib");
const zflecs = @import("zflecs");

const components = @import("components.zig");

const tileSelector = @import("systems/tile_selector.zig");
const bridgeBuilder = @import("systems/bridge_builder.zig");
const input = @import("systems/input.zig");
const move = @import("systems/move.zig");
const draw = @import("systems/draw.zig");

pub const World = *zflecs.world_t;

pub fn initWorld() *zflecs.world_t {
    const world = zflecs.init();
    zflecs.COMPONENT(world, components.Position);
    zflecs.COMPONENT(world, components.Camera2D);
    zflecs.COMPONENT(world, components.TilePosition);

    zflecs.TAG(world, components.Renderable);
    zflecs.TAG(world, components.TileSelector);
    zflecs.TAG(world, components.Bridge);
    zflecs.TAG(world, components.BridgeBuilder);

    tileSelector.init(world);
    bridgeBuilder.init(world);
    input.init(world);
    draw.init(world);

    initCamera(world);
    return world;
}

pub fn deinitWorld(world: *zflecs.world_t) void {
    _ = zflecs.fini(world);
}

pub fn progressWorld(world: *zflecs.world_t, delta: f32) void {
    _ = zflecs.progress(world, delta);
}

fn initCamera(world: *zflecs.world_t) void {
    zflecs.add_id(world, zflecs.id(components.Camera2D), zflecs.Singleton);
    _ = zflecs.singleton_set(world, components.Camera2D, .{
        .offset = .{
            .x = 0,
            .y = 0,
        },
        .target = .{
            .x = 0,
            .y = 0,
        },
        .rotation = 0.0,
        .zoom = 1.0,
    });
}
