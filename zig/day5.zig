const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Ignoring freeing memory since process exit will do it for me :^)
    const input = try std.fs.cwd().readFileAlloc(allocator, "day5.input", std.math.maxInt(usize));
    var it = std.mem.splitSequence(u8, std.mem.trim(u8, input, "\n"), "\n\n");
    const rules_str = it.next().?;
    const updates_str = it.next().?;

    var rit = std.mem.splitScalar(u8, rules_str, '\n');
    var rules = std.ArrayList([2]u32).init(allocator);
    while (rit.next()) |rule| {
        var r = std.mem.tokenizeScalar(u8, rule, '|');
        const a = try std.fmt.parseInt(u32, r.next().?, 10);
        const b = try std.fmt.parseInt(u32, r.next().?, 10);
        try rules.append([2]u32{ a, b });
    }

    var uit = std.mem.splitScalar(u8, updates_str, '\n');
    var updates = std.ArrayList([]u32).init(allocator);
    while (uit.next()) |update| {
        var up_it = std.mem.tokenizeScalar(u8, update, ',');
        var up = std.ArrayList(u32).init(allocator);
        while (up_it.next()) |num| {
            try up.append(try std.fmt.parseInt(u32, num, 10));
        }
        try updates.append(up.items);
    }

    std.debug.print("Part 1: {d}\n", .{try solvePart1(updates.items, rules.items)});
    std.debug.print("Part 2: {d}\n", .{try solvePart2(updates.items, rules.items)});
}

fn solvePart1(updates: [][]u32, rules: [][2]u32) !usize {
    var sum: usize = 0;
    for (updates) |update| {
        sum += outer: for (0..update.len - 1) |i| {
            for (rules) |rule| {
                if (rule[0] == update[i + 1] and rule[1] == update[i]) {
                    break :outer update[update.len / 2];
                }
            }
        } else 0;
    }
    return sum;
}

// Rule-based gnome sort
fn solvePart2(updates: [][]u32, rules: [][2]u32) !usize {
    var sum: usize = 0;
    for (updates) |update| {
        var i: usize = 0;
        var modified = false;
        outer: while (i < update.len) {
            for (rules) |rule| {
                if (i > 0 and rule[0] == update[i] and rule[1] == update[i - 1]) {
                    std.mem.swap(u32, &update[i], &update[i - 1]);
                    i -= 1;
                    modified = true;
                    continue :outer;
                }
            }
            i += 1;
        }
        if (modified) {
            sum += update[update.len / 2];
        }
    }
    return sum;
}
