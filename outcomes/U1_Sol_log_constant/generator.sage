from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        while True:
            b_val = randint(2, 6)
            k_val = randint(1, 2)
            R = b_val**k_val
            
            c = randint(-9, 9)
            d = randint(-9, 9)
            if c == d: 
                continue
            
            B = c + d
            C = c * d - R
            disc = B**2 - 4*C
            
            if disc < 0: 
                continue
            if not Integer(disc).is_square(): 
                continue
            
            sq = Integer(disc).sqrt()
            if (B + sq) % 2 != 0: 
                continue
            
            r1 = (-B + sq) // 2
            r2 = (-B - sq) // 2
            
            r1_valid = (r1 + c > 0) and (r1 + d > 0)
            r2_valid = (r2 + c > 0) and (r2 + d > 0)
            
            if r1_valid and not r2_valid:
                sol = r1
                ext = r2
                break
            elif r2_valid and not r1_valid:
                sol = r2
                ext = r1
                break
        
        log_str = rf"\log_{{{b_val}}}"
        
        arg1 = x + c
        arg2 = x + d
        p1_str = f"({latex(arg1)})" if c != 0 else "x"
        p2_str = f"({latex(arg2)})" if d != 0 else "x"
        
        prob_eq = rf"{log_str}{p1_str} + {log_str}{p2_str} = {k_val}"
        
        step1 = rf"{log_str}({p1_str}{p2_str}) = {k_val}"
        step2 = rf"{p1_str}{p2_str} = {b_val}^{{{k_val}}}"
        
        expanded_lhs = x**2 + B*x + c*d
        step3 = rf"{latex(expanded_lhs)} = {R}"
        
        quad_expr = x**2 + B*x + C
        step4 = rf"{latex(quad_expr)} = 0"
        
        factor1 = x - sol
        factor2 = x - ext
        step5 = rf"({latex(factor1)})({latex(factor2)}) = 0"
        
        step6 = rf"x = {sol}, \quad x = {ext}"
        
        final_ans = rf"\boxed{{x = {sol}}} \quad \text{{(Extraneous: }} x = {ext} \text{{)}}"
        
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