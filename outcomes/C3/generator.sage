import random

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        # --- LOGARITHMIC EQUATION LOGIC ---
        while True:
            b_log = choice([2, 3, 4, 5, 6])
            k_log = choice([1, 2])
            R = b_log**k_log
            
            c = choice([i for i in range(-6, 7)])
            d = choice([i for i in range(-6, 7)])
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
                sol_log = r1
                ext_log = r2
                break
            elif r2_valid and not r1_valid:
                sol_log = r2
                ext_log = r1
                break

        log_b_str = rf"\log_{{{b_log}}}"
        arg1 = x + c
        arg2 = x + d
        
        log_prob = rf"{log_b_str}({latex(arg1)}) + {log_b_str}({latex(arg2)}) = {k_log}"
        
        if c == 0:
            prod_str = rf"x({latex(arg2)})"
        elif d == 0:
            prod_str = rf"x({latex(arg1)})"
        else:
            prod_str = rf"({latex(arg1)})({latex(arg2)})"
            
        expanded_rhs = x**2 + B*x + c*d
        quad_expr = x**2 + B*x + C
        factor1 = x - sol_log
        factor2 = x - ext_log
        
        log_align = []
        log_align.append(rf"{log_b_str}({prod_str}) &= {k_log}")
        log_align.append(rf"{R} &= {prod_str}")
        log_align.append(rf"{R} &= {latex(expanded_rhs)}")
        log_align.append(rf"0 &= {latex(quad_expr)}")
        log_align.append(rf"0 &= ({latex(factor1)})({latex(factor2)})")
        
        # We can safely use raw & here because the template will escape it
        log_steps = r"\begin{aligned} " + r" \\ ".join(log_align) + r" \end{aligned}"
        
        # FIX: Doubled the curly braces for the \boxed command
        log_ans = rf"\boxed{{x = {sol_log}}} \quad \text{{(Extraneous: }} x = {ext_log} \text{{)}}"
        
        
        # --- EXPONENTIAL EQUATION LOGIC ---
        b_val = choice([2, 3, 4, 5, 6, 7, 8, 9, 'e'])
        b_exp_str = 'e' if b_val == 'e' else str(b_val)
            
        while True:
            if choice([True, False]):
                c1 = choice([-4, -3, -2, 2, 3, 4])
                c2 = choice([-4, -3, -2, -1, 1, 2, 3, 4])
                d1, d2 = 0, 0
                d3 = choice([1, 2, 3])
            else:
                c1 = choice([-3, -2, -1, 1, 2, 3])
                c2 = choice([-3, -2, -1, 1, 2, 3])
                d1 = choice([i for i in range(-4, 5)])
                d2 = choice([i for i in range(-4, 5)])
                d3 = choice([-4, -3, -2, -1, 1, 2, 3, 4])
            
            cx = c1 + c2
            if cx != 0:
                break
                
        p1 = c1*x + d1
        p2 = c2*x + d2
        p3 = d3
        
        if p3 == 0:
            rhs_str = "1"
        elif p3 == 1:
            rhs_str = b_exp_str
        else:
            rhs_str = rf"{b_exp_str}^{{{p3}}}"
            
        lhs_str = rf"{b_exp_str}^{{{latex(p1)}}} \cdot {b_exp_str}^{{{latex(p2)}}}"
        exp_prob = rf"{lhs_str} = {rhs_str}"
        
        p1_str = latex(p1)
        p2_str = latex(p2)
        if p2_str.startswith('-'):
            exp_sum_str = rf"{p1_str}{p2_str}"
        else:
            exp_sum_str = rf"{p1_str}+{p2_str}"
            
        exp_align = []
        exp_align.append(rf"{b_exp_str}^{{{exp_sum_str}}} &= {rhs_str}")
        exp_align.append(rf"{exp_sum_str} &= {p3}")
        
        simp_lhs = cx*x + (d1+d2)
        const_rhs = d3 - d1 - d2
        
        if (d1 + d2) != 0:
            exp_align.append(rf"{latex(simp_lhs)} &= {p3}")
            
        exp_align.append(rf"{latex(cx*x)} &= {const_rhs}")
            
        ans_x = Integer(const_rhs) / Integer(cx)
        if ans_x.denominator() == 1:
            ans_str = str(ans_x.numerator())
        else:
            if ans_x < 0:
                ans_str = rf"-\frac{{{abs(ans_x.numerator())}}}{{{ans_x.denominator()}}}"
            else:
                ans_str = rf"\frac{{{ans_x.numerator()}}}{{{ans_x.denominator()}}}"
                
        exp_align.append(rf"x &= {ans_str}")
        
        exp_steps = r"\begin{aligned} " + r" \\ ".join(exp_align) + r" \end{aligned}"
        
        # FIX: Doubled the curly braces for the \boxed command
        exp_ans = rf"\boxed{{x = {ans_str}}}"
        
        
        # --- RANDOMIZE PART A AND PART B ORDER ---
        if choice([True, False]):
            return {
                "prob_a": log_prob,
                "step_a": log_steps,
                "ans_a": log_ans,
                "prob_b": exp_prob,
                "step_b": exp_steps,
                "ans_b": exp_ans
            }
        else:
            return {
                "prob_a": exp_prob,
                "step_a": exp_steps,
                "ans_a": exp_ans,
                "prob_b": log_prob,
                "step_b": log_steps,
                "ans_b": log_ans
            }