const std = @import("std");
const print = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const MemMap = std.AutoHashMap(usize, usize);

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);
 
    const p1 = part1(inputData);
    const p2 = part2(inputData);

    std.debug.print("{}\n", .{p1});
    std.debug.print("{}\n", .{p2});
}

fn part1(inputData: []const u8) !usize {
    var lines = std.mem.split(inputData, "\n");

    var and_mask: usize = 0;
    var or_mask: usize = 0;

    var memory = MemMap.init(alloc);
    defer memory.deinit();

    while (lines.next()) |line| {
        if (std.mem.eql(u8, line[0..3], "mas")) {
            const mask = line[7..];
            std.debug.assert(mask.len == 36);
            and_mask = 0;
            or_mask = 0;
            for (mask) |bit| {
                and_mask <<= 1;
                or_mask <<=1;
                switch (bit) {
                    'X' => {
                        and_mask += 1;
                    },
                    '1' => {
                        and_mask += 1;
                        or_mask += 1;
                    },
                    '0' => {
                    },
                    else => @panic("HELP"),
                }
            }
        } else if (std.mem.eql(u8, line[0..3], "mem")) {
            const start = std.mem.indexOf(u8, line, "[").? + 1;
            const end = std.mem.indexOf(u8, line, "]").?;
            const eql = std.mem.indexOf(u8, line, "=").?;
            const mem_loc = try std.fmt.parseInt(usize, line[start..end], 10);
            var value = try std.fmt.parseInt(usize, line[eql + 2..], 10);
            value |= or_mask;
            value &= and_mask;

            try memory.put(mem_loc, value);
        } else {
            print("LINE: {}\n", .{line});
            @panic("Unknown command");
        }
    }

    var it = memory.iterator();
    var sum: usize = 0;
    while (it.next()) |loc| {
        sum += loc.value;
    }
    return sum;
}

fn part2(inputData: []const u8) !usize {
    var lines = std.mem.split(inputData, "\n");

    var and_mask: usize = 0;
    var or_mask: usize = 0;

    var memory = MemMap.init(alloc);
    defer memory.deinit();

    var masks = std.ArrayList(usize).init(alloc);
    defer masks.deinit();
    try masks.append(0);
    var x_mask: usize = 0; // where the x's are

   while (lines.next()) |line| {
        if (std.mem.eql(u8, line[0..3], "mas")) {
            // print("Mask: {}\n", .{line[7..]});
            try masks.resize(1);
            x_mask = 0;
            masks.items[0] = 0;
            const mask = line[7..];
            std.debug.assert(mask.len == 36);
            for (mask) |bit| {
                for (masks.items) |*el| {
                    el.* <<= 1;
                }
                x_mask <<= 1;

                switch (bit) {
                    'X' => {
                        const cur_len = masks.items.len;
                        var i: usize = 0;
                        while (i < cur_len) : (i += 1) {
                            try masks.append(masks.items[i]); // append a "zero" version
                            masks.items[i] += 1; // make this a "1" version
                        }
                        x_mask += 1;
                    },
                    '1' => {
                        for (masks.items) |*m| {
                            m.* += 1;
                        }
                    },
                    '0' => {
                    },
                    else => @panic("HELP"),
                }
            }
            // print("X_MA: {b:0>36}\n", .{x_mask});
            // print("N_MA: {b:0>36}\n", .{~x_mask & 0x0000000FFFFFFFFF});
        } else if (std.mem.eql(u8, line[0..3], "mem")) {
            const start = std.mem.indexOf(u8, line, "[").? + 1;
            const end = std.mem.indexOf(u8, line, "]").?;
            const eql = std.mem.indexOf(u8, line, "=").?;
            var mem_loc = try std.fmt.parseInt(usize, line[start..end], 10);
            // ("Mem loc: {}\n", .{mem_loc});
            // print("Mem loc x: {}\n", .{mem_loc & ~x_mask});
            var value = try std.fmt.parseInt(usize, line[eql + 2..], 10);

            // print("N_XMSK: {b:0>36}\n", .{~x_mask & 0x0000000FFFFFFFFF});
            // print("MEMLOC: {b:0>36}\n", .{mem_loc});
            mem_loc &= ~x_mask;
            // print("NEWMEM: {b:0>36}\n", .{mem_loc});
            for (masks.items) |m| {
                const new_mem_loc = mem_loc | m;
                try memory.put(new_mem_loc, value);
            }
        } else {
            print("LINE: {}\n", .{line});
            @panic("Unknown command");
        }
    }

    var it = memory.iterator();
    var sum: usize = 0;
    while (it.next()) |loc| {
        sum += loc.value;
    }
    return sum;
}