from sage.all import *
import random


# Short explanations keyed by identity/technique code. "{v}" is replaced with
# the variable chosen for this version of the exercise.
REASONS = {
    "quotient": r"Use the quotient identity to rewrite the tangent or cotangent in terms of sine and cosine: <m>\tan {v}=\frac{\sin {v}}{\cos {v}}</m> and <m>\cot {v}=\frac{\cos {v}}{\sin {v}}</m>.",
    "reciprocal": r"Use the reciprocal identity to rewrite the secant or cosecant in terms of sine and cosine: <m>\sec {v}=\frac{1}{\cos {v}}</m> and <m>\csc {v}=\frac{1}{\sin {v}}</m>.",
    "quotient_reciprocal": r"Use the quotient identity for the tangent or cotangent and the reciprocal identity for the secant or cosecant so that everything is written in terms of sine and cosine.",
    "pythagorean": r"Use the Pythagorean identity <m>\sin^2 {v}+\cos^2 {v}=1</m>.",
    "pyth_tan": r"Use the Pythagorean identity <m>1+\tan^2 {v}=\sec^2 {v}</m>.",
    "pyth_cot": r"Use the Pythagorean identity <m>1+\cot^2 {v}=\csc^2 {v}</m>.",
    "pyth_sec": r"Use the Pythagorean identity <m>\sec^2 {v}-1=\tan^2 {v}</m>.",
    "pyth_csc": r"Use the Pythagorean identity <m>\csc^2 {v}-1=\cot^2 {v}</m>.",
    "even_odd": r"Use the even/odd identity to move the negative sign out of the argument.",
    "common_denominator": r"Write the terms with a common denominator and combine them into a single fraction.",
    "factor": r"Factor out the common trigonometric factor.",
    "cancel": r"Cancel the common factor in the numerator and denominator.",
    "simplify": r"Simplify the expression.",
    "quotient_out": r"Use the quotient identity to write the result as a single trigonometric function.",
    "reciprocal_out": r"Use the reciprocal identity to write the result as a single trigonometric function.",
}

# Which named identity family each code belongs to (used for the summary line).
# Codes not listed here are algebraic moves, not identities.
CATEGORY = {
    "quotient": "quotient",
    "reciprocal": "reciprocal",
    "quotient_reciprocal": ("quotient", "reciprocal"),
    "pythagorean": "Pythagorean",
    "pyth_tan": "Pythagorean",
    "pyth_cot": "Pythagorean",
    "pyth_sec": "Pythagorean",
    "pyth_csc": "Pythagorean",
    "even_odd": "even/odd",
    "quotient_out": "quotient",
    "reciprocal_out": "reciprocal",
}


def identity_summary(codes):
    """Comma-and list of the identity families used, in order of first use."""
    names = []
    for code in codes:
        cats = CATEGORY.get(code)
        if cats is None:
            continue
        if isinstance(cats, str):
            cats = (cats,)
        for c in cats:
            if c not in names:
                names.append(c)
    if not names:
        return None
    if len(names) == 1:
        return names[0]
    if len(names) == 2:
        return names[0] + " and " + names[1]
    return ", ".join(names[:-1]) + ", and " + names[-1]


class Generator(BaseGenerator):
    def data(self):
        # Select a variable to use for the problem
        v = random.choice(["x", r"\theta", "t"])

        def reason(code):
            return REASONS[code].replace("{v}", v)

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
            qset = {"tan", "cot"}
            rset = {"sec", "csc"}

            pair = random.choice(list(results.keys()))
            a, b = sorted(pair)
            negated = random.choice([a, b])          # randomize which factor is negated
            other = b if negated == a else a
            cancelled, final = results[pair]

            sign = "-" if negated in odd else ""
            expr = rf"{negated}(-{v}) {other} {v}"

            # Name the identity used when the factors are written in sin/cos.
            uses_q = negated in qset or other in qset
            uses_r = negated in rset or other in rset
            if uses_q and uses_r:
                rewrite_code = "quotient_reciprocal"
            elif uses_q:
                rewrite_code = "quotient"
            elif uses_r:
                rewrite_code = "reciprocal"
            else:
                rewrite_code = "simplify"

            steps = []
            if negated in odd:
                steps.append((rf"-{negated} {v} \cdot {other} {v}", "even_odd"))
            else:
                steps.append((rf"{negated} {v} \cdot {other} {v}", "even_odd"))
            steps.append((sign + forms[negated] + r" \cdot " + forms[other], rewrite_code))
            steps.append((sign + cancelled, "simplify"))
            if final != cancelled:
                out_code = "quotient_out" if final in ("tan", "cot") else "reciprocal_out"
                steps.append((sign + final, out_code))

            return {"expr": expr, "steps": steps, "final": sign + final}

        # ------------------------------------------------------------------
        # Families of explicitly enumerated problems. Each is solvable using
        # only the reciprocal, quotient, Pythagorean, and even/odd identities,
        # and each ends in a single trig function or a constant. Each step is
        # (math, code) where the code names the identity/technique used.
        # ------------------------------------------------------------------
        families = {

            # ===== A: quotient/reciprocal combined with Pythagorean =====
            "quotient_pythagorean": [
                {"expr": rf"\cot {v} \cos {v} + \sin {v}",
                 "steps": [(rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v} + \sin {v}", "quotient"),
                           (rf"\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}", "common_denominator"),
                           (rf"\frac{{1}}{{\sin {v}}}", "pythagorean"),
                           (rf"\csc {v}", "reciprocal_out")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\sin {v} + \cot {v} \cos {v}",
                 "steps": [(rf"\sin {v} + \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}", "quotient"),
                           (rf"\frac{{\sin^2 {v}}}{{\sin {v}}} + \frac{{\cos^2 {v}}}{{\sin {v}}}", "common_denominator"),
                           (rf"\frac{{1}}{{\sin {v}}}", "pythagorean"),
                           (rf"\csc {v}", "reciprocal_out")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\tan {v} \sin {v} + \cos {v}",
                 "steps": [(rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v} + \cos {v}", "quotient"),
                           (rf"\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}", "common_denominator"),
                           (rf"\frac{{1}}{{\cos {v}}}", "pythagorean"),
                           (rf"\sec {v}", "reciprocal_out")],
                 "final": rf"\sec {v}"},
                {"expr": rf"\cos {v} + \tan {v} \sin {v}",
                 "steps": [(rf"\cos {v} + \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}", "quotient"),
                           (rf"\frac{{\cos^2 {v}}}{{\cos {v}}} + \frac{{\sin^2 {v}}}{{\cos {v}}}", "common_denominator"),
                           (rf"\frac{{1}}{{\cos {v}}}", "pythagorean"),
                           (rf"\sec {v}", "reciprocal_out")],
                 "final": rf"\sec {v}"},
                {"expr": rf"\csc {v} - \cot {v} \cos {v}",
                 "steps": [(rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}", "quotient_reciprocal"),
                           (rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos^2 {v}}}{{\sin {v}}}", "common_denominator"),
                           (rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", "pythagorean"),
                           (rf"\sin {v}", "cancel")],
                 "final": rf"\sin {v}"},
                {"expr": rf"\sec {v} - \tan {v} \sin {v}",
                 "steps": [(rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}", "quotient_reciprocal"),
                           (rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin^2 {v}}}{{\cos {v}}}", "common_denominator"),
                           (rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", "pythagorean"),
                           (rf"\cos {v}", "cancel")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\cos^2 {v} \csc {v} + \sin {v}",
                 "steps": [(rf"\cos^2 {v} \cdot \frac{{1}}{{\sin {v}}} + \sin {v}", "reciprocal"),
                           (rf"\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}", "common_denominator"),
                           (rf"\frac{{1}}{{\sin {v}}}", "pythagorean"),
                           (rf"\csc {v}", "reciprocal_out")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\sin^2 {v} \sec {v} + \cos {v}",
                 "steps": [(rf"\sin^2 {v} \cdot \frac{{1}}{{\cos {v}}} + \cos {v}", "reciprocal"),
                           (rf"\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}", "common_denominator"),
                           (rf"\frac{{1}}{{\cos {v}}}", "pythagorean"),
                           (rf"\sec {v}", "reciprocal_out")],
                 "final": rf"\sec {v}"},
            ],

            # ===== B: factoring out a common trig factor + Pythagorean =====
            "factoring": [
                {"expr": rf"\sin {v} \cos^2 {v} + \sin^3 {v}",
                 "steps": [(rf"\sin {v} \left(\cos^2 {v} + \sin^2 {v}\right)", "factor"),
                           (rf"\sin {v} \cdot 1", "pythagorean"),
                           (rf"\sin {v}", "simplify")],
                 "final": rf"\sin {v}"},
                {"expr": rf"\cos {v} \sin^2 {v} + \cos^3 {v}",
                 "steps": [(rf"\cos {v} \left(\sin^2 {v} + \cos^2 {v}\right)", "factor"),
                           (rf"\cos {v} \cdot 1", "pythagorean"),
                           (rf"\cos {v}", "simplify")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\sin {v} + \sin {v} \cot^2 {v}",
                 "steps": [(rf"\sin {v} \left(1 + \cot^2 {v}\right)", "factor"),
                           (rf"\sin {v} \csc^2 {v}", "pyth_cot"),
                           (rf"\sin {v} \cdot \frac{{1}}{{\sin^2 {v}}}", "reciprocal"),
                           (rf"\frac{{1}}{{\sin {v}}}", "cancel"),
                           (rf"\csc {v}", "reciprocal_out")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\cos {v} + \cos {v} \tan^2 {v}",
                 "steps": [(rf"\cos {v} \left(1 + \tan^2 {v}\right)", "factor"),
                           (rf"\cos {v} \sec^2 {v}", "pyth_tan"),
                           (rf"\cos {v} \cdot \frac{{1}}{{\cos^2 {v}}}", "reciprocal"),
                           (rf"\frac{{1}}{{\cos {v}}}", "cancel"),
                           (rf"\sec {v}", "reciprocal_out")],
                 "final": rf"\sec {v}"},
                {"expr": rf"\tan {v} \cos^2 {v} + \tan {v} \sin^2 {v}",
                 "steps": [(rf"\tan {v} \left(\cos^2 {v} + \sin^2 {v}\right)", "factor"),
                           (rf"\tan {v} \cdot 1", "pythagorean"),
                           (rf"\tan {v}", "simplify")],
                 "final": rf"\tan {v}"},
                {"expr": rf"\cot {v} \sin^2 {v} + \cot {v} \cos^2 {v}",
                 "steps": [(rf"\cot {v} \left(\sin^2 {v} + \cos^2 {v}\right)", "factor"),
                           (rf"\cot {v} \cdot 1", "pythagorean"),
                           (rf"\cot {v}", "simplify")],
                 "final": rf"\cot {v}"},
                {"expr": rf"\sec {v} \cos^2 {v} + \sec {v} \sin^2 {v}",
                 "steps": [(rf"\sec {v} \left(\cos^2 {v} + \sin^2 {v}\right)", "factor"),
                           (rf"\sec {v} \cdot 1", "pythagorean"),
                           (rf"\sec {v}", "simplify")],
                 "final": rf"\sec {v}"},
                {"expr": rf"\csc {v} \sin^2 {v} + \csc {v} \cos^2 {v}",
                 "steps": [(rf"\csc {v} \left(\sin^2 {v} + \cos^2 {v}\right)", "factor"),
                           (rf"\csc {v} \cdot 1", "pythagorean"),
                           (rf"\csc {v}", "simplify")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\sin {v} \sec^2 {v} - \sin {v} \tan^2 {v}",
                 "steps": [(rf"\sin {v} \left(\sec^2 {v} - \tan^2 {v}\right)", "factor"),
                           (rf"\sin {v} \cdot 1", "pyth_sec"),
                           (rf"\sin {v}", "simplify")],
                 "final": rf"\sin {v}"},
                {"expr": rf"\cos {v} \csc^2 {v} - \cos {v} \cot^2 {v}",
                 "steps": [(rf"\cos {v} \left(\csc^2 {v} - \cot^2 {v}\right)", "factor"),
                           (rf"\cos {v} \cdot 1", "pyth_csc"),
                           (rf"\cos {v}", "simplify")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\sec {v} - \sec {v} \sin^2 {v}",
                 "steps": [(rf"\sec {v} \left(1 - \sin^2 {v}\right)", "factor"),
                           (rf"\sec {v} \cos^2 {v}", "pythagorean"),
                           (rf"\frac{{1}}{{\cos {v}}} \cdot \cos^2 {v}", "reciprocal"),
                           (rf"\cos {v}", "cancel")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\csc {v} - \csc {v} \cos^2 {v}",
                 "steps": [(rf"\csc {v} \left(1 - \cos^2 {v}\right)", "factor"),
                           (rf"\csc {v} \sin^2 {v}", "pythagorean"),
                           (rf"\frac{{1}}{{\sin {v}}} \cdot \sin^2 {v}", "reciprocal"),
                           (rf"\sin {v}", "cancel")],
                 "final": rf"\sin {v}"},
            ],

            # ===== C: fractions that reduce via a Pythagorean identity =====
            "rational": [
                {"expr": rf"\frac{{\sin {v}}}{{1 - \cos^2 {v}}}",
                 "steps": [(rf"\frac{{\sin {v}}}{{\sin^2 {v}}}", "pythagorean"),
                           (rf"\frac{{1}}{{\sin {v}}}", "cancel"),
                           (rf"\csc {v}", "reciprocal_out")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\frac{{\cos {v}}}{{1 - \sin^2 {v}}}",
                 "steps": [(rf"\frac{{\cos {v}}}{{\cos^2 {v}}}", "pythagorean"),
                           (rf"\frac{{1}}{{\cos {v}}}", "cancel"),
                           (rf"\sec {v}", "reciprocal_out")],
                 "final": rf"\sec {v}"},
                {"expr": rf"\frac{{1 - \sin^2 {v}}}{{\cos {v}}}",
                 "steps": [(rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", "pythagorean"),
                           (rf"\cos {v}", "cancel")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\frac{{1 - \cos^2 {v}}}{{\sin {v}}}",
                 "steps": [(rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", "pythagorean"),
                           (rf"\sin {v}", "cancel")],
                 "final": rf"\sin {v}"},
                {"expr": rf"\frac{{1 + \tan^2 {v}}}{{\sec {v}}}",
                 "steps": [(rf"\frac{{\sec^2 {v}}}{{\sec {v}}}", "pyth_tan"),
                           (rf"\sec {v}", "cancel")],
                 "final": rf"\sec {v}"},
                {"expr": rf"\frac{{1 + \cot^2 {v}}}{{\csc {v}}}",
                 "steps": [(rf"\frac{{\csc^2 {v}}}{{\csc {v}}}", "pyth_cot"),
                           (rf"\csc {v}", "cancel")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\frac{{\sec {v}}}{{1 + \tan^2 {v}}}",
                 "steps": [(rf"\frac{{\sec {v}}}{{\sec^2 {v}}}", "pyth_tan"),
                           (rf"\frac{{1}}{{\sec {v}}}", "cancel"),
                           (rf"\cos {v}", "reciprocal_out")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\frac{{\csc {v}}}{{1 + \cot^2 {v}}}",
                 "steps": [(rf"\frac{{\csc {v}}}{{\csc^2 {v}}}", "pyth_cot"),
                           (rf"\frac{{1}}{{\csc {v}}}", "cancel"),
                           (rf"\sin {v}", "reciprocal_out")],
                 "final": rf"\sin {v}"},
                {"expr": rf"\left(\sec^2 {v} - 1\right) \cot {v}",
                 "steps": [(rf"\tan^2 {v} \cot {v}", "pyth_sec"),
                           (rf"\tan^2 {v} \cdot \frac{{1}}{{\tan {v}}}", "reciprocal"),
                           (rf"\tan {v}", "cancel")],
                 "final": rf"\tan {v}"},
                {"expr": rf"\left(\csc^2 {v} - 1\right) \tan {v}",
                 "steps": [(rf"\cot^2 {v} \tan {v}", "pyth_csc"),
                           (rf"\cot^2 {v} \cdot \frac{{1}}{{\cot {v}}}", "reciprocal"),
                           (rf"\cot {v}", "cancel")],
                 "final": rf"\cot {v}"},
                {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan {v}}}",
                 "steps": [(rf"\frac{{\tan^2 {v}}}{{\tan {v}}}", "pyth_sec"),
                           (rf"\tan {v}", "cancel")],
                 "final": rf"\tan {v}"},
                {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot {v}}}",
                 "steps": [(rf"\frac{{\cot^2 {v}}}{{\cot {v}}}", "pyth_csc"),
                           (rf"\cot {v}", "cancel")],
                 "final": rf"\cot {v}"},
            ],

            # ===== D: ratios/quotients of reciprocal & quotient functions =====
            "ratio_quotient": [
                {"expr": rf"\frac{{\tan {v}}}{{\sec {v}}} \csc {v}",
                 "steps": [(rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \cos {v} \cdot \csc {v}", "quotient_reciprocal"),
                           (rf"\sin {v} \cdot \frac{{1}}{{\sin {v}}}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\frac{{\cot {v}}}{{\csc {v}}} \sec {v}",
                 "steps": [(rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \sin {v} \cdot \sec {v}", "quotient_reciprocal"),
                           (rf"\cos {v} \cdot \frac{{1}}{{\cos {v}}}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\frac{{\sec {v}}}{{\tan {v}}} \cos {v}",
                 "steps": [(rf"\frac{{1}}{{\cos {v}}} \cdot \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}", "quotient_reciprocal"),
                           (rf"\frac{{1}}{{\sin {v}}} \cdot \cos {v}", "simplify"),
                           (rf"\frac{{\cos {v}}}{{\sin {v}}}", "simplify"),
                           (rf"\cot {v}", "quotient_out")],
                 "final": rf"\cot {v}"},
                {"expr": rf"\frac{{\csc {v}}}{{\cot {v}}} \sin {v}",
                 "steps": [(rf"\frac{{1}}{{\sin {v}}} \cdot \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}", "quotient_reciprocal"),
                           (rf"\frac{{1}}{{\cos {v}}} \cdot \sin {v}", "simplify"),
                           (rf"\frac{{\sin {v}}}{{\cos {v}}}", "simplify"),
                           (rf"\tan {v}", "quotient_out")],
                 "final": rf"\tan {v}"},
                {"expr": rf"\frac{{\sec {v} - \cos {v}}}{{\tan {v}}}",
                 "steps": [(rf"\frac{{\frac{{1}}{{\cos {v}}} - \cos {v}}}{{\frac{{\sin {v}}}{{\cos {v}}}}}", "quotient_reciprocal"),
                           (rf"\frac{{\frac{{1 - \cos^2 {v}}}{{\cos {v}}}}}{{\frac{{\sin {v}}}{{\cos {v}}}}}", "common_denominator"),
                           (rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", "pythagorean"),
                           (rf"\sin {v}", "cancel")],
                 "final": rf"\sin {v}"},
                {"expr": rf"\frac{{\csc {v} - \sin {v}}}{{\cot {v}}}",
                 "steps": [(rf"\frac{{\frac{{1}}{{\sin {v}}} - \sin {v}}}{{\frac{{\cos {v}}}{{\sin {v}}}}}", "quotient_reciprocal"),
                           (rf"\frac{{\frac{{1 - \sin^2 {v}}}{{\sin {v}}}}}{{\frac{{\cos {v}}}{{\sin {v}}}}}", "common_denominator"),
                           (rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", "pythagorean"),
                           (rf"\cos {v}", "cancel")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\frac{{\tan {v} \sin {v} + \cos {v}}}{{\sec {v}}}",
                 "steps": [(rf"\frac{{\frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v} + \cos {v}}}{{\frac{{1}}{{\cos {v}}}}}", "quotient_reciprocal"),
                           (rf"\frac{{\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}}}{{\frac{{1}}{{\cos {v}}}}}", "common_denominator"),
                           (rf"\frac{{\frac{{1}}{{\cos {v}}}}}{{\frac{{1}}{{\cos {v}}}}}", "pythagorean"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\frac{{\cot {v} \cos {v} + \sin {v}}}{{\csc {v}}}",
                 "steps": [(rf"\frac{{\frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v} + \sin {v}}}{{\frac{{1}}{{\sin {v}}}}}", "quotient_reciprocal"),
                           (rf"\frac{{\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}}}{{\frac{{1}}{{\sin {v}}}}}", "common_denominator"),
                           (rf"\frac{{\frac{{1}}{{\sin {v}}}}}{{\frac{{1}}{{\sin {v}}}}}", "pythagorean"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\frac{{\tan^2 {v} + 1}}{{\sec {v} \csc {v}}}",
                 "steps": [(rf"\frac{{\sec^2 {v}}}{{\sec {v} \csc {v}}}", "pyth_tan"),
                           (rf"\frac{{\sec {v}}}{{\csc {v}}}", "cancel"),
                           (rf"\frac{{\sin {v}}}{{\cos {v}}}", "quotient_reciprocal"),
                           (rf"\tan {v}", "quotient_out")],
                 "final": rf"\tan {v}"},
                {"expr": rf"\frac{{\cot^2 {v} + 1}}{{\csc {v} \sec {v}}}",
                 "steps": [(rf"\frac{{\csc^2 {v}}}{{\csc {v} \sec {v}}}", "pyth_cot"),
                           (rf"\frac{{\csc {v}}}{{\sec {v}}}", "cancel"),
                           (rf"\frac{{\cos {v}}}{{\sin {v}}}", "quotient_reciprocal"),
                           (rf"\cot {v}", "quotient_out")],
                 "final": rf"\cot {v}"},
                {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan {v} \sec {v}}}",
                 "steps": [(rf"\frac{{\tan^2 {v}}}{{\tan {v} \sec {v}}}", "pyth_sec"),
                           (rf"\frac{{\tan {v}}}{{\sec {v}}}", "cancel"),
                           (rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \cos {v}", "quotient_reciprocal"),
                           (rf"\sin {v}", "cancel")],
                 "final": rf"\sin {v}"},
                {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot {v} \csc {v}}}",
                 "steps": [(rf"\frac{{\cot^2 {v}}}{{\cot {v} \csc {v}}}", "pyth_csc"),
                           (rf"\frac{{\cot {v}}}{{\csc {v}}}", "cancel"),
                           (rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \sin {v}", "quotient_reciprocal"),
                           (rf"\cos {v}", "cancel")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\frac{{\sec {v} - \cos {v}}}{{\sin {v} \tan {v}}}",
                 "steps": [(rf"\frac{{\frac{{1}}{{\cos {v}}} - \cos {v}}}{{\sin {v} \cdot \frac{{\sin {v}}}{{\cos {v}}}}}", "quotient_reciprocal"),
                           (rf"\frac{{\frac{{1 - \cos^2 {v}}}{{\cos {v}}}}}{{\frac{{\sin^2 {v}}}{{\cos {v}}}}}", "common_denominator"),
                           (rf"\frac{{\sin^2 {v}}}{{\sin^2 {v}}}", "pythagorean"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\frac{{\csc {v} - \sin {v}}}{{\cos {v} \cot {v}}}",
                 "steps": [(rf"\frac{{\frac{{1}}{{\sin {v}}} - \sin {v}}}{{\cos {v} \cdot \frac{{\cos {v}}}{{\sin {v}}}}}", "quotient_reciprocal"),
                           (rf"\frac{{\frac{{1 - \sin^2 {v}}}{{\sin {v}}}}}{{\frac{{\cos^2 {v}}}{{\sin {v}}}}}", "common_denominator"),
                           (rf"\frac{{\cos^2 {v}}}{{\cos^2 {v}}}", "pythagorean"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
            ],

            # ===== E: even/odd identities (generated above) =====
            "even_odd": None,

            # ===== F: Pythagorean -> reciprocal, then cancel =====
            "pythagorean_reciprocal": [
                {"expr": rf"\left(1 + \tan^2 {v}\right) \cos {v}",
                 "steps": [(rf"\sec^2 {v} \cos {v}", "pyth_tan"),
                           (rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos {v}", "reciprocal"),
                           (rf"\frac{{1}}{{\cos {v}}}", "cancel"),
                           (rf"\sec {v}", "reciprocal_out")],
                 "final": rf"\sec {v}"},
                {"expr": rf"\left(1 + \cot^2 {v}\right) \sin {v}",
                 "steps": [(rf"\csc^2 {v} \sin {v}", "pyth_cot"),
                           (rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin {v}", "reciprocal"),
                           (rf"\frac{{1}}{{\sin {v}}}", "cancel"),
                           (rf"\csc {v}", "reciprocal_out")],
                 "final": rf"\csc {v}"},
                {"expr": rf"\sec^2 {v} \cos {v} - \tan {v} \sin {v}",
                 "steps": [(rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos {v} - \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}", "quotient_reciprocal"),
                           (rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin^2 {v}}}{{\cos {v}}}", "simplify"),
                           (rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", "pythagorean"),
                           (rf"\cos {v}", "cancel")],
                 "final": rf"\cos {v}"},
                {"expr": rf"\csc^2 {v} \sin {v} - \cot {v} \cos {v}",
                 "steps": [(rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin {v} - \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}", "quotient_reciprocal"),
                           (rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos^2 {v}}}{{\sin {v}}}", "simplify"),
                           (rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", "pythagorean"),
                           (rf"\sin {v}", "cancel")],
                 "final": rf"\sin {v}"},
            ],

            # ===== G: expressions that reduce to a constant =====
            "constants": [
                {"expr": rf"\sin {v} \csc {v}",
                 "steps": [(rf"\sin {v} \cdot \frac{{1}}{{\sin {v}}}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\cos {v} \sec {v}",
                 "steps": [(rf"\cos {v} \cdot \frac{{1}}{{\cos {v}}}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\tan {v} \cot {v}",
                 "steps": [(rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \frac{{\cos {v}}}{{\sin {v}}}", "quotient"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\sin^2 {v} + \cos^2 {v}",
                 "steps": [(rf"1", "pythagorean")],
                 "final": rf"1"},
                {"expr": rf"\sec^2 {v} - \tan^2 {v}",
                 "steps": [(rf"1", "pyth_sec")],
                 "final": rf"1"},
                {"expr": rf"\csc^2 {v} - \cot^2 {v}",
                 "steps": [(rf"1", "pyth_csc")],
                 "final": rf"1"},
                {"expr": rf"\left(1 + \tan^2 {v}\right) \cos^2 {v}",
                 "steps": [(rf"\sec^2 {v} \cos^2 {v}", "pyth_tan"),
                           (rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos^2 {v}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\left(1 + \cot^2 {v}\right) \sin^2 {v}",
                 "steps": [(rf"\csc^2 {v} \sin^2 {v}", "pyth_cot"),
                           (rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin^2 {v}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\sin^2 {v} \csc^2 {v}",
                 "steps": [(rf"\sin^2 {v} \cdot \frac{{1}}{{\sin^2 {v}}}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\cos^2 {v} \sec^2 {v}",
                 "steps": [(rf"\cos^2 {v} \cdot \frac{{1}}{{\cos^2 {v}}}", "reciprocal"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\left(\sec^2 {v} - 1\right) \cot^2 {v}",
                 "steps": [(rf"\tan^2 {v} \cot^2 {v}", "pyth_sec"),
                           (rf"\frac{{\sin^2 {v}}}{{\cos^2 {v}}} \cdot \frac{{\cos^2 {v}}}{{\sin^2 {v}}}", "quotient"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\left(\csc^2 {v} - 1\right) \tan^2 {v}",
                 "steps": [(rf"\cot^2 {v} \tan^2 {v}", "pyth_csc"),
                           (rf"\frac{{\cos^2 {v}}}{{\sin^2 {v}}} \cdot \frac{{\sin^2 {v}}}{{\cos^2 {v}}}", "quotient"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan^2 {v}}}",
                 "steps": [(rf"\frac{{\tan^2 {v}}}{{\tan^2 {v}}}", "pyth_sec"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
                {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot^2 {v}}}",
                 "steps": [(rf"\frac{{\cot^2 {v}}}{{\cot^2 {v}}}", "pyth_csc"),
                           (rf"1", "cancel")],
                 "final": rf"1"},
            ],
        }

        # Pick a family uniformly, then a problem uniformly within it.
        family = random.choice(list(families.keys()))
        if family == "even_odd":
            problem = even_odd_problem()
        else:
            problem = random.choice(families[family])

        steps = problem["steps"]

        # Build the outtro: name the identity used, then show the math.
        outtro_lines = []
        outtro_lines.append(
            "    <p>We simplify the expression step by step, naming the identity "
            "or technique used at each step.</p>"
        )

        for i, (step, code) in enumerate(steps[:-1], start=1):
            outtro_lines.append(f"    <p>Step {i}. {reason(code)}</p>")
            outtro_lines.append(f"    <p><m>{step}</m></p>")

        last_step, last_code = steps[-1]
        outtro_lines.append(f"    <p>Step {len(steps)}. {reason(last_code)}</p>")
        outtro_lines.append(
            f"    <p>Therefore the simplified expression is <m>\\boxed{{{last_step}}}</m>.</p>"
        )

        summary = identity_summary([code for _, code in steps])
        if summary:
            outtro_lines.append(                f"    <p>Identities used: {summary}. Compare this list with the "
                f"identities you typed before submitting, and note which step each one "
                f"appears in.</p>")

        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {
            "expr": problem["expr"],
            "outtro": outtro
        }
