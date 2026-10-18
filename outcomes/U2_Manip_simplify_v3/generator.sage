from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        v = random.choice(["x", r"\theta", "t"])

        problems = [
            {"expr": rf"\frac{{\sin {v}}}{{1 - \cos^2 {v}}}",
             "steps": [rf"\frac{{\sin {v}}}{{\sin^2 {v}}}", rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
            {"expr": rf"\frac{{\cos {v}}}{{1 - \sin^2 {v}}}",
             "steps": [rf"\frac{{\cos {v}}}{{\cos^2 {v}}}", rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
            {"expr": rf"\frac{{1 - \sin^2 {v}}}{{\cos {v}}}",
             "steps": [rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\frac{{1 - \cos^2 {v}}}{{\sin {v}}}",
             "steps": [rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
            {"expr": rf"\frac{{1 + \tan^2 {v}}}{{\sec {v}}}",
             "steps": [rf"\frac{{\sec^2 {v}}}{{\sec {v}}}", rf"\sec {v}"], "final": rf"\sec {v}"},
            {"expr": rf"\frac{{1 + \cot^2 {v}}}{{\csc {v}}}",
             "steps": [rf"\frac{{\csc^2 {v}}}{{\csc {v}}}", rf"\csc {v}"], "final": rf"\csc {v}"},
            {"expr": rf"\frac{{\sec {v}}}{{1 + \tan^2 {v}}}",
             "steps": [rf"\frac{{\sec {v}}}{{\sec^2 {v}}}", rf"\frac{{1}}{{\sec {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\frac{{\csc {v}}}{{1 + \cot^2 {v}}}",
             "steps": [rf"\frac{{\csc {v}}}{{\csc^2 {v}}}", rf"\frac{{1}}{{\csc {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
            {"expr": rf"\left(\sec^2 {v} - 1\right) \cot {v}",
             "steps": [rf"\tan^2 {v} \cot {v}",
                       rf"\tan^2 {v} \cdot \frac{{1}}{{\tan {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
            {"expr": rf"\left(\csc^2 {v} - 1\right) \tan {v}",
             "steps": [rf"\cot^2 {v} \tan {v}",
                       rf"\cot^2 {v} \cdot \frac{{1}}{{\cot {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
            {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan {v}}}",
             "steps": [rf"\frac{{\tan^2 {v}}}{{\tan {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
            {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot {v}}}",
             "steps": [rf"\frac{{\cot^2 {v}}}{{\cot {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
        ]

        problem = random.choice(problems)

        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")
        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {"expr": problem["expr"], "outtro": outtro}
