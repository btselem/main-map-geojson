"""Copies GeoJSON files, splitting (nested) GeometryCollections, which
tippecanoe skips, into one Multi* geometry per kind, same properties."""
import json, sys, os
src, dst = sys.argv[1], sys.argv[2]
os.makedirs(dst, exist_ok=True)
KIND = {'Point': 'MultiPoint', 'MultiPoint': 'MultiPoint', 'LineString': 'MultiLineString', 'MultiLineString': 'MultiLineString', 'Polygon': 'MultiPolygon', 'MultiPolygon': 'MultiPolygon'}
def parts(g, out):
    if not g: return
    if g['type'] == 'GeometryCollection':
        for x in g['geometries']: parts(x, out)
    elif g['type'].startswith('Multi'):
        out.setdefault(g['type'], []).extend(g['coordinates'])
    else:
        out.setdefault(KIND[g['type']], []).append(g['coordinates'])
for f in sys.argv[3:]:
    j = json.load(open(os.path.join(src, f)))
    feats = []
    for ft in j['features']:
        g = ft.get('geometry')
        if g and g['type'] == 'GeometryCollection':
            out = {}
            parts(g, out)
            feats += [dict(ft, geometry={'type': t, 'coordinates': c}) for t, c in out.items()]
        else:
            feats.append(ft)
    j['features'] = feats
    json.dump(j, open(os.path.join(dst, f), 'w'), ensure_ascii=False)
