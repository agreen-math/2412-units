import random

class Generator(BaseGenerator):
    def data(self):
        # Randomize the given angle to the nearest tenth of a degree
        A_val = round(random.uniform(20.0, 70.0), 1)
        B_val = round(90.0 - A_val, 1)
        
        # Randomize which side is given and its integer length
        given_side_name = random.choice(['a', 'b', 'c'])
        given_val = random.randint(10, 50)
        
        # Convert degrees to radians for SageMath trigonometric evaluation
        A_rad = A_val * pi / 180.0
        
        # Dynamically build the solution steps based on the given side
        if given_side_name == 'a':
            a_val = float(given_val)
            b_val = float(a_val / tan(A_rad))
            c_val = float(a_val / sin(A_rad))
            
            step_b = rf"\tan({A_val}^\circ) = \frac{{{given_val}}}{{b}} \implies b = \frac{{{given_val}}}{{\tan({A_val}^\circ)}} \approx {b_val:.2f}"
            step_c = rf"\sin({A_val}^\circ) = \frac{{{given_val}}}{{c}} \implies c = \frac{{{given_val}}}{{\sin({A_val}^\circ)}} \approx {c_val:.2f}"
            
            steps = (
                rf"    <p><m>B = 90^\circ - {A_val}^\circ = {B_val}^\circ</m></p>\n"
                rf"    <p><m>{step_b}</m></p>\n"
                rf"    <p><m>{step_c}</m></p>"
            )
            
        elif given_side_name == 'b':
            b_val = float(given_val)
            a_val = float(b_val * tan(A_rad))
            c_val = float(b_val / cos(A_rad))
            
            step_a = rf"\tan({A_val}^\circ) = \frac{{a}}{{{given_val}}} \implies a = {given_val}\tan({A_val}^\circ) \approx {a_val:.2f}"
            step_c = rf"\cos({A_val}^\circ) = \frac{{{given_val}}}{{c}} \implies c = \frac{{{given_val}}}{{\cos({A_val}^\circ)}} \approx {c_val:.2f}"
            
            steps = (
                rf"    <p><m>B = 90^\circ - {A_val}^\circ = {B_val}^\circ</m></p>\n"
                rf"    <p><m>{step_a}</m></p>\n"
                rf"    <p><m>{step_c}</m></p>"
            )
            
        else:
            c_val = float(given_val)
            a_val = float(c_val * sin(A_rad))
            b_val = float(c_val * cos(A_rad))
            
            step_a = rf"\sin({A_val}^\circ) = \frac{{a}}{{{given_val}}} \implies a = {given_val}\sin({A_val}^\circ) \approx {a_val:.2f}"
            step_b = rf"\cos({A_val}^\circ) = \frac{{b}}{{{given_val}}} \implies b = {given_val}\cos({A_val}^\circ) \approx {b_val:.2f}"
            
            steps = (
                rf"    <p><m>B = 90^\circ - {A_val}^\circ = {B_val}^\circ</m></p>\n"
                rf"    <p><m>{step_a}</m></p>\n"
                rf"    <p><m>{step_b}</m></p>"
            )

        # Format the final boxed summary using an aligned environment to mimic a table
        # We must use &amp; instead of & to prevent XML parsing errors in SpaTeXt
        final_sol = (
            rf"\boxed{{\begin{{aligned}} "
            rf"A &amp;= {A_val}^\circ &amp; a &amp;\approx {a_val:.2f} \\ "
            rf"B &amp;= {B_val}^\circ &amp; b &amp;\approx {b_val:.2f} \\ "
            rf"C &amp;= 90^\circ &amp; c &amp;\approx {c_val:.2f} "
            rf"\end{{aligned}}}}"
        )
        
        # Construct the final outtro strictly adhering to the Zero-Text Rule
        solution_steps = f"{steps}\n    <p><m>{final_sol}</m></p>\n"

        return {
            "A_val": f"{A_val:.1f}",
            "given_side_name": given_side_name,
            "given_side_val": given_val,
            "solution_steps": solution_steps
        }