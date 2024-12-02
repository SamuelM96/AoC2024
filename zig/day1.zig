const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day1.input", std.math.maxInt(u64));
    defer allocator.free(input);

    const trimmed = std.mem.trim(u8, input, "\n");
    std.debug.print("Part 1: {d}\n", .{try solve_part1(allocator, trimmed)});
    std.debug.print("Part 2: {d}\n", .{try solve_part2(allocator, trimmed)});
}

fn solve_part1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var left = std.ArrayList(i64).init(allocator);
    defer left.deinit();
    var right = std.ArrayList(i64).init(allocator);
    defer right.deinit();

    var it = std.mem.splitSequence(u8, input, "\n");
    while (it.next()) |num_pair| {
        var pair = std.mem.splitSequence(u8, num_pair, "   ");
        try left.append(try std.fmt.parseInt(i64, pair.next().?, 10));
        try right.append(try std.fmt.parseInt(i64, pair.next().?, 10));
    }

    std.mem.sort(i64, left.items, {}, std.sort.asc(i64));
    std.mem.sort(i64, right.items, {}, std.sort.asc(i64));

    var sum: usize = 0;
    for (0..left.items.len) |i| {
        sum += @abs(left.items[i] - right.items[i]);
    }

    return sum;
}

fn solve_part2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var left = std.ArrayList(i64).init(allocator);
    defer left.deinit();
    var right = std.AutoHashMap(i64, i64).init(allocator);
    defer right.deinit();

    var it = std.mem.splitSequence(u8, input, "\n");
    while (it.next()) |num_pair| {
        var pair = std.mem.splitSequence(u8, num_pair, "   ");
        try left.append(try std.fmt.parseInt(i64, pair.next().?, 10));

        const value = try std.fmt.parseInt(i64, pair.next().?, 10);
        const count = if (try right.fetchPut(value, 0)) |kv| kv.value else 0;
        try right.put(value, count + 1);
    }

    var sum: usize = 0;
    for (left.items) |value| {
        sum += @abs(value * (right.get(value) orelse 0));
    }

    return sum;
}
