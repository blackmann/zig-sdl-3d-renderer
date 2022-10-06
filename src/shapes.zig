const vectors = @import("vectors.zig");
const std = @import("std");

pub const Rect = struct { width: u32, height: u32 };

const gap: i32 = 10;

pub fn createCube(width: u32, height: u32, depth: u32, allocator: std.mem.Allocator) ![]vectors.Vec3 {
    // we place the anchor point at the center of the cube
    // meaning we start from -(l/2) to (l/2) where l is width, height, or depth
    var cube: []vectors.Vec3 = try allocator.alloc(vectors.Vec3, width * height * depth);

    var pos: usize = 0;

    const w_half = @intCast(i32, (width / 2));
    var x: i32 = -w_half;
    var max_x: i32 = w_half;

    while (x < max_x) : (x += 1) {
        const h_half = @intCast(i32, (height / 2));
        var y: i32 = -1 * h_half;
        var max_y: i32 = h_half;

        while (y < max_y) : (y += 1) {
            const d_half = @intCast(i32, (depth / 2));
            var z: i32 = -1 * d_half;
            var max_z: i32 = d_half;

            while (z < max_z) : (z += 1) {
                cube[pos] = .{ .x = x * gap, .y = y * gap, .z = z * gap };
                pos += 1;
            }
        }
    }

    return cube;
}

test "create cube" {
    const side = 3;
    const cube = try createCube(side, side, side, std.testing.allocator);
    defer std.testing.allocator.free(cube);

    try std.testing.expect(cube[0].x == -10);
    try std.testing.expect(cube[1].z == 0);
    try std.testing.expect(cube.len == side * side * side);
}
