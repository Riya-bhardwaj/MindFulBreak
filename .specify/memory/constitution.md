<!--
Sync Impact Report
===================
Version change: [template] -> 1.0.0
Modified principles: N/A (initial creation)
Added sections:
  - 7 Core Principles (Non-Breaking Changes, Code Quality, Testability,
    Modularity, Simplicity, Extensibility, Performance)
  - Testing Standards section
  - Development Workflow section
  - Governance section
Removed sections: None
Templates requiring updates:
  - .specify/templates/plan-template.md: no update needed (Constitution
    Check section already references constitution generically)
  - .specify/templates/spec-template.md: no update needed (already
    includes testability and acceptance scenarios)
  - .specify/templates/tasks-template.md: no update needed (already
    includes test task patterns and checkpoint gates)
Follow-up TODOs: None
-->

# MindFulBreak Constitution

## Core Principles

### I. Non-Breaking Changes (NON-NEGOTIABLE)

Every change MUST preserve existing functionality. No modification,
refactor, or new feature is permitted to break previously working
behavior.

- All public APIs, view contracts, and data schemas MUST remain
  backward-compatible unless a migration path is provided and approved.
- Before merging any change, the full existing test suite MUST pass
  with zero regressions.
- When modifying shared code, the developer MUST identify and verify
  all call sites and dependents.
- Deprecation MUST precede removal: mark as deprecated in one release,
  remove no earlier than the next.

**Rationale**: MindFulBreak is a user-facing app. Regressions erode
trust and compound debugging cost. Stability is the highest priority.

### II. Code Quality

All code MUST be clean, readable, and maintainable. Quality is measured
by how easily another developer can understand and modify the code.

- Follow Swift and SwiftUI conventions (naming, access control, error
  handling) consistently across the codebase.
- Functions MUST do one thing. If a function exceeds ~30 lines,
  evaluate whether it should be decomposed.
- Avoid dead code, commented-out blocks, and unused imports. Remove
  them immediately.
- Compiler warnings MUST be treated as errors and resolved before
  merge.

**Rationale**: Readable code reduces onboarding time and prevents
subtle bugs from hiding in complexity.

### III. Testability

Code MUST be designed for testability. Unit tests MUST accompany all
new logic and bug fixes.

- Every new public function, method, or computed property with logic
  MUST have at least one corresponding unit test.
- Bug fixes MUST include a regression test that fails before the fix
  and passes after.
- Dependencies MUST be injectable (protocol-based or closure-based) to
  enable isolated unit testing without mocks of concrete types.
- Test names MUST follow the pattern:
  `test_<unit>_<scenario>_<expectedOutcome>`.

**Rationale**: Tests are the safety net that enables confident
refactoring and validates that Principle I (Non-Breaking Changes) is
upheld.

### IV. Modularity

The codebase MUST be organized into cohesive, loosely coupled modules
with clear boundaries.

- Each module (Swift package target, feature folder, or logical group)
  MUST have a single, well-defined responsibility.
- Cross-module communication MUST occur through defined interfaces
  (protocols), not concrete type references.
- Circular dependencies between modules are prohibited.
- Shared utilities MUST be extracted only when used by two or more
  modules; premature abstraction is prohibited.

**Rationale**: Modularity enables parallel development, independent
testing, and selective feature delivery.

### V. Simplicity

Prefer the simplest solution that satisfies the requirement. Complexity
MUST be justified.

- YAGNI: Do not implement functionality until it is needed.
- Prefer standard library and framework APIs over third-party
  dependencies when capability is equivalent.
- Avoid design patterns (coordinators, abstract factories, etc.)
  unless the problem demonstrably requires them.
- Configuration and feature flags MUST only be added when there is a
  concrete, current use case.

**Rationale**: Every line of code is a liability. Simpler code has
fewer bugs, is easier to test, and is cheaper to maintain.

### VI. Extensibility

The architecture MUST support adding new features without modifying
existing stable code.

- New features SHOULD be additive: new files, new types, new
  extensions -- not edits to unrelated existing code.
- Use protocol-oriented design to define extension points where
  variation is expected.
- View components MUST be composable and reusable across features
  where applicable.
- Data layer changes MUST use migrations that are forward-compatible
  with existing stored data.

**Rationale**: An extensible architecture reduces the risk of
introducing regressions (Principle I) when the product evolves.

### VII. Performance

Code MUST be efficient and optimized for responsive user experience on
the target platform.

- UI updates MUST occur on the main thread. Heavy computation and I/O
  MUST be dispatched off the main thread.
- Avoid unnecessary object allocations in hot paths (e.g., timer
  callbacks, animation frames).
- Database queries MUST use indexes for frequently accessed columns
  and avoid N+1 query patterns.
- Lazy loading MUST be used for resources not needed at launch (views,
  images, data).

**Rationale**: MindFulBreak runs as a menu bar/overlay app.
Perceptible lag during breaks undermines the core user experience.

## Testing Standards

Unit testing is the primary quality gate for this project.

- **Coverage target**: All business logic and data transformation
  functions MUST have unit tests. UI-only code (layouts, colors) is
  exempt.
- **Test isolation**: Each test MUST be independent. No test may depend
  on the execution order or side effects of another test.
- **Test speed**: Unit tests MUST complete in under 1 second each.
  Tests exceeding this threshold MUST be profiled and optimized.
- **Test location**: Tests MUST reside in a `Tests/` directory
  mirroring the source structure.
- **XCTest**: All tests MUST use XCTest framework conventions.
- **CI gate**: The test suite MUST pass before any code is merged.
  Flaky tests MUST be fixed or quarantined immediately.

## Development Workflow

- **Branch strategy**: Feature branches off `main`. No direct commits
  to `main`.
- **Change validation**: Before submitting any change, run the full
  test suite locally. Verify no regressions.
- **Incremental delivery**: Implement one user story at a time. Each
  story MUST be independently testable and functional before
  proceeding to the next.
- **Commit discipline**: Each commit MUST represent a single logical
  change. Commit messages MUST describe the "why", not just the
  "what".
- **Review checklist**: Every change MUST be reviewed against this
  constitution. Non-compliance MUST be flagged and resolved before
  merge.

## Governance

This constitution is the authoritative source of development
principles for MindFulBreak. It supersedes all informal practices and
ad-hoc conventions.

- **Amendments**: Any change to this constitution MUST be documented
  with rationale, reviewed, and versioned using semantic versioning
  (MAJOR.MINOR.PATCH).
- **Compliance**: All code changes, reviews, and architectural
  decisions MUST verify alignment with these principles.
- **Conflict resolution**: When principles conflict (e.g., simplicity
  vs. extensibility), Principle I (Non-Breaking Changes) takes
  precedence. Among remaining principles, prefer the option that
  minimizes total code and maximizes test coverage.
- **Runtime guidance**: Refer to `CLAUDE.md` for technology-specific
  development guidance that complements this constitution.

**Version**: 1.0.0 | **Ratified**: 2026-03-09 | **Last Amended**: 2026-03-09
