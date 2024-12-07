import time


def part1(nums, goal, pos, value):
    if pos == len(nums) - 1:
        return value == goal
    num = nums[pos + 1]
    return part1(nums, goal, pos + 1, value + num) or part1(
        nums, goal, pos + 1, value * num
    )


def part2(nums, goal, pos, value):
    if pos == len(nums) - 1:
        return value == goal
    num = nums[pos + 1]
    return (
        part2(nums, goal, pos + 1, value + num)
        or part2(nums, goal, pos + 1, value * num)
        or part2(nums, goal, pos + 1, value * (10 ** len(str(num))) + num)
    )


def solve(input, check):
    count = 0
    for line in input.splitlines():
        numbers = line.split()
        goal = int(numbers[0][:-1])
        nums = [int(n) for n in numbers[1:]]

        # A recursive algorithm appears to be the most performant
        # compared to using other data structures (stacks, dicts, sets, etc).
        #
        # Likely because the stack allocation for function frames are trivial
        # and common enough to be optimised, whereas data structures have
        # additional overhead (hashing + allocations). Pre-allocation helps a bit,
        # but still lost the recursive option.
        #
        # Only potential downside is running out of stack space if recursion gets
        # too deep, but it's fine in this case.
        #
        # Also has the benefit of being able to swap out implementations easily
        count += goal if check(nums, goal, 0, nums[0]) else 0
    return count


if __name__ == "__main__":
    with open("day7.input", "r") as f:
        input = f.read()

    print("Part 1:", solve(input, part1))
    start = time.perf_counter()
    result = solve(input, part2)
    end = time.perf_counter()
    print(f"Part 2: {result} => {end-start:.6f} seconds")
