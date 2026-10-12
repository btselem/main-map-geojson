# main-map-geojson

Static GeoJSON layers for the B'Tselem interactive map (btselem.org/map).

Served to the site through jsDelivr, pinned to a commit:
`https://cdn.jsdelivr.net/gh/btselem/main-map-geojson@<commit>/<file>`

This repo is a git submodule of the Drupal site at
`web/modules/custom/btselem_maps/vectormaps/geojson`. After pushing a change here,
commit the updated submodule pointer in the site repo and run **Generate GeoJSON**
(`/admin/config/geojson-operations`) so the map styles point at the new commit.
