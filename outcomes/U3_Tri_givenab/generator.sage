from sage.all import *
import math
import random


# ---------------------------------------------------------------------------
# Number formatting.  String formatting is used instead of round() so no Sage
# name can shadow the builtin, and the given values print with trailing zeros
# stripped ("8.1", not "8.10").
# ---------------------------------------------------------------------------
def fmt(x, nd=2):
    """Format with at most nd decimals, trailing zeros stripped."""
    s = ("%." + str(nd) + "f") % float(x)
    if "." in s:
        s = s.rstrip("0").rstrip(".")
    if s in ("-0", ""):
        s = "0"
    return s


def r1(x):
    return float("%.1f" % x)


def r2(x):
    return float("%.2f" % x)


# ---------------------------------------------------------------------------
# Pools
# ---------------------------------------------------------------------------
LEG_POOL = [2.5, 3, 3.5, 4, 4.25, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5,
            9, 9.5, 10, 11, 12, 13, 14, 15, 16, 18, 20]
HYP_POOL = [6, 6.5, 7, 7.5, 8, 8.1, 8.5, 9, 9.5, 10, 11, 12, 13, 14,
            15, 16, 18, 19, 20, 22, 24, 25, 28, 30]
UNITS = ["m", "ft", "in", "cm", "yd", "units"]

# Angles a student could read off with no inverse function at all: the
# isosceles right triangle and the two special right triangles.
SHORTCUT_ANGLES = (30.0, 45.0, 60.0)

TWO_SIDES = [("a", "c"), ("b", "c"), ("a", "b")]
SIDE_ANGLE = [("a", "A"), ("a", "B"), ("b", "A"), ("b", "B"),
              ("c", "A"), ("c", "B")]


def draw_leg(lo=2.5, hi=16.0):
    return random.choice([s for s in LEG_POOL if lo <= s <= hi])


def draw_hyp(lo=6.0, hi=30.0):
    return random.choice([s for s in HYP_POOL if lo <= s <= hi])


def no_shortcut(A):
    """True when no special triangle hands the student the angle for free."""
    if not (12.0 <= A <= 78.0):
        return False
    return all(abs(A - k) > 1.5 for k in SHORTCUT_ANGLES)


# ---------------------------------------------------------------------------
# Builders.  Each returns a dict with A, B, C (degrees) and a, b, c (lengths).
# Side a is opposite angle A, side b opposite B, and c is the hypotenuse.
# ---------------------------------------------------------------------------
def tri_two_sides(pair):
    """Two sides given: the third comes from the Pythagorean theorem and the
    angles need an inverse function."""
    while True:
        if pair == ("a", "c"):
            c = draw_hyp()
            a = r2(c * random.uniform(0.30, 0.92))
            if a < 1.0 or c - a < 0.5:
                continue
            b = math.sqrt(c * c - a * a)
        elif pair == ("b", "c"):
            c = draw_hyp()
            b = r2(c * random.uniform(0.30, 0.92))
            if b < 1.0 or c - b < 0.5:
                continue
            a = math.sqrt(c * c - b * b)
        else:
            a = draw_leg()
            b = draw_leg()
            if min(a, b) < 2.0:
                continue
            c = math.hypot(a, b)
        A = math.degrees(math.atan2(a, b))
        if not no_shortcut(A):
            continue
        return {"A": A, "B": 90.0 - A, "C": 90.0, "a": a, "b": b, "c": c}


def tri_side_angle(side, angname):
    """One side and one acute angle given: angle sum plus SOH-CAH-TOA, no
    inverse function anywhere."""
    while True:
        base = r1(random.uniform(20.0, 70.0))
        A = base if angname == "A" else r1(90.0 - base)
        if not (18.0 <= A <= 72.0):
            continue
        rad = math.radians(A)
        if side == "a":
            a = draw_leg(3.0, 14.0)
            c = a / math.sin(rad)
            b = a / math.tan(rad)
        elif side == "b":
            b = draw_leg(3.0, 14.0)
            c = b / math.cos(rad)
            a = b * math.tan(rad)
        else:
            c = draw_hyp(8.0, 30.0)
            a = c * math.sin(rad)
            b = c * math.cos(rad)
        if min(a, b, c) < 1.0 or max(a, b, c) > 60.0:
            continue
        return {"A": A, "B": r1(90.0 - A), "C": 90.0, "a": a, "b": b, "c": c}


def tri_from_pin(pin):
    """Build the triangle from two pinned measurements (C is always 90)."""
    bad = [k for k in pin if k not in ("A", "B", "a", "b", "c")]
    if bad:
        raise ValueError("VARIANT_PIN keys must be A, B, a, b, or c; got %s" % bad)
    if len(pin) != 2:
        raise ValueError("VARIANT_PIN must fix exactly two values; got %r" % (pin,))
    p = dict((k, float(v)) for k, v in pin.items())

    if ("A" in p) or ("B" in p):
        if "A" in p and "B" in p:
            raise ValueError("VARIANT_PIN needs a side; A and B alone fix no size")
        if "A" in p:
            p["B"] = 90.0 - p["A"]
        else:
            p["A"] = 90.0 - p["B"]
        rad = math.radians(p["A"])
        if "a" in p:
            p["c"] = p["a"] / math.sin(rad)
            p["b"] = p["a"] / math.tan(rad)
        elif "b" in p:
            p["c"] = p["b"] / math.cos(rad)
            p["a"] = p["b"] * math.tan(rad)
        elif "c" in p:
            p["a"] = p["c"] * math.sin(rad)
            p["b"] = p["c"] * math.cos(rad)
        else:
            raise ValueError("VARIANT_PIN cannot fix only an angle")
    else:
        if "a" in p and "b" in p:
            p["c"] = math.hypot(p["a"], p["b"])
        elif "a" in p and "c" in p:
            if p["a"] >= p["c"]:
                raise ValueError("VARIANT_PIN needs a < c")
            p["b"] = math.sqrt(p["c"] ** 2 - p["a"] ** 2)
        elif "b" in p and "c" in p:
            if p["b"] >= p["c"]:
                raise ValueError("VARIANT_PIN needs b < c")
            p["a"] = math.sqrt(p["c"] ** 2 - p["b"] ** 2)
        else:
            raise ValueError("VARIANT_PIN cannot fix only one side")
        p["A"] = math.degrees(math.atan2(p["a"], p["b"]))
        p["B"] = 90.0 - p["A"]

    p["C"] = 90.0
    for k in ("a", "b", "c"):
        if p[k] <= 0:
            raise ValueError("VARIANT_PIN produced a non-positive side")
    return p


# ===========================================================================
# VARIANT CONTROL -- the only lines you edit to pin a variant.
#
#   VARIANT_INVERSE = None       -> two sides or a side+angle, at random
#   VARIANT_INVERSE = "required" -> always two sides (inverse function needed)
#   VARIANT_INVERSE = "forbidden"-> always a side + an acute angle
#
#   VARIANT_GIVEN = None         -> pick the given pair at random
#   VARIANT_GIVEN = "a,c"        -> pin which two measurements are stated
#       valid: a,c | b,c | a,b | a,A | a,B | b,A | b,B | c,A | c,B
#       must agree with VARIANT_INVERSE if both are set
#
#   VARIANT_UNIT = None          -> random from UNITS
#   VARIANT_UNIT = "m"           -> pin the unit
#       valid: m, ft, in, cm, yd, units
#
#   VARIANT_PIN = None           -> draw fresh numbers each seed
#   VARIANT_PIN = {"a": 4.25, "c": 8.1}
#       -> lock the triangle itself; the two keys must be any two of
#          A, B, a, b, c (C is always 90).  The remaining values are derived.
# ===========================================================================
VARIANT_INVERSE = None
VARIANT_GIVEN   = "a,b"
VARIANT_UNIT    = None
VARIANT_PIN     = None


def pick_given():
    if VARIANT_GIVEN is not None:
        parts = tuple(p.strip() for p in VARIANT_GIVEN.split(","))
        if parts in TWO_SIDES:
            pair = parts
        elif parts in SIDE_ANGLE:
            pair = parts
        elif parts[::-1] in TWO_SIDES:
            pair = parts[::-1]
        elif parts[::-1] in SIDE_ANGLE:
            pair = parts[::-1]
        else:
            raise ValueError(
                "VARIANT_GIVEN must be one of %s or %s; got %r"
                % (TWO_SIDES, SIDE_ANGLE, VARIANT_GIVEN)
            )
        if VARIANT_INVERSE == "required" and pair not in TWO_SIDES:
            raise ValueError(
                "VARIANT_GIVEN=%r is a side+angle pair, but VARIANT_INVERSE is "
                "'required'" % (VARIANT_GIVEN,)
            )
        if VARIANT_INVERSE == "forbidden" and pair not in SIDE_ANGLE:
            raise ValueError(
                "VARIANT_GIVEN=%r is a two-side pair, but VARIANT_INVERSE is "
                "'forbidden'" % (VARIANT_GIVEN,)
            )
        return pair
    if VARIANT_INVERSE == "required":
        return random.choice(TWO_SIDES)
    if VARIANT_INVERSE == "forbidden":
        return random.choice(SIDE_ANGLE)
    if VARIANT_INVERSE is not None:
        raise ValueError(
            "VARIANT_INVERSE must be None, 'required', or 'forbidden'; got %r"
            % (VARIANT_INVERSE,)
        )
    return random.choice(TWO_SIDES + SIDE_ANGLE)


def pick_unit():
    if VARIANT_UNIT is None:
        return random.choice(UNITS)
    if VARIANT_UNIT not in UNITS:
        raise ValueError("VARIANT_UNIT must be one of %s; got %r"
                         % (UNITS, VARIANT_UNIT))
    return VARIANT_UNIT


class Generator(BaseGenerator):

    def data(self):
        unit = pick_unit()
        utex = r"\text{ " + unit + "}"

        if VARIANT_PIN is not None:
            given = set(VARIANT_PIN)
            t = tri_from_pin(VARIANT_PIN)
        else:
            pair = pick_given()
            given = set(pair)
            if pair in TWO_SIDES:
                t = tri_two_sides(pair)
            else:
                side = pair[0] if pair[0] in "abc" else pair[1]
                angname = "A" if "A" in pair else "B"
                t = tri_side_angle(side, angname)

        two_sides = not (("A" in given) or ("B" in given))

        # Which values are exact as stated and which are computed.
        approx = {"A": True, "B": True, "C": False,
                  "a": True, "b": True, "c": True}
        for name in given:
            approx[name] = False
        if not two_sides:
            approx["A"] = False
            approx["B"] = False

        # ---- formatters ---------------------------------------------------
        def side_tex(name):
            if approx[name]:
                return r"<m>%s \approx %.2f%s</m>" % (name, t[name], utex)
            return r"<m>%s = %s%s</m>" % (name, fmt(t[name]), utex)

        def ang_tex(name):
            if approx[name]:
                return r"<m>%s \approx %.2f^\circ</m>" % (name, t[name])
            return r"<m>%s = %s^\circ</m>" % (name, fmt(t[name]))

        # ---- the given statement for the prompt ---------------------------
        stated = []
        for name in ("A", "B", "a", "b", "c"):
            if name in given:
                if name in "AB":
                    stated.append(r"<m>%s = %s^\circ</m>" % (name, fmt(t[name])))
                else:
                    stated.append(r"<m>%s = %s%s</m>" % (name, fmt(t[name]), utex))
        given_text = " and ".join(stated)

        # ---- solution steps ----------------------------------------------
        C90 = r"Angle <m>C</m> is the right angle, so <m>C=90^\circ</m>."

        if two_sides:
            s = set(given)
            lines = [C90]
            if s == {"a", "c"}:
                lines.append(
                    r"The Pythagorean theorem <m>a^2+b^2=c^2</m> gives the other leg: "
                    r"<m>b=\sqrt{c^2-a^2}=\sqrt{%.2f^2-%.2f^2}\approx %.2f%s</m>."
                    % (t["c"], t["a"], t["b"], utex))
                lines.append(
                    r"Now <m>\sin A=\frac{\text{opp}}{\text{hyp}}=\frac{a}{c}"
                    r"=\frac{%.2f}{%.2f}</m>, so the inverse sine gives "
                    r"<m>A=\sin^{-1}\!\left(\frac{%.2f}{%.2f}\right)\approx %.2f^\circ</m>."
                    % (t["a"], t["c"], t["a"], t["c"], t["A"]))
            elif s == {"b", "c"}:
                lines.append(
                    r"The Pythagorean theorem <m>a^2+b^2=c^2</m> gives the other leg: "
                    r"<m>a=\sqrt{c^2-b^2}=\sqrt{%.2f^2-%.2f^2}\approx %.2f%s</m>."
                    % (t["c"], t["b"], t["a"], utex))
                lines.append(
                    r"Now <m>\cos A=\frac{\text{adj}}{\text{hyp}}=\frac{b}{c}"
                    r"=\frac{%.2f}{%.2f}</m>, so the inverse cosine gives "
                    r"<m>A=\cos^{-1}\!\left(\frac{%.2f}{%.2f}\right)\approx %.2f^\circ</m>."
                    % (t["b"], t["c"], t["b"], t["c"], t["A"]))
            else:
                lines.append(
                    r"The Pythagorean theorem <m>a^2+b^2=c^2</m> gives the hypotenuse: "
                    r"<m>c=\sqrt{a^2+b^2}=\sqrt{%.2f^2+%.2f^2}\approx %.2f%s</m>."
                    % (t["a"], t["b"], t["c"], utex))
                lines.append(
                    r"Now <m>\tan A=\frac{\text{opp}}{\text{adj}}=\frac{a}{b}"
                    r"=\frac{%.2f}{%.2f}</m>, so the inverse tangent gives "
                    r"<m>A=\tan^{-1}\!\left(\frac{%.2f}{%.2f}\right)\approx %.2f^\circ</m>."
                    % (t["a"], t["b"], t["a"], t["b"], t["A"]))
            lines.append(
                r"The two acute angles of a right triangle are complementary, so "
                r"<m>B=90^\circ-A\approx %.2f^\circ</m>." % t["B"])

        else:
            side = [k for k in ("a", "b", "c") if k in given][0]
            angname = "A" if "A" in given else "B"
            lines = [C90]
            if angname == "B":
                lines.append(
                    r"The two acute angles are complementary, so "
                    r"<m>A=90^\circ-B=90^\circ-%s^\circ=%s^\circ</m>."
                    % (fmt(t["B"]), fmt(t["A"])))
            else:
                lines.append(
                    r"The two acute angles are complementary, so "
                    r"<m>B=90^\circ-A=90^\circ-%s^\circ=%s^\circ</m>."
                    % (fmt(t["A"]), fmt(t["B"])))

            if side == "a":
                lines.append(
                    r"With the side opposite <m>A</m> given, use the sine ratio: "
                    r"<m>\sin A=\frac{a}{c}</m>, so "
                    r"<m>c=\frac{a}{\sin A}=\frac{%s}{\sin %s^\circ}"
                    r"\approx %.2f%s</m>."
                    % (fmt(t["a"]), fmt(t["A"]), t["c"], utex))
                lines.append(
                    r"The tangent ratio gives the other leg: "
                    r"<m>\tan A=\frac{a}{b}</m>, so "
                    r"<m>b=\frac{a}{\tan A}=\frac{%s}{\tan %s^\circ}"
                    r"\approx %.2f%s</m>."
                    % (fmt(t["a"]), fmt(t["A"]), t["b"], utex))
            elif side == "b":
                lines.append(
                    r"With the side adjacent to <m>A</m> given, use the cosine ratio: "
                    r"<m>\cos A=\frac{b}{c}</m>, so "
                    r"<m>c=\frac{b}{\cos A}=\frac{%s}{\cos %s^\circ}"
                    r"\approx %.2f%s</m>."
                    % (fmt(t["b"]), fmt(t["A"]), t["c"], utex))
                lines.append(
                    r"The tangent ratio gives the other leg: "
                    r"<m>\tan A=\frac{a}{b}</m>, so "
                    r"<m>a=b\tan A=%s\tan %s^\circ\approx %.2f%s</m>."
                    % (fmt(t["b"]), fmt(t["A"]), t["a"], utex))
            else:
                lines.append(
                    r"With the hypotenuse given, the sine ratio gives the side opposite "
                    r"<m>A</m>: <m>a=c\sin A=%s\sin %s^\circ\approx %.2f%s</m>."
                    % (fmt(t["c"]), fmt(t["A"]), t["a"], utex))
                lines.append(
                    r"The cosine ratio gives the side adjacent to <m>A</m>: "
                    r"<m>b=c\cos A=%s\cos %s^\circ\approx %.2f%s</m>."
                    % (fmt(t["c"]), fmt(t["A"]), t["b"], utex))

        # ---- the summary, angles first then sides -------------------------
        summary = (ang_tex("A") + ", " + ang_tex("B") + ", "
                   + r"<m>C = 90^\circ</m>; "
                   + side_tex("a") + ", " + side_tex("b") + ", " + side_tex("c") + ".")
        lines.append(r"Collecting the results, angles first and then sides: "
                     + summary)

        solution_steps = "\n".join("    <p>" + ln + "</p>" for ln in lines)

        # ---- machine-checkable answer -------------------------------------
        def aplain(name):
            v = t[name]
            s = ("%.2f" % v) if approx[name] else fmt(v)
            if name in "ABC":
                return "%s=%s deg" % (name, s)
            return "%s=%s %s" % (name, s, unit)

        def atex(name):
            v = t[name]
            s = ("%.2f" % v) if approx[name] else fmt(v)
            if name in "ABC":
                if approx[name]:
                    return r"%s \approx %s^\circ" % (name, s)
                return r"%s = %s^\circ" % (name, s)
            if approx[name]:
                return r"%s \approx %s%s" % (name, s, utex)
            return r"%s = %s%s" % (name, s, utex)

        order = ("A", "B", "C", "a", "b", "c")
        return {
            "given_text": given_text,
            "solution_steps": solution_steps,
            "given": ",".join(k for k in order if k in given),
            "needs_inverse": (not two_sides) is False,
            "unit": unit,
            "answer": ", ".join(aplain(n) for n in order),
            "answer_tex": ", ".join(atex(n) for n in order),
        }
