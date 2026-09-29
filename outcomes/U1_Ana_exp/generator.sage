from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        A = choice([-3, -2, -1, 1, 2, 3])
        b_val = choice([2, 3, 4, 5, 'e'])
        C = randint(-5, 5)
        D = randint(-5, 5)
        
        b_str = 'e' if b_val == 'e' else str(b_val)
        
        if C > 0:
            exp_str = f"x - {C}"
        elif C < 0:
            exp_str = f"x + {-C}"
        else:
            exp_str = "x"
            
        term = rf"{b_str}^{{{exp_str}}}"
        
        if A == 1:
            A_str = ""
        elif A == -1:
            A_str = "-"
        else:
            A_str = rf"{A} \cdot " if b_val != 'e' else str(A)
            
        if D > 0:
            D_str = f" + {D}"
        elif D < 0:
            D_str = f" - {-D}"
        else:
            D_str = ""
            
        if choice([True, False]) and D != 0:
            if A == 1:
                f_expr = rf"{D} + {term}"
            elif A == -1:
                f_expr = rf"{D} - {term}"
            else:
                dot = r" \cdot " if b_val != 'e' else ""
                f_expr = rf"{D} {'+' if A > 0 else '-'} {abs(A)}{dot}{term}"
        else:
            f_expr = rf"{A_str}{term}{D_str}"
            
        domain_ans = r"(-\infty, \infty)"
        
        if A > 0:
            range_ans = rf"({D}, \infty)"
        else:
            range_ans = rf"(-\infty, {D})"
            
        asym_ans = rf"y = {D}"
        
        return {
            "f_expr": f_expr,
            "domain_ans": domain_ans,
            "range_ans": range_ans,
            "asym_ans": asym_ans
        }