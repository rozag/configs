#!/usr/bin/env python3

import re
import subprocess
import sys
from typing import Any, Dict, List, Optional, Tuple


def parse_block(block_text: str) -> Optional[Dict[str, Any]]:
    """
    Parses a single block of text to extract the title, lemma, and bullet
    points.

    Args:
        block_text: A string containing a single verb conjugation block.

    Returns:
        A dictionary with 'title', 'lemma', and 'bullets' if parsing is
        successful, otherwise None.
    """
    lines = [line for line in block_text.strip().split("\n") if line.strip()]
    if not lines:
        return None

    # First non-empty line is the title
    title = lines[0]
    match = re.search(r'"([^"]+)"', title)
    if not match:
        print(
            (
                "Warning: Could not find lemma in title for "
                f"block:\n---\n{block_text}\n---"
            ),
            file=sys.stderr,
        )
        return None
    lemma = match.group(1)

    # Collect bullet lines that end with a single word
    bullets: List[Tuple[str, str]] = []
    for line in lines[1:]:
        if re.match(r"\s*-\s", line):
            # Search for the last word on the line
            word_match = re.search(r"(\S+)\s*$", line)
            if not word_match:
                continue

            # The prefix is everything before the last word
            prefix = line[: word_match.start(1)]
            bullets.append((line, prefix))

    if not bullets:
        print(
            (
                "Warning: No valid bullet lines found for "
                f"block:\n---\n{block_text}\n---"
            ),
            file=sys.stderr,
        )
        return None

    return {"title": title, "lemma": lemma, "bullets": bullets}


def generate_output_for_block(parsed_data: Dict[str, Any]) -> str:
    """
    Generates the formatted card text for a single parsed block.
    """
    title = parsed_data["title"]
    lemma = parsed_data["lemma"]
    bullets = parsed_data["bullets"]

    output_parts = []

    # Block 1: All placeholders, then all original forms
    output_parts.append(title)
    for _, prefix in bullets:
        output_parts.append(f"{prefix}<{lemma}>")
    output_parts.append("---")
    for original, _ in bullets:
        output_parts.append(original)

    # Blocks per bullet
    for original, prefix in bullets:
        output_parts.append("\n" + title)
        output_parts.append(f"{prefix}<{lemma}>")
        output_parts.append("---")
        output_parts.append(original)

    return "\n".join(output_parts)


def copy_to_clipboard(text: str):
    """
    Copies the given text to the clipboard. Currently only supports macOS.
    """
    if sys.platform != "darwin":
        print(
            "Info: Skipping clipboard copy on non-macOS system.",
            file=sys.stderr,
        )
        return

    try:
        subprocess.run(
            ["pbcopy"],
            input=text,
            text=True,
            check=True,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )
        print("Success: Output copied to clipboard.", file=sys.stderr)
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(
            f"Error: Could not copy to clipboard. `pbcopy` command failed: {e}",
            file=sys.stderr,
        )


def main():
    """
    Main execution function. Reads from stdin, processes blocks, prints to
    stdout, and copies the result to the clipboard.
    """
    # 1. Read the entire standard input
    full_input = sys.stdin.read()

    # 2. Split the input into blocks using 2 or more newlines as a delimiter
    blocks = re.split(r"\n{2,}", full_input.strip())

    all_outputs = []
    for block_text in blocks:
        if not block_text.strip():
            continue

        parsed_data = parse_block(block_text)
        if parsed_data:
            block_output = generate_output_for_block(parsed_data)
            all_outputs.append(block_output)

    if not all_outputs:
        sys.exit("No processable blocks found in the input.")

    # Join the processed blocks with two newlines for separation
    final_output = "\n\n".join(all_outputs)

    # 3. Print the result to standard output
    print(final_output)

    # 4. Copy the result to the clipboard
    copy_to_clipboard(final_output)


if __name__ == "__main__":
    main()
