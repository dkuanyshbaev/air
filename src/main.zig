const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const http = std.debug.http;

pub fn main() void {
	std.debug.print("{s}\n", .{"ok"});
}
