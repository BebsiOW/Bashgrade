#!/usr/bin/python3

import sys

if len(sys.argv) != 2:
    print("Usage: stats.py COURSE_FILE")
    sys.exit(1)

course_file = sys.argv[1]

weights = {}
scores = {}

with open(course_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue

        # CATEGORY lines: CATEGORY:Homework:0.40
        if line.startswith("CATEGORY:"):
            parts = line.split(":")
            cat = parts[1]
            weight = float(parts[2])
            weights[cat] = weight
            continue

        # Assignment lines: Homework:HW1:85
        parts = line.split(":")
        if len(parts) == 3:
            cat = parts[0]
            score = float(parts[2])
            if cat not in scores:
                scores[cat] = []
            scores[cat].append(score)

print("=== Python Stats ===")
for cat in scores:
    vals = scores[cat]
    avg = sum(vals) / len(vals)
    print(f"{cat}: min = {min(vals):.2f}% max = {max(vals):.2f}% avg = {avg:.2f}%")

# Final course grade (unweighted)
all_scores = []
for cat in scores:
    all_scores.extend(scores[cat])

if all_scores:
    overall_unweighted = sum(all_scores) / len(all_scores)
    print(f"\nFinal course grade (unweighted) = {overall_unweighted:.2f}%")

# Final course grade (weighted)
if weights:
    total = 0.0
    any_positive = False

    for cat in weights:
        if cat in scores and weights[cat] > 0:
            avg = sum(scores[cat]) / len(scores[cat])
            total += avg * weights[cat]
            any_positive = True

    if any_positive:
        print(f"Final course grade (weighted) = {total:.2f}%")
