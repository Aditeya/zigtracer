const std = @import("std");

pub fn main() !void {
    // Allocator setup
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    // Constants
    const IMAGE_WIDTH: u32 = 256;
    const IMAGE_HEIGHT: u32 = 256;

    std.debug.print("=> Starting Render\n", .{});

    // Create/Overwrite File
    const file = try std.fs.cwd().createFile("image.ppm", .{});

    // PPM Header
    const header = try std.fmt.allocPrint(allocator, "P3\n{d} {d}\n255\n", .{IMAGE_HEIGHT, IMAGE_HEIGHT});
    try file.writeAll(header);

    for (0..IMAGE_HEIGHT) |j| {
        for (0..IMAGE_WIDTH) |i| {
            const r: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(IMAGE_WIDTH-1));
            const g: f32 = @as(f32, @floatFromInt(j)) / @as(f32, @floatFromInt(IMAGE_HEIGHT-1));
            const b: f32 = 0.0;

            const ir: u8 = @intFromFloat(255.999 * r);
            const ig: u8 = @intFromFloat(255.999 * g);
            const ib: u8 = @intFromFloat(255.999 * b);

            // PPM Pixel
            const pixel = try std.fmt.allocPrint(allocator, "{d} {d} {d}\n", .{ir, ig, ib});
            try file.writeAll(pixel);
        }

        // std.debug.print("=> Line {d:0>3} complete\n", .{j});
    }

    // close file
    defer file.close();

    std.debug.print("=> Render Complete!\n", .{});
}
