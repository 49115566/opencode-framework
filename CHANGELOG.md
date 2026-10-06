# opencode-framework Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-10-06

### Added

- The prompt-driven development lifecycle: `/spec`, `/plan`, `/build`, `/test`,
  `/review`, `/ship`, and the supporting `/fix`, `/status`, `/roadmap`,
  `/visual`, `/bootstrap`, and `/doctor` commands.
- The agent, command, and skill set under `.opencode/` that implements the
  lifecycle.
- `AGENTS.md`, `docs/workflow.md`, and `docs/artifact-conventions.md` as the
  always-loaded workflow contract.
- The committed, provider-neutral test suite (`bash tests/run.sh`) and its CI
  workflow.
- An MIT `LICENSE`, so the framework can be legally copied into arbitrary
  repositories.
- `VERSION`, the single source of truth for the framework version, and this
  changelog.
- `CONTRIBUTING.md`, documenting how to contribute and the manual release model.
