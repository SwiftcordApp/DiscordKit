# ``DiscordKitCore``

DiscordKit: A Discord API implementation for Swift. 

> DiscordKit is geared towards supporting human accounts,
> and does not work with bot accounts at the moment. Adding
> bot support would not be tough, and might be considered in the future.

Supports most documented REST endpoints, plus most Gateway opcodes and events.
Written in pure Swift 5, and uses only built-in macOS APIs (with the excecption
of the `Reachability` package for improved Gateway reconnection). The Gateway
implementation uses a convenient subscription pattern, for the greatest ease
in listening for them. All responses are also decoded as dedicated structs
per API "object", which takes the guesswork out of using this package.

## Topics

### Gateway

Connect to, send payloads to and from, and listen for dispatched events from
Discord's WebSocket Gateway API.

Events such as message create, presence update and channel are received through
the Gateway. This allows realtime events to be received, for each client to
be notified immediately about an event. Presence updates, among others, are
also sent to Discord through the Gateway.

- ``DiscordGateway``
- ``CachedState``
- ``GatewayConnProperties``

### REST

Interact with the Discord REST API. Sending/fetching messages, getting a user's 
full profile and signaling typing start are all done through the REST API.

- ``DiscordAPI``

### Utilities

- ``EventDispatch``
- ``DecodableThrowable``

### Low-level Socket Management

Handles the low level socket connection to the Discord Gateway, 

- ``RobustWebSocket``
- ``DecompressionEngine``

### Configuration

Configuration options like client parity version and URLs, used in various places 
to make requests/set headers/identify.

- ``GatewayConfig``
- ``ClientParityVersion``

### Endpoint "Objects"

Structs of all (documented) payloads that can be sent to or received from Discord
endpoints. These are named "objects" in the official Discord Developer docs.

- ``Activity``
- ``ActivityAssets``
- ``ActivityButton``
- ``ActivityEmoji``
- ``ActivityOutgoing``
- ``ActivityParty``
- ``ActivitySecrets``
- ``ActivityTimestamp``
- ``AllowedMentions``
- ``Application``
- ``Attachment``
- ``Channel``
- ``ChannelMention``
- ``ChannelPinsUpdate``
- ``ChannelUnreadUpdate``
- ``ChannelUnreadUpdateItem``
- ``Connection``
- ``Embed``
- ``EmbedAuthor``
- ``EmbedField``
- ``EmbedFooter``
- ``EmbedMedia``
- ``EmbedProvider``
- ``Emoji``
- ``GatewayGuildRequestMembers``
- ``GatewayHeartbeat``
- ``GatewayHello``
- ``GatewayIdentify``
- ``GatewayIncoming``
- ``GatewayOutgoing``
- ``GatewayPresenceUpdate``
- ``GatewayResume``
- ``GatewayVoiceStateUpdate``
- ``Guild``
- ``GuildBan``
- ``GuildEmojisUpdate``
- ``GuildFolderItem``
- ``GuildIntegrationsUpdate``
- ``GuildMemberRemove``
- ``GuildMemberUpdate``
- ``GuildRoleDelete``
- ``GuildRoleEvt``
- ``GuildSchEvtUserEvt``
- ``GuildScheduledEvent``
- ``GuildScheduledEventEntityMeta``
- ``GuildStickersUpdate``
- ``GuildUnavailable``
- ``GuildWelcomeScreen``
- ``GuildWelcomeScreenChannel``
- ``Integration``
- ``IntegrationAccount``
- ``IntegrationApplication``
- ``Member``
- ``Message``
- ``MessageACKEvt``
- ``MessageActivity``
- ``MessageComponent``
- ``MessageDelete``
- ``MessageDeleteBulk``
- ``MessageInteraction``
- ``MessageReadAck``
- ``MessageReference``
- ``MutualGuild``
- ``NewAttachment``
- ``NewMessage``
- ``OutgoingMessage``
- ``PartialApplication``
- ``PartialGuild``
- ``PartialMessage``
- ``PartialPresenceUpdate``
- ``PermOverwrite``
- ``Presence``
- ``PresenceClientStatus``
- ``PresenceUpdate``
- ``PresenceUser``
- ``Reaction``
- ``ReadyEvt``
- ``Role``
- ``RoleTags``
- ``StageInstance``
- ``Sticker``
- ``StickerItem``
- ``SubscribeGuildEvts``
- ``Team``
- ``TeamMember``
- ``ThreadListSync``
- ``ThreadMember``
- ``ThreadMembersUpdate``
- ``ThreadMeta``
- ``TypingStart``
- ``User``
- ``UserProfile``
- ``UserSettings``
- ``VoiceState``
