const std = @import("std");

const Point = struct {
    const Self = @This();

    x: isize,
    y: isize,

    fn init(x: anytype, y: anytype) Self {
        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    fn toIndex(self: Self, width: usize) usize {
        // Adding an extra self.y accounts for newlines
        return @as(usize, @intCast(self.y * @as(isize, @intCast(width)) + self.x + self.y));
    }
};

const Node = struct {
    sym: u8,
    pos: Point,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day8.input", std.math.maxInt(usize));

    const trimmed = std.mem.trim(u8, input, " \n");
    const width = std.mem.indexOfScalar(u8, trimmed, '\n').?;
    const height = std.mem.count(u8, trimmed, "\n") + 1;

    var timer = try std.time.Timer.start();
    timer.reset();
    var result = try solve(allocator, trimmed, width, height, false);
    var elapsed_ns = timer.read();
    var elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 1: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });

    timer.reset();
    result = try solve(allocator, trimmed, width, height, true);
    elapsed_ns = timer.read();
    elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 2: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });
}

fn solve(allocator: std.mem.Allocator, input: []const u8, width: usize, height: usize, extend: bool) !usize {
    const points = try getNodes(allocator, input, width, height);
    var antinodes = std.AutoHashMap(Point, void).init(allocator);
    var sum: usize = points.items.len;

    var map: []u8 = undefined;
    if (extend) map = try allocator.dupe(u8, input);

    for (0.., points.items) |i, n1| {
        for (0.., points.items) |j, n2| {
            if (i == j or n1.sym != n2.sym) continue;
            const dx = n1.pos.x - n2.pos.x;
            const dy = n1.pos.y - n2.pos.y;
            var p = Point{ .x = n1.pos.x + dx, .y = n1.pos.y + dy };
            while (0 <= p.x and p.x < width and 0 <= p.y and p.y < height) {
                try antinodes.put(p, {});
                if (!extend) break;
                if (map[p.toIndex(width)] == '.') {
                    map[p.toIndex(width)] = '#';
                    sum += 1;
                }
                p = Point{ .x = p.x + dx, .y = p.y + dy };
            }
        }
    }

    return if (extend) sum else antinodes.count();
}

fn getNodes(allocator: std.mem.Allocator, input: []const u8, width: usize, height: usize) !std.ArrayList(Node) {
    var nodes = std.ArrayList(Node).init(allocator);
    for (0..height) |y| {
        for (0..width) |x| {
            const c = input[y * width + x + y];
            if (c == '.') continue;
            try nodes.append(.{ .sym = c, .pos = Point.init(x, y) });
        }
    }

    return nodes;
}
