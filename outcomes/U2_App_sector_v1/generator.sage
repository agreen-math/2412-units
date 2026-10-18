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
            "pizza": {
                "angles": [24, 32, 36, 40, 48, 50, 54, 65, 72, 78],
                "r_range": (6, 9),
                "rate_range": (0.03, 0.15),
                "unit": "inch",
                "unit_plural": "inches",
                "unit_abbr": "in",
                "square_unit": "square inch",
                "region": "slice",
                "professional": "caterer",
                "rate_action": "provide pizza",
                "short_action": "buy",
                "includes_radii": False,
                "diagram_note": "For this situation the two straight sides are the two cuts, and the arc is the crust.",
                "length_result": "the slice has about {L} inches of crust",
                "scenario_text": r"A slice is cut from a round pizza whose radius is <m>{r}</m> inches. The slice is cut so that its tip, at the center of the pizza, forms an angle of <m>{angle}^\circ</m>.",
                "length_task": "The crust runs along the outer arc of the slice. To the nearest inch, how many inches of crust does the slice have?",
            },
        }

        sc = scenarios[random.choice(list(scenarios.keys()))]
        angle = pick_angle(sc["angles"])
        r = Integer(random.randint(*sc["r_range"]))
        rate = round(random.uniform(*sc["rate_range"]), 2)

        unit = sc["unit"]
        unit_plural = sc["unit_plural"]
        u = sc["unit_abbr"]
        square_unit = sc["square_unit"]

        scenario_text = sc["scenario_text"].format(angle=angle, r=r)

        # --- Convert the angle to radians first, then use the radian formulas ---
        rad_exact = (angle / Integer(180)) * pi
        rad_float = float(rad_exact)
        rad_disp = round(rad_float, 4)

        # --- Part B: area of the sector (A = 1/2 r^2 theta), then its cost ---
        # The area is rounded to the nearest hundredth because that is the value
        # students see and use when they multiply by the rate.
        area_exact = (Integer(1) / Integer(2)) * (r**2) * rad_exact
        area_disp = round(float(area_exact), 2)
        cost = round(area_disp * rate, 2)

        # --- Part C: arc length (s = r theta), optionally plus the two radii ---
        arc_exact = r * rad_exact
        if sc["includes_radii"]:
            length_exact = arc_exact + 2 * r
            length_formula = r"P = r\theta + 2r"
            length_sub = (
                rf"({r}\ \text{{{u}}})\left({latex(rad_exact)}\right)"
                rf" + 2({r}\ \text{{{u}}})"
            )
        else:
            length_exact = arc_exact
            length_formula = r"s = r\theta"
            length_sub = rf"({r}\ \text{{{u}}})\left({latex(rad_exact)}\right)"
        length_rounded = round(float(length_exact))

        # --- The math, written out with units at every step ---
        step_convert = (
            rf"\theta = {angle}^\circ = {angle}^\circ \cdot "
            rf"\frac{{\pi\ \text{{rad}}}}{{180^\circ}} "
            rf"= {latex(rad_exact)}\ \text{{rad}} \approx {rad_disp}\ \text{{rad}}"
        )

        step_area = (
            rf"A = \frac{{1}}{{2}} r^2 \theta = \frac{{1}}{{2}}({r}\ \text{{{u}}})^2 "
            rf"\left({latex(rad_exact)}\ \text{{rad}}\right) "
            rf"\approx {area_disp}\ \text{{{u}}}^2"
        )

        # Boxed final answer for part (b): the total cost in dollars.
        boxed_cost = r"\boxed{" + rf"\${cost:.2f}" + "}"

        step_cost = (
            rf"\text{{cost}} = {area_disp}\ \text{{{u}}}^2 \cdot "
            rf"\frac{{\${rate:.2f}}}{{1\ \text{{{u}}}^2}} = " + boxed_cost
        )

        # Boxed final answer for part (c): the length, in its scenario's unit.
        boxed_length = r"\boxed{" + rf"{length_rounded}\ \text{{{u}}}" + "}"

        step_length = (
            rf"{length_formula} = {length_sub} \approx " + boxed_length
        )

        # --- Part (c) prose depends on whether the boundary includes the radii ---
        if sc["includes_radii"]:
            part_c_intro = (
                f"The brass strip follows the entire boundary of the {sc['region']}: "
                f"the curved arc plus the two straight sides. The arc has length "
                f"<m>s = r\\theta</m>, and each straight side has length equal to the "
                f"radius, so we add <m>2r</m>."
            )
        else:
            part_c_intro = (
                f"The arc is the curved outer edge of the {sc['region']}, and its length is "
                f"<m>s = r\\theta</m>, with <m>\\theta</m> in radians (the same value we "
                f"used in part (b))."
            )

        solution_steps = "\n".join([
            f"    <p><em>Part (a).</em> The {sc['region']} is a circular sector, the part of a "
            f"circle cut off by a central angle. Sketch it by marking the vertex of the angle, "
            f"drawing the two straight sides out to a length of <m>{r}</m> {unit_plural}, and "
            f"joining their far ends with the curved arc. Label the central angle "
            f"<m>{angle}^\\circ</m>, both straight sides <m>{r}</m> {unit_plural}, and the arc "
            f"<m>s</m>. {sc['diagram_note']}</p>",

            f"    <p><em>Part (b).</em> The area of a sector is "
            f"<m>A = \\frac{{1}}{{2}} r^2 \\theta</m>, but that formula only works when the "
            f"angle is measured in radians, so we convert the given angle first.</p>",

            f"    <p><m>{step_convert}</m></p>",

            f"    <p>Now substitute <m>r = {r}</m> {unit_plural} and "
            f"<m>\\theta \\approx {rad_disp}</m> radians into the area formula:</p>",

            f"    <p><m>{step_area}</m></p>",

            f"    <p>The {sc['professional']} charges <m>\\${rate:.2f}</m> for every "
            f"{square_unit}, so we multiply the area by that rate. The {square_unit} units "
            f"cancel, leaving dollars:</p>",

            f"    <p><m>{step_cost}</m></p>",

            f"    <p>So the total cost to {sc['short_action']} the {sc['region']} is "
            f"<m>{boxed_cost}</m>.</p>",

            f"    <p><em>Part (c).</em> {part_c_intro}</p>",

            f"    <p><m>{step_length}</m></p>",

            f"    <p>So {sc['length_result'].format(L=length_rounded)}.</p>",
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
