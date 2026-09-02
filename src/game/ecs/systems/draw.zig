const raylib = @import("raylib");
const zflecs = @import("zflecs");
const components = @import("../components.zig");

const std = @import("std");

const CTX = struct {
    base: *zflecs.query_t,
    layer1: *zflecs.query_t,
};

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const camera = zflecs.singleton_get(iter.world, components.Camera2D) orelse return;
    const economy = zflecs.singleton_get(iter.world, components.Economy) orelse return;

    const ctx: *CTX = @ptrCast(@alignCast(iter.ctx));
    const queries: [2]*zflecs.query_t = .{
        ctx.base,
        ctx.layer1,
    };

    raylib.beginDrawing();
    raylib.clearBackground(.black);
    raylib.beginMode2D(camera.*);

    for (queries) |query| {
        var query_iter = zflecs.query_iter(iter.world, query);
        while (zflecs.query_next(&query_iter) == true) {
            const position = zflecs.field(&query_iter, components.Position, 0) orelse continue;
            const textureField = zflecs.field(&query_iter, components.Texture, 1);
            const animationField = zflecs.field(&query_iter, components.Animation, 2);

            for (0..query_iter.count()) |entity_index| {
                const x: i32 = @intFromFloat(position[entity_index].x);
                const y: i32 = @intFromFloat(position[entity_index].y);

                if (textureField) |textures| {
                    const texture: components.Texture = textures[entity_index];
                    if (animationField) |animations| {
                        const animation: components.Animation = animations[entity_index];
                        const source = animation.getCurrentRect();
                        const destination = raylib.Rectangle{
                            .x = @floatFromInt(x),
                            .y = @floatFromInt(y),
                            .width = source.width,
                            .height = source.height,
                        };
                        texture.drawPro(source, destination, .zero(), 0, .white);
                    } else {
                        texture.draw(x, y, .white);
                    }
                } else {
                    raylib.drawRectangle(x, y, 64, 64, .green);
                }
            }
        }
    }

    var buffer: [64]u8 = undefined;
    const string = std.fmt.bufPrintSentinel(&buffer, "Economy: {any}", .{economy.build}, 0) catch unreachable;
    raylib.drawText(string, 32, 32, 64, .white);

    raylib.endMode2D();
    raylib.endDrawing();
}

pub fn init(world: *zflecs.world_t, allocator: *const std.mem.Allocator) !void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Texture),
        .oper = .Optional,
    };
    query_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Animation),
        .oper = .Optional,
    };
    query_description.terms[3] = zflecs.term_t{
        .id = zflecs.id(components.Renderable),
    };
    query_description.terms[4] = zflecs.term_t{
        .id = zflecs.id(components.DrawLayer1),
    };
    const query = zflecs.query_init(world, &query_description) catch unreachable;

    var drawlayer1Description: zflecs.query_desc_t = .{};
    drawlayer1Description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    drawlayer1Description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Texture),
        .oper = .Optional,
    };
    drawlayer1Description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Animation),
        .oper = .Optional,
    };
    drawlayer1Description.terms[3] = zflecs.term_t{
        .id = zflecs.id(components.Renderable),
    };
    drawlayer1Description.terms[4] = zflecs.term_t{
        .id = zflecs.id(components.DrawLayer1),
    };
    const drawlayer1Query = zflecs.query_init(world, &drawlayer1Description) catch unreachable;

    const entity: zflecs.entity_desc_t = .{
        .name = "draw",
        .add = &.{
            zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
        },
    };

    const ctx: *CTX = try allocator.create(CTX);
    ctx.base = query;
    ctx.layer1 = drawlayer1Query;

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = zflecs.entity_init(world, &entity),
        .ctx = ctx,
    };

    _ = zflecs.system_init(world, &system_description);
}
