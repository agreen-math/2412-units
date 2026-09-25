from sage.all import *
from random import choice

class Generator(BaseGenerator):
    def data(self):
        t = var('t')
        x, y, u = var('x, y, u')
        
        # Randomize parameters for linear substitution
        # a is strictly greater than 1 to ensure a coefficient is always present
        a = choice([Integer(2), Integer(3), Integer(4), Integer(5)])
        m = choice([Integer(i) for i in range(-5, 6) if i not in [0, 1]])
        c = a * m
        b = choice([Integer(i) for i in range(-7, 8) if i != 0])
        trig_func = choice([sin, cos])
        
        # Construct parametric equations
        x_expr = a * trig_func(t)
        y_expr = c * trig_func(t) + b
        
        x_eq = (x == x_expr)
        y_eq = (y == y_expr)
        
        # Construct the outtro dynamically to satisfy the Zero-Text Rule
        outtro = f"<outtro>\n"
        
        step1 = (trig_func(t) == x / a)
        outtro += rf"    <p><m>{latex(step1)}</m></p>\n"
        
        # Construct unsimplified substitution string
        y_sub = c * u + b
        fraction_latex = latex(x / a)
        step2_latex = r"y = " + latex(y_sub).replace('u', rf"\left({fraction_latex}\right)")
        outtro += rf"    <p><m>{step2_latex}</m></p>\n"
        
        # Provide final simplified equation in a box
        final_eq = (y == m * x + b)
        outtro += rf"    <p><m>\boxed{{ {latex(final_eq)} }}</m></p>\n"
        
        outtro += f"</outtro>"
        
        return {
            "x_eq": latex(x_eq),
            "y_eq": latex(y_eq),
            "outtro": outtro
        }