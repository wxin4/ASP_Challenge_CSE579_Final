#script (python)

from clingo import Function

def get(val, default):
    return val if val != None else default

def main(prg):
    imin   = get(prg.get_const("imin"), 1)
    imax   = prg.get_const("imax")
    istop  = get(prg.get_const("istop"), "SAT")

    step, ret = 0, None
    while ((imax is None or step < imax) and
           (step == 0 or step < imin or (
              (istop == "SAT"     and not ret.satisfiable) or
              (istop == "UNSAT"   and not ret.unsatisfiable) or
              (istop == "UNKNOWN" and not ret.unknown)))):
        parts = []
        parts.append(("check", [step]))
        if step > 0:
            prg.release_external(Function("query", [step-1]))
            parts.append(("step", [step]))
            prg.cleanup()
        else:
            parts.append(("base", []))
        prg.ground(parts)
        prg.assign_external(Function("query", [step]), True)
        ret, step = prg.solve(), step+1
#end.

#program check(t).
#external query(t).