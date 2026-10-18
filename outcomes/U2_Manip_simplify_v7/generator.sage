from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        v = random.choice(["x", r"\theta", "t"])

        problems = [
            {"expr": rf"\sin {v} \csc {v}",
             "steps": [rf"\sin {v} \cdot \frac{{1}}{{\sin {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\cos {v} \sec {v}",
             "steps": [rf"\cos {v} \cdot \frac{{1}}{{\cos {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\tan {v} \cot {v}",
             "steps": [rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \frac{{\cos {v}}}{{\sin {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\sin^2 {v} + \cos^2 {v}",
             "steps": [rf"1"], "final": rf"1"},
            {"expr": rf"\sec^2 {v} - \tan^2 {v}",
             "steps": [rf"1"], "final": rf"1"},
            {"expr": rf"\csc^2 {v} - \cot^2 {v}",
             "steps": [rf"1"], "final": rf"1"},
            {"expr": rf"\left(1 + \tan^2 {v}\right) \cos^2 {v}",
             "steps": [rf"\sec^2 {v} \cos^2 {v}",
                       rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos^2 {v}", rf"1"], "final": rf"1"},
            {"expr": rf"\left(1 + \cot^2 {v}\right) \sin^2 {v}",
             "steps": [rf"\csc^2 {v} \sin^2 {v}",
                       rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin^2 {v}", rf"1"], "final": rf"1"},
            {"expr": rf"\sin^2 {v} \csc^2 {v}",
             "steps": [rf"\sin^2 {v} \cdot \frac{{1}}{{\sin^2 {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\cos^2 {v} \sec^2 {v}",
             "steps": [rf"\cos^2 {v} \cdot \frac{{1}}{{\cos^2 {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\left(\sec^2 {v} - 1\right) \cot^2 {v}",
             "steps": [rf"\tan^2 {v} \cot^2 {v}",
                       rf"\frac{{\sin^2 {v}}}{{\cos^2 {v}}} \cdot \frac{{\cos^2 {v}}}{{\sin^2 {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\left(\csc^2 {v} - 1\right) \tan^2 {v}",
             "steps": [rf"\cot^2 {v} \tan^2 {v}",
                       rf"\frac{{\cos^2 {v}}}{{\sin^2 {v}}} \cdot \frac{{\sin^2 {v}}}{{\cos^2 {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan^2 {v}}}",
             "steps": [rf"\frac{{\tan^2 {v}}}{{\tan^2 {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot^2 {v}}}",
             "steps": [rf"\frac{{\cot^2 {v}}}{{\cot^2 {v}}}", rf"1"], "final": rf"1"},
        ]

        problem = random.choice(problems)

        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")
        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {"expr": problem["expr"], "outtro": outtro}
