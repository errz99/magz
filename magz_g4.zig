const std = @import("std");
const print = std.debug.print;

pub fn sayHola(name: []const u8) void {
    print("Hola desde magz_g4, {s}\n", .{name});
}
