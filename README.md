# DynamicIslandUtilities

A collection of utilities that provides functionality around the Dynamic Island on the iPhone 14 Pro/Max.

I will be adding more utilities to this package in the near future.

# Utilities

## DynamicIsland

A type that provides the size, origin, rect and some other information related to the Dynamic Island. For example, you can do:

```swift
let size = DynamicIsland.size
```

to get the size of the Dynamic Island cutout. This size is the same on both the iPhone 14 Pro and Max.

> **Warning**
> At the moment, this provides the static size of the island, not the dynamic size (the island will expand if there's a live activity running).

## DynamicIsland.progressIndicator

A simple object that provides access to a progress indicator around the Dynamic Island cutout. To use it, simply access `DynamicIsland.progressIndicator` from anywhere to control the indicator.

```swift
DynamicIsland.progressIndicator.progressColor = .green
DynamicIsland.progressIndicator.isProgressIndeterminate = false

// Manual progress

doFixedWork { currentProgress in 
  if currentProgress == 100 {
    DynamicIsland.progressIndicator.hideProgressIndicator()
  } else {
    DynamicIsland.progressIndicator.progress = currentProgress
  }
}

/// Indeterminate progress

DynamicIsland.progressIndicator.showIndeterminateProgressAnimation()
doSomeWorkThatMayFinishLater { result in
 ...
 DynamicIsland.progressIndicator.hideProgressIndicator()
}
```

In order to access this property, you need to first check `DynamicIsland.isAvailable` (this is enforced at runtime), which also nudges you to provide fallback logic:

```swift
if DynamicIsland.isAvailable {
  // Show a cool progress indicator around the Dynamic Island
  DynamicIsland.progressIndicator.showIndeterminateProgressAnimation()
} else {
  // Fallback to a default indicator
  showIndeterminateProgressBar()
}
```

> **Note**
> By default, the progress indicator is added to the key window (or the first window of the first scene). If you want to change that, set `DynamicIsland.progressIndicator.window` to a `UIWindow` of your choice.

Example:

### Indeterminate 

![](Images/indeterminate_progress.gif)

### Manual

![](Images/fixed_progress.gif)

# Requirements

- Swift Package Manager
- Xcode 14
- iOS 11 to import the package, iOS 16 to actually use it (this is obvious!)
