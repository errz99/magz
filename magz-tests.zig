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
