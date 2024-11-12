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
    const my_str = magz.MyString.init("/home/me/myself");
    try expectEqual(my_str.buf[14], 'f');
    try expectEqual(my_str.buf[15], 0);
    try expectEqual(my_str.len, 15);
    try expectEqualStrings(my_str.buf[0..my_str.len], "/home/me/myself");

    const my_str_z = magz.MyString.init("/home/me/myself");
    try expectEqual(my_str_z.len, 15);
    try expectEqual(my_str_z.buf[14], 'f');
    try expectEqual(my_str_z.len, 15);
}
