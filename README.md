# main-map-geojson

Static GeoJSON layers for the B'Tselem interactive map (btselem.org/map).

Served to the site through jsDelivr, pinned to a commit:
`https://cdn.jsdelivr.net/gh/btselem/main-map-geojson@<commit>/<file>`

This repo is a git submodule of the Drupal site at
`web/modules/custom/btselem_maps/vectormaps/geojson`. After pushing a change here,
commit the updated submodule pointer in the site repo and run **Generate GeoJSON**
(`/admin/config/geojson-operations`) so the map styles point at the new commit.

## Vector tiles (static.pmtiles)

`static.pmtiles` holds the same layers as vector tiles in one file, so a map
loads only the tiles it shows (about 1.4 MB for the whole West Bank) instead
of 27 MB of GeoJSON. The site reads it from GitHub Pages:
`https://projects.btselem.org/main-map-geojson/static.pmtiles` (the
organisation's Pages domain; range requests,
CORS open). The GeoJSON files stay: they are the source, and the Hebron map
still loads `hebron-oldcity-roads.geojson` and `unleashed.geojson`.

After changing a GeoJSON file, rebuild the tiles (needs Docker only) and
commit both:

    build/build-pmtiles.sh

The layer list in `build/build-pmtiles.sh` follows the site's map style
(`btselem_maps/assets/style/btselem.json`): one layer per GeoJSON source, named
after the source id.
