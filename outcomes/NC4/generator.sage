from sage.all import *
from random import choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize Parameters (Single-digits, even Period, positive Dilation)
        A = Integer(choice([2, 3, 4, 5, 6, 7, 8, 9]))
        P = Integer(choice([2, 4, 6, 8]))
        h = Integer(choice([i for i in range(-9, 10) if i != 0]))
        
        # 2. Determine Dynamic Window Size (Must remain identical for all 3 graphs)
        # Calculate maximum absolute extents based on the domains of interest
        max_x_sin_cos = max(abs(h), abs(h + P))
        max_x_tan = max(abs(h - P/2), abs(h + P/2))
        X = float(max(max_x_sin_cos, max_x_tan)) + 1.0
        Y = float(A + 1)
        
        # Generate Ticks dynamically (every 2 units for large windows to prevent text overlap)
        ticks = ""
        x_step = 2 if X > 6 else 1
        for i in range(-int(X), int(X) + 1, x_step):
            if i != 0:
                ticks += rf"\draw ({i}, 0.15) -- ({i}, -0.15) node[below] {{\tiny ${i}$}};"
                
        y_step = 2 if Y > 5 else 1
        for j in range(-int(Y), int(Y) + 1, y_step):
            if j != 0:
                ticks += rf"\draw (0.15, {j}) -- (-0.15, {j}) node[left] {{\tiny ${j}$}};"

        # Common TikZ Setup (Origin perfectly centered)
        # CRITICAL FIX: Replaced < and > with &lt; and &gt; to prevent XML parsing crash
        grid_setup = rf"""
            \clip (-{X},- {Y}) rectangle ({X}, {Y});
            \draw[step=1cm, black!40] (-{X},-{Y}) grid ({X},{Y});
            \draw[very thick, &lt;-&gt;] (-{X},0) -- ({X},0) node[right] {{x}};
            \draw[very thick, &lt;-&gt;] (0,-{Y}) -- (0,{Y}) node[above] {{y}};
            {ticks}
"""
        
        def draw_point(x_val, y_val):
            return rf"\filldraw[black] ({float(x_val)}, {float(y_val)}) circle (4pt);"

        # --- Sine Graph ---
        tikz_sin = rf"\begin{{tikzpicture}}[scale=0.35,&gt;=triangle 45]{grid_setup}"
        # TikZ natively uses degrees for trig functions, so we scale radians (2pi) to degrees (360)
        tikz_sin += rf"\draw[blue, very thick, samples=100, domain={float(h)}:{float(h+P)}, smooth] plot (\x, {{ {A} * sin( 360/{P} * (\x - ({h})) ) }});"
        tikz_sin += draw_point(h, 0)
        tikz_sin += draw_point(h + P/4.0, A)
        tikz_sin += draw_point(h + P/2.0, 0)
        tikz_sin += draw_point(h + 3.0*P/4.0, -A)
        tikz_sin += draw_point(h + P, 0)
        tikz_sin += r"\end{tikzpicture}"
        
        # --- Cosine Graph ---
        tikz_cos = rf"\begin{{tikzpicture}}[scale=0.35,&gt;=triangle 45]{grid_setup}"
        tikz_cos += rf"\draw[red, very thick, samples=100, domain={float(h)}:{float(h+P)}, smooth] plot (\x, {{ {A} * cos( 360/{P} * (\x - ({h})) ) }});"
        tikz_cos += draw_point(h, A)
        tikz_cos += draw_point(h + P/4.0, 0)
        tikz_cos += draw_point(h + P/2.0, -A)
        tikz_cos += draw_point(h + 3.0*P/4.0, 0)
        tikz_cos += draw_point(h + P, A)
        tikz_cos += r"\end{tikzpicture}"
        
        # --- Tangent Graph ---
        tikz_tan = rf"\begin{{tikzpicture}}[scale=0.35,&gt;=triangle 45]{grid_setup}"
        # Asymptotes
        tikz_tan += rf"\draw[dashed, very thick, purple] ({float(h - P/2.0)}, -{Y}) -- ({float(h - P/2.0)}, {Y});"
        tikz_tan += rf"\draw[dashed, very thick, purple] ({float(h + P/2.0)}, -{Y}) -- ({float(h + P/2.0)}, {Y});"
        # Curve (domain slightly restricted to avoid calculating infinite values at asymptotes)
        domain_start = float(h - P/2.0) + 0.05
        domain_end = float(h + P/2.0) - 0.05
        # Tangent period is pi (180 degrees)
        tikz_tan += rf"\draw[purple, very thick, samples=100, domain={domain_start}:{domain_end}, smooth] plot (\x, {{ {A} * tan( 180/{P} * (\x - ({h})) ) }});"
        tikz_tan += draw_point(h - P/4.0, -A)
        tikz_tan += draw_point(h, 0)
        tikz_tan += draw_point(h + P/4.0, A)
        tikz_tan += r"\end{tikzpicture}"

        # 3. Assemble dynamic HTML outtro string
        outtro = f"<outtro>\n"
        outtro += rf"    <p><m>\textbf{{Sine (Wave of Interest):}}</m></p>\n"
        outtro += rf"    <p><m>{tikz_sin}</m></p>\n"
        outtro += rf"    <p><m>\textbf{{Cosine (Wave of Interest):}}</m></p>\n"
        outtro += rf"    <p><m>{tikz_cos}</m></p>\n"
        outtro += rf"    <p><m>\textbf{{Tangent (Wave of Interest):}}</m></p>\n"
        outtro += rf"    <p><m>{tikz_tan}</m></p>\n"
        outtro += f"</outtro>"
        
        return {
            "A": A,
            "P": P,
            "h": h,
            "outtro": outtro
        }