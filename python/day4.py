from itertools import product


def solve_part1(data):
    directions = list(product([-1, 0, 1], repeat=2))
    directions.remove((0, 0))
    width = len(data[0])
    height = len(data)

    sum = 0
    for y in range(height):
        for x in range(width):
            if data[y][x] != "X":
                continue
            for dx, dy in directions:
                for i, c in enumerate("XMAS"):
                    px = x + i * dx
                    py = y + i * dy
                    if (
                        px < 0
                        or px >= width
                        or py < 0
                        or py >= height
                        or data[py][px] != c
                    ):
                        break
                else:
                    sum += 1

    return sum


def solve_part2(data):
    sum = 0
    for y in range(1, len(data) - 1):
        for x in range(1, len(data[0]) - 1):
            if data[y][x] != "A":
                continue
            count = 0
            if data[y - 1][x - 1] == "M" and data[y + 1][x + 1] == "S":
                count += 1
            if data[y + 1][x - 1] == "M" and data[y - 1][x + 1] == "S":
                count += 1
            if data[y - 1][x - 1] == "S" and data[y + 1][x + 1] == "M":
                count += 1
            if data[y + 1][x - 1] == "S" and data[y - 1][x + 1] == "M":
                count += 1
            sum += 1 if count == 2 else 0

    return sum


with open("day4.input", "r") as f:
    input = f.read()

data = [[c for c in line] for line in input.splitlines()]

print(f"Part 1: {solve_part1(data)}")
print(f"Part 2: {solve_part2(data)}")
