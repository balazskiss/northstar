# Northstar

A personal motivation tool that surfaces a single meaningful metric to your Apple Watch — keeping your side project top of mind.

## Goal

Side projects die from neglect, not bad ideas. Northstar solves the visibility problem: instead of opening a dashboard buried in some browser tab, your most important metric is glanceable on your wrist at any moment.

The first milestone is simple: **one number, always visible, always meaningful**.

## Concept

1. Pick the metric that matters most right now (e.g. revenue, active users, commits this week, streak days)
2. Northstar fetches and caches that metric on a schedule
3. A watchOS complication displays it on your watch face

No noise. No dashboards. Just your north star.

## Roadmap

### Milestone 1: A number on the watch

- [ ] watchOS app with a complication
- [ ] Hardcode a single metric value end-to-end
- [ ] Fetch the real value from a source (API, webhook, etc.)
- [ ] Display it live on the watch face

## Structure

```
northstar/
├── NorthstarKit/       # Shared Swift library (models, API client)
└── NorthstarUI/        # Xcode project
    ├── project.yml     # xcodegen spec — edit this, not the .xcodeproj
    ├── Northstar.xcodeproj
    └── Sources/
        ├── App/        # iOS app
        ├── Watch/      # watchOS app
        ├── Complication/  # watchOS complication (WidgetKit)
        └── Widget/     # iOS home screen widget (WidgetKit)
```

## Tech Stack

- Swift / SwiftUI
- WidgetKit (complication + iOS widget)
- [timeapi.io](https://timeapi.io) — current metric source
- [xcodegen](https://github.com/yonaskolb/XcodeGen) — project generation

## Getting Started

**Prerequisites:** Xcode, xcodegen (`brew install xcodegen`)

```sh
cd NorthstarUI
xcodegen generate
open Northstar.xcodeproj
```

1. Select the **Northstar** scheme → your iPhone → **Run**
2. Select the **NorthstarWatch** scheme → your Apple Watch → **Run**
3. On the watch, long-press the face → Edit → add the **Northstar** complication

**After editing `project.yml`**, always re-run `xcodegen generate` from `NorthstarUI/` before building.

## Motivation

> "A goal without a metric is just a wish."

Northstar keeps the number in front of you so you never forget why you're building.
