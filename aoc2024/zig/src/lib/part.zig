const std = @import("std");
const Writer = std.io.Writer;

pub const Part = enum {
    one,
    two,

    pub inline fn format(self: Part, writer: *Writer) Writer.Error!void {
        try writer.print("Part {s}", .{@tagName(self)});
    }
};
