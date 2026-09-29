from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        animal = choice(['grasshopper', 'cricket', 'frog', 'flea'])
        perch = choice(['reed', 'rock', 'log', 'stump', 'branch'])
        unit = choice(['inches', 'centimeters'])
        
        x = var('x')
        
        a_num = -randint(1, 5)
        b_num = randint(5, 25)
        
        # Ensure b_num does not evaluate to exactly 1.0 or 2.0 to maintain explicit coefficients
        if b_num % 10 == 0:
            b_num += 1
            
        c_val = randint(3, 9)
        
        # Cast to native Python floats to prevent trailing zeros in SageMath representation
        a_val = float(a_num / 10)
        b_val = float(b_num / 10)
        
        # Calculate the ground landing distance
        D0 = b_val**2 - 4 * a_val * c_val
        x_land = (-b_val - (D0)**0.5) / (2 * a_val)
        land_dist = round(x_land, 1)
        
        # Determine a target height strictly lower than the initial perch height
        h_target = randint(1, c_val - 1)
        c_new = c_val - h_target
        
        # Calculate the distance at the target height
        D1 = b_val**2 - 4 * a_val * c_new
        x_target = (-b_val - (D1)**0.5) / (2 * a_val)
        ans_val = round(x_target, 1)
        
        # Build mathematical expressions symbolically 
        h_expr = a_val*x**2 + b_val*x + c_val
        
        step1 = h_expr == h_target
        step2 = a_val*x**2 + b_val*x + c_new == 0
        
        # Retain raw strings for unsimplified quadratic formula steps
        step3 = rf"x = \frac{{-{b_val} \pm \sqrt{{{b_val}^2 - 4({a_val})({c_new})}}}}{{2({a_val})}}"
        
        D1_rounded = round(D1, 4)
        denom = round(2 * a_val, 1)
        step4 = rf"x = \frac{{-{b_val} \pm \sqrt{{{D1_rounded}}}}}{{{denom}}}"
        
        final_ans = rf"x \approx {ans_val} \text{{ {unit}}}"
        
        return {
            "animal": animal,
            "perch": perch,
            "c_val": c_val,
            "unit": unit,
            "land_dist": land_dist,
            "h_target": h_target,
            "h_expr": latex(h_expr),
            "step1": latex(step1),
            "step2": latex(step2),
            "step3": step3,
            "step4": step4,
            "final_ans": final_ans
        }