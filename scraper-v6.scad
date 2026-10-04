// Razor scraper for a trapezoid utility blade - v6
// v2: guard's blade slot runs through to the mouth (the 61 mm edge couldn't pass the 59 mm mouth)
// v3: guard relieved below the slot + mouth chamfer (it caught on the cap's elephant's foot)
// v4: tapered dovetails (head and cap widen 0.05 mm/mm per side towards the back): the cap only
//     clamps in the last 2 mm of travel, so the head no longer drags the blade out while it slides on
// v5: new handle, 21 mm shorter (156 mm overall), lower and slimmer (31 x 19 mm palm swell), one smooth
//     spline instead of hulled stations: user wants it sleeker, shorter and lighter on filament.
//     Blade drawer: 5 spare blades lie flat in a tray that slides into the grip from the butt and clicks
//     shut on a sprung tongue: user asked for safe blade storage in the handle.
//     Flowing head: above band_top the head is one loft from the blade width into the grip (the block
//     with a square back is gone): user wanted the head to flow into the handle. Everything below
//     band_top (sole, dovetails, grooves, snap dimple) and the nose under the guard are v4's exactly,
//     so cap and guard are unchanged.
// v6: open-top guard, 8.4 mm tall instead of 13.7: user wanted a sleeker guard to match the v5 head.
//     It closes only over the exposed blade; behind the nose it is a frame that hooks over the cap's
//     side walls and lets the head show through. Same inside fit as before (slot, cap zone, bumps,
//     mouth lead-in); walls 1.6 -> 1.2 mm.
// Four printed parts, no hardware: body (handle + head), cap (holds the blade), guard, blade drawer.
// Axes (use = print orientation of the body): X along the tool, cutting edge at x = 0,
// handle towards +X. The blade lies in z = -0.6..0, the body sits on top (z >= 0), the cap below.
// The cap slides onto the head from the front (towards +X) on 45 deg dovetails; its pegs run in
// two grooves under the head and stop at the groove ends, which take the scraping force.

/* [Part] */
part_sel = "all"; // [all, body, cap, guard, drawer, test, drawer_test, guard_test, assembly, assembly_guard, assembly_open]

/* [Blade (measured)] */
blade_edge = 61;        // cutting edge length
blade_back = 31.6;      // back (notched) edge length
blade_h = 19;           // edge to back edge
blade_t = 0.6;
notch_w = 3.35;
notch_depth = 3.85;     // back edge to tip of the round end
notch_pitch = 6.65;     // centre to centre

/* [Fit] */
pocket_clear = 0.25;    // blade outline clearance in the cap pocket
pocket_depth = 0.45;    // < blade_t: cap top stays clear of the body sole
peg_d = 3.0;            // pegs in the notches
groove_w = 3.4;         // peg grooves under the head
groove_depth = 1.8;
clamp_interference = 0.1; // dovetail overlap; the cap walls spread this much and clamp the blade
guard_clear = 0.3;

/* [Head and cap] */
exposure = 6;           // blade beyond the holder
dt = 2.0;               // dovetail height (45 deg)
hw0 = 26.8;             // head half width at the sole (widest point of the dovetail)
head_end = 38;
head_h = 8.5;
nose_h = 3.0;           // head height at the front edge
cap_floor_t = 1.6;      // cap under the blade
cap_wall_t = 2.4;
cap_end = 36;
lip_top = dt + 1.2;
dt_taper = 0.05;        // dovetail widening per mm towards the back, each side
front_chamfer = 1.4;    // underside of the cap nose: surface clearance

/* [Snap] */
tab_w = 10;
tab_x0 = 23;
tab_t = 1.2;
bump_x = 34;
bump_h = 0.45;          // above the sole
dimple_depth = 0.7;

/* [Handle] */
// control stations [x, width, height, section exponent]: 10 = boxy (head), 2.5 = D-section (grip).
// A Catmull-Rom spline runs through them; under the guard (x < 20) it is clipped to v4's nose slope.
cp = [[6, 49.4, 3.0, 10], [20, 49.4, 8.5, 8], [32, 44, 10, 5], [44, 31, 10.5, 3.5], [56, 26, 12, 2.8],
      [76, 28.5, 16, 2.5], [104, 31, 19, 2.5], [132, 30, 17, 2.5], [146, 28, 15, 2.5]];
// drawer tail: continues the body's last station
tail = [[146, 28, 15, 2.5], [150, 26.5, 13.5, 2.5], [153, 22, 10.5, 2.5], [155.5, 9, 5, 2.5]];
band_top_over = 0.4;    // the head keeps v4's exact shape up to this far above the cap's lips
dish_x = 56;            // thumb / index-finger dish
bed_chamfer = 0.6;
smooth_fn = 64;

/* [Blade drawer] */
ch_x0 = 69;             // channel in the grip, open at the butt
ch_x1 = 146;
ch_w = 23;
ch_z0 = 1.6;            // channel floor above the bed
ch_h = 4.8;
drawer_clear = 0.2;     // per side, and over the top
tray_x0 = 80;           // tray front face (home position)
tray_floor = 1.0;
spare_n = 5;
spare_clear = 0.3;      // blade outline clearance in the tray pocket
push_hole_d = 10;
// catch: two arms run forward from the tray's front corners and flex sideways (in the print plane, so
// no overhang); a bump on each clicks into a vertical groove in the channel side wall
arm_l = 10;
arm_t = 1.2;            // arm thickness (y)
catch_x = 72;           // bump / groove position
catch_h = 0.7;          // bump height beyond the tray side
dimple_d = 0.6;         // groove depth into the channel wall

/* [Guard] */
guard_t = 1.2;          // three printed lines
guard_back = 12;
mouth_chamfer = 0.8;

// ---------- derived ----------
side_run = (blade_edge - blade_back) / 2;           // 14.7
x_front = exposure;                                  // holder front edge
function blade_hw(x) = blade_edge / 2 - side_run * x / blade_h;
x_pc = blade_h - notch_depth + notch_w / 2;          // centre of the notch's round end
peg_rear = blade_h + 0.5 + peg_d / 2;                // pegs run back past the blade's back edge
groove_end = peg_rear + 0.05;
cap_z0 = -blade_t - cap_floor_t;                     // cap underside
cap_top = -blade_t + pocket_depth;
function hw(x) = hw0 + dt_taper * (x - x_front);     // head half width at the sole
function cap_hw_at(x) = hw(x) - clamp_interference - cap_top + cap_wall_t;
cap_hw = cap_hw_at(x_front);                         // at the front; widest at cap_end
body_len = cp[len(cp) - 1][0];
total_len = tail[len(tail) - 1][0];
clear_angle = atan(cap_floor_t / (exposure + front_chamfer));
function body_top(x) = x < 20 ? nose_h + (x - x_front) * (head_h - nose_h) / (20 - x_front) : head_h;
band_top = lip_top + band_top_over;
tray_w = ch_w - 2 * drawer_clear;
tray_h = ch_h - 2 * drawer_clear;
tray_top = ch_z0 + tray_h;
pocket_c = (tray_x0 + ch_x1) / 2;                    // spare blade pocket centre (x)
arm_flex = catch_h - drawer_clear;                   // arm deflection while the drawer slides
arm_strain = 3 * arm_t * arm_flex / (2 * arm_l * arm_l);

echo(str("blade covered: ", blade_h - exposure, " mm, width at holder front ", 2 * blade_hw(x_front)));
echo(str("clamp engages in the last ", clamp_interference / dt_taper, " mm of travel"));
echo(str("cap width ", 2 * cap_hw, " front, ", 2 * cap_hw_at(cap_end), " back, body length ", body_len, ", surface clearance angle ", clear_angle));
echo(str("overall length ", total_len, " mm; drawer catch: arms deflect ", arm_flex, " mm, strain ", 100 * arm_strain, " %"));
assert(hw0 + 0.05 > blade_hw(x_front) + pocket_clear + 0.5, "cap wall cuts into the pocket");
assert(pocket_depth < blade_t, "cap top would touch the sole: no clamping");
assert(peg_d < notch_w, "pegs too big for the notches");
assert(total_len < 220, "body longer than the bed");
assert(g_cap_hw(x_front + guard_back) + mouth_chamfer < g_hw, "guard mouth chamfer cuts into the wall");
assert(spare_n * blade_t + 0.3 < tray_h - tray_floor, "spare blades don't fit the pocket depth");
assert(blade_edge + 2 * spare_clear + 2 < ch_x1 - tray_x0, "tray too short for the spare blades");
assert(blade_h + 2 * spare_clear + 2.5 < tray_w, "tray too narrow for the spare blades");
assert(arm_flex > 0.3 && arm_strain < 0.015, "drawer catch too weak or overstrained");

// ---------- blade ----------
module blade_2d(notches = true, grow = 0)
    offset(delta = grow) difference() {
        polygon([[0, -blade_edge / 2], [0, blade_edge / 2], [blade_h, blade_back / 2], [blade_h, -blade_back / 2]]);
        if (notches) for (s = [-1, 1]) hull() {
            translate([x_pc, s * notch_pitch / 2]) circle(d = notch_w);
            translate([blade_h + 1, s * notch_pitch / 2 - notch_w / 2]) square([0.1, notch_w]);
        }
    }
module blade() color("silver") translate([0, 0, -blade_t]) linear_extrude(blade_t) blade_2d();

// ---------- body ----------
function se(w, h, n = 2.5, N = 48) =
    [for (i = [0:N]) let(t = i * 180 / N, c = cos(t), s = sin(t))
        [w / 2 * sign(c) * pow(abs(c), 2 / n), h * pow(s, 2 / n)]];
module grip_2d(w, h, n = 2.5) intersection() {
    polygon(se(w, h, n));
    polygon([[-w / 2 + bed_chamfer, 0], [w / 2 - bed_chamfer, 0], [w / 2 + h, h + bed_chamfer], [-w / 2 - h, h + bed_chamfer]]);
}
module slice(st) translate([st[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(0.01) grip_2d(st[1], st[2], st[3]);

// Catmull-Rom spline through the stations: a smooth outline with no kinks at the stations
function cr(p0, p1, p2, p3, t) = 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t
                                       + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);
function spline(c, N = 6) = let(n = len(c))
    concat([for (i = [0:n - 2]) for (k = [0:N - 1])
        cr(c[max(i - 1, 0)], c[i], c[i + 1], c[min(i + 2, n - 1)], k / N)], [c[n - 1]]);
module loft(c) let(st = spline(c)) for (i = [0:len(st) - 2]) hull() { slice(st[i]); slice(st[i + 1]); }
function h_at(x) = lookup(x, [for (s = spline(cp)) [s[0], s[2]]]);

module head() intersection() {
    rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)        // side profile
        polygon([[x_front, 0], [head_end, 0], [head_end, head_h], [20, head_h], [x_front, nose_h]]);
    tapered(x_front, head_end)                                          // tapered dovetail section
        polygon([[-5, 0], [hw0, 0], [hw0 - dt, dt], [hw0 - dt, head_h - 2], [hw0 - dt - 2, head_h], [-5, head_h]]);
    linear_extrude(3 * head_h, center = true)                          // lead-in at the front corners
        polygon([[x_front, -(hw(x_front) - 1.2)], [x_front, hw(x_front) - 1.2], [x_front + 2.2, hw(x_front + 2.2) + 1],
                 [cap_end + 0.5, hw(cap_end + 0.5) + 1], [head_end, hw(head_end) - 4], [head_end, -(hw(head_end) - 4)],
                 [cap_end + 0.5, -(hw(cap_end + 0.5) + 1)], [x_front + 2.2, -(hw(x_front + 2.2) + 1)]]);
}
// v4's head (the dovetail band) is kept up to band_top; it ends just behind the cap with rounded
// corners and a 45 deg back edge
module band_trim() let(xb = cap_end + 0.5, r = 4) intersection() {
    translate([0, 0, -1]) linear_extrude(band_top + 1) hull() {
        translate([-10, -4 * hw0]) square([1, 8 * hw0]);
        for (s = [-1, 1]) translate([xb - r, s * (hw(xb) - r)]) circle(r);
    }
    rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)
        polygon([[-10, -1], [xb + 1, -1], [xb - band_top, band_top], [-10, band_top]]);
}
// under the guard the top may not rise above v4's nose slope
module guard_envelope() rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)
    polygon([[x_front - 1, -1], [x_front - 1, nose_h], [x_front, nose_h], [20, head_h], [20, 100], [300, 100], [300, -1]]);

module channel() translate([ch_x0, -ch_w / 2, ch_z0]) cube([ch_x1 - ch_x0 + 1, ch_w, ch_h]);
// bump on the drawer arms and the matching groove in the channel walls, 45 deg flanks both ways
// (clicks in, pulls out); h = height beyond y0, w0 = flat top width
module catch_profile(y0, h, w0) polygon([[catch_x - w0 / 2 - h - 0.5, y0 - 0.5], [catch_x + w0 / 2 + h + 0.5, y0 - 0.5],
                                         [catch_x + w0 / 2, y0 + h], [catch_x - w0 / 2, y0 + h]]);
module catch_dimple() for (m = [0, 1]) mirror([0, m, 0]) translate([0, 0, ch_z0 - 0.01]) linear_extrude(ch_h + 0.02)
    catch_profile(ch_w / 2, dimple_d, 1.3);

module body() {
    $fn = smooth_fn;
    difference() {
        union() {
            intersection() { head(); band_trim(); }
            intersection() { loft(cp); guard_envelope(); }
        }
        // peg grooves: open at the front, the closed ends are the hard stop
        for (s = [-1, 1]) translate([0, 0, -1]) linear_extrude(groove_depth + 1) hull() {
            translate([x_front - 3, s * notch_pitch / 2]) circle(d = groove_w);
            translate([groove_end - groove_w / 2, s * notch_pitch / 2]) circle(d = groove_w);
        }
        // snap dimple (45 deg V across the sole)
        rotate([90, 0, 0]) linear_extrude(tab_w + 1, center = true)
            polygon([[bump_x - dimple_depth - 1, -1], [bump_x + dimple_depth + 1, -1], [bump_x, dimple_depth]]);
        // lead-in where the blade slides under the nose
        rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)
            polygon([[x_front - 1, -1], [x_front + 0.6, -1], [x_front + 0.6, 0], [x_front, 0.6], [x_front - 1, 0.6]]);
        // thumb / index-finger dish on top
        translate([dish_x, 0, h_at(dish_x) + 6 - 1.3]) scale([12, 8, 6]) sphere(1, $fn = 48);
        channel();
        catch_dimple();
        // the underside rises 45 deg at the butt to meet the drawer tail, which prints at channel floor level
        rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)
            polygon([[ch_x1 - ch_z0, -1], [ch_x1 + 1, -1], [ch_x1 + 1, ch_z0], [ch_x1 - ch_z0 + 1, ch_z0]]);
    }
}

// ---------- blade drawer ----------
// In assembly position (home). Prints on its floor (z = ch_z0), so the tail is cut off at that level too.
module spare_blade_2d(grow = 0)   // blade lying along X, cutting edge at y = 0, back edge towards +y
    offset(delta = grow) polygon([[-blade_edge / 2, 0], [blade_edge / 2, 0], [blade_back / 2, blade_h], [-blade_back / 2, blade_h]]);
pocket_y0 = -tray_w / 2 + 1.5;     // the cutting edges lie against the tray's solid side wall
module drawer() {
    $fn = smooth_fn;
    difference() {
        union() {
            translate([tray_x0, -tray_w / 2, ch_z0]) cube([ch_x1 - tray_x0 + 0.5, tray_w, tray_h]);
            intersection() {
                loft(tail);
                translate([ch_x1 - 1, -50, ch_z0]) cube([20, 100, 30]);
            }
            // catch arms with their bumps
            for (m = [0, 1]) mirror([0, m, 0]) translate([0, 0, ch_z0]) linear_extrude(tray_h) {
                translate([tray_x0 - arm_l, tray_w / 2 - arm_t]) square([arm_l + 0.5, arm_t]);
                intersection() {
                    catch_profile(tray_w / 2, catch_h, 0.3);
                    translate([0, tray_w / 2 - 1]) square([200, 10]);
                }
            }
        }
        // spare blade pocket
        translate([pocket_c, pocket_y0 + spare_clear, ch_z0 + tray_floor]) linear_extrude(tray_h)
            spare_blade_2d(spare_clear);
        // push the stack up through the floor
        translate([pocket_c, 0, 0]) cylinder(d = push_hole_d, h = 10);
        // finger-nail groove across the tail to pull the drawer
        translate([ch_x1 + 5, 0, 17]) rotate([90, 0, 0]) cylinder(r = 6, h = 40, center = true);
    }
}
module spare_blades(pull = 0) for (i = [0:spare_n - 1]) color("silver")
    translate([pocket_c + pull, pocket_y0 + spare_clear, ch_z0 + tray_floor + 0.02 + i * blade_t])
        linear_extrude(blade_t - 0.02) spare_blade_2d();

// ---------- cap ----------
// Right-half YZ section (from y = -5) extruded along X from x0 to x1, sheared so it widens by
// dt_taper per mm, then mirrored: every cross-section keeps its exact shape (45 deg faces stay 45 deg).
module tapered(x0, x1) for (m = [0, 1]) mirror([0, m, 0])
    multmatrix([[1, 0, 0, 0], [dt_taper, 1, 0, -dt_taper * x_front], [0, 0, 1, 0], [0, 0, 0, 1]])
        translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();
// cap block, and the space for the head (45 deg lip faces with clamp_interference overlap), at x_front
module cap_outer_2d() translate([-5, cap_z0]) square([cap_hw + 5, lip_top - cap_z0]);
module cap_inner_2d() let(ci = clamp_interference, yi = hw0 - dt + 0.3)
    polygon([[-5, cap_top], [hw0 - ci - cap_top, cap_top], [yi, hw0 - ci - yi], [yi, lip_top + 1], [-5, lip_top + 1]]);

module cap() {
    $fn = smooth_fn;
    difference() {
        union() {
            difference() {
                tapered(x_front, cap_end) cap_outer_2d();
                tapered(x_front - 0.01, cap_end + 0.01) cap_inner_2d();
            }
            // pegs: stadiums from the notch's round end to behind the back edge
            for (s = [-1, 1]) translate([0, 0, cap_top - 0.5]) linear_extrude(groove_depth - 0.3 - cap_top + 0.5) hull() {
                translate([x_pc, s * notch_pitch / 2]) circle(d = peg_d);
                translate([peg_rear - peg_d / 2, s * notch_pitch / 2]) circle(d = peg_d);
            }
        }
        // blade pocket (open at the front)
        translate([0, 0, -blade_t]) linear_extrude(1) difference() {
            union() { blade_2d(false, pocket_clear); translate([-5, -blade_edge / 2 - 1]) square([5, blade_edge + 2]); }
            for (s = [-1, 1]) hull() {   // keep the pegs
                translate([x_pc, s * notch_pitch / 2]) circle(d = peg_d);
                translate([peg_rear - peg_d / 2, s * notch_pitch / 2]) circle(d = peg_d);
            }
        }
        // nose chamfer underneath (surface clearance)
        rotate([90, 0, 0]) linear_extrude(3 * cap_hw_at(cap_end), center = true)
            polygon([[x_front - 1, cap_z0 - 1], [x_front + front_chamfer + 1, cap_z0 - 1], [x_front - 1, cap_z0 + front_chamfer + 1]]);
        // snap tab: two side slots, top lowered to tab_t
        for (s = [-1, 1]) translate([tab_x0, s * (tab_w / 2 + 0.4) - 0.4, cap_z0 - 1]) cube([cap_end - tab_x0 + 1, 0.8, 10]);
        translate([tab_x0, -tab_w / 2, cap_z0 + tab_t]) cube([cap_end - tab_x0 + 1, tab_w, 5]);
    }
    // snap bump on the tab
    rotate([90, 0, 0]) linear_extrude(tab_w, center = true)
        polygon([[bump_x - 0.15 - (bump_h - cap_z0 - tab_t), cap_z0 + tab_t - 0.01], [bump_x + 0.15 + (bump_h - cap_z0 - tab_t), cap_z0 + tab_t - 0.01],
                 [bump_x + 0.15, bump_h], [bump_x - 0.15, bump_h]]);
}

// ---------- guard ----------
g_hw = blade_edge / 2 + 0.5;                 // blade zone inner half width
function g_cap_hw(x) = cap_hw_at(x) + guard_clear;   // follows the tapered cap
g_z0 = cap_z0 - guard_clear;
g_slot_z0 = -blade_t - 0.6;                 // blade slot
g_slot_z1 = 0.6;
function g_top(x) = max(lip_top, body_top(x)) + guard_clear;
function g_lip_top() = lip_top + guard_clear;       // inside top over the cap walls
function g_open_hw(x) = hw(x) - dt + 0.6;           // opening over the head: the head band + 0.6
// outside: a rounded rectangle whose top and bottom run straight from the nose back to the cap zone
function g_zb(x) = lookup(x, [[-1.1, g_slot_z0 - guard_t], [x_front + 0.5, g_z0 - guard_t], [99, g_z0 - guard_t]]);
function g_zt(x) = lookup(x, [[-1.1, g_slot_z1 + guard_t], [x_front + 0.5, g_lip_top() + guard_t], [99, g_lip_top() + guard_t]]);
module g_slice(x, inset = 0) let(w = g_hw + guard_t - inset, zb = g_zb(x) + inset, zt = g_zt(x) - inset, r = 1.4)
    translate([x, 0, 0]) rotate([90, 0, 90]) linear_extrude(0.01)
        hull() for (s = [-1, 1], z = [zb + r, zt - r]) translate([s * (w - r), z]) circle(r);
module g_cap_zone(x) translate([x, -g_cap_hw(x), g_z0]) cube([0.01, 2 * g_cap_hw(x), g_lip_top() - g_z0]);
module guard() {
    $fn = 24;
    x0 = -0.5 - guard_t;
    xm = x_front + guard_back;
    difference() {
        union() {
            hull() { g_slice(x0, 1); g_slice(x0 + 1); }
            hull() { g_slice(x0 + 1); g_slice(x_front + 0.5); }
            hull() { g_slice(x_front + 0.5); g_slice(xm); }
        }
        // the full 61 mm cutting edge has to pass the mouth on the way in
        translate([-0.5, -g_hw, g_slot_z0]) cube([xm + 2.5, 2 * g_hw, g_slot_z1 - g_slot_z0]);
        // relief below the slot: the cap's flared first layers (elephant's foot) can't catch on the walls
        translate([x_front + 0.5, -g_hw, g_z0]) cube([guard_back + 1, 2 * g_hw, g_slot_z1 - g_z0]);
        // over the cap walls, ramping in from the slot
        hull() { translate([3.5, -g_hw, g_slot_z0]) cube([0.01, 2 * g_hw, g_slot_z1 - g_slot_z0]); g_cap_zone(x_front + 0.5); }
        // full height from just before the cap's front edge (its top corner sits right where the ramp ends)
        hull() { g_cap_zone(x_front - 0.2); g_cap_zone(xm + 1); }
        // open top over the head. Its front end rises 45 deg towards the nose, so printed mouth-down
        // it closes without a bridge, and stays clear of the head's nose slope
        hull() for (p = [[x_front + 0.5 - guard_t, g_lip_top() + guard_t], [x_front + 0.5, g_lip_top()], [xm + 1, g_lip_top()]])
            translate([p[0], -g_open_hw(p[0]), p[1]]) cube([0.01, 2 * g_open_hw(p[0]), 20]);
        // lead-in chamfer at the mouth, which prints on the bed and flares inwards
        hull() {
            translate([xm - mouth_chamfer, -g_cap_hw(xm), g_z0]) cube([0.01, 2 * g_cap_hw(xm), g_lip_top() - g_z0]);
            translate([xm, -g_cap_hw(xm) - mouth_chamfer, g_z0 - mouth_chamfer])
                cube([1, 2 * (g_cap_hw(xm) + mouth_chamfer), g_lip_top() - g_z0 + 2 * mouth_chamfer]);
        }
    }
    // friction bumps on the cap walls, above the blade slot
    for (s = [-1, 1]) translate([x_front + 4, s * g_cap_hw(x_front + 4), (g_slot_z1 + lip_top) / 2]) sphere(0.75);
}

// ---------- layout ----------
module print_cap() translate([0, 0, -cap_z0]) cap();
module print_guard() translate([0, 0, x_front + guard_back]) rotate([0, 90, 0]) guard();
module print_drawer() translate([0, 0, -ch_z0]) drawer();

module scraper(sel = part_sel, pull = 60) {
    if (sel == "body") body();
    else if (sel == "cap") print_cap();
    else if (sel == "guard") print_guard();
    else if (sel == "drawer") print_drawer();
    else if (sel == "all") {
        body();
        translate([0, -2 * hw0 - 12, 0]) print_cap();
        translate([90, -2 * hw0 - 12, 0]) print_guard();
        translate([-50, 2 * hw0 - 10, 0]) print_drawer();
    } else if (sel == "test") {
        intersection() { body(); translate([0, -50, -1]) cube([42, 100, 30]); }
        translate([0, -2 * hw0 - 12, 0]) print_cap();
    } else if (sel == "drawer_test") {
        // a slice of the grip with the channel and the catch dimple, and the front of the tray with the tongue
        intersection() { body(); translate([ch_x0 - 4, -50, -1]) cube([tray_x0 + 12 - ch_x0 + 4, 100, 40]); }
        translate([0, 40, 0]) intersection() { print_drawer(); translate([0, -50, -1]) cube([tray_x0 + 16, 100, 40]); }
    } else if (sel == "guard_test") {
        // the guard plus the front of the head and cap it slides over, to check the fit and the hold
        intersection() { body(); translate([0, -50, -1]) cube([24, 100, 30]); }
        translate([0, -2 * hw0 - 12, 0]) print_cap();
        translate([40, 0, 0]) print_guard();
    } else if (sel == "assembly") {
        color("#8fb3d9") body(); color("#e8a33d") cap(); blade(); color("#5cb88a") drawer();
    } else if (sel == "assembly_guard") {
        color("#8fb3d9") body(); color("#e8a33d") cap(); blade(); color("#5cb88a") drawer(); color("#5d9e72") guard();
    } else if (sel == "assembly_open") {
        color("#8fb3d9") body(); color("#e8a33d") cap(); blade();
        color("#5cb88a") translate([pull, 0, 0]) drawer(); spare_blades(pull);
    }
}

scraper();
