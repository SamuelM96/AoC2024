const std = @import("std");

const Vec = struct {
    const Self = @This();

    x: isize,
    y: isize,

    inline fn init(x: anytype, y: anytype) Self {
        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    inline fn toIndex(self: Self, width: usize) usize {
        const iwidth: isize = @intCast(width);
        return @intCast(self.y * iwidth + self.x + self.y); // add y for newlines
    }

    inline fn fromIndex(index: usize, width: usize) Self {
        return Self.init(index % (width + 1), index / (width + 1)); // add 1 for newlines
    }

    inline fn add(self: Self, other: Self) Self {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    inline fn sub(self: Self, other: Self) Self {
        return .{ .x = self.x - other.x, .y = self.y - other.y };
    }

    inline fn eql(self: Self, other: Self) bool {
        return self.x == other.x and self.y == other.y;
    }
};

const DIRS = [_]Vec{
    .{ .x = 0, .y = -1 }, // ^
    .{ .x = 1, .y = 0 }, // >
    .{ .x = 0, .y = 1 }, // V
    .{ .x = -1, .y = 0 }, // <
};
const BACKGROUND = '.';
const BARRIER = '#';
const OBSTACLE = 'O';

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day6.input", std.math.maxInt(usize));

    const trimmed = std.mem.trim(u8, input, "\n");
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const height = std.mem.count(u8, trimmed, "\n") + 1;

    const p1, _ = try solvePart1(allocator, input, width, height);
    std.debug.print("Part 1: {d}\n", .{p1});

    var timer = try std.time.Timer.start();
    timer.reset();
    const result = try solvePart2(allocator, input, width, height);
    const elapsed_ns = timer.read();
    const elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 2: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });
}

fn solvePart1(allocator: std.mem.Allocator, map: []const u8, width: usize, height: usize) !struct { usize, std.AutoHashMap(Vec, void) } {
    var guard = findGuard(map, width);
    var visited = std.AutoHashMap(Vec, void).init(allocator);
    var sum: usize = 0;
    var dir: usize = 0;
    while (0 <= guard.x and guard.x < width and 0 <= guard.y and guard.y < height) {
        if (map[guard.toIndex(width)] == BARRIER) {
            guard = guard.sub(DIRS[dir]);
            dir = (dir + 1) % 4;
        } else if (!visited.contains(guard)) {
            sum += 1;
        }

        try visited.put(guard, {});
        guard = guard.add(DIRS[dir]);
    }
    return .{ sum, visited };
}

fn solvePart2(allocator: std.mem.Allocator, map: []u8, width: usize, height: usize) !usize {
    _, const walked = try solvePart1(allocator, map, width, height);

    const guard = findGuard(map, width);
    map[guard.toIndex(width)] = BACKGROUND;

    var visited = std.AutoHashMap(Vec, u8).init(allocator);
    try visited.ensureTotalCapacity(8192);
    var sum: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            const pos = Vec.init(x, y);
            if (guard.eql(pos) or !walked.contains(pos)) continue;
            const i = pos.toIndex(width);
            const prev = map[i];
            map[i] = OBSTACLE;
            sum += @intFromBool(try walk(map, width, height, guard, &visited));
            visited.clearRetainingCapacity();
            map[i] = prev;
        }
    }
    return sum;
}

fn findGuard(map: []const u8, width: usize) Vec {
    const offset = std.mem.indexOfScalar(u8, map, '^').?;
    return Vec.fromIndex(offset, width);
}

// A modified version of part 1 which exits early as soon as a loop is detected
fn walk(map: []const u8, width: usize, height: usize, guard: Vec, visited: *std.AutoHashMap(Vec, u8)) !bool {
    var g = guard;
    var dir: usize = 0;
    while (0 <= g.x and g.x < width and 0 <= g.y and g.y < height) {
        var d = DIRS[dir];
        const current = try visited.getOrPutValue(g, map[g.toIndex(width)]);
        const value: u8 = current.value_ptr.*;

        if (value == BARRIER or value == OBSTACLE) {
            g = g.sub(d);
            dir = (dir + 1) % 4;
            d = DIRS[dir];
        } else if (value == '+') {
            const next = map[g.add(d).toIndex(width)];
            if (next == BARRIER or next == OBSTACLE) return true;
        }

        try visited.put(g, if (value == BACKGROUND) (if (dir == 0 or dir == 2) '|' else '-') else '+');
        g = g.add(d);
    }

    return false;
}
