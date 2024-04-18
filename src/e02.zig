const std = @import("std");
const throw = @import("log.zig");
const Random = @import("std").rand.Random;

// Make a function such that

const Vec2 = struct {
    x: u8 = 0,
    y: u8 = 0,
    fn print(self: *Vec2) void {
        std.debug.print("({d},{d})\n", .{ self.x, self.y });
    }
};

const Entity = struct {
    position: Vec2 = Vec2{},
    fn randomizePosition(self: *Entity, rand: *const Random) *Entity {
        self.position.x = rand.int(@TypeOf(self.position.x));
        self.position.y = rand.int(@TypeOf(self.position.y));
        return self;
    }
};

pub fn run() !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const rand = prng.random();

    var entities = std.mem.zeroes([16]Entity);

    for (0..entities.len) |index| {
        @constCast(&entities[index]).randomizePosition(&rand).position.print();
    }
}
