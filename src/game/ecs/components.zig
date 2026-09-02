const raylib = @import("raylib");
const texture = @import("../managers/texture.zig");
const animation = @import("../managers/animation.zig");

// ** TAGS **
pub const Renderable = struct {};
pub const TileSelector = struct {};
pub const Bridge = struct {};
pub const Enemy = struct {};
pub const EnemySpawner = struct {};
pub const Tower = struct {};
pub const Bullet = struct {};

pub const DrawLayer1 = struct {};
pub const DrawLayer2 = struct {};
pub const DrawLayer3 = struct {};

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
pub const TextureManager = texture.TextureManager;
pub const Animation = animation.Animation;

const BuildThing = enum {
    Bridge,
    Tower,
};
pub const BridgeBuilder = struct {
    bulidThing: BuildThing,
    max_time: f32,
    current_time: f32,
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
