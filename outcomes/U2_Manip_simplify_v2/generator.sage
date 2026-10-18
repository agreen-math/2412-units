from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        v = random.choice(["x", r"\theta", "t"])

        problems = [
            {"expr": rf"\sin {v} \cos^2 {v} + \sin^3 {v}",
             "steps": [rf"\sin {v} \left(\cos^2 {v} + \sin^2 {v}\right)",
                       rf"\sin {v} \cdot 1", rf"\sin {v}"], "final": rf"\sin {v}"},
            {"expr": rf"\cos {v} \sin^2 {v} + \cos^3 {v}",
             "steps": [rf"\cos {v} \left(\sin^2 {v} + \cos^2 {v}\right)",
                       rf"\cos {v} \cdot 1", rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\sin {v} + \sin {v} \cot^2 {v}",
             "steps": [rf"\sin {v} \left(1 + \cot^2 {v}\right)",
                       rf"\sin {v} \csc^2 {v}",
                       rf"\sin {v} \cdot \frac{{1}}{{\sin^2 {v}}}",
                       rf"\frac{{1}}{{\sin {v}}}"], "final": rf"\csc {v}"},
            {"expr": rf"\cos {v} + \cos {v} \tan^2 {v}",
             "steps": [rf"\cos {v} \left(1 + \tan^2 {v}\right)",
                       rf"\cos {v} \sec^2 {v}",
                       rf"\cos {v} \cdot \frac{{1}}{{\cos^2 {v}}}",
                       rf"\frac{{1}}{{\cos {v}}}"], "final": rf"\sec {v}"},
            {"expr": rf"\tan {v} \cos^2 {v} + \tan {v} \sin^2 {v}",
             "steps": [rf"\tan {v} \left(\cos^2 {v} + \sin^2 {v}\right)",
                       rf"\tan {v} \cdot 1", rf"\tan {v}"], "final": rf"\tan {v}"},
            {"expr": rf"\cot {v} \sin^2 {v} + \cot {v} \cos^2 {v}",
             "steps": [rf"\cot {v} \left(\sin^2 {v} + \cos^2 {v}\right)",
                       rf"\cot {v} \cdot 1", rf"\cot {v}"], "final": rf"\cot {v}"},
            {"expr": rf"\sec {v} \cos^2 {v} + \sec {v} \sin^2 {v}",
             "steps": [rf"\sec {v} \left(\cos^2 {v} + \sin^2 {v}\right)",
                       rf"\sec {v} \cdot 1", rf"\sec {v}"], "final": rf"\sec {v}"},
            {"expr": rf"\csc {v} \sin^2 {v} + \csc {v} \cos^2 {v}",
             "steps": [rf"\csc {v} \left(\sin^2 {v} + \cos^2 {v}\right)",
                       rf"\csc {v} \cdot 1", rf"\csc {v}"], "final": rf"\csc {v}"},
            {"expr": rf"\sin {v} \sec^2 {v} - \sin {v} \tan^2 {v}",
             "steps": [rf"\sin {v} \left(\sec^2 {v} - \tan^2 {v}\right)",
                       rf"\sin {v} \cdot 1", rf"\sin {v}"], "final": rf"\sin {v}"},
            {"expr": rf"\cos {v} \csc^2 {v} - \cos {v} \cot^2 {v}",
             "steps": [rf"\cos {v} \left(\csc^2 {v} - \cot^2 {v}\right)",
                       rf"\cos {v} \cdot 1", rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\sec {v} - \sec {v} \sin^2 {v}",
             "steps": [rf"\sec {v} \left(1 - \sin^2 {v}\right)",
                       rf"\sec {v} \cos^2 {v}",
                       rf"\frac{{1}}{{\cos {v}}} \cdot \cos^2 {v}",
                       rf"\cos {v}"], "final": rf"\cos {v}"},
            {"expr": rf"\csc {v} - \csc {v} \cos^2 {v}",
             "steps": [rf"\csc {v} \left(1 - \cos^2 {v}\right)",
                       rf"\csc {v} \sin^2 {v}",
                       rf"\frac{{1}}{{\sin {v}}} \cdot \sin^2 {v}",
                       rf"\sin {v}"], "final": rf"\sin {v}"},
        ]

        problem = random.choice(problems)

        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")
        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {"expr": problem["expr"], "outtro": outtro}
