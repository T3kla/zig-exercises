const std = @import("std");
const throw = @import("log.zig");

// Given an int, return each u8 that compose it as binary
// Make it generic
// Choose the biggest byte and return is at u8
// Given an [*]u8 array, invert it

pub fn run() !void {
    const x: i32 = (1 << 16) + 1;
    try bytes(&x);

    //

    const y: u64 = (1 << 48) + (1 << 32) + (1 << 16) + 1;
    try bytesGeneric(@TypeOf(y), &y);

    //

    const z: u64 = 7923472123811229477;
    try biggestGeneric(@TypeOf(z), &z);

    //

    var w = [_]u8{ 'a', 2, 'b', 3, 'c' };
    try invert(&w);
}

fn bytes(x: *const i32) !void {
    const stdout = std.io.getStdOut().writer();

    const s = @sizeOf(i32);
    const y: *const [s]u8 = @ptrCast(x);

    for (0..s) |index| {
        try stdout.print("{d} -> {b}\n", .{ index, y[index] });
    }

    try stdout.print("\n", .{});
}

fn bytesGeneric(comptime T: type, x: *const T) !void {
    const stdout = std.io.getStdOut().writer();

    const s = @sizeOf(T);
    const y: *const [s]u8 = @ptrCast(x);

    for (0..s) |index| {
        try stdout.print("{d} -> {b}\n", .{ index, y[index] });
    }

    try stdout.print("\n", .{});
}

fn biggestGeneric(comptime T: type, x: *const T) !void {
    const stdout = std.io.getStdOut().writer();

    const s = @sizeOf(T);
    const y: *const [s]u8 = @ptrCast(x);

    var b: u8 = 0;

    for (0..s) |index| {
        const c = y[index];

        if (b < c)
            b = c;

        try stdout.print("{d} -> {b}\n", .{ index, c });
    }

    try stdout.print("Biggest: {b}\n\n", .{b});
}

fn invert(arr: []u8) !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("Given: \n", .{});
    for (arr) |v| {
        try stdout.print("    > {c}\n", .{v});
    }

    for (0..arr.len / 2) |v| {
        const tmp: u8 = arr[v];
        arr[v] = arr[arr.len - 1 - v];
        arr[arr.len - 1 - v] = tmp;
    }

    try stdout.print("Inverted: \n", .{});
    for (arr) |v| {
        try stdout.print("    > {c}\n", .{v});
    }
}
