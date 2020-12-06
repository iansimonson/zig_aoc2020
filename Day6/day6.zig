const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    const count_1 = try part1(inputData);
    const count_2 = try part2(inputData);

    std.debug.print("{}\n", .{count_1});
    std.debug.print("{}\n", .{count_2});
}

fn part1(input: []const u8) !usize {
    var count: usize = 0;

    var it = std.mem.split(input, "\n");

    var current_questions = std.StringHashMap(void).init(alloc);
    defer current_questions.deinit();

    while (it.next()) |line| {
        if (line.len == 0) {
            count += current_questions.count();
            current_questions.clearAndFree();
            continue;
        }

        for (line) |c, i| {
            try current_questions.put(line[i .. i + 1], {});
        }
    }

    return count;
}

fn part2(input: []const u8) !usize {
    var count: usize = 0;

    var it = std.mem.split(input, "\n");

    var cur_set = std.StringHashMap(usize).init(alloc);
    var cur_set_people: usize = 0;
    defer cur_set.deinit();

    while (it.next()) |line| {
        if (line.len == 0) {
            var sub_count:usize = 0;
            var cs_it = cur_set.iterator();
            while (cs_it.next()) |kv| {
                if (kv.value == cur_set_people) {
                    sub_count += 1;
                }
            }
            count += sub_count;
            cur_set.clearAndFree();
            cur_set_people = 0;
            continue;
        }

        cur_set_people += 1;

        for (line) |c, i| {
            const cur_val = cur_set.get(line[i .. i + 1]);
            if (cur_val) |val| {
                try cur_set.put(line[i .. i + 1], val + 1);
            } else {
                try cur_set.put(line[i .. i + 1], 1);
            }
        }
    }

    return count;
}
