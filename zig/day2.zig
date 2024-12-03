const std = @import("std");
const builtin = @import("builtin");

const MAX_NUMBERS_PER_ROW = 1024;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day2.input", std.math.maxInt(usize));
    defer allocator.free(input);

    std.debug.print("Safe reports (part 1): {d}\n", .{try solvePart1(input)});
    std.debug.print("Safe reports (part 2): {d}\n", .{try solvePart2(input)});
    std.debug.print("Safe reports (part 2 brute): {d}\n", .{try solvePart2Brute(input)});

    std.debug.print("Benchmarking part 2 solution against AoC input file...\n", .{});
    try benchmark("Optimal", input, solvePart2);
    try benchmark("Bruteforced", input, solvePart2Brute);

    std.debug.print("Generating random benchmark test data...\n", .{});
    var prng = std.rand.DefaultPrng.init(123456); // fixing the seed for others to replicate
    const random = prng.random();

    // Each number can be up to 3 digits + space + newline
    const rows = 10000;
    const max_size = rows * (MAX_NUMBERS_PER_ROW * 4 + 1);

    const buffer = try allocator.alloc(u8, max_size);

    var fbs = std.io.fixedBufferStream(buffer);
    var writer = fbs.writer();

    for (0..rows) |_| {
        for (0..MAX_NUMBERS_PER_ROW) |col| {
            const num = random.int(u32) % 100;
            if (col < MAX_NUMBERS_PER_ROW - 1) {
                try writer.print("{d} ", .{num});
            } else {
                try writer.print("{d}\n", .{num});
            }
        }
    }

    // Shrink buffer to actual size
    const actual_size = @as(usize, @intCast(writer.context.getPos() catch unreachable));
    const buf = try allocator.realloc(buffer, actual_size);
    defer allocator.free(buf);

    std.debug.print("Benchmarking solutions to part 2...\n", .{});
    try benchmark("Optimal", buf, solvePart2);
    try benchmark("Bruteforced", buf, solvePart2Brute);
}

fn solvePart1(input: []const u8) !usize {
    var lines = std.mem.splitScalar(u8, std.mem.trim(u8, input, " \n"), '\n');

    var count: usize = 0;
    var level: [8]i64 = undefined; // Max row length is known, so avoiding allocations
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        var len: usize = 0;
        while (nums.next()) |num| {
            // A "production" version would check bounds, but no need when
            // the input is known
            level[len] = try std.fmt.parseInt(i64, num, 10);
            len += 1;
        }

        count += 1;
        const direction = level[0] - level[1];
        for (0..len - 1) |i| {
            const diff = level[i] - level[i + 1];
            if (@abs(diff) > 3 or direction * diff <= 0) {
                count -= 1;
                break;
            }
        }
    }

    return count;
}

fn solvePart2(input: []const u8) !usize {
    var lines = std.mem.splitScalar(u8, std.mem.trim(u8, input, " \n"), '\n');

    var count: usize = 0;
    var level: [MAX_NUMBERS_PER_ROW]i64 = undefined; // Max row length is known, so avoiding allocations
    var temp: [MAX_NUMBERS_PER_ROW]i64 = undefined;
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        const len = blk: {
            var i: usize = 0;
            while (nums.next()) |num| : (i += 1) {
                level[i] = try std.fmt.parseInt(i64, num, 10);
            }
            break :blk i;
        };

        if (len < 2) continue;

        const lvl = level[0..len];
        const tmp = temp[0 .. len - 1];

        // If an unsafe report is found, see if removing one makes the level safe
        // [0, 1, 2, 3, 4]
        //     i=2^
        // [0:i  ] + [i+1:len]  =>  [0, 1, 3, 4]
        // [0:i+1] + [i+2:len]  =>  [0, 1, 2, 4]
        // [0:i-1] + [  i:len]  =>  [0, 2, 3, 4]
        var safe = true;
        if (unsafeAt(lvl)) |i| {
            const checks = [_]isize{ -1, 0, 1 };
            safe = false;
            inline for (checks) |offset| {
                const idx = @as(isize, @intCast(i)) + offset;
                if (idx >= 0 and idx < len) {
                    const skip: usize = @intCast(idx);
                    @memcpy(temp[0..skip], lvl[0..skip]);
                    @memcpy(temp[skip .. len - 1], lvl[skip + 1 .. len]);
                    if (unsafeAt(tmp) == null) {
                        safe = true;
                        break;
                    }
                }
            }
        }
        count += @intFromBool(safe);
    }

    return count;
}

fn solvePart2Brute(input: []const u8) !usize {
    var lines = std.mem.splitScalar(u8, std.mem.trim(u8, input, " \n"), '\n');

    var count: usize = 0;
    var level: [MAX_NUMBERS_PER_ROW]i64 = undefined; // Max row length is known, so avoiding allocations
    var temp: [MAX_NUMBERS_PER_ROW]i64 = undefined;
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        var len: usize = 0;
        while (nums.next()) |num| {
            // A "production" version would check bounds, but no need when
            // the input is known
            level[len] = try std.fmt.parseInt(i64, num, 10);
            len += 1;
        }

        // Whilst the safety check *could* check the (idx-1..idx+1) surrounding
        // pairs based on the index it failed on, the input is small enough
        // that bruteforcing works just as well. See `solvePart2()` for the
        // optimal solution for larger inputs.
        var safe = false;
        for (0..len) |j| {
            @memcpy(temp[0..j], level[0..j]);
            @memcpy(temp[j .. len - 1], level[j + 1 .. len]);
            var valid = true;
            const direction = temp[0] - temp[1];
            for (0..len - 2) |i| {
                const diff = temp[i] - temp[i + 1];
                valid = valid and @abs(diff) <= 3 and direction * diff > 0;
                if (!valid) break;
            }
            safe = safe or valid;
            if (safe) break;
        }
        count += @intFromBool(safe);
    }

    return count;
}

// Get the index of the first unsafe report found. `null` if none are found.
fn unsafeAt(level: []const i64) ?usize {
    const direction = level[0] - level[1];
    for (0..level.len - 1) |i| {
        const diff = level[i] - level[i + 1];
        if (@abs(diff) > 3 or direction * diff <= 0) {
            return i;
        }
    }
    return null;
}

inline fn benchmark(name: []const u8, input: []const u8, func: *const fn ([]const u8) anyerror!usize) !void {
    const iterations = 10;
    var min: usize = std.math.maxInt(usize);
    var max: usize = 0;
    var total: usize = 0;
    var timer = try std.time.Timer.start();
    for (0..iterations) |i| {
        timer.reset();
        const result = try func(input);
        const elapsed_ns = timer.read();

        min = @min(min, elapsed_ns);
        max = @max(max, elapsed_ns);
        total += elapsed_ns;

        const elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
        std.debug.print("[#{d:0>3}] {s}: {d:<3} =>  {d:.6} seconds\n", .{ i, name, result, elapsed });
    }

    std.debug.print("Results:\n", .{});
    std.debug.print("  Min: {d:.6} seconds\n", .{@as(f64, @floatFromInt(min)) / std.time.ns_per_s});
    std.debug.print("  Max: {d:.6} seconds\n", .{@as(f64, @floatFromInt(max)) / std.time.ns_per_s});
    std.debug.print("  Avg: {d:.6} seconds\n", .{@as(f64, @floatFromInt(total)) / (iterations * std.time.ns_per_s)});
}
