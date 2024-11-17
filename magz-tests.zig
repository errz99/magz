const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const magz = @import("magz.zig");

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

test "mkup3s" {
    const mkup = try magz.mkup3s("<span>", "hello", "</span>");
    try expectEqual(mkup.len, 18);
    try expectEqualStrings(mkup, "<span>hello</span>");
}
