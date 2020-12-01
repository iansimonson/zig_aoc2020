const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    var it = std.mem.split(inputData, "\n");

    var data = try std.ArrayList(u32).initCapacity(alloc, 1000);
    defer data.deinit();

    while(it.next()) |line| {
        try data.append(try std.fmt.parseInt(u32, line, 10));
    }

    std.sort.sort(u32, data.items, LessCtx{}, less);

    var begin: usize = 0;
    var end: usize = data.items.len - 1;
    while (end > begin) {
        const value = data.items[begin] + data.items[end];
        if (value < 2020) {
            begin += 1;
        } else if (value > 2020) {
            end -= 1;
        } else {
            std.debug.print("Value: {}\n", .{data.items[begin] * data.items[end]});
            return;
        }
    }

}

const LessCtx = struct{};

pub fn less(context: LessCtx, x: u32, y: u32) bool {
    return x < y;
}