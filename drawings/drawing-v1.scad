// Dimensioned drawing sheet for scraper-v1 (assembled, with blade).
use <../scraper-v1.scad>

flat = false;
module ex(h) if (flat) children(); else linear_extrude(h) children();
module model() scraper("assembly");

lw = 0.3;
ts = 3.2;

module seg(a, b, w = lw) hull() { translate(a) circle(d = w, $fn = 8); translate(b) circle(d = w, $fn = 8); }
module arrow(p, dir) translate(p) rotate(dir) polygon([[0, 0], [-2.2, 0.7], [-2.2, -0.7]]);
module label(p, s, rot = 0, h = "center") translate(p) rotate(rot) text(s, size = ts, halign = h, valign = "center", font = "Liberation Sans");
module dim_h(x1, x2, y, s, ye) {
    if (ye != undef) { seg([x1, ye], [x1, y + (y > ye ? 1 : -1)]); seg([x2, ye], [x2, y + (y > ye ? 1 : -1)]); }
    seg([x1, y], [x2, y]); arrow([x1, y], 180); arrow([x2, y], 0);
    label([(x1 + x2) / 2, y + 2.8], s);
}
module dim_v(y1, y2, x, s, xe) {
    if (xe != undef) { seg([xe, y1], [x + (x > xe ? 1 : -1), y1]); seg([xe, y2], [x + (x > xe ? 1 : -1), y2]); }
    seg([x, y1], [x, y2]); arrow([x, y1], 270); arrow([x, y2], 90);
    if (s != "") label([x - 2.8, (y1 + y2) / 2], s, 90);
}
module leader(from, to, s, h = "left") {
    seg(from, to); arrow(from, atan2(from.y - to.y, from.x - to.x));
    label(to + [h == "left" ? 1.5 : -1.5, 0], s, 0, h);
}
module clip(x0, y0, w, h) intersection() {
    children();
    if (flat) translate([x0, y0]) square([w, h]); else translate([x0, y0, -1]) cube([w, h, 3]);
}

module section_xz(y0 = 0) color("#8c8c8c") ex(0.1) projection(cut = true) translate([0, 0, y0]) rotate([-90, 0, 0]) model();
module section_yz(x0 = 0) color("#8c8c8c") ex(0.1) projection(cut = true) translate([0, 0, -x0]) rotate([-90, 0, 0]) rotate([0, 0, -90]) model();
module top_view() color("#8c8c8c") ex(0.1) projection() model();

// ================= SHEET =================
// 1) full side section through a peg (y = 3.3), 1:1
section_xz(3.325);
color("#000") ex(0.2) {
    dim_h(0, 177, -10, "177", -3);
    dim_v(0, 26, 186, "26", 178);
    label([88, -20], "A: SIDE SECTION THROUGH A PEG, 1:1");
}
// 2) plan view, 1:1
translate([0, -70]) {
    top_view();
    color("#000") ex(0.2) {
        dim_v(-30.5, 30.5, -8, "61 blade", 0);
        dim_v(-29.25, 29.25, 52, "58.5 cap", 36);
        dim_h(97, 129, 26, "grip 33 max", 18);
        dim_h(0, 6, -36, "6", -31);
        label([88, -46], "B: TOP VIEW, 1:1");
    }
}
// 3) head detail, side section through a peg, 4:1
translate([215, -12]) {
    k = 4;
    scale(k) clip(-1, -3, 42, 13) section_xz(3.325);
    color("#000") ex(0.2) {
        dim_h(0, 6 * k, 40, "6 exposed", 4);
        dim_v(-2.2 * k, -0.6 * k, -6, "1.6", 4);
        dim_v(0, 3 * k, 20, "3", 6 * k);
        leader([7.5 * k, -1.6 * k], [60, -22], "45° nose chamfer: usable down to 12°");
        leader([21 * k, 1.0 * k], [104, 50], "groove end = hard stop (1.8 deep)");
        leader([18 * k, 0.6 * k], [150, 40], "peg 3.0 in notch 3.35");
        leader([34 * k, 0.2 * k], [150, -18], "snap bump in 45° dimple");
        leader([12 * k, -0.3 * k], [60, -32], "blade 0.6 in 0.45 pocket");
        label([82, -44], "C: HEAD DETAIL (SECTION A), 4:1");
    }
}
// 4) cross-section through the head at x = 15, 3:1
translate([480, -12]) {
    k = 3;
    scale(k) clip(-31, -3, 62, 13) section_yz(15);
    color("#000") ex(0.2) {
        dim_h(-26.8 * k, 26.8 * k, 36, "53.6 head at sole", 0);
        dim_h(-29.25 * k, 29.25 * k, -22, "58.5", -2.2 * k);
        dim_v(0, 2 * k, 95, "2", 26.8 * k);
        leader([25.8 * k, 1 * k], [104, 20], "45° dovetail, 0.1 overlap");
        leader([-24.8 * k, 2.5 * k], [-112, 28], "cap lip", "right");
        leader([-8 * k, -0.3 * k], [-60, -32], "blade clamped", "right");
        label([0, -44], "D: SECTION AT X = 15 (HEAD + CAP + BLADE), 3:1");
    }
}
color("#000") ex(0.2) label([0, -126], "BLADE SCRAPER - v1 - dimensions in mm - blade 61 x 19 x 0.6, back edge 31.6, notches 3.35 wide, 6.65 apart", 0, "left");
