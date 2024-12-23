import re


def solve_part1(input):
    sum = 0
    for match in re.findall(r"(mul\((\d+),(\d+)\))", input):
        sum += int(match[1]) * int(match[2])
    return sum


def solve_part2(input):
    sum = 0
    enabled = True
    for m in re.findall(r"(mul\((\d+),(\d+)\))|(do(n't)?\(\))", input):
        match m[-2]:
            case "do()":
                enabled = True
            case "don't()":
                enabled = False
            case _:
                if enabled:
                    sum += int(m[1]) * int(m[2])
    return sum


if __name__ == "__main__":
    with open("day3.input", "r") as f:
        input = f.read()

    print("Part 1:", solve_part1(input))
    print("Part 2:", solve_part2(input))
