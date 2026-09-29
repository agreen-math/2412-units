from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        A, B = var('A B')

        while True:
            r1 = randint(-6, 6)
            r2 = randint(-6, 6)
            if r1 != r2:
                break

        while True:
            ans_A = randint(-9, 9)
            ans_B = randint(-9, 9)
            if ans_A != 0 and ans_B != 0:
                break

        fac1 = x - r1
        fac2 = x - r2
        
        denom = expand(fac1 * fac2)
        num = expand(ans_A * fac2 + ans_B * fac1)

        prob_eq = rf"\frac{{{latex(num)}}}{{{latex(denom)}}} = \frac{{A}}{{{latex(fac1)}}} + \frac{{B}}{{{latex(fac2)}}}"

        step1 = rf"{latex(num)} = A({latex(fac2)}) + B({latex(fac1)})"
        
        step2_lhs = num(x=r2)
        step2_rhs = fac1(x=r2) * B
        step2 = rf"x = {r2} \implies {latex(step2_lhs)} = {latex(step2_rhs)} \implies B = {ans_B}"
        
        step3_lhs = num(x=r1)
        step3_rhs = fac2(x=r1) * A
        step3 = rf"x = {r1} \implies {latex(step3_lhs)} = {latex(step3_rhs)} \implies A = {ans_A}"
        
        final_ans = rf"A = {ans_A}, \quad B = {ans_B}"

        return {
            "prob_eq": prob_eq,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "final_ans": final_ans
        }