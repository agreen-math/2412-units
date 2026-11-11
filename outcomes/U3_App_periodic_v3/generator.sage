from sage.all import *
import random
import re


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
def fill(template, **tokens):
    """Replace @token@ markers so LaTeX braces stay literal."""
    out = template
    for key, value in tokens.items():
        out = out.replace("@%s@" % key, str(value))
    return out


def spatext_math(text):
    """Wrap the whole scenario in ONE paragraph. Display math <me> must be a
    CHILD of <p>; a bare <me> directly inside <content> is dropped silently."""
    return "<p>" + text.strip() + "</p>"


MONTHS = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
]

# sin(k*pi/6) is exact for every integer k, but k = 0, 3, 6, 9, 12 land on the
# midline or on an extreme, which makes part (e) trivial. Excluded.
EVAL_OFFSETS = [1, 2, 4, 5, 7, 8, 10, 11]

# Offsets whose sine is +-1/2. These give D +- A/2, an integer when A is even,
# so they are the only usable offsets in contexts that round to a whole number.
HALF_OFFSETS = (1, 5, 7, 11)


def clock(hour):
    hour = int(hour) % 24
    if hour == 0:
        return "midnight"
    if hour == 12:
        return "noon"
    if hour < 12:
        return "%d:00 a.m." % hour
    return "%d:00 p.m." % (hour - 12)


def month_name(n):
    return MONTHS[(int(n) - 1) % 12]


# ---------------------------------------------------------------------------
# Every context keeps the same structure: B = pi/6 (period exactly 12 index
# units), even integer amplitude, integer midline, integer phase shift.
#
# Adding a context = appending one dict with the same keys. Nothing in the
# solution builder needs to change.
#
# decimals = 0 means part (e) is graded to a whole unit, which forces the
# evaluation offset to the +-1/2 ones. See ALLOWED OFFSETS in data().
# ---------------------------------------------------------------------------
CONTEXTS = [

    {
        "key": "temperature",
        "func": "f",
        "var": "x",
        "label_kind": "month",
        "index_unit": "months",
        "unit_tex": r"^\circ\text{F}",
        "A_range": (12, 22),
        "D_range": (46, 64),
        "h_choices": (2, 3, 4, 5),
        "decimals": 1,
        "setup": (
            r"The function <me>@func@(@var@)=@A@\sin\left[\frac{\pi}{6}(@var@-@h@)\right]+@D@</me> "
            r"models the average monthly temperature, in degrees Fahrenheit, for a particular "
            r"city, where <m>@var@=1</m> represents January, <m>@var@=2</m> represents "
            r"February, and so on."
        ),
        "q_a": "What is the average temperature?",
        "q_b": "What is the range of temperatures in this city?",
        "q_c": "What is the period of this function, and what does it mean in this context?",
        "q_d": "What is the phase shift of this function, and what does it mean in this context?",
        "q_e": (
            "Use the model to estimate the average temperature in @eval_label@. "
            "Round to the nearest tenth of a degree."
        ),
        "sol_a": (
            r"The midline of a sinusoid <m>@func@(@var@)=A\sin[B(@var@-h)]+D</m> is "
            r"<m>y=D</m>, and the midline is the average value of the oscillation. Here "
            r"<m>D=@D@</m>, so the average temperature is <m>\boxed{@D@@unit_tex@}</m>."
        ),
        "sol_b": (
            r"The warmest month on average is @max_label@ and the coolest is @min_label@, so "
            r"the range of monthly average temperatures is "
            r"<m>\boxed{[@min@@unit_tex@,\ @max@@unit_tex@]}</m>."
        ),
        "sol_c": r"so the temperature pattern repeats every 12 months, that is, once each year.",
        "sol_d": (
            r"so the sine pattern is shifted <m>@h@</m> months to the right: the temperature "
            r"is at its average and rising in @phase_label@, not in January. Equivalently, the "
            r"warmest month is @max_label@ and the coolest is @min_label@."
        ),
        "sol_e_tail": r"So the model gives @certainty@ <m>\boxed{@answer@}</m> in @eval_label@.",
    },

    {
        "key": "tide",
        "func": "d",
        "var": "x",
        "label_kind": "hour",
        "index_unit": "hours",
        "unit_tex": r"\text{ ft}",
        "A_range": (4, 6),
        "D_range": (9, 15),
        "h_choices": (2, 3, 4, 5),
        "decimals": 1,
        "setup": (
            r"The function <me>@func@(@var@)=@A@\sin\left[\frac{\pi}{6}(@var@-@h@)\right]+@D@</me> "
            r"models the depth of the water, in feet, at a harbor, where <m>@var@=0</m> "
            r"represents midnight and <m>@var@</m> is the number of hours after midnight."
        ),
        "q_a": "What is the average depth of the water at this harbor?",
        "q_b": "What are the greatest and least depths of the water at this harbor?",
        "q_c": "What is the period of this function? How many times does high tide occur in a day?",
        "q_d": "What is the phase shift of this function, and what does it mean in this context?",
        "q_e": (
            "Use the model to estimate the depth of the water at @eval_label@. "
            "Round to the nearest tenth of a foot."
        ),
        "sol_a": (
            r"The midline of a sinusoid <m>@func@(@var@)=A\sin[B(@var@-h)]+D</m> is "
            r"<m>y=D</m>, and the midline is the average value of the oscillation. Here "
            r"<m>D=@D@</m>, so the water averages <m>\boxed{@D@@unit_tex@}</m> deep."
        ),
        "sol_b": (
            r"High tide is at @max_label@, when the depth is <m>@max@@unit_tex@</m>, and low "
            r"tide is at @min_label@, when the depth is <m>@min@@unit_tex@</m>, so the range "
            r"of depths is <m>\boxed{[@min@@unit_tex@,\ @max@@unit_tex@]}</m>."
        ),
        "sol_c": (
            r"so the water returns to the same depth every 12 hours. High tide therefore "
            r"occurs twice in a 24-hour day, and low tide twice as well."
        ),
        "sol_d": (
            r"so the pattern is shifted <m>@h@</m> hours to the right: at @phase_label@ the "
            r"water is at its average depth and rising. High tide is at @max_label@ and again "
            r"at @second_max@; low tide is at @min_label@ and again at @second_min@."
        ),
        "sol_e_tail": r"So the model gives @certainty@ <m>\boxed{@answer@}</m> at @eval_label@.",
    },

    {
        "key": "daylight",
        "func": "L",
        "var": "x",
        "label_kind": "month",
        "index_unit": "months",
        "unit_tex": r"\text{ hr}",
        "A_range": (2, 4),
        "D_range": (12, 12),
        "h_choices": (3, 9),
        "decimals": 1,
        "setup": (
            r"The function <me>@func@(@var@)=@A@\sin\left[\frac{\pi}{6}(@var@-@h@)\right]+@D@</me> "
            r"models the number of hours of daylight in a city in the @hemi@ Hemisphere, "
            r"where <m>@var@=1</m> represents January, <m>@var@=2</m> represents February, "
            r"and so on."
        ),
        "q_a": "What is the average number of hours of daylight in this city over the year?",
        "q_b": "What is the range of the number of hours of daylight in this city?",
        "q_c": "What is the period of this function, and what does it mean in this context?",
        "q_d": "What is the phase shift of this function, and what does it mean in this context?",
        "q_e": (
            "Use the model to estimate the number of hours of daylight in @eval_label@. "
            "Round to the nearest tenth of an hour."
        ),
        "sol_a": (
            r"The midline <m>y=D</m> is the average value of the oscillation. Here "
            r"<m>D=@D@</m>, so the city averages <m>\boxed{@D@@unit_tex@}</m> of daylight."
        ),
        "sol_b": (
            r"The longest day is in @max_label@, with <m>@max@@unit_tex@</m> of daylight, and "
            r"the shortest is in @min_label@, with <m>@min@@unit_tex@</m>, so the range is "
            r"<m>\boxed{[@min@@unit_tex@,\ @max@@unit_tex@]}</m>."
        ),
        "sol_c": r"so the daylight pattern repeats every 12 months, that is, once each year.",
        "sol_d": (
            r"so the pattern is shifted <m>@h@</m> months to the right: daylight is at its "
            r"average and increasing in @phase_label@, which is an equinox. The longest day "
            r"falls in @max_label@ and the shortest in @min_label@, as expected in the "
            r"@hemi@ Hemisphere."
        ),
        "sol_e_tail": r"So the model gives @certainty@ <m>\boxed{@answer@}</m> of daylight in @eval_label@.",
    },

    {
        "key": "reservoir",
        "func": "L",
        "var": "x",
        "label_kind": "month",
        "index_unit": "months",
        "unit_tex": r"\text{ ft}",
        "A_range": (4, 8),
        "D_range": (18, 30),
        "h_choices": (2, 3, 4, 5),
        "decimals": 1,
        "setup": (
            r"The function <me>@func@(@var@)=@A@\sin\left[\frac{\pi}{6}(@var@-@h@)\right]+@D@</me> "
            r"models the water level, in feet, of a reservoir, where <m>@var@=1</m> represents "
            r"January, <m>@var@=2</m> represents February, and so on."
        ),
        "q_a": "What is the average water level of the reservoir?",
        "q_b": "What are the highest and lowest water levels of the reservoir?",
        "q_c": "What is the period of this function, and what does it mean in this context?",
        "q_d": "What is the phase shift of this function, and what does it mean in this context?",
        "q_e": (
            "Use the model to estimate the water level in @eval_label@. "
            "Round to the nearest tenth of a foot."
        ),
        "sol_a": (
            r"The midline <m>y=D</m> is the average value of the oscillation. Here "
            r"<m>D=@D@</m>, so the reservoir averages <m>\boxed{@D@@unit_tex@}</m>."
        ),
        "sol_b": (
            r"The reservoir is highest in @max_label@ at <m>@max@@unit_tex@</m> and lowest in "
            r"@min_label@ at <m>@min@@unit_tex@</m>, so the range of levels is "
            r"<m>\boxed{[@min@@unit_tex@,\ @max@@unit_tex@]}</m>."
        ),
        "sol_c": r"so the level follows a yearly cycle and repeats every 12 months.",
        "sol_d": (
            r"so the pattern is shifted <m>@h@</m> months to the right: the level is at its "
            r"average and rising in @phase_label@, peaks in @max_label@, and is lowest in "
            r"@min_label@."
        ),
        "sol_e_tail": r"So the model gives @certainty@ <m>\boxed{@answer@}</m> in @eval_label@.",
    },

    {
        "key": "electricity",
        "func": "E",
        "var": "x",
        "label_kind": "month",
        "index_unit": "months",
        "unit_tex": r"\text{ kWh}",
        "A_range": (80, 160),
        "D_range": (700, 950),
        "h_choices": (2, 3, 4, 5),
        "decimals": 0,
        "setup": (
            r"The function <me>@func@(@var@)=@A@\sin\left[\frac{\pi}{6}(@var@-@h@)\right]+@D@</me> "
            r"models a household's electricity use, in kilowatt-hours, in month <m>@var@</m> "
            r"of the year, where <m>@var@=1</m> represents January."
        ),
        "q_a": "What is the household's average monthly electricity use?",
        "q_b": "What is the range of the household's monthly electricity use?",
        "q_c": "What is the period of this function, and what does it mean in this context?",
        "q_d": "What is the phase shift of this function, and what does it mean in this context?",
        "q_e": (
            "Use the model to estimate the household's electricity use in @eval_label@. "
            "Round to the nearest kilowatt-hour."
        ),
        "sol_a": (
            r"The midline <m>y=D</m> is the average value of the oscillation. Here "
            r"<m>D=@D@</m>, so the household averages <m>\boxed{@D@@unit_tex@}</m> per month."
        ),
        "sol_b": (
            r"The heaviest use is in @max_label@ at <m>@max@@unit_tex@</m> and the lightest is "
            r"in @min_label@ at <m>@min@@unit_tex@</m>, so the range of monthly use is "
            r"<m>\boxed{[@min@@unit_tex@,\ @max@@unit_tex@]}</m>."
        ),
        "sol_c": r"so use follows a yearly cycle and repeats every 12 months.",
        "sol_d": (
            r"so the pattern is shifted <m>@h@</m> months to the right: use is at its average "
            r"and rising in @phase_label@, peaks in @max_label@, and bottoms out in @min_label@."
        ),
        "sol_e_tail": r"So the model gives @certainty@ <m>\boxed{@answer@}</m> in @eval_label@.",
    },

    {
        "key": "visitors",
        "func": "V",
        "var": "x",
        "label_kind": "month",
        "index_unit": "months",
        "unit_tex": r"\text{ thousand}",
        "A_range": (8, 20),
        "D_range": (30, 60),
        "h_choices": (2, 3, 4, 5),
        "decimals": 0,
        "setup": (
            r"The function <me>@func@(@var@)=@A@\sin\left[\frac{\pi}{6}(@var@-@h@)\right]+@D@</me> "
            r"models the number of visitors, in thousands, to a national park in month "
            r"<m>@var@</m> of the year, where <m>@var@=1</m> represents January."
        ),
        "q_a": "What is the average number of visitors the park receives per month, in thousands?",
        "q_b": "What is the range of the park's monthly number of visitors, in thousands?",
        "q_c": "What is the period of this function, and what does it mean in this context?",
        "q_d": "What is the phase shift of this function, and what does it mean in this context?",
        "q_e": (
            "Use the model to estimate the number of visitors in @eval_label@. "
            "Round to the nearest thousand visitors."
        ),
        "sol_a": (
            r"The midline <m>y=D</m> is the average value of the oscillation. Here "
            r"<m>D=@D@</m>, so the park averages <m>\boxed{@D@@unit_tex@}</m> visitors per month."
        ),
        "sol_b": (
            r"The busiest month is @max_label@ with <m>@max@@unit_tex@</m> visitors and the "
            r"slowest is @min_label@ with <m>@min@@unit_tex@</m>, so the range is "
            r"<m>\boxed{[@min@@unit_tex@,\ @max@@unit_tex@]}</m>."
        ),
        "sol_c": r"so visitation follows a yearly cycle and repeats every 12 months.",
        "sol_d": (
            r"so the pattern is shifted <m>@h@</m> months to the right: attendance is at its "
            r"average and climbing in @phase_label@, peaks in @max_label@, and is lowest in "
            r"@min_label@."
        ),
        "sol_e_tail": r"So the model gives @certainty@ <m>\boxed{@answer@}</m> visitors in @eval_label@.",
    },

    {
        "key": "ferris",
        "func": "H",
        "var": "t",
        "label_kind": "minute",
        "index_unit": "minutes",
        "unit_tex": r"\text{ ft}",
        "A_range": (16, 24),
        "D_range": (30, 42),
        "h_choices": (1, 2, 3),
        "decimals": 1,
        "setup": (
            r"The function <me>@func@(@var@)=@A@\sin\left[\frac{\pi}{6}(@var@-@h@)\right]+@D@</me> "
            r"models a rider's height, in feet, above the ground on a Ferris wheel, where "
            r"<m>@var@</m> is the number of minutes after the ride starts."
        ),
        "q_a": "What is the rider's average height above the ground during one full revolution?",
        "q_b": "What are the rider's greatest and least heights above the ground?",
        "q_c": "What is the period of this function, and what does it mean in this context?",
        "q_d": "What is the phase shift of this function, and what does it mean in this context?",
        "q_e": (
            "Use the model to estimate the rider's height @eval_label@. "
            "Round to the nearest tenth of a foot."
        ),
        "sol_a": (
            r"The midline <m>y=D</m> is the average value of the oscillation, and for a rider "
            r"on a wheel that is the height of the wheel's center, because the rider spends "
            r"equal time above and below it. Here <m>D=@D@</m>, so the rider averages "
            r"<m>\boxed{@D@@unit_tex@}</m> above the ground."
        ),
        "sol_b": (
            r"The rider reaches a maximum of <m>@max@@unit_tex@</m> @max_label@ and a minimum "
            r"of <m>@min@@unit_tex@</m> @min_label@, so the range of heights is "
            r"<m>\boxed{[@min@@unit_tex@,\ @max@@unit_tex@]}</m>. That minimum is also the "
            r"height of the boarding platform."
        ),
        "sol_c": r"so the wheel makes one full revolution every 12 minutes.",
        "sol_d": (
            r"so the ride is shifted <m>@h@</m> minutes: the rider is at the height of the "
            r"center and rising @phase_label@, reaches the top @max_label@, and is lowest "
            r"@min_label@."
        ),
        "sol_e_tail": r"So the model gives @certainty@ <m>\boxed{@answer@}</m> @eval_label@.",
    },
]


# ===========================================================================
# VARIANT CONTROL -- the only lines you edit to pin a variant.
#
#   VARIANT_CONTEXT = None          -> random context each seed (default)
#   VARIANT_CONTEXT = "tide"        -> always the harbor tide
#
#   VARIANT_PARAMS  = None          -> draw fresh numbers each seed
#   VARIANT_PARAMS  = {"A": 18, "D": 55, "h": 3}   -> lock the numbers too,
#                                                      reproducing last year's
#                                                      temperature item exactly
#
# Valid VARIANT_CONTEXT values:
#   temperature, tide, daylight, reservoir, electricity, visitors, ferris
#
# If you pin params: A must be even, h must be one of that context's
# h_choices, and D - A must be nonnegative.
# ===========================================================================
VARIANT_CONTEXT = "daylight"
VARIANT_PARAMS = None


def select_context():
    """Return the pinned context, or a random one when nothing is pinned."""
    if VARIANT_CONTEXT is None:
        return random.choice(CONTEXTS)
    for ctx in CONTEXTS:
        if ctx["key"] == VARIANT_CONTEXT:
            return ctx
    raise ValueError(
        "VARIANT_CONTEXT %r is not one of %s"
        % (VARIANT_CONTEXT, [c["key"] for c in CONTEXTS])
    )


def check_params(ctx, A, D, h):
    """Fail loudly instead of silently emitting a broken or ugly item."""
    if A % 2 != 0:
        raise ValueError(
            "A must be even so part (e) has a tidy exact value; got %r" % (A,)
        )
    if h not in ctx["h_choices"]:
        raise ValueError(
            "h must be one of %s for context %r; got %r"
            % (list(ctx["h_choices"]), ctx["key"], h)
        )
    if D - A < 0:
        raise ValueError(
            "D - A must be nonnegative in %r; got D=%r, A=%r" % (ctx["key"], D, A)
        )


class Generator(BaseGenerator):

    def data(self):
        ctx = select_context()

        # ---- parameters ---------------------------------------------------
        if VARIANT_PARAMS is not None:
            A = int(VARIANT_PARAMS["A"])
            D = int(VARIANT_PARAMS["D"])
            h = int(VARIANT_PARAMS["h"])
            check_params(ctx, A, D, h)
        else:
            lo, hi = ctx["A_range"]
            A = random.randrange(lo, hi + 1, 2)          # even amplitude
            D = random.randint(*ctx["D_range"])
            h = random.choice(ctx["h_choices"])

        func = ctx["func"]
        var = ctx["var"]
        unit = ctx["unit_tex"]
        dec = ctx["decimals"]

        max_val = D + A
        min_val = D - A

        # ---- labels -------------------------------------------------------
        def label(n):
            kind = ctx["label_kind"]
            if kind == "month":
                return month_name(n)
            if kind == "hour":
                return clock(n)
            return "at %d minutes after the ride starts" % int(n)

        # sin = 1 three units after the phase shift; sin = -1 nine units after
        # it, which is the same as three units before, plus one full period.
        max_label = label(h + 3)
        min_label = label(h + 9)
        phase_label = label(h)
        second_max = label(h + 15)
        second_min = label(h + 21)

        # ---- part (e) input -----------------------------------------------
        # ALLOWED OFFSETS. k <= 12 - h keeps the substituted input inside the
        # first cycle, so the angle really is k*pi/6 and no modular reduction
        # needs explaining. When the context rounds to a whole unit, only the
        # +-1/2 offsets are allowed, because D +- A*sqrt(3)/2 is irrational.
        allowed = [k for k in EVAL_OFFSETS if k <= 12 - int(h)]
        if dec == 0:
            allowed = [k for k in allowed if k in HALF_OFFSETS]
        if not allowed:
            raise ValueError(
                "no valid part (e) offset for context %r with h=%r"
                % (ctx["key"], h)
            )
        k = random.choice(allowed)
        eval_x = int(h) + k
        eval_label = label(eval_x)

        # Reduce k*pi/6 so the displayed angle is in lowest terms.
        if k == 1:
            angle_tex = r"\frac{\pi}{6}"
        else:
            g = gcd(k, 6)
            num, den = k // g, 6 // g
            if num == 1:
                angle_tex = r"\frac{\pi}{%d}" % den
            elif den == 1:
                angle_tex = r"%d\pi" % num
            else:
                angle_tex = r"\frac{%d\pi}{%d}" % (num, den)

        # ---- part (e) arithmetic ------------------------------------------
        if k in HALF_OFFSETS:
            sign = 1 if k in (1, 5) else -1
            sine_tex = r"\frac{1}{2}" if sign > 0 else r"-\frac{1}{2}"
            exact_val = Integer(D) + sign * (Integer(A) // 2)
            exact_tex = str(int(exact_val))
            certainty = "exactly"
        else:
            sign = 1 if k in (2, 4) else -1
            sine_tex = r"\frac{\sqrt{3}}{2}" if sign > 0 else r"-\frac{\sqrt{3}}{2}"
            exact_val = Integer(D) + sign * Integer(A) * sqrt(3) / 2
            if sign > 0:
                exact_tex = r"\frac{%d\sqrt{3}}{2}+%d" % (A, D)
            else:
                exact_tex = r"-\frac{%d\sqrt{3}}{2}+%d" % (A, D)
            certainty = "approximately"

        if dec == 0 and certainty != "exactly":
            # Unreachable: decimals = 0 contexts restrict k to HALF_OFFSETS.
            raise ValueError(
                "internal: irrational evaluation in an integer-rounding context"
            )

        second_line = (
            "=" + str(A) + r"\left(" + sine_tex + r"\right)+"
            + str(D) + "=" + exact_tex
        )

        approx = round(float(exact_val), dec)
        approx_txt = (("%%.%df" % dec) % approx)
        answer_tex = approx_txt + unit

        # ---- tokens -------------------------------------------------------
        hemi = "Northern" if int(h) == 3 else "Southern"
        tok = {
            "A": A,
            "D": D,
            "h": h,
            "func": func,
            "var": var,
            "unit_tex": unit,
            "index_unit": ctx["index_unit"],
            "max": max_val,
            "min": min_val,
            "max_label": max_label,
            "min_label": min_label,
            "phase_label": phase_label,
            "second_max": second_max,
            "second_min": second_min,
            "eval_x": eval_x,
            "eval_label": eval_label,
            "angle_tex": angle_tex,
            "sine_tex": sine_tex,
            "exact_tex": exact_tex,
            "answer": answer_tex,
            "approx": approx_txt,
            "certainty": certainty,
            "hemi": hemi,
        }

        # ---- solution -----------------------------------------------------
        # Every backslash below sits inside a raw string. A non-raw string here
        # turns \f into a form feed and \r into a carriage return, silently.
        solution_steps = "\n".join([
            "    <p><em>Part (a).</em> "
            + fill(ctx["sol_a"], **tok) + "</p>",

            "    <p><em>Part (b).</em> The amplitude is <m>A=" + str(A)
            + "</m>, so the quantity rises <m>" + str(A)
            + "</m> above the average value and falls <m>" + str(A)
            + "</m> below it:</p>",

            "    <p><m>" + fill(
                r"\text{maximum}=@D@+@A@=@max@@unit_tex@"
                r"\qquad\text{minimum}=@D@-@A@=@min@@unit_tex@", **tok)
            + "</m></p>",

            "    <p>" + fill(ctx["sol_b"], **tok) + "</p>",

            "    <p><em>Part (c).</em> Here <m>B=" + r"\frac{\pi}{6}"
            + "</m>, so the period is</p>",

            "    <p><m>"
            + r"\text{Period}=\frac{2\pi}{B}=\frac{2\pi}{\pi/6}"
            + r"=2\pi\cdot\frac{6}{\pi}=12"
            + "</m></p>",

            "    <p>The period is <m>" + r"\boxed{12}" + "</m> " + ctx["index_unit"]
            + ", and " + fill(ctx["sol_c"], **tok) + "</p>",

            "    <p><em>Part (d).</em> The phase shift is the value of <m>" + var
            + "</m> that makes the argument of the sine equal to zero:</p>",

            "    <p><m>" + fill(
                r"\frac{\pi}{6}(@var@-@h@)=0 \implies @var@-@h@=0 \implies @var@=@h@",
                **tok)
            + "</m></p>",

            "    <p>The phase shift is <m>" + r"\boxed{" + str(int(h)) + "}</m> "
            + ctx["index_unit"] + ", and " + fill(ctx["sol_d"], **tok) + "</p>",

            "    <p><em>Part (e).</em> Substitute <m>" + var + "=" + str(eval_x)
            + "</m> (" + eval_label + "):</p>",

            "    <p><m>" + fill(
                r"@func@(@eval_x@)=@A@\sin\left[\frac{\pi}{6}(@eval_x@-@h@)\right]+@D@"
                r"=@A@\sin\left(@angle_tex@\right)+@D@", **tok)
            + "</m></p>",

            "    <p><m>" + second_line + "</m></p>",

            "    <p>" + fill(ctx["sol_e_tail"], **tok) + "</p>",
        ])

        return {
            "scenario_text": spatext_math(fill(ctx["setup"], **tok)),
            "part_a": fill(ctx["q_a"], **tok),
            "part_b": fill(ctx["q_b"], **tok),
            "part_c": fill(ctx["q_c"], **tok),
            "part_d": fill(ctx["q_d"], **tok),
            "part_e": fill(ctx["q_e"], **tok),
            "solution_steps": solution_steps,
            "context": ctx["key"],
            "answer_a": str(D),
            "answer_b": "[%d,%d]" % (min_val, max_val),
            "answer_c": "12",
            "answer_d": str(int(h)),
            "answer_e": approx_txt,
        }
