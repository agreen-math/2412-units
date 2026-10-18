from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        v = random.choice(["x", r"\theta", "t"])

        problems = [
            {"expr": rf"\left(1 + \tan^2 {v}\right) \cos {v}",
             "steps": [rf"\sec^2 {v} \cos {v}",
                       rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos {v}",
                       rf"\frac{{1}}{{\cos {v}}}", rf"\sec {v}"], "final": rf"\sec {v}"},
            {"expr": rf"\left(1 + \cot^2 {v}\right) \sin {v}",
             "steps": [rf"\csc^2 {v} \sin {v}",
                       rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin {v}",
                       rf"\frac{{1}}{{\sin {v}}}", rf"\csc {v}"], "final": rf"\csc {v}"},
            {"expr": rf"\sec^2 {v} \cos {v} - \tan {v} \sin {v}",
             "steps": [rf"\frac{{1}}{{\cos^2 {v}}} \cdot \cos {v} - \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                       rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin^2 {v}}}{{\cos {v}}}",
                       rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\csc^2 {v} \sin {v} - \cot {v} \cos {v}",
             "steps": [rf"\frac{{1}}{{\sin^2 {v}}} \cdot \sin {v} - \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                       rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos^2 {v}}}{{\sin {v}}}",
                       rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
        ]

        problem = random.choice(problems)

        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")
        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {"expr": problem["expr"], "outtro": outtro}
