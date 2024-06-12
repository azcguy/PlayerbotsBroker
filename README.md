## PlayerbotsBroker

This Addon/Library serves as a layer between other addons and server with mod-playerbots.
This is mainly developed for PlayerbotsPanel, but it is designed to be used 

This addon uses custom protocol for communication through AddonMsg channel with the server, which is hidden from the user.
This protocol eventually should replicate all commands available through normal playerbot chat messages.

- Query bots for various data on demand
- Receive reports from other bots 
- Store received data globally between characters (not between accounts)
- Send commands
- Receive lua events that you can subscribe to 



