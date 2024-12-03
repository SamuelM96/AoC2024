const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day3.input", std.math.maxInt(usize));
    defer allocator.free(input);

    // Hmmm... Is this going to become another virtual machine which executes corrupted programs?
    // TODO: Convert this to a recursive descent parser to prepare for the future :P
    std.debug.print("Part 1: {d}\n", .{try solvePart1(input)});
    std.debug.print("Part 2: {d}\n", .{try solvePart2(input)});
}

fn solvePart1(input: []const u8) !usize {
    // Zig doesn't have a regex library currently, so I've two options:
    //  1. Use the POSIX regex.h, which requires a wrapper (ziglang/zig #1499)
    //  2. I do some good ol' manual string parsing
    var sum: usize = 0;
    var it = std.mem.tokenizeSequence(u8, input, "mul(");
    while (it.next()) |token| {
        var parsing_second = false;
        var first: usize = 0;
        var second: usize = 0;
        var start: usize = 0;
        for (0..token.len, token) |i, c| {
            if (c >= '0' and c <= '9') {
                continue;
            } else if (!parsing_second and c == ',') {
                first = try std.fmt.parseInt(usize, token[start..i], 10);
                start = i + 1;
                parsing_second = true;
                continue;
            } else if (c == ')') {
                second = try std.fmt.parseInt(usize, token[start..i], 10);
            }
            break;
        }
        sum += first * second;
    }
    return sum;
}

fn solvePart2(input: []const u8) !usize {
    var sum: usize = 0;
    var it = std.mem.tokenizeSequence(u8, input, "do");
    var enabled = true;
    while (it.next()) |token| {
        if (token[0] == '(' and token[1] == ')') {
            enabled = true;
        } else if (std.mem.eql(u8, token[0..5], "n't()")) {
            enabled = false;
        }
        if (enabled) {
            sum += try solvePart1(token);
        }
    }
    return sum;
}
