const std = @import("std");
const expect = std.testing.expect;
const magz = @import("magz.zig");

test "to C string" {
    const home = magz.toCstr("/home/myself/me");
    try expect(home.len == 15);
}

test "to C string Bis" {
    const home = magz.toCstrBis("/home/myself/me");
    try expect(home.len == 15);
    try expect(home[14] == 'e');
}

test "MyString" {
    const my_str = magz.MyString.init("/home/myself/me");
    try expect(my_str.buf[14] == 'e');
    try expect(my_str.buf[15] == 0);
    try expect(my_str.len == 15);

    const my_str_z = magz.MyString.init("/home/myself/me");
    try expect(my_str_z.len == 15);
    try expect(my_str_z.buf[14] == 'e');
}
