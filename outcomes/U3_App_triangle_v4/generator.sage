from sage.all import *
import random
import math


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
def fill(template, **tokens):
    """Replace @token@ markers so LaTeX braces stay literal."""
    out = template
    for key, value in tokens.items():
        out = out.replace("@%s@" % key, str(value))
    return out


def draw(spec):
    """spec is (lo, hi) or (lo, hi, step)."""
    if len(spec) == 3:
        lo, hi, step = spec
        return random.randrange(lo, hi + 1, step)
    lo, hi = spec
    return random.randint(lo, hi)


def complete(v):
    """Given two of {opp, adj, hyp, ang}, fill in the other two."""
    v = dict(v)
    if v.get("ang") is not None:
        t = math.radians(v["ang"])
        if "hyp" in v:
            v["opp"] = v["hyp"] * math.sin(t)
            v["adj"] = v["hyp"] * math.cos(t)
        elif "opp" in v:
            v["adj"] = v["opp"] / math.tan(t)
            v["hyp"] = v["opp"] / math.sin(t)
        else:
            v["opp"] = v["adj"] * math.tan(t)
            v["hyp"] = v["adj"] / math.cos(t)
    else:
        if "opp" in v and "hyp" in v:
            v["ang"] = math.degrees(math.asin(v["opp"] / v["hyp"]))
            v["adj"] = math.sqrt(v["hyp"] ** 2 - v["opp"] ** 2)
        elif "adj" in v and "hyp" in v:
            v["ang"] = math.degrees(math.acos(v["adj"] / v["hyp"]))
            v["opp"] = math.sqrt(v["hyp"] ** 2 - v["adj"] ** 2)
        else:
            v["ang"] = math.degrees(math.atan(v["opp"] / v["adj"]))
            v["hyp"] = math.sqrt(v["opp"] ** 2 + v["adj"] ** 2)
    return v


def shadow_drawer():
    """Monument height and shadow length. tan(theta) = 10 / tenths, so the
    sun's angle stays between about 34 and 55 degrees."""
    opp = random.choice([20, 30, 40])
    tenths = random.randrange(7, 16)
    return {"opp": opp, "adj": opp * tenths // 10}


def ramp_drawer():
    """Rise and ramp length with a run-to-rise ratio of 10:1 to 14:1, which
    keeps the angle between about 4.1 and 5.7 degrees -- near the 1:12
    accessible-ramp maximum of about 4.76 degrees."""
    opp = random.choice([2, 3])
    hyp = random.randrange(opp * 10, opp * 14 + 1)
    return {"opp": opp, "hyp": hyp}


# ---------------------------------------------------------------------------
# Ratio and formula tables, keyed by (set of givens, unknown).
# ---------------------------------------------------------------------------
RATIOS = {
    (frozenset({"hyp", "ang"}), "opp"): ("sine",    r"\sin\theta=\dfrac{\text{opposite}}{\text{hypotenuse}}"),
    (frozenset({"hyp", "ang"}), "adj"): ("cosine",  r"\cos\theta=\dfrac{\text{adjacent}}{\text{hypotenuse}}"),
    (frozenset({"opp", "ang"}), "adj"): ("tangent", r"\tan\theta=\dfrac{\text{opposite}}{\text{adjacent}}"),
    (frozenset({"opp", "ang"}), "hyp"): ("sine",    r"\sin\theta=\dfrac{\text{opposite}}{\text{hypotenuse}}"),
    (frozenset({"adj", "ang"}), "opp"): ("tangent", r"\tan\theta=\dfrac{\text{opposite}}{\text{adjacent}}"),
    (frozenset({"adj", "ang"}), "hyp"): ("cosine",  r"\cos\theta=\dfrac{\text{adjacent}}{\text{hypotenuse}}"),
    (frozenset({"opp", "hyp"}), "ang"): ("inverse sine",    r"\sin\theta=\dfrac{\text{opposite}}{\text{hypotenuse}}"),
    (frozenset({"adj", "hyp"}), "ang"): ("inverse cosine",  r"\cos\theta=\dfrac{\text{adjacent}}{\text{hypotenuse}}"),
    (frozenset({"opp", "adj"}), "ang"): ("inverse tangent", r"\tan\theta=\dfrac{\text{opposite}}{\text{adjacent}}"),
}

FORMULAS = {
    (frozenset({"hyp", "ang"}), "opp"): r"h=@hyp@\sin(@ang_deg@^\circ)",
    (frozenset({"hyp", "ang"}), "adj"): r"d=@hyp@\cos(@ang_deg@^\circ)",
    (frozenset({"opp", "ang"}), "adj"): r"d=\frac{@opp@}{\tan(@ang_deg@^\circ)}",
    (frozenset({"opp", "ang"}), "hyp"): r"L=\frac{@opp@}{\sin(@ang_deg@^\circ)}",
    (frozenset({"adj", "ang"}), "opp"): r"h=@adj@\tan(@ang_deg@^\circ)",
    (frozenset({"adj", "ang"}), "hyp"): r"L=\frac{@adj@}{\cos(@ang_deg@^\circ)}",
    (frozenset({"opp", "hyp"}), "ang"): r"\theta=\sin^{-1}\left(\frac{@opp@}{@hyp@}\right)",
    (frozenset({"adj", "hyp"}), "ang"): r"\theta=\cos^{-1}\left(\frac{@adj@}{@hyp@}\right)",
    (frozenset({"opp", "adj"}), "ang"): r"\theta=\tan^{-1}\left(\frac{@opp@}{@adj@}\right)",
}

# How a side sits relative to the GIVEN angle.
ROLE = {
    "opp": "the leg opposite the given angle",
    "adj": "the leg adjacent to the given angle",
    "hyp": "the hypotenuse",
}

# How a side sits relative to the unknown angle theta.
ROLE_THETA = {
    "opp": r"the leg opposite <m>\theta</m>",
    "adj": r"the leg adjacent to <m>\theta</m>",
    "hyp": r"the hypotenuse",
}

# When the unknown is the angle, describe the two given sides relative to it.
PAIR_ROLE = {
    frozenset({"opp", "hyp"}): (r"the leg opposite <m>\theta</m>", r"the hypotenuse"),
    frozenset({"adj", "hyp"}): (r"the leg adjacent to <m>\theta</m>", r"the hypotenuse"),
    frozenset({"opp", "adj"}): (r"the leg opposite <m>\theta</m>",
                                r"the leg adjacent to <m>\theta</m>"),
}

GENERIC_PLACEMENT = (
    r"The given angle is stated from a horizontal reference line that is parallel to "
    r"the ground, so it is congruent to an interior angle of the right triangle (alternate "
    r"interior angles). Place the <m>@ang_deg@^\circ</m> angle at the vertex where the "
    r"line of sight meets the triangle."
)


# ---------------------------------------------------------------------------
# Adding a context = appending one dict with the same keys.
#
# vertex_hint (optional) tells the grader where the given angle belongs in the
# sketch. Only used by scenarios that state an angle of depression/elevation.
# ---------------------------------------------------------------------------
SCENARIOS = [

    {
        "id": "zipline",
        "givens": {"hyp": (100, 160, 10), "ang": (18, 30)},
        "finds": ["opp", "adj"],
        "unit": r"\text{ ft}",
        "setup": (
            r"A zipline runs in a straight line from the top of a launch platform to an "
            r"anchor point on the ground. The zipline is <m>@hyp@</m> feet long, and the "
            r"angle of depression from the top of the platform to the anchor point is "
            r"<m>@ang_deg@^\circ</m>."
        ),
        "vertex_hint": (
            r"The <m>@ang_deg@^\circ</m> angle belongs at the anchor point on the ground, "
            r"not at the top of the platform: the angle of depression stated at the top and "
            r"the angle of elevation at the anchor are alternate interior angles, with the "
            r"horizontal through the top of the platform parallel to the ground."
        ),
        "sol_ang_placement": (
            r"The angle of depression is measured downward from a horizontal line through "
            r"the top of the platform. That line is parallel to the ground, so the angle of "
            r"depression and the angle of elevation from the anchor point are alternate "
            r"interior angles and are therefore congruent. The <m>@ang_deg@^\circ</m> angle "
            r"sits inside the triangle at the anchor point."
        ),
        "phr": {
            "opp": "the height of the platform",
            "adj": "the horizontal distance from the base of the platform to the anchor point",
            "hyp": "the length of the zipline",
            "ang": "the angle of elevation from the anchor point",
        },
    },

    {
        "id": "lighthouse",
        "givens": {"opp": (90, 180, 10), "ang": (15, 32)},
        "finds": ["adj", "hyp"],
        "unit": r"\text{ ft}",
        "setup": (
            r"From the top of a lighthouse <m>@opp@</m> feet above sea level, the angle of "
            r"depression of a boat out at sea is <m>@ang_deg@^\circ</m>."
        ),
        "vertex_hint": (
            r"The <m>@ang_deg@^\circ</m> angle belongs at the boat, not at the top of the "
            r"lighthouse: the angle of depression stated at the top and the angle of "
            r"elevation at the boat are alternate interior angles, with the horizontal "
            r"through the top of the lighthouse parallel to the sea."
        ),
        "sol_ang_placement": (
            r"The angle of depression is measured downward from a horizontal line through "
            r"the top of the lighthouse. Because that line is parallel to the surface of the "
            r"sea, alternate interior angles give a congruent angle of elevation at the "
            r"boat, so the <m>@ang_deg@^\circ</m> angle is the one inside the triangle at "
            r"the boat."
        ),
        "phr": {
            "opp": "the height of the lighthouse",
            "adj": "the horizontal distance from the boat to the foot of the lighthouse",
            "hyp": "the straight-line distance from the top of the lighthouse to the boat",
            "ang": "the angle of elevation from the boat",
        },
    },

    {
        "id": "ramp",
        "drawer": ramp_drawer,
        "finds": ["ang"],
        "unit": r"\text{ ft}",
        "setup": (
            r"A wheelchair ramp is to be built beside the steps to a building. The ramp is "
            r"<m>@hyp@</m> feet long and rises <m>@opp@</m> feet to reach the door."
        ),
        "phr": {
            "opp": "the rise of the ramp",
            "adj": "the horizontal run of the ramp",
            "hyp": "the length of the ramp",
            "ang": "the angle the ramp makes with the ground",
        },
    },

    {
        "id": "kite",
        "givens": {"adj": (25, 60, 5), "ang": (40, 62)},
        "finds": ["opp", "hyp"],
        "unit": r"\text{ ft}",
        "setup": (
            r"You stand <m>@adj@</m> feet from the point on the ground directly below a kite. "
            r"The angle of elevation from your feet to the kite is <m>@ang_deg@^\circ</m>."
        ),
        "vertex_hint": (
            r"The <m>@ang_deg@^\circ</m> angle belongs at your feet on the ground, between "
            r"the horizontal ground and the line of sight to the kite. It is an interior "
            r"angle of the triangle as stated, so no conversion is needed."
        ),
        "sol_ang_placement": (
            r"The angle of elevation is measured upward from the horizontal ground at your "
            r"feet, which is already a vertex of the right triangle, so it is an interior "
            r"angle as given -- no conversion is needed."
        ),
        "phr": {
            "opp": "the height of the kite above the ground",
            "adj": "the horizontal distance from you to the point below the kite",
            "hyp": "the length of the string",
            "ang": "the angle of elevation to the kite",
        },
    },

    {
        "id": "ladder",
        "givens": {"adj": (4, 8), "hyp": (18, 28)},
        "finds": ["ang"],
        "unit": r"\text{ ft}",
        "setup": (
            r"A <m>@hyp@</m>-foot ladder leans against a wall, with its foot <m>@adj@</m> "
            r"feet from the base of the wall."
        ),
        "phr": {
            "opp": "the height the ladder reaches on the wall",
            "adj": "the distance from the foot of the ladder to the wall",
            "hyp": "the length of the ladder",
            "ang": "the angle the ladder makes with the ground",
        },
    },

    {
        "id": "shadow",
        "drawer": shadow_drawer,
        "finds": ["ang"],
        "unit": r"\text{ ft}",
        "setup": (
            r"A <m>@opp@</m>-foot monument casts a shadow <m>@adj@</m> feet long on level "
            r"ground."
        ),
        "phr": {
            "opp": "the height of the monument",
            "adj": "the length of the shadow",
            "hyp": "the distance from the tip of the shadow to the top of the monument",
            "ang": "the angle of elevation of the sun",
        },
    },
]


# ===========================================================================
# VARIANT CONTROL -- the only lines you edit to pin a variant.
#
#   VARIANT_CONTEXT = None      -> random context each seed (default)
#   VARIANT_CONTEXT = "ladder"  -> always the ladder
#
#   VARIANT_UNKNOWN = None      -> random unknown from that context's finds
#   VARIANT_UNKNOWN = "hyp"     -> always the hypotenuse
#
#   VARIANT_PARAMS  = None      -> draw fresh numbers each seed
#   VARIANT_PARAMS  = {"opp": 160, "ang": 24}   -> lock the given values too
#
# Valid VARIANT_CONTEXT values:
#   zipline, lighthouse, ramp, kite, ladder, shadow
# ===========================================================================
VARIANT_CONTEXT = "ramp"
VARIANT_UNKNOWN = "ang"
VARIANT_PARAMS  = None


def select_scenario():
    """Return the pinned scenario, or a random one when nothing is pinned."""
    if VARIANT_CONTEXT is None:
        return random.choice(SCENARIOS)
    for sc in SCENARIOS:
        if sc["id"] == VARIANT_CONTEXT:
            return sc
    raise ValueError(
        "VARIANT_CONTEXT %r is not one of %s"
        % (VARIANT_CONTEXT, [s["id"] for s in SCENARIOS])
    )


def check_givens(sc, given):
    """Fail loudly instead of silently emitting a broken triangle."""
    ok = {"opp", "adj", "hyp", "ang"}
    if not set(given) <= ok:
        raise ValueError("unknown parameter names: %s" % sorted(set(given) - ok))
    if len(given) != 2:
        raise ValueError(
            "VARIANT_PARAMS for %r must supply exactly two of %s; got %s"
            % (sc["id"], sorted(ok), sorted(given))
        )
    if "opp" in given and "hyp" in given and given["opp"] >= given["hyp"]:
        raise ValueError("opp must be smaller than hyp, or the leg overhangs")
    if "adj" in given and "hyp" in given and given["adj"] >= given["hyp"]:
        raise ValueError("adj must be smaller than hyp")
    if "ang" in given and not (1 <= given["ang"] <= 89):
        raise ValueError("angle must be strictly between 0 and 90 degrees")


class Generator(BaseGenerator):

    def data(self):
        sc = select_scenario()

        # ---- given quantities ---------------------------------------------
        if VARIANT_PARAMS is not None:
            given = dict(VARIANT_PARAMS)
            check_givens(sc, given)
        elif "drawer" in sc:
            given = sc["drawer"]()
        else:
            given = {name: draw(spec) for name, spec in sc["givens"].items()}

        v = complete(given)
        givens = frozenset(given.keys())

        # ---- unknown ------------------------------------------------------
        if VARIANT_UNKNOWN is not None:
            if VARIANT_UNKNOWN not in sc["finds"]:
                raise ValueError(
                    "%r cannot ask for %r; its finds are %s"
                    % (sc["id"], VARIANT_UNKNOWN, sc["finds"])
                )
            unk = VARIANT_UNKNOWN
        else:
            unk = random.choice(sc["finds"])

        key = (givens, unk)
        if key not in RATIOS:
            raise ValueError(
                "no ratio defined for givens=%s, unknown=%r"
                % (sorted(givens), unk)
            )
        ratio_word, ratio_eq = RATIOS[key]
        base_ratio = ratio_word.replace("inverse ", "")

        unit = sc["unit"]
        unk_name = sc["phr"][unk]
        ans_txt = "%.2f" % v[unk]

        def show(name):
            """Givens print exactly; computed values print to two places."""
            if name in given:
                return given[name]
            return "%.2f" % v[name]

        tok = {
            "opp": show("opp"),
            "adj": show("adj"),
            "hyp": show("hyp"),
            "ang_deg": show("ang"),
            "unk_name": unk_name,
            "ratio_word": ratio_word,
            "ratio_eq": ratio_eq,
            "unit": unit,
            "ans": ans_txt,
            "formula": fill(FORMULAS[key], opp=show("opp"), adj=show("adj"),
                            hyp=show("hyp"), ang_deg=show("ang")),
        }

        # ---- part (a): the sketch key --------------------------------------
        # Only the quantities actually stated in the problem get labeled, plus
        # the right angle. Anything the student must compute stays blank.
        if "ang" in givens:
            known_side = next(iter(givens - {"ang"}))
            sketch_sol = (
                r"A correct sketch shows a right triangle with the right angle marked, the "
                r"given <m>" + str(given["ang"]) + r"^\circ</m> angle placed at the correct "
                r"vertex, and the one given length written on its correct side: "
                + ROLE[known_side] + r" is <m>" + str(given[known_side]) + unit + r"</m>. "
                r"The other two side lengths are not given, so they stay unlabeled."
            )
            # vertex_hint is a template string too: run it through fill, or its
            # @ang_deg@ placeholder leaks onto the page verbatim.
            if sc.get("vertex_hint"):
                sketch_sol = sketch_sol + " " + fill(sc["vertex_hint"], **tok)
        else:
            sides = [s for s in ("opp", "adj", "hyp") if s in givens]
            labels = [
                ROLE_THETA[s] + r" is <m>" + str(given[s]) + unit + r"</m>"
                for s in sides
            ]
            sketch_sol = (
                r"A correct sketch shows a right triangle with the right angle marked and "
                r"only the two given lengths written in: " + labels[0] + " and " + labels[1]
                + r". The third side is not given, so it stays unlabeled, and the angle "
                r"should not be filled in."
            )

        # ---- part (b): find the quantity, with the ratio reasoning inside --
        paras = []

        if "ang" in givens:
            paras.append(fill(sc.get("sol_ang_placement", GENERIC_PLACEMENT), **tok))
            # frozenset has no .pop(); exactly one member remains after removing "ang".
            known_side = next(iter(givens - {"ang"}))
            paras.append(fill(
                r"Read the triangle from that angle: @unk_name@ is @unk_role@, and the "
                r"known quantity is @known_role@. The one basic ratio that uses exactly "
                r"those two sides is @ratio_word@, <m>@ratio_eq@</m>, so that is the ratio "
                r"to use.",
                unk_role=ROLE[unk], known_role=ROLE[known_side], **tok
            ))
        else:
            r1, r2 = PAIR_ROLE[givens]
            paras.append(fill(
                r"Both given quantities are lengths and the unknown is an angle, so the "
                r"answer comes from an inverse function. In the triangle the given sides are "
                r"@r1@ and @r2@; the ratio built from exactly those two sides is "
                r"@base_ratio@, <m>@ratio_eq@</m>, so we solve <m>@ratio_eq@</m> for "
                r"<m>\theta</m> using the inverse @base_ratio@.",
                r1=r1, r2=r2, base_ratio=base_ratio, **tok
            ))

        paras.append(fill(r"Substituting and computing, <m>@formula@</m>.", **tok))

        if unk == "ang":
            paras.append(fill(
                r"This gives <m>\theta \approx @ans@^\circ</m>, so @unk_name@ is "
                r"<m>\boxed{@ans@^\circ}</m>.", **tok
            ))
        else:
            paras.append(fill(
                r"So @unk_name@ is <m>\boxed{@ans@@unit@}</m>.", **tok
            ))

        b_paras = []
        for i, p in enumerate(paras):
            label = "<em>Part (b).</em> " if i == 0 else ""
            b_paras.append("    <p>" + label + p + "</p>")

        solution_steps = "\n".join(
            ["    <p><em>Part (a).</em> " + sketch_sol + "</p>"] + b_paras
        )

        return {
            "scenario_text": fill(sc["setup"], **tok),
            "find_task": "Find " + unk_name + ". Do not round until the final answer; "
                         "then round to two decimal places as necessary.",
            "solution_steps": solution_steps,
            "context": sc["id"],
            "unknown": unk,
            "answer": ans_txt,
            "answer_tex": (ans_txt + r"^\circ") if unk == "ang" else (ans_txt + unit),
        }
