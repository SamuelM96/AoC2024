DIRS = [
    (0, -1),  # ^
    (1, 0),  # >
    (0, 1),  # V
    (-1, 0),  # <
]


def solve_part1(map):
    x, y = find_guard(map)
    width, height = len(map[0]), len(map)
    visited = set()

    dir = 0
    count = 0
    while 0 <= x < width and 0 <= y < height:
        if map[y][x] == "#":
            dx, dy = DIRS[dir]
            x, y = x - dx, y - dy
            dir = (dir + 1) % 4
        elif (x,y) not in visited:
            count += 1

        visited.add((x,y))
        dx, dy = DIRS[dir]
        x, y = x + dx, y + dy

    return count, visited


def solve_part2(map):
    # Map out the guard's path first so that we can focus on putting obstacles
    # where they'll affect the pathfinding, avoiding unnecessary work
    _, walked = solve_part1(map)

    gx, gy = find_guard(map)
    map[gy][gx] = "."  # easier to blank the guard marker to avoid more checks

    width, height = len(map[0]), len(map)
    count = 0
    for y in range(height):
        for x in range(width):
            if gy == y and gx == x or (x,y) not in walked:
                continue
            prev = map[y][x]
            map[y][x] = "O"
            looped = walk(map, gx, gy)
            count += 1 if looped else 0
            map[y][x] = prev

    return count


def find_guard(map):
    for y in range(len(map)):
        for x in range(len(map[0])):
            if map[y][x] == "^":
                return x, y
    return 0, 0


# A modified version of part 1 which exits early as soon as a loop is detected
def walk(map, x, y):
    width, height = len(map[0]), len(map)
    dir = 0
    visited = {}
    while 0 <= x < width and 0 <= y < height:
        current = visited.get((x, y), map[y][x])
        dx, dy = DIRS[dir]

        if current in "#O":
            x, y = x - dx, y - dy
            dir = (dir + 1) % 4
            dx, dy = DIRS[dir]
        elif current == "+" and map[y + dy][x + dx] in ["#", "O"]:
            # Hit a barrier and we've walked here twice already => looped
            return True

        visited[(x, y)] = ("|" if dir in (0, 2) else "-") if current == "." else "+"
        y, x = y + dy, x + dx

    return False


if __name__ == "__main__":
    with open("day6.input", "r") as f:
        input = f.read().strip("\n")

    map = [list(row) for row in input.splitlines()]
    print("Part 1:", solve_part1(map)[0])
    print("Part 2:", solve_part2(map))
