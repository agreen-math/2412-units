from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # Restricted to the smallest primitive Pythagorean triples for non-calculator arithmetic
        triples = [
            (3, 4, 5), (4, 3, 5),
            (5, 12, 13), (12, 5, 13)
        ]

        # Quadrant mappings: (quad_num, x_sign, y_sign, interval_latex)
        # Added \displaystyle to all interval strings
        quadrants = [
            (1, 1, 1, r"\displaystyle 0 < \theta < \frac{\pi}{2}"),
            (2, -1, 1, r"\displaystyle \frac{\pi}{2} < \theta < \pi"),
            (3, -1, -1, r"\displaystyle \pi < \theta < \frac{3\pi}{2}"),
            (4, 1, -1, r"\displaystyle \frac{3\pi}{2} < \theta < 2\pi")
        ]

        # Randomly select the triangle and quadrant
        x_mag, y_mag, r = random.choice(triples)
        quad_num, x_sign, y_sign, interval = random.choice(quadrants)

        # Apply quadrant signs
        x = x_mag * x_sign
        y = y_mag * y_sign

        # Calculate exact rational trigonometric ratios
        sin_val = Integer(y) / Integer(r)
        cos_val = Integer(x) / Integer(r)
        tan_val = Integer(y) / Integer(x)

        # Select which ratio to give to the student
        funcs = [
            ("sin", sin_val),
            ("cos", cos_val),
            ("tan", tan_val)
        ]
        given_func, given_val = random.choice(funcs)
        
        # Added \displaystyle to the given prompt string
        prompt_given = rf"\displaystyle \{given_func} \theta = {latex(given_val)}"

        # Step 1: State the double-angle identity
        step1 = r"\sin(2\theta) = 2\sin\theta\cos\theta"
        
        # Step 2: Establish the known sine and cosine values based on the reference triangle
        step2 = rf"\sin\theta = {latex(sin_val)} \quad \cos\theta = {latex(cos_val)}"
        
        # Step 3: Substitute into the identity
        step3 = rf"= 2 \left({latex(sin_val)}\right) \left({latex(cos_val)}\right)"

        # Step 4: Final exact evaluation
        final_ans = 2 * sin_val * cos_val
        final_sol = rf"\boxed{{{latex(final_ans)}}}"

        # Assemble the outtro strictly following the Zero-Text Rule
        outtro = (
            f"<outtro>\n"
            f"    <p><m>{step1}</m></p>\n"
            f"    <p><m>{step2}</m></p>\n"
            f"    <p><m>{step3}</m></p>\n"
            f"    <p><m>{final_sol}</m></p>\n"
            f"</outtro>"
        )

        return {
            "given": prompt_given,
            "interval": interval,
            "outtro": outtro
        }