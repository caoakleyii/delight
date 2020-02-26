

<div align="center" style="background-color: #FFF;">
 <img src="https://imgur.com/eVYJAMX.png" />
</div>

<div align="center" style="margin-top: 20px; font-weight: bold; font-style: italic;">
A highly optimized, authorative, and multiplayer server boiler plate for Love2D.
</div>

# Features
#### *Byte Sized Network Messages*
Each network message packed as condensly as possible, and only sending exactly what is needed using lua's string pack methods.

#### *Event Based Network Messages*
Network messages are hooked into as an event for a specific node.

#### *Event Based Collision Detection*
Models are hooked into the Love2D World Collision Detection.

####  *Shared Code Base*
With the design, much of the game logic is shared between client and server.


# Quick Start

```bash
# Clone this repository.
git clone --depth=1 https://github.com/caoakleyii/delight.git <YOUR_PROJECT_NAME>

# Move to your project.
cd <YOUR_PROJECT_NAME>

# Start the server
bin/start_server.cmd

# Start the client
bin/start_client.cmd
```

# Documentation
#### Classes
* _main.lua_
  *  As with any Love2D Project, this is the entry point for both client and server. Within this, you'll find the `love.load()`, `love.update(dt)` and `love.draw` functions.
  *  Each entity will be able to implement their own `load()`, `update(dt)` and `draw()` methods, that will be called if they are added to the `EntitySystem`
*  _entity_system.lua_
   *  This is where the entities running within the game will be easily managed, adding, accessing, and removing.
   *  EntitySystem also has an event handler, called `signals`, you are able to hook an entity into the four collision events, `begin_contact`, `end_contact`, `pre_solve`, and `end_solve`
   *  The entity system also create the `love.physics.World`
* _client.lua_
  * This handle the configuration of which server to connect to, and shares the same node ID as the `Server`
  * The `Client` also handles the intial reception and sending of network messages.
* _server.lua_
  * This handles the configuration of the `Server` and shares the same node ID as the `Client`
  * The `Server` handles the reception of network messages
  * `Server` also has public methods to send a message to a single player, all players, or all players except one
    * `:send_to(player, message_type, data)`
    * `:broadcast(message_type, data)`
    * `:broadcast_except(player, message_type, data)`
* _networking.lua_
  * Uses a service architecture to handle packaging and unpackaging network messages into small packed strings.
  * `Networking` also has an event handler, called `signals`, you are able to hook a specific node to receive an event when it receives a network message.
    * Signals are only sent to nodes with the same `.id`. This allows you to have 1:1:1 control over sending a message from client-server-client, all while controlling the same instance of an object.
    * An example of this is within the `Character` class:
    ```lua
        -- we hook into the `player_input` signal for when this specific character has an input down like so, this is done on the server and all clients
        networking:signal(NETWORK_MESSAGE_TYPES.player_inputs, self, self.on_player_inputs)

        -- when a local player has a key down, we send this to the server
        client:send(NETWORK_MESSAGE_TYPES.player_inputs, { id = self.id, key = key })

        -- the server receives this signal, processes it and then broadcasts to other players
        function Character:on_player_inputs(data)
            self.keys_down[data.key] = true
            if server then
                server:broadcast_except(self.player, NETWORK_MESSAGE_TYPES.player_inputs, data)
            end
        end
    ```
* _player_spawner.lua_
  * Handles connecting and spawning new players, as well as telling them about existing
* _ai_spawner.lua_
  * Handles the spawning of new AI, in this case we only have Enemy AI.
* _lib/networking/messages/*.lua_
  * These are the message services that handle properly packaging and unpackaging each network message. At the very least, each message requries a `signed byte` as `type` signifying the type of message, and an `unsigned int` as `id` corresponding to which node id should be able to receive the message.