"""Build a Creality Print project (.3mf) with the model and all print settings.

Settings come from the config block of a gcode Creality Print sliced for the K2 Pro;
the 3mf layout mirrors Creality Print's own project files (resources/calib/*.3mf).

    py tools/make_3mf.py <settings.gcode> <model.stl> <out.3mf> [filament slot, default 1]
"""
import datetime, json, os, re, struct, sys, uuid, zipfile

# Changes on top of the sliced settings (none: reprint with exactly what was sliced)
OVERRIDES = {}

# Template from Creality Print 7.2 resources: tells which settings are lists in JSON
TEMPLATE = r"C:\Program Files\Creality\Creality Print 7.2\resources\calib\tolerance_test\CrealityToleranceTest.3mf"
# Full settings JSON from a Creality Print session: covers the newer settings the template lacks
TYPES = os.path.join(os.path.dirname(__file__), "creality-settings-types.config")


def unescape(s):
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "r": "\r", "t": "\t"}.get(m.group(1), m.group(1)), s)


def gcode_config(path):
    cfg, inside = {}, False
    for line in open(path, encoding="utf-8", errors="ignore"):
        if line.startswith("; CONFIG_BLOCK_START"):
            inside = True
        elif line.startswith("; CONFIG_BLOCK_END"):
            break
        elif inside and " = " in line:
            k, v = line[2:].rstrip("\n").split(" = ", 1)
            cfg[k] = v
        elif inside and line.rstrip().endswith(" ="):
            cfg[line[2:].rstrip()[:-2]] = ""
    return cfg


def split_strings(v):
    """String vector as written in gcode: items separated by ';', each optionally quoted."""
    items = re.findall(r'(?:^|;)("(?:[^"\\]|\\.)*"|[^;]*)', v)
    return [unescape(x[1:-1]) if x.startswith('"') else unescape(x) for x in items]


def to_list(v, tmpl):
    numeric = all(re.fullmatch(r"[-\d.%x]*", str(t)) for t in tmpl)
    if v.startswith('"') or ";" in v or not (numeric or "," in v):
        return split_strings(v)
    return v.split(",")                          # numeric / point / enum vector


def project_settings(cfg, version, suffix):
    with zipfile.ZipFile(TEMPLATE) as z:
        tmpl = json.loads(z.read("Metadata/project_settings.config"))
    tmpl.update(json.load(open(TYPES, encoding="utf-8")))
    cfg = dict(cfg, **OVERRIDES)
    out = {}
    for k, v in sorted(cfg.items()):
        if isinstance(tmpl.get(k), list):
            out[k] = to_list(v, tmpl[k])
        elif k not in tmpl and ";" in v and r"\n" not in v:   # unknown key, ';'-separated (not gcode): a list
            out[k] = split_strings(v)
        else:
            out[k] = unescape(v[1:-1]) if v.startswith('"') and v.endswith('"') else unescape(v)
    # Preset names that match a system preset make Creality Print load that preset's
    # defaults; a "(project.3mf)" suffix (as in Creality's own 3mfs) keeps our values.
    out["print_settings_id"] += suffix
    out["printer_settings_id"] += suffix
    out["filament_settings_id"] = [f + suffix for f in out["filament_settings_id"]]
    out.update({"from": "project", "name": "project_settings", "version": version})
    return out


def preset_keys():
    """Which settings belong to the process, filament and printer presets, from the
    system profiles plus Creality's example project."""
    import glob
    keys = {"process": set(), "filament": set(), "machine": set()}
    base = os.path.expandvars(r"%APPDATA%\Creality\Creality Print")
    for t in keys:
        for f in glob.glob(os.path.join(base, "*", "system", "Creality", t, "**", "*.json"), recursive=True):
            try:
                keys[t] |= set(json.load(open(f, encoding="utf-8")))
            except ValueError:
                pass
    with zipfile.ZipFile(TEMPLATE) as z:
        for t in keys:
            keys[t] |= set(json.loads(z.read(f"Metadata/{t}_settings_1.config")))
    meta = {"name", "inherits", "from", "version", "setting_id", "instantiation", "type", "filament_id"}
    return {t: k - meta for t, k in keys.items()}


def project_presets(ps, version):
    """The project's own presets, embedded like Creality's example project does.
    Without them the "(project.3mf)" preset names don't exist and Creality Print
    falls back to its default presets."""
    keys = preset_keys()
    parents = ps.get("inherits_group", [])
    n = len(ps["filament_settings_id"])
    parent = lambda i: parents[i] if i < len(parents) else ""
    files = {}

    def preset(t, name, inherits, values):
        p = {k: v for k, v in values.items() if k in keys[t]}
        p.update({"name": name, "inherits": inherits, "from": "project", "version": version})
        return json.dumps(p, indent=4, ensure_ascii=False)

    name = ps["print_settings_id"]
    files["Metadata/process_settings_1.config"] = preset(
        "process", name, parent(0), dict(ps, print_settings_id=name, compatible_printers=[]))
    for i, name in enumerate(ps["filament_settings_id"]):
        one = {k: [v[i]] if isinstance(v, list) and len(v) == n else v for k, v in ps.items()}
        one.update(filament_settings_id=[name], compatible_printers=[], compatible_prints=[])
        files[f"Metadata/filament_settings_{i + 1}.config"] = preset("filament", name, parent(1 + i), one)
    name = ps["printer_settings_id"]
    files["Metadata/machine_settings_1.config"] = preset("machine", name, parent(1 + n), dict(ps, printer_settings_id=name))
    return files


def read_stl(path):
    data = open(path, "rb").read()
    if data[:5] == b"solid" and b"facet" in data[:400]:
        v = [tuple(map(float, m)) for m in re.findall(rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)", data)]
    else:
        n = struct.unpack("<I", data[80:84])[0]
        v = [struct.unpack("<3f", data[84 + 50 * i + 12 * (j + 1): 84 + 50 * i + 12 * (j + 2)])
             for i in range(n) for j in range(3)]
    idx, verts, tris = {}, [], []
    for i in range(0, len(v), 3):
        t = []
        for p in v[i:i + 3]:
            if p not in idx:
                idx[p] = len(verts); verts.append(p)
            t.append(idx[p])
        tris.append(t)
    return verts, tris


def main(gcode, stl, out, extruder="1"):
    cfg = gcode_config(gcode)
    version = re.search(r"Creality_Print V([\d.]+)", open(gcode, encoding="utf-8", errors="ignore").read(2000)).group(1)
    verts, tris = read_stl(stl)

    # centre the mesh on its bounding box (as Creality Print does), place on bed centre
    lo = [min(p[i] for p in verts) for i in range(3)]
    hi = [max(p[i] for p in verts) for i in range(3)]
    c = [(lo[i] + hi[i]) / 2 for i in range(3)]
    bed = [list(map(float, p.split("x"))) for p in cfg["printable_area"].split(",")]
    bx = (min(p[0] for p in bed) + max(p[0] for p in bed)) / 2
    by = (min(p[1] for p in bed) + max(p[1] for p in bed)) / 2
    place = f"1 0 0 0 1 0 0 0 1 {bx:g} {by:g} {hi[2] - c[2]:g}"
    name = stl.replace("\\", "/").split("/")[-1]
    today = datetime.date.today().isoformat()
    U = lambda: str(uuid.uuid4())

    ns = ('xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
          'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
          'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" requiredextensions="p"')
    obj = [f'<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" {ns}>',
           ' <metadata name="BambuStudio:3mfVersion">1</metadata>\n <resources>',
           f'  <object id="1" p:UUID="{U()}" type="model">\n   <mesh>\n    <vertices>']
    obj += [f'     <vertex x="{x - c[0]:.6g}" y="{y - c[1]:.6g}" z="{z - c[2]:.6g}"/>' for x, y, z in verts]
    obj += ['    </vertices>\n    <triangles>']
    obj += [f'     <triangle v1="{a}" v2="{b}" v3="{d}"/>' for a, b, d in tris]
    obj += ['    </triangles>\n   </mesh>\n  </object>\n </resources>\n <build/>\n</model>']

    root = f'''<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" {ns}>
 <metadata name="Application">Creality_Print V{version}</metadata>
 <metadata name="BambuStudio:3mfVersion">1</metadata>
 <metadata name="CreationDate">{today}</metadata>
 <metadata name="ModificationDate">{today}</metadata>
 <metadata name="Title">{name}</metadata>
 <resources>
  <object id="2" p:UUID="{U()}" type="model">
   <components>
    <component p:path="/3D/Objects/object_1.model" objectid="1" p:UUID="{U()}" transform="1 0 0 0 1 0 0 0 1 0 0 0"/>
   </components>
  </object>
 </resources>
 <build p:UUID="{U()}">
  <item objectid="2" p:UUID="{U()}" transform="{place}" printable="1"/>
 </build>
</model>'''

    model_settings = f'''<?xml version="1.0" encoding="UTF-8"?>
<config>
  <object id="2">
    <metadata key="name" value="{name}"/>
    <metadata key="extruder" value="{extruder}"/>
    <part id="1" subtype="normal_part">
      <metadata key="name" value="{name}"/>
      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>
    </part>
  </object>
  <plate>
    <metadata key="plater_id" value="1"/>
    <metadata key="plater_name" value=""/>
    <metadata key="bed_type" value="{cfg.get('curr_bed_type', '')}"/>
    <metadata key="locked" value="false"/>
    <model_instance>
      <metadata key="object_id" value="2"/>
      <metadata key="instance_id" value="0"/>
      <metadata key="identify_id" value="1"/>
    </model_instance>
  </plate>
  <assemble>
   <assemble_item object_id="2" instance_id="0" transform="{place}" offset="0 0 0" />
  </assemble>
</config>'''

    with zipfile.ZipFile(TEMPLATE) as t:
        keep = {n: t.read(n) for n in ("[Content_Types].xml", "Metadata/creality.config",
                                       "Metadata/slice_info.config", "Metadata/custom_gcode_per_layer.xml")}
    keep["Metadata/creality.config"] = re.sub(rb'(AppVersion" value=")[^"]*', rb"\g<1>" + version.encode(),
                                              keep["Metadata/creality.config"])
    rels = lambda target: ('<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                           f' <Relationship Target="{target}" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>\n</Relationships>')

    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for n, d in keep.items():
            z.writestr(n, d)
        z.writestr("_rels/.rels", rels("/3D/3dmodel.model"))
        z.writestr("3D/_rels/3dmodel.model.rels", rels("/3D/Objects/object_1.model"))
        z.writestr("3D/3dmodel.model", root)
        z.writestr("3D/Objects/object_1.model", "\n".join(obj))
        z.writestr("Metadata/model_settings.config", model_settings)
        ps = project_settings(cfg, version, f"({os.path.basename(out)})")
        z.writestr("Metadata/project_settings.config", json.dumps(ps, indent=4, ensure_ascii=False))
        presets = project_presets(ps, version)
        for n, d in presets.items():
            z.writestr(n, d)
    print(f"{out}: {len(verts)} vertices, {len(tris)} triangles, {len(cfg)} settings, "
          f"{len(presets)} embedded presets, Creality Print {version}")


if __name__ == "__main__":
    main(*sys.argv[1:5])
