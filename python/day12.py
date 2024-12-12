import time


def solve_part1(input):
    return sum(len(blob) * len(surrounding) for blob, surrounding in blobify(input))


def count_corners(blob):
    min_x, min_y = min(x for x, _ in blob), min(y for _, y in blob)
    max_x, max_y = max(x for x, _ in blob), max(y for _, y in blob)
    corners = 0

    # Blob can be up against the bounds of the grid, so account for the
    # additional out-of-bounds space
    for x in range(min_x - 1, max_x + 2):
        for y in range(min_y - 1, max_y + 2):
            # 2x2 sliding window across the blob to perform corner detection
            quadrants = [
                (x, y) in blob,
                (x - 1, y) in blob,
                (x - 1, y - 1) in blob,
                (x, y - 1) in blob,
            ]
            filled = sum(quadrants)

            if filled == 1 or filled == 3:
                # Convex and concave corner cases
                # . .  # A .
                # A .  # A A
                corners += 1
            elif filled == 2:
                # Diagonal corners for shapes with holes
                # A .   # . A
                # . A   # A .
                if (quadrants[0] and quadrants[2]) or (quadrants[1] and quadrants[3]):
                    corners += 2

    return corners


def solve_part2(input):
    return sum(len(blob) * count_corners(blob) for blob, _ in blobify(input))


def blobify(input):
    width, height = len(input[0]), len(input)
    stack = set([(0, 0)])
    seen = set()
    blobs = []
    while stack:
        point = stack.pop()
        x, y = point
        if point in seen or width <= x or x < 0 or height <= y or y < 0:
            continue
        seen.add(point)
        blob = set()
        surrounding = flood(input, blob, x, y)
        blobs.append((blob, surrounding))
        seen |= blob
        stack.update(surrounding)
    return blobs


def flood(input, blob, x, y):
    width, height = len(input[0]), len(input)
    surrounding = []
    if (x, y) in blob:
        return surrounding

    blob.add((x, y))
    letter = input[y][x]

    directions = [(1, 0), (0, 1), (-1, 0), (0, -1)]
    for dx, dy in directions:
        px, py = x + dx, y + dy
        if 0 <= px < width and 0 <= py < height and input[py][px] == letter:
            surrounding.extend(flood(input, blob, px, py))
        else:
            surrounding.append((px, py))

    return surrounding


if __name__ == "__main__":
    with open("day12.input", "r") as f:
        input = f.read()

    input = [list(row) for row in input.strip().splitlines()]

    start = time.perf_counter()
    result = solve_part1(input)
    end = time.perf_counter()
    print(f"Part 1: {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve_part2(input)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
