const std = @import("std");

const Point = struct {
    const Self = @This();

    x: i32,
    y: i32,

    inline fn init(x: anytype, y: anytype) Self {
        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    inline fn toIndex(self: Self, stride: usize) usize {
        return @as(usize, @intCast(self.y * @as(i32, @intCast(stride)) + self.x));
    }

    inline fn add(self: Self, other: Self) Self {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    inline fn inside(self: Self, width: usize, height: usize) bool {
        return 0 <= self.x and self.x < width and 0 <= self.y and self.y < height;
    }
};

const PointSet = std.AutoHashMap(Point, void);

const Context = struct {
    const Self = @This();

    input: []const u8,
    width: usize,
    height: usize,
    stride: usize,

    fn init(input: []const u8) Self {
        const width = std.mem.indexOfScalar(u8, input, '\n').?;
        return .{
            .input = input,
            .width = width,
            .height = std.mem.count(u8, input, "\n") + 1,
            .stride = width + 1, // account for newline
        };
    }
};

const DIRECTIONS = [_]Point{
    .{ .x = 0, .y = -1 },
    .{ .x = 0, .y = 1 },
    .{ .x = -1, .y = 0 },
    .{ .x = 1, .y = 0 },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day10.input", std.math.maxInt(usize));
    const trimmed = std.mem.trim(u8, input, " \n");

    const ctx = Context.init(trimmed);

    var timer = try std.time.Timer.start();
    var result = try solve(PointSet, allocator, &ctx);
    var elapsed_ns = timer.read();
    var elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 1: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });

    timer.reset();
    result = try solve(usize, allocator, &ctx);
    elapsed_ns = timer.read();
    elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 2: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });
}

fn solve(T: type, allocator: std.mem.Allocator, ctx: *const Context) !usize {
    var point_set: ?PointSet = if (T == PointSet) PointSet.init(allocator) else null;
    var total: usize = 0;
    for (0..ctx.height) |y| {
        for (0..ctx.width) |x| {
            const point = Point.init(x, y);
            if (ctx.input[point.toIndex(ctx.stride)] == '0') {
                var acc: T = switch (T) {
                    PointSet => blk: {
                        if (point_set) |*ps| {
                            ps.clearRetainingCapacity();
                            break :blk ps.*;
                        } else unreachable;
                    },
                    usize => 0,
                    else => unreachable,
                };
                try dfs(@TypeOf(acc), ctx, point, &acc);
                total += switch (T) {
                    PointSet => acc.count(),
                    usize => acc,
                    else => unreachable,
                };
            }
        }
    }

    return total;
}

fn dfs(T: type, ctx: *const Context, p: Point, acc: *T) !void {
    const n = ctx.input[p.toIndex(ctx.stride)];
    if (n == '9') {
        switch (T) {
            PointSet => try acc.put(p, {}),
            usize => acc.* += 1,
            else => unreachable,
        }
        return;
    }

    for (DIRECTIONS) |dir| {
        const point = p.add(dir);
        if (point.inside(ctx.width, ctx.height) and ctx.input[point.toIndex(ctx.stride)] == n + 1) {
            try dfs(T, ctx, point, acc);
        }
    }
}
