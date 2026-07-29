const std = @import("std");
const raylib = @import("raylib");
const ecs = @import("ecs.zig");

const tile_size = 64;
const camera_speed = tile_size * 8;

const Entity = struct {
    position: raylib.Vector2,

    pub fn debugDraw(self: @This()) void {
        const x: i32 = @intFromFloat(self.position.x);
        const y: i32 = @intFromFloat(self.position.y);
        raylib.drawRectangle(x, y, tile_size, tile_size, .red);
    }
};

var camera: raylib.Camera2D = .{
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
};

const bridge: Entity = std.mem.zeroes(Entity);
var enemies: std.ArrayList(Entity) = undefined;

pub fn init() !void {
    enemies = try .initCapacity(std.heap.page_allocator, 10);
    try enemies.append(std.heap.page_allocator, .{
        .position = .{
            .x = 250.0,
            .y = 2.0,
        },
    });
    for (enemies.items) |enemy| {
        std.debug.print("{}\n", .{enemy.position.y});
    }
}

pub fn deinit() !void {
    enemies.deinit(std.heap.page_allocator);
}

pub fn frame() callconv(.c) void {
    update();

    raylib.beginDrawing();
    raylib.clearBackground(.black);
    raylib.drawText("Raylib Game!", 32, 32, 32, .white);

    raylib.beginMode2D(camera);
    bridge.debugDraw();
    drawEnemies();
    raylib.endMode2D();

    raylib.endDrawing();
}

pub fn update() void {
    const delta = raylib.getFrameTime();
    updateEnemies(delta);

    if (raylib.isKeyDown(.left)) {
        camera.target.x = camera.target.x - (camera_speed * delta);
    }
    if (raylib.isKeyDown(.right)) {
        camera.target.x = camera.target.x + (camera_speed * delta);
    }
}

pub fn updateEnemies(delta: f32) void {
    for (enemies.items) |*enemy| {
        enemy.position.x = enemy.position.x - 10.0 * delta;
    }
}

pub fn drawEnemies() void {
    for (enemies.items) |*enemy| {
        enemy.debugDraw();
    }
}
