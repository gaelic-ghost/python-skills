#!/usr/bin/env -S uv run

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

import yaml


README_REQUIRED_HEADINGS = [
    "# python-skills",
    "## Table of Contents",
    "## What These Agent Skills Help With",
    "## Skill Guide (When To Use What)",
    "## Quick Start (Vercel Skills CLI)",
    "## Install individually by Skill or Skill Pack",
    "## Update Skills",
    "## More resources for similar Skills",
    "## Repository Layout",
    "## Notes",
    "## Keywords",
    "## License",
]

ROADMAP_REQUIRED_HEADINGS = [
    "# Project Roadmap",
    "## Vision",
    "## Product principles",
    "## Milestone Progress",
]

PATH_REFERENCE_RE = re.compile(
    r"(?:\[[^\]]+\]\()?((?:scripts|references|assets|agents)/[A-Za-z0-9._/\-]+)(?:\))?"
)
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


@dataclass
class Finding:
    path: str
    message: str


def parse_frontmatter(text: str, path: Path) -> dict[str, object]:
    match = FRONTMATTER_RE.match(text)
    if not match:
        raise ValueError(f"missing frontmatter in {path}")
    data = yaml.safe_load(match.group(1))
    if not isinstance(data, dict):
        raise ValueError(f"invalid frontmatter in {path}")
    return data


def load_yaml(path: Path) -> dict[str, object]:
    data = yaml.safe_load(path.read_text())
    if not isinstance(data, dict):
        raise ValueError(f"invalid YAML in {path}")
    return data


def find_skill_dirs(repo_root: Path) -> list[Path]:
    return sorted(
        path
        for path in repo_root.iterdir()
        if path.is_dir() and not path.name.startswith(".") and (path / "SKILL.md").exists()
    )


def validate_readme(repo_root: Path) -> list[Finding]:
    findings: list[Finding] = []
    readme = repo_root / "README.md"
    text = readme.read_text()
    for heading in README_REQUIRED_HEADINGS:
        if heading not in text:
            findings.append(Finding("README.md", f"missing heading: {heading}"))
    return findings


def validate_roadmap(repo_root: Path) -> list[Finding]:
    findings: list[Finding] = []
    roadmap = repo_root / "ROADMAP.md"
    text = roadmap.read_text()
    for heading in ROADMAP_REQUIRED_HEADINGS:
        if heading not in text:
            findings.append(Finding("ROADMAP.md", f"missing heading: {heading}"))
    if "Tickets:" not in text:
        findings.append(Finding("ROADMAP.md", "missing Tickets sections"))
    if "Exit criteria:" not in text:
        findings.append(Finding("ROADMAP.md", "missing Exit criteria sections"))
    return findings


def validate_skill_dir(skill_dir: Path) -> list[Finding]:
    findings: list[Finding] = []
    skill_md = skill_dir / "SKILL.md"
    skill_text = skill_md.read_text()
    repo_root = skill_dir.parent

    try:
        frontmatter = parse_frontmatter(skill_text, skill_md)
    except ValueError as exc:
        return [Finding(str(skill_md.relative_to(repo_root)), str(exc))]

    if frontmatter.get("name") != skill_dir.name:
        findings.append(
            Finding(str(skill_md.relative_to(repo_root)), "frontmatter name does not match directory name")
        )

    openai_yaml = skill_dir / "agents" / "openai.yaml"
    if not openai_yaml.exists():
        findings.append(Finding(str(skill_dir.relative_to(repo_root)), "missing agents/openai.yaml"))
    else:
        try:
            metadata = load_yaml(openai_yaml)
            interface = metadata.get("interface")
            if not isinstance(interface, dict):
                findings.append(Finding(str(openai_yaml.relative_to(repo_root)), "missing interface mapping"))
            else:
                for key in ("display_name", "short_description", "default_prompt"):
                    value = interface.get(key)
                    if not isinstance(value, str) or not value.strip():
                        findings.append(
                            Finding(str(openai_yaml.relative_to(repo_root)), f"missing or empty interface.{key}")
                        )
        except ValueError as exc:
            findings.append(Finding(str(openai_yaml.relative_to(repo_root)), str(exc)))

    for match in PATH_REFERENCE_RE.finditer(skill_text):
        rel_path = match.group(1)
        candidate = skill_dir / rel_path
        if not candidate.exists():
            findings.append(Finding(str(skill_md.relative_to(repo_root)), f"referenced path does not exist: {rel_path}"))

    return findings


def validate_doc_inventory(repo_root: Path, skill_dirs: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    readme_text = (repo_root / "README.md").read_text()
    for skill_dir in skill_dirs:
        skill_name = skill_dir.name
        if f"`{skill_name}`" not in readme_text:
            findings.append(Finding("README.md", f"skill missing from root docs: {skill_name}"))
    return findings


def run(repo_root: Path) -> list[Finding]:
    findings: list[Finding] = []
    skill_dirs = find_skill_dirs(repo_root)
    findings.extend(validate_readme(repo_root))
    findings.extend(validate_roadmap(repo_root))
    findings.extend(validate_doc_inventory(repo_root, skill_dirs))
    for skill_dir in skill_dirs:
        findings.extend(validate_skill_dir(skill_dir))
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate python-skills docs and metadata alignment.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    parser.add_argument("--repo-root", default=".", help="Repository root to validate.")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    findings = run(repo_root)

    if args.json:
        print(json.dumps([finding.__dict__ for finding in findings], indent=2))
    elif findings:
        for finding in findings:
            print(f"{finding.path}: {finding.message}")
    else:
        print("No findings.")

    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
