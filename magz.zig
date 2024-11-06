const std = @import("std");
const print = std.debug.print;

var buf_itoa: [24]u8 = undefined;
var buf_genx: [256]u8 = undefined;
var buf_mkup: [1024]u8 = undefined;
var buf_start: [128]u8 = undefined;
var buf_end: [128]u8 = undefined;
var buf_str: [256]u8 = undefined;

pub fn itoaBuf(num: usize) ![]const u8 {
    const result = try std.fmt.bufPrintZ(&buf_itoa, "{}", .{num});
    return buf_itoa[0..result.len];
}

pub fn mkupBuf(a: []const u8, b: []const u8, cc: []const u8) ![]const u8 {
    const result = try std.fmt.bufPrintZ(&buf_mkup, "{s}{s}{s}", .{ a, b, cc });
    return buf_mkup[0 .. result.len + 1];
}

pub fn mkupFs(a: []const u8, b: usize, cc: []const u8) ![]const u8 {
    const result = try std.fmt.bufPrintZ(&buf_mkup, "{s}{}{s}", .{ a, b, cc });
    return buf_mkup[0 .. result.len + 1];
}

pub fn fromCstrBuf(buf: []u8, str: [*c]const u8) []const u8 {
    var pos: usize = 0;
    const len = buf.len;
    while (str[pos] != 0 and pos < len) {
        buf[pos] = str[pos];
        pos += 1;
    }
    return buf[0..pos];
}

pub fn fromCstr(str: [*c]const u8) []const u8 {
    var pos: usize = 0;
    const len = buf_str.len;
    while (str[pos] != 0 and pos < len) {
        buf_str[pos] = str[pos];
        pos += 1;
    }
    return buf_str[0..pos];
}

pub fn toCstr(str: []const u8) []const u8 {
    // var pos: usize = 0;
    // for (str) |s| {
    //     buf_str[pos] = s;
    //     pos += 1;
    // }
    // buf_str[pos] = 0;
    // return buf_str[0..pos];

    @memcpy(buf_str[0..str.len], str);
    buf_str[str.len] = 0;
    return buf_str[0..str.len];
}

pub fn toCstrWithBuf(buf: []u8, str: []const u8) usize {
    // var pos: usize = 0;
    // for (str) |s| {
    //     buf[pos] = s;
    //     pos += 1;
    // }
    // buf[pos] = 0;
    // return pos;

    @memcpy(buf[0..str.len], str);
    buf[str.len] = 0;
    return str.len;
}

// compare strings case sensitive
pub fn compare2str(str1: []const u8, str2: []const u8) bool {
    if (std.mem.eql(u8, str1, str2)) return true;
    return false;
}
