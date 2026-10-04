# Design brief

A hand-held razor scraper for flat surfaces (glass, tiles, print beds, labels, paint), holding one standard trapezoid utility blade across the front of the handle. Printed in PLA, assembled without screws or other hardware.

| Requirement | Value | Source |
|---|---|---|
| Use | Flat-surface scraping at a low angle (about 15–35°), full cutting edge exposed | user |
| Blade | Trapezoid utility blade, 61 mm edge × 19 mm tall × 0.6 mm, two notches in the back edge, no holes | user / standard |
| Blade back edge | 31.6 mm, so each slanted side runs 14.7 mm sideways over 19 mm | measured from photo with ruler |
| Notches | 3.35 mm wide, 3.85 mm deep (to the tip of the round end), centres 6.65 mm apart, centred on the back edge | measured from photo with ruler (±0.2 mm) |
| Blade retention | Concept A: pegs in the notches, slide-on clamp cap with dovetail and snap | user |
| Blade exposure | 6 mm beyond the holder | user |
| Handle | Sleek, shorter, less filament than v4 (v5: 155.5 mm overall, D-section 31 × 19 mm at the palm swell), waist near the head, thumb/index-finger dish on top | user (v5) |
| Head shape | Flows smoothly into the grip; sole, dovetails, grooves and snap stay as v4 | user (v5) |
| Blade storage | Spare blades kept safely inside the handle: drawer from the butt, 5 blades flat, edges enclosed, clicks shut | user (v5) |
| Blade guard | Separate slide-on guard, as slim as possible to match the head (v6: open-top frame, 8.4 mm tall; closed only over the exposed blade) | user (v6) |
| Material / printer | PLA, 0.4 mm nozzle, bed ≥ 220 mm | user |
| Warping | Curved plan outline with no long straight walls, rounded ends, 0.6 mm bed chamfers; every part prints without supports | user |
| Hardware | None. Four printed parts: body, cap, guard, blade drawer | user |

## How the blade is held

Seen from the side, top to bottom: the body (head and handle), then the blade, then the cap. The surface being scraped is below the cap.

- **Cap (surface side):** a thin plate with a 0.6 mm blade-shaped pocket and two pegs that go up through the notches. Its side walls hook onto 45° dovetails on the sides of the head.
- **Changing the blade:** lay the blade in the cap, then slide the cap backwards onto the head until it clicks. The pegs run in two grooves under the head, and the end of each groove is the hard stop.
- **Load path:** scraping pushes the blade back into the pegs, the pegs push into the groove ends in the body, so the force goes straight into the handle and never through the snap.
- **Clamping:** the cap's dovetail lips overlap the head by 0.1 mm, so the cap walls have to spread slightly to slide on and then pull the cap up against the blade over its whole covered area (about 13 × 32–52 mm). The pocket is 0.45 mm deep for the 0.6 mm blade, so the cap never touches the body and all the clamping force goes through the blade. The only thing that stops the blade being pulled straight forward is this clamping friction, because the notches open towards the back.
- **Snap:** a flexible tab in the cap behind the blade has a bump that clicks into a 45° dimple under the head. It only stops the cap creeping forward. To release it, pull the cap firmly forward and the bump ramps out.
- **Surface clearance:** the cap is 1.6 mm thick under the blade, with a 45° chamfer at the front, so the scraper can be used down to about 12° from the surface.

## Why "cranked" becomes "rising handle"

The body prints on its flat underside, so the handle's underside has to stay on the bed: a real downward bend would need supports. Instead the grip's top rises from about 7 mm at the head to 19 mm at the palm swell (26 mm before v5), so the handle's centre line climbs like a crank while the underside stays flat. Held at a normal scraping angle, the underside lifts away from the surface along the whole length.

Interfaces
- Blade ↔ cap pocket: +0.25 mm clearance on the outline, pocket depth 0.45 mm (the blade stands 0.15 mm proud).
- Notches ↔ pegs: pegs Ø 3.0 mm (notch 3.35 mm), sitting against the round end of each notch.
- Pegs ↔ body grooves: groove 3.4 mm wide, 1.8 mm deep, open at the front, closed at the stop.
- Cap ↔ head dovetail: 45°, 2 mm high, 0.1 mm overlap that sets the clamping force.
- Guard ↔ head: friction fit over the cap walls, 0.3 mm clearance plus two small bumps. From v6 the guard is open over the head (opening = head band + 0.6 mm) and its rails hook over the cap walls.
- Drawer ↔ channel: 23 × 4.8 mm channel, 0.2 mm clearance per side and over the top.
- Drawer catch: two 10 × 1.2 mm arms flex sideways; 0.7 mm bumps click into 0.6 mm grooves in the channel walls (0.5 mm flex while sliding).

Out of scope / nice-to-have
- Adjustable blade exposure, hang hole, text or logo.

Assumptions to check
- Notch values come from a photo, so they're good to about ±0.2 mm. The first print is a small **test-fit piece** (the head plus cap, about 10 minutes) to check the pegs, pocket, dovetail and snap before printing the full handle.
- The 0.1 mm dovetail overlap (the clamping force) may need tuning on your printer. It's a single parameter, `clamp_interference`.
- The drawer catch force depends on the printer; `catch_h` (bump height) tunes it. The drawer test-fit piece (about 6 g) checks the sliding fit and the click.
