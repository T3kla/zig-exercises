const std = @import("std");
const throw = @import("log.zig");

// Request user for two numbers and return their addition

pub fn run() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var arr: std.BoundedArray(u8, 16) = .{};

    // -------------------------------------------------------------- Ask for a number

    try stdout.print("A number please: \n", .{});

    stdin.streamUntilDelimiter(arr.writer(), '\r', arr.capacity()) catch |err| {
        return throw.throw(@src(), "{}", .{err});
    };
    //      std.debug.print("\n{}\n", .{arr});

    const a = std.fmt.parseInt(i32, arr.buffer[0 .. arr.len - 1], 0) catch |err| {
        return throw.throw(@src(), "{}", .{err});
    };

    // -------------------------------------------------------------- Clean stdin and buffer

    try stdin.skipUntilDelimiterOrEof('\n'); // Windows carriage return are two chars "/r/n"
    @memset(&arr.buffer, 0);
    arr.len = 0;
    //      std.debug.print("\n{}\n", .{arr});

    // -------------------------------------------------------------- Ask for another number

    try stdout.print("\nAnother number please: \n", .{});

    stdin.streamUntilDelimiter(arr.writer(), '\r', arr.capacity()) catch |err| {
        return throw.throw(@src(), "{}", .{err});
    };
    //      std.debug.print("\n{}\n", .{arr});

    const b = std.fmt.parseInt(i32, arr.buffer[0 .. arr.len - 1], 0) catch |err| {
        return throw.throw(@src(), "{}", .{err});
    };

    // -------------------------------------------------------------- Sum

    try stdout.print("\nTheir sum is: {d}\n\n", .{sum(a, b)});
}

pub fn sum(a: i32, b: i32) i32 {
    return a + b;
}
