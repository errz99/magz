const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const magz = @import("magz.zig");

test "MyCstr" {
    const alloc = std.testing.allocator;
    var my_str = try magz.MyCstr.init(alloc, "magarci");
    defer my_str.deinit();
    try expectEqualStrings(my_str.string(), "magarci");
    try expectEqual(my_str.size, 7);
    try expectEqual(my_str.buffer[my_str.size], 0);
}

test "MyString" {
    var my_str = magz.MyString.init("/home/me/myself");
    try expectEqual(my_str.buf[14], 'f');
    try expectEqual(my_str.buf[15], 0);
    try expectEqual(my_str.len, 15);
    try expectEqualStrings(my_str.string(), "/home/me/myself");

    const my_str_z = magz.MyString.init("/home/me/myself");
    try expectEqual(my_str_z.buf[14], 'f');
    try expectEqual(my_str_z.len, 15);

    var number_s = try magz.MyString.initFromNumber(1);
    try expectEqualStrings(number_s.string(), "1");
    try number_s.updateFromNumber(2);
    try expectEqualStrings(number_s.string(), "2");
}

test "fromCstrBuf" {
    var buffer: [128]u8 = undefined;
    const home_z: []const u8 = "/home/me/myself";
    const home_c: [*c]const u8 = @ptrCast(home_z);
    const home = magz.fromCstrBuf(&buffer, home_c);
    try expectEqual(home.len, 15);
    try expectEqual(buffer[15], 0);
    try expectEqualStrings(home, "/home/me/myself");
}

test "fromCstr" {
    const home_z: []const u8 = "/home/me/myself";
    const home_c: [*c]const u8 = @ptrCast(home_z);
    const home = magz.fromCstr(home_c);
    try expectEqual(home.len, 15);
    try expectEqualStrings(home, "/home/me/myself");
}

test "toCstr" {
    const home = magz.toCstr("/home/me/myself");
    try expectEqual(home.len, 15);
    try expectEqualStrings(home, "/home/me/myself");
}

test "toCstrBis" {
    const home = magz.toCstrBis("/home/me/myself");
    try expectEqual(home.len, 15);
    try expectEqual(home[14], 'f');
    try expectEqualStrings(home, "/home/me/myself");
}

test "iupAxBbuf" {
    var buf: [16]u8 = undefined;
    const res = try magz.iupAxBbuf(&buf, 1234, 321);
    try expectEqual(buf[4], 'x');
    try expectEqual(res, 8);
    try expectEqualStrings(buf[0..res], "1234x321");
}

test "concatStrs" {
    const home: [3][]const u8 = .{ "/home", "/me", "/myself" };
    const concat = magz.concatStrs(&home);
    try expectEqual(concat.len, 15);
    try expectEqualStrings(concat, "/home/me/myself");
}

test "concatStrsBuf" {
    var buf: [256]u8 = undefined;
    const home: [3][]const u8 = .{ "/home", "/me", "/myself" };
    const pos = magz.concatStrsBuf(&buf, &home);
    try expectEqual(pos, 15);
    try expectEqualStrings(buf[0..pos], "/home/me/myself");
}

test "mkup3s" {
    const mkup = try magz.mkup3s("<span>", "hello", "</span>");
    try expectEqual(mkup.len, 18);
    try expectEqualStrings(mkup, "<span>hello</span>");
}

test "concatArray" {
    const string = try magz.concatArray(&.{ "<span>", "hello", "</span>" });
    defer string.deinit();
    try expectEqual(string.items.len, 19);
    try expectEqualStrings(string.items[0 .. string.items.len - 1], "<span>hello</span>");
}

test "myConcatString" {
    var string = try magz.myConcatString(&.{ "<span>", "hello", "</span>" }, false);
    defer magz.myConcatStringDeinit();
    string = try magz.myConcatStringAppend("<again>", false);
    try expectEqual(string.len, 25);
    try expectEqualStrings(string, "<span>hello</span><again>");

    const string_sen = try magz.myConcatString(&.{ "<span>", "hello", "</span>" }, true);
    try expectEqual(string_sen.len, 18);
    try expectEqual(magz.concat_string.?.items[18], 0);
    try expectEqualStrings(string_sen, "<span>hello</span>");
}

test "stringColor" {
    const white = magz.stringFromRgb(&.{ 255, 255, 255 });
    try expectEqualStrings(white, "#FFFFFF");

    const black = magz.stringFromRgb(&.{ 0, 0, 0 });
    try expectEqualStrings(black, "#000000");

    const red = magz.stringFromRgb(&.{ 255, 0, 0 });
    try expectEqualStrings(red, "#FF0000");

    const green = magz.stringFromRgb(&.{ 0, 255, 0 });
    try expectEqualStrings(green, "#00FF00");

    const blue = magz.stringFromRgb(&.{ 0, 0, 255 });
    try expectEqualStrings(blue, "#0000FF");
}

test "stringColorBuf" {
    var buf_black: [8]u8 = undefined;
    var buf_white: [8]u8 = undefined;
    var buf_red: [8]u8 = undefined;
    var buf_green: [8]u8 = undefined;
    var buf_blue: [8]u8 = undefined;

    const black = try magz.stringFromRgbBuf(&buf_black, &.{ 0, 0, 0 });
    const white = try magz.stringFromRgbBuf(&buf_white, &.{ 255, 255, 255 });
    const red = try magz.stringFromRgbBuf(&buf_red, &.{ 255, 0, 0 });
    const green = try magz.stringFromRgbBuf(&buf_green, &.{ 0, 255, 0 });
    const blue = try magz.stringFromRgbBuf(&buf_blue, &.{ 0, 0, 255 });

    try expectEqualStrings(black, "#000000");
    try expectEqualStrings(white, "#FFFFFF");
    try expectEqualStrings(red, "#FF0000");
    try expectEqualStrings(green, "#00FF00");
    try expectEqualStrings(blue, "#0000FF");
}
