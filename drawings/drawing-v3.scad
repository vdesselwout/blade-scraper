// Dimensioned drawing sheet for scraper-v3: the guard (the only part changed since v1).
use <../scraper-v3.scad>

flat = false;
module ex(h) if (flat) children(); else linear_extrude(h) children();
module model() scraper("assembly_guard");

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
    color("#8c8c8c") translate([0, 0, 0.02]) ex(0.1) children(1);
    color("#222222") translate([0, 0, 0.04]) ex(0.1) children(2);
    color("#e8a33d") translate([0, 0, 0.06]) ex(0.1) children(3);
}
module section_xz(y0 = 0) parts() { cut_xz(y0) body(); cut_xz(y0) cap(); cut_xz(y0) blade(); cut_xz(y0) guard(); }
module section_yz(x0 = 0) parts() { cut_yz(x0) body(); cut_yz(x0) cap(); cut_yz(x0) blade(); cut_yz(x0) guard(); }
module guard_plan(z) color("#e8a33d") ex(0.1) projection(cut = true) translate([0, 0, -z]) guard();

// ================= SHEET =================
// A) section across the head with the guard on, at x = 12, 3:1
{
    k = 3;
    scale(k) clip(-34, -5, 68, 16) section_yz(12);
    color("#000") ann() ex(0.2) {
        dim_h(-31 * k, 31 * k, -24, "62 blade slot + relief", -1.2 * k);
        dim_h(-29.55 * k, 29.55 * k, 40, "59.1 over the cap walls", 8 * k);
        dim_v(-1.2 * k, 0.6 * k, 108, "1.8", 31 * k);
        dim_v(-2.5 * k, 0.6 * k, 124, "3.1", 31 * k);
        leader([29.2 * k, 1.9 * k], [118, 22], "friction bump R0.75");
        leader([-24 * k, -0.3 * k], [-118, 22], "blade", "right");
        label([0, -34], "A: SECTION AT X = 12 (HEAD + CAP + BLADE + GUARD), 3:1");
    }
}
// B) side section through the relief at y = 30, 4:1
translate([175, 0]) {
    k = 4;
    scale(k) clip(-3, -5, 23, 16) section_xz(30);
    color("#000") ann() ex(0.2) {
        dim_h(-2.1 * k, 18 * k, -24, "20.1", -4.1 * k);
        leader([17.6 * k, -2.9 * k], [92, -12], "0.8 lead-in chamfer");
        leader([12 * k, -2 * k], [92, 2], "relief");
        label([36, -34], "B: SIDE SECTION AT Y = 30, 4:1");
    }
}
// C) guard alone, cut in the blade plane (z = -0.3), 2:1, front edge up
translate([0, -62]) {
    k = 2;
    scale(k) rotate(-90) guard_plan(-0.3);
    color("#000") ann() ex(0.2) {
        dim_h(-31 * k, 31 * k, -44, "62 slot runs through to the mouth", -18 * k);
        dim_h(-32.6 * k, 32.6 * k, 12, "65.2", 2.1 * k);
        label([0, -58], "C: GUARD ALONE, CUT IN THE BLADE PLANE, 2:1 (mouth down)");
    }
}
color("#000") ann() ex(0.2) label([-102, -132], "BLADE SCRAPER - v3 - guard only (body and cap unchanged from v1) - dimensions in mm", 0, "left");
