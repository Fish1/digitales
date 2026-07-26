const std = @import("std");

var log_buf: [1024]u8 = undefined;

pub fn logFn(
    comptime message_level: std.log.Level,
    comptime scope: @EnumLiteral(),
    comptime format: []const u8,
    args: anytype,
) void {
    var writer: std.Io.Writer = .fixed(&log_buf);
    writeLevelScope(&writer, message_level.asText(), if (scope == .default) null else @tagName(scope)) catch {
        @branchHint(.unlikely);
        return;
    };
    writer.print(format, args) catch {
        @branchHint(.unlikely);
        return;
    };
    writer.writeByte(0) catch {
        @branchHint(.unlikely);
        return;
    };
    const written: [*:0]const u8 = @ptrCast(writer.buffered().ptr);
    switch (message_level) {
        .err => emscripten_err(written),
        .warn, .info, .debug => emscripten_out(written),
    }
}

fn writeLevelScope(writer: *std.Io.Writer, level: []const u8, scope: ?[]const u8) !void {
    try writer.writeAll(level);
    if (scope) |scope_| {
        try writer.print("({s})", .{scope_});
    }
    try writer.writeAll(": ");
}

extern fn emscripten_out(text: [*:0]const u8) void;
extern fn emscripten_err(text: [*:0]const u8) void;
