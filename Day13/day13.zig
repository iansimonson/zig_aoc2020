const std = @import("std");
const print = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const Pair = struct { first: usize, second: usize };
const DataList = std.ArrayList(Pair);

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    const p1 = part1(inputData);
    const p2 = part2(inputData);

    std.debug.print("{}\n", .{p1});
    std.debug.print("{}\n", .{p2});
}

fn sort_times(ctx: void, lhs: Pair, rhs: Pair) bool {
    return lhs.second < rhs.second;
}

fn part1(inputData: []const u8) !usize {
    var times_list = DataList.init(alloc);
    defer times_list.deinit();

    var lines = std.mem.split(inputData, "\n");
    const cur_time = try std.fmt.parseInt(usize, lines.next().?, 10);
    var busses = std.mem.split(lines.next().?, ",");
    while (busses.next()) |bus_str| {
        if (std.mem.eql(u8, bus_str, "x")) {
            continue;
        }
        const bus = try std.fmt.parseInt(usize, bus_str, 10);
        const time_left = bus - @mod(cur_time, bus);
        try times_list.append(.{ .first = bus, .second = time_left });
    }

    std.sort.sort(Pair, times_list.items, {}, sort_times);

    return times_list.items[0].first * times_list.items[0].second;
}

// here "second" is the relative position
fn part2(inputData: []const u8) !usize {
    var times_list = DataList.init(alloc);
    defer times_list.deinit();

    var lines = std.mem.split(inputData, "\n");
    const cur_time = try std.fmt.parseInt(usize, lines.next().?, 10); // unused for p2
    var busses = std.mem.split(lines.next().?, ",");
    var rel_pos: usize = 0;
    while (busses.next()) |bus_str| : (rel_pos += 1) {
        if (std.mem.eql(u8, bus_str, "x")) {
            continue;
        }
        const bus = try std.fmt.parseInt(usize, bus_str, 10);
        try times_list.append(.{ .first = bus, .second = rel_pos });
    }

    std.sort.sort(Pair, times_list.items, {}, sort_desc_by_period);

    const max = times_list.items[0].first;
    const max_offset = times_list.items[0].second;
    var timestamp = 2 * max - max_offset; // start from some value > 0 that satisfies n0
    var prev_ts: usize = timestamp;
    var step: usize = max;
    for (times_list.items[1..]) |item| {
        while ((timestamp + item.second) % item.first != 0) {
            timestamp += step;
        }
        step *= item.first;
    }

    return timestamp;
}

fn sort_desc_by_period(ctx: void, lhs: Pair, rhs: Pair) bool {
    return lhs.first > rhs.first;
}
