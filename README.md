# trend

Landing page for the trend family of ocean climate records: daily
satellite fields reduced to exact, mergeable statistics on S2 level-5
cells, kept current on Pawsey.

| record | sources | site | repo |
|---|---|---|---|
| sea surface temperature | NOAA OISST v2.1, GHRSST MUR | https://mdsumner.github.io/trend.sst/ | [mdsumner/trend.sst](https://github.com/mdsumner/trend.sst) |
| sea level anomaly | Copernicus Marine DUACS L4 | https://mdsumner.github.io/trend.sla/ | [mdsumner/trend.sla](https://github.com/mdsumner/trend.sla) |
| chlorophyll-a | ESA OC-CCI v6.0 | https://mdsumner.github.io/trend.chl/ | [mdsumner/trend.chl](https://github.com/mdsumner/trend.chl) |

Engine: [hypertidy/grist](https://github.com/hypertidy/grist).

The page is `docs/index.html`, served by GitHub Pages from `main` /
`docs`. It is a single static file with no build step.
