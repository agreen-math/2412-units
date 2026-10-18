from sage.all import *
import random


# Angles that are multiples of 15 degrees are "unit-circle friendly": students
# recognize them instantly (30, 45, 60, 90, ...) and their radian measures are
# tidy fractions of pi. We exclude them so students must actually convert
# degrees to radians with a calculator before using the formulas.
FRIENDLY_STEP = 15


def pick_angle(pool):
    options = [a for a in pool if a % FRIENDLY_STEP != 0]
    return Integer(random.choice(options))


class Generator(BaseGenerator):
    def data(self):
        scenarios = {
            "wiper": {
                "angles": [70, 80, 95, 100, 110, 125, 130, 140, 145, 155],
                "r_range": (14, 26),
                "rate_range": (0.03, 0.12),
                "unit": "inch",
                "region": "region cleared by the wiper",
                "professional": "auto detailer",
                "rate_action": "apply a water-repellent coating",
                "short_action": "treat",
                "includes_radii": False,
                "scenario_text": r"A windshield wiper pivots through an angle of <m>{angle}^\circ</m> and sweeps out a circular sector of the windshield with a radius of <m>{r}</m> inches.",
                "length_task": "The tip of the wiper blade travels along the outer arc of the region. To the nearest inch, how far does the tip travel in a single sweep?",
            }
        }

        sc = scenarios[random.choice(list(scenarios.keys()))]
        angle = pick_angle(sc["angles"])
        r = Integer(random.randint(*sc["r_range"]))
        rate = round(random.uniform(*sc["rate_range"]), 2)

        scenario_text = sc["scenario_text"].format(angle=angle, r=r)

        # --- Convert the angle to radians first, then use the radian formulas ---
        rad_exact = (angle / Integer(180)) * pi
        rad_float = float(rad_exact)

        # --- Part B: area of the sector (A = 1/2 r^2 theta), then its cost ---
        area_exact = (Integer(1) / Integer(2)) * (r**2) * rad_exact
        area_float = float(area_exact)
        cost = round(area_float * rate, 2)

        # --- Part C: arc length (s = r theta), optionally plus the two radii ---
        arc_exact = r * rad_exact
        if sc["includes_radii"]:
            length_exact = arc_exact + 2 * r
            length_symbol = "P"
            length_rhs = rf"r\theta + 2r = ({r})\left({latex(rad_exact)}\right) + 2({r})"
        else:
            length_exact = arc_exact
            length_symbol = "s"
            length_rhs = rf"r\theta = ({r})\left({latex(rad_exact)}\right)"
        length_rounded = round(float(length_exact))

        step_convert = rf"\theta = {angle}^\circ = {angle}\left(\frac{{\pi}}{{180}}\right) = {latex(rad_exact)} \approx {round(rad_float, 4)}"
        step_b1 = rf"A = \frac{{1}}{{2}} r^2 \theta = \frac{{1}}{{2}}({r})^2\left({latex(rad_exact)}\right) \approx {round(area_float, 2)}"
        step_b2 = rf"{round(area_float, 2)} \cdot {rate:.2f} = {cost:.2f}"
        step_c1 = rf"{length_symbol} = {length_rhs} \approx {length_rounded}"

        solution_steps = "\n".join([
            f"    <p><m>{step_convert}</m></p>",
            f"    <p><m>{step_b1}</m></p>",
            f"    <p><m>{step_b2}</m></p>",
            f"    <p><m>{step_c1}</m></p>",
        ])

        return {
            "scenario_text": scenario_text,
            "region": sc["region"],
            "professional": sc["professional"],
            "rate_action": sc["rate_action"],
            "short_action": sc["short_action"],
            "unit": sc["unit"],
            "rate": f"{rate:.2f}",
            "length_task": sc["length_task"],
            "solution_steps": solution_steps,
        }
