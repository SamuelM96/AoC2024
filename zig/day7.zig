const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day7.input", std.math.maxInt(usize));

    std.debug.print("Part 1: {d}\n", .{try solve(allocator, input, part1)});
    std.debug.print("Part 2: {d}\n", .{try solve(allocator, input, part2)});
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

