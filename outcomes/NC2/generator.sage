from sage.all import *
import random

# ==============================================================================
# Pre-formatted LaTeX Map
# Forces radicals into the numerator instead of floating beside the fraction
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

class Generator(BaseGenerator):
    def data(self):
        # Pre-defined unit-circle angles
        angles = [
            (0, 0, r"0"), (30, pi/6, r"\frac{\pi}{6}"), (45, pi/4, r"\frac{\pi}{4}"),
            (60, pi/3, r"\frac{\pi}{3}"), (90, pi/2, r"\frac{\pi}{2}"), (120, 2*pi/3, r"\frac{2\pi}{3}"),
            (135, 3*pi/4, r"\frac{3\pi}{4}"), (150, 5*pi/6, r"\frac{5\pi}{6}"), (180, pi, r"\pi"),
            (210, 7*pi/6, r"\frac{7\pi}{6}"), (225, 5*pi/4, r"\frac{5\pi}{4}"), (240, 4*pi/3, r"\frac{4\pi}{3}"),
            (270, 3*pi/2, r"\frac{3\pi}{2}"), (300, 5*pi/3, r"\frac{5\pi}{3}"), (315, 7*pi/4, r"\frac{7\pi}{4}"),
            (330, 11*pi/6, r"\frac{11\pi}{6}"),
        ]

        functions = ["sin", "cos", "tan", "sec", "csc", "cot"]
        
        data = {}
        outtro_lines = []

        for i in range(1, 7):
            func = random.choice(functions)
            deg, rad, rad_tex = random.choice(angles)

            # Assign degree labels to the first 3, radian labels to the last 3
            angle_tex = rf"{deg}^\circ" if i <= 3 else rad_tex

            # Check for undefined values safely based on denominator domains
            if func in ["tan", "sec"] and cos(rad) == 0:
                answer = r"\text{UND}"
            elif func in ["csc", "cot"] and sin(rad) == 0:
                answer = r"\text{UND}"
            else:
                # Direct calculation using SageMath's lightning-fast native exact evaluation
                val = {
                    "sin": sin(rad),
                    "cos": cos(rad),
                    "tan": tan(rad),
                    "sec": sec(rad),
                    "csc": csc(rad),
                    "cot": cot(rad),
                }[func]
                
                # Check our map for the pretty format, fall back to native latex() if not found
                answer = tex_map.get(val, latex(val))

            prompt_tex = rf"\{func}\left({angle_tex}\right)"
            data[f"q{i}"] = prompt_tex
            
            letter = chr(96 + i) 
            step = rf"\text{{({letter})}} \quad {prompt_tex} = {answer}"
            outtro_lines.append(f"    <p><m>{step}</m></p>")

        data["solution_steps"] = "\n".join(outtro_lines)
        
        return data