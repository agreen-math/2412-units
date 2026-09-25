from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # Select the trigonometric function
        func_str = random.choice(["sin", "cos"])

        # Generate a non-standard rational ratio between -1 and 1
        valid_ratio = False
        while not valid_ratio:
            # A is the coefficient of the trigonometric function
            A = random.choice([2, 3, 4, 5, 6])
            
            # D is the denominator of the constant term
            D = random.choice([2, 3, 4, 5])
            
            # C is the numerator of the constant term
            max_num = A * D - 1
            if max_num < 1:
                continue
                
            C = random.choice(list(range(1, max_num + 1)))
            sign = random.choice([-1, 1])
            C = C * sign

            denom = A * D
            
            # Prevent standard unit circle values (like +/- 1/2) 
            # to guarantee calculator necessity
            if C * 2 == denom or C * 2 == -denom:
                continue
                
            valid_ratio = True

        # Construct the Left Hand Side (LHS)
        if A == 1:
            lhs_latex = rf"\{func_str} \theta"
        elif A == -1:
            lhs_latex = rf"-\{func_str} \theta"
        else:
            lhs_latex = rf"{A} \{func_str} \theta"

        # Construct the Right Hand Side (RHS)
        if D == 1:
            rhs_latex = rf"{C}"
        else:
            frac = Integer(C) / Integer(D)
            rhs_latex = latex(frac)

        # Step 1: Isolate the trigonometric function
        final_ratio = Integer(C) / Integer(denom)
        step1 = rf"\{func_str} \theta = {latex(final_ratio)}"

        # Step 2: Establish the inverse trigonometric relationship
        step2 = rf"\theta = \{func_str}^{{-1}}\left({latex(final_ratio)}\right)"

        # Step 3 & 4: Calculator evaluation and symmetry calculation
        ratio_float = float(final_ratio)
        if func_str == "sin":
            inv_rad = arcsin(ratio_float)
        else:
            inv_rad = arccos(ratio_float)

        inv_deg = float(inv_rad * 180 / pi)
        step3 = rf"\theta \approx {round(inv_deg, 4)}^\circ \dots"

        calc_steps = []
        if func_str == "sin":
            if inv_deg >= 0:
                ans1 = inv_deg
                ans2 = 180.0 - inv_deg
                calc_steps.append(rf"180^\circ - {round(inv_deg, 4)}^\circ \approx {round(ans2, 4)}^\circ")
            else:
                ans1 = 180.0 - inv_deg
                ans2 = 360.0 + inv_deg
                calc_steps.append(rf"180^\circ - ({round(inv_deg, 4)}^\circ) \approx {round(ans1, 4)}^\circ")
                calc_steps.append(rf"360^\circ + ({round(inv_deg, 4)}^\circ) \approx {round(ans2, 4)}^\circ")
        else: 
            ans1 = inv_deg
            ans2 = 360.0 - inv_deg
            calc_steps.append(rf"360^\circ - {round(inv_deg, 4)}^\circ \approx {round(ans2, 4)}^\circ")

        # Sort the answers to appear sequentially 
        ans_list = sorted([ans1, ans2])
        step4 = r" \text{ and } ".join(calc_steps)

        # Final Box formatting
        ans1_rnd = round(ans_list[0], 1)
        ans2_rnd = round(ans_list[1], 1)
        final_sol = rf"\boxed{{\theta = {ans1_rnd}^\circ, {ans2_rnd}^\circ}}"

        # Assemble outtro utilizing the Zero-Text Rule
        outtro_lines = [
            f"    <p><m>{step1}</m></p>",
            f"    <p><m>{step2}</m></p>",
            f"    <p><m>{step3}</m></p>"
        ]
        if step4:
            outtro_lines.append(f"    <p><m>{step4}</m></p>")
            
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")

        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {
            "lhs": lhs_latex,
            "rhs": rhs_latex,
            "outtro": outtro
        }