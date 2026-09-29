from sage.all import *
from random import randint, choice, sample

class Generator(BaseGenerator):
    def data(self):
        b = choice([2, 3, 5])
        
        m = randint(2, 4)
        n = randint(1, 2)
        while m <= n:
            m = randint(2, 4)
            
        A = b**m
        B = b**n
        
        v1, v2 = sample(['x', 'y', 'z', 'w'], 2)
        p = randint(2, 4)
        q = randint(1, 3)
        
        q_str = rf"^{{{q}}}" if q > 1 else ""
        
        expr = rf"\displaystyle \log_{{{b}}}\left( \frac{{{A}{v1}^{{{p}}}}}{{{B}{v2}{q_str}}} \right)"
        
        q_log_str = rf"{q}\log_{{{b}}}({v2})" if q > 1 else rf"\log_{{{b}}}({v2})"
        
        step1 = rf"\log_{{{b}}}({A}) + {p}\log_{{{b}}}({v1}) - \log_{{{b}}}({B}) - {q_log_str}"
        step2 = rf"{m} + {p}\log_{{{b}}}({v1}) - {n} - {q_log_str}"
        ans = rf"{m-n} + {p}\log_{{{b}}}({v1}) - {q_log_str}"
        
        return {
            "expr": expr,
            "step1": step1,
            "step2": step2,
            "ans": ans
        }