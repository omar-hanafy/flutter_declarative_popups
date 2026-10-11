#!/usr/bin/env python3
"""Extract a release's reviewed changelog notes without author mentions."""

import re
import sys
from pathlib import Path


def release_notes(changelog: str, version: str) -> str:
    heading = re.compile(
        rf"^## \[{re.escape(version)}\](?: - [^\n]+)?[ \t]*$",
        re.MULTILINE,
    )
    matches = list(heading.finditer(changelog))
    if len(matches) != 1:
        raise ValueError(f"Expected one changelog section for {version}, found {len(matches)}.")
    start = matches[0].end()
    next_heading = re.search(r"^##[ \t]+", changelog[start:], re.MULTILINE)
    end = start + next_heading.start() if next_heading else len(changelog)
    notes = changelog[start:end].strip()
    if not notes:
        raise ValueError(f"Changelog section for {version} is empty.")
    if re.search(r"(?<![\w@])@[A-Za-z0-9][A-Za-z0-9-]*(?:/[A-Za-z0-9_.-]+)?", notes):
        raise ValueError("Release notes must not contain GitHub user or team mentions.")
    return notes + "\n"


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit("Usage: python3 scripts/release-notes.py VERSION CHANGELOG OUTPUT")
    version, changelog, output = sys.argv[1:]
    try:
        notes = release_notes(Path(changelog).read_text(encoding="utf-8"), version)
    except ValueError as error:
        raise SystemExit(str(error)) from error
    Path(output).write_text(notes, encoding="utf-8")


if __name__ == "__main__":
    main()
