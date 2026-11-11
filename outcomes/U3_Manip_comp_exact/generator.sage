from sage.all import *
import random
import math


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
def fill(template, **tokens):
    """Replace @token@ markers so LaTeX braces stay literal."""
    out = template
    for key, value in tokens.items():
        out = out.replace("@%s@" % key, str(value))
    return out


def frac(n, d):
    """TeX for n/d, dropping a denominator of 1. Both args are TeX strings."""
    if d == "1":
        return n
    return r"\frac{%s}{%s}" % (n, d)


def sqrt_split(n):
    """Write n = c^2 * d with d squarefree; return (c, d)."""
    c, d, p = 1, 1, 2
    q = n
    while p * p <= q:
        e = 0
        while q % p == 0:
            q //= p
            e += 1
        if e:
            c *= p ** (e // 2)
            if e % 2:
                d *= p
        p += 1
    return c, d * q


class Rad(object):
    """Exact value a*sqrt(d)/b, kept in lowest terms with d squarefree.
    d == 1 means the value is rational."""

    def __init__(self, a, d=1, b=1):
        c, e = sqrt_split(d)
        a, d = a * c, e
        if a == 0:
            d, b = 1, 1
        g = math.gcd(abs(a), b) if a else b
        a //= g
        b //= g
        if b < 0:
            a, b = -a, -b
        self.a, self.d, self.b = a, d, b

    def scaled(self, n):
        """self * n, for integer n."""
        return Rad(self.a * n, self.d, self.b)

    def over(self, n):
        """self / n, for integer n."""
        return Rad(self.a, self.d, self.b * n)

    def inverse(self):
        """1 / self, with the radical rationalized into the numerator."""
        return Rad(self.b, self.d, self.a * self.d)

    def tex(self):
        a, d, b = self.a, self.d, self.b
        if d == 1:
            return str(a) if b == 1 else r"\frac{%d}{%d}" % (a, b)
        num = (r"%d\sqrt{%d}" % (a, d)) if a != 1 else (r"\sqrt{%d}" % d)
        return num if b == 1 else r"\frac{%s}{%d}" % (num, b)

    def plain(self):
        a, d, b = self.a, self.d, self.b
        if d == 1:
            return str(a) if b == 1 else "%d/%d" % (a, b)
        num = "sqrt(%d)" % d if a == 1 else "%d*sqrt(%d)" % (a, d)
        return num if b == 1 else "%s/%d" % (num, b)

    def __repr__(self):
        return "Rad(%d,%d,%d)" % (self.a, self.d, self.b)


# ---------------------------------------------------------------------------
# Triangle pool.  x = leg adjacent to theta, r = hypotenuse, and
# y = sqrt(r^2 - x^2) is the opposite leg.  Every pair is in lowest terms and
# chosen so the answer stays small and exact: either a Pythagorean triple or a
# radicand that simplifies to a single squarefree root.
# ---------------------------------------------------------------------------
TRIANGLES = [
    (1, 2), (1, 3), (2, 3), (3, 4), (1, 4), (2, 5), (5, 6),      # y irrational
    (3, 5), (4, 5), (5, 13), (12, 13), (8, 17), (15, 17),        # y integer
]


# ---------------------------------------------------------------------------
# The 12 variants: (outer function, inner inverse).
#
# The outer function fixes the answer; the inner function fixes how the
# triangle is presented.  Compositions where the two match (sin(arcsin ...))
# are deliberately absent -- they are not "manipulating" anything.
# ---------------------------------------------------------------------------
VARIANTS = [
    ("sin", "arccos"), ("sin", "arctan"),
    ("cos", "arcsin"), ("cos", "arctan"),
    ("tan", "arccos"), ("tan", "arcsin"),
    ("csc", "arccos"), ("csc", "arctan"),
    ("sec", "arcsin"), ("sec", "arctan"),
    ("cot", "arccos"), ("cot", "arcsin"),
]

OUTER_TEX = {"sin": r"\sin", "cos": r"\cos", "tan": r"\tan",
             "csc": r"\csc", "sec": r"\sec", "cot": r"\cot"}

INV_TEX = {
    "arccos":  {"arccos": r"\arccos", "arcsin": r"\arcsin", "arctan": r"\arctan"},
    "inverse": {"arccos": r"\cos^{-1}", "arcsin": r"\sin^{-1}", "arctan": r"\tan^{-1}"},
}

FNNAME = {"sin": "sine", "cos": "cosine", "tan": "tangent",
          "csc": "cosecant", "sec": "secant", "cot": "cotangent"}

NEED = {
    "sin": r"\sin\theta=\frac{y}{r}",
    "cos": r"\cos\theta=\frac{x}{r}",
    "tan": r"\tan\theta=\frac{y}{x}",
    "csc": r"\csc\theta=\frac{r}{y}",
    "sec": r"\sec\theta=\frac{r}{x}",
    "cot": r"\cot\theta=\frac{x}{y}",
}

RAW_TEX = {
    "sin": lambda t: frac(t["y"].tex(), str(t["r"])),
    "cos": lambda t: frac(str(t["x"]), str(t["r"])),
    "tan": lambda t: frac(t["y"].tex(), str(t["x"])),
    "csc": lambda t: frac(str(t["r"]), t["y"].tex()),
    "sec": lambda t: frac(str(t["r"]), str(t["x"])),
    "cot": lambda t: frac(str(t["x"]), t["y"].tex()),
}


def value_of(fn, t):
    """Exact value of the outer function at theta, as a Rad."""
    x, y, r = t["x"], t["y"], t["r"]
    if fn == "sin":
        return y.over(r)
    if fn == "cos":
        return Rad(x, 1, r)
    if fn == "tan":
        return y.over(x)
    if fn == "csc":
        return y.inverse().scaled(r)
    if fn == "sec":
        return Rad(r, 1, x)
    return y.inverse().scaled(x)          # cot


# ===========================================================================
# VARIANT CONTROL -- the only lines you edit to pin a variant.
#
#   VARIANT_FUNCTION = None     -> random outer function (default)
#   VARIANT_FUNCTION = "tan"    -> always evaluate a tangent
#       choices: sin, cos, tan, csc, sec, cot
#
#   VARIANT_INPUT = None        -> random inverse, subject to availability
#   VARIANT_INPUT = "arccos"    -> always start from an arccos
#       choices: arccos, arcsin, arctan
#
#   VARIANT_NOTATION = None     -> arccos / \cos^{-1} chosen per seed
#   VARIANT_NOTATION = "arccos" -> always \arccos
#   VARIANT_NOTATION = "inverse"-> always \cos^{-1}
#
#   VARIANT_ANGLE = None        -> random triangle from TRIANGLES
#   VARIANT_ANGLE = {"x": 1, "r": 3}   -> pin adjacent 1, hypotenuse 3
#
# Valid (function, input) pairs, i.e. everything VARIANT_FUNCTION and
# VARIANT_INPUT can jointly select:
#   sin: arccos, arctan          csc: arccos, arctan
#   cos: arcsin, arctan          sec: arcsin, arctan
#   tan: arccos, arcsin          cot: arccos, arcsin
# ===========================================================================
VARIANT_FUNCTION = None
VARIANT_INPUT    = None
VARIANT_NOTATION = None
VARIANT_ANGLE    = None


def is_triple(x, r):
    c, d = sqrt_split(r * r - x * x)
    return d == 1


def check_angle(x, r, inner):
    """Fail loudly rather than emit an unusable argument."""
    if not (isinstance(x, int) and isinstance(r, int)):
        raise ValueError("VARIANT_ANGLE needs integer x and r; got %r" % (VARIANT_ANGLE,))
    if not (0 < x < r):
        raise ValueError("VARIANT_ANGLE needs 0 < x < r; got x=%r r=%r" % (x, r))
    if math.gcd(x, r) != 1:
        raise ValueError("VARIANT_ANGLE needs x/r in lowest terms; got %d/%d" % (x, r))
    if inner != "arccos" and not is_triple(x, r):
        raise ValueError(
            "x/r = %d/%d leaves an irrational opposite leg, so only an arccosine "
            "input reads cleanly; %r needs a Pythagorean pair" % (x, r, inner)
        )


def angle(x, r):
    c, d = sqrt_split(r * r - x * x)
    return {"x": x, "r": r, "y": Rad(c, d, 1)}


def pick_variant():
    cands = [(f, i) for (f, i) in VARIANTS
             if VARIANT_FUNCTION in (None, f) and VARIANT_INPUT in (None, i)]
    if not cands:
        raise ValueError(
            "no variant has function=%r and input=%r; valid pairs are %s"
            % (VARIANT_FUNCTION, VARIANT_INPUT, VARIANTS)
        )
    return random.choice(cands)


def pick_notation():
    if VARIANT_NOTATION is None:
        return random.choice(["arccos", "inverse"])
    if VARIANT_NOTATION not in INV_TEX:
        raise ValueError(
            "VARIANT_NOTATION must be None, 'arccos', or 'inverse'; got %r"
            % (VARIANT_NOTATION,)
        )
    return VARIANT_NOTATION


def pick_angle(inner):
    if VARIANT_ANGLE is not None:
        x, r = VARIANT_ANGLE["x"], VARIANT_ANGLE["r"]
        check_angle(x, r, inner)
        return angle(x, r)
    pool = [(x, r) for (x, r) in TRIANGLES if inner == "arccos" or is_triple(x, r)]
    return angle(*random.choice(pool))


class Generator(BaseGenerator):

    def data(self):
        fn, inner = pick_variant()
        notation = pick_notation()
        t = pick_angle(inner)

        x, r, y = t["x"], t["r"], t["y"]
        yt = y.tex()
        yi = y.a if y.d == 1 else None

        # ---- the expression as printed ------------------------------------
        arg_tex = {"arccos": Rad(x, 1, r),
                   "arcsin": y.over(r),
                   "arctan": y.over(x)}[inner].tex()
        inv = INV_TEX[notation][inner]
        expr_tex = (OUTER_TEX[fn] + r"\left(" + inv + r"\left("
                    + arg_tex + r"\right)\right)")

        # ---- the answer ---------------------------------------------------
        val = value_of(fn, t)
        final = val.tex()
        raw = RAW_TEX[fn](t)
        chain = raw if raw == final else raw + "=" + final

        # ---- the triangle that produces the argument ----------------------
        if inner == "arccos":
            n = r * r - x * x
            setup = (
                r"Let <m>\theta=@inv@\left(@arg@\right)</m>. The argument <m>@arg@</m> is "
                r"positive, so <m>\theta</m> is an acute angle and can be placed in a right "
                r"triangle. Call the leg adjacent to <m>\theta</m> <m>x</m>, the leg "
                r"opposite it <m>y</m>, and the hypotenuse <m>r</m>. Arccosine returns "
                r"adjacent over hypotenuse, so take <m>x=@x@</m> and <m>r=@r@</m>; then "
                r"<m>y=\sqrt{r^2-x^2}=\sqrt{@r2@-@x2@}=\sqrt{@n@}=@yt@</m>."
            )
        elif inner == "arcsin":
            n = r * r - yi * yi
            setup = (
                r"Let <m>\theta=@inv@\left(@arg@\right)</m>. The argument <m>@arg@</m> is "
                r"positive, so <m>\theta</m> is an acute angle and can be placed in a right "
                r"triangle. Call the leg adjacent to <m>\theta</m> <m>x</m>, the leg "
                r"opposite it <m>y</m>, and the hypotenuse <m>r</m>. Arcsine returns "
                r"opposite over hypotenuse, so take <m>y=@yt@</m> and <m>r=@r@</m>; then "
                r"<m>x=\sqrt{r^2-y^2}=\sqrt{@r2@-@y2@}=\sqrt{@n@}=@x@</m>."
            )
        else:
            n = x * x + yi * yi
            setup = (
                r"Let <m>\theta=@inv@\left(@arg@\right)</m>. The argument <m>@arg@</m> is "
                r"positive, so <m>\theta</m> is an acute angle and can be placed in a right "
                r"triangle. Call the leg adjacent to <m>\theta</m> <m>x</m>, the leg "
                r"opposite it <m>y</m>, and the hypotenuse <m>r</m>. Arctangent returns "
                r"opposite over adjacent, so take <m>y=@yt@</m> and <m>x=@x@</m>; then "
                r"<m>r=\sqrt{x^2+y^2}=\sqrt{@x2@+@y2@}=\sqrt{@n@}=@r@</m>."
            )

        tok = {
            "inv": inv, "arg": arg_tex, "expr": expr_tex,
            "x": x, "r": r, "yt": yt,
            "x2": x * x, "r2": r * r,
            "y2": (yi * yi) if yi is not None else 0,
            "n": n,
            "fnname": FNNAME[fn], "need": NEED[fn],
            "raw": raw, "final": final, "chain": chain,
            "d": str(y.d),
        }

        paras = [fill(setup, **tok)]

        # ---- the definitions, stated in x, y, r ---------------------------
        paras.append(fill(
            r"By the right-triangle definitions, <m>\sin\theta=\frac{y}{r}</m>, "
            r"<m>\cos\theta=\frac{x}{r}</m>, <m>\tan\theta=\frac{y}{x}</m>, "
            r"<m>\csc\theta=\frac{r}{y}</m>, <m>\sec\theta=\frac{r}{x}</m>, and "
            r"<m>\cot\theta=\frac{x}{y}</m>. This expression asks for the @fnname@ of "
            r"<m>\theta</m>, so the definition to use is <m>@need@</m>.",
            **tok
        ))

        # ---- substitute ---------------------------------------------------
        sub = (r"With <m>x=@x@</m>, <m>y=@yt@</m>, and <m>r=@r@</m>, "
               r"<m>@need@=@chain@</m>.")
        if raw != final and fn in ("csc", "cot"):
            sub += (r" The last step multiplies numerator and denominator by "
                    r"<m>\sqrt{@d@}</m> to rationalize the denominator.")
        paras.append(fill(sub, **tok))

        # ---- conclude -----------------------------------------------------
        paras.append(fill(
            r"Therefore <m>@expr@=\boxed{@final@}</m>.", **tok
        ))

        solution_steps = "\n".join("    <p>" + p + "</p>" for p in paras)

        return {
            "expr_tex": expr_tex,
            "solution_steps": solution_steps,
            "function": fn,
            "input": inner,
            "notation": notation,
            "answer": val.plain(),
            "answer_tex": final,
        }
