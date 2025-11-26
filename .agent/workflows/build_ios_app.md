---
description: Build the iOS application using xcodebuild
---

To build the iOS application from the terminal, run the following command:

```bash
xcodebuild -scheme musiccuration -destination 'platform=iOS Simulator,name=iPhone 17' build
```

If this fails, ensure you have the correct Simulator installed or try opening the project in Xcode:

```bash
open musiccuration.xcodeproj
```
