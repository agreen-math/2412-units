from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')

        # Helper formatting functions to strictly manage LaTeX string construction
        def fmt_cx(c):
            if c == 1: return "x"
            if c == -1: return "-x"
            return f"{c}x"

        def fmt_cln(c, base, absolute=False):
            val = abs(c) if absolute else c
            if val == 1: return rf"\ln({base})"
            if val == -1: return rf"-\ln({base})"
            return rf"{val}\ln({base})"

        def fmt_clog(c, base_arg, base_sub, absolute=False):
            val = abs(c) if absolute else c
            log_str = rf"\log_{{{base_sub}}}({base_arg})"
            if val == 1: return log_str
            if val == -1: return rf"-{log_str}"
            return rf"{val}{log_str}"

        def fmt_c(c, absolute=False):
            val = abs(c) if absolute else c
            if val == 1: return ""
            if val == -1: return "-"
            return str(val)

        # 1. Select distinct prime bases to guarantee mismatch and prevent rational reduction
        bases = [2, 3, 5, 7, 11]
        b1 = choice(bases)
        b2 = choice(bases)
        while b1 == b2:
            b2 = choice(bases)

        # 2. Select non-zero coefficients
        while True:
            c1 = randint(-6, 6)
            c2 = randint(-6, 6)
            d1 = randint(-9, 9)
            d2 = randint(-9, 9)
            
            # Ensure full binomials and no zero-cancellation
            if c1 != 0 and c2 != 0 and d1 != 0 and d2 != 0 and c1 != c2:
                break

        p1 = c1*x + d1
        p2 = c2*x + d2

        prob_eq = rf"{b1}^{{{latex(p1)}}} = {b2}^{{{latex(p2)}}}"

        # 3. Step-by-Step Construction
        
        # Step 1: Take ln of both sides
        step1 = rf"\ln\left({b1}^{{{latex(p1)}}}\right) = \ln\left({b2}^{{{latex(p2)}}}\right)"

        # Step 2: Power rule
        step2 = rf"({latex(p1)})\ln({b1}) = ({latex(p2)})\ln({b2})"

        # Step 3: Distribute
        sign_d1 = " + " if d1 > 0 else " - "
        sign_d2 = " + " if d2 > 0 else " - "
        lhs_dist = rf"{fmt_cx(c1)}\ln({b1}){sign_d1}{fmt_cln(d1, b1, True)}"
        rhs_dist = rf"{fmt_cx(c2)}\ln({b2}){sign_d2}{fmt_cln(d2, b2, True)}"
        step3 = rf"{lhs_dist} = {rhs_dist}"

        # Step 4: Isolate x terms
        opp_sign_c2 = " - " if c2 > 0 else " + "
        opp_sign_d1 = " - " if d1 > 0 else " + "
        lhs_iso = rf"{fmt_cx(c1)}\ln({b1}){opp_sign_c2}{fmt_cx(abs(c2))}\ln({b2})"
        rhs_iso = rf"{fmt_cln(d2, b2)}{opp_sign_d1}{fmt_cln(d1, b1, True)}"
        step4 = rf"{lhs_iso} = {rhs_iso}"

        # Step 5: Factor out x
        lhs_fac_inner = rf"{fmt_c(c1)}\ln({b1}){opp_sign_c2}{fmt_c(abs(c2), True)}\ln({b2})"
        step5 = rf"x({lhs_fac_inner}) = {rhs_iso}"

        # Formulate equivalent solutions using specific bases
        num_b1 = rf"{fmt_clog(d2, b2, b1)}{opp_sign_d1}{abs(d1)}"
        den_b1 = rf"{c1}{opp_sign_c2}{fmt_clog(abs(c2), b2, b1)}"

        num_b2 = rf"{d2}{opp_sign_d1}{fmt_clog(abs(d1), b1, b2)}"
        den_b2 = rf"{fmt_clog(c1, b1, b2)}{opp_sign_c2}{abs(c2)}"

        # Step 6: Final Answer with equivalent log expressions
        final_ans = rf"x = \frac{{{rhs_iso}}}{{{lhs_fac_inner}}} = \frac{{{num_b1}}}{{{den_b1}}} = \frac{{{num_b2}}}{{{den_b2}}}"

        return {
            "prob_eq": prob_eq,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "step4": step4,
            "step5": step5,
            "final_ans": final_ans
        }