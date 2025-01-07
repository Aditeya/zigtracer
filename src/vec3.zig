const std = @import("std");

pub const Point3 = Vec3;
pub const Color = Vec3;

pub const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub const default: Vec3 = .{
        .x = 0.0,
        .y = 0.0,
        .z = 0.0,
    };

    pub fn init(x: f64, y: f64, z: f64) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn clone(self: Vec3) Vec3 {
        return Vec3{
            .x = self.x,
            .y = self.y,
            .z = self.z,
        };
    }

    pub fn negate(self: *Vec3) void {
        self.x = -self.x;
        self.y = -self.y;
        self.z = -self.z;
    }

    pub fn get(self: Vec3, idx: usize) f64 {
        comptime {
            switch (idx) {
                0 => return self.x,
                1 => return self.y,
                2 => return self.z,
                _ => @compileError("Function must be called with 0, 1, or 2 arguments"),
            }
        }
    }

    pub fn add_v(self: *Vec3, other: *Vec3) void {
        self.x += other.x;
        self.y += other.y;
        self.z += other.z;
    }

    pub fn multiply_t(self: *Vec3, t: f64) void {
        self.x *= t;
        self.y *= t;
        self.z *= t;
    }

    pub fn divide_t(self: *Vec3, t: f64) void {
        self.x /= t;
        self.y /= t;
        self.z /= t;
    }

    pub fn length_squared(self: Vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn length(self: Vec3) f64 {
        return @sqrt(self.length_squared());
    }

    pub fn format(
        self: Vec3,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = try writer.print("{d} ", .{self.x});
        _ = try writer.print("{d} ", .{self.y});
        _ = try writer.print("{d}\n", .{self.z});
    }

    pub fn add_vv(self: Vec3, rhs: Vec3) Vec3 {
        return Vec3.init(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z);
    }

    pub fn sub_vv(self: Vec3, rhs: Vec3) Vec3 {
        return Vec3.init(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z);
    }

    pub fn multiply_tv(self: Vec3, t: f64) Vec3 {
        var s = self.clone();
        s.multiply_t(t);
        return s;
    }

    pub fn divide_tv(self: Vec3, t: f64) Vec3 {
        var s = self.clone();
        s.divide_t(t);
        return s;
    }

    pub fn dot_vv(self: Vec3, v: Vec3) f64 {
        return self.x * v.x +
            self.y * v.y +
            self.z * v.z;
    }

    pub fn cross_vv(self: Vec3, v: Vec3) Vec3 {
        return Vec3.init(self.y * v.z - self.z * v.y, self.z * v.x - self.x * v.z, self.x * v.y - self.y * v.x);
    }

    pub fn unitVector_v(self: Vec3) Vec3 {
        const l = self.length();
        var uv = self.clone();
        uv.divide_t(l);
        return uv;
    }
};

pub fn write_color_to_str(
    allocator: std.mem.Allocator,
    pixel_color: Color,
) ![]u8 {
    var color = pixel_color.clone();
    color.multiply_t(255.999);
    const r = @as(u8, @intFromFloat(color.x));
    const g = @as(u8, @intFromFloat(color.y));
    const b = @as(u8, @intFromFloat(color.z));

    const pixel = try std.fmt.allocPrint(allocator, "{d} {d} {d}\n", .{ r, g, b });
    return pixel;
}
