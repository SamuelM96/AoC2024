from itertools import product


def solve_part1(data):
    directions = list(product([-1, 0, 1], repeat=2))
    directions.remove((0, 0))
    width = len(data[0])
    height = len(data)

    count = 0
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
                    count += 1

    return count


def solve_part2(data):
    return sum(
        sum(
            all(data[y + dy][x + dx] == p[i] for i, (dx, dy) in enumerate(d))
            for p in [("M", "S"), ("S", "M")]
            for d in [((-1, -1), (1, 1)), ((-1, 1), (1, -1))]
        )
        == 2
        for y in range(1, len(data) - 1)
        for x in range(1, len(data[0]) - 1)
        if data[y][x] == "A"
    )


with open("day4.input", "r") as f:
    input = f.read()

data = [[c for c in line] for line in input.splitlines()]

print(f"Part 1: {solve_part1(data)}")
print(f"Part 2: {solve_part2(data)}")
