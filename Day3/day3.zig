const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const DataArray = std.ArrayList(u32);

const column_size = 31;

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    var map_data = try std.ArrayList([column_size]bool).initCapacity(alloc, 1000);
    defer map_data.deinit();

    var it = std.mem.split(inputData, "\n");

    while (it.next()) |line| {
        try map_data.append([_]bool{false} ** column_size);
        for (line) |char, i| {
            if (char == '#') {
                map_data.items[map_data.items.len - 1][i] = true;
            }
        }
    }

    std.debug.print("{}\n", .{slope(&map_data, 1, 3)});

    const p2 = slope(&map_data, 1, 3)
    * slope(&map_data, 1, 1)
    * slope(&map_data, 1, 5)
    * slope(&map_data, 1, 7)
    * slope(&map_data, 2, 1);

    std.debug.print("{}\n", .{p2});
    
}

fn slope(data: *std.ArrayList([column_size]bool), row_slope: usize, col_slope: usize) usize {
    var count: usize = 0;
    var row = row_slope;
    var col = col_slope;
    while (row < data.items.len) {
        if (data.items[row][col]) {
            count += 1;
        }

        row += row_slope;
        col = @mod(col + col_slope, column_size);
    }

    return count;
}