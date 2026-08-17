const std = @import("std");
const raylib = @import("raylib");

pub const Textures = enum {
    // Bridge,
    Tower,
    Enemy,
};

pub const TextureManager = struct {
    data: std.AutoHashMap(Textures, raylib.Texture),

    pub fn init(allocator: std.mem.Allocator) !@This() {
        var data: std.AutoHashMap(Textures, raylib.Texture) = .init(allocator);

        const tower = try raylib.loadTexture("./assets/export/tower.png");
        try data.put(.Tower, tower);

        const enemy = try raylib.loadTexture("./assets/export/enemy.png");
        try data.put(.Enemy, enemy);

        return .{
            .data = data,
        };
    }
};
