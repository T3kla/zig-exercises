const std = @import("std");

pub fn throw(comptime src: anytype, comptime fmt: []const u8, args: anytype) void {
    return std.debug.print("{s}:{d} -> " ++ fmt ++ "\n", .{ src.file, src.line } ++ args);
}
