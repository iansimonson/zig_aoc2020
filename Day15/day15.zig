const std = @import("std");
const print = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const MemMap = std.AutoHashMap(usize, usize);

const INPUT = [_]usize{7,14,0,17,11,1,2};
const TEST_INPUT = [_]usize{0, 3, 6};

pub fn main() !void {
    defer _ = gpa.deinit();

    const p1 = parts(INPUT[0..], 2020);
    const p2 = parts(INPUT[0..], 30000000);

    print("P1: {}\n", .{p1});
    print("P2: {}\n", .{p2});
}

fn parts(starters: []const usize, ith_num: usize) !usize {
    var map = MemMap.init(alloc);
    defer map.deinit();

    var counter: usize = 0;
    for (starters) |s| {
        try map.put(s, counter);
        counter += 1;
    }
    var next_num_to_insert: usize = 0;
    while (counter < ith_num - 1) : (counter += 1) {
        const prev = map.get(next_num_to_insert);
        try map.put(next_num_to_insert, counter);
        if (prev) |p| {
            next_num_to_insert = (counter) - p;
        } else {
            next_num_to_insert = 0;
        }
    }

    return next_num_to_insert;
}