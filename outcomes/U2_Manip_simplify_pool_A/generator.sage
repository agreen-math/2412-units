load("shared/pool.sage")


class Generator(BaseGenerator):
    def data(self):
        return draw(
            "outcomes/U2_Manip_simplify_v3/generator.sage",
            "outcomes/U2_Manip_simplify_v5/generator.sage",
            "outcomes/U2_Manip_simplify_v7/generator.sage",
        )
