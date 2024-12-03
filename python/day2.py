import random
import time
from functools import wraps


def benchmark(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        times = []
        result = 0
        for i in range(10):
            print(f"{func.__name__} iteration #{i}...", end="")
            start = time.perf_counter()
            result = func(*args, **kwargs)
            end = time.perf_counter()
            times.append(end - start)
            print(f" => {times[-1]:.6f} seconds")

        print(f"{func.__name__}:")
        print(f"  Min: {min(times):.6f} seconds")
        print(f"  Max: {max(times):.6f} seconds")
        print(f"  Avg: {sum(times)/len(times):.6f} seconds")
        return result

    return wrapper


def is_safe_brute(lvl):
    return all(
        abs(a - b) <= 3 and (lvl[0] - lvl[1]) * (a - b) > 0
        for a, b in zip(lvl, lvl[1:])
    )


@benchmark
def solve_part1(input):
    return sum(
        is_safe_brute(level)
        for level in [
            [int(i) for i in line.split()] for line in input.strip().splitlines()
        ]
    )


@benchmark
def solve_part2_brute(input):
    return sum(
        any(is_safe_brute(level[:i] + level[i + 1 :]) for i in range(len(level)))
        for level in [
            [int(i) for i in line.split()] for line in input.strip().splitlines()
        ]
    )


def is_safe(lvl):
    direction = lvl[0] - lvl[1]
    for i in range(len(lvl) - 1):
        diff = lvl[i] - lvl[i + 1]
        if abs(diff) > 3 or diff * direction <= 0:
            return False, i
    return True, -1


@benchmark
def solve_part2(input):
    levels = [[int(i) for i in line.split()] for line in input.strip().splitlines()]
    sum = 0
    for level in levels:
        ok, i = is_safe(level)
        if (
            ok
            or is_safe(level[:i] + level[i + 1 :])[0]
            or is_safe(level[: i + 1] + level[i + 2 :])[0]
            or i > 0 and is_safe(level[: i - 1] + level[i:])[0]
        ):
            sum += 1
    return sum


if __name__ == "__main__":
    with open("day2.input", "r") as f:
        input = f.read()
    print("Safe reports (part 1):", solve_part1(input))
    print("Safe reports (part 2):", solve_part2(input))

    print("Generating test data for benchmarking...")
    input = "\n".join(
        " ".join(str(random.randint(0, 9999)) for _ in range(1000)) for _ in range(1000)
    )
    print("Benchmarking...")
    print("Optimised result:", solve_part2(input))
    print("Bruteforced result:", solve_part2_brute(input))
