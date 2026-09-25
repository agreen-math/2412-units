from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize Global Rigid Transformations
        sx = Integer(random.choice([1, -1]))
        sy = Integer(random.choice([1, -1]))
        h = Integer(random.randint(-1, 1)) 
        k = Integer(random.randint(-1, 1))
        
        def T(x, y):
            return (sx * x + h, sy * y + k)

        # 2. Define Master Feature Data
        # Locations: Hole Only @ -5, VA @ -3, Jump @ -1, Hole+Point @ 3
        # FIXED: Replaced $ with <m> tags for SpaTeXt XML compatibility
        features = {
            "hole_only": {
                "x": sx * (-5) + h,
                "L_lim": sy * 1 + k,
                "R_lim": sy * 1 + k,
                "full_lim": sy * 1 + k,
                "f_val": "DNE",
                "conceptual_prompt": r"For what value <m>a</m> does <m>f(a)</m> not exist, but <m>\displaystyle\lim_{x \to a} f(x)</m> does exist?"
            },
            "jump": {
                "x": sx * (-1) + h,
                "L_lim": sy * (2.5 if sx == 1 else -2) + k, 
                "R_lim": sy * (-2 if sx == 1 else 2.5) + k,
                "full_lim": "DNE",
                "f_val": sy * (-2) + k,
                "conceptual_prompt": r"For what value <m>a</m> does <m>\displaystyle\lim_{x \to a} f(x)</m> not exist, but <m>f(a)</m> does exist?"
            },
            "hole_point": {
                "x": sx * (3) + h,
                "L_lim": sy * 2 + k,
                "R_lim": sy * 2 + k,
                "full_lim": sy * 2 + k,
                "f_val": sy * -3 + k,
                "conceptual_prompt": r"For what value <m>a</m> do both <m>\displaystyle\lim_{x \to a} f(x)</m> and <m>f(a)</m> exist, but <m>\displaystyle\lim_{x \to a} f(x) \neq f(a)</m>?"
            }
        }
        
        # 3. Assign Features to Tasks (Ensure zero overlap between Multi-part and Conceptual)
        keys = ["hole_only", "jump", "hole_point"]
        random.shuffle(keys)
        q_multi = features[keys[0]]      # Multi-part (Task 1)
        q_conceptual = features[keys[1]] # Conceptual (Task 3)
        # Note: keys[2] is unused, providing variety across different generated exams.

        def fmt(val):
            return r"\text{DNE}" if val == "DNE" else latex(val)

        # Helper to wrap negative values in parentheses for limit subscripts
        def sub_fmt(val):
            if isinstance(val, (int, Integer)) and val < 0:
                return rf"({val})"
            return latex(val)

        # 4. End Behavior Logic
        inf_dir_val = random.choice([-1, 1])
        inf_dir_str = r"(-\infty)" if inf_dir_val == -1 else r"\infty"
        
        if inf_dir_val * sx == 1:
            ans_inf = r"-\infty" if sy == 1 else r"\infty"
        else:
            ans_inf = r"-\infty" if sy == 1 else r"\infty"

        # 5. Build TikZ String
        grid = rf"""
            \clip (-8.5,-5.5) rectangle (8.5,5.5);
            \draw[black!40] (-8,-5) grid (8,5);
            \draw[very thick, &lt;-&gt;] (-8.5,0) -- (8.5,0) node[right] {{x}};
            \draw[very thick, &lt;-&gt;] (0,-5.5) -- (0,5.5) node[above] {{y}};
        """
        labels = ""
        for i in range(-8, 9, 2):
            if i != 0: labels += rf"\node[below, fill=white, inner sep=1pt] at ({i},0) {{\tiny {i}}};"
        for j in range(-4, 5, 2):
            if j != 0: labels += rf"\node[left, fill=white, inner sep=1pt] at (0,{j}) {{\tiny {j}}};"

        p1 = rf"\draw[blue, ultra thick, &lt;-&gt;, domain={sx*(-8.5)+h}:{sx*(-3.25)+h}, samples=50] plot (\x, {{ {sy}*(0.5*((\x-{h})/{sx}) + 3 - 1/( ((\x-{h})/{sx}) + 3)) + {k} }});"
        p2 = rf"\draw[blue, ultra thick, -&gt;, domain={sx*(-2.85)+h}:{sx*(-1)+h}, samples=50] plot (\x, {{ {sy}*(0.5*((\x-{h})/{sx}) + 3 - 1/( ((\x-{h})/{sx}) + 3)) + {k} }});"
        p3 = rf"\draw[blue, ultra thick] ({T(-1,-2)[0]}, {T(-1,-2)[1]}) -- ({T(3,2)[0]}, {T(3,2)[1]});"
        p4 = rf"\draw[blue, ultra thick, -&gt;, domain={sx*(3)+h}:{sx*(7)+h}, samples=50] plot (\x, {{ {sy}*(-(((\x-{h})/{sx})-4)**2 + 3) + {k} }});"

        dots = rf"""
            \filldraw[white, draw=blue, thick] ({T(-5,1)[0]}, {T(-5,1)[1]}) circle (5pt);
            \filldraw[white, draw=blue, thick] ({T(-1,2.5)[0]}, {T(-1,2.5)[1]}) circle (5pt);
            \filldraw[blue] ({T(-1,-2)[0]}, {T(-1,-2)[1]}) circle (5pt);
            \filldraw[white, draw=blue, thick] ({T(3,2)[0]}, {T(3,2)[1]}) circle (5pt);
            \filldraw[blue] ({T(3,-3)[0]}, {T(3,-3)[1]}) circle (5pt);
        """
        graph_tikz = rf"\begin{{tikzpicture}}[scale=0.5, &gt;=triangle 45]{grid}{labels}{p1}{p2}{p3}{p4}{dots}\end{{tikzpicture}}"

        return {
            "graph_tikz": graph_tikz,
            "c_multi": q_multi["x"],
            "c_multi_sub": sub_fmt(q_multi["x"]),
            "ans_L": rf"\boxed{{ {fmt(q_multi['L_lim'])} }}",
            "ans_R": rf"\boxed{{ {fmt(q_multi['R_lim'])} }}",
            "ans_full": rf"\boxed{{ {fmt(q_multi['full_lim'])} }}",
            "ans_val": rf"\boxed{{ {fmt(q_multi['f_val'])} }}",
            "prompt_conceptual": q_conceptual["conceptual_prompt"],
            "ans_conceptual": rf"\boxed{{ a = {q_conceptual['x']} }}",
            "inf_dir_sub": inf_dir_str,
            "ans_inf": rf"\boxed{{ {ans_inf} }}"
        }