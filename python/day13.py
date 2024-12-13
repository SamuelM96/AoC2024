import time

# The "fewest tokens" bit is a red herring! I thought it was a variation
# on the classic coins dynamic programming problem, but it's just solving
# linear equations instead. Realistically, we did a dynamic programming
# problem for day 11, so it's unlikely to repeat the problem type so soon...
#
# Button A: X+94, Y+34
# Button B: X+22, Y+67
# Prize: X=8400, Y=5400
#
# Using Gaussian Elimination with two equations
#
# px = 94*a + 22*b = 8400
# py = 34*a + 67*b = 5400
#
# px = (94*34)*a + (22*34)*b = 8400*34
# py = (34*94)*a + (67*94)*b = 5400*94
#
# e = px - py
# e = (22*34)*b - (67*94)*b = 8400*34 - 5400*94
# e = (22*34 - 67*94)*b = 8400*34 - 5400*94
# b = (8400*34 - 5400*94) / (22*34 - 67*94)
#
# b = (px*ay - py*ax) / (bx*ay - by*ax)
#
# 94*a + 22*b = 8400
# a = (8400 - 22*b)/94
# a = (px - bx*b)/ax
#
# Invalid solutions will have a fractional part


def solve(input, part2):
    total = 0
    for (ax, ay), (bx, by), (px, py) in input:
        if part2:
            px += 10000000000000
            py += 10000000000000
        b = (px * ay - py * ax) / (bx * ay - by * ax)
        a = (px - bx * b) / ax
        total += int(a * 3 + b) if a == int(a) and b == int(b) else 0
    return total


def parse_challenge(challenge: str):
    a, b, prize = challenge.splitlines()
    a, b, prize = a.split(), b.split(), prize.split()

    ax = int(a[2].split("+")[1][:-1])
    ay = int(a[3].split("+")[1])
    bx = int(b[2].split("+")[1][:-1])
    by = int(b[3].split("+")[1])

    px = int(prize[1].split("=")[1][:-1])
    py = int(prize[2].split("=")[1])

    return (ax, ay), (bx, by), (px, py)


if __name__ == "__main__":
    with open("day13.input", "r") as f:
        input = f.read()

    input = [parse_challenge(challenge) for challenge in input.strip().split("\n\n")]

    start = time.perf_counter()
    result = solve(input, False)
    end = time.perf_counter()
    print(f"Part 1: {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve(input, True)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
