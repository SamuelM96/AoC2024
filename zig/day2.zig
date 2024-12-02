const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day2.input", std.math.maxInt(usize));
    defer allocator.free(input);

    std.debug.print("Safe reports (part 1): {d}\n", .{try solve_part1(input)});
    std.debug.print("Safe reports (part 2): {d}\n", .{try solve_part2(input)});
}

fn solve_part1(input: []const u8) !usize {
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

fn solve_part2(input: []const u8) !usize {
    var lines = std.mem.splitScalar(u8, std.mem.trim(u8, input, " \n"), '\n');

    var count: usize = 0;
    var level: [8]i64 = undefined; // Max row length is known, so avoiding allocations
    var tmp: [8]i64 = undefined;
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
        // that bruteforcing has better cache coherence and less branching
        var safe = false;
        for (0..len) |j| {
            @memcpy(tmp[0..j], level[0..j]);
            @memcpy(tmp[j .. len - 1], level[j + 1 .. len]);
            var valid = true;
            const direction = tmp[0] - tmp[1];
            for (0..len - 2) |i| {
                const diff = tmp[i] - tmp[i + 1];
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
