const std = @import("std");

const root = @import("root.zig");
const vec3 = root.Vec3;
const Vec3 = root.Vec3.Vec3;
const Color = root.Vec3.Color;
const Point3 = root.Vec3.Point3;
const Ray = root.Ray.Ray;

// Image
const ASPECT_RATIO: f64 = 16.0 / 9.0;
const IMAGE_WIDTH: u32 = 400;
const IMAGE_HEIGHT = blk: {
    // int image_height = int(image_width / aspect_ratio);
    // image_height = (image_height < 1) ? 1 : image_height;
    const w = @as(f64, @floatFromInt(IMAGE_WIDTH));
    const r = @as(u32, @intFromFloat(w / ASPECT_RATIO));
    break :blk @max(1, r);
};

// Camera
const FOCAL_LENGTH: f64 = 1.0;
const VIEWPORT_HEIGHT: f64 = 2.0;
const VIEWPORT_WIDTH = blk: {
    // viewport_height * (double(image_width)/image_height);
    const iw = @as(f64, @floatFromInt(IMAGE_WIDTH));
    const ih = @as(f64, @floatFromInt(IMAGE_HEIGHT));
    const r = iw / ih;
    break :blk VIEWPORT_HEIGHT * r;
};
const CAMERA_CENTER = Point3.default;

// Calculate the vectors across the horizontal and down the vertical viewport edges.
const VIEWPORT_U = Vec3.init(VIEWPORT_WIDTH, 0, 0);
const VIEWPORT_V = Vec3.init(0, -VIEWPORT_HEIGHT, 0);

// Calculate the horizontal and vertical delta vectors from pixel to pixel.
const PIXEL_DELTA_U = VIEWPORT_U.divide_tv(IMAGE_WIDTH);
const PIXEL_DELTA_V = VIEWPORT_V.divide_tv(IMAGE_HEIGHT);

// Calculate the location of the upper left pixel.
const VIEWPORT_UPPER_LEFT = blk: {
    // camera_center - vec3(0, 0, focal_length) - viewport_u/2 - viewport_v/2;
    const a = CAMERA_CENTER.sub_vv(Vec3.init(0, 0, FOCAL_LENGTH));
    const b = a.sub_vv(VIEWPORT_U.divide_tv(2));
    const c = b.sub_vv(VIEWPORT_V.divide_tv(2));
    break :blk c;
};
const PIXEL00_LOC = blk: {
    var result = PIXEL_DELTA_U.add_vv(PIXEL_DELTA_V);
    result.multiply_t(0.5);
    break :blk result.add_vv(VIEWPORT_UPPER_LEFT);
};

fn hit_sphere(center: Point3, radius: f64, r: Ray) f64 {
    const oc: Vec3 = center.sub_vv(r.origin);
    const a = r.dir.length_squared();
    const h = r.dir.dot_vv(oc);
    const c = oc.length_squared() - radius*radius;
    const discriminant = h*h - a*c;

    if (discriminant < 0) {
        return -1.0;
    } else {
        return (h - @sqrt(discriminant)) / a;
    }
}

fn ray_color(ray: Ray) Color {
    const t = hit_sphere(Point3.init(0.0,0.0,-1.0), 0.5, ray);
    if (t > 0.0) {
        const N = ray.at(t).sub_vv(Vec3.init(0.0, 0.0, -1.0)).unitVector_v();
        return Color.init(N.x+1.0, N.y+1.0, N.z+1.0).multiply_tv(0.5);
    }

    const unit_direction = ray.dir.unitVector_v();
    const a = 0.5 * (unit_direction.y + 1.0);
    return Color.init(1.0, 1.0, 1.0).multiply_tv(1.0 - a).add_vv(Color.init(0.5, 0.7, 1.0).multiply_tv(a));
}

pub fn main() !void {
    // Allocator setup
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    std.log.info("Starting Render\n", .{});

    // Create/Overwrite File
    const file = try std.fs.cwd().createFile("image.ppm", .{});

    // PPM Header
    const header = try std.fmt.allocPrint(allocator, "P3\n{d} {d}\n255\n", .{ IMAGE_WIDTH, IMAGE_HEIGHT });
    try file.writeAll(header);
    allocator.free(header);

    for (0..IMAGE_HEIGHT) |j| {
        std.log.info("Scanlines remaining: {d:0>3} ", .{IMAGE_HEIGHT - j});
        for (0..IMAGE_WIDTH) |i| {
            const pixel_center = PIXEL00_LOC
                .add_vv(PIXEL_DELTA_U.multiply_tv(@as(f64, @floatFromInt(i))))
                .add_vv(PIXEL_DELTA_V.multiply_tv(@as(f64, @floatFromInt(j))));
            const ray_direction = pixel_center.sub_vv(CAMERA_CENTER);
            const r = Ray.init(CAMERA_CENTER, ray_direction);

            const pixel_color = ray_color(r);

            // PPM Pixel
            const pixel = try vec3.write_color_to_str(allocator, pixel_color);
            defer allocator.free(pixel);
            try file.writeAll(pixel);
        }
    }

    // close file
    defer file.close();

    std.log.info("\rRender Complete!\n", .{});
}
