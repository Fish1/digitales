const raylib = @import("raylib");

pub const Renderable = struct {};
pub const TileSelector = struct {};
pub const Bridge = struct {};
pub const BridgeBuilder = struct {};

pub const Position = raylib.Vector2;
pub const Camera2D = raylib.Camera2D;

pub const TilePosition = struct {
    x: i32,
    y: i32,
};
