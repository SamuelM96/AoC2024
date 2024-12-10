import time


def solve_part1(input):
    data = decompress(input, False)
    j = 0
    for i in range(len(data) - 1, 1, -1):
        j = data.index(".", j)
        if j > i:
            break
        data[j] = data[i]
        data[i] = "."

    checksum = 0
    for i, n in enumerate(data):
        if n == ".":
            break
        checksum += i * int(n)
    return checksum


def solve_part2(input):
    data = decompress(input, True)
    for i in range(len(data) - 1, 0, -1):
        id, n = data[i]
        if id == ".":
            continue
        for j, (_, space) in enumerate(data):
            if j >= i:
                break
            if data[j][0] != ".":
                continue
            if n == space:
                data[i], data[j] = data[j], data[i]
                break
            if n < space:
                data[j][1] -= n
                data[i][0] = "."
                data.insert(j, [id, n])
                break

    return checksum(data)

def decompress(input, as_blocks):
    result = []
    data = input[::2]
    free = input[1::2]
    i = j = 0
    while i < len(data) and j < len(free):
        if as_blocks:
            result.extend([[str(i), data[i]], [".", free[j]]])
        else:
            result.extend([str(i)] * data[i] + ["."] * free[j])
        i += 1
        j += 1
    for n in range(i, len(data)):
        if as_blocks:
            result.append([str(n), data[n]])
        else:
            result.extend([str(n)] * data[n])
    for n in range(j, len(free)):
        if as_blocks:
            result.append([".", free[n]])
        else:
            result.extend(["."] * free[n])
    return result

def checksum(data):
    checksum = 0
    i = 0
    for id, n in data:
        if id == ".":
            i += n
            continue
        for _ in range(n):
            checksum += i * int(id)
            i += 1
    return checksum

if __name__ == "__main__":
    with open("day9.input", "r") as f:
        input = f.read()

    input = [int(n) for n in list(input.strip())]

    start = time.perf_counter()
    result = solve_part1(input)
    end = time.perf_counter()
    print(f"Part 1: {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve_part2(input)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
