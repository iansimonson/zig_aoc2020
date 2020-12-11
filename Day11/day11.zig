const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const column_size = 31;

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    var map_data = try Map.initCapacity(alloc, 1000);
    defer deinit_map(map_data);

    var it = std.mem.split(inputData, "\n");

    while (it.next()) |line| {
        var row = try std.ArrayList(u8).initCapacity(alloc, line.len);
        // std.debug.print("Line: {}\n", .{line});
        for (line) |char| {
            try row.append(char);
        }
        try map_data.append(row);
    }

    // print_map(map_data);

    const p1 = part1(map_data);
    const p2 = part2(map_data);

    std.debug.print("{}\n", .{p1});
    std.debug.print("{}\n", .{p2});
}

const Row = std.ArrayList(u8);
const Map = std.ArrayList(Row);

fn is_occupied(map: Map, row: usize, col: usize) isize {
    if ((row < 0 or row >= map.items.len) or (col < 0 or col >= map.items[0].items.len)) {
        return 0;
    }

    return if (map.items[row].items[col] == '#') 1 else 0;
}

fn p2_is_occupied(map: Map, row: isize, row_dir: isize, col: isize, col_dir: isize) isize {
    if ((row < 0 or row >= map.items.len) or (col < 0 or col >= map.items[0].items.len)) {
        return 0;
    }

    const urow = @intCast(usize, row);
    const ucol = @intCast(usize, col);

    return if (map.items[urow].items[ucol] == '#') 1 else if (map.items[urow].items[ucol] == 'L') 0 else p2_is_occupied(map, row + row_dir, row_dir, col + col_dir, col_dir);
}

fn neighbors_occupied(map: Map, row: usize, col: usize) isize {
    return is_occupied(map, row -% 1, col -% 1) + is_occupied(map, row -% 1, col) + is_occupied(map, row -% 1, col +% 1) + is_occupied(map, row, col -% 1) + is_occupied(map, row, col +% 1) + is_occupied(map, row +% 1, col -% 1) + is_occupied(map, row +% 1, col) + is_occupied(map, row +% 1, col +% 1);
}

fn p2_neighbors_occupied(map: Map, row: usize, col: usize) isize {
    const irow = @intCast(isize, row);
    const icol = @intCast(isize, col);
    return p2_is_occupied(map, irow - 1, -1, icol - 1, -1) + p2_is_occupied(map, irow - 1, -1, icol, 0) + p2_is_occupied(map, irow - 1, -1, icol + 1, 1) + p2_is_occupied(map, irow, 0, icol - 1, -1) + p2_is_occupied(map, irow, 0, icol + 1, 1) + p2_is_occupied(map, irow + 1, 1, icol - 1, -1) + p2_is_occupied(map, irow + 1, 1, icol, 0) + p2_is_occupied(map, irow + 1, 1, icol + 1, 1);
}

fn clone_map(map: Map) !Map {
    var new_map = Map.init(map.allocator);
    for (map.items) |row| {
        var new_row = Row.init(new_map.allocator);
        for (row.items) |item| {
            try new_row.append(item);
        }

        try new_map.append(new_row);
    }
    return new_map;
}

fn deinit_map(map: Map) void {
    for (map.items) |row| {
        row.deinit();
    }

    map.deinit();
}

// TODO? just keep a dirty flag in function rather than check the map
fn are_same(map: Map, m2: Map) bool {
    for (map.items) |row, r| {
        for (row.items) |item, c| {
            if (item != m2.items[r].items[c]) {
                return false;
            }
        }
    }
    return true;
}

fn print_map(map: Map) void {
    for (map.items) |row| {
        for (row.items) |el| {
            std.debug.print("{c}", .{el});
        }
        std.debug.print("\n", .{});
    }
}

fn part1(map: Map) !isize {
    var updated_map = try clone_map(map);
    defer deinit_map(updated_map);

    while (true) {
        // print_map(updated_map);
        var arena = std.heap.ArenaAllocator.init(map.allocator);
        defer arena.deinit();

        var new_map = Map.init(&arena.allocator);
        for (updated_map.items) |r| {
            var new_row = Row.init(&arena.allocator);
            for (r.items) |c| {
                try new_row.append(@as(u8, '?'));
            }
            try new_map.append(new_row);
        }

        for (updated_map.items) |row, r| {
            for (row.items) |item, c| {
                const num_occupied_neighbors = neighbors_occupied(updated_map, r, c);
                switch (item) {
                    'L' => if (num_occupied_neighbors == 0) {
                        new_map.items[r].items[c] = '#';
                    } else {
                        new_map.items[r].items[c] = item;
                    },
                    '#' => if (num_occupied_neighbors >= 4) {
                        new_map.items[r].items[c] = 'L';
                    } else {
                        new_map.items[r].items[c] = item;
                    },
                    else => {
                        new_map.items[r].items[c] = item;
                    },
                }
                // std.debug.print("r={}, c={}, value={}, neighbors={}\n", .{r, c, item, num_occupied_neighbors});
            }
        }

        if (are_same(updated_map, new_map)) {
            break;
        }

        for (updated_map.items) |*row, r| {
            for (row.items) |*item, c| {
                item.* = new_map.items[r].items[c];
            }
        }
    }

    var count: isize = 0;
    for (updated_map.items) |row| {
        for (row.items) |el| {
            if (el == '#') {
                count += 1;
            }
        }
    }

    return count;
}

fn part2(map: Map) !isize {
    var updated_map = try clone_map(map);
    defer deinit_map(updated_map);

    while (true) {
        // print_map(updated_map);
        var arena = std.heap.ArenaAllocator.init(map.allocator);
        defer arena.deinit();

        var new_map = Map.init(&arena.allocator);
        for (updated_map.items) |r| {
            var new_row = Row.init(&arena.allocator);
            for (r.items) |c| {
                try new_row.append(@as(u8, '?'));
            }
            try new_map.append(new_row);
        }

        for (updated_map.items) |row, r| {
            for (row.items) |item, c| {
                const num_occupied_neighbors = p2_neighbors_occupied(updated_map, r, c);
                switch (item) {
                    'L' => if (num_occupied_neighbors == 0) {
                        new_map.items[r].items[c] = '#';
                    } else {
                        new_map.items[r].items[c] = item;
                    },
                    '#' => if (num_occupied_neighbors >= 5) {
                        new_map.items[r].items[c] = 'L';
                    } else {
                        new_map.items[r].items[c] = item;
                    },
                    else => {
                        new_map.items[r].items[c] = item;
                    },
                }
                // std.debug.print("r={}, c={}, value={}, neighbors={}\n", .{r, c, item, num_occupied_neighbors});
            }
        }

        if (are_same(updated_map, new_map)) {
            break;
        }

        for (updated_map.items) |*row, r| {
            for (row.items) |*item, c| {
                item.* = new_map.items[r].items[c];
            }
        }
    }

    var count: isize = 0;
    for (updated_map.items) |row| {
        for (row.items) |el| {
            if (el == '#') {
                count += 1;
            }
        }
    }

    return count;
}
