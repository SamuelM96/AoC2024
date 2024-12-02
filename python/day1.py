from collections import Counter


def solve_part1():
    input = open("day1.input", "r").read().split()
    return sum(
        abs(a - b)
        for a, b in zip(
            sorted([int(i) for i in input[::2]]), sorted([int(i) for i in input[1::2]])
        )
    )


def solve_part2():
    with open("day1.input", "r") as f:
        input = [int(x) for x in f.read().split()]
    counts = Counter(input[1::2])
    return sum(x * counts[x] for x in input[::2])


if __name__ == "__main__":
    print("Part 1:", solve_part1())
    print("Part 2:", solve_part2())
