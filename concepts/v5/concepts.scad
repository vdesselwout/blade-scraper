// v5 handle concepts. The head, cap, guard and blade interface are v4's, unchanged.
include <v4lib.scad>

concept = 1;      // 0 = v4 reference, 1..4
view = "assembly"; // body, drawer, assembly, guard_check
pull_out = 0;      // concept 2: drawer pulled out by this much

// Catmull-Rom through control stations [x, width, height]: smooth outline, no kinks at the stations
function cr(p0, p1, p2, p3, t) = 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t
                                       + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
function spline(cp, N = 6) = let(n = len(cp))
    concat([for (i = [0:n - 2]) for (k = [0:N - 1])
        cr(cp[max(i - 1, 0)], cp[i], cp[i + 1], cp[min(i + 2, n - 1)], k / N)], [cp[n - 1]]);
function hat(cp, x) = lookup(x, [for (s = spline(cp)) [s[0], s[2]]]);

module handle_c(cp) let(st = spline(cp)) for (i = [0:len(st) - 2]) hull() { slice(st[i]); slice(st[i + 1]); }

// the v4 head features (grooves, snap dimple, nose lead-in)
module head_cuts() {
    for (s = [-1, 1]) translate([0, 0, -1]) linear_extrude(groove_depth + 1) hull() {
        translate([x_front - 3, s * notch_pitch / 2]) circle(d = groove_w);
        translate([groove_end - groove_w / 2, s * notch_pitch / 2]) circle(d = groove_w);
    }
    rotate([90, 0, 0]) linear_extrude(tab_w + 1, center = true)
        polygon([[bump_x - dimple_depth - 1, -1], [bump_x + dimple_depth + 1, -1], [bump_x, dimple_depth]]);
    rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)
        polygon([[x_front - 1, -1], [x_front + 0.6, -1], [x_front + 0.6, 0], [x_front, 0.6], [x_front - 1, 0.6]]);
}
module dish(cp, x, r = [12, 8, 6], d = 1.3) translate([x, 0, hat(cp, x) + r[2] - d]) scale(r) sphere(1, $fn = 48);

module body_c(cp, dx = 52) {
    $fn = smooth_fn;
    difference() {
        union() { head(); handle_c(cp); }
        head_cuts();
        if (dx) dish(cp, dx);
        children();
    }
}

// ---- 1: Slim. Same layout as v4, 27 mm shorter, lower and narrower, one smooth spline ----
cp1 = [[37, 46, 8.5], [52, 24, 11], [74, 26, 17], [102, 30, 21], [126, 29, 19.5], [143, 22, 14], [150, 7, 5]];

// ---- 2: Blade drawer. Spare blades lie flat in a tray that slides into the handle from the butt ----
cp2 = [[37, 46, 8.5], [52, 25, 11], [74, 28.5, 16], [104, 31, 19], [132, 30, 17], [146, 28, 15]];
cap2 = [[146, 28, 15], [150, 26.5, 13.5], [153, 22, 10.5], [155.5, 9, 5]];
ch_x0 = 80; ch_x1 = 146;          // channel, open at the butt
ch_w = 23; ch_z0 = 1.6; ch_h = 4.8;
tray_floor = 1.0; spare_n = 5;
module channel() translate([ch_x0, -ch_w / 2, ch_z0]) cube([ch_x1 - ch_x0 + 1, ch_w, ch_h]);
module drawer() {
    $fn = smooth_fn;
    tw = ch_w - 0.4; th = ch_h - 0.4;
    difference() {
        union() {
            translate([ch_x0 + 1, -tw / 2, ch_z0]) cube([ch_x1 - ch_x0, tw, th]);
            handle_c(cap2);
        }
        // trapezoid blade pocket, cutting edge against the wall, back edge towards the open middle
        translate([(ch_x0 + 1 + ch_x1) / 2, -9.5, ch_z0 + tray_floor]) linear_extrude(th)
            polygon([[-31, -0.3], [31, -0.3], [blade_back / 2 + 0.6, 19.4], [-blade_back / 2 - 0.6, 19.4]]);
        // push-up hole in the floor
        translate([(ch_x0 + 1 + ch_x1) / 2, 0, 0]) cylinder(d = 10, h = 10);
        // finger nail grip on the butt
        translate([152, 0, 15]) rotate([90, 0, 0]) cylinder(r = 6.5, h = 40, center = true);
    }
}

// ---- 3: Skeleton. Slim profile with a chamfered window through the grip ----
cp3 = [[37, 46, 8.5], [52, 24, 11], [74, 28, 17], [102, 32, 21], [128, 31, 19], [145, 24, 14], [152, 7, 5]];
module window_cut() let(x0 = 78, x1 = 126, w = 11, c = 1.6) {
    hull() for (x = [x0, x1]) translate([x, 0, -1]) cylinder(d = w, h = 40);
    // 45 deg chamfers top and bottom
    hull() for (x = [x0, x1]) { translate([x, 0, -1]) cylinder(d = w + 2 * c + 2, h = 0.01); translate([x, 0, c]) cylinder(d = w, h = 0.01); }
    for (x = [x0:2:x1]) let(zt = hat(cp3, x)) hull() {
        translate([x, 0, zt + 1]) cylinder(d = w + 2 * c + 2, h = 0.01);
        translate([x, 0, zt - c]) cylinder(d = w, h = 0.01);
    }
}

// ---- 4: Low paddle. Flat, wide palm pebble with an index-finger saddle behind the head ----
cp4 = [[37, 46, 8.5], [50, 30, 9.5], [68, 30, 12], [98, 37, 15.5], [126, 35, 14.5], [142, 27, 11], [148, 8, 5]];


// ---- 5: Blade drawer with a flowing head ----
// The head keeps everything the cap and guard touch: the sole, the tapered dovetails up to band_top, the
// grooves, the snap dimple, and the nose slope under the guard (x < 20). Everything above band_top is
// one loft from the head's full width into the grip, with the section rounding from boxy (n = 10) to
// the D-section (n = 2.5).
band_top = lip_top + 0.4;
cp5 = [[x_front, 49.4, nose_h, 10], [20, 49.4, head_h, 8], [32, 44, 10, 5], [44, 31, 10.5, 3.5],
       [56, 26, 12, 2.8], [76, 28.5, 16, 2.5], [104, 31, 19, 2.5], [132, 30, 17, 2.5], [146, 28, 15, 2.5]];
module grip_n(w, h, n) intersection() {
    polygon(se(w, h, n, 48));
    polygon([[-w / 2 + bed_chamfer, 0], [w / 2 - bed_chamfer, 0], [w / 2 + h, h + bed_chamfer], [-w / 2 - h, h + bed_chamfer]]);
}
module slice_n(st) translate([st[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(0.01) grip_n(st[1], st[2], st[3]);
module loft(cp) let(st = spline(cp)) for (i = [0:len(st) - 2]) hull() { slice_n(st[i]); slice_n(st[i + 1]); }
// under the guard the top may not rise above v4's nose slope
module guard_envelope() rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)
    polygon([[x_front - 1, -1], [x_front - 1, nose_h], [x_front, nose_h], [20, head_h], [20, 100], [300, 100], [300, -1]]);
// dovetail band ends flush with the cap's back (x = cap_end), rear corners rounded, back edge 45 deg
module band_trim() let(xb = cap_end + 0.5, r = 4) intersection() {
    translate([0, 0, -1]) linear_extrude(band_top + 1) hull() {
        translate([-10, -60]) square([1, 120]);
        for (s = [-1, 1]) translate([xb - r, s * (hw(xb) - r)]) circle(r);
    }
    rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)
        polygon([[-10, -1], [xb + 1, -1], [xb + 1 - band_top - 1, band_top], [-10, band_top]]);
}
module body5() {
    $fn = smooth_fn;
    difference() {
        union() {
            intersection() { head(); band_trim(); }
            intersection() { loft(cp5); guard_envelope(); }
        }
        head_cuts();
        dish(cp5, 56);
        channel();
    }
}

module body_sel(c) {
    if (c == 0) body();
    else if (c == 1) body_c(cp1);
    else if (c == 2) body_c(cp2) channel();
    else if (c == 3) body_c(cp3) window_cut();
    else if (c == 5) body5();
    else if (c == 4) body_c(cp4, false) translate([56, 0, hat(cp4, 56) + 40 - 1.8]) scale([14, 60, 40]) sphere(1, $fn = 96);
}

module model(c = concept, v = view, pull = pull_out) {
    if (v == "body") body_sel(c);
    else if (v == "guard_check") intersection() { body_sel(c); guard(); }
    else if (v == "guarded") { color("#9dbfe3") body_sel(c); color("#e8a33d") cap(); blade(); color("#5cb88a") drawer(); color("#6c6", 0.55) guard(); }
    else if (v == "drawer") drawer();
    else {
        color("#9dbfe3") body_sel(c);
        color("#e8a33d") cap();
        blade();
        if (c == 2 || c == 5) {
            color("#5cb88a") translate([pull, 0, 0]) drawer();
            if (pull > 0) for (i = [0:spare_n - 1]) color("silver")
                translate([(ch_x0 + 1 + ch_x1) / 2 + pull, -9.5, ch_z0 + tray_floor + 0.05 + i * 0.6])
                    linear_extrude(0.6) translate([-blade_edge / 2, 0])
                        polygon([[0, 0], [blade_edge, 0], [blade_edge / 2 + blade_back / 2, 19], [blade_edge / 2 - blade_back / 2, 19]]);
        }
    }
}
model();
