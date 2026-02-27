const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const aoc_zlib_dependency = b.dependency("aoc", .{
        .target = target,
        .optimize = optimize,
    });

    // Data fetching step
    const setup_mod = b.addModule("setup", .{
        .root_source_file = b.path("src/setup.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "aoc",
                .module = aoc_zlib_dependency.module("aoc"),
            },
        },
    });
    const setup_exe = b.addExecutable(.{
        .root_module = setup_mod,
        .name = "setup",
    });
    const setup = b.addRunArtifact(setup_exe);

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "aoc",
                .module = aoc_zlib_dependency.module("aoc"),
            },
        },
    });

    const exe = b.addExecutable(.{
        .name = "aoc2025",
        .root_module = exe_mod,
    });
    exe.step.dependOn(&setup.step);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_filters = b.option(
        []const []const u8,
        "test-filter",
        "Skip tests that do not match any filter",
    ) orelse &.{};

    const exe_unit_tests = b.addTest(.{ .root_module = exe_mod, .filters = test_filters });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const setup_unit_tests = b.addTest(.{ .root_module = setup_mod, .filters = test_filters });
    const run_setup_unit_tests = b.addRunArtifact(setup_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
    test_step.dependOn(&run_setup_unit_tests.step);

    const exe_check = b.addExecutable(.{ .name = "aoc2024", .root_module = exe_mod });
    const setup_check = b.addExecutable(.{ .name = "setup", .root_module = setup_mod });

    const check = b.step("check", "Check if it compiles");
    check.dependOn(&exe_check.step);
    check.dependOn(&run_exe_unit_tests.step);
    check.dependOn(&setup_check.step);
}
