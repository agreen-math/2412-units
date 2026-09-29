from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        b_val = choice([2, 3, 4, 5, 'e'])
        b_str = 'e' if b_val == 'e' else str(b_val)

        while True:
            c1 = randint(-6, 6)
            c2 = randint(-6, 6)
            c3 = randint(-6, 6)
            
            # Ensure the x coefficients do not cancel out to 0
            if c1 + c2 != c3 and (c1 != 0 or c2 != 0 or c3 != 0):
                break

        d1 = randint(-9, 9)
        d2 = randint(-9, 9)
        d3 = randint(-9, 9)

        p1 = c1*x + d1
        p2 = c2*x + d2
        p3 = c3*x + d3

        p1_tex = "0" if p1 == 0 else latex(p1)
        p2_tex = "0" if p2 == 0 else latex(p2)
        p3_tex = "0" if p3 == 0 else latex(p3)

        prob_eq = rf"{b_str}^{{{p1_tex}}} \cdot {b_str}^{{{p2_tex}}} = {b_str}^{{{p3_tex}}}"

        sum_p = p1 + p2
        sum_tex = latex(sum_p)
        step1 = rf"{b_str}^{{{sum_tex}}} = {b_str}^{{{p3_tex}}}"

        step2 = rf"{sum_tex} = {p3_tex}"

        cx = c1 + c2 - c3
        cd = d3 - d1 - d2
        
        # Use latex(cx * x) to ensure formatting like -x instead of -1x
        step3 = rf"{latex(cx * x)} = {cd}"

        ans = Integer(cd) / Integer(cx)
        final_ans = rf"x = {latex(ans)}"

        return {
            "prob_eq": prob_eq,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "final_ans": final_ans
        }