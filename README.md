# Linktree — Mobile

SwiftUI app for **Linktree** — a link-in-bio profile page.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Status

This is a Swift package, not yet a shippable app:

- `Sources/LinktreeCore` — Foundation-only domain logic, unit-tested in
  `Tests/LinktreeCoreTests` (XCTest).
- `Sources/LinktreeUI` — SwiftUI tab shell (Home / Explore / Profile). It does not
  use `LinktreeCore` yet, and there is no Xcode app target (`@main`) yet.

The code has **not been compiled outside CI** (it was written without a Swift
toolchain); the macOS CI job is the first real build. See
[docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Core features (`LinktreeCore`)

- Handle rules (3–30 chars, `a–z0–9_.`, no leading/trailing/doubled dots, leading `@` stripped)
- Link URL rules: https, mailto and tel only; bare domains get https; http and script schemes rejected
- UTM tagging (`utm_source` / `utm_medium`) for https links without overwriting existing values
- Profile links: add, reorder, enable/disable, scheduled visibility windows
- View and click counting with click-through rate

## Tech Stack

- **UI:** SwiftUI (iOS 17+ / macOS 14+)
- **Language:** Swift 5.10
- **Tests:** XCTest via SwiftPM

## Getting Started

```bash
swift build
swift test          # runs LinktreeCoreTests
open Package.swift  # opens in Xcode 15+
```

CI (`.github/workflows/build.yml`, macOS 14) runs `swift build` and
`swift test`; failures fail the workflow.

## Related

- **Frontend:** [bookchaowalit-website/linktree-frontend](https://github.com/bookchaowalit-website/bookchaowalit-linktree-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
