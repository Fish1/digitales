const std = @import("std");
const zflecs = @import("zflecs");
const raylib = @import("raylib");
const components = @import("../components.zig");

const Queries = struct {
    tileSelector: *zflecs.query_t,
    bridges: *zflecs.query_t,
};

var queries: Queries = undefined;

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const camera = zflecs.singleton_get(iter.world, components.Camera2D) orelse return;
    // var economy = zflecs.singleton_get_mut(iter.world, components.Economy) orelse return;

    const ctx = iter.ctx orelse unreachable;
    // const query: *zflecs.query_t = @ptrCast(@alignCast(ctx));
    const query: *Queries = @ptrCast(@alignCast(ctx));
    var query_iter = zflecs.query_iter(iter.world, query.tileSelector);

    const mouse_screen = raylib.getMousePosition();
    const mouse_world = raylib.getScreenToWorld2D(mouse_screen, camera.*);

    const tile_x = std.math.divFloor(f32, mouse_world.x, 64.0) catch unreachable;
    const tile_y = std.math.divFloor(f32, mouse_world.y, 64.0) catch unreachable;

    const world_x = tile_x * 64.0;
    const world_y = tile_y * 64.0;

    while (zflecs.query_next(&query_iter) == true) {
        const position = zflecs.field(&query_iter, components.Position, 0) orelse continue;
        const tile_position = zflecs.field(&query_iter, components.TilePosition, 1) orelse continue;

        for (0..query_iter.count()) |entity_index| {
            position[entity_index].x = world_x;
            position[entity_index].y = world_y;
            tile_position[entity_index].x = @intFromFloat(tile_x);
            tile_position[entity_index].y = @intFromFloat(tile_y);
        }
    }

    if (raylib.isMouseButtonPressed(.left)) {
        addBridgeBuilder(
            iter.world,
            components.Position{
                .x = world_x,
                .y = world_y,
            },
            components.TilePosition{
                .x = @intFromFloat(tile_x),
                .y = @intFromFloat(tile_y),
            },
        );
    } else if (raylib.isMouseButtonPressed(.right)) {
        var bridges_query_iter = zflecs.query_iter(iter.world, query.bridges);
        var canPlace: bool = false;
        while (zflecs.query_next(&bridges_query_iter) == true) {
            if (canPlace == true) {
                continue;
            }
            const position_field = zflecs.field(&bridges_query_iter, components.TilePosition, 1) orelse continue;
            for (0..bridges_query_iter.count()) |bridge_index| {
                const position = position_field[bridge_index];
                if (position.x == @as(i32, @intFromFloat(tile_x)) and position.y == @as(i32, @intFromFloat(tile_y))) {
                    canPlace = true;
                    break;
                }
            }
        }
        if (canPlace == true) {
            addTowerBuilder(
                iter.world,
                components.Position{
                    .x = world_x,
                    .y = world_y,
                },
                components.TilePosition{
                    .x = @intFromFloat(tile_x),
                    .y = @intFromFloat(tile_y),
                },
            );
        }
    }
}

fn addBridgeBuilder(world: *zflecs.world_t, position: components.Position, tilePosition: components.TilePosition) void {
    const textureManager = zflecs.singleton_get(world, components.TextureManager) orelse return;
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.TilePosition, tilePosition);
    _ = zflecs.set(world, entity, components.Texture, textureManager.getTexture(.BuilderSheet));
    _ = zflecs.set(world, entity, components.Animation, .init(64, 2, 0.25));
    _ = zflecs.set(world, entity, components.BridgeBuilder, components.BridgeBuilder{
        .bulidThing = .Bridge,
        .current_time = 0.0,
        .max_time = 5.0,
    });
}

fn addTowerBuilder(world: *zflecs.world_t, position: components.Position, tilePosition: components.TilePosition) void {
    const textureManager = zflecs.singleton_get(world, components.TextureManager) orelse return;
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.TilePosition, tilePosition);
    _ = zflecs.set(world, entity, components.Texture, textureManager.getTexture(.BuilderSheet));
    _ = zflecs.set(world, entity, components.Animation, .init(64, 2, 0.25));
    _ = zflecs.set(world, entity, components.BridgeBuilder, components.BridgeBuilder{
        .bulidThing = .Tower,
        .current_time = 0.0,
        .max_time = 5.0,
    });
}

fn addTileSelector(world: *zflecs.world_t) void {
    const entity = zflecs.new_entity(world, "tile selector");
    _ = zflecs.set(world, entity, components.Position, .{
        .x = 300.0,
        .y = 100.0,
    });
    _ = zflecs.set(world, entity, components.TilePosition, .{
        .x = 0,
        .y = 0,
    });
    zflecs.add(world, entity, components.Renderable);
    zflecs.add(world, entity, components.TileSelector);
}

pub fn init(world: *zflecs.world_t) void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.TilePosition),
    };
    query_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.TileSelector),
    };
    const query = zflecs.query_init(
        world,
        &query_description,
    ) catch unreachable;

    var bridge_query_description: zflecs.query_desc_t = .{};
    bridge_query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Bridge),
    };
    bridge_query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.TilePosition),
    };
    const bridge_query = zflecs.query_init(world, &bridge_query_description) catch unreachable;

    const entity = zflecs.entity_init(
        world,
        &zflecs.entity_desc_t{
            .name = "tile_selector",
            .add = &.{
                zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
            },
        },
    );

    queries.tileSelector = query;
    queries.bridges = bridge_query;

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .ctx = &queries,
    };
    _ = zflecs.system_init(world, &system_description);

    addTileSelector(world);
}
