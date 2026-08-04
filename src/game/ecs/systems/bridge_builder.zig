const zflecs = @import("zflecs");
const components = @import("../components.zig");

const std = @import("std");

var gctx: struct {
    builder_query: *zflecs.query_t,
    bridge_query: *zflecs.query_t,
} = .{
    .builder_query = undefined,
    .bridge_query = undefined,
};

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const ctx = iter.ctx orelse unreachable;
    const queries: *struct {
        builder_query: *zflecs.query_t,
        bridge_query: *zflecs.query_t,
    } = @ptrCast(@alignCast(ctx));

    var builder_iter = zflecs.query_iter(iter.world, queries.builder_query);
    while (zflecs.query_next(&builder_iter) == true) {
        const tile_position = zflecs.field(&builder_iter, components.TilePosition, 1) orelse continue;
        for (0..builder_iter.count()) |builder_entity_index| {
            var skipBuild = false;
            var bridge_iter = zflecs.query_iter(iter.world, queries.bridge_query);
            while (zflecs.query_next(&bridge_iter) == true) {
                const bridge_tile_position = zflecs.field(&bridge_iter, components.TilePosition, 1) orelse continue;

                for (0..bridge_iter.count()) |bridge_entity_index| {
                    const builder_x = tile_position[builder_entity_index].x;
                    const bridge_x = bridge_tile_position[bridge_entity_index].x;
                    const builder_y = tile_position[builder_entity_index].y;
                    const bridge_y = bridge_tile_position[bridge_entity_index].y;
                    if (builder_x == bridge_x and builder_y == bridge_y) {
                        skipBuild = true;
                    }
                    std.debug.print("builder = {} , bridge = {}\n", .{
                        builder_entity_index,
                        bridge_entity_index,
                    });
                }
            }

            const entity = builder_iter.entities()[builder_entity_index];
            zflecs.delete(iter.world, entity);
            const p: components.Position = .{
                .x = @floatFromInt(tile_position[builder_entity_index].x * 32),
                .y = @floatFromInt(tile_position[builder_entity_index].y * 32),
            };
            if (skipBuild == false) {
                addBridge(
                    iter.world,
                    p,
                    tile_position[builder_entity_index],
                );
            }
        }
    }
}

fn addBridge(world: *zflecs.world_t, position: components.Position, tilePosition: components.TilePosition) void {
    const entity = zflecs.new_entity(world, "");
    zflecs.add(world, entity, components.Bridge);
    zflecs.add(world, entity, components.Renderable);
    _ = zflecs.set(world, entity, components.Position, position);
    _ = zflecs.set(world, entity, components.TilePosition, tilePosition);
}

pub fn init(world: *zflecs.world_t) void {
    var builder_description: zflecs.query_desc_t = .{};
    builder_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.BridgeBuilder),
    };
    builder_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.TilePosition),
    };
    builder_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    const builder_query = zflecs.query_init(
        world,
        &builder_description,
    ) catch unreachable;

    // UNCOMMENT THIS LINE TO FIX
    // builder_query.cache_kind = .QueryCacheDefault;

    std.debug.print("{} \n", .{builder_query});

    var bridge_query_description: zflecs.query_desc_t = .{
        .cache_kind = .QueryCacheNone,
    };
    bridge_query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Bridge),
    };
    bridge_query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.TilePosition),
    };
    const bridge_query = zflecs.query_init(
        world,
        &bridge_query_description,
    ) catch unreachable;

    std.debug.print("{} \n", .{bridge_query});

    const entity = zflecs.entity_init(
        world,
        &zflecs.entity_desc_t{
            .name = "",
            .add = &.{
                zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
            },
        },
    );

    gctx.bridge_query = bridge_query;
    gctx.builder_query = builder_query;

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = entity,
        .ctx = &gctx,
    };
    _ = zflecs.system_init(world, &system_description);
}
