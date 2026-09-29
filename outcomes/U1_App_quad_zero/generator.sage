from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        t = var("t")
        
        subject = choice(["model rocket", "firework", "flare", "water balloon", "cannonball"])
        location = choice(["hill", "platform", "cliff", "tower", "building"])
        surface = choice(["lake", "ground", "field", "valley"])
        
        while True:
            t_land = randint(3, 12)
            t_neg = randint(-6, -1)
            
            if t_land > abs(t_neg):
                break
        
        v0 = 16 * (t_land + t_neg)
        h0 = -16 * (t_land * t_neg)
        
        equation = rf"h(t) = -16t^2 + {v0}t + {h0}"
        
        step1 = rf"-16t^2 + {v0}t + {h0} = 0"
        
        b_div = -(t_land + t_neg)
        c_div = t_land * t_neg
        
        if b_div == 1:
            sign_b = " + t"
        elif b_div == -1:
            sign_b = " - t"
        elif b_div > 0:
            sign_b = f" + {b_div}t"
        elif b_div < 0:
            sign_b = f" - {abs(b_div)}t"
        else:
            sign_b = ""
            
        sign_c = f" + {c_div}" if c_div > 0 else f" - {abs(c_div)}"
        
        step2 = rf"t^2{sign_b}{sign_c} = 0"
        
        fac1 = t - t_land
        fac2 = t - t_neg
        step3 = rf"({latex(fac1)})({latex(fac2)}) = 0"
        
        final_ans = rf"t = {t_land} \text{{ seconds}}"
        
        return {
            "subject": subject,
            "location": location,
            "surface": surface,
            "h0": h0,
            "equation": equation,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "final_ans": final_ans
        }