const raylib = @import("raylib");
const zflecs = @import("zflecs");
const components = @import("../components.zig");

const std = @import("std");

fn system(iter: *zflecs.iter_t) callconv(.c) void {
    const camera = zflecs.singleton_get(iter.world, components.Camera2D) orelse return;
    const economy = zflecs.singleton_get(iter.world, components.Economy) orelse return;

    const ctx = iter.ctx orelse unreachable;
    const query: *zflecs.query_t = @ptrCast(@alignCast(ctx));
    var query_iter = zflecs.query_iter(iter.world, query);

    raylib.beginDrawing();
    raylib.clearBackground(.black);

    raylib.beginMode2D(camera.*);

    while (zflecs.query_next(&query_iter) == true) {
        const position = zflecs.field(&query_iter, components.Position, 0) orelse continue;
        const texture = zflecs.field(&query_iter, components.Texture, 2);

        for (0..query_iter.count()) |entity_index| {
            const x: i32 = @intFromFloat(position[entity_index].x);
            const y: i32 = @intFromFloat(position[entity_index].y);

            if (texture) |tex| {
                const t: components.Texture = tex[entity_index];
                t.draw(x, y, .white);
            } else {
                raylib.drawRectangle(x, y, 64, 64, .green);
            }
        }
    }

    var buffer: [64]u8 = undefined;
    const string = std.fmt.bufPrintSentinel(&buffer, "Economy: {any}", .{economy.build}, 0) catch unreachable;
    raylib.drawText(string, 32, 32, 64, .white);

    raylib.endMode2D();
    raylib.endDrawing();
}

pub fn init(world: *zflecs.world_t) void {
    var query_description: zflecs.query_desc_t = .{};
    query_description.terms[0] = zflecs.term_t{
        .id = zflecs.id(components.Position),
    };
    query_description.terms[1] = zflecs.term_t{
        .id = zflecs.id(components.Renderable),
    };
    query_description.terms[2] = zflecs.term_t{
        .id = zflecs.id(components.Texture),
        .oper = .Optional,
    };
    const query = zflecs.query_init(world, &query_description) catch unreachable;

    const entity: zflecs.entity_desc_t = .{
        .name = "draw",
        .add = &.{
            zflecs.pair(zflecs.DependsOn, zflecs.OnUpdate),
        },
    };

    const system_description: zflecs.system_desc_t = .{
        .callback = system,
        .entity = zflecs.entity_init(world, &entity),
        .ctx = query,
    };

    _ = zflecs.system_init(world, &system_description);
}
