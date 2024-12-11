import time

def solve(input, distinct):
    width, height = len(input[0]), len(input)

    def dfs(x,y):
        n = input[y][x]
        if n == 9:
            return {(x,y)} if distinct else 1
        
        result = set() if distinct else 0
        for dx, dy in [(0, -1), (0, 1), (-1, 0), (1, 0)]:
            px, py = x + dx, y + dy
            if 0 <= px < len(input[0]) and 0 <= py < len(input) and input[py][px] == n + 1:
                if distinct:
                    result |= dfs(px, py) # pyright: ignore
                else:
                    result += dfs(px, py) # pyright: ignore
        return result

    return sum(len(dfs(x,y)) if distinct else dfs(x,y) # pyright: ignore
               for y in range(height)
               for x in range(width)
               if input[y][x] == 0)


if __name__ == "__main__":
    with open("day10.input", "r") as f:
        input = f.read()

    input = [[int(n) for n in list(row)] for row in input.strip().splitlines()]

    start = time.perf_counter()
    result = solve(input, True)
    end = time.perf_counter()
    print(f"Part 1: {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve(input, False)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
