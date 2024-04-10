const std = @import("std");
const expect = @import("std").testing.expect;
const e0 = @import("e0.zig");

pub fn main() !void {
    //     // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    //     std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    //     // stdout is for the actual output of your application, for example if you
    //     // are implementing gzip, then only the compressed bytes should be sent to
    //     // stdout, not any debugging messages.
    //     const stdout_file = std.io.getStdOut().writer();
    //     var bw = std.io.bufferedWriter(stdout_file);
    //     const stdout = bw.writer();

    //     try stdout.print("Run `zig build test` to run the tests.\n", .{});

    //     try bw.flush(); // don't forget to flush!

    try e0.run();
}

test "all" {
    const x = e0.fibonacci(10);
    try expect(x == 55);
}
