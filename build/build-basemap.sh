#!/usr/bin/env bash
# Builds basemap.pmtiles: the base map under the B'Tselem maps (land cover,
# roads and their names, water, waterways) for our area only, from
# OpenStreetMap, in the OpenMapTiles schema the site's style already uses
# (it was served by Stadia Maps). Run it when newer roads are wanted.
#
# Needs Docker only. Downloads go to $WORK (default ~/projects/basemap-work),
# outside the repo. From the repo root:
#   build/build-basemap.sh
# then commit basemap.pmtiles.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO=$PWD
WORK=${WORK:-$HOME/projects/basemap-work}
# West of Gaza to east of the Jordan Valley, Eilat to the Litani: the area
# the maps show, with a margin.
BOUNDS=33.8,29.3,36.4,33.6
mkdir -p "$WORK/osm"

# OpenStreetMap extracts that touch the box (Geofabrik, updated daily).
for area in asia/israel-and-palestine asia/jordan asia/lebanon asia/syria africa/egypt; do
  file="$WORK/osm/$(basename "$area").osm.pbf"
  [ -s "$file" ] || curl -sSfL -o "$file" "https://download.geofabrik.de/$area-latest.osm.pbf"
done

docker build -q -t local/osmium -f - "$WORK" >/dev/null <<'DOCKER'
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends osmium-tool && rm -rf /var/lib/apt/lists/*
WORKDIR /data
DOCKER
# Merge them and keep the box only.
docker run --rm -u "$(id -u):$(id -g)" -v "$WORK":/data local/osmium sh -c \
  "osmium merge osm/*.osm.pbf -o merged.osm.pbf --overwrite && osmium extract -b $BOUNDS merged.osm.pbf -o area.osm.pbf --overwrite"

# The layers the style reads, to zoom 14 (the map over-zooms beyond).
# --download fetches the sea (water polygons) and Natural Earth once.
docker run --rm -u "$(id -u):$(id -g)" -v "$WORK":/data ghcr.io/onthegomap/planetiler:0.9.1 \
  --osm-path=/data/area.osm.pbf --download --download-dir=/data/sources --tmpdir=/data/tmp \
  --only-layers=landcover,transportation,transportation_name,water,waterway \
  --bounds=$BOUNDS --maxzoom=14 --output=/data/basemap.pmtiles --force
cp "$WORK/basemap.pmtiles" "$REPO/basemap.pmtiles"
ls -l "$REPO/basemap.pmtiles"
