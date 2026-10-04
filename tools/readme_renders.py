"""Render the README images for one model version into images/.

    py tools/readme_renders.py 6

Uses the model's own part selector (scraper(sel)); the assemblies are coloured by the model,
the print-bed layout gets one colour here.
"""
import os, subprocess, sys, tempfile

OPENSCAD = r"C:\Program Files\OpenSCAD (Nightly)\openscad.com"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# name: (part selector, view rotation x,y,z); every view is framed with --viewall
VIEWS = {
    "scraper": ("assembly", "58,0,-38"),
    "scraper-guard": ("assembly_guard", "50,0,-50"),
    "scraper-drawer": ("assembly_open", "52,0,-145"),
    "scraper-print-bed": ("all", "40,0,-20"),
}


def main(v):
    out = os.path.join(ROOT, "images")
    os.makedirs(out, exist_ok=True)
    model = os.path.join(ROOT, f"scraper-v{v}.scad").replace("\\", "/")
    for name, (sel, rot) in VIEWS.items():
        wrapper = os.path.join(tempfile.gettempdir(), "readme_view.scad")
        part = f'color("#8fb3d9") scraper("all");' if sel == "all" else f'scraper("{sel}");'
        open(wrapper, "w").write(f"use <{model}>\n{part}\n")
        png = os.path.join(out, f"{name}.png")
        subprocess.run([OPENSCAD, "--backend=manifold", "--render", "--colorscheme=Tomorrow", "--imgsize=2400,1600",
                        "--projection=p", f"--camera=0,0,0,{rot},300", "--viewall", "--autocenter", "-o", png, wrapper],
                       check=True, capture_output=True)
        crop(png)
        print(png)


def crop(png, pad=40):
    """Trim the empty background around the render (needs Pillow)."""
    from PIL import Image, ImageChops
    im = Image.open(png).convert("RGB")
    box = ImageChops.difference(im, Image.new("RGB", im.size, im.getpixel((0, 0)))).getbbox()
    if box:
        im.crop((max(box[0] - pad, 0), max(box[1] - pad, 0), min(box[2] + pad, im.width), min(box[3] + pad, im.height))).save(png)


if __name__ == "__main__":
    main(int(sys.argv[1]))
