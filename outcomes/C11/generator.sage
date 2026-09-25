from sage.all import *
from random import choice, shuffle

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        parts = []
        
        # --- Radical with perfect square ---
        c1 = choice([i for i in range(-8, 9) if i != 0])
        # Ensure the radical evaluates to a non-zero perfect square
        k = choice([i for i in range(-5, 6) if i != 0 and i != -c1])
        
        expr_a_inside = x**2 + 2*k*x + k**2
        ans_a = abs(c1 + k)
        c1_str = f"({c1})" if c1 < 0 else str(c1)
        
        lim_a = rf"\displaystyle \lim_{{x \to {c1_str}}} \sqrt{{{latex(expr_a_inside)}}}"
        eval_a = rf"\sqrt{{{latex(expr_a_inside(x=c1))}}}"
        sol_a = rf"{lim_a} = {eval_a} = {latex(ans_a)}"
        
        parts.append({"lim": lim_a, "sol": sol_a})
        
        # --- Rational requiring factoring ---
        c2 = choice([i for i in range(-7, 8) if i != 0])
        # Ensure p does not cancel the difference of squares perfectly
        p = choice([i for i in range(-9, 10) if i not in [c2, -c2]])
        
        num_b = x**2 + (p - c2)*x - c2*p
        den_b = x**2 - c2**2
        
        ans_b = (Integer(c2) + Integer(p)) / (Integer(2) * Integer(c2))
        c2_str = f"({c2})" if c2 < 0 else str(c2)
        
        lim_b = rf"\displaystyle \lim_{{x \to {c2_str}}} \frac{{{latex(num_b)}}}{{{latex(den_b)}}}"
        
        # Hardcoding the factored string prevents Sage from automatically expanding it
        num_b_factored_str = rf"({latex(x - c2)})({latex(x + p)})"
        den_b_factored_str = rf"({latex(x - c2)})({latex(x + c2)})"
        step1_b = rf"\displaystyle \lim_{{x \to {c2_str}}} \frac{{{num_b_factored_str}}}{{{den_b_factored_str}}}"
        step2_b = rf"\displaystyle \lim_{{x \to {c2_str}}} \frac{{{latex(x + p)}}}{{{latex(x + c2)}}}"
        sol_b = rf"{lim_b} = {step1_b} = {step2_b} = {latex(ans_b)}"
        
        parts.append({"lim": lim_b, "sol": sol_b})
        
        # --- Rational with direct substitution ---
        c3 = choice([i for i in range(-6, 7)])
        c3_str = f"({c3})" if c3 < 0 else str(c3)
        
        # Ensure the denominator does not evaluate to zero at c3
        d = choice([i for i in range(-5, 6) if i != 0 and i != -c3])
        num_c = x**2 + choice([-4, -3, -2, 2, 3, 4])*x + choice([-5, -4, 4, 5])
        den_c = x + d
        
        ans_c = Integer(num_c(x=c3)) / Integer(den_c(x=c3))
        
        lim_c = rf"\displaystyle \lim_{{x \to {c3_str}}} \frac{{{latex(num_c)}}}{{{latex(den_c)}}}"
        eval_c = rf"\frac{{{latex(num_c(x=c3))}}}{{{latex(den_c(x=c3))}}}"
        sol_c = rf"{lim_c} = {eval_c} = {latex(ans_c)}"
        
        parts.append({"lim": lim_c, "sol": sol_c})
        
        # Shuffle the order of the limits
        shuffle(parts)

        return {
            "parts": parts
        }