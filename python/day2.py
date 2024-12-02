def is_safe(lvl):
    return all(
        abs(a - b) <= 3 and (lvl[0] - lvl[1]) * (a - b) > 0
        for a, b in zip(lvl, lvl[1:])
    )


def solve_part1(input):
    return sum(
        is_safe(level)
        for level in [
            [int(i) for i in line.split()] for line in input.strip().splitlines()
        ]
    )


def solve_part2(input):
    return sum(
        any(is_safe(level[:i] + level[i + 1 :]) for i in range(len(level)))
        for level in [
            [int(i) for i in line.split()] for line in input.strip().splitlines()
        ]
    )


if __name__ == "__main__":
    with open("day2.input", "r") as f:
        input = f.read()
    print("Safe reports (part 1):", solve_part1(input))
    print("Safe reports (part 2):", solve_part2(input))
