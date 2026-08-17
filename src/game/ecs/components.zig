const raylib = @import("raylib");
const textures = @import("../textures.zig");

// ** TAGS **
pub const Renderable = struct {};
pub const TileSelector = struct {};
pub const Bridge = struct {};
pub const Enemy = struct {};
pub const EnemySpawner = struct {};
pub const Tower = struct {};
pub const Bullet = struct {};

// ** COMPONENTS **
pub const Economy = struct {
    build: i32,
};
pub const Camera2D = raylib.Camera2D;
pub const TilePosition = struct {
    x: i32,
    y: i32,
};
pub const Timer = struct {
    max_time: f32,
    current_time: f32,
};
pub const Texture = raylib.Texture2D;
pub const TextureManager = textures.TextureManager;

const BuildThing = enum {
    Bridge,
    Tower,
};
pub const BridgeBuilder = struct {
    bulidThing: BuildThing,
};

pub const Position = raylib.Vector2;

pub const Target = struct {
    position: ?raylib.Vector2,
    max_time: f32,
    current_time: f32,
};

pub const DirectionMovement = struct {
    direction: raylib.Vector2,
    speed: f32,
};

pub const Health = struct {
    max: i32,
    current: i32,
};
