# DynamicIslandUtilities

A collection of utilities that provides functionality around the Dynamic Island on the iPhone 14 Pro/Max.

I will be adding more utilities to this package in the near future.

# Utilities

## DynamicIsland

A type that provides the size, origin and rect for the Dynamic Island. For example, you can do:

```swift
let size = DynamicIsland.size
```

to get the size of the Dynamic Island cutout. This size is the same on both the iPhone 14 Pro and Max.

> **Warning**
> At the moment, this provides the static size of the island, not the dynamic size (the island will expand if there's a live activity running).

## DynamicIslandProgressIndicatorViewController

A `UIViewController` that provides a progress indicator around the Dynamic Island cutout.

To use it, simply subclass the view controller. You can subclass it even if you're not targetting iOS 16 yet, the minimum requirement is iOS 11.

In order to control the progress indicator, you need to access the configuration object by calling `dynamicIslandProgressIndicatorConfiguration()`, which will return a view into the progress indicator, allowing you to tweak the color, progress value/visibility or show an indeterminate animation.

```swift
let progressConfiguration = dynamicIslandProgressIndicatorConfiguration()
progressConfiguration.progressColor = .green
progressConfiguration.isProgressIndeterminate = false

// Manual progress

doFixedWork { currentProgress in 
  if currentProgress == 100 {
    progressConfiguration.hideProgressIndicator()
  } else {
    progressConfiguration.progress = currentProgress
  }
}

progressConfiguration.isProgressIndeterminate = true

/// Indeterminate progress

progressConfiguration.showIndeterminateProgressAnimation()
doSomeWorkThatMayFinishLater { result in
 ...
 progressConfiguration.hideProgressIndicator()
}
```

In order to call this method, you do need to use `#available` (if the availability context is below iOS 16) since this method can only be accessed on iOS 16. This is intentional, since it also nudges you to write fallback logic, for example:

```swift
if #available(iOS 16, *) {
  // Show a cool progress indicator around the Dynamic Island
  let progressConfiguration = dynamicIslandProgressIndicatorConfiguration()
  progressConfiguration.showIndeterminateProgressAnimation()
} else {
  // Fallback to a default indicator
  showIndeterminateProgressBar()
}
```

Example:

### Indeterminate 

![](Images/indeterminate_progress.gif)

### Manual

![](Images/fixed_progress.gif)

> **Note**
> If you're using SwiftUI, I will be providing a native version for that soon. In the meantime, you can wrap the view controller manually.


# Requirements

- Swift Package Manager
- Xcode 14
