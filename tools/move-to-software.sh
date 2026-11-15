#!/bin/bash
## Move a trend.* working repo from $MYSCRATCH to $MYSOFTWARE, leaving its
## data where it is. Code lives in $MYSOFTWARE/<repo> (persistent); data
## stays in $MYSCRATCH/<repo> (sums, mapping, catalogs, logs). The new
## clone gets a symlink for every gitignored entry of the old one, so the
## scripts' relative paths (sums/, mapping/, *.parquet, ...) still work.
##
##   bash move-to-software.sh trend.sst            # dry run: prints the plan
##   bash move-to-software.sh trend.sst --go       # does it
##
## Then point the scrontab entry's --chdir at $MYSOFTWARE/<repo> (scrontab -e).
## Nothing on scratch is deleted or moved; the old checkout stays as a
## fallback (retire its .git later, once the new home has run cleanly).
set -euo pipefail
repo=${1:?usage: move-to-software.sh <repo> [--go]}
go=${2:-}
old=$MYSCRATCH/$repo
new=$MYSOFTWARE/$repo
run() { echo "+ $*"; if [ "$go" = "--go" ]; then "$@"; fi; }

[ -d "$old/.git" ] || { echo "no git clone at $old" >&2; exit 1; }
[ -e "$new" ] && { echo "$new already exists; not touching it" >&2; exit 1; }

cd "$old"
branch=$(git branch --show-current)
[ "$branch" = main ] || { echo "$old is on '$branch', not main" >&2; exit 1; }
url=$(git remote get-url origin)

## 1. flush the old clone: local commits (e.g. unpushed site data) go to
##    GitHub first, so the new clone starts with everything
echo "== $repo: $old -> $new (origin $url)"
git fetch -q origin
ahead=$(git rev-list --count origin/main..main)
echo "local commits not on origin: $ahead"
if [ "$ahead" -gt 0 ]; then
  run git pull -q --rebase --autostash origin main
  run git push -q origin main
fi

## 2. what stays on scratch: every ignored entry (top-most ignored path),
##    except logs, which keep going to scratch via scrontab --output
mapfile -t ignored < <(git ls-files --others --ignored --exclude-standard --directory \
  | sed 's#/$##' | grep -v -E '\.(out|log)$' || true)
mapfile -t untracked < <(git ls-files --others --exclude-standard || true)

## 3. clone and link
run git clone -q "$url" "$new"
for p in "${ignored[@]}"; do
  [ -n "$p" ] || continue
  run mkdir -p "$new/$(dirname "$p")"
  run ln -s "$old/$p" "$new/$p"
done

if [ "${#untracked[@]}" -gt 0 ] && [ -n "${untracked[0]}" ]; then
  echo "NOTE untracked, not ignored, left in $old (not linked):"
  printf '  %s\n' "${untracked[@]}"
fi
echo "== next: scrontab -e, set --chdir=$new for $repo's entry"
[ "$go" = "--go" ] || echo "(dry run; add --go to do it)"
