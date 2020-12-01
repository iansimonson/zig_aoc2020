const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const DataArray = std.ArrayList(u32);

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    var it = std.mem.split(inputData, "\n");

    var data = try DataArray.initCapacity(alloc, 1000);
    defer data.deinit();

    while (it.next()) |line| {
        try data.append(try std.fmt.parseInt(u32, line, 10));
    }

    std.sort.sort(u32, data.items, LessCtx{}, less);

    var outer_begin: usize = 0;

    while (true) {
        const number_to_find = 2020 - data.items[outer_begin];
        var begin: usize = outer_begin + 1;
        var end: usize = data.items.len - 1;
        while (end > begin) {
            const value = data.items[begin] + data.items[end];
            if (value < number_to_find) {
                begin += 1;
            } else if (value > number_to_find) {
                end -= 1;
            } else {
                std.debug.print("Value: {}\n", .{data.items[begin] * data.items[end] * data.items[outer_begin]});
                return;
            }
        }
        outer_begin += 1;
    }
}

const LessCtx = struct {};

pub fn less(context: LessCtx, x: u32, y: u32) bool {
    return x < y;
}
