from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # Choose a variable
        v = random.choice(["x", r"\theta", "t", r"\alpha"])

        # The 3 standard identities for cos(2x) found on formula charts
        cos2_forms = [
            rf"\cos^2({v}) - \sin^2({v})",
            rf"2\cos^2({v}) - 1",
            rf"1 - 2\sin^2({v})"
        ]
        cos2_expr = random.choice(cos2_forms)

        # The "sneaky" identity for sin(2x)
        sin2_expr = rf"2\sin({v})\cos({v})"

        # Randomly select whether we are verifying tan(2x) or cot(2x)
        func_type = random.choice(["cot", "tan"])

        if func_type == "cot":
            messy_latex = rf"\frac{{{cos2_expr}}}{{{sin2_expr}}}"
            clean_latex = rf"\cot(2{v})"
            step2 = rf"= \frac{{\cos(2{v})}}{{\sin(2{v})}}"
        else:
            messy_latex = rf"\frac{{{sin2_expr}}}{{{cos2_expr}}}"
            clean_latex = rf"\tan(2{v})"
            step2 = rf"= \frac{{\sin(2{v})}}{{\cos(2{v})}}"

        # Randomize the display order of the equation in the prompt
        if random.choice([True, False]):
            eq_latex = rf"{clean_latex} = {messy_latex}"
        else:
            eq_latex = rf"{messy_latex} = {clean_latex}"

        # Build the steps starting from the messy side
        step1 = messy_latex
        step3 = rf"= \boxed{{{clean_latex}}}"

        # Assemble the outtro using the Zero-Text Rule
        outtro = (
            f"<outtro>\n"
            f"    <p><m>{step1}</m></p>\n"
            f"    <p><m>{step2}</m></p>\n"
            f"    <p><m>{step3}</m></p>\n"
            f"</outtro>"
        )

        return {
            "eq": eq_latex,
            "outtro": outtro
        }