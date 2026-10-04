// Dimensioned drawing sheet for scraper-v7: the guard grips the head, not the cap.
use <../scraper-v7.scad>

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
// body light grey, cap orange, blade black, guard green
module parts() {
    color("#c4c4c4") ex(0.1) children(0);
    color("#e8a33d") translate([0, 0, 0.02]) ex(0.1) children(1);
    color("#222222") translate([0, 0, 0.04]) ex(0.1) children(2);
    color("#5cb88a") translate([0, 0, 0.06]) ex(0.1) children(3);
}
module section_xz(y0 = 0) parts() { cut_xz(y0) body(); cut_xz(y0) cap(); cut_xz(y0) blade(); cut_xz(y0) guard(); }
module section_yz(x0 = 0) parts() { cut_yz(x0) body(); cut_yz(x0) cap(); cut_yz(x0) blade(); cut_yz(x0) guard(); }

// ================= SHEET =================
// A) section on the centre line through the guard, 3:1
{
    k = 3;
    scale(k) clip(-3, -5, 30, 15) section_xz(0);
    color("#000") ann() ex(0.2) {
        dim_h(-1.7 * k, 18 * k, -20, "19.7", -3.7 * k);
        dim_v(-2.4 * k, 1.8 * k, -16, "4.2", -1.7 * k);
        dim_v(-3.7 * k, 4.7 * k, 90, "8.4", 18 * k);
        leader([12 * k, 4.6 * k], [20, 40], "open over the head", "right");
        leader([3 * k, 1.8 * k], [-20, 30], "closed over the exposed blade", "right");
        label([-8, -32], "A: SECTION ON THE CENTRE LINE, 3:1", 0, "left");
    }
}
// B) cross section at x = 15.5 through the grip pads, 2:1
translate([170, 0]) {
    k = 2;
    scale(k) clip(-34, -5, 68, 14) section_yz(15.5);
    color("#000") ann() ex(0.2) {
        dim_h(-32.2 * k, 32.2 * k, -18, "64.4", -3.7 * k);
        dim_h(-24.45 * k, 24.45 * k, 22, "pads 48.9 (head 49.6)", 4.7 * k);
        leader([25.5 * k, 4.4 * k], [40, 36], "pads grip the head, not the cap", "left");
        label([-60, -30], "B: SECTION AT X = 15.5 (GRIP PADS), 2:1", 0, "left");
    }
}
// C) plan cut at z = 4.2 through the rails, 1:1
translate([20, -85]) {
    color("#5cb88a") ex(0.1) projection(cut = true) translate([0, 0, -4.2]) guard();
    color("#000") ann() ex(0.2) {
        dim_v(-32.2, 32.2, -10, "64.4", -1.7);
        dim_h(-1.7, 18, -40, "19.7", -32.2);
        leader([15, 24.5], [32, 30], "grip pads, 0.35 into the head", "left");
        label([-10, 42], "C: PLAN CUT AT Z = 4.2 (RAILS), 1:1", 0, "left");
    }
}
color("#000") ann() ex(0.2) label([-30, -145], "BLADE SCRAPER - v7 - guard grips the head, not the cap (body, cap, drawer as v6), dimensions in mm", 0, "left");
