const std = @import("std");
const throw = @import("log.zig");
const Random = @import("std").rand.Random;

// Make a function such that

const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    fn add(a: *const Vec2, b: *const Vec2) Vec2 {
        return Vec2{ .x = a.x + b.x, .y = a.y + b.y };
    }

    fn mod(self: *Vec2) f32 {
        const x: f32 = @as(f32, @floatFromInt(self.x));
        const y: f32 = @as(f32, @floatFromInt(self.y));
        return std.math.sqrt(x * x + y * y);
    }

    fn print(self: *Vec2) void {
        std.debug.print("({d},{d})\n", .{ self.x, self.y });
    }
};

const Entity = struct {
    health: i8 = 10,
    color: u8 = 0,
    position: Vec2 = Vec2{},
    velocity: Vec2 = Vec2{},

    fn randSlice(entities: []Entity, bounds: [2]Vec2) !void {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        var prng = std.rand.DefaultPrng.init(seed);
        const rand = prng.random();

        for (0..entities.len) |i| {
            const randPosX = rand.intRangeAtMost(i32, bounds[0].x, bounds[1].x);
            const randPosY = rand.intRangeAtMost(i32, bounds[0].y, bounds[1].y);
            const randPos = Vec2{ .x = randPosX, .y = randPosY };

            var randVel: Vec2 = Vec2{};
            while (randVel.mod() <= 0) {
                const randVelX = rand.intRangeAtMost(i32, -2, 2);
                const randVelY = rand.intRangeAtMost(i32, -1, 1);
                randVel = Vec2{ .x = randVelX, .y = randVelY };
            }

            const randColor: u8 = rand.intRangeAtMost(u8, 1, 14);

            entities[i].position = randPos;
            entities[i].velocity = randVel;
            entities[i].color = randColor;
        }
    }
};

const Frame = struct {
    padding: Vec2 = Vec2{},
    size: Vec2 = Vec2{},

    fn render(self: *Frame, entities: []Entity) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("size{} padding{} entities{}", .{ self.size, self.padding, entities });
    }

    /// Returns a `[2]Vec2` in which the first item contains the min bounds (top left)
    /// and the second one contains the max bounds (bottom right)
    /// @return: [2]Vec2
    fn getBounds(self: *const Frame) [2]Vec2 {
        return .{
            Vec2{ .x = self.padding.x + 2, .y = self.padding.y + 2 },
            Vec2{ .x = self.padding.x + self.size.x - 1, .y = self.padding.y + self.size.y - 1 },
        };
    }
};

fn cmdGoto(value: ?*const Vec2) !void {
    var where: Vec2 = undefined;

    if (value) |v| where = v.* else where = Vec2{ .x = 0, .y = 0 };

    const stdout = std.io.getStdOut().writer();
    try stdout.print("\x1B[{d};{d}H", .{ where.y, where.x });
}

fn cmdCursorShow(value: bool) !void {
    const stdout = std.io.getStdOut().writer();
    if (value) {
        try stdout.print("\x1B[?25h", .{});
    } else {
        try stdout.print("\x1B[?25l", .{});
    }
}

fn cmdColorFg(color: u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\x1B[38;5;{d}m", .{color});
}

fn cmdClear() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\x1B[2J", .{});
}

fn drawFrame(frame: *const Frame, entities: []Entity) !void {
    const stdout = std.io.getStdOut().writer();

    try cmdGoto(null);

    const xOutMin = 0;
    const yOutMin = 0;
    const xOutMax = frame.padding.x * 2 + frame.size.x - 1;
    const yOutMax = frame.padding.y * 2 + frame.size.y - 1;

    const xInsMin = frame.padding.x + 1;
    const yInsMin = frame.padding.y + 1;
    const xInsMax = frame.padding.x + frame.size.x - 2;
    const yInsMax = frame.padding.y + frame.size.y - 2;

    for (xOutMin..@intCast(yOutMax + 1)) |y| {
        for (yOutMin..@intCast(xOutMax + 1)) |x| {
            // Outside Corners ╔.201 ╗.187 ╚.200 ╝.188
            if (x == xOutMin and y == yOutMin) {
                try stdout.print("{c}", .{201});
            } else if (x == xOutMax and y == yOutMin) {
                try stdout.print("{c}", .{187});
            } else if (x == xOutMin and y == yOutMax) {
                try stdout.print("{c}", .{200});
            } else if (x == xOutMax and y == yOutMax) {
                try stdout.print("{c}", .{188});
            } else
            // Outside Sides ║.186 ═.205
            if (x == xOutMin or x == xOutMax) {
                try stdout.print("{c}", .{186});
            } else if (y == xOutMin or y == yOutMax) {
                try stdout.print("{c}", .{205});
            } else

            // Inside Corners ┌.218 ┐.191 └.192 ┘.217
            if (x == xInsMin and y == yInsMin) {
                try stdout.print("{c}", .{218});
            } else if (x == xInsMax and y == yInsMin) {
                try stdout.print("{c}", .{191});
            } else if (x == xInsMin and y == yInsMax) {
                try stdout.print("{c}", .{192});
            } else if (x == xInsMax and y == yInsMax) {
                try stdout.print("{c}", .{217});
            } else
            // Inside Sides │.179 ─.196
            if ((x == xInsMin or x == xInsMax) and (y > yInsMin and y < yInsMax)) {
                try stdout.print("{c}", .{179});
            } else if ((y == yInsMin or y == yInsMax) and (x > xInsMin and x < xInsMax)) {
                try stdout.print("{c}", .{196});
            } else try stdout.print(" ", .{});
        }
        try stdout.print("\n", .{});
    }

    // Entities ▓.178 ▒.177 ░.176 ■.254
    for (0..entities.len) |i| {
        const entity = &entities[i];
        try cmdGoto(&entity.position);
        try cmdColorFg(entity.color);
        std.debug.print("{c}", .{254});
        try cmdColorFg(15);
    }

    try cmdGoto(&Vec2{ .x = 0, .y = yOutMax + 2 });
}

fn renderThread(frame: *const Frame, entities: []Entity, rate: u64) !void {
    while (true) {
        try drawFrame(frame, entities);

        if (rate == 0)
            break;

        std.time.sleep(rate);
    }
}

fn gamethread(frame: *const Frame, entities: []Entity, rate: u64) !void {
    const bounds = frame.getBounds();

    while (true) {
        for (0..entities.len) |i| {
            var e = &entities[i];
            var newPos = Vec2.add(&e.position, &e.velocity);

            if (newPos.x < bounds[0].x) {
                newPos.x = bounds[1].x;
            } else if (newPos.x > bounds[1].x) {
                newPos.x = bounds[0].x;
            }

            if (newPos.y < bounds[0].y) {
                newPos.y = bounds[1].y;
            } else if (newPos.y > bounds[1].y) {
                newPos.y = bounds[0].y;
            }

            e.position = newPos;
        }

        if (rate == 0)
            break;

        std.time.sleep(rate);
    }
}

pub fn run() !void {
    const gpa = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();

    var multiThreaded = false;

    while (true) {
        if (args.next()) |path| {
            if (std.mem.eql(u8, path, "-t"))
                multiThreaded = true;
        } else break;
    }

    //

    const frame = Frame{ .padding = Vec2{ .x = 5, .y = 1 }, .size = Vec2{ .x = 80, .y = 30 } };
    var entities = std.mem.zeroes([20]Entity);

    try Entity.randSlice(&entities, frame.getBounds());
    try cmdClear();
    try cmdGoto(null);
    try cmdCursorShow(false);

    if (multiThreaded) {
        _ = try std.Thread.spawn(.{}, renderThread, .{ &frame, &entities, std.time.ns_per_ms * 33 });
        _ = try std.Thread.spawn(.{}, gamethread, .{ &frame, &entities, std.time.ns_per_ms * 150 });
        while (true) {}
    } else {
        while (true) {
            try gamethread(&frame, &entities, 0);
            try renderThread(&frame, &entities, 0);
            std.time.sleep(std.time.ns_per_ms * 200);
        }
    }

    try cmdCursorShow(true);
}
