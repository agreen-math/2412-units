from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # Primitive Pythagorean triples strictly limited to small numbers
        # to ensure non-calculator arithmetic remains manageable
        triples = [
            (3, 4, 5), (4, 3, 5),
            (5, 12, 13), (12, 5, 13)
        ]
        
        a_val, b_val, c_val = random.choice(triples)
        inv_func = random.choice(['sin', 'cos', 'tan'])
        
        # Map the triple to the appropriate fraction depending on the inverse function
        if inv_func == 'tan':
            A = a_val
            Denom = b_val
        else:
            A = a_val
            Denom = c_val
            
        # Format the algebraic components for LaTeX
        Au_str = f"{A}u"
        Asq_u2_str = f"{A**2}u^2"
        Denom_sq = Denom**2
        
        arg_tex = rf"\frac{{{Au_str}}}{{{Denom}}}"
        
        # Added \displaystyle to ensure the fraction renders at full size
        prompt_tex = rf"\displaystyle \cos\left(2\{inv_func}^{{-1}}\left({arg_tex}\right)\right)"
        
        outtro_lines = []
        
        # Build step-by-step logic based on the geometric right-triangle approach
        if inv_func == 'tan':
            prelim1 = rf"\text{{Let }} \theta = \tan^{{-1}}\left({arg_tex}\right) \implies \tan\theta = {arg_tex} = \frac{{y}}{{x}}"
            prelim2 = rf"r = \sqrt{{x^2 + y^2}} = \sqrt{{{Denom}^2 + ({Au_str})^2}} = \sqrt{{{Denom_sq} + {Asq_u2_str}}}"
            cos_val_tex = rf"\frac{{{Denom}}}{{\sqrt{{{Denom_sq} + {Asq_u2_str}}}}}"
            prelim3 = rf"\cos\theta = \frac{{x}}{{r}} = {cos_val_tex}"
            
            step1 = r"\cos(2\theta) = 2\cos^2\theta - 1"
            step2 = rf"= 2\left({cos_val_tex}\right)^2 - 1"
            step3 = rf"= 2 \cdot \frac{{{Denom_sq}}}{{{Denom_sq} + {Asq_u2_str}}} - 1"
            two_D_sq = 2 * Denom_sq
            step4 = rf"= \frac{{{two_D_sq}}}{{{Denom_sq} + {Asq_u2_str}}} - \frac{{{Denom_sq} + {Asq_u2_str}}}{{{Denom_sq} + {Asq_u2_str}}}"
            step5 = rf"= \frac{{{two_D_sq} - ({Denom_sq} + {Asq_u2_str})}}{{{Denom_sq} + {Asq_u2_str}}}"
            
            final_num_tex = f"{Denom_sq} - {Asq_u2_str}"
            final_ans = rf"\frac{{{final_num_tex}}}{{{Denom_sq} + {Asq_u2_str}}}"
            
            outtro_lines.extend([prelim1, prelim2, prelim3, step1, step2, step3, step4, step5])
            
        elif inv_func == 'sin':
            prelim1 = rf"\text{{Let }} \theta = \sin^{{-1}}\left({arg_tex}\right) \implies \sin\theta = {arg_tex} = \frac{{y}}{{r}}"
            prelim2 = rf"x = \sqrt{{r^2 - y^2}} = \sqrt{{{Denom}^2 - ({Au_str})^2}} = \sqrt{{{Denom_sq} - {Asq_u2_str}}}"
            cos_val_tex = rf"\frac{{\sqrt{{{Denom_sq} - {Asq_u2_str}}}}}{{{Denom}}}"
            prelim3 = rf"\cos\theta = \frac{{x}}{{r}} = {cos_val_tex}"
            
            step1 = r"\cos(2\theta) = 2\cos^2\theta - 1"
            step2 = rf"= 2\left({cos_val_tex}\right)^2 - 1"
            step3 = rf"= 2 \cdot \frac{{{Denom_sq} - {Asq_u2_str}}}{{{Denom_sq}}} - 1"
            two_D_sq = 2 * Denom_sq
            two_A_sq = 2 * A**2
            step4 = rf"= \frac{{{two_D_sq} - {two_A_sq}u^2}}{{{Denom_sq}}} - \frac{{{Denom_sq}}}{{{Denom_sq}}}"
            step5 = rf"= \frac{{{two_D_sq} - {two_A_sq}u^2 - {Denom_sq}}}{{{Denom_sq}}}"
            
            final_num_tex = f"{Denom_sq} - {two_A_sq}u^2"
            final_ans = rf"\frac{{{final_num_tex}}}{{{Denom_sq}}}"
            
            outtro_lines.extend([prelim1, prelim2, prelim3, step1, step2, step3, step4, step5])
            
        elif inv_func == 'cos':
            prelim1 = rf"\text{{Let }} \theta = \cos^{{-1}}\left({arg_tex}\right) \implies \cos\theta = {arg_tex}"
            cos_val_tex = arg_tex
            
            step1 = r"\cos(2\theta) = 2\cos^2\theta - 1"
            step2 = rf"= 2\left({cos_val_tex}\right)^2 - 1"
            step3 = rf"= 2 \cdot \frac{{{Asq_u2_str}}}{{{Denom_sq}}} - 1"
            two_A_sq = 2 * A**2
            step4 = rf"= \frac{{{two_A_sq}u^2}}{{{Denom_sq}}} - \frac{{{Denom_sq}}}{{{Denom_sq}}}"
            step5 = rf"= \frac{{{two_A_sq}u^2 - {Denom_sq}}}{{{Denom_sq}}}"
            
            final_num_tex = f"{two_A_sq}u^2 - {Denom_sq}"
            final_ans = rf"\frac{{{final_num_tex}}}{{{Denom_sq}}}"
            
            outtro_lines.extend([prelim1, step1, step2, step3, step4, step5])
            
        final_sol = rf"\boxed{{{final_ans}}}"
        outtro_lines.append(final_sol)
        
        # Assemble the outtro dynamically following the Zero-Text Rule
        outtro = "<outtro>\n" + "\n".join([f"    <p><m>{line}</m></p>" for line in outtro_lines]) + "\n</outtro>"
        
        return {
            "prompt": prompt_tex,
            "outtro": outtro
        }