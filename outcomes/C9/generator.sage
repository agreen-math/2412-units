from sage.all import *
import random

class Generator(BaseGenerator):
    def data(self):
        # 1. Define thematic scenarios with realistic numerical ranges
        contexts = [
            {
                "range": (100, 500),
                "text": "A city is developing a new public park in a triangular lot left over from a highway project. The three sides of the lot are bordered by existing roads and measure approximately <m>{a}</m> feet, <m>{b}</m> feet, and <m>{c}</m> feet. How many square feet of sod need to be ordered to cover the entire lot?"
            },
            {
                "range": (15, 60),
                "text": "A sailmaker is designing a custom triangular sail for a racing yacht. The three edges of the sail need to measure exactly <m>{a}</m> feet, <m>{b}</m> feet, and <m>{c}</m> feet. How many square feet of sailcloth are required to manufacture this sail?"
            },
            {
                "range": (20, 80),
                "text": "A landscaper is planting a triangular flower garden in the corner of a large estate. The borders of the garden measure <m>{a}</m> feet, <m>{b}</m> feet, and <m>{c}</m> feet. What is the total area of the garden in square feet?"
            },
            {
                "range": (30, 100),
                "text": "An architect is designing a custom triangular stained-glass window for a modern building. The three sides of the glass pane will measure <m>{a}</m> inches, <m>{b}</m> inches, and <m>{c}</m> inches. What is the area of the glass required in square inches?"
            }
        ]
        
        # 2. Randomly select a scenario
        context = random.choice(contexts)
        min_val, max_val = context["range"]

        # 3. Enforce the Triangle Inequality Theorem to ensure valid geometry
        while True:
            a = random.randint(min_val, max_val)
            b = random.randint(min_val, max_val)
            c = random.randint(min_val, max_val)
            if a + b > c and a + c > b and b + c > a:
                break

        # Dynamically inject the generated sides into the chosen word problem
        prompt_text = context["text"].format(a=a, b=b, c=c)

        # 4. Calculate the semi-perimeter
        s_val = (a + b + c) / 2.0
        
        # 5. Calculate the area using Heron's Formula
        area_val = float(sqrt(s_val * (s_val - a) * (s_val - b) * (s_val - c)))
        
        # Format the final area uniformly to two decimal places
        formatted_area = f"{area_val:.2f}"
        
        # --- Build the Step-by-Step Solution ---
        step1 = r"s = \frac{a + b + c}{2}"
        step2 = rf"s = \frac{{{a} + {b} + {c}}}{{2}} = {s_val:g}"
        
        step3 = r"\text{Area} = \sqrt{s(s-a)(s-b)(s-c)}"
        step4 = rf"\text{{Area}} = \sqrt{{{s_val:g}({s_val:g}-{a})({s_val:g}-{b})({s_val:g}-{c})}}"
        
        # Calculate the internal differences for the intermediate step
        sa = s_val - a
        sb = s_val - b
        sc = s_val - c
        step5 = rf"\text{{Area}} = \sqrt{{{s_val:g}({sa:g})({sb:g})({sc:g})}}"
        step6 = rf"\text{{Area}} \approx {formatted_area}"

        outtro_lines = [
            f"    <p>Using Heron's Formula:</p>",
            f"    <p><m>{step1}</m></p>",
            f"    <p><m>{step2}</m></p>",
            f"    <p><m>{step3}</m></p>",
            f"    <p><m>{step4}</m></p>",
            f"    <p><m>{step5}</m></p>",
            f"    <p><m>{step6}</m></p>"
        ]
        
        solution_steps = "\n".join(outtro_lines)
        
        return {
            "prompt_text": f"<p>{prompt_text}</p>",
            "solution_steps": solution_steps
        }