const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

var buf_itoa: [24]u8 = undefined;
var buf_genx: [256]u8 = undefined;
var buf_mkup: [1024]u8 = undefined;
var buf_start: [128]u8 = undefined;
var buf_end: [128]u8 = undefined;
var buf_str: [256]u8 = undefined;
var buf_color: [10]u8 = undefined;

const hex_numbers_up = "0123456789ABCDEF";
const hex_numbers_lo = "0123456789abcdef";
const BUF_SIZE = 128;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub var concat_string: ?std.ArrayList(u8) = null;

pub const Error = error{
    InvalidBuffer,
    InvalidString,
    NotHexadecimal,
};

pub const MyCstr = struct {
    allocator: Allocator = undefined,
    buffer: []u8 = undefined,
    size: usize = 0,

    pub fn init(allocator: ?Allocator, str: []const u8) !MyCstr {
        var my_allocator = gpa.allocator();
        if (allocator) |alloc| my_allocator = alloc;
        var buf_str_ = try my_allocator.alloc(u8, str.len + 1);
        @memcpy(buf_str_[0..str.len], str);
        buf_str_[str.len] = 0;

        return MyCstr{
            .allocator = my_allocator,
            .buffer = buf_str_,
            .size = str.len,
        };
    }

    pub fn string(self: *MyCstr) []const u8 {
        return self.buffer[0..self.size];
    }

    pub fn deinit(self: *MyCstr) void {
        self.allocator.free(self.buffer);
    }
};

pub const MyString = struct {
    buf: [BUF_SIZE]u8 = .{0} ** BUF_SIZE,
    len: usize,

    pub fn init(str: []const u8) MyString {
        var buf: [BUF_SIZE]u8 = undefined;
        @memcpy(buf[0..str.len], str);
        buf[str.len] = 0;

        return MyString{
            .buf = buf,
            .len = str.len,
        };
    }

    pub fn initFromNumber(i: usize) !MyString {
        const str = try itoaBuf(i);
        var buf: [BUF_SIZE]u8 = undefined;
        @memcpy(buf[0..str.len], str);
        buf[str.len] = 0;

        return MyString{
            .buf = buf,
            .len = str.len,
        };
    }

    pub fn string(self: *MyString) []const u8 {
        return self.buf[0..self.len];
    }

    pub fn stringZ(self: *MyString) [:0]const u8 {
        return self.buf[0..self.len :0];
    }

    pub fn update(self: *MyString, str: []const u8) void {
        @memcpy(self.buf[0..str.len], str);
        self.buf[str.len] = 0;
        self.len = str.len;
    }
    pub fn updateFromNumber(self: *MyString, i: usize) !void {
        const str = try itoaBuf(i);
        @memcpy(self.buf[0..str.len], str);
        self.buf[str.len] = 0;
        self.len = str.len;
    }
};

pub fn itoaBuf(num: usize) ![]const u8 {
    const result = try std.fmt.bufPrintZ(&buf_itoa, "{}", .{num});
    return buf_itoa[0..result.len];
}

pub fn mkup3s(aa: []const u8, bb: []const u8, cc: []const u8) ![]const u8 {
    const result = try std.fmt.bufPrintZ(&buf_mkup, "{s}{s}{s}", .{ aa, bb, cc });
    return buf_mkup[0..result.len :0];
}

pub fn mkupBuf(a: []const u8, b: []const u8, cc: []const u8) ![]const u8 {
    const result = try std.fmt.bufPrintZ(&buf_mkup, "{s}{s}{s}", .{ a, b, cc });
    return buf_mkup[0 .. result.len + 1];
}

pub fn mkupFs(a: []const u8, b: usize, cc: []const u8) ![]const u8 {
    const result = try std.fmt.bufPrintZ(&buf_mkup, "{s}{}{s}", .{ a, b, cc });
    return buf_mkup[0 .. result.len + 1];
}

// Better than this use std.mem.span
pub fn fromCstrBuf(buf: []u8, str: [*c]const u8) []const u8 {
    var pos: usize = 0;
    const len = buf.len;
    while (str[pos] != 0 and pos < len) {
        buf[pos] = str[pos];
        pos += 1;
    }
    buf[pos] = 0;
    return buf[0..pos];
}

// Better than this use std.mem.span
pub fn fromCstr(str: [*c]const u8) []const u8 {
    var pos: usize = 0;
    const len = buf_str.len;
    while (str[pos] != 0 and pos < len) {
        buf_str[pos] = str[pos];
        pos += 1;
    }
    buf_str[pos] = 0;
    return buf_str[0..pos];
}

pub fn toCstr(str: []const u8) []const u8 {
    var str_len = str.len;
    if (str.len >= buf_str.len) str_len = buf_str.len - 1;
    @memcpy(buf_str[0..str_len], str[0..str_len]);
    buf_str[str_len] = 0;
    return buf_str[0..str_len];
}

pub fn toCstrBis(str: []const u8) []const u8 {
    var pos: usize = 0;
    for (str) |s| {
        buf_str[pos] = s;
        if (pos < buf_str.len - 1) pos += 1 else break;
    }
    buf_str[pos] = 0;
    return buf_str[0..pos];
}

pub fn toCstrZ(str: []const u8) [:0]const u8 {
    @memcpy(buf_str[0..str.len], str);
    buf_str[str.len] = 0;
    return buf_str[0..str.len :0];
}

pub fn toCstrWithBuf(buf: []u8, str: []const u8) usize {
    @memcpy(buf[0..str.len], str);
    buf[str.len] = 0;
    return str.len;
}

// compare strings case sensitive
pub fn compare2str(str1: []const u8, str2: []const u8) bool {
    if (std.mem.eql(u8, str1, str2)) return true;
    return false;
}

pub fn iupAxB(num1: u64, num2: u64) ![]const u8 {
    return try std.fmt.bufPrintZ(&buf_str, "{}x{}", .{ num1, num2 });
}

pub fn iupAxBbuf(str: []u8, num1: u64, num2: u64) ![]const u8 {
    return try std.fmt.bufPrintZ(str, "{}x{}", .{ num1, num2 });
}

pub fn concatStrs(strs: []const []const u8) []const u8 {
    var pos: usize = 0;
    for (strs) |str| {
        if (pos + str.len >= buf_mkup.len) break;
        @memcpy(buf_mkup[pos .. pos + str.len], str);
        pos += str.len;
    }
    buf_mkup[pos] = 0;
    return buf_mkup[0..pos];
}

pub fn concatStrsBuf(buf: []u8, strs: []const []const u8) usize {
    var pos: usize = 0;
    for (strs) |str| {
        if (pos + str.len >= buf.len) break;
        @memcpy(buf[pos .. pos + str.len], str);
        pos += str.len;
    }
    buf[pos] = 0;
    return pos;
}

pub fn concatArray(strs: []const []const u8) !std.ArrayList(u8) {
    var string = std.ArrayList(u8).init(gpa.allocator());
    for (strs) |str| {
        try string.appendSlice(str);
    }
    try string.append(0);
    return string;
}

pub fn myConcatString(strs: []const []const u8, sentinel: bool) ![]const u8 {
    if (concat_string) |*string| {
        string.clearRetainingCapacity();
    } else {
        concat_string = std.ArrayList(u8).init(gpa.allocator());
    }

    for (strs) |str| {
        try concat_string.?.appendSlice(str);
    }

    if (sentinel) {
        try concat_string.?.append(0);
        return concat_string.?.items[0 .. concat_string.?.items.len - 1];
    }
    return concat_string.?.items[0..];
}

pub fn myConcatStringAppend(str: []const u8, sentinel: bool) ![]const u8 {
    if (concat_string == null) concat_string = std.ArrayList(u8).init(gpa.allocator());
    try concat_string.?.appendSlice(str);

    if (sentinel) {
        try concat_string.?.append(0);
        return concat_string.?.items[0 .. concat_string.?.items.len - 1];
    }
    return concat_string.?.items[0..];
}

pub fn myConcatStringDeinit() void {
    if (concat_string) |string| {
        string.deinit();
        concat_string = null;
    }
}

pub fn deinit() void {
    myConcatStringDeinit();
}

pub fn stringFromColor(color: []const u8) []const u8 {
    const red = color[0];
    const green = color[1];
    const blue = color[2];

    buf_color[0] = '#';
    buf_color[1] = hex_numbers_up[red / 16];
    buf_color[2] = hex_numbers_up[red % 16];
    buf_color[3] = hex_numbers_up[green / 16];
    buf_color[4] = hex_numbers_up[green % 16];
    buf_color[5] = hex_numbers_up[blue / 16];
    buf_color[6] = hex_numbers_up[blue % 16];

    if (color.len >= 4) {
        const alpha = color[3];

        buf_color[7] = hex_numbers_up[alpha / 16];
        buf_color[8] = hex_numbers_up[alpha % 16];
        buf_color[9] = 0;

        return buf_color[0..9];
    }

    buf_color[7] = 0;
    return buf_color[0..7];
}

pub fn stringFromColorBuf(buf: []u8, color: []const u8) ![]const u8 {
    if (buf.len < color.len * 2 + 2) return Error.InvalidBuffer;
    const result = stringFromColor(color);
    @memcpy(buf[0..result.len], result);
    return buf[0..result.len];
}

fn hexNumber(char: u8) !u8 {
    for (hex_numbers_up, 0..) |hex_up, i| {
        if (char == hex_up or char == hex_numbers_lo[i]) return @intCast(i);
    }
    return Error.NotHexadecimal;
}

pub fn colorFromString(str: []const u8) ![4]u8 {
    var start_point: usize = 0;
    if (str[0] == '#') start_point = 1;
    if (str.len < start_point + 6) return Error.InvalidString;

    var rgb: [4]u8 = .{ 0, 0, 0, 255 };
    var range: usize = 0;

    if (str.len <= start_point + 6) {
        range = 3;
    } else if (str.len >= start_point + 8) {
        range = 4;
    } else {
        return Error.InvalidString;
    }

    for (0..range) |i| {
        const a = try hexNumber(str[start_point + i * 2]);
        const b = try hexNumber(str[start_point + 1 + i * 2]);
        rgb[i] = a * 16 + b;
    }
    return rgb;
}
