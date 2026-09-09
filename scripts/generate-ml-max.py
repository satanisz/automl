from __future__ import annotations

import argparse
import re
from pathlib import Path


PACKAGE_NAME = re.compile(r"^([A-Za-z0-9_.-]+)")
PYPI_ALIASES = {
    "jupyterlab-variableinspector": "lckr-jupyterlab-variableinspector",
}


def canonical_name(requirement: str) -> str:
    match = PACKAGE_NAME.match(requirement)
    if not match:
        raise ValueError(f"Cannot read package name from: {requirement!r}")
    return re.sub(r"[-_.]+", "-", match.group(1)).lower()


def collect(source_dir: Path) -> list[str]:
    selected: dict[str, str] = {}
    for source in sorted(source_dir.glob("*.txt")):
        for raw_line in source.read_text(encoding="utf-8").splitlines():
            requirement = raw_line.strip()
            if not requirement or requirement.startswith("#"):
                continue
            name = canonical_name(requirement)
            if name in PYPI_ALIASES:
                requirement = PYPI_ALIASES[name]
                name = canonical_name(requirement)
            current = selected.get(name)
            if current is None or len(requirement) > len(current):
                selected[name] = requirement
    return [selected[name] for name in sorted(selected)]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build ml-max as the union of dependency catalog files."
    )
    parser.add_argument("--check", action="store_true", help="verify without modifying the output")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    destination = root / "docker" / "requirements" / "ml-max.txt"
    catalog_dir = root / "docker" / "requirements" / "catalogs"
    generated = "\n".join(collect(catalog_dir)) + "\n"

    if args.check:
        if destination.read_text(encoding="utf-8") != generated:
            print(f"{destination} is not synchronized with {catalog_dir}")
            return 1
        print(f"{destination} is synchronized ({len(generated.splitlines())} packages)")
        return 0

    destination.write_text(generated, encoding="utf-8", newline="\n")
    print(f"Wrote {destination} ({len(generated.splitlines())} packages)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
