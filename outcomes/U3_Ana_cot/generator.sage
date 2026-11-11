from sage.all import *
import math
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


# --- multiples of pi, as plain (numerator, denominator) int pairs ----------
# Deliberately NOT fractions.Fraction: under `from sage.all import *`, Sage
# Integers can slip into the arithmetic, and Fraction's fast path chokes on
# them because Sage elements expose .numerator() as a method, not a property.
def rat(n, d=1):
    """Reduce n/d to lowest terms with the sign carried on the numerator."""
    n, d = int(n), int(d)
    if d == 0:
        raise ZeroDivisionError("denominator of zero in rat()")
    if d < 0:
        n, d = -n, -d
    g = math.gcd(abs(n), d)
    return (n // g, d // g)


ZERO = (0, 1)


def is_zero(nd):
    return nd[0] == 0


def pi_tex(nd):
    """TeX for c*pi, where c = nd[0]/nd[1]."""
    n, d = nd
    if n == 0:
        return "0"
    sign = "-" if n < 0 else ""
    n = abs(n)
    num = r"\pi" if n == 1 else r"%d\pi" % n
    if d == 1:
        return sign + num
    return sign + r"\frac{%s}{%d}" % (num, d)


def pi_plain(nd):
    """ASCII version, for the answer field."""
    n, d = nd
    if n == 0:
        return "0"
    sign = "-" if n < 0 else ""
    n = abs(n)
    if d == 1:
        return sign + ("pi" if n == 1 else "%dpi" % n)
    return sign + ("pi/%d" % d if n == 1 else "%dpi/%d" % (n, d))


# ---------------------------------------------------------------------------
# Function tables
# ---------------------------------------------------------------------------
FUNCS = ["sin", "cos", "tan", "csc", "sec", "cot"]
MAIN = ["sin", "cos", "tan"]
RECIP = ["csc", "sec", "cot"]

FUNC_TEX = {"sin": r"\sin", "cos": r"\cos", "tan": r"\tan",
            "csc": r"\csc", "sec": r"\sec", "cot": r"\cot"}

FUNC_NAME = {"sin": "sine", "cos": "cosine", "tan": "tangent",
             "csc": "cosecant", "sec": "secant", "cot": "cotangent"}

# Numerator of the period, over that function's base period.
PERIOD_NUM = {"sin": 2, "cos": 2, "sec": 2, "csc": 2, "tan": 1, "cot": 1}

# Only these two are bounded.
HAS_AMPLITUDE = {"sin", "cos"}

# C choices, as multiples of pi kept small enough to read.
C_CHOICES = [ZERO, rat(1, 6), rat(1, 4), rat(1, 3), rat(1, 2),
             rat(2, 3), rat(3, 4), rat(1, 1)]


def inner_tex(B, C):
    """Bx + C, with the constant's sign folded into the printed form."""
    core = "x" if B == 1 else "%dx" % B
    if is_zero(C):
        return core
    if C[0] > 0:
        return core + "+" + pi_tex(C)
    return core + "-" + pi_tex((-C[0], C[1]))


def func_tex(f, A, B, C, D):
    """y = D + A f(Bx + C), printed the way the worksheet examples are."""
    trig = FUNC_TEX[f] + r"\left(" + inner_tex(B, C) + r"\right)"
    if A == 1:
        body, neg = trig, False
    elif A == -1:
        body, neg = trig, True
    else:
        body, neg = "%d" % abs(A) + trig, A < 0
    if D == 0:
        return "y = " + ("-" if neg else "") + body
    # Prefix with the vertical shift, e.g. "y = 5 + cos(...)".
    return "y = %d %s %s" % (D, "-" if neg else "+", body)


# ===========================================================================
# VARIANT CONTROL -- the only lines you edit to pin a variant.
#
#   VARIANT_FUNCTION = None         -> random from all six (default)
#   VARIANT_FUNCTION = "cos"        -> always a cosine
#   VARIANT_FUNCTION = "main"       -> random from sin, cos, tan
#   VARIANT_FUNCTION = "reciprocal" -> random from csc, sec, cot
#
#   VARIANT_PARAMS = None           -> fresh numbers each seed (default)
#   VARIANT_PARAMS = {"A": -2, "B": 3, "C": [1, 2], "D": 5}
#       -> y = 5 - 2 tan(3x + pi/2).  A is the coefficient, B the frequency,
#          D the vertical shift, and C the constant given as [numerator,
#          denominator] of a multiple of pi.
# ===========================================================================
VARIANT_FUNCTION = "cot"
VARIANT_PARAMS   = None


def pick_function():
    if VARIANT_FUNCTION is None:
        return random.choice(FUNCS)
    if VARIANT_FUNCTION == "main":
        return random.choice(MAIN)
    if VARIANT_FUNCTION == "reciprocal":
        return random.choice(RECIP)
    if VARIANT_FUNCTION not in FUNCS:
        raise ValueError(
            "VARIANT_FUNCTION must be None, 'main', 'reciprocal', or one of %s; got %r"
            % (FUNCS, VARIANT_FUNCTION)
        )
    return VARIANT_FUNCTION


def parse_params(p):
    """Turn a pinned VARIANT_PARAMS dict into (A, B, C, D), all plain ints."""
    if "A" not in p or "B" not in p:
        raise ValueError("VARIANT_PARAMS needs at least 'A' and 'B'; got %r" % (p,))
    A, B = int(p["A"]), int(p["B"])
    D = int(p.get("D", 0))
    c = p.get("C", 0)
    try:
        if isinstance(c, (list, tuple)):
            C = rat(int(c[0]), int(c[1]))
        else:
            C = rat(int(c), 1)
    except (TypeError, ValueError, ZeroDivisionError):
        raise ValueError(
            "VARIANT_PARAMS['C'] must be a fraction of pi, e.g. [1, 3]; got %r" % (c,)
        )
    if A == 0:
        raise ValueError("VARIANT_PARAMS['A'] must be a nonzero integer; got %r" % (A,))
    if B < 1:
        raise ValueError("VARIANT_PARAMS['B'] must be a positive integer; got %r" % (B,))
    return A, B, C, D


def pick_params():
    """Draw (A, B, C, D) with a clean period and a clean phase shift."""
    if VARIANT_PARAMS is not None:
        return parse_params(VARIANT_PARAMS)
    while True:
        A = random.choice([1, -1, 2, -2, 3, -3])
        B = random.choice([1, 2, 3, 4])
        c = random.choice(C_CHOICES)
        sign = random.choice([1, -1])
        C = ZERO if is_zero(c) else rat(sign * c[0], c[1])
        D = random.choice([0, 0, 3, 5, -2, 7, -4])
        # Keep the shift's denominator at most 6, e.g. pi/6 or 3pi/4.
        if not is_zero(C):
            shift = rat(-C[0], C[1] * B)
            if shift[1] > 6:
                continue
        # Allow the plainest case, y = A f(x), only some of the time.
        if B == 1 and is_zero(C) and random.random() < 0.5:
            continue
        return A, B, C, D


class Generator(BaseGenerator):

    def data(self):
        f = pick_function()
        A, B, C, D = pick_params()

        period = rat(PERIOD_NUM[f], B)                  # in units of pi
        shift = rat(-C[0], C[1] * B) if not is_zero(C) else ZERO
        absA = abs(A)
        amp = str(absA) if f in HAS_AMPLITUDE else "N/A"

        base_tex = r"2\pi" if PERIOD_NUM[f] == 2 else r"\pi"
        period_tex = pi_tex(period)
        period_frac_tex = r"\frac{%s}{%d}" % (base_tex, B)

        tok = {
            "func_tex": func_tex(f, A, B, C, D),
            "A": A, "B": B, "D": D,
            "Ctex": pi_tex(C),
            "shift": pi_tex(shift),
            "shiftmag": pi_tex((abs(shift[0]), shift[1])),
            "dir": "right" if shift[0] > 0 else "left",
            "base": base_tex,
            "period": period_tex,
            "periodfrac": period_frac_tex,
            "absA": absA,
            "amp": amp,
            "fnname": FUNC_NAME[f],
        }

        # ---- 1. the standard form ----------------------------------------
        paras = [fill(
            r"This function has the form <m>y=D+A\,f(Bx+C)</m>, with <m>f</m> the "
            r"@fnname@ function. Matching terms gives <m>A=@A@</m>, <m>B=@B@</m>, "
            r"<m>C=@Ctex@</m>, and <m>D=@D@</m>. The vertical shift <m>D</m> moves the "
            r"whole graph up or down, so it changes none of the three quantities asked "
            r"for; only <m>A</m>, <m>B</m>, and <m>C</m> matter below.",
            **tok
        )]

        # ---- 2. period ----------------------------------------------------
        if B == 1:
            paras.append(fill(
                r"The period of a @fnname@ is <m>@base@</m>. Here <m>B=1</m>, so the "
                r"argument advances through <m>@base@</m> in one full cycle and the period "
                r"is <m>@period@</m>.",
                **tok
            ))
        else:
            paras.append(fill(
                r"The period of a @fnname@ is <m>@base@</m> divided by <m>|B|</m>. Here "
                r"<m>B=@B@</m>, so the period is <m>@periodfrac@=@period@</m>.",
                **tok
            ))

        # ---- 3. amplitude -------------------------------------------------
        if f in HAS_AMPLITUDE:
            paras.append(fill(
                r"The amplitude of a @fnname@ is <m>|A|=@absA@</m>, so the amplitude is "
                r"<m>@amp@</m>.",
                **tok
            ))
        else:
            paras.append(fill(
                r"The @fnname@ function is unbounded: over one period its values run off "
                r"to infinity in both directions, so it has no maximum or minimum to "
                r"measure from a midline. It therefore has no amplitude; write "
                r"<em>N/A</em>.",
                **tok
            ))

        # ---- 4. phase shift ----------------------------------------------
        if is_zero(shift):
            paras.append(fill(
                r"With the argument written as <m>Bx+C</m>, the phase shift is the "
                r"<m>x</m>-value that makes the argument zero. Here <m>C=0</m>, so "
                r"<m>Bx=0</m> gives <m>x=0</m>: the graph has no phase shift, and the "
                r"answer is <m>0</m>.",
                **tok
            ))
        else:
            paras.append(fill(
                r"With the argument written as <m>Bx+C</m>, the phase shift is the "
                r"<m>x</m>-value that makes the argument zero. Solving <m>Bx+C=0</m> "
                r"gives <m>x=-\dfrac{C}{B}</m>; substituting <m>B=@B@</m> and "
                r"<m>C=@Ctex@</m> gives <m>x=@shift@</m>, so the graph is shifted "
                r"<m>@shiftmag@</m> to the @dir@.",
                **tok
            ))

        # ---- 5. collect the three answers ---------------------------------
        # Each answer gets its own box, in one display element, as its own
        # <me> rather than nested inside a <p>; nesting is what silently drops
        # display math in spatext.
        amp_tex = (r"\lvert A\rvert=%d" % absA) if f in HAS_AMPLITUDE \
                  else r"\text{N/A}"

        boxes = ("    <me>"
                 r"\boxed{\text{Period} = %s}\qquad "
                 r"\boxed{\text{Amplitude} = %s}\qquad "
                 r"\boxed{\text{Phase shift} = %s}"
                 "</me>"
                 % (period_tex, amp_tex, pi_tex(shift)))

        recap = ["    <p>Collecting the three answers:</p>", boxes]

        if D != 0:
            recap.append(
                "    <p>The vertical shift <m>D=%d</m> moved the graph up or down "
                "and appears in none of the three boxes.</p>" % D)

        solution_steps = "\n".join(
            ["    <p>" + p + "</p>" for p in paras] + recap)

        answer_plain = ("Period: %s; Amplitude: %s; Phase shift: %s"
                        % (pi_plain(period), amp, pi_plain(shift)))

        return {
            "func_tex": tok["func_tex"],
            "solution_steps": solution_steps,
            "function": f,
            "A": A, "B": B, "D": D,
            "period": pi_plain(period),
            "amplitude": amp,
            "phase_shift": pi_plain(shift),
            "answer": answer_plain,
            # Kept plain (unboxed) so anything grepping the JSON for
            # "Period:" still matches.
            "answer_tex": (r"\text{Period: }%s,\ \text{Amplitude: }%s,\ "
                           r"\text{Phase shift: }%s"
                           % (period_tex, amp, pi_tex(shift))),
        }
