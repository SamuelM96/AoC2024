import time


def part1(nums, goal, pos, value):
    if pos == len(nums) - 1:
        return value == goal
    num = nums[pos + 1]
    return (part1(nums, goal, pos + 1, value + num)
         or part1( nums, goal, pos + 1, value * num))


def part2(nums, goal, pos, value):
    if pos == len(nums) - 1:
        return value == goal
    num = nums[pos + 1]
    return (part2(nums, goal, pos + 1, value + num)
         or part2(nums, goal, pos + 1, value * num)
         or part2(nums, goal, pos + 1, value * (10 ** len(str(num))) + num))


def solve(input, check):
    count = 0
    for line in input.splitlines():
        numbers = line.split()
        goal = int(numbers[0][:-1])
        nums = [int(n) for n in numbers[1:]]
        count += goal if check(nums, goal, 0, nums[0]) else 0
    return count

def solve_part2(input):
    count = 0

    for line in input.splitlines():
        numbers = line.split()
        goal = int(numbers[0][:-1])
        nums = [int(n) for n in numbers[1:]]

        # Pre-calculate digit count for concatenation
        digits = [10**len(str(n)) for n in nums]

        # A list is more efficient than deque in this case.
        # Pre-allocating the list didn't seem to have much of an
        # effect in python
        stack = [(nums[0], 0)]
        i = 0

        while i >= 0:
            val, idx = stack[i]
            i -= 1

            if idx == len(nums) - 1:
                if val == goal:
                    count += goal
                    break
                continue

            next_num = nums[idx + 1]
            if i + 3 >= len(stack):  # Extend stack if needed
                stack.extend([(0, 0)] * (i + 3 - len(stack) + 1))

            i += 1
            stack[i] = (val + next_num, idx + 1)
            i += 1
            stack[i] = (val * next_num, idx + 1)
            i += 1
            stack[i] = (val * digits[idx + 1] + next_num, idx + 1)

    return count

if __name__ == "__main__":
    with open("day7.input", "r") as f:
        input = f.read()

    # The recursive algorithm has worse time complexity when handling longer
    # number lists, especially when needing concat everything (the last operation
    # it does). The stack-based approach appears to be roughly linear time as 
    # the number count grows, but performs worse than recursion for shorter
    # lists.
    #
    # As such:
    #   - Recurse when lines are short
    #   - Use a stack when lines are long
    #
    # Worst case example for recursive:
    # input = "123456789123456789: 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9\n"
    # input = input * 5

    print("Part 1:", solve(input, part1))

    start = time.perf_counter()
    result = solve_part2(input)
    end = time.perf_counter()
    print(f"Part 2 (stack): {result} => {end-start:.6f} seconds")

    start = time.perf_counter()
    result = solve(input, part2)
    end = time.perf_counter()
    print(f"Part 2 (recursive): {result} => {end-start:.6f} seconds")
