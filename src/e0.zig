const std = @import("std");
const expect = @import("std").testing.expect;

pub fn run() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var arr: std.BoundedArray(u8, 128) = .{};

    try stdout.print("A number please: \n", .{});

    stdin.streamUntilDelimiter(arr.writer(), '\n', arr.capacity()) catch |err| {
        return std.debug.print("{}", .{err});
    };

    try stdout.print("{s}\n", .{&arr.buffer});

    var a = std.fmt.parseUnsigned(i32, &arr.buffer, 0) catch |err| {
        return std.debug.print("{s}:{d} -> {}\n", .{ @src().file, @src().line, err });
    };

    try stdout.print("Your number: {d}\n", .{a});

    // try stdout.print("\nAnother number please: \n", .{});

    // stdin.streamUntilDelimiter(arr.writer(), '\n', undefined) catch |err| {
    //     std.debug.print("{}", .{err});
    //     return;
    // };

    // var b = std.fmt.parseInt(i32, &arr.buffer, 10) catch |err| {
    //     std.debug.print("{}", .{err});
    //     return;
    // };

    // try stdout.print("Their sum is: {d}", .{sum(a, b)});
}

pub fn sum(a: i32, b: i32) i32 {
    return a + b;
}

test "0_sum test" {
    try expect(3 == sum(1, 2));
    try expect(4 == sum(1, 3));
}

pub fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "function recursion" {
    const x = fibonacci(10);
    try expect(x == 55);
}
