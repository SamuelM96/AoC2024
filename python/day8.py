import time


def solve(map: list, extend: bool):
    points = get_points(map)
    height, width = len(map), len(map[0])
    antinodes = set()
    total = len(points)

    if extend:
        map = [list(row) for row in map]

    for i, (c1, x1, y1) in enumerate(points):
        for j, (c2, x2, y2) in enumerate(points):
            if i == j or c1 != c2:
                continue
            dx, dy = x1 - x2, y1 - y2
            px, py = x1 + dx, y1 + dy
            while 0 <= px < width and 0 <= py < height:
                antinodes.add((px, py))
                if not extend:
                    break
                if map[py][px] == ".":
                    map[py][px] = "#"
                    total += 1
                px, py = px + dx, py + dy
    return total if extend else len(antinodes)


def get_points(input):
    return [
        (c, x, y) for y, row in enumerate(input) for x, c in enumerate(row) if c != "."
    ]


if __name__ == "__main__":
    with open("day8.input", "r") as f:
        input = f.read()

    input = [list(line) for line in input.strip().splitlines()]

    start = time.perf_counter()
    result = solve(input, False)
    end = time.perf_counter()
    print(f"Part 1: {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve(input, True)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
