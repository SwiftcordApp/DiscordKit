# DiscordKit

![Discord](https://img.shields.io/discord/964741354112577557?style=for-the-badge)

The Discord API implementation that powers [Swiftcord](https://github.com/SwiftcordApp/Swiftcord),
a native Discord client for macOS also written in Swift.

A (mainly) fully functional Discord API library written from scratch fully in Swift!
Currently only supports user accounts, bot support coming soon. Check out the
[`bot-support`](https://github.com/SwiftcordApp/DiscordKit/tree/bot-support) branch
and SwiftcordApp/DiscordKit#18 for a quick peep into what we've been up to ;D

**If you like DiscordKit, please give it a ⭐ star, or consider sponsoring! It helps motivate
me to continue developing it**

## Documentation

WIP Developer Documentation is available [here](https://swiftcordapp.github.io/DiscordKit/documentation/discordkit/).

## Platform Support

Currently, DiscordKit only offically supports macOS versions 12 and up. Theoretically, You should be able to compile and use DiscordKit on i(Pad)OS/tvOS, however this has not been tested and is considered an unsupported setup.

Linux and Windows is not supported at the moment, due to our reliance on Apple's `Security` and `SystemConfiguration` frameworks. We have not blocked building DiscordKit on Linux and Windows in the event that support for those frameworks is added in the future. We may rework the code to add support for linux/windows in the future.

## Adding DiscordKit to your project
### SPM:
Add the following to your `Package.swift`:
```swift
.package(url: "https://github.com/SwiftcordApp/DiscordKit", branch: "main"),
```
Currently, DiscordKit is in alpha, so it's recommended to use the latest commit on the `main` branch.
