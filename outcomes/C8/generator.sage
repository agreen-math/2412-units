from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # SSA ambiguous case: guaranteed two triangles
        A = Integer(random.randint(25, 40))  
        
        # Generate realistic floats for sides (rounded to 1 decimal place)
        b = round(random.uniform(10.0, 14.0), 1)

        # Force ambiguous case: b*sin(A) < a < b
        lower = float(b * sin(A * pi / Integer(180)))
        a = round(random.uniform(lower + 0.5, b - 0.5), 1)

        # Law of Sines to find the first angle (B1)
        sinB = float(b * sin(A * pi / Integer(180)) / a)
        B1 = float(asin(sinB) * Integer(180) / pi)
        
        # Calculate theoretical second angle and sum check
        B2 = 180.0 - B1
        sum_check = A + B2

        # Triangle 1 parameters
        C1 = 180.0 - A - B1
        c1 = float(a * sin(C1 * pi / Integer(180)) / sin(A * pi / Integer(180)))

        # Triangle 2 parameters
        C2 = 180.0 - A - B2
        c2 = float(a * sin(C2 * pi / Integer(180)) / sin(A * pi / Integer(180)))

        # Format solutions mathematically to adhere to the requested rounding rules
        B1_format = f"{B1:.1f}"
        B2_format = f"{B2:.1f}"
        sum_format = f"{sum_check:.1f}"
        C1_format = f"{C1:.1f}"
        c1_format = f"{c1:.2f}"
        C2_format = f"{C2:.1f}"
        c2_format = f"{c2:.2f}"

        # --- Build Step-by-Step Solution ---
        # Note: All English narrative is omitted to comply with the Zero-Text Rule
        
        step1 = r"\frac{\sin(B)}{b} = \frac{\sin(A)}{a}"
        step2 = rf"\sin(B) = \frac{{{b}\sin({A}^\circ)}}{{{a}}} \approx {sinB:.4f}"
        step3 = rf"B_1 = \sin^{{-1}}({sinB:.4f}) \approx {B1_format}^\circ"
        
        step4 = rf"B_2 = 180^\circ - {B1_format}^\circ = {B2_format}^\circ"
        step5 = rf"{A}^\circ + {B2_format}^\circ = {sum_format}^\circ &lt; 180^\circ"

        step6 = rf"C_1 = 180^\circ - {A}^\circ - {B1_format}^\circ = {C1_format}^\circ"
        step7 = r"c_1 = \frac{a\sin(C_1)}{\sin(A)}"
        step8 = rf"c_1 = \frac{{{a}\sin({C1_format}^\circ)}}{{\sin({A}^\circ)}} \approx {c1_format}"

        step9 = rf"C_2 = 180^\circ - {A}^\circ - {B2_format}^\circ = {C2_format}^\circ"
        step10 = r"c_2 = \frac{a\sin(C_2)}{\sin(A)}"
        step11 = rf"c_2 = \frac{{{a}\sin({C2_format}^\circ)}}{{\sin({A}^\circ)}} \approx {c2_format}"

        # Format the final boxed summaries using an aligned environment to mimic a table
        # We must use &amp; instead of & to prevent XML parsing errors in SpaTeXt
        final_sol_1 = (
            rf"\boxed{{\begin{{aligned}} "
            rf"A &amp;= {A}^\circ &amp; a &amp;= {a} \\ "
            rf"B_1 &amp;\approx {B1_format}^\circ &amp; b &amp;= {b} \\ "
            rf"C_1 &amp;\approx {C1_format}^\circ &amp; c_1 &amp;\approx {c1_format} "
            rf"\end{{aligned}}}}"
        )
        
        final_sol_2 = (
            rf"\boxed{{\begin{{aligned}} "
            rf"A &amp;= {A}^\circ &amp; a &amp;= {a} \\ "
            rf"B_2 &amp;\approx {B2_format}^\circ &amp; b &amp;= {b} \\ "
            rf"C_2 &amp;\approx {C2_format}^\circ &amp; c_2 &amp;\approx {c2_format} "
            rf"\end{{aligned}}}}"
        )

        outtro_lines = [
            f"    <p><m>{step1}</m></p>",
            f"    <p><m>{step2}</m></p>",
            f"    <p><m>{step3}</m></p>",
            f"    <p><m>{step4}</m></p>",
            f"    <p><m>{step5}</m></p>",
            f"    <p><m>{step6}</m></p>",
            f"    <p><m>{step7}</m></p>",
            f"    <p><m>{step8}</m></p>",
            f"    <p><m>{step9}</m></p>",
            f"    <p><m>{step10}</m></p>",
            f"    <p><m>{step11}</m></p>",
            f"    <p><m>{final_sol_1}</m></p>",
            f"    <p><m>{final_sol_2}</m></p>"
        ]
        
        solution_steps = "\n".join(outtro_lines)

        return {
            "A": A,
            "a": a,
            "b": b,
            "solution_steps": solution_steps
        }