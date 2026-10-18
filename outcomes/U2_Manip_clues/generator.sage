from sage.all import *
import random
from fractions import Fraction as F
from math import gcd as igcd


class Generator(BaseGenerator):
    def data(self):
        # ------------------------------------------------------------------
        # Safe exact arithmetic.
        #
        # A .sage file is PREPARSED, so integer literals (1, -1, 2, ...) become
        # Sage Integers.  Sage Integers are registered as numbers.Rational but
        # expose .numerator/.denominator as *methods*, not properties, so
        # Fraction(sage_integer) silently builds a broken Fraction and the next
        # time it meets a Sage Integer math.gcd() receives a bound method:
        #     TypeError: 'method' object cannot be interpreted as an integer
        # (Sage issue #28234).  Fix: coerce every integer to a Python int, and
        # only ever construct Fractions from Python ints.
        #
        # NOTE ON XML: this file emits raw XML, so "<" and ">" may NEVER appear
        # in the generated text.  Write inequalities as \lt and \gt.
        # ------------------------------------------------------------------
        def Fr(x):
            return x if isinstance(x, F) else F(int(x))

        def reduce_sqrt(m):
            m = int(m)
            k, m0, d = 1, m, 2
            while d * d <= m0:
                while m0 % (d * d) == 0:
                    m0 //= d * d
                    k *= d
                d += 1
            return int(k), int(m0)

        def mul(a, b):
            k, m = reduce_sqrt(int(a[1]) * int(b[1]))
            return (Fr(a[0]) * Fr(b[0]) * k, m)

        def div(a, b):
            return mul(a, (Fr(1) / (Fr(b[0]) * int(b[1])), int(b[1])))

        def num(n):
            return (Fr(n), 1)

        def sqrt_val(m):
            k, m0 = reduce_sqrt(m)
            return (Fr(k), m0)

        def fmt(a, dfrac=False):
            c, rad = Fr(a[0]), int(a[1])
            n, d = c.numerator, c.denominator
            sgn = "-" if n < 0 else ""
            n = abs(n)
            fr = "\\dfrac" if dfrac else "\\frac"
            if rad == 1:
                if d == 1:
                    return sgn + str(n)
                return sgn + fr + "{" + str(n) + "}{" + str(d) + "}"
            top = ("\\sqrt{%d}" % rad) if n == 1 else ("%d\\sqrt{%d}" % (n, rad))
            if d == 1:
                return sgn + top
            return sgn + fr + "{" + top + "}{" + str(d) + "}"

        def fmt_sqrt(m):
            k, m0 = reduce_sqrt(m)
            if m0 == 1:
                return str(k)
            return ("\\sqrt{%d}" % m0) if k == 1 else ("%d\\sqrt{%d}" % (k, m0))

        def sq(s):
            return ("(%s)^2" % s) if s.startswith("-") else ("%s^2" % s)

        # ------------------------------------------------------------------
        # Function metadata: name, the (numerator, denominator) sides it
        # uses, and the LaTeX ratio.
        # ------------------------------------------------------------------
        fname = {"sin": "\\sin", "cos": "\\cos", "tan": "\\tan",
                 "cot": "\\cot", "sec": "\\sec", "csc": "\\csc"}
        roles = {"sin": ("y", "r"), "cos": ("x", "r"), "tan": ("y", "x"),
                 "cot": ("x", "y"), "sec": ("r", "x"), "csc": ("r", "y")}
        rat = {"sin": "\\frac{y}{r}", "cos": "\\frac{x}{r}", "tan": "\\frac{y}{x}",
               "cot": "\\frac{x}{y}", "sec": "\\frac{r}{x}", "csc": "\\frac{r}{y}"}
        recip = {"sin": "csc", "csc": "sin", "cos": "sec",
                 "sec": "cos", "tan": "cot", "cot": "tan"}
        funcs = ["sin", "cos", "tan", "cot", "sec", "csc"]
        order = {"x": 0, "y": 1, "r": 2}

        # ------------------------------------------------------------------
        # Integer side pairs: Pythagorean (third side whole) vs. not
        # (third side a radical).  Coerced to Python ints.
        # ------------------------------------------------------------------
        triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25)]
        triples = [tuple(int(t) for t in tr) for tr in triples]
        leg_hyp_triples, leg_leg_triples = [], []
        for (a, b, c) in triples:
            leg_hyp_triples += [(a, c), (b, c)]
            leg_leg_triples += [(a, b), (b, a)]
        leg_hyp_rad, leg_leg_rad = [], []
        for u in range(1, 8):
            for v in range(u + 1, 9):
                u, v = int(u), int(v)
                if igcd(u, v) != 1:
                    continue
                if not is_square(v * v - u * u):
                    leg_hyp_rad.append((u, v))
                if not is_square(u * u + v * v):
                    leg_leg_rad.append((u, v))

        # ------------------------------------------------------------------
        # Given function f, target function g (no reciprocal pairs, no
        # repeats).
        # ------------------------------------------------------------------
        f = random.choice(funcs)
        g = random.choice([t for t in funcs if t != f and t != recip[f]])

        # ------------------------------------------------------------------
        # Reference triangle.  The two sides in the given ratio are whole
        # numbers, so the given value is a simple fraction.
        # ------------------------------------------------------------------
        rnum, rden = roles[f]
        third = ({"x", "y", "r"} - {rnum, rden}).pop()

        if third == "r":
            # known sides are the two legs
            u, v = random.choice(leg_leg_triples if random.random() < 0.5 else leg_leg_rad)
            u, v = int(u), int(v)
            xm, ym = (num(u), num(v)) if random.random() < 0.5 else (num(v), num(u))
            rm = sqrt_val(u * u + v * v)
            m3 = u * u + v * v
        else:
            # known sides are one leg and the hypotenuse
            u, v = random.choice(leg_hyp_triples if random.random() < 0.5 else leg_hyp_rad)
            u, v = int(u), int(v)
            legrole = rnum if rnum != "r" else rden
            if legrole == "x":
                xm, ym = num(u), sqrt_val(v * v - u * u)
            else:
                xm, ym = sqrt_val(v * v - u * u), num(u)
            rm = num(v)
            m3 = v * v - u * u

        quads = {"I": (1, 1), "II": (-1, 1), "III": (-1, -1), "IV": (1, -1)}
        qname = random.choice(["I", "II", "III", "IV"])
        sx, sy = (int(s) for s in quads[qname])

        side = {"x": (sx * xm[0], xm[1]),
                "y": (sy * ym[0], ym[1]),
                "r": (rm[0], rm[1])}

        def value(fn):
            a, b = roles[fn]
            return div(side[a], side[b])

        given_val = value(f)
        answer_val = value(g)

        # ------------------------------- solution -------------------------
        known = sorted([rnum, rden], key=lambda s: order[s])
        step1 = ("In the reference triangle for <m>\\theta</m>, since "
                 "<m>%s(\\theta) = %s = %s</m> and <m>\\theta</m> is in quadrant %s "
                 "(where <m>%s</m> and <m>%s</m>), we may take "
                 "<m>%s = %s</m> and <m>%s = %s</m>."
                 % (fname[f], rat[f], fmt(given_val, dfrac=True), qname,
                    "x \\lt 0" if sx < 0 else "x \\gt 0",
                    "y \\lt 0" if sy < 0 else "y \\gt 0",
                    known[0], fmt(side[known[0]]), known[1], fmt(side[known[1]])))

        if third == "r":
            fs = fmt_sqrt(m3)
            tail = "" if fs == ("\\sqrt{%d}" % m3) else (" = %s" % fs)
            step2 = ("Using <m>x^2 + y^2 = r^2</m>: "
                     "<m>r = \\sqrt{x^2 + y^2} = \\sqrt{%s + %s} = \\sqrt{%d}%s</m>."
                     % (sq(fmt(side["x"])), sq(fmt(side["y"])), m3, tail))
        else:
            knownleg = "y" if third == "x" else "x"
            neg = (third == "x" and sx < 0) or (third == "y" and sy < 0)
            step2 = ("Using <m>x^2 + y^2 = r^2</m>: "
                     "<m>%s^2 = r^2 - %s^2 = %d - %d = %d</m>, so <m>|%s| = %s</m>. "
                     "Since <m>%s %s</m>, <m>%s = %s</m>."
                     % (third, knownleg, v * v, u * u, m3, third, fmt_sqrt(m3),
                        third, "\\lt 0" if neg else "\\gt 0", third, fmt(side[third])))

        step3 = ("Therefore <m>%s(\\theta) = %s = %s</m>."
                 % (fname[g], rat[g], fmt(answer_val)))

        outtro_lines = [
            "    <p>%s</p>" % step1,
            "    <p>%s</p>" % step2,
            "    <p>%s</p>" % step3,
            "    <p><m>\\boxed{%s(\\theta) = %s}</m></p>" % (fname[g], fmt(answer_val)),
        ]
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {
            "target": "%s(\\theta)" % fname[g],
            "given": "%s(\\theta) = %s" % (fname[f], fmt(given_val, dfrac=True)),
            "quadrant": qname,
            "outtro": outtro,
        }
