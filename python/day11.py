import functools
import time
from math import log10


def solve(input: list, n: int):
    return sum(blink(stone, n) for stone in input)


cache = {}
# The caching behaviour can be simplified with @functools.cache,
# but I'm doing it manually for learning purposes
def blink(stone: int, depth: int):
    key = (stone, depth)
    if key in cache:
        return cache[key]
    if depth == 0:
        return 1
    if stone == 0:
        value = blink(1, depth - 1)
    elif stone > 9:
        # n = number of digits (avoids string operations)
        n, m = divmod(int(log10(stone)) + 1, 2)
        if m % 2 == 0:
            a, b = divmod(stone, 10**n)
            value = blink(a, depth - 1) + blink(b, depth - 1)
        else:
            value = blink(stone * 2024, depth - 1)
    else:
        value = blink(stone * 2024, depth - 1)
    cache[key] = value
    return value


# Just documenting what the @functools.cache version would be
@functools.cache
def blink_functools(stone: int, depth: int):
    if depth == 0:
        return 1
    if stone == 0:
        return blink(1, depth - 1)
    elif stone > 9:
        # n = number of digits (avoids string operations)
        n, m = divmod(int(log10(stone)) + 1, 2)
        if m % 2 == 0:
            a, b = divmod(stone, 10**n)
            return blink(a, depth - 1) + blink(b, depth - 1)
    return blink(stone * 2024, depth - 1)


if __name__ == "__main__":
    with open("day11.input", "r") as f:
        input = f.read()

    input = [int(n) for n in input.strip().split()]

    start = time.perf_counter()
    result = solve(input, 25)
    end = time.perf_counter()
    print(f"Part 1: {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve(input, 75)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
