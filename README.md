<p align="center">
  <img src="https://user-images.githubusercontent.com/64193267/208341700-75fb1d63-f044-4b60-9c86-ed945916b65c.png" height="128">
</p>

<h1 align="center">DiscordKit</h1>

<p align="center">
  <a aria-label="Join the community on Discord" href="https://discord.gg/vChUXVf9Em" target="_blank">
    <img alt="" src="https://img.shields.io/discord/964741354112577557?style=for-the-badge&labelColor=black&label=Discord">
  </a>

  <!-- Self-hosted tokei_rs instance, only works for repos in the SwiftcordApp org -->
  <img alt="" src="https://vinkwok.tk/tokei/github/SwiftcordApp/DiscordKit?style=for-the-badge&branch=bot-support">

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

## Installation

### Swift Package Manager (SPM):

<details>
  <summary><code>Package.swift</code></summary>

  Add the following to your `Package.swift`:
  ```swift
  .package(url: "https://github.com/SwiftcordApp/DiscordKit", branch: "bot-support")
  ```
</details>
<details>
  <summary>Xcode Project</summary>

  Add a package dependancy in your Xcode project with the following parameters:

  **Package URL:**
  ```
  https://github.com/SwiftcordApp/DiscordKit
  ```

  **Branch:**
  ```
  bot-support
  ```

  **Product:**
  - [x] DiscordKitBot
</details>

For more detailed instructions, refer to [this page](https://app.gitbook.com/o/bq2pyf3PEDPf2CURHt4z/s/WJuHiYLW9jKqPb7h8D7t/getting-started/installation)
in the DiscordKit guide.

## Example Usage

Create a simple bot with a **/ping** command:

```swift

import DiscordKitBot

let bot = Client(intents: .unprivileged)

bot.ready.listen {
    print("Logged in as \(bot.user!.username)#\(bot.user!.discriminator)!")

    print("Started refreshing application (/) commands.")
    try? await bot.registerApplicationCommands(guild: ProcessInfo.processInfo.environment["COMMAND_GUILD_ID"]) {
        NewAppCommand("ping", description: "Ping me!") { interaction in
            try? await interaction.reply("Pong!")
        }
    }
    print("Successfully reloaded application (/) commands.")
}

bot.login() // Reads the bot token from the DISCORD_TOKEN environment variable and logs in with the token

// Run the main RunLoop to prevent the program from exiting
RunLoop.main.run()
```
_(Yes, that's really the whole code, no messing with registering commands with the REST
API or anything!)_

Not sure what to do next? Check out the guide below, which walks you through
all the steps to create your own Discord bot!

## Resources

Here are some (WIP) resources that might be useful while developing with DiscordKit.

* [DiscordKit Guide](https://swiftcord.gitbook.io/discordkit-guide/)
* [Developer Documentation](https://swiftcordapp.github.io/DiscordKit/documentation/discordkit/)

## Platform Support

Currently, DiscordKit only offically supports macOS versions 11 and up. Theoretically, you should be able to compile and use DiscordKit on any Apple platform with equivalent APIs, however this has not been tested and is considered an unsupported setup.

Linux and Windows is not supported at the moment, primarily due to our reliance on Apple's `Combine` framework. We have not blocked building DiscordKit on other platforms in the event that support for those frameworks is added to Swift's corelibs in the future.

Linux support is planned, and will arrive sometime in the future. Unfortunately, we do not have a timeline for that at the moment.
