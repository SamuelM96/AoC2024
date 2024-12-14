import time


def solve_part1(robots: list, width: int, height: int, seconds: int):
    tl = tr = bl = br = 0
    for p, v in robots:
        x = (p[0] + v[0] * seconds) % width
        y = (p[1] + v[1] * seconds) % height
        if x < width // 2 and y < height // 2:
            tl += 1
        elif x > width // 2 and y < height // 2:
            tr += 1
        elif x > width // 2 and y > height // 2:
            br += 1
        elif x < width // 2 and y > height // 2:
            bl += 1
    return tl * tr * bl * br


def solve_part2(robots: list, width: int, height: int):
    for i in range(10000):
        map = [[0] * width for _ in range(height)]
        for p, v in robots:
            x = (p[0] + v[0] * i) % width
            y = (p[1] + v[1] * i) % height
            map[y][x] = 1
        save_image(map, i)
    return "Search the images in the current folder for the tree!"


def save_image(data, seconds: int):
    width, height = len(data[0]), len(data)
    with open(f"{seconds}.pbm", "w") as f:
        f.write("P1\n")
        f.write(f"{width} {height}\n")
        for row in data:
            f.write(" ".join(map(str, row)) + "\n")


def parse(input):
    data = []
    for row in input.strip().splitlines():
        p, v = row.split(" ")
        pos = [int(n) for n in p[2:].split(",")]
        vel = [int(n) for n in v[2:].split(",")]
        data.append([pos, vel])
    return data


if __name__ == "__main__":
    with open("input", "r") as f:
        input = f.read()

    input = parse(input)

    start = time.perf_counter()
    result = solve_part1(input, 101, 103, 100)
    end = time.perf_counter()
    print(f"Part 1: {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve_part2(input, 101, 103)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
