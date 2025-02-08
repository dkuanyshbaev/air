const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const http = std.http;
const json = std.json;
const testing = std.testing;

const chiang_mai = "http://api.airvisual.com/v2/city?city=Chiang%20Mai&state=Chiang%20Mai&country=Thailand&key=bb42773c-315b-4570-83bc-6046a7a061fe";

const Pollution = struct {
    ts: []const u8,
    aqius: u32,
    mainus: []const u8,
    aqicn: u32,
    maincn: []const u8,
};

const Weather = struct {
    ts: []const u8,
    tp: u32,
    pr: u32,
    hu: u32,
    ws: f32,
    wd: u32,
    ic: []const u8,
};

const Current = struct {
    pollution: Pollution,
    weather: Weather,
};

const Location = struct {
    type: []const u8,
    coordinates: []const f64,
};

const Data = struct {
    city: []const u8,
    state: []const u8,
    country: []const u8,
    location: Location,
    current: Current,
};

const Info = struct {
    status: []const u8,
    data: Data,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = try std.Uri.parse(chiang_mai);
    const buf = try allocator.alloc(u8, 1024 * 1024 * 4);
    defer allocator.free(buf);
    var req = try client.open(.GET, uri, .{
        .server_header_buffer = buf,
    });
    defer req.deinit();

    try req.send();
    try req.finish();
    try req.wait();

    assert(req.response.status == .ok);

    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(body);

    //print("{s}\n", .{body});

    const parsed = try json.parseFromSlice(Info, allocator, body, .{});
    defer parsed.deinit();
    const value = parsed.value;

    print("{s}: {d}\n", .{value.data.city,value.data.current.pollution.aqius });
}
