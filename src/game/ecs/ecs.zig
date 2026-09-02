const std = @import("std");
const raylib = @import("raylib");
const zflecs = @import("zflecs");

const components = @import("components.zig");

const tileSelector = @import("systems/tile_selector.zig");
const bridgeBuilder = @import("systems/bridge_builder.zig");
const enemySpawner = @import("systems/enemy_spawner.zig");
const input = @import("systems/input.zig");
const move = @import("systems/move.zig");
const draw = @import("systems/draw.zig");
const enemy = @import("systems/enemy.zig");
const towerTargeter = @import("systems/tower_targeter.zig");
const towerShooter = @import("systems/tower_shooter.zig");
const directionMovement = @import("systems/direction_movement.zig");
const bulletEnemyCollision = @import("systems/bullet_enemy_collision.zig");
const removeNoHealth = @import("systems/remove_no_health.zig");
const removeNoHealthEnemies = @import("systems/remove_no_health_enemies.zig");
const updateAnimations = @import("systems/update_animations.zig");

const testing = @import("systems/testing.zig");

pub const World = *zflecs.world_t;

pub fn initWorld(allocator: *const std.mem.Allocator) *zflecs.world_t {
    const world = zflecs.init();
    zflecs.COMPONENT(world, components.Position);
    zflecs.COMPONENT(world, components.Camera2D);
    zflecs.COMPONENT(world, components.TextureManager);
    zflecs.COMPONENT(world, components.TilePosition);
    zflecs.COMPONENT(world, components.Texture);
    zflecs.COMPONENT(world, components.BridgeBuilder);
    zflecs.COMPONENT(world, components.Timer);
    zflecs.COMPONENT(world, components.Target);
    zflecs.COMPONENT(world, components.DirectionMovement);
    zflecs.COMPONENT(world, components.Health);
    zflecs.COMPONENT(world, components.Economy);
    zflecs.COMPONENT(world, components.Animation);

    zflecs.TAG(world, components.Renderable);
    zflecs.TAG(world, components.TileSelector);
    zflecs.TAG(world, components.Bridge);
    zflecs.TAG(world, components.Enemy);
    zflecs.TAG(world, components.Tower);
    zflecs.TAG(world, components.EnemySpawner);
    zflecs.TAG(world, components.Bullet);

    tileSelector.init(world);
    bridgeBuilder.init(world, allocator) catch unreachable;
    enemySpawner.init(world);
    towerTargeter.init(world);
    towerShooter.init(world);
    directionMovement.init(world);
    bulletEnemyCollision.init(world);
    removeNoHealth.init(world);
    removeNoHealthEnemies.init(world);
    updateAnimations.init(world);
    // testing.init(world);

    enemy.init(world);
    input.init(world);
    draw.init(world, allocator) catch unreachable;

    initEconomy(world);
    initCamera(world);
    initTextures(world);

    addEnemySpawner(world, components.Position{
        .x = 600.0,
        .y = 300.0,
    });
    addEnemySpawner(world, components.Position{
        .x = 800.0,
        .y = 400.0,
    });

    return world;
}

pub fn deinitWorld(world: *zflecs.world_t) void {
    _ = zflecs.fini(world);
}

pub fn progressWorld(world: *zflecs.world_t, delta: f32) void {
    _ = zflecs.progress(world, delta);
}

fn addEnemySpawner(world: *zflecs.world_t, position: components.Position) void {
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.EnemySpawner);
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.Timer, components.Timer{
        .current_time = 0.0,
        .max_time = 2.5,
    });
}

fn initCamera(world: *zflecs.world_t) void {
    zflecs.add_id(world, zflecs.id(components.Camera2D), zflecs.Singleton);
    _ = zflecs.singleton_set(
        world,
        components.Camera2D,
        .{
            .offset = .{
                .x = 0,
                .y = 0,
            },
            .target = .{
                .x = 0,
                .y = 0,
            },
            .rotation = 0.0,
            .zoom = 0.5,
        },
    );
}

fn initTextures(world: *zflecs.world_t) void {
    zflecs.add_id(world, zflecs.id(components.TextureManager), zflecs.Singleton);
    _ = zflecs.singleton_set(
        world,
        components.TextureManager,
        components.TextureManager.init(std.heap.page_allocator) catch unreachable,
    );
}

fn initEconomy(world: *zflecs.world_t) void {
    zflecs.add_id(world, zflecs.id(components.Economy), zflecs.Singleton);
    _ = zflecs.singleton_set(
        world,
        components.Economy,
        components.Economy{
            .build = 15,
        },
    );
}
