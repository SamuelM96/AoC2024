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

        results = [nums[0]]
        for num in nums[1:]:
            results = (
                [a + num for a in results]
                + [a * num for a in results]
                + [int(str(a) + str(num)) for a in results]
            )
        count += goal if goal in results else 0

    return count


if __name__ == "__main__":
    with open("day7.input", "r") as f:
        input = f.read()

    print("Part 1:", solve_part1(input))
    print("Part 2:", solve_part2(input))
