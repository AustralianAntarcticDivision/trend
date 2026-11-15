# trend

Landing page and presentation home for the trend family of ocean
climate records: daily
satellite fields reduced to exact, mergeable statistics on S2 level-5
cells, kept current on Pawsey.

| record | sources | site | repo |
|---|---|---|---|
| sea surface temperature | NOAA OISST v2.1, GHRSST MUR | https://mdsumner.github.io/trend.sst/ | [mdsumner/trend.sst](https://github.com/mdsumner/trend.sst) |
| sea level anomaly | Copernicus Marine DUACS L4 | https://mdsumner.github.io/trend.sla/ | [mdsumner/trend.sla](https://github.com/mdsumner/trend.sla) |
| chlorophyll-a | ESA OC-CCI v6.0 | https://mdsumner.github.io/trend.chl/ | [mdsumner/trend.chl](https://github.com/mdsumner/trend.chl) |
| sea ice | NSIDC sea ice concentration CDR | https://mdsumner.github.io/trend.ice/ | [mdsumner/trend.ice](https://github.com/mdsumner/trend.ice) |

Engine: [hypertidy/grist](https://github.com/hypertidy/grist).

Every record's site links back here (the "trend family" pill in its
nav); a new record gets a card on `docs/index.html` and a row above.

The page is `docs/index.html`, served by GitHub Pages from `main` /
`docs`. It is a single static file with no build step.

## Working repos on Setonix

Each record's clone lives in `$MYSOFTWARE/<repo>` (persistent), its data
and job logs in `$MYSCRATCH/<repo>`: the clone's gitignored paths
(`sums/`, `mapping/`, catalogs) are symlinks to scratch, so scripts keep
their relative paths. `tools/move-to-software.sh <repo>` makes that
layout from an old scratch clone (dry run unless `--go`); then set the
scrontab entry's `--chdir` to the new clone.
