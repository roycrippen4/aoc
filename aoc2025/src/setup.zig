const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const Allocator = mem.Allocator;
const fs = std.fs;
const File = fs.File;
const Client = std.http.Client;
const Writer = std.io.Writer;
const Reader = std.io.Reader;

const aoc = @import("aoc");
const Day = aoc.Day;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    fs.cwd().makeDir("src/data") catch |e| switch (e) {
        error.PathAlreadyExists => {},
        else => return e,
    };

    var buf: [256]u8 = undefined;
    try make_session_cookie(&buf);
    const cookie = try std.fs.cwd().readFileAlloc(allocator, "src/data/session.txt", 64 * 1024);
    defer allocator.free(cookie);

    var client: Client = .{ .allocator = allocator };
    defer client.deinit();

    var response_buf: [64 * 1024]u8 = undefined;

    for (std.enums.values(Day), 1..) |day, i| {
        if (i == 13) break;

        const path = day.to_filepath();
        if (file_exists(path)) {
            continue;
        }

        const data = try fetch_input_data(&response_buf, &client, day, cookie);
        try create_data_file(path, data);
    }
}

/// Exit the program with a failure code
fn abort(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.print(fmt, args);
    std.process.exit(1);
}

pub fn make_session_cookie(buf: []u8) !void {
    const cwd = fs.cwd();
    const session_cookie_raw = cwd.readFile("src/data/session.txt", buf) catch try handle_missing_file(buf);
    const session_cookie = mem.trim(u8, session_cookie_raw, " \n\r");

    if (session_cookie.len != 136) {
        std.debug.print("session.txt is invalid. Deleting..\n", .{});
        cwd.deleteFile("src/data/session.txt") catch {};
        abort("Invalid session.txt deleted\nRun `zig build` recreate it\n", .{});
    }
}

pub fn handle_missing_file(buf: []u8) ![]u8 {
    var stdin_buf: [256]u8 = undefined;
    var stdin_reader = File.stdin().reader(&stdin_buf);
    const stdin = &stdin_reader.interface;
    const cwd = fs.cwd();

    std.debug.print("session.txt was not found\nCreate it? [Y/n]\n", .{});

    const response = try stdin.takeDelimiter('\n') orelse "";
    if (response.len != 0 and (response[0] != 'y' or response[0] != 'Y'))
        abort("Failed to compile AoC\n", .{});

    const file = cwd.createFile("src/data/session.txt", .{}) catch |e|
        abort("Failed to create session.txt: {}", .{e});
    defer file.close();

    std.debug.print("\x1b[32msession.txt created\x1b[0m\n", .{});

    _ = try file.write("session=");
    _ = try file.write(get_token_from_stdin(stdin));

    return cwd.readFile("src/data/session.txt", buf);
}

fn get_token_from_stdin(stdin: *Reader) []u8 {
    const submit_token_message = "Paste your session token (or type 'help'):";
    const get_token_help =
        \\
        \\1. Navigate to https://adventofcode.com/
        \\2. Log in if you are not already logged in
        \\3. Open your browser's developer tools (shift + control + i)
        \\4. Navigate to the network tab in the dev tools
        \\5. Find the GET request on the root file `https://adventofcode.com/` or `/`
        \\6. Find the `Cookie` response header for the aforementioned request
        \\   Example cookie: {s}
        \\7. Copy the value of the `session` key (highlighted example above)
        \\8. Paste the session token into the terminal and press return
        \\
        \\
    ;

    // can't inline this in `get_token_help` since multi-line
    // strings do not interpret escape sequences
    const example_cookie =
        "_ga=GA1.2.7236763948.0093056273; _ga_MHSNPJKWC7=GS2.2.s4005468081$o12$g4$t4005469676$j83$l3$h3; _gid=GA1.2.842299243.4005335776; session=\x1b[32mqgNUNYiOjfqLkCcrIXOvQ5zvUddSckEkyjCcalbhD8USclu8rvT4eeLvKDHhNg1t4BzSTcA4UXtPVttLeD83Xuj6elQOQOxtmZJDfMbbUmQiM4UHjR4n3QIhsdEGwoWF\x1b[0m; _gat=1";

    std.debug.print("\n{s}\n", .{submit_token_message});

    while (stdin.takeDelimiter('\n')) |response_option| {
        const response = response_option.?; // null is pretty much impossible here.

        // no response is an error
        if (response.len == 0) abort("Aborting compilation\n", .{});

        // help shows help and loops back
        if (mem.eql(u8, "help", response)) std.debug.print(get_token_help, .{example_cookie});

        // My session token is 128 chars
        // I'm assuming anyone else's token will be the same
        if (response.len == 128) return response;

        std.debug.print("{s}\n", .{submit_token_message});
    } else |e| {
        abort("Error {}\nAborting compilation\n", .{e});
    }
}

fn fetch_input_data(buf: []u8, client: *Client, day: Day, cookie: []const u8) ![]const u8 {
    var response_writer: Writer = .fixed(buf);

    var url_buf: [64]u8 = undefined;
    const url = aoc.make_input_url(&url_buf, day, .@"2025");

    const response = try client.fetch(.{
        .location = .{ .url = url },
        .method = .GET,
        .extra_headers = &.{
            .{
                .name = "cookie",
                .value = cookie,
            },
        },
        .response_writer = &response_writer,
    });

    const status = response.status.class();
    if (status != .success) {
        std.debug.print("{?s}", .{response.status.phrase()});
        return error.FailedToFetch;
    }

    return response_writer.buffered();
}

fn create_data_file(path: []const u8, data: []const u8) !void {
    const file = try fs.cwd().createFile(path, .{});
    defer file.close();
    _ = try file.write(data);
}

/// returns true if the file exists and has content
pub fn file_exists(path: []const u8) bool {
    const file = fs.cwd().openFile(path, .{}) catch return false;
    const stat = file.stat() catch return false;
    return stat.size != 0;
}
test "fetch file_exists" {
    try testing.expect(file_exists("build.zig"));
    try testing.expect(file_exists("src/main.zig"));
    try testing.expect(!file_exists("foo"));
}
