# Blade scraper — review log

Approved version: **v1** (2026-10-03); v3 guard (fits the printed v1) and v4 tapered dovetails pending test prints; v5 (new handle, blade drawer) pending review. Print files are in prints/vN/: v1 body, cap, test-fit piece and the sliced gcode; v3 guard (plus all three parts with the v3 guard); v4 all parts and test-fit project; v5 all four parts and the drawer test-fit project. Design concepts are in concepts/.

| Version | Changes | Why | Verdict |
|---|---|---|---|
| v1 | First model: body with rising D-section handle, slide-on cap with pegs + 45° dovetails + snap tab, slide-on guard, test-fit piece | Design brief | approved |
| v2 | Guard: the 62 mm blade slot now runs through to the mouth; friction bumps moved above the slot | The guard's mouth was only 59 mm wide, narrower than the 61 mm cutting edge that has to pass through it, so the guard couldn't slide on | reviewed: folded into v3 before printing |
| v3 | Guard: walls relieved to the blade slot's width below the slot; 0.8 mm lead-in chamfer at the mouth | The cap's flared first layers (elephant's foot) caught on one side, and the mouth's own first layers narrow the opening | pending: test print |
| v4 | Tapered dovetails: head and cap widen 0.05 mm per mm per side towards the back (cap 58.5 mm at the front as before, 61.5 mm at the back); guard follows the wider cap | Sliding the cap on dragged the blade out of the pocket: the clamp was tight over the whole travel and nothing stops the blade moving forward. Now the lips only touch in the last 2 mm | pending: test-fit print |
| v5 | New handle: 155.5 mm overall (was 177), 31 × 19 mm palm swell, one smooth spline. Head above the cap lofted into the grip; below 3.6 mm and under the guard it is v4's exactly, so cap and guard are unchanged. Blade drawer: a tray for 5 spare blades slides in from the butt and clicks shut on two side-flexing arms. Drawer test-fit piece | User wanted it sleeker, shorter and lighter on filament, safe storage for spare blades, and a head that flows into the handle. Chosen from the v5 concept study (concept 2 with the flowing head) | pending: review, then drawer test-fit print |
