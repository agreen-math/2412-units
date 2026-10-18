from sage.all import *
from random import choice, randint

class Generator(BaseGenerator):
    def data(self):
        vehicles = [
            ("truck", 20, 25, 400, 800)
        ]

        vehicle, r_min, r_max, w_min, w_max = choice(vehicles)

        r = Integer(randint(r_min, r_max))
        w = Integer(randint(w_min, w_max) // 10 * 10)

        # circumference of one tire, in inches
        circ = 2 * pi * r

        # exact and numeric speed in miles per hour
        mph = pi * r * w / Integer(528)
        mph_value = n(mph, digits=5)

        # Step 1: distance rolled in one revolution
        step1 = rf"2 \pi r = 2 \pi ({r}) = {latex(circ)}\ \text{{in}}"

        # Step 2: distance rolled in one minute (still in inches)
        step2 = (
            rf"2 \pi ({r}) ({w}) "
            rf"\approx {latex(n(2 * pi * r * w, digits=5))}\ \text{{in per minute}}"
        )

        # Step 3: dimensional-analysis chain, units shown and cancelled
        step3 = (
            rf"v = "
            rf"\frac{{{w}\ \cancel{{\text{{rev}}}}}}{{1\ \text{{min}}}}"
            rf"\cdot \frac{{2 \pi ({r})\ \cancel{{\text{{in}}}}}}{{1\ \cancel{{\text{{rev}}}}}}"
            rf"\cdot \frac{{1\ \cancel{{\text{{ft}}}}}}{{12\ \cancel{{\text{{in}}}}}}"
            rf"\cdot \frac{{1\ \text{{mi}}}}{{5280\ \cancel{{\text{{ft}}}}}}"
            rf"\cdot \frac{{60\ \cancel{{\text{{min}}}}}}{{1\ \text{{hr}}}}"
        )

        # Step 4: arithmetic after cancelling
        step4 = rf"v = \frac{{\pi ({r}) ({w})}}{{528}}\ \frac{{\text{{mi}}}}{{\text{{hr}}}}"

        final_sol = r"\boxed{" + rf"{latex(mph_value)}\ \text{{mph}}" + "}"

        return {
            "vehicle": vehicle,
            "radius": r,
            "rpm": w,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "step4": step4,
            "final_sol": final_sol,
        }
