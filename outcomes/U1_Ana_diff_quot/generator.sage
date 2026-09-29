from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x, h = var('x h')

        # 1. Define Function parameters
        # f(x) = ax^2 + bx + c
        # Constraint: a is non-zero, widened ranges for retake variety
        a = randint(-6, 6)
        while a == 0:
            a = randint(-6, 6)
        b = randint(-9, 9)
        c = randint(-9, 9)
        
        f_expr = a * x**2 + b * x + c
        f_tex = r"f(x) = " + latex(f_expr)

        # 2. Step-by-Step Construction
        
        # Step 1: Find f(x+h)
        step1_sub = f"{a}(x+h)^2"
        if b > 0: 
            step1_sub += f" + {b}(x+h)"
        elif b < 0: 
            step1_sub += f" - {abs(b)}(x+h)"
        
        if c > 0: 
            step1_sub += f" + {c}"
        elif c < 0: 
            step1_sub += f" - {abs(c)}"
        
        # Step 2: Expand the binomial
        step2_expand = f"{a}(x^2 + 2xh + h^2)"
        if b > 0: 
            step2_expand += f" + {b}x + {b}h"
        elif b < 0: 
            step2_expand += f" - {abs(b)}x - {abs(b)}h"
        
        if c > 0: 
            step2_expand += f" + {c}"
        elif c < 0: 
            step2_expand += f" - {abs(c)}"
        
        # Step 3: Distribute
        dist_poly = a*x**2 + 2*a*x*h + a*h**2 + b*x + b*h + c
        step3_dist = latex(dist_poly)
        
        # Step 4: Numerator Setup (show subtraction)
        step4_num = r"\frac{(" + step3_dist + r") - (" + latex(f_expr) + r")}{h}"
        
        # Step 5: Simplify Numerator
        num_simp_poly = 2*a*x*h + a*h**2 + b*h
        step5_simp = r"\frac{" + latex(num_simp_poly) + r"}{h}"
        
        # Step 6: Factor out h
        inner_factor = 2*a*x + a*h + b
        step6_factor = r"\frac{h(" + latex(inner_factor) + r")}{h}"
        
        # Step 7: Final Answer
        final_ans = latex(inner_factor)

        return {
            "f_tex": f_tex,
            "step1_sub": step1_sub,
            "step2_expand": step2_expand,
            "step3_dist": step3_dist,
            "step4_num": step4_num,
            "step5_simp": step5_simp,
            "step6_factor": step6_factor,
            "final_ans": final_ans
        }