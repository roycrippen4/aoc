const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/lib/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("aoc", lib_mod);
    const lib = b.addLibrary(.{ .linkage = .static, .name = "aoc", .root_module = lib_mod });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{ .name = "aoc2024", .root_module = exe_mod });
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

    const lib_unit_tests = b.addTest(.{ .root_module = lib_mod, .filters = test_filters });
    const exe_unit_tests = b.addTest(.{ .root_module = exe_mod, .filters = test_filters });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);

    const exe_check = b.addExecutable(.{ .name = "aoc2024", .root_module = exe_mod });
    const lib_check = b.addLibrary(.{ .name = "aoc", .root_module = lib_mod });
    const check = b.step("check", "Check if it compiles");
    check.dependOn(&exe_check.step);
    check.dependOn(&lib_check.step);
    check.dependOn(&run_lib_unit_tests.step);
    check.dependOn(&run_exe_unit_tests.step);
}
