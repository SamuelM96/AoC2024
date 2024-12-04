const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day4.input", std.math.maxInt(usize));

    std.debug.print("Part 1: {d}\n", .{try solvePart1(input)});
    std.debug.print("Part 2: {d}\n", .{try solvePart2(input)});
}

const Vec = struct {
    x: isize,
    y: isize,

    inline fn init(x: anytype, y: anytype) Vec {
        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    inline fn toIndex(self: Vec, width: usize) usize {
        const iwidth: isize = @intCast(width);
        return @intCast(self.y * iwidth + self.x + self.y); // add y for newlines
    }

    inline fn add(self: Vec, other: Vec) Vec {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    inline fn mul(self: Vec, value: anytype) Vec {
        const k: isize = @intCast(value);
        return .{ .x = self.x * k, .y = self.y * k};
    }
};

fn solvePart1(input: []const u8) !usize {
    const directions = [_]Vec{
        .{.x=-1, .y= 1}, .{.x=0, .y= 1}, .{.x=1, .y= 1},
        .{.x=-1, .y= 0},                 .{.x=1, .y= 0},
        .{.x=-1, .y=-1}, .{.x=0, .y=-1}, .{.x=1, .y=-1},
    };

    const data = std.mem.trim(u8, input, " \n");
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const height = std.mem.count(u8, data, "\n") + 1;

    var count: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            const pos = Vec.init(x,y);
            if (data[pos.toIndex(width)] != 'X') continue;
            for (directions) |dir| {
                count += @intFromBool(for (0.., "XMAS") |i, c| {
                    const p = pos.add(dir.mul(i));
                    if (p.x < 0 or p.x >= width
                     or p.y < 0 or p.y >= height
                     or data[p.toIndex(width)] != c) break false;
                } else true);
            }
        }
    }

    return count;
}

fn solvePart2(input: []const u8) !usize {
    const diagonals = [_][2]Vec{
        .{.{.x=-1, .y=-1}, .{.x=1, .y= 1}},
        .{.{.x=-1, .y= 1}, .{.x=1, .y=-1}},
    };
    const corners = [_][2]u8{.{'M', 'S'}, .{'S', 'M'}};

    const data = std.mem.trim(u8, input, " \n");
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const height = std.mem.count(u8, data, "\n") + 1;

    var sum: usize = 0;
    for (1..height-1) |y| {
        for (1..width-1) |x| {
            const pos = Vec.init(x, y);
            if (data[pos.toIndex(width)] != 'A') continue;
            var count: usize = 0;
            for (diagonals) |dia| {
                for (corners) |c| {
                    count += inline for (0.., dia) |i, d| {
                        if (data[pos.add(d).toIndex(width)] != c[i]) break 0;
                    } else 1;
                }
            }
            sum += @intFromBool(count == 2);
        }
    }

    return sum;
}
