from sage.all import *
from random import randint, choice, shuffle

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        deg_N = choice([1, 2, 3])
        deg_D = choice([1, 2])
        
        has_hole = choice([True, False])
        
        pool = list(range(-4, 5))
        shuffle(pool)
        
        N_roots = sorted([pool.pop() for _ in range(deg_N)])
        D_roots = sorted([pool.pop() for _ in range(deg_D)])
        hole_root = pool.pop() if has_hole else None
        
        a = choice([1, 2, -1, -2])
        b = choice([1, 2])
        if a == b:
            b = 1
            
        def fmt_factored(coef, roots, h_root):
            res = ""
            if coef == -1: res += "-"
            elif coef != 1: res += str(coef)
            
            all_roots = list(roots)
            if h_root is not None:
                all_roots.append(h_root)
            all_roots.sort()
            
            if len(all_roots) == 0:
                if coef == 1: return "1"
                if coef == -1: return "-1"
                return str(coef)
            
            for r in all_roots:
                if r == 0:
                    res += "x"
                elif r > 0:
                    res += f"(x - {r})"
                else:
                    res += f"(x + {-r})"
            return res

        N_factored_tex = fmt_factored(a, N_roots, hole_root)
        D_factored_tex = fmt_factored(b, D_roots, hole_root)
        
        N_poly = a
        for r in N_roots: N_poly *= (x - r)
        D_poly = b
        for r in D_roots: D_poly *= (x - r)
        
        N_poly_exp = expand(N_poly)
        D_poly_exp = expand(D_poly)
        
        if has_hole:
            N_poly_exp = expand(N_poly_exp * (x - hole_root))
            D_poly_exp = expand(D_poly_exp * (x - hole_root))
            
        f_expr = rf"\dfrac{{{latex(N_poly_exp)}}}{{{latex(D_poly_exp)}}}"
        f_fact = rf"\dfrac{{{N_factored_tex}}}{{{D_factored_tex}}}"
        
        dom_roots = list(D_roots)
        if has_hole:
            dom_roots.append(hole_root)
        dom_roots.sort()
        
        if not dom_roots:
            domain_ans = r"\text{All real numbers}"
        else:
            domain_ans = ", ".join([rf"x \neq {r}" for r in dom_roots])
            
        if has_hole:
            y_val = N_poly(x=hole_root) / D_poly(x=hole_root)
            hole_ans = rf"\left({hole_root}, {latex(y_val)}\right)"
        else:
            hole_ans = r"\text{none}"
            
        if D_roots:
            va_ans = ", ".join([rf"x = {r}" for r in D_roots])
        else:
            va_ans = r"\text{none}"
            
        if deg_N < deg_D:
            ha_ans = r"y = 0"
        elif deg_N == deg_D:
            ha_ans = rf"y = {latex(QQ(a)/QQ(b))}"
        else:
            ha_ans = r"\text{none}"
            
        if deg_N == deg_D + 1:
            R_poly = PolynomialRing(QQ, 'x')
            P_N = R_poly(N_poly_exp)
            P_D = R_poly(D_poly_exp)
            Q, Rem = P_N.quo_rem(P_D)
            oa_ans = rf"y = {latex(Q(x))}"
        else:
            oa_ans = r"\text{none}"
            
        if 0 in dom_roots:
            y_int_ans = r"\text{none}"
        else:
            y_int = N_poly_exp(x=0) / D_poly_exp(x=0)
            y_int_ans = rf"\left(0, {latex(y_int)}\right)"
            
        if N_roots:
            x_int_ans = ", ".join([rf"\left({r}, 0\right)" for r in N_roots])
        else:
            x_int_ans = r"\text{none}"
            
        return {
            "f_expr": f_expr,
            "f_fact": f_fact,
            "domain_ans": domain_ans,
            "hole_ans": hole_ans,
            "va_ans": va_ans,
            "ha_ans": ha_ans,
            "oa_ans": oa_ans,
            "y_int_ans": y_int_ans,
            "x_int_ans": x_int_ans
        }