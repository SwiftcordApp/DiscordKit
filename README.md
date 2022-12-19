<p align="center">
  <img src="https://user-images.githubusercontent.com/64193267/208341700-75fb1d63-f044-4b60-9c86-ed945916b65c.png" height="128">
</p>

<h1 align="center">DiscordKit</h1>

<p align="center">
  <a aria-label="Join the community on Discord" href="https://discord.gg/vChUXVf9Em" target="_blank">
    <img alt="" src="https://img.shields.io/discord/964741354112577557?style=for-the-badge&labelColor=black&label=Discord">
  </a>
  <img alt="" src="https://www.aschey.tech/tokei/github/SwiftcordApp/DiscordKit?style=for-the-badge&labelColor=black">
  <a aria-label="DiscordKit Guide" href="https://swiftcord.gitbook.io/discordkit-guide/" target="_blank">
    <img alt="" src="https://img.shields.io/badge/guide-gitbook-important?style=for-the-badge&labelColor=black">
  </a>
</p>

<p align="center">Package for interacting with Discord's API to build Swift bots</p>

> DiscordKit for Bots is now released! Use DiscordKit to create that bot you've been
> looking to make, in the Swift that you know and love!

## About

DiscordKit is a Swift package for creating Discord bots in Swift.

**If DiscordKit has helped you, please give it a ⭐ star, or consider sponsoring! It
keeps me motivated to continue developing this and other projects.**

## Resources

Here are some (WIP) resources that might be useful while developing with DiscordKit.

* [DiscordKit Guide](https://swiftcord.gitbook.io/discordkit-guide/)
* [Developer Documentation](https://swiftcordapp.github.io/DiscordKit/documentation/discordkit/)

## Platform Support

Currently, DiscordKit only offically supports macOS versions 11 and up. Theoretically, you should be able to compile and use DiscordKit on any Apple platform with equivalent APIs, however this has not been tested and is considered an unsupported setup.

Linux and Windows is not supported at the moment, primarily due to our reliance on Apple's `Combine` framework. We have not blocked building DiscordKit on other platforms in the event that support for those frameworks is added to Swift's corelibs in the future.

Linux support is planned, and will arrive sometime in the future. Unfortunately, we do not have a timeline for that at the moment.

## Installation
### SPM:
Add the following to your `Package.swift`:
```swift
.package(url: "https://github.com/SwiftcordApp/DiscordKit", branch: "bot-support"),
```
Currently, DiscordKit is in alpha, so it's recommended to use the latest commit on the `main` branch.
