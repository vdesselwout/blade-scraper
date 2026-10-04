// Dimensioned drawing sheet for scraper-v5: new handle with blade drawer, flowing head.
use <../scraper-v5.scad>

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

module ann() if (flat) children(); else translate([0, 0, 0.3]) children();
module cut_xz(y0) projection(cut = true) translate([0, 0, y0]) rotate([-90, 0, 0]) children();
module cut_yz(x0) projection(cut = true) translate([0, 0, -x0]) rotate([-90, 0, 0]) rotate([0, 0, -90]) children();
// body light grey, cap orange, blade black, drawer green, spare blades dark grey
module parts() {
    color("#c4c4c4") ex(0.1) children(0);
    color("#e8a33d") translate([0, 0, 0.02]) ex(0.1) children(1);
    color("#222222") translate([0, 0, 0.04]) ex(0.1) children(2);
    color("#5cb88a") translate([0, 0, 0.06]) ex(0.1) children(3);
    color("#555555") translate([0, 0, 0.08]) ex(0.1) children(4);
}
module section_xz(y0 = 0) parts() { cut_xz(y0) body(); cut_xz(y0) cap(); cut_xz(y0) blade(); cut_xz(y0) drawer(); cut_xz(y0) spare_blades(); }
module section_yz(x0 = 0) parts() { cut_yz(x0) body(); cut_yz(x0) cap(); cut_yz(x0) blade(); cut_yz(x0) drawer(); cut_yz(x0) spare_blades(); }

// ================= SHEET =================
// A) long section at y = 0, 1:1
{
    section_xz(0);
    color("#000") ann() ex(0.2) {
        dim_h(0, 155.5, -12, "155.5 overall (v4: 177)", 0);
        dim_v(0, 19, 162, "19", 104);
        dim_h(69, 146, 26, "channel 77 (23 wide x 4.8)", 19);
        leader([30, 3.6], [8, 30], "below z = 3.6: v4 head, unchanged", "left");
        leader([118, 3.5], [112, -24], "5 spare blades in the drawer", "left");
        label([0, -32], "A: SECTION ON THE CENTRE LINE, 1:1", 0, "left");
    }
}
// B) cross section through the drawer at x = 113, 2:1
translate([40, -95]) {
    k = 2;
    scale(k) section_yz(113);
    color("#000") ann() ex(0.2) {
        dim_h(-11.5 * k, 11.5 * k, -10, "23 channel / 22.6 tray", 1.6 * k);
        dim_v(1.6 * k, 6.4 * k, -40, "4.8", -11.5 * k);
        dim_v(0, 19 * k, 40, "19", 0);
        label([0, -22], "B: SECTION AT X = 113, 2:1", 0, "center");
    }
}
// C) drawer catch, plan cut at z = 3.6 (one side), 4:1
module plan_cut(z) parts() {
    projection(cut = true) translate([0, 0, -z]) body(); projection(cut = true) translate([0, 0, -z]) cap();
    projection(cut = true) translate([0, 0, -z]) blade(); projection(cut = true) translate([0, 0, -z]) drawer();
    projection(cut = true) translate([0, 0, -z]) spare_blades();
}
translate([-150, -125]) {
    k = 4;
    scale(k) clip(64, 4, 22, 11) plan_cut(3.6);
    color("#000") ann() ex(0.2) {
        leader([72 * k, 12.1 * k], [72 * k - 8, 66], "groove 0.6 deep", "right");
        leader([72.6 * k, 11.7 * k], [80 * k, 66], "bump 0.7, 45 deg both ways", "left");
        leader([76 * k, 10.7 * k], [80 * k, 52], "arm 10 x 1.2, flexes 0.5 sideways", "left");
        label([64 * k, 6], "C: DRAWER CATCH, PLAN CUT AT Z = 3.6, 4:1", 0, "left");
    }
}
color("#000") ann() ex(0.2) label([-30, -142], "BLADE SCRAPER - v5 - flowing head, blade drawer (body + drawer new; cap + guard as v4), dimensions in mm", 0, "left");
