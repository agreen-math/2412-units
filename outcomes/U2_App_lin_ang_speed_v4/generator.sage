from sage.all import *
from random import choice, randint

class Generator(BaseGenerator):
    def data(self):
        vehicles = [
            ("tractor", 25, 35, 100, 400)
        ]
        
        vehicle, r_min, r_max, w_min, w_max = choice(vehicles)
        
        r = Integer(randint(r_min, r_max))
        w = Integer(randint(w_min, w_max) // 10 * 10)
        
        v = var('v')
        
        step1_latex = rf"{latex(v)} = 2 \pi ({r}) ({w})"
        step2_latex = rf"{latex(v)} = 2 \pi ({r}) ({w}) \left(\frac{{60}}{{5280 \cdot 12}}\right)"
        
        step3 = v == (pi * r * w) / Integer(528)
        final_sol = v == n((pi * r * w) / Integer(528), digits=5)
        
        return {
            "vehicle": vehicle,
            "radius": r,
            "rpm": w,
            "step1": step1_latex,
            "step2": step2_latex,
            "step3": latex(step3),
            "final_sol": latex(final_sol)
        }