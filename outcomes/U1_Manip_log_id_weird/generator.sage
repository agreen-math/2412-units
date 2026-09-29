import random

class Generator(BaseGenerator):
    def data(self):
        # Randomize the exponents and the root index
        m_pow = random.choice([1, 2, 3])
        n_root = random.choice([2, 3, 4])
        p_pow = random.choice([2, 3, 4])

        # Randomize the given logarithm values
        m_val = random.randint(2, 9)
        # Force n_val to be a multiple of n_root for clean integer division in the steps
        n_val = n_root * random.randint(2, 6) 
        p_val = random.randint(2, 9)

        # Dynamically build the LaTeX for the logarithmic expression to preserve strict formatting
        m_part = f"m^{{{m_pow}}}" if m_pow > 1 else "m"
        n_part = rf"\sqrt[{n_root}]{{n-1}}" if n_root > 2 else r"\sqrt{n-1}"
        num = f"{m_part}{n_part}"
        den = f"p^{{{p_pow}}}" if p_pow > 1 else "p"
        
        expr_latex = rf"\log_b\left(\frac{{{num}}}{{{den}}}\right)"

        # Construct the first step string to mirror the handwritten exemplar
        term1_str = f"{m_pow}({m_val})" if m_pow > 1 else f"{m_val}"
        term2_str = rf"\frac{{1}}{{{n_root}}}({n_val})"
        term3_str = f"{p_pow}({p_val})" if p_pow > 1 else f"{p_val}"
        
        step1 = rf"{term1_str} + {term2_str} - {term3_str}"

        # Calculate the intermediate arithmetic values
        val1 = m_pow * m_val
        val2 = n_val // n_root
        val3 = p_pow * p_val

        step2 = f"{val1} + {val2} - {val3}"
        
        # Calculate the final boxed solution
        final_sol = val1 + val2 - val3

        # Construct the solution steps dynamically, adhering to the Zero-Text Rule
        solution_steps = (
            f"    <p><m>{step1}</m></p>\n"
            f"    <p><m>{step2}</m></p>\n"
            f"    <p><m>\\boxed{{{final_sol}}}</m></p>\n"
        )

        return {
            "m_val": m_val,
            "n_val": n_val,
            "p_val": p_val,
            "expr_latex": expr_latex,
            "solution_steps": solution_steps
        }