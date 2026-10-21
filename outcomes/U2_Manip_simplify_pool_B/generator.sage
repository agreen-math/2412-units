load("shared/pool.sage")


class Generator(BaseGenerator):
    def data(self):
        return draw(
            "outcomes/U2_Manip_simplify_v1/generator.sage",
            "outcomes/U2_Manip_simplify_v6/generator.sage",
        )
