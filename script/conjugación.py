#!/usr/bin/env python3
import sys, re


def main():
    lines = [l.rstrip("\n") for l in sys.stdin]
    # First non-empty line is the title
    title = next((l for l in lines if l.strip()), "")
    if not title:
        sys.exit("No title line found.")
    m = re.search(r'"([^"]+)"', title)
    if not m:
        sys.exit("Title line must contain a word in double quotes.")
    lemma = m.group(1)

    # Collect bullet lines that end with a single word
    bullets = []
    for l in lines[lines.index(title) + 1 :]:
        if re.match(r"\s*-\s", l):
            mw = re.search(r"(\S+)\s*$", l)
            if not mw:
                continue
            prefix = l[
                : mw.start(1)
            ]  # includes the trailing space before the last word
            bullets.append((l, prefix))

    if not bullets:
        sys.exit("No bullet lines found.")

    # Block 1: all placeholders, then originals
    print(title)
    for _, prefix in bullets:
        print(f"{prefix}<{lemma}>")
    print("---")
    for orig, _ in bullets:
        print(orig)
    print()

    # Blocks per bullet
    for i, (orig, prefix) in enumerate(bullets):
        print(title)
        print(f"{prefix}<{lemma}>")
        print("---")
        print(orig)
        if i != len(bullets) - 1:
            print()


if __name__ == "__main__":
    main()
