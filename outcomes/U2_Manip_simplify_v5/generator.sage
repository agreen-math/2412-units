from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        v = random.choice(["x", r"\theta", "t"])

        def even_odd_problem():
            results = {
                frozenset(("sin", "cot")): (rf"\cos {v}", rf"\cos {v}"),
                frozenset(("sin", "sec")): (rf"\frac{{\sin {v}}}{{\cos {v}}}", rf"\tan {v}"),
                frozenset(("sin", "csc")): (rf"1", rf"1"),
                frozenset(("cos", "tan")): (rf"\sin {v}", rf"\sin {v}"),
                frozenset(("cos", "sec")): (rf"1", rf"1"),
                frozenset(("cos", "csc")): (rf"\frac{{\cos {v}}}{{\sin {v}}}", rf"\cot {v}"),
                frozenset(("tan", "cot")): (rf"1", rf"1"),
                frozenset(("tan", "csc")): (rf"\frac{{1}}{{\cos {v}}}", rf"\sec {v}"),
                frozenset(("cot", "sec")): (rf"\frac{{1}}{{\sin {v}}}", rf"\csc {v}"),
            }
            forms = {
                "sin": rf"\sin {v}",
                "cos": rf"\cos {v}",
                "tan": rf"\frac{{\sin {v}}}{{\cos {v}}}",
                "cot": rf"\frac{{\cos {v}}}{{\sin {v}}}",
                "sec": rf"\frac{{1}}{{\cos {v}}}",
                "csc": rf"\frac{{1}}{{\sin {v}}}",
            }
            odd = {"sin", "tan", "cot", "csc"}

            pair = random.choice(list(results.keys()))
            a, b = sorted(pair)
            negated = random.choice([a, b])          # randomize which factor is negated
            other = b if negated == a else a
            cancelled, final = results[pair]

            sign = "-" if negated in odd else ""
            expr = rf"{negated}(-{v}) {other} {v}"

            steps = []
            if negated in odd:
                steps.append(rf"-{negated} {v} \cdot {other} {v}")
            else:
                steps.append(rf"{negated} {v} \cdot {other} {v}")
            steps.append(sign + forms[negated] + r" \cdot " + forms[other])
            steps.append(sign + cancelled)
            if final != cancelled:
                steps.append(sign + final)

            return {"expr": expr, "steps": steps, "final": sign + final}

        problem = even_odd_problem()

        outtro_lines = []
        for step in problem["steps"]:
            outtro_lines.append(f"    <p><m>{step}</m></p>")
        final_sol = rf"\boxed{{{problem['final']}}}"
        outtro_lines.append(f"    <p><m>{final_sol}</m></p>")
        outtro = "<outtro>\n" + "\n".join(outtro_lines) + "\n</outtro>"

        return {"expr": problem["expr"], "outtro": outtro}
