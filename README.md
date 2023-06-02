<p align="center">
  <img src="https://user-images.githubusercontent.com/64193267/208341700-75fb1d63-f044-4b60-9c86-ed945916b65c.png" height="128">
</p>

<h1 align="center">DiscordKit</h1>

<p align="center">
  <a aria-label="Join the community on Discord" href="https://discord.gg/he7n6MGDXS" target="_blank">
    <img alt="" src="https://img.shields.io/discord/964741354112577557?style=for-the-badge&labelColor=black&label=Discord">
  </a>

  <!-- Self-hosted tokei_rs instance, only works for repos in the SwiftcordApp org -->
  <img alt="" src="http://vinkwok.mywire.org/tokei/github/SwiftcordApp/DiscordKit?style=for-the-badge&branch=bot-support&category=code">

  <a aria-label="DiscordKit Guide" href="https://swiftcord.gitbook.io/discordkit-guide/" target="_blank">
    <img alt="" src="https://img.shields.io/badge/guide-gitbook-important?style=for-the-badge&labelColor=black">
  </a>
</p>

<p align="center">Package for interacting with Discord's API to build Swift bots</p>

> DiscordKit for Bots is now released! Use DiscordKit to create that bot you've been
> looking to make, in the Swift that you know and love!

## About

DiscordKit is a Swift package for creating Discord bots in Swift.

**If DiscordKit has helped you, please give it a ⭐ star and consider sponsoring! It
keeps me motivated to continue developing this and other projects.**

## Installation

### Swift Package Manager (SPM):

<details>
  <summary><code>Package.swift</code></summary>

  Add the following to your `Package.swift`:
  ```swift
  .package(url: "https://github.com/SwiftcordApp/DiscordKit", branch: "main")
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
  main
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

// Guild to register commands in. If the COMMAND_GUILD_ID environment variable is set, commands are scoped
// to that server and update instantly, useful for debugging. Otherwise, they are registered globally.
let commandGuildID = ProcessInfo.processInfo.environment["COMMAND_GUILD_ID"]

bot.ready.listen {
    print("Logged in as \(bot.user!.username)#\(bot.user!.discriminator)!")

    try? await bot.registerApplicationCommands(guild: commandGuildID) {
        NewAppCommand("ping", description: "Ping me!") { interaction in
            try? await interaction.reply("Pong!")
        }
    }
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
* [Developer Documentation](https://swiftcordapp.github.io/DiscordKit/documentation/discordkitbot/) (Built with DocC)

## Platform Support

Currently, DiscordKit only offically supports macOS versions 11 and up. Theoretically, you should be able to compile and use DiscordKit on any Apple platform with equivalent APIs, however this has not been tested and is considered an unsupported setup.

DiscordKitBot and DiscordKitCore is supported on Linux, but not DiscordKit itself. However, you are able to develop and host bots made with DiscordKit on Linux. 

Windows is not supported natively at the moment. The recommended method is to use Windows Subsystem for Linux to do any development/hosting of DiscordKit bots on Windows. Native support may come in the future.
