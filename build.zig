const std = @import("std");
const rlz = @import("raylib_zig");
const emsdk = rlz.emsdk;

pub fn build(b: *std.Build) !void {
    // const wasm32_target = comptime std.Target.Query.parse(.{
    //    .arch_os_abi = "wasm32-emscripten",
    //}) catch unreachable;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = .Wayland,
    });
    const raylib_module = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const box2d_dep = b.dependency("box2d_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const box2d_module = box2d_dep.module("box2d");

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    root_module.addImport("raylib", raylib_module);
    root_module.addImport("box2d", box2d_module);

    if (target.result.cpu.arch.isWasm()) {
        const wasm = b.addLibrary(.{
            .name = "raylib",
            .root_module = root_module,
        });

        const install_dir: std.Build.InstallDir = .{ .custom = "web" };
        const emcc_flags = emsdk.emccDefaultFlags(
            b.allocator,
            .{ .optimize = optimize },
        );
        const emcc_settings = emsdk.emccDefaultSettings(
            b.allocator,
            .{ .optimize = optimize },
        );

        const emcc_step = emsdk.emccStep(b, raylib_artifact, wasm, .{
            .optimize = optimize,
            .flags = emcc_flags,
            .settings = emcc_settings,
            .install_dir = install_dir,
        });
        b.getInstallStep().dependOn(emcc_step);

        const html_filename = try std.fmt.allocPrint(b.allocator, "{s}.html", .{wasm.name});
        const emrun_step = emsdk.emrunStep(
            b,
            b.getInstallPath(install_dir, html_filename),
            &.{},
        );

        const run_step = b.step("run", "Run the application.");
        emrun_step.dependOn(emcc_step);
        run_step.dependOn(emrun_step);
    } else {
        const exe = b.addExecutable(.{
            .name = "raylib",
            .root_module = root_module,
        });
        b.installArtifact(exe);

        const run_step = b.step("run", "Run the application.");
        const run_cmd = b.addRunArtifact(exe);
        run_step.dependOn(&run_cmd.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }
}
