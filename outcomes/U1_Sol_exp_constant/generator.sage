from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')

        base_choice = choice(['e', 2, 3, 4, 5])
        if base_choice == 'e':
            b_str = 'e'
            log_str = r"\ln"
            dot = ""
        else:
            b_str = str(base_choice)
            log_str = rf"\log_{{{base_choice}}}"
            dot = r" \cdot "

        while True:
            A = randint(2, 6) * choice([1, -1])
            E = randint(-9, 9)
            if E != 0:
                break

        H = randint(2, 19)
        F = A * H + E

        c = randint(2, 5)
        
        while True:
            d = randint(-9, 9)
            if d != 0:
                break

        p = c * x + d
        
        sign_E = f" + {E}" if E > 0 else f" - {abs(E)}"
        
        prob_eq = rf"{A}{dot}{b_str}^{{{latex(p)}}}{sign_E} = {F}"
        
        step1 = rf"{A}{dot}{b_str}^{{{latex(p)}}} = {A * H}"
        step2 = rf"{b_str}^{{{latex(p)}}} = {H}"
        step3 = rf"{latex(p)} = {log_str}({H})"
        
        opp_sign_d = f" - {d}" if d > 0 else f" + {abs(d)}"
        step4_rhs = rf"{log_str}({H}){opp_sign_d}"
        
        step4 = rf"{latex(c * x)} = {step4_rhs}"
        
        final_ans = rf"x = \frac{{{step4_rhs}}}{{{c}}}"

        return {
            "prob_eq": prob_eq,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "step4": step4,
            "final_ans": final_ans
        }