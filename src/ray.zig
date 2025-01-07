const vec3 = @import("vec3.zig");
const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;

pub const Ray = struct {
    origin: Point3,
    dir: Vec3,

    pub const default: Vec3 = .{
        .origin = Point3.default,
        .dir = Vec3.default,
    };

    pub fn init(origin: Point3, direction: Vec3) Ray {
        return .{
            .origin = origin,
            .dir = direction,
        };
    }

    pub fn at(self: Ray, t: f64) Point3 {
        var dir = self.dir;
        dir.multiply_t(t);
        return self.origin.add_vv(dir);
    }
};
