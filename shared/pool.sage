# shared/pool.sage
# Draw one exercise from a pool of existing generator.sage files.
import os
import random

_pool_cache = {}


def _pooled_generator(path):
    """Execute a generator.sage in a private namespace; return its Generator class."""
    if path in _pool_cache:
        return _pool_cache[path]
    if not os.path.exists(path):
        raise RuntimeError("Pool entry not found (paths are relative to the bank root): " + path)
    ns = {
        "__name__": "pooled_" + os.path.basename(os.path.dirname(path)),
        "__file__": path,
        "BaseGenerator": BaseGenerator,
    }
    with open(path) as f:
        exec(compile(f.read(), path, "exec"), ns)
    if "Generator" not in ns:
        raise RuntimeError("No Generator class found in " + path)
    _pool_cache[path] = ns["Generator"]
    return _pool_cache[path]


def draw(*entries):
    """
    Pick one entry and return its data dict.
    Each entry is either "outcomes/X/generator.sage" or ("outcomes/X/generator.sage", weight).
    """
    paths = [e[0] if isinstance(e, tuple) else e for e in entries]
    weights = [e[1] if isinstance(e, tuple) else 1 for e in entries]
    path = random.choices(paths, weights=weights, k=1)[0]
    return _pooled_generator(path)().data()