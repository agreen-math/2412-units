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
        v = random.choice(["x", r"\theta", "t"])

        def reason(code):
            return REASONS[code].replace("{v}", v)

        # ===== F: Pythagorean -> reciprocal, then cancel =====
        problems = [
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
        ]

        problem = random.choice(problems)
        steps = problem["steps"]

        # (identical outtro-assembly block)
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
            outtro_lines.append(
                f"    <p>Identities used: {summary}. Compare this list with the "
                f"identities you typed before submitting, and note which step each one "
                f"appears in.</p>"
            )

        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {
            "expr": problem["expr"],
            "outtro": outtro
        }
