const std = @import("std");
const raylib = @import("raylib");
const ecs = @import("ecs/ecs.zig");
const textures = @import("textures.zig");

const tile_size = 64;
const camera_speed = tile_size * 8;

var world: ecs.World = undefined;

pub fn init() !void {
    world = ecs.initWorld();
}

pub fn deinit() !void {
    ecs.deinitWorld(world);
}

pub fn frame() callconv(.c) void {
    const delta = raylib.getFrameTime();
    ecs.progressWorld(world, delta);
}
