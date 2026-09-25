import random

class Generator(BaseGenerator):
    def data(self):
        # Ensure exactly one quadrantal and one non-quadrantal angle
        is_quad = [True, False]
        random.shuffle(is_quad)
        
        # Ensure exactly one is in radians and one is in degrees
        is_rad = [True, False]
        random.shuffle(is_rad)
        
        # Select integer radii to fit the (-5, 5) grid
        r_vals = [choice([-5, -4, -3, -2, 2, 3, 4, 5]) for _ in range(2)]
        
        # Standard unit circle angle pools
        quad_rads = [0, pi/2, pi, 3*pi/2]
        quad_degs = [0, 90, 180, 270]
        nq_rads = [pi/6, pi/4, pi/3, 2*pi/3, 3*pi/4, 5*pi/6, 7*pi/6, 5*pi/4, 4*pi/3, 5*pi/3, 7*pi/4, 11*pi/6]
        nq_degs = [30, 45, 60, 120, 135, 150, 210, 225, 240, 300, 315, 330]
        
        pts = []
        rects = []
        theta_evals = []
        
        for i in range(2):
            if is_quad[i]:
                if is_rad[i]:
                    theta = choice(quad_rads)
                    theta_str = latex(theta)
                    theta_eval = theta
                else:
                    deg = choice(quad_degs)
                    theta_str = rf"{deg}^\circ"
                    theta_eval = deg * pi / 180
            else:
                if is_rad[i]:
                    theta = choice(nq_rads)
                    theta_str = latex(theta)
                    theta_eval = theta
                else:
                    deg = choice(nq_degs)
                    theta_str = rf"{deg}^\circ"
                    theta_eval = deg * pi / 180
            
            theta_evals.append(theta_eval)        
            r = r_vals[i]
            pts.append(rf"\left({r}, {theta_str}\right)")
            
            # Exact rectangular coordinates
            x_c = r * cos(theta_eval)
            y_c = r * sin(theta_eval)
            rects.append(rf"\left({latex(x_c)}, {latex(y_c)}\right)")
            
        # Convert angles to degrees for TikZ
        deg_a = float(theta_evals[0] * 180 / pi)
        deg_b = float(theta_evals[1] * 180 / pi)
        
        # Build TikZ string - wrapped in <p><m> to satisfy Zero-Text Rule
        tikz_code = (
            r"\begin{tikzpicture}[scale=0.5,baseline=(current bounding box.center)]"
            r"\draw[lightgray,very thin] (0,0) circle (1) circle (2) circle (3) circle (4) circle (5);"
            r"\foreach \a in {0,15,...,345} \draw[lightgray,very thin] (0,0) -- (\a:5);"
            r"\draw[gray,thin] (0,0) circle (1) circle (2) circle (3) circle (4) circle (5);"
            r"\foreach \a in {0,30,...,330} \draw[gray,thin] (0,0) -- (\a:5);"
            r"\draw[->,thick] (-5.5,0) -- (5.5,0) node[right] {$x$};"
            r"\draw[->,thick] (0,-5.5) -- (0,5.5) node[above] {$y$};"
            f"\\fill[blue] ({deg_a}:{r_vals[0]}) circle (3pt) node[above right,blue,fill=white,inner sep=1pt] {{A}};"
            f"\\fill[red] ({deg_b}:{r_vals[1]}) circle (3pt) node[above right,red,fill=white,inner sep=1pt] {{B}};"
            r"\end{tikzpicture}"
        )
            
        # Every component of the outtro is now a <p><m> block
        outtro = (
            f"<outtro>\n"
            f"    <p><m>{tikz_code}</m></p>\n"
            f"    <p><m>A: (x, y) = {rects[0]}</m></p>\n"
            f"    <p><m>B: (x, y) = {rects[1]}</m></p>\n"
            f"</outtro>"
        )

        return {
            "pt_a": pts[0],
            "pt_b": pts[1],
            "outtro": outtro
        }