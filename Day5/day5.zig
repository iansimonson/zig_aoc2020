const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    var seats = try std.ArrayList(usize).initCapacity(alloc, 1000);
    defer seats.deinit();

    var lines = std.mem.split(inputData, "\n");

    var max_id: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) { continue; }
        const id = seatId(line);
        try seats.append(id);
        max_id = std.math.max(max_id, id);
    }
    std.debug.print("p1: {}\n", .{max_id});

    std.sort.sort(usize, seats.items, {}, less);

    var prev_seat: usize = seats.items[0];
    for (seats.items[1..]) |seat| {
        if (seat != prev_seat + 1) {
            std.debug.print("p2: {}\n", .{seat - 1});
            std.debug.assert(seat == prev_seat + 2);
            return;
        }
        prev_seat = seat;
    }

}

fn less(nothing: void, l: usize, r: usize) bool {
    return l < r;
}

fn seatId(boarding_pass: []const u8) usize {
    var row: usize = 0;
    var col: usize = 0;

    var power: usize = 64;
    for (boarding_pass[0..7]) |r| {
        if (r == 'B') {
            row += power;
        }
        power >>= 1;
    }

    power = 4;

    for (boarding_pass[7..]) |c| {
        if (c == 'R') {
            col += power;
        }
        power >>= 1;
    }

    return row * 8 + col;
}