const raylib = @import("raylib");
const std = @import("std");

pub const Animation = struct {
    frame: i32,
    max_frames: i32,

    current_time: f32,
    max_time: f32,

    width: i32,

    pub fn init(width: i32, frames: i32, speed: f32) @This() {
        return .{
            .frame = 0,
            .max_frames = frames,
            .current_time = 0.0,
            .max_time = speed,
            .width = width,
        };
    }

    pub fn getCurrentRect(self: @This()) raylib.Rectangle {
        const current_x: f32 = @floatFromInt(self.width * self.frame);
        const width: f32 = @floatFromInt(self.width);
        const rectangle: raylib.Rectangle = .{
            .x = current_x,
            .y = 0.0,
            .width = width,
            .height = width,
        };
        return rectangle;
    }

    pub fn update(self: *@This(), delta: f32) void {
        self.current_time = self.current_time + delta;
        if (self.current_time >= self.max_time) {
            self.frame = @mod(self.frame + 1, self.max_frames);
            self.current_time = 0;
        }
    }
};
