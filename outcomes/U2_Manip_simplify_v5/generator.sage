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

        # ===== E: even/odd identities, generated programmatically so the sign
        # (and which factor carries the negated argument) is randomized. =====
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
            expr = rf"\{negated}(-{v}) \{other} {v}"

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
                steps.append((rf"-\{negated} {v} \cdot \{other} {v}", "even_odd"))
            else:
                steps.append((rf"\{negated} {v} \cdot \{other} {v}", "even_odd"))
            steps.append((sign + forms[negated] + r" \cdot " + forms[other], rewrite_code))
            steps.append((sign + cancelled, "simplify"))
            if final != cancelled:
                out_code = "quotient_out" if final in ("tan", "cot") else "reciprocal_out"
                steps.append((sign + final, out_code))

            return {"expr": expr, "steps": steps, "final": sign + final}

        problem = even_odd_problem()
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
