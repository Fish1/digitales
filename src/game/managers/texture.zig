const std = @import("std");
const raylib = @import("raylib");

pub const Textures = enum {
    RedBridge,
    Tower,
    Enemy,
    Bullet,
    Builder,
    BuilderSheet,
};

pub const TextureManager = struct {
    data: std.AutoHashMap(Textures, raylib.Texture),

    pub fn init(allocator: std.mem.Allocator) !@This() {
        var data: std.AutoHashMap(Textures, raylib.Texture) = .init(allocator);

        const tower = try raylib.loadTexture("./assets/export/tower.png");
        try data.put(.Tower, tower);

        const enemy = try raylib.loadTexture("./assets/export/enemy.png");
        try data.put(.Enemy, enemy);

        const bullet = try raylib.loadTexture("./assets/export/bullet.png");
        try data.put(.Bullet, bullet);

        const red_bridge = try raylib.loadTexture("./assets/export/red_bridge.png");
        try data.put(.RedBridge, red_bridge);

        const builder = try raylib.loadTexture("./assets/export/builder.gif");
        try data.put(.Builder, builder);

        const builderSheet = try raylib.loadTexture("./assets/export/builder-Sheet.png");
        try data.put(.BuilderSheet, builderSheet);

        return .{
            .data = data,
        };
    }

    pub fn getTexture(self: *const TextureManager, texture: Textures) raylib.Texture {
        return self.data.get(texture) orelse unreachable;
    }
};
