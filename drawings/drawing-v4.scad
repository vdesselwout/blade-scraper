// Dimensioned drawing sheet for scraper-v4: tapered dovetails on the head and cap (+ guard to match).
use <../scraper-v4.scad>

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

// each part in its own shade, the changed guard in orange; notes sit above the sections
module ann() if (flat) children(); else translate([0, 0, 0.3]) children();
module cut_xz(y0) projection(cut = true) translate([0, 0, y0]) rotate([-90, 0, 0]) children();
module cut_yz(x0) projection(cut = true) translate([0, 0, -x0]) rotate([-90, 0, 0]) rotate([0, 0, -90]) children();
module parts() {
    color("#c4c4c4") ex(0.1) children(0);
    color("#e8a33d") translate([0, 0, 0.02]) ex(0.1) children(1);
    color("#222222") translate([0, 0, 0.04]) ex(0.1) children(2);
    if ($children > 3) color("#b0b0b0") translate([0, 0, 0.06]) ex(0.1) children(3);
}
module section_xz(y0 = 0) parts() { cut_xz(y0) body(); cut_xz(y0) cap(); cut_xz(y0) blade(); }
module section_yz(x0 = 0) parts() { cut_yz(x0) body(); cut_yz(x0) cap(); cut_yz(x0) blade(); }
module plan(z) {   // cut at height z, seen from above: body light, cap orange
    color("#c4c4c4") ex(0.1) projection(cut = true) translate([0, 0, -z]) body();
    color("#e8a33d") translate([0, 0, 0.06]) ex(0.1) projection(cut = true) translate([0, 0, -z]) cap();
}

function hw0_at(x) = 26.8 + 0.05 * (x - 6);
function cap_at(x) = hw0_at(x) + 2.45;
// ================= SHEET =================
// A) plan view cut at z = 1 (through the dovetails), 2:1, front edge left
{
    k = 2;
    scale(k) clip(-2, -34, 44, 68) plan(1);
    color("#000") ann() ex(0.2) {
        dim_v(-29.25 * k, 29.25 * k, -12, "58.5 cap at front (as v1)", 6 * k);
        dim_v(-30.75 * k, 30.75 * k, 96, "61.5 cap at back", 36 * k);
        leader([20 * k, 26.5 * k], [104, 74], "dovetail widens 0.05 mm per mm, each side");
        leader([30 * k, -27.3 * k], [104, -92], "clamp engages only in the last 2 mm of travel");
        label([40, -82], "A: PLAN CUT AT Z = 1 (HEAD + CAP), 2:1");
    }
}
// B) section at x = 8, near the front, 3:1
translate([200, 32]) {
    k = 2;
    scale(k) clip(-32, -3, 64, 12) section_yz(8);
    color("#000") ann() ex(0.2) {
        dim_h(-hw0_at(8) * k, hw0_at(8) * k, 30, str(2 * hw0_at(8), " head at sole"), 0);
        dim_h(-cap_at(8) * k, cap_at(8) * k, -18, str(2 * cap_at(8)), -2.2 * k);
        label([0, -26], "B: SECTION AT X = 8, 2:1");
    }
}
// C) section at x = 34, near the back, 3:1
translate([200, -45]) {
    k = 2;
    scale(k) clip(-32, -3, 64, 12) section_yz(34);
    color("#000") ann() ex(0.2) {
        dim_h(-hw0_at(34) * k, hw0_at(34) * k, 30, str(2 * hw0_at(34), " head at sole"), 0);
        dim_h(-cap_at(34) * k, cap_at(34) * k, -18, str(2 * cap_at(34)), -2.2 * k);
        label([0, -26], "C: SECTION AT X = 34, 2:1 (45° lips, 0.1 overlap when home)");
    }
}
color("#000") ann() ex(0.2) label([-30, -110], "BLADE SCRAPER - v4 - tapered dovetails (body + cap + guard), dimensions in mm", 0, "left");
