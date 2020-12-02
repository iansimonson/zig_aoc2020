const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const DataArray = std.ArrayList(u32);

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);


    const p1_count = try part1(inputData);
    const p2_count = try part2(inputData);
    std.debug.print("Part 1: {}\n", .{p1_count});
    std.debug.print("Part 2: {}\n", .{p2_count});
}

fn part1(input: []const u8) !usize {
    var it = std.mem.split(input, "\n");

    var count: usize = 0;
    while (it.next()) |line| {
        if(line.len == 0) { continue; }
        
        var line_it = std.mem.split(line, " ");
        const range = line_it.next().?;

        var range_it = std.mem.split(range, "-");
        const min = try std.fmt.parseInt(i64, range_it.next().?, 10);
        const max = try std.fmt.parseInt(i64, range_it.next().?, 10);

        const letter = line_it.next().?;

        const password = line_it.next().?;

        const letter_count = std.mem.count(u8, password, letter[0..1]);
        if (letter_count >= min and letter_count <= max) {
            count +=1;
        }
    }

    return count;
}

fn part2(input: []const u8) !usize {
    var it = std.mem.split(input, "\n");

    var count: usize = 0;
    while (it.next()) |line| {
        if(line.len == 0) { continue; }
        
        var line_it = std.mem.split(line, " ");
        const range = line_it.next().?;

        var range_it = std.mem.split(range, "-");
        const pos1 = try std.fmt.parseInt(usize, range_it.next().?, 10);
        const pos2 = try std.fmt.parseInt(usize, range_it.next().?, 10);

        const letter = line_it.next().?;

        const password = line_it.next().?;

        const at_pos_1 = @as(u64, @boolToInt(password[pos1 - 1] == letter[0]));
        const at_pos_2 =  @as(u64, @boolToInt(password[pos2-1] == letter[0]));

        if (at_pos_1 ^ at_pos_2 != 0) {
            count += 1;
        }
    }

    return count;
}