from sage.all import *
from random import randint, choice, sample, shuffle

class Generator(BaseGenerator):
    def data(self):
        base_func = choice([r"\ln", r"\log"])
        v_rad, v_norm, v_split = sample(['x', 'y', 'z', 'a', 'b', 'c'], 3)
        
        rad_idx = choice([2, 3])
        rad_sign = choice([-1, 1])
        
        c_norm = choice([-4, -3, -2, 2, 3, 4])
        
        c_split_total = choice([-3, -2, -1, 1, 2, 3])
        c_split1 = randint(1, 4) if choice([True, False]) else randint(-4, -1)
        c_split2 = c_split_total - c_split1
        while c_split2 == 0:
            c_split1 = randint(1, 4) if choice([True, False]) else randint(-4, -1)
            c_split2 = c_split_total - c_split1
            
        components = [
            {'var': v_rad, 'sign': rad_sign, 'abs_val': 1, 'is_rad': True, 'rad_idx': rad_idx},
            {'var': v_norm, 'sign': 1 if c_norm > 0 else -1, 'abs_val': abs(c_norm), 'is_rad': False},
            {'var': v_split, 'sign': 1 if c_split1 > 0 else -1, 'abs_val': abs(c_split1), 'is_rad': False},
            {'var': v_split, 'sign': 1 if c_split2 > 0 else -1, 'abs_val': abs(c_split2), 'is_rad': False}
        ]
        shuffle(components)
        
        expr = ""
        step1 = ""
        num_factors = []
        den_factors = []
        
        for i, comp in enumerate(components):
            sign = comp['sign']
            var = comp['var']
            abs_val = comp['abs_val']
            is_rad = comp['is_rad']
            
            if abs_val == 1 and not is_rad:
                coeff_str = ""
            elif is_rad:
                coeff_str = rf"\frac{{1}}{{{comp['rad_idx']}}}"
            else:
                coeff_str = str(abs_val)
                
            term_str = rf"{coeff_str}{base_func} {var}"
            
            if sign > 0:
                if i == 0: expr += term_str
                else: expr += rf" + {term_str}"
            else:
                if i == 0: expr += rf"-{term_str}"
                else: expr += rf" - {term_str}"
                    
            if abs_val == 1 and not is_rad:
                pow_str = var
            elif is_rad:
                pow_str = rf"{var}^{{1/{comp['rad_idx']}}}"
            else:
                pow_str = rf"{var}^{{{abs_val}}}"
                
            step1_term = rf"{base_func}({pow_str})"
            if sign > 0:
                if i == 0: step1 += step1_term
                else: step1 += rf" + {step1_term}"
            else:
                if i == 0: step1 += rf"-{step1_term}"
                else: step1 += rf" - {step1_term}"

            if is_rad:
                factor_str = rf"\sqrt{{{var}}}" if comp['rad_idx'] == 2 else rf"\sqrt[{comp['rad_idx']}]{{{var}}}"
            else:
                factor_str = rf"{var}^{{{abs_val}}}" if abs_val != 1 else var
                
            if sign > 0:
                num_factors.append(factor_str)
            else:
                den_factors.append(factor_str)
                
        num_factors.sort()
        den_factors.sort()
        
        num_str = " ".join(num_factors) if num_factors else "1"
        den_str = " ".join(den_factors) if den_factors else "1"
        
        if den_str == "1":
            step2 = rf"{base_func}\left( {num_str} \right)"
        else:
            step2 = rf"{base_func}\left( \frac{{{num_str}}}{{{den_str}}} \right)"
            
        ans_num = []
        ans_den = []
        
        if rad_sign > 0:
            ans_num.append(rf"\sqrt{{{v_rad}}}" if rad_idx == 2 else rf"\sqrt[{rad_idx}]{{{v_rad}}}")
        else:
            ans_den.append(rf"\sqrt{{{v_rad}}}" if rad_idx == 2 else rf"\sqrt[{rad_idx}]{{{v_rad}}}")
            
        if c_norm > 0: 
            ans_num.append(rf"{v_norm}" if c_norm == 1 else rf"{v_norm}^{{{c_norm}}}")
        else: 
            ans_den.append(rf"{v_norm}" if -c_norm == 1 else rf"{v_norm}^{{{-c_norm}}}")
            
        if c_split_total > 0: 
            ans_num.append(rf"{v_split}" if c_split_total == 1 else rf"{v_split}^{{{c_split_total}}}")
        elif c_split_total < 0: 
            ans_den.append(rf"{v_split}" if -c_split_total == 1 else rf"{v_split}^{{{-c_split_total}}}")
        
        ans_num.sort()
        ans_den.sort()
        
        ans_num_str = " ".join(ans_num) if ans_num else "1"
        ans_den_str = " ".join(ans_den) if ans_den else "1"
        
        if ans_den_str == "1":
            ans = rf"{base_func}\left( {ans_num_str} \right)"
        else:
            ans = rf"{base_func}\left( \frac{{{ans_num_str}}}{{{ans_den_str}}} \right)"
            
        return {
            "expr": expr,
            "step1": step1,
            "step2": step2,
            "ans": ans
        }