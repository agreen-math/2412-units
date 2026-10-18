from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        v = random.choice(["x", r"\theta", "t"])

        problems = [
            {"expr": rf"\frac{{\tan {v}}}{{\sec {v}}} \csc {v}",
             "steps": [rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \cos {v} \cdot \csc {v}",
                       rf"\sin {v} \cdot \frac{{1}}{{\sin {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\frac{{\cot {v}}}{{\csc {v}}} \sec {v}",
             "steps": [rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \sin {v} \cdot \sec {v}",
                       rf"\cos {v} \cdot \frac{{1}}{{\cos {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\frac{{\sec {v}}}{{\tan {v}}} \cos {v}",
             "steps": [rf"\frac{{1}}{{\cos {v}}} \cdot \frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v}",
                       rf"\frac{{1}}{{\sin {v}}} \cdot \cos {v}",
                       rf"\frac{{\cos {v}}}{{\sin {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
            {"expr": rf"\frac{{\csc {v}}}{{\cot {v}}} \sin {v}",
             "steps": [rf"\frac{{1}}{{\sin {v}}} \cdot \frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v}",
                       rf"\frac{{1}}{{\cos {v}}} \cdot \sin {v}",
                       rf"\frac{{\sin {v}}}{{\cos {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
            {"expr": rf"\frac{{\sec {v} - \cos {v}}}{{\tan {v}}}",
             "steps": [rf"\frac{{\frac{{1}}{{\cos {v}}} - \cos {v}}}{{\frac{{\sin {v}}}{{\cos {v}}}}}",
                       rf"\frac{{\frac{{1 - \cos^2 {v}}}{{\cos {v}}}}}{{\frac{{\sin {v}}}{{\cos {v}}}}}",
                       rf"\frac{{\sin^2 {v}}}{{\sin {v}}}", rf"\sin {v}"], "final": rf"\sin {v}"},
            {"expr": rf"\frac{{\csc {v} - \sin {v}}}{{\cot {v}}}",
             "steps": [rf"\frac{{\frac{{1}}{{\sin {v}}} - \sin {v}}}{{\frac{{\cos {v}}}{{\sin {v}}}}}",
                       rf"\frac{{\frac{{1 - \sin^2 {v}}}{{\sin {v}}}}}{{\frac{{\cos {v}}}{{\sin {v}}}}}",
                       rf"\frac{{\cos^2 {v}}}{{\cos {v}}}", rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\frac{{\tan {v} \sin {v} + \cos {v}}}{{\sec {v}}}",
             "steps": [rf"\frac{{\frac{{\sin {v}}}{{\cos {v}}} \cdot \sin {v} + \cos {v}}}{{\frac{{1}}{{\cos {v}}}}}",
                       rf"\frac{{\frac{{\sin^2 {v}}}{{\cos {v}}} + \frac{{\cos^2 {v}}}{{\cos {v}}}}}{{\frac{{1}}{{\cos {v}}}}}",
                       rf"\frac{{\frac{{1}}{{\cos {v}}}}}{{\frac{{1}}{{\cos {v}}}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\frac{{\cot {v} \cos {v} + \sin {v}}}{{\csc {v}}}",
             "steps": [rf"\frac{{\frac{{\cos {v}}}{{\sin {v}}} \cdot \cos {v} + \sin {v}}}{{\frac{{1}}{{\sin {v}}}}}",
                       rf"\frac{{\frac{{\cos^2 {v}}}{{\sin {v}}} + \frac{{\sin^2 {v}}}{{\sin {v}}}}}{{\frac{{1}}{{\sin {v}}}}}",
                       rf"\frac{{\frac{{1}}{{\sin {v}}}}}{{\frac{{1}}{{\sin {v}}}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\frac{{\tan^2 {v} + 1}}{{\sec {v} \csc {v}}}",
             "steps": [rf"\frac{{\sec^2 {v}}}{{\sec {v} \csc {v}}}",
                       rf"\frac{{\sec {v}}}{{\csc {v}}}",
                       rf"\frac{{\sin {v}}}{{\cos {v}}}", rf"\tan {v}"], "final": rf"\tan {v}"},
            {"expr": rf"\frac{{\cot^2 {v} + 1}}{{\csc {v} \sec {v}}}",
             "steps": [rf"\frac{{\csc^2 {v}}}{{\csc {v} \sec {v}}}",
                       rf"\frac{{\csc {v}}}{{\sec {v}}}",
                       rf"\frac{{\cos {v}}}{{\sin {v}}}", rf"\cot {v}"], "final": rf"\cot {v}"},
            {"expr": rf"\frac{{\sec^2 {v} - 1}}{{\tan {v} \sec {v}}}",
             "steps": [rf"\frac{{\tan^2 {v}}}{{\tan {v} \sec {v}}}",
                       rf"\frac{{\tan {v}}}{{\sec {v}}}",
                       rf"\frac{{\sin {v}}}{{\cos {v}}} \cdot \cos {v}", rf"\sin {v}"], "final": rf"\sin {v}"},
            {"expr": rf"\frac{{\csc^2 {v} - 1}}{{\cot {v} \csc {v}}}",
             "steps": [rf"\frac{{\cot^2 {v}}}{{\cot {v} \csc {v}}}",
                       rf"\frac{{\cot {v}}}{{\csc {v}}}",
                       rf"\frac{{\cos {v}}}{{\sin {v}}} \cdot \sin {v}", rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\frac{{\sec {v} - \cos {v}}}{{\sin {v} \tan {v}}}",
             "steps": [rf"\frac{{\frac{{1}}{{\cos {v}}} - \cos {v}}}{{\sin {v} \cdot \frac{{\sin {v}}}{{\cos {v}}}}}",
                       rf"\frac{{\frac{{1 - \cos^2 {v}}}{{\cos {v}}}}}{{\frac{{\sin^2 {v}}}{{\cos {v}}}}}",
                       rf"\frac{{\sin^2 {v}}}{{\sin^2 {v}}}", rf"1"], "final": rf"1"},
            {"expr": rf"\frac{{\csc {v} - \sin {v}}}{{\cos {v} \cot {v}}}",
             "steps": [rf"\frac{{\frac{{1}}{{\sin {v}}} - \sin {v}}}{{\cos {v} \cdot \frac{{\cos {v}}}{{\sin {v}}}}}",
                       rf"\frac{{\frac{{1 - \sin^2 {v}}}{{\sin {v}}}}}{{\frac{{\cos^2 {v}}}{{\sin {v}}}}}",
                       rf"\frac{{\cos^2 {v}}}{{\cos^2 {v}}}", rf"1"], "final": rf"1"},
        ]

        problem = random.choice(problems)

        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")
        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {"expr": problem["expr"], "outtro": outtro}
