from sage.all import *
import random

# ==============================================================================
# MODULE-LEVEL PRECOMPUTATION:
# Runs ONCE. Stores symbolic values and forces pretty LaTeX formatting.
# ==============================================================================

tex_map = {
    0: r"0", 
    1: r"1", 
    -1: r"-1",
    1/2: r"\frac{1}{2}", 
    -1/2: r"-\frac{1}{2}",
    2: r"2", 
    -2: r"-2",
    sqrt(3)/2: r"\frac{\sqrt{3}}{2}", 
    -sqrt(3)/2: r"-\frac{\sqrt{3}}{2}",
    sqrt(2)/2: r"\frac{\sqrt{2}}{2}", 
    -sqrt(2)/2: r"-\frac{\sqrt{2}}{2}",
    sqrt(3)/3: r"\frac{\sqrt{3}}{3}", 
    -sqrt(3)/3: r"-\frac{\sqrt{3}}{3}",
    2*sqrt(3)/3: r"\frac{2\sqrt{3}}{3}", 
    -2*sqrt(3)/3: r"-\frac{2\sqrt{3}}{3}",
    sqrt(3): r"\sqrt{3}", 
    -sqrt(3): r"-\sqrt{3}",
    sqrt(2): r"\sqrt{2}", 
    -sqrt(2): r"-\sqrt{2}"
}

angles = [
    0, pi/6, pi/4, pi/3, pi/2, 2*pi/3, 3*pi/4, 5*pi/6, 
    pi, 7*pi/6, 5*pi/4, 4*pi/3, 3*pi/2, 5*pi/3, 7*pi/4, 11*pi/6
]

funcs = ["sin", "cos", "tan", "csc", "sec", "cot"]

uc_table = {ang: {} for ang in angles}

for ang in angles:
    for f in funcs:
        if f in ["tan", "sec"] and cos(ang) == 0:
            uc_table[ang][f] = None
        elif f in ["csc", "cot"] and sin(ang) == 0:
            uc_table[ang][f] = None
        else:
            # Native SageMath evaluation
            uc_table[ang][f] = {
                "sin": sin(ang), "cos": cos(ang), "tan": tan(ang),
                "csc": csc(ang), "sec": sec(ang), "cot": cot(ang)
            }[f]


# ==============================================================================
# GENERATOR CLASS
# ==============================================================================

class Generator(BaseGenerator):
    def data(self):
        data_dict = {}

        for i in range(1, 7):
            is_degree = (i <= 3) # First 3 in degrees, last 3 in radians
            func = random.choice(funcs)
            
            # Pick a random angle to guarantee we are searching for a valid unit-circle value
            target_angle = random.choice(angles)
            target_val = uc_table[target_angle][func]
            
            # Instant dictionary lookup to find all angles that match target_val
            sols = []
            for ang in angles:
                val = uc_table[ang][func]
                if target_val is None and val is None:
                    sols.append(ang)
                # Use boolean equality to safely compare the precomputed SageMath expressions
                elif target_val is not None and val is not None and bool(val == target_val):
                    sols.append(ang)
            
            # Format the prompt natively using our pretty tex_map!
            if target_val is None:
                stmt = rf"\{func}\theta \text{{ is undefined}}"
            else:
                pretty_val = tex_map.get(target_val, latex(target_val))
                stmt = rf"\{func}\theta = {pretty_val}"
                
            # Format the solutions appropriately based on the domain
            if is_degree:
                ans_str = ", ".join([rf"{int(ang * 180 / pi)}^\circ" for ang in sols])
            else:
                ans_str = ", ".join([latex(ang) for ang in sols])
                
            # Pass the raw variables directly to the XML
            data_dict[f"q{i}_stmt"] = stmt
            data_dict[f"q{i}_ans"] = ans_str

        return data_dict