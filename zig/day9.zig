const std = @import("std");

const Block = struct { []const u8, usize };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day9.input", std.math.maxInt(usize));
    const trimmed = std.mem.trim(u8, input, " \n");

    var timer = try std.time.Timer.start();
    var result = try solvePart1(allocator, trimmed);
    var elapsed_ns = timer.read();
    var elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 1: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });

    timer.reset();
    result = try solvePart2(allocator, trimmed);
    elapsed_ns = timer.read();
    elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 2: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });
}

fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var data = try decompress(allocator, input, []const u8);
    var j: usize = 0;
    for (0..data.items.len) |idx| {
        const i = data.items.len - 1 - idx;
        j = blk: for (j.., data.items[j..]) |k, s| {
            if (s[0] == '.') break :blk k;
        } else break;
        if (j > i) break;
        data.items[j] = data.items[i];
        data.items[i] = ".";
    }

    var result: usize = 0;
    for (0.., data.items) |i, n| {
        if (n[0] == '.') break;
        result += i * try std.fmt.parseInt(usize, n, 10);
    }
    return result;
}

fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var data = try decompress(allocator, input, Block);
    for (0..data.items.len) |idx| {
        const i = data.items.len - 1 - idx;
        const id, const n = data.items[i];
        if (id[0] == '.') continue;
        for (0.., data.items) |j, d| {
            _, const space = d;
            if (j >= i) break;
            if (data.items[j][0][0] != '.') continue;
            if (n == space) {
                std.mem.swap(Block, &data.items[i], &data.items[j]);
                break;
            }
            if (n < space) {
                data.items[j][1] -= n;
                data.items[i][0] = ".";
                try data.insert(j, .{ id, n });
                break;
            }
        }
    }
    return try checksum(data.items);
}

fn decompress(allocator: std.mem.Allocator, input: []const u8, T: type) !std.ArrayList(T) {
    var result = std.ArrayList(T).init(allocator);

    for (0.., input) |i, num| {
        const value = if (i % 2 == 0) try std.fmt.allocPrint(allocator, "{d}", .{i / 2}) else ".";
        switch (T) {
            Block => {
                try result.append(.{ value, num - '0' });
            },
            []const u8 => {
                for (0..num - '0') |_| {
                    try result.append(value);
                }
            },
            else => unreachable,
        }
    }

    return result;
}

fn checksum(data: []const Block) !usize {
    var result: usize = 0;
    var i: usize = 0;
    for (data) |block| {
        const id, const n = block;
        if (id[0] == '.') {
            i += n;
            continue;
        }
        for (0..n) |_| {
            result += i * try std.fmt.parseInt(usize, id, 10);
            i += 1;
        }
    }
    return result;
}
