from sage.all import *
from random import choice, sample

class Generator(BaseGenerator):
    def data(self):
        x = var('x')

        r1, r2, r3 = sample([i for i in range(-6, 7) if i != 0], 3)
        a = choice([1, -1])

        if a == 1:
            linear_factor = x - r1
        else:
            linear_factor = r1 - x

        quad_factor = expand((x - r2) * (x - r3))
        full_poly = expand(linear_factor * quad_factor)

        prob_eq = rf"{latex(full_poly)} = 0"
        hint_eq = rf"{latex(full_poly)} = ({latex(linear_factor)})({latex(quad_factor)})"

        step1 = rf"({latex(linear_factor)})({latex(quad_factor)}) = 0"
        
        fac2 = x - r2
        fac3 = x - r3
        step2 = rf"({latex(linear_factor)})({latex(fac2)})({latex(fac3)}) = 0"
        
        step3 = rf"{latex(linear_factor)} = 0, \quad {latex(fac2)} = 0, \quad {latex(fac3)} = 0"

        roots_sorted = sorted([r1, r2, r3])
        final_ans = rf"x = {roots_sorted[0]}, \quad x = {roots_sorted[1]}, \quad x = {roots_sorted[2]}"

        return {
            "prob_eq": prob_eq,
            "hint_eq": hint_eq,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "final_ans": final_ans
        }