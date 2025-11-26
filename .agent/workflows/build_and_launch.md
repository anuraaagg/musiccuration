---
description: Build and launch the app on iPhone 17 Pro simulator
---

# Build and Launch on iPhone 17 Pro

This workflow builds and launches the musiccuration app on the iPhone 17 Pro simulator, bypassing the sweetpad extension's cached device selection.

## Steps

// turbo-all
1. Boot the iPhone 17 Pro simulator
```bash
xcrun simctl boot 32AE4C85-6A02-4EFE-A960-7C503664BEC2 2>/dev/null || echo "Simulator already booted"
```

2. Build the app for iPhone 17 Pro
```bash
xcodebuild -scheme musiccuration -configuration Debug \
  -workspace musiccuration.xcodeproj/project.xcworkspace \
  -destination 'platform=iOS Simulator,id=32AE4C85-6A02-4EFE-A960-7C503664BEC2' \
  -derivedDataPath .build \
  build
```

3. Install and launch the app
```bash
xcrun simctl install 32AE4C85-6A02-4EFE-A960-7C503664BEC2 \
  .build/Build/Products/Debug-iphonesimulator/musiccuration.app

xcrun simctl launch 32AE4C85-6A02-4EFE-A960-7C503664BEC2 \
  com.yourcompany.musiccuration
```

4. Open the Simulator app
```bash
open -a Simulator
```

## Alternative: Use a different simulator

To use iPhone 17 instead, replace `32AE4C85-6A02-4EFE-A960-7C503664BEC2` with `1FD0E27B-C84C-4898-9360-B09B5B00D3B8` in all commands above.

To use iPhone Air, use `D6D94BC4-3DD5-4F4D-A86D-133D430065F4`.
