from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        v = random.choice(["x", r"\theta", "t"])

        problems = [
            {"expr": rf"\cot {v} \cos {v} + \sin {v}",
             "steps": [rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v} + \sin {v}",
                       rf"\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}",
                       rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
            {"expr": rf"\sin {v} + \cot {v} \cos {v}",
             "steps": [rf"\sin {v} + \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                       rf"\frac{{\sin^2 {v}}}{{\sin {v}}} + \frac{{\cos^2 {v}}}{{\sin {v}}}",
                       rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
            {"expr": rf"\tan {v} \sin {v} + \cos {v}",
             "steps": [rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v} + \cos {v}",
                       rf"\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}",
                       rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
            {"expr": rf"\cos {v} + \tan {v} \sin {v}",
             "steps": [rf"\cos {v} + \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                       rf"\frac{{\cos^2 {v}}}{{\cos {v}}} + \frac{{\sin^2 {v}}}{{\cos {v}}}",
                       rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
            {"expr": rf"\csc {v} - \cot {v} \cos {v}",
             "steps": [rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                       rf"\frac{{1}}{{\sin {v}}} - \frac{{\cos^2 {v}}}{{\sin {v}}}",
                       rf"\frac{{\sin^2 {v}}}{{\sin {v}}}"], "final": rf"\sin {v}"},
            {"expr": rf"\sec {v} - \tan {v} \sin {v}",
             "steps": [rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                       rf"\frac{{1}}{{\cos {v}}} - \frac{{\sin^2 {v}}}{{\cos {v}}}",
                       rf"\frac{{\cos^2 {v}}}{{\cos {v}}}"], "final": rf"\cos {v}"},
            {"expr": rf"\cos^2 {v} \csc {v} + \sin {v}",
             "steps": [rf"\cos^2 {v} \cdot \frac{{1}}{{\sin {v}}} + \sin {v}",
                       rf"\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}",
                       rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
            {"expr": rf"\sin^2 {v} \sec {v} + \cos {v}",
             "steps": [rf"\sin^2 {v} \cdot \frac{{1}}{{\cos {v}}} + \cos {v}",
                       rf"\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}",
                       rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
        ]

        problem = random.choice(problems)

        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")
        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {"expr": problem["expr"], "outtro": outtro}
