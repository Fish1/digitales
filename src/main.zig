const std = @import("std");
const raylib = @import("raylib");
const builtin = @import("builtin");

pub const is_web = builtin.cpu.arch.isWasm();

pub const std_options: std.Options = if (is_web) .{
    .networking = false,
    .logFn = @import("web_log.zig").logFn,
} else .{};

pub const panic = if (is_web) std.debug.no_panic else std.debug.FullPanic(std.debug.defaultPanic);
pub const main = if (is_web) web_main else native_main;

const screen_width = 800;
const screen_height = 450;
const target_fps = 60;
const title = "Raylib Game!";

pub fn web_main() !void {
    raylib.initWindow(screen_width, screen_height, title);
    std.os.emscripten.emscripten_set_main_loop(frame, target_fps, 0);
}

pub fn native_main() !void {
    raylib.initWindow(screen_width, screen_height, "Raylib Game!");
    defer raylib.closeWindow();
    raylib.setTargetFPS(target_fps);

    while (raylib.windowShouldClose() == false) {
        frame();
    }
}

fn frame() callconv(.c) void {
    raylib.beginDrawing();
    raylib.clearBackground(.black);
    raylib.drawText("Raylib Game!", 32, 32, 32, .white);
    raylib.endDrawing();
}
