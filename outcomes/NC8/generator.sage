from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # Helper to beautifully format radians as LaTeX fractions
        def format_radian(val):
            if val == 0:
                return "0"
            
            frac = val / pi
            num = frac.numerator()
            den = frac.denominator()
            
            sign = "-" if frac < 0 else ""
            abs_num = abs(num)
            
            if abs_num == 1:
                num_str = r"\pi"
            else:
                num_str = rf"{abs_num}\pi"
                
            if den == 1:
                return rf"{sign}{num_str}"
            else:
                return rf"{sign}\frac{{{num_str}}}{{{den}}}"
                
        # Dictionary to map principal angles back to standard textbook LaTeX
        val_latex = {
            "sin": {
                -pi/2: r"-1", -pi/3: r"-\frac{\sqrt{3}}{2}", -pi/4: r"-\frac{\sqrt{2}}{2}", -pi/6: r"-\frac{1}{2}",
                0: "0",
                pi/6: r"\frac{1}{2}", pi/4: r"\frac{\sqrt{2}}{2}", pi/3: r"\frac{\sqrt{3}}{2}", pi/2: r"1"
            },
            "cos": {
                0: "1",
                pi/6: r"\frac{\sqrt{3}}{2}", pi/4: r"\frac{\sqrt{2}}{2}", pi/3: r"\frac{1}{2}",
                pi/2: "0",
                2*pi/3: r"-\frac{1}{2}", 3*pi/4: r"-\frac{\sqrt{2}}{2}", 5*pi/6: r"-\frac{\sqrt{3}}{2}",
                pi: "-1"
            },
            "tan": {
                -pi/3: r"-\sqrt{3}", -pi/4: r"-1", -pi/6: r"-\frac{\sqrt{3}}{3}",
                0: "0",
                pi/6: r"\frac{\sqrt{3}}{3}", pi/4: r"1", pi/3: r"\sqrt{3}"
            }
        }
        
        # Select the two inverse trigonometric functions
        f1 = random.choice(["sin", "cos", "tan"])
        f2 = random.choice(["sin", "cos", "tan"])
        
        # Select valid principal angles
        theta1 = random.choice(list(val_latex[f1].keys()))
        theta2 = random.choice(list(val_latex[f2].keys()))
        
        # Determine the operator connecting the two inverse functions
        op = random.choice(["+", "-"])
        
        if op == "+":
            C = theta1 + theta2
        else:
            C = theta1 - theta2
            
        C_tex = format_radian(C)
        t1_tex = format_radian(theta1)
        t2_tex = format_radian(theta2)
        
        v1_tex = val_latex[f1][theta1]
        v2_tex = val_latex[f2][theta2]
        
        # Construct Left Hand Side (LHS)
        f2_term = rf"\{f2}^{{-1}}\left({v2_tex}\right)"
        lhs_latex = rf"\{f1}^{{-1}}(x) {op} {f2_term}"
        
        # Construct Right Hand Side (RHS)
        rhs_latex = C_tex
        
        # Step 1: Isolate the unknown inverse function and evaluate the known one
        if op == '+':
            if theta2 < 0:
                step1 = rf"\{f1}^{{-1}}(x) = {C_tex} + {format_radian(-theta2)}"
            else:
                step1 = rf"\{f1}^{{-1}}(x) = {C_tex} - {t2_tex}"
        else:
            if theta2 < 0:
                step1 = rf"\{f1}^{{-1}}(x) = {C_tex} - {format_radian(-theta2)}"
            else:
                step1 = rf"\{f1}^{{-1}}(x) = {C_tex} + {t2_tex}"
                
        # Step 2: Perform the arithmetic
        step2 = rf"\{f1}^{{-1}}(x) = {t1_tex}"
        
        # Step 3: Apply the standard trigonometric function to isolate x
        step3 = rf"x = \{f1}\left({t1_tex}\right)"
        
        # Final explicit answer
        final_sol = rf"\boxed{{x = {v1_tex}}}"
        
        outtro_lines = [
            f"    <p><m>{step1}</m></p>",
            f"    <p><m>{step2}</m></p>",
            f"    <p><m>{step3}</m></p>",
            f"    <p><m>{final_sol}</m></p>"
        ]
        
        # We now only return the inner HTML blocks, not the <outtro> tags themselves
        solution_steps = "\n".join(outtro_lines)
        
        return {
            "lhs": lhs_latex,
            "rhs": rhs_latex,
            "solution_steps": solution_steps
        }