const std = @import("std");

const Key = struct { usize, usize };
const Cache = std.AutoHashMap(Key, usize);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day11.input", std.math.maxInt(usize));
    const trimmed = std.mem.trim(u8, input, " \n");

    var data = std.ArrayList(usize).init(allocator);
    var it = std.mem.tokenizeScalar(u8, trimmed, ' ');
    while (it.next()) |num| {
        try data.append(try std.fmt.parseInt(usize, num, 10));
    }

    var cache = Cache.init(allocator);
    defer cache.deinit();

    var timer = try std.time.Timer.start();
    var result = try solve(&cache, data.items, 25);
    var elapsed_ns = timer.read();
    var elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 1: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });

    timer.reset();
    result = try solve(&cache, data.items, 75);
    elapsed_ns = timer.read();
    elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 2: {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });
}

fn solve(cache: *Cache, input: []const usize, n: usize) !usize {
    var total: usize = 0;
    for (input) |stone| {
        total += try blink(cache, stone, n);
    }
    return total;
}

fn blink(cache: *Cache, stone: usize, depth: usize) !usize {
    const key = Key{ stone, depth };
    if (cache.get(key)) |value| return value;
    if (depth == 0) return 1;

    const value = blk: {
        if (stone == 0) break :blk try blink(cache, 1, depth - 1);
        if (stone > 9) {
            const digits = std.math.log10_int(stone) + 1;
            const n = digits / 2;
            const m = digits % 2;
            if (m % 2 == 0) {
                const p = std.math.pow(usize, 10, n);
                break :blk try blink(cache, stone / p, depth - 1) + try blink(cache, stone % p, depth - 1);
            }
        }
        break :blk try blink(cache, stone * 2024, depth - 1);
    };

    try cache.put(key, value);
    return value;
}
