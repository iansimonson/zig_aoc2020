const std = @import("std");
const print = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = &gpa.allocator;

const Range = struct {
    min: usize,
    max: usize,
};

const Rule = struct {
    lower_range: Range,
    upper_range: Range,
};

const INVALID_RANGE = Range{.min = 0, .max = 0};

const RuleMap = std.StringHashMap(Rule);

var rules = RuleMap.init(alloc);

fn in_range(v: usize, r: Range) bool {
    return v >= r.min and v <= r.max;
}

fn rule_valid(v: usize, r: Rule) bool {
    return in_range(v, r.lower_range) or in_range(v, r.upper_range);
}

pub fn main() !void {
    defer _ = gpa.deinit();
    defer rules.deinit();

    const inputData = try std.fs.cwd().readFileAlloc(alloc, "input", std.math.maxInt(u64));
    defer alloc.free(inputData);

    var sections = std.mem.split(inputData, "\n\n");
    var rule_section = sections.next().?;
    var rules_it = std.mem.split(rule_section, "\n");
    while (rules_it.next()) |rule| {
        const colon = std.mem.indexOf(u8, rule, ":").?;
        const or_str = std.mem.indexOfPos(u8, rule, colon, "or").?;

        const rule_name = rule[0..colon];
        const lower_range = rule[colon + 2 .. or_str - 1];
        const upper_range = rule[or_str + 3 ..];
        var lr_it = std.mem.split(lower_range, "-");
        var ur_it = std.mem.split(upper_range, "-");

        const lower_min = try std.fmt.parseInt(usize, lr_it.next().?, 10);
        const lower_max = try std.fmt.parseInt(usize, lr_it.next().?, 10);
        const upper_min = try std.fmt.parseInt(usize, ur_it.next().?, 10);
        const upper_max = try std.fmt.parseInt(usize, ur_it.next().?, 10);

        try rules.put(
            rule_name,
            Rule{
                .lower_range = Range{ .min = lower_min, .max = lower_max },
                .upper_range = Range{ .min = upper_min, .max = upper_max },
            },
        );
    }

    var your_ticket = sections.next().?;
    var other_tickets = sections.next().?;

    const p1 = try solve(your_ticket, other_tickets);

    print("P1: {}\nP2: {}\n", .{p1.p1, p1.p2});

}

const Sln = struct {
    p1: usize,
    p2: usize,
};

fn solve(m_ticket: []const u8, tickets: []const u8) !Sln {

    // there are no numbers > 999
    var valid_numbers = [_]bool{false} ** 1000;

    var rules_it = rules.iterator();
    while (rules_it.next()) |r| {
        var i = r.value.lower_range.min;
        while (i <= r.value.lower_range.max) : (i += 1) {
            valid_numbers[i] = true;
        }
        i = r.value.upper_range.min;
        while (i <= r.value.upper_range.max) : (i += 1) {
            valid_numbers[i] = true;
        }
    }

    var valid_tickets = std.ArrayList([]const u8).init(alloc);
    defer valid_tickets.deinit();

    var err_code: usize = 0;
    var t_it = std.mem.split(tickets, "\n");
    _ = t_it.next(); // remove "Other tickets:"
    while(t_it.next()) |ticket| {
        var f_it = std.mem.split(ticket, ",");
        var valid: bool = true;
        while(f_it.next()) |field| {
            const f_value = try std.fmt.parseInt(usize, field, 10);
            if (!valid_numbers[f_value]) {
                err_code += f_value;
                valid = false;
            }
        }
        if (valid) {
            try valid_tickets.append(ticket);
        }
    }

    var possible_values = std.ArrayList(std.ArrayList([]const u8)).init(alloc);
    defer {
        for (possible_values.items) |*item| {
            item.deinit();
        }
        possible_values.deinit();
    }

    const ticket = valid_tickets.items[0];
    var num_fields: usize = 0;
    var f_it = std.mem.split(ticket, ",");
    while (f_it.next()) |_| {
        num_fields += 1;
    }

    var i: usize = 0;
    while (i < num_fields) : (i += 1) {
        var possible_fields = std.ArrayList([]const u8).init(alloc);
        var it = rules.iterator();
        while (it.next()) |rule| {
            try possible_fields.append(rule.key);
        } 
        try possible_values.append(possible_fields);
    }

    for (valid_tickets.items) |v_ticket| {
        var it = std.mem.split(v_ticket, ",");
        var j: usize = 0;
        while (it.next()) |field| : (j += 1) {
            const f_value = try std.fmt.parseInt(usize, field, 10);
            var k:usize = 0;
            while (k < possible_values.items[j].items.len) {
                const rule = possible_values.items[j].items[k];
                const rule_ranges = rules.get(rule).?;
                if (!rule_valid(f_value, rule_ranges)) {
                    _ = possible_values.items[j].orderedRemove(k);
                } else {
                    k += 1;
                }
            }
        }
    }

    while (true) {
        var single_solution: bool = true;
        for (possible_values.items) |*pv, idx| {
            if (pv.items.len == 1) {
                const field_name = pv.items[0];
                var index: usize = 0;
                while (index < possible_values.items.len) : (index += 1) {
                    if (index == idx) { continue; }
                    for (possible_values.items[index].items) |itm, j_idx| {
                        if (std.mem.eql(u8, field_name, itm)) {
                            _ = possible_values.items[index].orderedRemove(j_idx);
                            single_solution = false;
                            break;
                        }
                    }
                }
            }
        }

        if (single_solution) { break; }
    }

    const DEP = "departure";
    i = 0;
    var product: usize = 1;
    var m_ticket_sec_it = std.mem.split(m_ticket, "\n");
    _ = m_ticket_sec_it.next().?;
    var my_ticket_it = std.mem.split(m_ticket_sec_it.next().?, ",");
    while (i < possible_values.items.len) : (i += 1) {
        const f_value = try std.fmt.parseInt(usize, my_ticket_it.next().?, 10);
        std.debug.assert(possible_values.items[i].items.len == 1);
        const field_name = possible_values.items[i].items[0];
        if (std.mem.eql(u8, field_name[0..std.math.min(DEP.len, field_name.len)], DEP[0..])) {
            product *= f_value;
        }
    }

    return Sln{.p1 = err_code, .p2 = product};
}
