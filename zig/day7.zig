const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day7.input", std.math.maxInt(usize));
    // Worst case for recursive
    // const input = "123456789123456789: 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9\n";

    std.debug.print("Part 1: {d}\n", .{try solve(allocator, input, part1)});

    var timer = try std.time.Timer.start();
    timer.reset();
    var result = try solvePart2(allocator, input);
    var elapsed_ns = timer.read();
    var elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 2 (stack): {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });

    timer.reset();
    result = try solve(allocator, input, part2);
    elapsed_ns = timer.read();
    elapsed = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    std.debug.print("Part 2 (recursive): {d:<3}  =>  {d:.6} seconds\n", .{ result, elapsed });
}

fn solve(allocator: std.mem.Allocator, input: []const u8, check: fn (nums: []const usize, goal: usize, pos: usize, value: usize) bool) !usize {
    var sum: usize = 0;
    var it = std.mem.splitScalar(u8, std.mem.trim(u8, input, "\n"), '\n');
    var nums = try std.ArrayList(usize).initCapacity(allocator, 32);
    while (it.next()) |line| {
        const goal_len = std.mem.indexOfScalar(u8, line, ':') orelse return error.InvalidGoal;
        const goal = try std.fmt.parseInt(usize, line[0..goal_len], 10);
        var num_it = std.mem.tokenizeScalar(u8, line[goal_len + 1 ..], ' ');
        while (num_it.next()) |num| {
            try nums.append(try std.fmt.parseInt(usize, num, 10));
        }
        sum += if (check(nums.items, goal, 0, nums.items[0])) goal else 0;
        nums.clearRetainingCapacity();
    }
    return sum;
}

fn part1(nums: []const usize, goal: usize, pos: usize, value: usize) bool {
    if (pos == nums.len - 1) return value == goal;
    const num = nums[pos + 1];
    return part1(nums, goal, pos + 1, value + num)
        or part1(nums, goal, pos + 1, value * num);
}

fn part2(nums: []const usize, goal: usize, pos: usize, value: usize) bool {
    if (pos == nums.len - 1) return value == goal;
    const num = nums[pos + 1];
    return part2(nums, goal, pos + 1, value + num)
        or part2(nums, goal, pos + 1, value * num)
        or part2(nums, goal, pos + 1, value * std.math.pow(usize, 10, std.fmt.count("{d}", .{num})) + num);
}

fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var sum: usize = 0;
    var it = std.mem.splitScalar(u8, std.mem.trim(u8, input, "\n"), '\n');
    var nums = try std.ArrayList(usize).initCapacity(allocator, 32);
    var stack = try std.ArrayList(struct {usize, usize}).initCapacity(allocator, 32);
    while (it.next()) |line| {
        const goal_len = std.mem.indexOfScalar(u8, line, ':') orelse return error.InvalidGoal;
        const goal = try std.fmt.parseInt(usize, line[0..goal_len], 10);
        var num_it = std.mem.tokenizeScalar(u8, line[goal_len + 1 ..], ' ');
        while (num_it.next()) |num| {
            try nums.append(try std.fmt.parseInt(usize, num, 10));
        }

        stack.appendAssumeCapacity(.{nums.items[0], 0});
        while (stack.items.len > 0) {
            const val, const idx = stack.pop();

            if (idx == nums.items.len - 1) {
                if (val == goal) {
                    sum += goal;
                    break;
                }
                continue;
            }

            const next = nums.items[idx + 1];
            try stack.append(.{val + next, idx + 1});
            try stack.append(.{ val * next, idx + 1 });
            try stack.append(.{ val * std.math.pow(usize, 10, std.fmt.count("{d}", .{next})) + next, idx + 1});
        }
        nums.clearRetainingCapacity();
        stack.clearRetainingCapacity();
    }
    return sum;
}
