from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        A = choice([-3, -2, -1, 1, 2, 3])
        b_val = choice([2, 3, 4, 5, 'e'])
        C = randint(-5, 5)
        D = randint(-5, 5)
        
        log_str = r"\ln" if b_val == 'e' else rf"\log_{{{b_val}}}"
            
        if C > 0:
            arg_str = f"(x - {C})"
        elif C < 0:
            arg_str = f"(x + {-C})"
        else:
            arg_str = "(x)"
            
        if A == 1:
            A_str = ""
        elif A == -1:
            A_str = "-"
        else:
            A_str = str(A)
            
        if D > 0:
            D_str = f" + {D}"
        elif D < 0:
            D_str = f" - {-D}"
        else:
            D_str = ""
            
        if choice([True, False]) and D != 0:
            if A == 1:
                f_expr = rf"{D} + {log_str}{arg_str}"
            elif A == -1:
                f_expr = rf"{D} - {log_str}{arg_str}"
            else:
                f_expr = rf"{D} {'+' if A > 0 else '-'} {abs(A)}{log_str}{arg_str}"
        else:
            f_expr = rf"{A_str}{log_str}{arg_str}{D_str}"
            
        domain_ans = rf"({C}, \infty)"
        range_ans = r"(-\infty, \infty)"
        asym_ans = rf"x = {C}"
        
        return {
            "f_expr": f_expr,
            "domain_ans": domain_ans,
            "range_ans": range_ans,
            "asym_ans": asym_ans
        }