const std = @import("std");
const zflecs = @import("zflecs");
const raylib = @import("raylib");
const components = @import("../components.zig");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const camera = zflecs.singleton_get(iter.world, components.Camera2D) orelse return;

    const ctx = iter.ctx orelse unreachable;
    const query: *zflecs.query_t = @ptrCast(@alignCast(ctx));
    var query_iter = zflecs.query_iter(iter.world, query);

    const mouse_screen = raylib.getMousePosition();
    const mouse_world = raylib.getScreenToWorld2D(mouse_screen, camera.*);

    const tile_x = std.math.divFloor(f32, mouse_world.x, 32.0) catch unreachable;
    const tile_y = std.math.divFloor(f32, mouse_world.y, 32.0) catch unreachable;

    const world_x = tile_x * 32.0;
    const world_y = tile_y * 32.0;

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
        addBridge(
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

fn addBridge(world: *zflecs.world_t, position: components.Position, tilePosition: components.TilePosition) void {
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.BridgeBuilder);
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.TilePosition, tilePosition);
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

    const entity = zflecs.entity_init(
        world,
        &zflecs.entity_desc_t{
            .name = "tile_selector",
            .add = &.{
                zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
            },
        },
    );

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .ctx = query,
    };
    _ = zflecs.system_init(world, &system_description);

    addTileSelector(world);
}
