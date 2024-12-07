import time

def solve_part1(input):
    count = 0
    for line in input.splitlines():
        numbers = line.split()
        goal = int(numbers[0][:-1])
        nums = [int(n) for n in numbers[1:]]

        results = [nums[0]]
        for num in nums[1:]:
            results = (
                [a + num for a in results]
                + [a * num for a in results]
            )
        count += goal if goal in results else 0

    return count

def solve_part2(input):
    count = 0
    for line in input.splitlines():
        numbers = line.split()
        goal = int(numbers[0][:-1])
        nums = [int(n) for n in numbers[1:]]

        # A set performs worse for this use case due to the additional
        # overhead versus input size, so the list is best
        results = [nums[0]]
        for num in nums[1:]:
            # Using the op method reduces the number of list creations
            # and additions. 2.4s -> 1.8s on my system
            results = [
                val * num if op == 0 else
                val + num if op == 1 else
                val * (10 ** len(str(num))) + num
                for val in results
                for op in range(3)
            ]
        count += goal if goal in results else 0

    return count


if __name__ == "__main__":
    with open("day7.input", "r") as f:
        input = f.read()

    print("Part 1:", solve_part1(input))
    start = time.perf_counter()
    result = solve_part2(input)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
