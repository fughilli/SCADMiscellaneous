gap = 10; // mm
width = 10; // mm
depth = 5; // mm
thickness = 3; // mm
radius = 6; // mm
inset_y = 3; // mm
inset_x = 3; // mm
difference()
{
scale([width + thickness, gap + thickness * 2, depth])
{
    cube();
}
union()
{
translate([thickness, thickness, -thickness])
scale([width + thickness, gap, depth + thickness * 2])
{
    cube();
}
translate([width - inset_x, thickness + gap - inset_y, -thickness])
scale([radius, radius, depth])
cylinder();
}
}
