from sage.all import *
import random


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
def fill(template, **tokens):
    """Replace @token@ markers so LaTeX braces stay literal."""
    out = template
    for key, value in tokens.items():
        out = out.replace("@%s@" % key, str(value))
    return out


def frac(num, den):
    """TeX for num/den, dropping a denominator of 1."""
    if den == "1":
        return num
    return r"\dfrac{%s}{%s}" % (num, den)


def frac_plain(num, den):
    if den == "1":
        return num
    return "%s/%s" % (num, den)


# ---------------------------------------------------------------------------
# Sides of the reference triangle, in x (adjacent), y (opposite), r terms.
# "c" is the constant a; "sum" is sqrt(u^2+a^2); "diff" is sqrt(a^2-u^2).
# ---------------------------------------------------------------------------
SIDES = {
    "arctan": {"opp": "u", "adj": "c",    "hyp": "sum"},
    "arcsin": {"opp": "u", "adj": "diff", "hyp": "c"},
    "arccos": {"opp": "diff", "adj": "u", "hyp": "c"},
}

# Which two sides each outer function reads, in order (numerator, denominator).
RATIO_SIDES = {
    "sin": ("opp", "hyp"),
    "cos": ("adj", "hyp"),
    "tan": ("opp", "adj"),
    "csc": ("hyp", "opp"),
    "sec": ("hyp", "adj"),
    "cot": ("adj", "opp"),
}


def side_tex(side, a):
    if side == "u":
        return "u"
    if side == "c":
        return str(a)
    if side == "sum":
        return r"\sqrt{u^2+%d}" % (a * a)
    return r"\sqrt{%d-u^2}" % (a * a)


def side_plain(side, a):
    if side == "u":
        return "u"
    if side == "c":
        return str(a)
    if side == "sum":
        return "sqrt(u^2+%d)" % (a * a)
    return "sqrt(%d-u^2)" % (a * a)


# ---------------------------------------------------------------------------
# The 12 variants: (outer function, inner inverse).
#
# Compositions where the two agree (sin(arcsin ...), cos(arccos ...),
# tan(arctan ...), csc(arcsin ...), sec(arccos ...), cot(arctan ...)) are
# absent: they only undo themselves, so nothing is being manipulated.
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
    "sin": r"\sin\theta=\dfrac{y}{r}",
    "cos": r"\cos\theta=\dfrac{x}{r}",
    "tan": r"\tan\theta=\dfrac{y}{x}",
    "csc": r"\csc\theta=\dfrac{r}{y}",
    "sec": r"\sec\theta=\dfrac{r}{x}",
    "cot": r"\cot\theta=\dfrac{x}{y}",
}

# How the given ratio fixes two of the three sides, and how the third follows.
PLACE = {
    "arctan": (
        r"Tangent returns opposite over adjacent, so take <m>y=u</m> and <m>x=@a@</m>; "
        r"then <m>r=\sqrt{x^2+y^2}=\sqrt{u^2+@a2@}</m>."
    ),
    "arcsin": (
        r"Sine returns opposite over hypotenuse, so take <m>y=u</m> and <m>r=@a@</m>; "
        r"then <m>x=\sqrt{r^2-y^2}=\sqrt{@a2@-u^2}</m>."
    ),
    "arccos": (
        r"Cosine returns adjacent over hypotenuse, so take <m>x=u</m> and <m>r=@a@</m>; "
        r"then <m>y=\sqrt{r^2-x^2}=\sqrt{@a2@-u^2}</m>."
    ),
}


# ===========================================================================
# VARIANT CONTROL -- the only lines you edit to pin a variant.
#
#   VARIANT_FUNCTION = None     -> random outer function (default)
#   VARIANT_FUNCTION = "sin"    -> always evaluate a sine
#       choices: sin, cos, tan, csc, sec, cot
#
#   VARIANT_INPUT = None        -> random inverse (default)
#   VARIANT_INPUT = "arctan"    -> always start from an arctangent
#       choices: arccos, arcsin, arctan
#
#   VARIANT_NOTATION = None     -> arctan / \tan^{-1} chosen per seed
#   VARIANT_NOTATION = "arccos" -> always \arctan, \arcsin, \arccos
#   VARIANT_NOTATION = "inverse"-> always \tan^{-1}, \sin^{-1}, \cos^{-1}
#
#   VARIANT_PARAM = None        -> random constant from A_POOL
#   VARIANT_PARAM = {"a": 4}    -> pin the constant, e.g. arctan(u/4)
#
# Valid (function, input) pairs, i.e. everything VARIANT_FUNCTION and
# VARIANT_INPUT can jointly select:
#   sin: arccos, arctan          csc: arccos, arctan
#   cos: arcsin, arctan          sec: arcsin, arctan
#   tan: arccos, arcsin          cot: arccos, arcsin
# ===========================================================================
VARIANT_FUNCTION = "sec"
VARIANT_INPUT    = None
VARIANT_NOTATION = None
VARIANT_PARAM    = None

# The constant a. Small values keep the radicand a^2 readable; a = 1 is
# excluded because it turns some answers into a denominator of 1.
A_POOL = [2, 3, 4, 5, 6]


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


def check_param(a):
    if not isinstance(a, int):
        raise ValueError("VARIANT_PARAM['a'] must be an integer; got %r" % (a,))
    if a < 2:
        raise ValueError(
            "VARIANT_PARAM['a'] must be at least 2; a=%r gives a degenerate "
            "argument or leaves a denominator of 1" % (a,)
        )


def pick_param():
    if VARIANT_PARAM is not None:
        if "a" not in VARIANT_PARAM:
            raise ValueError("VARIANT_PARAM must look like {'a': 4}; got %r" % (VARIANT_PARAM,))
        a = VARIANT_PARAM["a"]
        check_param(a)
        return a
    return random.choice(A_POOL)


class Generator(BaseGenerator):

    def data(self):
        fn, inner = pick_variant()
        notation = pick_notation()
        a = pick_param()

        sides = SIDES[inner]
        xt = side_tex(sides["adj"], a)
        yt = side_tex(sides["opp"], a)
        rt = side_tex(sides["hyp"], a)

        # ---- the expression as printed ------------------------------------
        arg_tex = frac("u", str(a))
        inv = INV_TEX[notation][inner]
        expr_tex = (OUTER_TEX[fn] + r"\left(" + inv + r"\left("
                    + arg_tex + r"\right)\right)")

        # ---- the answer ---------------------------------------------------
        num, den = RATIO_SIDES[fn]
        ans_tex = frac(side_tex(sides[num], a), side_tex(sides[den], a))
        ans_plain = frac_plain(side_plain(sides[num], a), side_plain(sides[den], a))

        # ---- domain: arcsin/arccos need the radicand positive -------------
        if inner == "arctan":
            domain = r"u \gt 0"
        else:
            domain = r"0 \lt u \lt %d" % a

        tok = {
            "inv": inv, "arg": arg_tex, "expr": expr_tex,
            "a": a, "a2": a * a,
            "xt": xt, "yt": yt, "rt": rt,
            "fnname": FNNAME[fn], "need": NEED[fn],
            "ans": ans_tex, "domain": domain,
        }

        # ---- 1. place theta in the reference triangle ---------------------
        paras = [fill(
            r"Let <m>\theta=@inv@\left(@arg@\right)</m>. The argument is positive, so "
            r"<m>\theta</m> is an acute angle and can be drawn in a right triangle. Call "
            r"the leg adjacent to <m>\theta</m> <m>x</m>, the leg opposite it <m>y</m>, "
            r"and the hypotenuse <m>r</m>. " + PLACE[inner],
            **tok
        )]

        # ---- 2. the definitions, stated in x, y, r ------------------------
        paras.append(fill(
            r"By the right-triangle definitions, <m>\sin\theta=\dfrac{y}{r}</m>, "
            r"<m>\cos\theta=\dfrac{x}{r}</m>, <m>\tan\theta=\dfrac{y}{x}</m>, "
            r"<m>\csc\theta=\dfrac{r}{y}</m>, <m>\sec\theta=\dfrac{r}{x}</m>, and "
            r"<m>\cot\theta=\dfrac{x}{y}</m>. This expression asks for the @fnname@ of "
            r"<m>\theta</m>, so the definition to use is <m>@need@</m>.",
            **tok
        ))

        # ---- 3. substitute ------------------------------------------------
        paras.append(fill(
            r"With <m>x=@xt@</m>, <m>y=@yt@</m>, and <m>r=@rt@</m>, "
            r"<m>@need@=@ans@</m>.",
            **tok
        ))

        # ---- 4. conclude --------------------------------------------------
        paras.append(fill(
            r"Therefore <m>@expr@=\boxed{@ans@}</m>.", **tok
        ))

        solution_steps = "\n".join("    <p>" + p + "</p>" for p in paras)

        return {
            "expr_tex": expr_tex,
            "domain": domain,
            "solution_steps": solution_steps,
            "function": fn,
            "input": inner,
            "notation": notation,
            "a": a,
            "answer": ans_plain,
            "answer_tex": ans_tex,
        }
