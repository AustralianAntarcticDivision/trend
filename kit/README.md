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
    tmerc: { frame: "both", radius: 50 },   // south | north | both polar caps
    coast: true                        // coastline on at load
  }
};
```

Views: `world` (Equal Earth, the family default), `tmerc` (transverse
Mercator on the central meridian, as `+proj=tmerc +lon_0=...`; the polar
default), `ortho` (globe), `longlat`, `spilhaus` (needs `sring` in the
export), `faces` (S2 cube net). All views share the central meridian.
The tmerc view is framed on the polar cap(s) of `tmerc.frame`: both
poles lie on the central meridian, so one transverse Mercator holds both
caps (`"both"`: Antarctic below, Arctic above on `lon_0=115`).

A page is a thin HTML file: kit CSS, `kit/records.js`, `site.js`, the
header placeholder `<header class="trend"></header><script
src="kit/shell.js"></script>`, its own prose, and the module script.
Record-specific pages (trend.sst Heatwaves, trend.ice's analysis pages)
use the kit header and CSS and keep their own content and scripts.

## Data contract

A record's site **sources** (what the explorer and status series show)
are usually one-to-one with its **stores** (`sums/<store>/` in the
bucket). A source may be made of several stores with disjoint cells:
trend.ice's CDR is one bipolar source from a south and a north store,
declared in `records.js` as `stores: { "cdr-sic": "s", "cdr-sic-north":
"n" }` so the explorer's code reads only the stores that hold the
selected cells. `status.json` is per store (each may carry a `label`),
`series.json` per source, and a source lists only the regions it has.

Written by each record's exporter into the site's `data/`:

- `cells-<source>.json`: `{ months, regions: { key: { label, cells } },
  cells: [{ id, ring, mean, trend, anom, w, lon, lat, sring? }] }`
- `monthly-<source>.bin`: Float32 cells x months, cell-major
- `weights-<source>.bin` (optional): Float32 cells x months of cell
  weights, same layout, named by the cells JSON `"weights"` field
- `status.json`, `series.json`: store state and daily regional series
- `coast-110m.json`: coastline mesh

`w` is the weight of a cell in a union: its mean `sumw` per time step
with data, i.e. the ocean area it covers in the record's weight units
(km2 for sea ice, cos-latitude pixel weights for the others). The
explorer's selection series is `sum(w * mean) / sum(w)` over the cells
with a value that month. That equals the union of the sums wherever a
cell's coverage is steady from step to step (SST, SLA and sea ice).
Where coverage varies (cloud, ice and polar night in chlorophyll) the
exporter also writes the monthly weights: the cell's `sumw` in each
month over the number of time steps in that month, in `w`'s units, 0
where there is no data. The explorer then uses them in place of `w`,
and every month of a selection is exactly the union of the sums. Within
a record only ratios of the weights matter; for sea ice `sum(w * mean)`
is itself sea ice area. A site lists the weights file in `extraFiles`
so the Mechanics page shows it.

## Adding a record

Add its entry to `records.js` (units, metric scales, sources, bucket,
code text, status rules), make its `site.js`, sync the kit, and give it a
card on `docs/index.html`. Any explorer can then list it under `family`.
