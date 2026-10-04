// Guard concepts for the v5 scraper. Body, cap and blade are v5's; only the guard changes.
include <v5lib.scad>

concept = 1;       // 0 = v4/v5 guard, 1 = wedge, 2 = raked, 3 = short sleeve
view = "assembly"; // assembly, guard, print, clash

// The guard slides on from the front. Inside it needs: the 62 mm blade slot the whole way (the
// cutting edge passes the mouth), the low "cap zone" over the cap walls (up to lip_top), and a
// narrower "crown zone" over the head (up to the nose slope). Outside is free: v4 hulled the
// whole thing into a box at the full mouth height.
function crown_hw(x) = hw(x) - dt + 0.6;          // head band + clearance
function cap_zone_top() = lip_top + guard_clear;
function crown_top(x) = x < 20 ? g_top(x) : max(g_top(x), h_at(x) + guard_clear);   // nose slope (the head is clipped to it) / head top

// interior; xm = mouth position at the bottom, xt = at the top (raked mouth when xt > xm)
module g_inner(xm, xt) {
    x1 = max(xm, xt) + 1;
    translate([-0.5, -g_hw, g_slot_z0]) cube([x1 + 0.5, 2 * g_hw, g_slot_z1 - g_slot_z0]);       // blade slot
    translate([x_front + 0.5, -g_hw, g_z0]) cube([x1 - x_front, 2 * g_hw, g_slot_z1 - g_z0]);  // relief below
    // ramp from the slot into the zones, then the zones themselves
    for (zone = [0, 1]) {
        hull() {
            translate([3.5, -g_hw, g_slot_z0]) cube([0.01, 2 * g_hw, g_slot_z1 - g_slot_z0]);
            zone_slice(x_front + 0.5, zone);
        }
        // follow the head's top: the nose slope to x = 20, then the loft
        let(xs = concat([x_front + 0.5], [for (x = [20:2:x1]) if (x < x1) x], [x1]))
            for (i = [0:len(xs) - 2]) hull() { zone_slice(xs[i], zone); zone_slice(xs[i + 1], zone); }
    }
}
module zone_slice(x, zone) let(w = zone == 0 ? g_cap_hw(x) : crown_hw(x), t = zone == 0 ? cap_zone_top() : crown_top(x))
    translate([x, -w, g_z0]) cube([0.01, 2 * w, t - g_z0]);

// outer section at x: a rounded slab over the blade and cap, and a rounded crown over the head
// Outer section at x: a rounded slab over the blade and cap walls, hulled with a crown in the
// head's own superellipse style. The crown's top runs as one straight wedge line from the nose
// back to x = 20 (2.4 mm over the nose slope there), so there is no step at the cap's front.
// per-concept outer settings (dynamic so every helper sees them): $gt wall, $ct crown wall over the head,
// $gn crown superellipse exponent, $gm crown half width beyond the inner crown zone
function wedge_top(x) = lookup(x, [[-1.1, g_slot_z1 + $gt], [x_front + 0.5, cap_zone_top() + $ct],
                                   [20, crown_top(20) + $ct], [40, crown_top(40) + $ct]]);
module g_section(x, inset = 0) let(
        nose = x < x_front + 0.5,
        // side and bottom lines run straight from the nose to the cap zone: no step at the sides
        zb = lookup(x, [[-1.1, g_slot_z0 - $gt], [x_front + 0.5, g_z0 - $gt], [40, g_z0 - $gt]]) + inset,
        zs = lookup(x, [[-1.1, g_slot_z1 + $gt], [x_front + 0.5, cap_zone_top() + $gt], [40, cap_zone_top() + $gt]]) - inset,
        zt = (nose ? wedge_top(x) : $open ? min(wedge_top(x), cap_zone_top() + $gt) : max(wedge_top(x), crown_top(x) + $ct)) - inset,
        ws = g_hw + $gt - inset, wc = crown_hw(x) + $gm - inset, r = 1.4)
    hull() {
        for (s = [-1, 1]) {
            translate([s * (ws - r), zb + r]) circle(r);
            translate([s * (ws - r), zs - r]) circle(r);
        }
        intersection() {
            polygon(se(2 * wc, zt, $gn, 64));
            translate([-wc, zb]) square([2 * wc, zt - zb]);
        }
    }
module g_slice(x, inset = 0) translate([x, 0, 0]) rotate([90, 0, 90]) linear_extrude(0.01) g_section(x, inset);

module g_outer(xm, xt) {
    x0 = -0.5 - $gt;
    xs = concat([for (x = [x0 + 1:1:max(xm, xt) - 0.5]) x], [max(xm, xt)]);
    hull() { g_slice(x0, 1); g_slice(xs[0]); }
    for (i = [0:len(xs) - 2]) hull() { g_slice(xs[i]); g_slice(xs[i + 1]); }
}
// raked mouth: plane through (xm, bottom) and (xt, top)
module rake_cut(xm, xt) let(zb = g_z0 - $gt - 1, zt = crown_top(xt) + $gt + 1)
    rotate([90, 0, 0]) linear_extrude(200, center = true)
        polygon([[xm, zb], [xt, zt], [xt + 40, zt], [xt + 40, zb]]);

module guard_c(xm, xt) {
    $fn = 32;
    difference() {
        g_outer(xm, xt);
        g_inner(xm, xt);
        rake_cut(xm, xt);
        // open top: the guard only needs to close over the exposed blade; behind it the head shows through
        if ($open) let(x1 = max(xm, xt) + 1) hull() for (x = [x_front + 0.5, x1])
            translate([x, -crown_hw(x), g_z0]) cube([0.01, 2 * crown_hw(x), 40]);
        // lead-in chamfer at the mouth: each zone's opening flares by mouth_chamfer
        if (xm == xt) for (zone = [0, 1]) let(zp0 = g_z0 - $gt - 1, zp1 = crown_top(xt) + $gt + 1,
                                x = zone == 0 ? xm : xm + (xt - xm) * (cap_zone_top() - zp0) / (zp1 - zp0),
                                w = zone == 0 ? g_cap_hw(x) : crown_hw(x), t = zone == 0 ? cap_zone_top() : crown_top(x))
            hull() {
                zone_slice(x - mouth_chamfer - 0.5, zone);
                translate([x + 0.5, -(w + mouth_chamfer + 0.5), g_z0 - mouth_chamfer - 0.5])
                    cube([0.01, 2 * (w + mouth_chamfer + 0.5), t - g_z0 + 2 * mouth_chamfer + 1]);
            }
    }
    // friction bumps on the cap walls, above the blade slot (as v4)
    for (s = [-1, 1]) translate([x_front + 4, s * g_cap_hw(x_front + 4), (g_slot_z1 + lip_top) / 2]) sphere(0.75, $fn = 16);
}

// ---- concepts: [mouth x at the bottom, mouth x at the top] ----
mouths = [[18, 18], [18, 18], [15.5, 21], [12, 12], [18, 18], [18, 18], [15, 15]];
// [wall, crown wall, exponent, crown margin]; concept 4 = slim wedge
outers = [[], [guard_t, 2.4, 8, 3, false], [guard_t, 2.4, 8, 3, false], [guard_t, 2.4, 8, 3, false], [1.2, 1.6, 10, 3.5, false], [1.2, 1.2, 10, 3.5, true], [1.2, 1.6, 10, 3.5, false]];
module guard_sel(c) {
    if (c == 0) guard();
    else let($gt = outers[c][0], $ct = outers[c][1], $gn = outers[c][2], $gm = outers[c][3], $open = outers[c][4]) guard_c(mouths[c][0], mouths[c][1]);
}

module model(c = concept, v = view) {
    if (v == "guard") guard_sel(c);
    else if (v == "clash") { intersection() { guard_sel(c); body(); } intersection() { guard_sel(c); blade(); } }
    else {
        color("#8fb3d9") body(); color("#e8a33d") cap(); blade(); color("#5cb88a") drawer();
        color("#5d9e72") guard_sel(c);
    }
}
if (view != "none") model();
