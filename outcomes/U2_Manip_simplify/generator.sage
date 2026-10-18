from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # Select a variable to use for the problem
        v = random.choice(["x", r"\theta", "t"])

        # ------------------------------------------------------------------
        # Even/odd family, generated programmatically so the sign (and which
        # factor carries the negated argument) is randomized. Every product
        # below simplifies to a single trig function or a constant.
        # ------------------------------------------------------------------
        def even_odd_problem():
            results = {
                frozenset(("sin", "cot")): (rf"\cos {v}", rf"\cos {v}"),
                frozenset(("sin", "sec")): (rf"\frac{{\sin {v}}}{{\cos {v}}}", rf"\tan {v}"),
                frozenset(("sin", "csc")): (rf"1", rf"1"),
                frozenset(("cos", "tan")): (rf"\sin {v}", rf"\sin {v}"),
                frozenset(("cos", "sec")): (rf"1", rf"1"),
                frozenset(("cos", "csc")): (rf"\frac{{\cos {v}}}{{\sin {v}}}", rf"\cot {v}"),
                frozenset(("tan", "cot")): (rf"1", rf"1"),
                frozenset(("tan", "csc")): (rf"\frac{{1}}{{\cos {v}}}", rf"\sec {v}"),
                frozenset(("cot", "sec")): (rf"\frac{{1}}{{\sin {v}}}", rf"\csc {v}"),
            }
            forms = {
                "sin": rf"\sin {v}",
                "cos": rf"\cos {v}",
                "tan": rf"\frac{{\sin {v}}}{{\cos {v}}}",
                "cot": rf"\frac{{\cos {v}}}{{\sin {v}}}",
                "sec": rf"\frac{{1}}{{\cos {v}}}",
                "csc": rf"\frac{{1}}{{\sin {v}}}",
            }
            odd = {"sin", "tan", "cot", "csc"}

            pair = random.choice(list(results.keys()))
            a, b = sorted(pair)
            negated = random.choice([a, b])          # randomize which factor is negated
            other = b if negated == a else a
            cancelled, final = results[pair]

            sign = "-" if negated in odd else ""
            expr = rf"{negated}(-{v}) {other} {v}"

            steps = []
            if negated in odd:
                steps.append(rf"-{negated} {v} \cdot {other} {v}")
            else:
                steps.append(rf"{negated} {v} \cdot {other} {v}")
            steps.append(sign + forms[negated] + r" \cdot " + forms[other])
            steps.append(sign + cancelled)
            if final != cancelled:
                steps.append(sign + final)

            return {"expr": expr, "steps": steps, "final": sign + final}

        # ------------------------------------------------------------------
        # Families of explicitly enumerated problems. Each is solvable using
        # only the reciprocal, quotient, Pythagorean, and even/odd identities,
        # and each ends in a single trig function or a constant.
        # ------------------------------------------------------------------
        families = {

            # ===== A: quotient/reciprocal combined with Pythagorean =====
            "quotient_pythagorean": [
                {"expr": rf"\cot {v} \cos {v} + \sin {v}",
                 "steps": [rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v} + \sin {v}",
                           rf"\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}",
                           rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
                {"expr": rf"\sin {v} + \cot {v} \cos {v}",
                 "steps": [rf"\sin {v} + \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                           rf"\frac{{\sin^2 {v}}}{{\sin {v}}} + \frac{{\cos^2 {v}}}{{\sin {v}}}",
                           rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
                {"expr": rf"\tan {v} \sin {v} + \cos {v}",
                 "steps": [rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v} + \cos {v}",
                           rf"\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}",
                           rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
                {"expr": rf"\cos {v} + \tan {v} \sin {v}",
                 "steps": [rf"\cos {v} + \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                           rf"\frac{{\cos^2 {v}}}{{\cos {v}}} + \frac{{\sin^2 {v}}}{{\cos {v}}}",
                           rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
                {"expr": rf"\csc {v} - \cot {v} \cos {v}",
                 "steps": [rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                           rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos^2 {v}}}{{\sin {v}}}",
                           rf"\frac{{\sin^2 {v}}}{{\sin {v}}}"], "final": rf"\sin {v}"},
                {"expr": rf"\sec {v} - \tan {v} \sin {v}",
                 "steps": [rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                           rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin^2 {v}}}{{\cos {v}}}",
                           rf"\frac{{\cos^2 {v}}}{{\cos {v}}}"], "final": rf"\cos {v}"},
                {"expr": rf"\cos^2 {v} \csc {v} + \sin {v}",
                 "steps": [rf"\cos^2 {v} \cdot \frac{{1}}{{\sin {v}}} + \sin {v}",
                           rf"\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}",
                           rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
                {"expr": rf"\sin^2 {v} \sec {v} + \cos {v}",
                 "steps": [rf"\sin^2 {v} \cdot \frac{{1}}{{\cos {v}}} + \cos {v}",
                           rf"\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}",
                           rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
            ],

            # ===== B: factoring out a common trig factor + Pythagorean =====
            "factoring": [
                {"expr": rf"\sin {v} \cos^2 {v} + \sin^3 {v}",
                 "steps": [rf"\sin {v} \left(\cos^2 {v} + \sin^2 {v}\right)",
                           rf"\sin {v} \cdot 1", rf"\sin {v}"], "final": rf"\sin {v}"},
                {"expr": rf"\cos {v} \sin^2 {v} + \cos^3 {v}",
                 "steps": [rf"\cos {v} \left(\sin^2 {v} + \cos^2 {v}\right)",
                           rf"\cos {v} \cdot 1", rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\sin {v} + \sin {v} \cot^2 {v}",
                 "steps": [rf"\sin {v} \left(1 + \cot^2 {v}\right)",
                           rf"\sin {v} \csc^2 {v}",
                           rf"\sin {v} \cdot \frac{{1}}{{\sin^2 {v}}}",
                           rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
                {"expr": rf"\cos {v} + \cos {v} \tan^2 {v}",
                 "steps": [rf"\cos {v} \left(1 + \tan^2 {v}\right)",
                           rf"\cos {v} \sec^2 {v}",
                           rf"\cos {v} \cdot \frac{{1}}{{\cos^2 {v}}}",
                           rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
                {"expr": rf"\tan {v} \cos^2 {v} + \tan {v} \sin^2 {v}",
                 "steps": [rf"\tan {v} \left(\cos^2 {v} + \sin^2 {v}\right)",
                           rf"\tan {v} \cdot 1", rf"\tan {v}"], "final": rf"\tan {v}"},
                {"expr": rf"\cot {v} \sin^2 {v} + \cot {v} \cos^2 {v}",
                 "steps": [rf"\cot {v} \left(\sin^2 {v} + \cos^2 {v}\right)",
                           rf"\cot {v} \cdot 1", rf"\cot {v}"], "final": rf"\cot {v}"},
                {"expr": rf"\sec {v} \cos^2 {v} + \sec {v} \sin^2 {v}",
                 "steps": [rf"\sec {v} \left(\cos^2 {v} + \sin^2 {v}\right)",
                           rf"\sec {v} \cdot 1", rf"\sec {v}"], "final": rf"\sec {v}"},
                {"expr": rf"\csc {v} \sin^2 {v} + \csc {v} \cos^2 {v}",
                 "steps": [rf"\csc {v} \left(\sin^2 {v} + \cos^2 {v}\right)",
                           rf"\csc {v} \cdot 1", rf"\csc {v}"], "final": rf"\csc {v}"},
                {"expr": rf"\sin {v} \sec^2 {v} - \sin {v} \tan^2 {v}",
                 "steps": [rf"\sin {v} \left(\sec^2 {v} - \tan^2 {v}\right)",
                           rf"\sin {v} \cdot 1", rf"\sin {v}"], "final": rf"\sin {v}"},
                {"expr": rf"\cos {v} \csc^2 {v} - \cos {v} \cot^2 {v}",
                 "steps": [rf"\cos {v} \left(\csc^2 {v} - \cot^2 {v}\right)",
                           rf"\cos {v} \cdot 1", rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\sec {v} - \sec {v} \sin^2 {v}",
                 "steps": [rf"\sec {v} \left(1 - \sin^2 {v}\right)",
                           rf"\sec {v} \cos^2 {v}",
                           rf"\frac{{1}}{{\cos {v}}} \cdot \cos^2 {v}",
                           rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\csc {v} - \csc {v} \cos^2 {v}",
                 "steps": [rf"\csc {v} \left(1 - \cos^2 {v}\right)",
                           rf"\csc {v} \sin^2 {v}",
                           rf"\frac{{1}}{{\sin {v}}} \cdot \sin^2 {v}",
                           rf"\sin {v}"], "final": rf"\sin {v}"},
            ],

            # ===== C: fractions that reduce via a Pythagorean identity =====
            "rational": [
                {"expr": rf"\frac{{\sin {v}}}{{1 - \cos^2 {v}}}",
                 "steps": [rf"\frac{{\sin {v}}}{{\sin^2 {v}}}", rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
                {"expr": rf"\frac{{\cos {v}}}{{1 - \sin^2 {v}}}",
                 "steps": [rf"\frac{{\cos {v}}}{{\cos^2 {v}}}", rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
                {"expr": rf"\frac{{1 - \sin^2 {v}}}{{\cos {v}}}",
                 "steps": [rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\frac{{1 - \cos^2 {v}}}{{\sin {v}}}",
                 "steps": [rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
                {"expr": rf"\frac{{1 + \tan^2 {v}}}{{\sec {v}}}",
                 "steps": [rf"\frac{{\sec^2 {v}}}{{\sec {v}}}", rf"\sec {v}"], "final": rf"\sec {v}"},
                {"expr": rf"\frac{{1 + \cot^2 {v}}}{{\csc {v}}}",
                 "steps": [rf"\frac{{\csc^2 {v}}}{{\csc {v}}}", rf"\csc {v}"], "final": rf"\csc {v}"},
                {"expr": rf"\frac{{\sec {v}}}{{1 + \tan^2 {v}}}",
                 "steps": [rf"\frac{{\sec {v}}}{{\sec^2 {v}}}", rf"\frac{{1}}{{\sec {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\frac{{\csc {v}}}{{1 + \cot^2 {v}}}",
                 "steps": [rf"\frac{{\csc {v}}}{{\csc^2 {v}}}", rf"\frac{{1}}{{\csc {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
                {"expr": rf"\left(\sec^2 {v} - 1\right) \cot {v}",
                 "steps": [rf"\tan^2 {v} \cot {v}",
                           rf"\tan^2 {v} \cdot \frac{{1}}{{\tan {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
                {"expr": rf"\left(\csc^2 {v} - 1\right) \tan {v}",
                 "steps": [rf"\cot^2 {v} \tan {v}",
                           rf"\cot^2 {v} \cdot \frac{{1}}{{\cot {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
                {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan {v}}}",
                 "steps": [rf"\frac{{\tan^2 {v}}}{{\tan {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
                {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot {v}}}",
                 "steps": [rf"\frac{{\cot^2 {v}}}{{\cot {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
            ],

            # ===== D: ratios/quotients of reciprocal & quotient functions =====
            # (Hardened: each problem now needs a Pythagorean step or a
            #  reciprocal cancellation ON TOP of converting to sin/cos.)
            "ratio_quotient": [
                {"expr": rf"\frac{{\tan {v}}}{{\sec {v}}} \csc {v}",
                 "steps": [rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \cos {v} \cdot \csc {v}",
                           rf"\sin {v} \cdot \frac{{1}}{{\sin {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\frac{{\cot {v}}}{{\csc {v}}} \sec {v}",
                 "steps": [rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \sin {v} \cdot \sec {v}",
                           rf"\cos {v} \cdot \frac{{1}}{{\cos {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\frac{{\sec {v}}}{{\tan {v}}} \cos {v}",
                 "steps": [rf"\frac{{1}}{{\cos {v}}} \cdot \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                           rf"\frac{{1}}{{\sin {v}}} \cdot \cos {v}",
                           rf"\frac{{\cos {v}}}{{\sin {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
                {"expr": rf"\frac{{\csc {v}}}{{\cot {v}}} \sin {v}",
                 "steps": [rf"\frac{{1}}{{\sin {v}}} \cdot \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                           rf"\frac{{1}}{{\cos {v}}} \cdot \sin {v}",
                           rf"\frac{{\sin {v}}}{{\cos {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
                {"expr": rf"\frac{{\sec {v} - \cos {v}}}{{\tan {v}}}",
                 "steps": [rf"\frac{{\frac{{1}}{{\cos {v}}} - \cos {v}}}{{\frac{{\sin {v}}}{{\cos {v}}}}}",
                           rf"\frac{{\frac{{1 - \cos^2 {v}}}{{\cos {v}}}}}{{\frac{{\sin {v}}}{{\cos {v}}}}}",
                           rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
                {"expr": rf"\frac{{\csc {v} - \sin {v}}}{{\cot {v}}}",
                 "steps": [rf"\frac{{\frac{{1}}{{\sin {v}}} - \sin {v}}}{{\frac{{\cos {v}}}{{\sin {v}}}}}",
                           rf"\frac{{\frac{{1 - \sin^2 {v}}}{{\sin {v}}}}}{{\frac{{\cos {v}}}{{\sin {v}}}}}",
                           rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\frac{{\tan {v} \sin {v} + \cos {v}}}{{\sec {v}}}",
                 "steps": [rf"\frac{{\frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v} + \cos {v}}}{{\frac{{1}}{{\cos {v}}}}}",
                           rf"\frac{{\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}}}{{\frac{{1}}{{\cos {v}}}}}",
                           rf"\frac{{\frac{{1}}{{\cos {v}}}}}{{\frac{{1}}{{\cos {v}}}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\frac{{\cot {v} \cos {v} + \sin {v}}}{{\csc {v}}}",
                 "steps": [rf"\frac{{\frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v} + \sin {v}}}{{\frac{{1}}{{\sin {v}}}}}",
                           rf"\frac{{\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}}}{{\frac{{1}}{{\sin {v}}}}}",
                           rf"\frac{{\frac{{1}}{{\sin {v}}}}}{{\frac{{1}}{{\sin {v}}}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\frac{{\tan^2 {v} + 1}}{{\sec {v} \csc {v}}}",
                 "steps": [rf"\frac{{\sec^2 {v}}}{{\sec {v} \csc {v}}}",
                           rf"\frac{{\sec {v}}}{{\csc {v}}}",
                           rf"\frac{{\sin {v}}}{{\cos {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
                {"expr": rf"\frac{{\cot^2 {v} + 1}}{{\csc {v} \sec {v}}}",
                 "steps": [rf"\frac{{\csc^2 {v}}}{{\csc {v} \sec {v}}}",
                           rf"\frac{{\csc {v}}}{{\sec {v}}}",
                           rf"\frac{{\cos {v}}}{{\sin {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
                {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan {v} \sec {v}}}",
                 "steps": [rf"\frac{{\tan^2 {v}}}{{\tan {v} \sec {v}}}",
                           rf"\frac{{\tan {v}}}{{\sec {v}}}",
                           rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \cos {v}", rf"\sin {v}"], "final": rf"\sin {v}"},
                {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot {v} \csc {v}}}",
                 "steps": [rf"\frac{{\cot^2 {v}}}{{\cot {v} \csc {v}}}",
                           rf"\frac{{\cot {v}}}{{\csc {v}}}",
                           rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \sin {v}", rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\frac{{\sec {v} - \cos {v}}}{{\sin {v} \tan {v}}}",
                 "steps": [rf"\frac{{\frac{{1}}{{\cos {v}}} - \cos {v}}}{{\sin {v} \cdot \frac{{\sin {v}}}{{\cos {v}}}}}",
                           rf"\frac{{\frac{{1 - \cos^2 {v}}}{{\cos {v}}}}}{{\frac{{\sin^2 {v}}}{{\cos {v}}}}}",
                           rf"\frac{{\sin^2 {v}}}{{\sin^2 {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\frac{{\csc {v} - \sin {v}}}{{\cos {v} \cot {v}}}",
                 "steps": [rf"\frac{{\frac{{1}}{{\sin {v}}} - \sin {v}}}{{\cos {v} \cdot \frac{{\cos {v}}}{{\sin {v}}}}}",
                           rf"\frac{{\frac{{1 - \sin^2 {v}}}{{\sin {v}}}}}{{\frac{{\cos^2 {v}}}{{\sin {v}}}}}",
                           rf"\frac{{\cos^2 {v}}}{{\cos^2 {v}}}", rf"1"], "final": rf"1"},
            ],

            # ===== E: even/odd identities (generated above) =====
            "even_odd": None,

            # ===== F: Pythagorean -> reciprocal, then cancel =====
            "pythagorean_reciprocal": [
                {"expr": rf"\left(1 + \tan^2 {v}\right) \cos {v}",
                 "steps": [rf"\sec^2 {v} \cos {v}",
                           rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos {v}",
                           rf"\frac{{1}}{{\cos {v}}}", rf"\sec {v}"], "final": rf"\sec {v}"},
                {"expr": rf"\left(1 + \cot^2 {v}\right) \sin {v}",
                 "steps": [rf"\csc^2 {v} \sin {v}",
                           rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin {v}",
                           rf"\frac{{1}}{{\sin {v}}}", rf"\csc {v}"], "final": rf"\csc {v}"},
                {"expr": rf"\sec^2 {v} \cos {v} - \tan {v} \sin {v}",
                 "steps": [rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos {v} - \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                           rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin^2 {v}}}{{\cos {v}}}",
                           rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
                {"expr": rf"\csc^2 {v} \sin {v} - \cot {v} \cos {v}",
                 "steps": [rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin {v} - \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                           rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos^2 {v}}}{{\sin {v}}}",
                           rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
            ],

            # ===== G: expressions that reduce to a constant =====
            "constants": [
                {"expr": rf"\sin {v} \csc {v}",
                 "steps": [rf"\sin {v} \cdot \frac{{1}}{{\sin {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\cos {v} \sec {v}",
                 "steps": [rf"\cos {v} \cdot \frac{{1}}{{\cos {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\tan {v} \cot {v}",
                 "steps": [rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \frac{{\cos {v}}}{{\sin {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\sin^2 {v} + \cos^2 {v}",
                 "steps": [rf"1"], "final": rf"1"},
                {"expr": rf"\sec^2 {v} - \tan^2 {v}",
                 "steps": [rf"1"], "final": rf"1"},
                {"expr": rf"\csc^2 {v} - \cot^2 {v}",
                 "steps": [rf"1"], "final": rf"1"},
                {"expr": rf"\left(1 + \tan^2 {v}\right) \cos^2 {v}",
                 "steps": [rf"\sec^2 {v} \cos^2 {v}",
                           rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos^2 {v}", rf"1"], "final": rf"1"},
                {"expr": rf"\left(1 + \cot^2 {v}\right) \sin^2 {v}",
                 "steps": [rf"\csc^2 {v} \sin^2 {v}",
                           rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin^2 {v}", rf"1"], "final": rf"1"},
                {"expr": rf"\sin^2 {v} \csc^2 {v}",
                 "steps": [rf"\sin^2 {v} \cdot \frac{{1}}{{\sin^2 {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\cos^2 {v} \sec^2 {v}",
                 "steps": [rf"\cos^2 {v} \cdot \frac{{1}}{{\cos^2 {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\left(\sec^2 {v} - 1\right) \cot^2 {v}",
                 "steps": [rf"\tan^2 {v} \cot^2 {v}",
                           rf"\frac{{\sin^2 {v}}}{{\cos^2 {v}}} \cdot \frac{{\cos^2 {v}}}{{\sin^2 {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\left(\csc^2 {v} - 1\right) \tan^2 {v}",
                 "steps": [rf"\cot^2 {v} \tan^2 {v}",
                           rf"\frac{{\cos^2 {v}}}{{\sin^2 {v}}} \cdot \frac{{\sin^2 {v}}}{{\cos^2 {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan^2 {v}}}",
                 "steps": [rf"\frac{{\tan^2 {v}}}{{\tan^2 {v}}}", rf"1"], "final": rf"1"},
                {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot^2 {v}}}",
                 "steps": [rf"\frac{{\cot^2 {v}}}{{\cot^2 {v}}}", rf"1"], "final": rf"1"},
            ],
        }

        # Pick a family uniformly, then a problem uniformly within it.
        family = random.choice(list(families.keys()))
        if family == "even_odd":
            problem = even_odd_problem()
        else:
            problem = random.choice(families[family])

        # Assemble the outtro using the Zero-Text Rule
        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")

        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")

        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {
            "expr": problem["expr"],
            "outtro": outtro
        }
