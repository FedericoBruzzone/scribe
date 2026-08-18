"""scribe's matplotlib theme: the same MidnightBlue accent + HSL complement
palette as ~/dev/scribe's LaTeX class, rounded-top bars, and shared rcParams
loading. Lives verbatim (this file + scribe-theme.mplstyle) in both this
project and scribe itself -- the canonical copy is scribe's, this one is a
copy kept in sync by hand until scribe grows a package manager worth using.

This module knows nothing about any specific paper's entities (no "baseline
vs. our approach", no "estimate vs. measured") and nothing about any
project's directory layout -- that's deliberate. To reuse this theme in a
new paper: copy this file + scribe-theme.mplstyle (same directory) verbatim,
then write a small per-paper module (this project's plotstyle.py is the
example) that imports the palette below and assigns YOUR entities to it,
plus whatever I/O glue your project needs. Never re-add project-specific
names here -- that's exactly the coupling this split exists to prevent.

Filename is scribe_mpl.py (underscore), not scribe-mpl.py: Python's `import`
statement requires a valid identifier, and hyphens aren't legal there --
only the .mplstyle sidecar (loaded by path string, never imported) can use
a hyphen freely.

No dual y-axis, ever, in any figure that uses this module.
"""
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import PathPatch
from matplotlib.path import Path

__all__ = [
    "STYLE_PATH",
    "MIDNIGHT", "MIDNIGHT_EDGE", "TINT", "TINT_EDGE",
    "COMPLEMENT", "COMPLEMENT_EDGE",
    "GRAY_DARK", "GRAY_DARK_EDGE", "GRAY_MID", "GRAY_MID_EDGE",
    "GRAY_LIGHT", "GRAY_LIGHT_EDGE",
    "SURFACE", "INK_PRIMARY", "INK_SECONDARY", "INK_MUTED",
    "GRIDLINE", "AXIS", "BAR_WIDTH_FRAC",
    "tint", "setup", "style_axes", "rounded_bars", "label_bars",
]

STYLE_PATH = os.path.join(os.path.dirname(__file__), "scribe-theme.mplstyle")

# --- Base palette: a single diverging family (MidnightBlue <-> its HSL
# complement), not an arbitrary multi-hue rainbow. Every fill has a matching
# darker-shade edge color (same hue, ~13% less lightness) so bars read as
# filled+outlined shapes, not flat color blocks -- see rounded_bars() below.
#
# MIDNIGHT is literally scribe's own accent (~/dev/scribe's MidnightBlue,
# xcolor dvipsnames CMYK(0.98,0.13,0,0.43) -> RGB(0,112,145) -- verified via
# \convertcolorspec, not hand-computed, since xcolor's CMYK->RGB is the
# additive/clipped model (R=1-min(1,C+K)), not naive multiplication). Its
# HSL complement (same lightness/saturation, hue+180) is COMPLEMENT below.
MIDNIGHT = "#007091"
MIDNIGHT_EDGE = "#003c4e"
TINT = "#1293b9"          # a lighter, less-saturated point on MIDNIGHT's side
TINT_EDGE = "#0c627c"
COMPLEMENT = "#912100"    # MIDNIGHT's HSL complement -- the diverging family's other pole
COMPLEMENT_EDGE = "#4e1100"
GRAY_DARK = "#727272"     # neutral (non-diverging) fills for "other/external" entities
GRAY_DARK_EDGE = "#515151"
GRAY_MID = "#999999"
GRAY_MID_EDGE = "#777777"
GRAY_LIGHT = "#bfbfbf"
GRAY_LIGHT_EDGE = "#9e9e9e"

SURFACE = "#ffffff"  # pure white -- matches a paper's white page, not warm-white
INK_PRIMARY = "#0b0b0b"
INK_SECONDARY = "#52514e"
INK_MUTED = "#898781"
GRIDLINE = "#e1e0d9"
AXIS = "#c3c2b7"

BAR_WIDTH_FRAC = 0.6  # of the category slot -- leaves visible air between groups, per marks-and-anatomy.md


def tint(hex_color, pct):
    """Blend hex_color with white, TikZ `color!pct` style: pct=100 returns
    hex_color unchanged, pct=0 returns white, pct=45 is 45% hex_color + 55%
    white. Used to derive a bar chart's lighter fill from the same full-
    saturation hex Fig. 1/2's TikZ uses for `draw=`, so bars read as
    filled+outlined shapes in the same family as those diagrams' boxes
    (`draw=cdqblue, fill=cdqblue!10`) rather than flat, fully-saturated
    blocks -- just at a less extreme percentage than the diagrams' 10%,
    since a data bar's fill (unlike a label-carrying box) needs enough
    contrast against the page to stay legible on its own.
    """
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    frac = pct / 100.0
    r = round(r * frac + 255 * (1 - frac))
    g = round(g * frac + 255 * (1 - frac))
    b = round(b * frac + 255 * (1 - frac))
    return f"#{r:02x}{g:02x}{b:02x}"


def setup():
    """Call once at the top of every figure script before creating any Axes.

    Loads scribe-theme.mplstyle rather than building rcParams inline. Font
    fallback (STIXGeneral -> Charter -> Times New Roman -> DejaVu Serif) is
    handled by matplotlib itself via the style file's font.serif list, not
    hand-rolled here.
    """
    plt.style.use(STYLE_PATH)
    plt.rcParams["font.size"] = 9  # ACM sigconf two-column: legible at ~3.3in width


def style_axes(ax, *, y_only_grid=True):
    """Per-axis grid selection (y-only vs x-only): the one piece of the
    recessive-axes look that isn't expressible as a static rcParam in
    scribe-theme.mplstyle (spine visibility/color already come from the style)."""
    if y_only_grid:
        ax.grid(axis="y")
        ax.grid(axis="x", visible=False)


def rounded_bars(ax, bars, edgecolors, *, hatches=None, radius_pt=11, linewidth=1.5, n_arc=12):
    """Replace each Rectangle patch ax.bar() created with a rounded-top,
    flat-bottom shape (the "4px rounded data-ends anchored to the baseline"
    mark spec) plus a matching darker-shade edge, so bars read as
    filled+outlined shapes instead of flat color blocks.

    edgecolors: a single color (applied to every bar) or a list, one per bar.
    hatches: optional -- a single hatch pattern string (applied to every
    bar), a list (one per bar), or None (no hatch). Matplotlib draws the
    hatch in the patch's edgecolor, so a bar's texture and its color both
    encode which series it belongs to -- color alone isn't load-bearing for
    distinguishing series (colorblind-safe, and survives grayscale print).
    radius_pt is in points -- call this AFTER setting final xlim/ylim, not
    before.

    The two top corners are built as TRUE circular arcs in display
    (pixel/point) space, then mapped back to data coordinates -- not via
    FancyBboxPatch's `rounding_size` (tried first, reverted): that parameter
    is a single scalar applied identically in x *and* y **data** units, but
    a bar chart's x/y axes almost never share the same data-per-point ratio
    (a handful of category slots across the plot width vs. a value range of
    dozens-to-hundreds across the same physical height). The same
    data-unit radius therefore renders as a squashed, sometimes
    self-intersecting arc -- a visible pinch/notch right at the top-center
    apex, worst on narrow/tall bars. Building the arc in display space first
    sidesteps the anisotropy entirely: a circle in pixel space is still a
    circle after inverse-transforming its points back to (possibly
    anisotropic) data space, because each point is mapped individually
    rather than the radius being reinterpreted as a single data-unit scalar.

    The rounding radius is achieved by extending the path `radius_pt` below
    each bar's actual baseline and letting the axes clip the (rounded)
    bottom edge at y=0/ylim -- so the visible bottom stays flat while only
    the top corners show the rounding.

    Returns the new PathPatch list (same order as `bars`), so callers that
    need further per-bar customization (e.g. a hatch on one bar) can apply
    it after this call instead of on the now-hidden original bars.
    """
    if isinstance(edgecolors, str):
        edgecolors = [edgecolors] * len(bars)
    if hatches is None or isinstance(hatches, str):
        hatches = [hatches] * len(bars)
    fig = ax.figure
    t2d = ax.transData.transform
    d2t = ax.transData.inverted().transform
    px_per_pt = fig.dpi / 72.0
    patches = []
    for bar, ec, hatch in zip(bars, edgecolors, hatches):
        x, y = bar.get_x(), bar.get_y()
        w, h = bar.get_width(), bar.get_height()
        fc = bar.get_facecolor()
        bar.set_visible(False)

        x0_d, y0_d = t2d((x, y))
        x1_d, _ = t2d((x + w, y))
        _, y_top_d = t2d((x, y + h))
        w_px = abs(x1_d - x0_d)
        h_px = abs(y_top_d - y0_d)
        w_pt, h_pt = w_px / px_per_pt, h_px / px_per_pt

        # Cap in points against the bar's own on-page size: the full
        # radius_pt if it fits, else shrink -- but always leave an
        # ABSOLUTE minimum 2.5pt flat segment at the top center (not just a
        # percentage of the width), so the two corner arcs never get close
        # enough to touch/overlap regardless of how narrow the bar is.
        r_pt = min(radius_pt, max(0.0, (w_pt - 2.5) / 2.0), h_pt * 0.9)
        r_px = r_pt * px_per_pt

        if os.environ.get("PLOTSTYLE_DEBUG_ROUNDING"):
            print(f"  [rounding] h={h:.4g} w={w:.4g} req_pt={radius_pt} "
                  f"w_pt={w_pt:.2f} h_pt={h_pt:.2f} effective_pt={r_pt:.2f}", file=sys.stderr)

        y_bot_d = y0_d - r_px  # extend below the baseline; axes clip hides it
        verts_disp = [(x0_d, y_bot_d), (x1_d, y_bot_d), (x1_d, y_top_d - r_px)]
        # top-right quarter circle: center inset (r_px, r_px) from (x1_d, y_top_d)
        cx, cy = x1_d - r_px, y_top_d - r_px
        verts_disp += [(cx + r_px * np.cos(a), cy + r_px * np.sin(a))
                        for a in np.linspace(0.0, np.pi / 2, n_arc)]
        verts_disp.append((x0_d + r_px, y_top_d))
        # top-left quarter circle: center inset (r_px, r_px) from (x0_d, y_top_d)
        cx, cy = x0_d + r_px, y_top_d - r_px
        verts_disp += [(cx + r_px * np.cos(a), cy + r_px * np.sin(a))
                        for a in np.linspace(np.pi / 2, np.pi, n_arc)]
        verts_disp.append((x0_d, y_bot_d))

        verts = [d2t(v) for v in verts_disp]
        codes = [Path.MOVETO] + [Path.LINETO] * (len(verts) - 2) + [Path.CLOSEPOLY]
        patch = PathPatch(
            Path(verts, codes), transform=ax.transData,
            linewidth=linewidth, facecolor=fc, edgecolor=ec, joinstyle="round",
            hatch=hatch,
        )
        ax.add_patch(patch)
        patches.append(patch)
    return patches


def label_bars(ax, bars, values, fmt="{:.2f}", *, color=INK_PRIMARY, fontsize=8, offset_frac=0.02):
    """Direct value labels at each bar's tip. Never colors the label with the
    series color (marks-and-anatomy.md: "text never wears the data color")."""
    ymax = ax.get_ylim()[1]
    offset = ymax * offset_frac
    for bar, v in zip(bars, values):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + offset,
            fmt.format(v),
            ha="center", va="bottom",
            color=color, fontsize=fontsize,
        )
