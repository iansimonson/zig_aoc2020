const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const PassportCheck = struct {
    byr: bool = false,
    iyr: bool = false,
    eyr: bool = false,
    hgt: bool = false,
    hcl: bool = false,
    ecl: bool = false,
    pid: bool = false,
    //cid: bool = false, optional

    pub fn valid(p: *PassportCheck) bool {
        return p.byr and p.iyr and p.eyr and p.hgt and p.hcl and p.ecl and p.pid;
    }
};

pub fn main() !void {
    defer _ = gpa.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    const valid_p1 = part1(inputData);
    const valid_p2 = part2(inputData);
    std.debug.print("p1 {}\n", .{valid_p1});
    std.debug.print("p2 {}\n", .{valid_p2});
}

fn part1(inputData: []const u8) usize {
    var it = std.mem.split(inputData, "\n");
    var cur_passport = PassportCheck{};
    var count: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) {
            if (cur_passport.valid()) {
                count += 1;
            }
            cur_passport = PassportCheck{};
        }

        var field_it = std.mem.tokenize(line, " ");
        while (field_it.next()) |field| {
            var kv_it = std.mem.split(field, ":");
            const key = kv_it.next().?;

            if (std.mem.eql(u8, key, "byr")) {
                cur_passport.byr = true;
            } else if (std.mem.eql(u8, key, "iyr")) {
                cur_passport.iyr = true;
            } else if (std.mem.eql(u8, key, "eyr")) {
                cur_passport.eyr = true;
            } else if (std.mem.eql(u8, key, "hgt")) {
                cur_passport.hgt = true;
            } else if (std.mem.eql(u8, key, "hcl")) {
                cur_passport.hcl = true;
            } else if (std.mem.eql(u8, key, "ecl")) {
                cur_passport.ecl = true;
            } else if (std.mem.eql(u8, key, "pid")) {
                cur_passport.pid = true;
            } else if (std.mem.eql(u8, key, "cid")) {} else {
                @panic("Unknown field");
            }
        }
    }

    return count;
}

fn part2(inputData: []const u8) !usize {
    var it = std.mem.split(inputData, "\n");
    var cur_passport = PassportCheck{};
    var count: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) {
            if (cur_passport.valid()) {
                count += 1;
            }
            cur_passport = PassportCheck{};
        }

        var field_it = std.mem.tokenize(line, " ");
        while (field_it.next()) |field| {
            var kv_it = std.mem.split(field, ":");
            const key = kv_it.next().?;
            const value = kv_it.next().?;

            if (std.mem.eql(u8, key, "byr")) {
                if (value.len != 4) {
                    continue;
                }

                const year = try std.fmt.parseInt(usize, value, 10);
                cur_passport.byr = year >= 1920 and year <= 2002;
            } else if (std.mem.eql(u8, key, "iyr")) {
                if (value.len != 4) {
                    continue;
                }

                const year = try std.fmt.parseInt(usize, value, 10);
                cur_passport.iyr = year >= 2010 and year <= 2020;
            } else if (std.mem.eql(u8, key, "eyr")) {
                if (value.len != 4) {
                    continue;
                }

                const year = try std.fmt.parseInt(usize, value, 10);
                cur_passport.eyr = year >= 2020 and year <= 2030;
            } else if (std.mem.eql(u8, key, "hgt")) {
                if (value.len == 0) {
                    continue;
                }
                var p: usize = 0;
                while (p < value.len and value[p] >= '0' and value[p] <= '9') {
                    p += 1;
                }
                const height = try std.fmt.parseInt(usize, value[0..p], 10);
                if (std.mem.eql(u8, value[p..], "cm")) {
                    cur_passport.hgt = height >= 150 and height <= 193;
                } else if (std.mem.eql(u8, value[p..], "in")) {
                    cur_passport.hgt = height >= 59 and height <= 76;
                } else {
                    continue;
                }
            } else if (std.mem.eql(u8, key, "hcl")) {
                if (value.len == 0) {
                    continue;
                }

                const starts_with_hash = value[0] == '#';
                if (value[1..].len != 6) {
                    continue;
                }

                var valid: bool = true;
                for (value[1..]) |c| {
                    valid = valid and (c >= 'a' and c <= 'f') or (c >= '0' and c <= '9');
                }
                cur_passport.hcl = starts_with_hash and valid;
            } else if (std.mem.eql(u8, key, "ecl")) {
                const valid_colors = [_][]const u8{ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" };
                var valid: bool = false;
                for (valid_colors) |color| {
                    valid = valid or std.mem.eql(u8, value, color);
                }
                cur_passport.ecl = valid;
            } else if (std.mem.eql(u8, key, "pid")) {
                if (value.len != 9) {
                    continue;
                }
                var valid: bool = true;
                for (value) |d| {
                    valid = valid and (d >= '0' and d <= '9');
                }
                cur_passport.pid = valid;
            } else if (std.mem.eql(u8, key, "cid")) {} else {
                @panic("Unknown field");
            }
        }
    }

    return count;
}
