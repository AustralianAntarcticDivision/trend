# kit: the shared look of the trend.* sites

Every trend.* site opens on the same S2 cell explorer and shares one
header, tab strip and set of page modules. This directory is the
canonical copy. Sites serve a vendored copy (same-origin, no runtime
dependency on this repo), written by

    tools/kit-sync ../trend.sst ../trend.sla ../trend.chl ../trend.ice
    tools/kit-sync --check ../trend.*      # drift report, writes nothing

then committed in each site. `kit/VERSION` in a site records the hub
commit its copy came from.

## Files

| file | what |
|---|---|
| `trend.css` | tokens (light/dark), header and tabs, common components, layouts `app`, `prose`, `ledger` |
| `shell.js` | writes the record name and tabs into `<header class="trend">` from the site config |
| `records.js` | the family registry: per record its site, bucket, units, metric scales, sources, combos, code-generator text, status rules |
| `explorer.js`, `explorer.css` | the S2 cell explorer (landing page, `index.html`) |
| `status.js` | store status: freshness tiles, coverage, sanity series (`status.html`) |
| `modes.js`, `modes.css` | EOF modes of the monthly export (`modes.html`; prose and a JSON config stay in the page) |
| `mechanics.js`, `mechanics.css` | the pipeline ledger, bucket manifest vs site data (`mechanics.html`) |
| `quarto.css` | Quarto pages in the family look (`theme: none`, `minimal: true`; trend.ice) |

## A site

A site directory (`docs/`, or `site/` for a Quarto project) holds
`site.js`, the pages, `data/` and `kit/`:

```js
window.TREND_SITE = {
  record: "ice",                       // key into records.js
  title: "trend.ice",
  repo: "https://github.com/mdsumner/trend.ice",
  tabs: [["index.html", "Explorer"], ["status.html", "Status"], ...],
  links: [{ href, label, title }],     // extra pills after "trend family"
  dataHint: "Run pawsey/export_site.R and commit site/data/.",
  explorer: {
    sources: ["cdr-sic", "asi-sic"],   // this record's sources and combos
    family: ["sst:oisst", "chl:occci-log10chl"],   // other records, read from their sites
    view: "tmerc",                     // default view (all views are in the menu)
    rotate: [-115, 70],                // central meridian 115E; globe centred 115E 70S
    tmerc: { lat: -90, radius: 50 },   // cap the transverse Mercator frames
    coast: true                        // coastline on at load
  }
};
```

Views: `world` (Equal Earth, the family default), `tmerc` (transverse
Mercator on the central meridian, as `+proj=tmerc +lon_0=...`; the polar
default), `ortho` (globe), `longlat`, `spilhaus` (needs `sring` in the
export), `faces` (S2 cube net). All views share the central meridian.

A page is a thin HTML file: kit CSS, `kit/records.js`, `site.js`, the
header placeholder `<header class="trend"></header><script
src="kit/shell.js"></script>`, its own prose, and the module script.
Record-specific pages (trend.sst Heatwaves, trend.ice's analysis pages)
use the kit header and CSS and keep their own content and scripts.

## Data contract

Written by each record's exporter into the site's `data/`:

- `cells-<source>.json`: `{ months, regions: { key: { label, cells } },
  cells: [{ id, ring, mean, trend, anom, w, lon, lat, sring? }] }`
- `monthly-<source>.bin`: Float32 cells x months, cell-major
- `status.json`, `series.json`: store state and daily regional series
- `coast-110m.json`: coastline mesh

`w` is the weight of a cell in a union. The exact weight is the cell's
mean daily `sumw` (its ocean area for sea ice); the sst, sla and chl
exporters write `sumw / n`, the mean per-pixel weight, which treats a
coastal cell as if it were full.

## Adding a record

Add its entry to `records.js` (units, metric scales, sources, bucket,
code text, status rules), make its `site.js`, sync the kit, and give it a
card on `docs/index.html`. Any explorer can then list it under `family`.
