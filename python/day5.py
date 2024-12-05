import time
from copy import deepcopy


def solve_part1(updates, rules):
    correct = []
    for update in updates:
        valid = True
        for a, b in zip(update, update[1:]):
            for rule in rules:
                if rule[0] == b and rule[1] == a:
                    valid = False
                    break
            if not valid:
                break
        if valid:
            correct.append(update)

    return sum(up[len(up) // 2] for up in correct)


# The naive yet simple way is to reset to the beginning of the
# array when you encounter a rule violation. That way you catch
# any additional rule violations that may occur in previous parts
# when swapping elements. However, this results in a lot of
# redundant work, since only the previous pair is affected
# by the swap.
def solve_part2_naive(updates, rules):
    corrected = []
    for update in updates:
        i = 0
        valid = True
        while i < len(update) - 1:
            i += 1
            for rule in rules:
                if rule[0] == update[i] and rule[1] == update[i - 1]:
                    update[i], update[i - 1] = update[i - 1], update[i]
                    valid = False
                    i = 0
                    break
        if not valid:
            corrected.append(update)

    return sum(up[len(up) // 2] for up in corrected)


# The optimal way is to switch sorting direction until either
# all rules pass, or the start of the array is reached. That
# way we can back propogate the sorting with minimal redundancy.
# This is similar to insertion sort.
#
# WAIT IT'S BASICALLY GNOME SORT! Fitting the theme, I see :D
def solve_part2(updates, rules):
    corrected = []
    for update in updates:
        i = 1
        valid = True
        while i < len(update):
            for rule in rules:
                if i > 0 and rule[0] == update[i] and rule[1] == update[i - 1]:
                    update[i], update[i - 1] = update[i - 1], update[i]
                    valid = False
                    i -= 1
                    break
            else:
                i += 1
        if not valid:
            corrected.append(update)

    return sum(up[len(up) // 2] for up in corrected)


def parse_input(input):
    rules, updates = input.strip().split("\n\n")
    updates = [[int(n) for n in update.split(",")] for update in updates.split("\n")]
    rules = [[int(n) for n in rule.split("|")] for rule in rules.split("\n")]
    return updates, rules


if __name__ == "__main__":
    with open("day5.input", "r") as f:
        input = f.read()

    updates, rules = parse_input(input)

    print("Part 1:", solve_part1(updates, rules))

    # Sorting happens in place, so need to deepcopy updates each time.
    # Just going to repeat the benchmarking stuff since sorting out the
    # wrapper function to do deepcopying is more hassle than it's worth.

    times = []
    result = 0
    for i in range(10):
        print(f"Part 2 (Naive) iteration #{i}...", end="")
        start = time.perf_counter()
        result = solve_part2_naive(deepcopy(updates), rules)
        end = time.perf_counter()
        times.append(end - start)
        print(f" = {result} => {times[-1]:.6f} seconds")

    print("Naive results:")
    print(f"  Min: {min(times):.6f} seconds")
    print(f"  Max: {max(times):.6f} seconds")
    print(f"  Avg: {sum(times)/len(times):.6f} seconds")

    print("-"*80)

    times = []
    result = 0
    for i in range(10):
        print(f"Part 2 (Gnome) iteration #{i}...", end="")
        start = time.perf_counter()
        result = solve_part2(deepcopy(updates), rules)
        end = time.perf_counter()
        times.append(end - start)
        print(f" = {result} => {times[-1]:.6f} seconds")

    print("Gnome results:")
    print(f"  Min: {min(times):.6f} seconds")
    print(f"  Max: {max(times):.6f} seconds")
    print(f"  Avg: {sum(times)/len(times):.6f} seconds")
