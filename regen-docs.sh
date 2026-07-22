#!/usr/bin/env bash
#
# regen-docs.sh — rebuild the example PDFs and the preview images in docs/.
#
# Run it from anywhere after changing scribe.cls, beamerthemescribe.sty, or the
# example sources:
#
#     ./regen-docs.sh
#
# It produces, from a single source each:
#   example/{onecolumn,twocolumn,twocolumnabstract,main}.pdf  +  docs/*.png
#   example-beamer/main.pdf                                   +  docs/beamer-*.png
#
# The three paper layouts all come from example/main.tex via the \scribelayout
# switch, so editing the content there updates every variant.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EX="$ROOT/example"
BEAMER="$ROOT/example-beamer"
CV="$ROOT/example-cv"
DOCS="$ROOT/docs"

PDFLATEX="pdflatex -shell-escape -interaction=nonstopmode -file-line-error"
DENSITY=150 # PNG resolution; raise for crisper (larger) previews

# ---- dependencies -----------------------------------------------------------
for cmd in pdflatex bibtex magick; do
	command -v "$cmd" >/dev/null 2>&1 || {
		echo "error: required command '$cmd' not found in PATH" >&2
		exit 1
	}
done

# ---- helpers ----------------------------------------------------------------
# Full LaTeX build (pdflatex, bibtex, pdflatex x2) for a job in the current dir.
#   $1 = jobname (and output basename)
#   $2 = TeX to run (defaults to \input{main.tex})
build() {
	local job="$1" tex="${2:-\\input{main.tex}}"
	$PDFLATEX -jobname="$job" "$tex" >/dev/null
	bibtex "$job" >/dev/null 2>&1 || true
	$PDFLATEX -jobname="$job" "$tex" >/dev/null
	$PDFLATEX -jobname="$job" "$tex" >/dev/null
}

# Remove LaTeX aux files for the given basenames in the current dir.
clean_aux() {
	local b ext
	for b in "$@"; do
		for ext in aux log out bbl blg toc nav snm vrb fls fdb_latexmk synctex.gz run.xml bcf; do
			rm -f "$b.$ext"
		done
	done
}

# PDF page -> PNG.  $1 = pdf  $2 = 0-based page  $3 = output  $4 = extra args
render() {
	magick -density "$DENSITY" "$1[$2]" -background white -alpha remove \
		-depth 8 -quality 95 ${4:-} "$3"
}

# ---- sync class/theme -------------------------------------------------------
# The example dirs keep their own copies; refresh them from the repo root so the
# previews reflect the files you actually edit.
echo ">> Syncing scribe.cls / beamerthemescribe.sty / scribecv.cls into example dirs"
cp "$ROOT/scribe.cls" "$EX/scribe.cls"
cp "$ROOT/beamerthemescribe.sty" "$BEAMER/beamerthemescribe.sty"
cp "$ROOT/scribecv.cls" "$CV/scribecv.cls"

# ---- paper examples ---------------------------------------------------------
echo ">> Building paper examples (example/)"
cd "$EX"
build main                                # default \scribelayout = twocolumnabstract
build onecolumn "\\def\\scribelayout{onecolumn}\\input{main.tex}"
build twocolumn "\\def\\scribelayout{twocolumn}\\input{main.tex}"
cp main.pdf twocolumnabstract.pdf         # identical content; keep both names

echo ">> Rendering paper previews -> docs/"
render onecolumn.pdf        0 "$DOCS/onecolumn.png"
render twocolumn.pdf        0 "$DOCS/twocolumn.png"
render twocolumnabstract.pdf 0 "$DOCS/twocolumnabstract.png"

clean_aux main onecolumn twocolumn

# ---- beamer example ---------------------------------------------------------
echo ">> Building beamer example (example-beamer/)"
cd "$BEAMER"
build main

echo ">> Rendering beamer previews -> docs/"
render main.pdf 0 "$DOCS/beamer-title.png"   '-bordercolor #dddddd -border 1'
render main.pdf 3 "$DOCS/beamer-content.png" '-bordercolor #dddddd -border 1'
render main.pdf 4 "$DOCS/beamer-blocks.png"  '-bordercolor #dddddd -border 1'

clean_aux main

# ---- CV example --------------------------------------------------------------
echo ">> Building CV example (example-cv/)"
cd "$CV"
build main

echo ">> Rendering CV preview -> docs/"
render main.pdf 0 "$DOCS/cv-preview.png"

clean_aux main

echo "Done. PDFs in example/, example-beamer/, and example-cv/, previews in docs/."
