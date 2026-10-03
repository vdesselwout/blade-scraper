// Razor scraper for a trapezoid utility blade - v3 (guard: blade slot to the mouth, elephant's-foot clearance)
// Three printed parts, no hardware: body (handle + head), cap (holds the blade), guard.
// Axes (use = print orientation of the body): X along the tool, cutting edge at x = 0,
// handle towards +X. The blade lies in z = -0.6..0, the body sits on top (z >= 0), the cap below.
// The cap slides onto the head from the front (towards +X) on 45 deg dovetails; its pegs run in
// two grooves under the head and stop at the groove ends, which take the scraping force.

/* [Part] */
part_sel = "all"; // [all, body, cap, guard, test, assembly, assembly_guard]

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
front_chamfer = 1.4;    // underside of the cap nose: surface clearance

/* [Snap] */
tab_w = 10;
tab_x0 = 23;
tab_t = 1.2;
bump_x = 34;
bump_h = 0.45;          // above the sole
dimple_depth = 0.7;

/* [Handle] (x, width, height) */
stations = [[37, 48, 8.5], [62, 27, 17], [85, 30, 22], [112, 33, 26], [140, 31, 25],
            [160, 28, 21], [172, 20, 15], [177, 9, 8]];
bed_chamfer = 0.6;
smooth_fn = 64;

/* [Guard] */
guard_t = 1.6;
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
cap_hw = hw0 - clamp_interference - cap_top + cap_wall_t;
body_len = stations[len(stations) - 1][0];
clear_angle = atan(cap_floor_t / (exposure + front_chamfer));
function body_top(x) = x < 20 ? nose_h + (x - x_front) * (head_h - nose_h) / (20 - x_front) : head_h;

echo(str("blade covered: ", blade_h - exposure, " mm, width at holder front ", 2 * blade_hw(x_front)));
echo(str("cap width ", 2 * cap_hw, ", body length ", body_len, ", surface clearance angle ", clear_angle));
assert(hw0 + 0.05 > blade_hw(x_front) + pocket_clear + 0.5, "cap wall cuts into the pocket");
assert(pocket_depth < blade_t, "cap top would touch the sole: no clamping");
assert(peg_d < notch_w, "pegs too big for the notches");
assert(body_len < 220, "body longer than the bed");

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
function se(w, h, n = 2.5, N = 36) =
    [for (i = [0:N]) let(t = i * 180 / N, c = cos(t), s = sin(t))
        [w / 2 * sign(c) * pow(abs(c), 2 / n), h * pow(s, 2 / n)]];
module grip_2d(w, h) intersection() {
    polygon(se(w, h));
    polygon([[-w / 2 + bed_chamfer, 0], [w / 2 - bed_chamfer, 0], [w / 2 + h, h + bed_chamfer], [-w / 2 - h, h + bed_chamfer]]);
}
module slice(st) translate([st[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(0.01) grip_2d(st[1], st[2]);

module head() intersection() {
    rotate([90, 0, 0]) linear_extrude(4 * hw0, center = true)        // side profile
        polygon([[x_front, 0], [head_end, 0], [head_end, head_h], [20, head_h], [x_front, nose_h]]);
    translate([x_front, 0, 0]) rotate([90, 0, 90]) linear_extrude(head_end - x_front)   // dovetail section
        polygon([[-hw0, 0], [hw0, 0], [hw0 - dt, dt], [hw0 - dt, head_h - 2], [hw0 - dt - 2, head_h],
                 [-(hw0 - dt - 2), head_h], [-(hw0 - dt), head_h - 2], [-(hw0 - dt), dt]]);
    linear_extrude(3 * head_h, center = true)                          // lead-in at the front corners
        polygon([[x_front, -(hw0 - 1.2)], [x_front, hw0 - 1.2], [x_front + 2.2, hw0 + 1], [cap_end + 0.5, hw0 + 1],
                 [head_end, hw0 - 4], [head_end, -(hw0 - 4)], [cap_end + 0.5, -(hw0 + 1)], [x_front + 2.2, -(hw0 + 1)]]);
}

module handle() for (i = [0:len(stations) - 2]) hull() { slice(stations[i]); slice(stations[i + 1]); }

function h_at(x) = lookup(x, [for (s = stations) [s[0], s[2]]]);
dish_x = 52;

module body() {
    $fn = smooth_fn;
    difference() {
        union() { head(); handle(); }
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
    }
}

// ---------- cap ----------
module cap_section() {   // YZ, right half mirrored
    yi_top = hw0 - dt + 0.3;
    half = [[0, cap_z0], [cap_hw, cap_z0], [cap_hw, lip_top], [yi_top, lip_top],
            [yi_top, hw0 - yi_top - clamp_interference],          // on the 45 deg lip face
            [hw0 - clamp_interference - cap_top, cap_top], [0, cap_top]];
    polygon(concat(half, [for (i = [len(half) - 1:-1:0]) [-half[i][0], half[i][1]]]));
}

module cap() {
    $fn = smooth_fn;
    difference() {
        union() {
            translate([x_front, 0, 0]) rotate([90, 0, 90]) linear_extrude(cap_end - x_front) cap_section();
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
        rotate([90, 0, 0]) linear_extrude(3 * cap_hw, center = true)
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
g_cap_hw = cap_hw + guard_clear;
g_z0 = cap_z0 - guard_clear;
g_slot_z0 = -blade_t - 0.6;                 // blade slot
g_slot_z1 = 0.6;
function g_top(x) = max(lip_top, body_top(x)) + guard_clear;
module guard() {
    $fn = 24;
    x0 = -0.5 - guard_t;
    difference() {
        hull() for (x = [x0 + 1.5, x_front + guard_back - 1.5], y = [-1, 1], z = [g_z0 - guard_t + 1.5, g_top(x_front + guard_back) + guard_t - 1.5])
            translate([x, y * (g_hw + guard_t - 1.5), z]) sphere(1.5);
        // blade zone, widening into the head zone
        hull() {
            translate([-0.5, -g_hw, g_slot_z0]) cube([4, 2 * g_hw, g_slot_z1 - g_slot_z0]);
            translate([x_front + 0.5, -g_cap_hw, g_z0]) cube([0.01, 2 * g_cap_hw, g_top(x_front + 0.5) - g_z0]);
        }
        hull() for (x = [x_front + 0.5, x_front + guard_back + 1])
            translate([x, -g_cap_hw, g_z0]) cube([0.01, 2 * g_cap_hw, g_top(x) - g_z0]);
        // the full 61 mm cutting edge has to pass the mouth on the way in
        translate([-0.5, -g_hw, g_slot_z0]) cube([x_front + guard_back + 2, 2 * g_hw, g_slot_z1 - g_slot_z0]);
        // relief below the slot: the cap's flared first layers (elephant's foot) can't catch on the walls
        translate([x_front + 0.5, -g_hw, g_z0]) cube([guard_back + 1, 2 * g_hw, g_slot_z1 - g_z0]);
        // lead-in chamfer at the mouth, which prints on the bed and flares inwards
        hull() {
            translate([x_front + guard_back - mouth_chamfer, -g_cap_hw, g_z0])
                cube([0.01, 2 * g_cap_hw, g_top(x_front + guard_back) - g_z0]);
            translate([x_front + guard_back, -g_cap_hw - mouth_chamfer, g_z0 - mouth_chamfer])
                cube([1, 2 * (g_cap_hw + mouth_chamfer), g_top(x_front + guard_back) - g_z0 + 2 * mouth_chamfer]);
        }
    }
    // friction bumps on the cap walls, above the blade slot
    for (s = [-1, 1]) translate([x_front + 4, s * g_cap_hw, (g_slot_z1 + lip_top) / 2]) sphere(0.75);
}

// ---------- layout ----------
module print_cap() translate([0, 0, -cap_z0]) cap();
module print_guard() translate([0, 0, x_front + guard_back]) rotate([0, 90, 0]) guard();

module scraper(sel = part_sel) {
    if (sel == "body") body();
    else if (sel == "cap") print_cap();
    else if (sel == "guard") print_guard();
    else if (sel == "all") {
        body();
        translate([0, -2 * hw0 - 12, 0]) print_cap();
        translate([90, -2 * hw0 - 12, 0]) print_guard();
    } else if (sel == "test") {
        intersection() { body(); translate([0, -50, -1]) cube([42, 100, 30]); }
        translate([0, -2 * hw0 - 12, 0]) print_cap();
    } else if (sel == "assembly") {
        color("#8fb3d9") body(); color("#e8a33d") cap(); blade();
    } else if (sel == "assembly_guard") {
        color("#8fb3d9") body(); color("#e8a33d") cap(); blade(); color("#6c6", 0.6) guard();
    }
}

scraper();
