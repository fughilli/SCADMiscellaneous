function normalize(v) = v / (sqrt(v[0] * v[0] + v[1] * v[1]));

module voronoi(points, L = 200, thickness = 1, round = 6, nuclei = true) {
    for (p = points) {
        difference() {
            minkowski() {
                intersection_for(p1 = points){
                    if (p != p1) {
                        angle = 90 + atan2(p[1] - p1[1], p[0] - p1[0]);

                        translate((p + p1) / 2 - normalize(p1 - p) *
                                  (thickness + round))
                        rotate([0, 0, angle])
                        translate([-L, -L])
                        square([2 * L, L]);
                    }
                }
                circle(r = round, $fn = 20);
            }
            if (nuclei)
                translate(p) circle(r = 1, $fn = 20);
        }
    }
}

module random_voronoi(n = 20, nuclei = true, L = 200, thickness = 1, round = 6,
                      min = 0, max = 100, seed = undef, center = false) {
    seed = seed == undef ? rands(0, 100, 1)[0] : seed;
    echo("Seed", seed);

    // Generate points.
    x = rands(min, max, n, seed);
    y = rands(min, max, n, seed + 1);
    points = [ for (i = [0 : n - 1]) [x[i], y[i]] ];

    // Center Voronoi.
    offset_x = center ? -(max(x) - min(x)) / 2 : 0;
    offset_y = center ? -(max(y) - min(y)) / 2 : 0;
    translate([offset_x, offset_y])

    voronoi(points, L = L, thickness = thickness, round = round,
            nuclei = nuclei);
}

// example with an explicit list of points:
point_set = [
    [0, 0], [30, 0], [20, 10], [50, 20], [15, 30], [85, 30], [35, 30], [12, 60],
    [45, 50], [80, 80], [20, -40], [-20, 20], [-15, 10], [-15, 50]
];
//voronoi(points = point_set, round = 4, nuclei = true);

module voronoi_slab(n = 32, thickness = 3, edge_thickness = 3, border = 3,
                    round = 0.5, width = 200, height = 200, seed = undef) {
    seed = seed == undef ? rands(0, 100, 1)[0] : seed;

    x = rands(0, width, n, seed);
    y = rands(0, height, n, seed + 1);
    points = [ for (i = [0 : n - 1]) [x[i], y[i]] ];

    union() {
        difference() {
            cube([width, height, thickness]);
            translate([border, border, -0.5]) {
                cube([width - border * 2, height - border * 2, thickness + 1]);
            }
        }
        difference() {
            translate([border/2, border/2, 0]) {
                cube([width - border, height - border, thickness]);
            }
            translate([0,0,-0.5]) {
                linear_extrude(thickness + 1) {
                    voronoi(points, L = sqrt(pow(width, 2) + pow(height, 2)),
                            thickness = edge_thickness / 2, round = round,
                            nuclei = false);
                }
            }
        }
    }
}

thick = 1.5;
density = 0.003;
width = 150;
depth = 60;
height = 45;
slab_thickness = 4;

rotate([90,0,0])
translate([0,0,-thick])
voronoi_slab(thickness = thick, edge_thickness = thick, border = thick,
             n = round(width * height * density), width = width,
             height = height - slab_thickness - 1);

translate([0,depth-thick,0])
rotate([90,0,0])
translate([0,0,-thick])
voronoi_slab(thickness = thick, edge_thickness = thick, border = thick,
             n = round(width * height * density), width = width,
             height = height - slab_thickness - 1);

translate([width-thick,0,0])
rotate([0,0,90])
rotate([90,0,0])
voronoi_slab(thickness = thick, edge_thickness = thick, border = thick,
             n = round(depth * height * density), width = depth,
             height = height - slab_thickness - 1);

rotate([0,0,90])
rotate([90,0,0])
voronoi_slab(thickness = thick, edge_thickness = thick, border = thick,
             n = round(depth * height * density), width = depth,
             height = height - slab_thickness - 1);

translate([0,0,height - slab_thickness])
cube([width,depth,slab_thickness]);

translate([1,1,height - slab_thickness - 1])
cube([width - 2,depth - 2,2]);
