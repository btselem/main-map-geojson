#!/usr/bin/env bash
# Builds static.pmtiles: the static layers of the B'Tselem map as vector
# tiles in one file, so a map loads only the tiles it shows instead of every
# GeoJSON file. Each layer is named after the style's source id.
#
# Needs Docker only (tippecanoe runs in a container). From the repo root:
#   build/build-pmtiles.sh
# then commit static.pmtiles with the GeoJSON change it follows.
set -euo pipefail
cd "$(dirname "$0")/.."

# Style source id = GeoJSON file (without .geojson).
LAYERS=(
  areas-a-b=areas-a-b settler-houses=settler-houses israeldata=israeldata
  settlements-muni-border=settlements-muni-border settlements-border=settlements-border
  barrier-2016=barrier-2016 jerusalem-municipal-border=jerusalem-municipal-border
  area-c=area-c ej-settlements=ej-settlements military-bases=military-bases
  arial-1=arial-1 green-line=green-line muvlaot=muvlaot arial-2=arial-2
  hebron=hebron e1=e1 h1h2=h1h2 gates=gates built-up-area-palestinian=bimkom
)

docker build -q -t local/tippecanoe build >/dev/null
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
files=()
args=()
for pair in "${LAYERS[@]}"; do
  files+=("${pair#*=}.geojson")
  args+=(-L "${pair%%=*}:prep/${pair#*=}.geojson")
done
# tippecanoe skips GeometryCollections (127 shapes, mostly built-up areas).
python3 -I build/flatten.py . "$work/prep" "${files[@]}"
# -r1: keep every point at every zoom (gates, settler houses); no feature or
# tile size limits and no tiny-polygon reduction: no shape is dropped. Zoom
# 14 is exact to about half a metre; the map over-zooms it beyond.
docker run --rm -u "$(id -u):$(id -g)" -v "$work":/data local/tippecanoe \
  tippecanoe -o static.pmtiles --force -Z4 -z14 -r1 \
  --no-feature-limit --no-tile-size-limit --no-tiny-polygon-reduction \
  --detect-shared-borders --quiet "${args[@]}" 2>&1 | grep -v 'dimensions beyond two' || true
cp "$work/static.pmtiles" static.pmtiles
ls -l static.pmtiles
