from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')

        # 1. Reverse-engineer the quadratic to ensure one valid and one extraneous root
        while True:
            r1 = randint(1, 9)          # Valid root
            c = randint(-5, 5)          # Argument 1 shift
            if c <= -r1: 
                continue                # Ensure (r1 + c) > 0
            
            r2 = randint(-9, -1)        # Extraneous root candidate
            if r2 >= -c: 
                continue                # Ensure (r2 + c) < 0 so it fails the domain check
            
            d = -r1 - r2 - c            # Force the linear coefficient: c + d = -(r1 + r2)
            R = c * d - r1 * r2         # Force the constant term
            
            if R > 0:                   # Log argument must be positive
                break

        # 2. Select logarithm base
        base_choice = choice(['ln', 2, 3, 4, 5, 6])
        if base_choice == 'ln':
            log_str = r"\ln"
        else:
            log_str = rf"\log_{{{base_choice}}}"

        # 3. Construct expressions
        arg1 = x + c
        arg2 = x + d
        
        # Format parentheses cleanly (e.g., x instead of (x) if c=0)
        p1_str = f"({latex(arg1)})" if c != 0 else "x"
        p2_str = f"({latex(arg2)})" if d != 0 else "x"

        prob_eq = rf"{log_str}{p1_str} + {log_str}{p2_str} = {log_str}({R})"

        # 4. Step-by-Step Solution Construction
        step1 = rf"{log_str}({p1_str}{p2_str}) = {log_str}({R})"
        step2 = rf"{p1_str}{p2_str} = {R}"

        expanded_lhs = x**2 + (c+d)*x + c*d
        step3 = rf"{latex(expanded_lhs)} = {R}"

        quad_expr = x**2 + (c+d)*x + (c*d - R)
        step4 = rf"{latex(quad_expr)} = 0"

        factor1 = x - r1
        factor2 = x - r2
        step5 = rf"({latex(factor1)})({latex(factor2)}) = 0"

        step6 = rf"x = {r1}, \quad x = {r2}"
        final_ans = rf"x = {r1}"

        return {
            "prob_eq": prob_eq,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "step4": step4,
            "step5": step5,
            "step6": step6,
            "final_ans": final_ans
        }