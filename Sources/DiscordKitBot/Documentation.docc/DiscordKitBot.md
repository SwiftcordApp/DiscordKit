# ``DiscordKitBot``

So you want to make a Discord bot in Swift, I hear?

@Metadata {
    @PageImage(
        purpose: icon, 
        source: "discordkit-icon", 
        alt: "A technology icon representing the SlothCreator framework.")
}

``DiscordKitBot`` is a swift library for creating Discord bots in Swift. It aims to make a first-class discord bot building experience in Swift, while also being computationally and memory efficient. 

You are currently at the symbol documentation for ``DiscordKitBot``, which is useful if you just need a quick reference for the library. If you are looking for a getting started guide, we have one that walks you through creating your first bot [over here](https://swiftcord.gitbook.io/discordkit-guide/).

> Note: Keep in mind that DiscordKitBot support is still in beta, so the API might change at any time without notice. 
> We do not recommend using DiscordKitBot for bots in production right now.

## Topics

### Clients

- ``Client``

### Working with Guilds

- ``Guild``
- ``Member``

### Working with Channels

- ``GuildChannel``
- ``TextChannel``
- ``VoiceChannel``
- ``CategoryChannel``
- ``StageChannel``
- ``ForumChannel``

### Working with Messages
- ``Message``
- ``MessageType``

### Working with Slash Commands

- ``AppCommandBuilder``
- ``AppCommandOptionChoice``
- ``NewAppCommand``
- ``SubCommand``
- ``CommandOption``
- ``OptionBuilder``
- ``BooleanOption``
- ``StringOption``
- ``NumberOption``
- ``IntegerOption``
- ``CommandData``
- ``InteractionResponse``

### Working with Embeds
- ``BotEmbed``
- ``EmbedBuilder``
- ``ComponentBuilder``
- ``EmbedFieldBuilder``
- ``ActionRow``
- ``Button``