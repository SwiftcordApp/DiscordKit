# ``DiscordKit``

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

### Low-level Socket Management

Handles the low level socket connection to the Discord Gateway, 

- ``RobustWebSocket``
- ``DecompressionEngine``

### Gateway

Connect to, send payloads to and from, and listen for dispatched events from
Discord's WebSocket Gateway API.

Events such as message create, presence update and channel are received through
the Gateway. This allows realtime events to be received, for each client to
be notified immediately about an event. Presence updates, among others, are
also sent to Discord through the Gateway.

- ``DiscordGateway``

### REST

Interact with the Discord REST API. Sending/fetching messages, getting a user's 
full profile and signaling typing start are all done through the REST API.

- ``DiscordAPI``
