const std = @import("std");

const Number = usize;
const VM = struct {
    const Self = @This();

    data: []const u8,
    pos: usize,

    fn exec(self: *Self) Number {
        var sum: Number = 0;
        var enabled = true;
        while (self.pos < self.data.len) {
            if (!enabled and self.match("do()")) {
                enabled = true;
            } else if (enabled and self.match("don't()")) {
                enabled = false;
            }

            if (enabled) {
                if (self.parseMul()) |res| {
                    sum += res;
                    continue;
                }
            }

            self.pos += 1;
        }
        return sum;
    }

    pub inline fn match(self: *Self, keyword: []const u8) bool {
        const end = self.pos + keyword.len;
        if (end < self.data.len and std.mem.eql(u8, keyword, self.data[self.pos..end])) {
            self.pos += keyword.len;
            return true;
        }
        return false;
    }

    pub inline fn parseNumber(self: *Self) ?Number {
        const start = self.pos;
        while (self.data[self.pos] >= '0' and self.data[self.pos] <= '9') self.pos += 1;
        return std.fmt.parseInt(Number, self.data[start..self.pos], 10) catch return null;
    }

    pub fn parseMul(self: *Self) ?Number {
        if (match(self, "mul(")) {
            const a = self.parseNumber() orelse return null;

            if (self.data[self.pos] != ',') return null;
            self.pos += 1;

            const b = self.parseNumber() orelse return null;

            if (self.data[self.pos] != ')') return null;
            self.pos += 1;

            return a * b;
        }
        return null;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "day3.input", std.math.maxInt(usize));
    defer allocator.free(input);

    // Zig doesn't have a regex library currently, so I've three options:
    //  1. Use the POSIX regex.h, which requires a wrapper (ziglang/zig #1499)
    //  2. I do some good ol' manual string parsing
    //  3. Recursive descent (fancy manual string parsing)
    std.debug.print("Part 1: {d}\n", .{try solvePart1(input)});
    std.debug.print("Part 2: {d}\n", .{try solvePart2(input)});

    // Preparing for another virtual machine year(?) :D
    var vm = VM{ .data = input, .pos = 0 };
    std.debug.print("Part 2 with recursive descent: {d}\n", .{vm.exec()});
}

fn solvePart1(input: []const u8) !usize {
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
            const res = try solvePart1(token);
            sum += res;
        }
    }
    return sum;
}
