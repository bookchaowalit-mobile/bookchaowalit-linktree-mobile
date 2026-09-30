# Upgrade plan

## Current state

Score: 3/10 (was 1/10) — domain logic + XCTest suite and honest CI exist, but
nothing has been compiled yet (no Swift toolchain was available when this was
written) and the UI is still a placeholder.

## Backlog

- P0: Confirm the macOS CI job is green (`swift build` + `swift test`); fix any
  compile errors it reports first.
- P0: Add an Xcode app target (`@main`) that hosts `LinktreeUI`, and build screens on
  top of `LinktreeCore` (an `@Observable` model wrapping the core API).
- P1: Public profile preview + editor UI on top of `Profile`.
- P1: Sync with the linktree backend; analytics must stay aggregate (no per-visitor data on device).
- P2: Add a Linux CI job that runs `swift test --filter LinktreeCoreTests` after
  making the UI target conditional, to keep the core portable.

## Done in this pass

- Split the package into `LinktreeCore` (Foundation-only logic), `LinktreeUI` (existing
  SwiftUI shell) and `LinktreeCoreTests` (5 XCTest cases).
- Removed `@main` from the library target (it belongs in an app target).
- CI: removed `|| echo` / `|| true` so build and test failures are visible.
- README now states what is verified and what is not.
- New Swift sources were syntax-checked with tree-sitter-swift only.
