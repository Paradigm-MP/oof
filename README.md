<p align="center"><img src="https://i.imgur.com/DImcy1B.jpg"></p>

# OOF - Object-Oriented Framework for developing with Lua in FiveM and RedM
OOF is an Object-Oriented Framework for developing scripts in Lua for FiveM and RedM.

## Disclaimer
OOF is entirely functional, but has not been officially released. Primarily, we are missing lots of documentation and need to clean up the codebase and remove unnecessary things. OOF should be officially released sometime in Q1 2021.

## Disclaimer
**This is not a "drag and drop" resource that you can simply install on your server.** This is a *framework* that can be used to help you code faster and better. You must be proficient at scripting to use this and must have experience with writing resources from scratch to use this. If you are looking for something to help improve your RP server, this is not what you are looking for. This is intended for server developers who want to create the next great server from scratch (or with a little help from OOF modules), guided by their creativity and ingenuity. If you decide to use other resources, you may have difficulty integrating them into this framework. OOF is still being developed, so there are unfinished parts. We encourage you to contribute!

## Intro
Want to make a cool server in FiveM or RedM, but don't want to deal with all the messy natives? OOF is perfect for that.

Our goal with OOF is to abstract away all of the messiness included with calling natives directly and wrap it all up in a nice object-oriented package for you to use. It helps to promote better coding style and keeps your code more organized. Plus, OOF supports inheritance (even multiple inheritance) so you can reuse logic from other classes.

If you'd like an example of what this framework is capable of, check out our "Wave Survival" gamemode on RedM. It was created entirely using this framework.

## [Wiki](https://github.com/Paradigm-MP/oof/wiki)
We have a wiki that we're working on for OOF. It includes API references as well as examples to help you understand how to use different parts of OOF. Feel free to check it out and suggest changes.

## Getting Started
This getting started guide assumes that you have experience with installing server resources and editing configuration files.

### Setting up your workspace
You'll probably want to remove most, if not all, existing resources on your server. Most are not compatible with OOF and you'll be writing them from scratch based on what you need. OOF also comes with [mysql-async](https://github.com/brouznouf/fivem-mysql-async/tree/2.0) built in, so working with persistent data is easy.

For our Wave Survival Gamemode, the only resources that we use are:
- [system]/[builders]/yarn
- [system]/sessionmanager-rdr3
- The core gamemode and OOF in one resource


Your core gamemode resource layout should look something like this:
```
gamemode-name
--\ oof
    --\ server
        -- sNetwork.lua
        -- sPlayer.lua
        -- etc...
    --\ client
        -- AssetRequester.lua
        -- Camera.lua
        -- etc...
    --\ shared
--\ module-name
    --\ server
    --\ client
    --\ shared
--\ module2-name
    --\ server
    --\ client
--\ module3-name
    --\ server
fxmanifest.lua
```

Each module can be thought of like what you would usually see in a normal resource. It has some purpose that it carries out, and might interact with other scripts. 

We separate each module into three types of Lua files: server, client, and shared. The files within `server` are files that only the server has access to; `client` files are files that only the clients have access to. Files within `shared` are files that both the server and client can access, such as shared classes, data structures, and config files.

OOF itself is a module. You must load in all of the OOF files in a specific order to ensure that they are loaded properly. This can be seen in the `example_fxmanifest.lua` file. Your own fxmanifest should look something like this. The example fxmanifest only loads the OOF module, assuming that you named it `oof`. When you see `Uncomment ONE of these depending on the game this is running on` in the `example_fxmanifest.lua`, make sure you only uncomment one of those when adding oof to your gamemode. Make sure to do this for both client and server scripts since it is a shared file. Your fxmanifest might look something like this:

```lua
client_scripts {
    'oof/shared/game/IsRedM.lua',
    --'oof/shared/game/IsFiveM.lua',

    'oof/shared/overloads.lua',
    'oof/shared/utilities/*.lua',
    ...

... 

server_scripts {

    'oof/shared/game/IsRedM.lua',
    --'oof/shared/game/IsFiveM.lua',

    'oof/server/sConfig.lua',
    'oof/shared/overloads.lua', -- load order position does not matter because this is non-class code
    'oof/shared/utilities/*.lua',
    ...

...
```

OOF interally uses MySQL as its database. This allows for you to easily save and load player data. However, you'll have to do a bit of setup in order for this to work.

Head on over to [MySQL](https://www.mysql.com/) and install your preferred version according to your platform. For Linux, you can use a command to install it. Once you've installed MySQL in your server environment, keep reading.😀

Now we'll need to modify the server's `.cfg` files. You only need to load your gamemode because the other system scripts are automatically loaded by the server itself. You can load your single-resource gamemode with 
```
ensure my-gamemode
```
where `my-gamemode` is the name of your resource. 

You also need to set the MySQL connection settings in your `.cfg` as well. Add this line to set the connection convar:

```set mysql_connection_string "server=127.0.0.1;database=DATABASE_NAME;userid=DATABASE_USERNAME;password=USER_PASSWORD"```

Adjust the fields according to how you set up MySQL. For most users, `127.0.0.1` should be fine to connect to your locally hosted database. If it's your first time settting this up, you'll need to create a database to connect to. Try running this command in MySQL to create a new one:

```
CREATE DATABASE my_new_database;
```

That'll create a new database that you can now connect to and store data in.

In terms of adding other resources to the config, we recommend that you use the our example fxmanifest as a base and then add onto it as you create more modules. There are designated places within the fxmanifest that you should load your module's Lua files (see the comments). This means that you won't ever have to touch the config files after today!

Once you think you've created your single-resource gamemode correctly and installed OOF, start your server. You should see two messages that look like this:
```
-------------------------

Initializing OOF...

-------------------------
```
and this:
```
-------------------------

OOF initialized successfully!

-------------------------
```
if you see those two messages, congrats! You've successfully installed OOF and have taken your first steps to becoming a master of the framework. If you don't see those messages, something went wrong and you should try the above steps again.

### Essential modules
There are some modules that are *essential* to working with OOF. Because OOF isn't particularly compatible with existing resources, we've created some modules to help get you started. Keep in mind that it's encouraged that you edit and extend the capabilities of these modules according to your needs. We created these out of necessity for our gamemode.

#### [Chat Module](https://github.com/Paradigm-MP/oof-chat)
The chat module is another very essential module. Internally, it uses the UI module, so you'll have to have the UI module installed before using the chat module. This module gives you all the functionality you'd expect from a chat resource. It's still a somewhat work-in-progress as it was originally ported from another game, but it works fairly well most of the time.

#### [Events Module](https://github.com/Paradigm-MP/oof-defaultevents)
The events module includes a lot of default events that you'll probably want to subscribe to and use. Some of these events include when a player dies, a ped dies, and ped spawn events. Additionally, it includes events that fire every second, minute, and hour for convenience.

#### [Blackscreen Module](https://github.com/Paradigm-MP/oof-blackscreen)
This is a very simple module that simply allows you to make the screen fade or cut to black, depending on the arguments you supply. It's important to use something like this so that the black screen overlays over all existing UI and game elements. It's also a great script for learning how the class and event systems work in OOF.

The installation for each module is very similar, but some have dependencies of others, so make sure to add them in the proper order in the fxmanifest.

## Class System
As mentioned previously, OOF allows you to use classes instead of having free-floating code within files. **__We highly encourage you to wrap everything in a class for the sake of organization, clarify, and future extensibility.__** For example, let's consider this simple script:
```lua
local counter = 0

function IncrementCounter(amount)
    counter = counter + amount
end
```
This simple script simply adds the specified amount to the counter variable every time `IncrementCounter` is called. This could be used in a number of different ways, like a player's score or a counter for points.

Now, let's take a look at the class implementation of it.
```lua
Counter = class()
function Counter:__init()
    self.count = 0
end

function Counter:Increment(amount)
    self.count = self.count + amount
end
```
Here, we create a new class called `Counter`. Any module within our single-resource gamemode can use this class, so it's important that you choose a unique name that's not used anywhere else.

The first line tells OOF that we want to define a class. If we want it to inherit from another class, we pass that class name into the `class()` call.

The next line is the initialization function of the class. Every class must have this method. This method is called when you first initialize an instance of a class, like so:
```lua
local score_counter = Counter()
```
In the above snippet, it creates a new `Counter` class and internally calls the `__init()` function, setting its `count` variable to 0. Now in order to increment our counter, we call:
```lua
score_counter:Increment(5)
```
Now our counter's internal `count` variable is at 5. Isn't that cool? We can make as many counters as we want now, all counting independently.

But how do we access it? You can do so like this:
```lua
local count = score_counter.count
```
But that doesn't seem very good, now does it? Let's make it better with our OOF helper method, `getter_setter()`.
```lua
Counter = class()
function Counter:__init()
    getter_setter(self, "count")
end

function Counter:Increment(amount)
    self.count = self.count + amount
end
```
Now if we want to get the value of the internal count, we can do:
```lua
local count = score_counter:GetCount()
```
But what if we want to reset it to 0? The `getter_setter()` helper also gives you a set method like so:
```lua
score_counter:SetCount(0)
```
Cool, right? If you want more functionality in a getter/setter method, you can define it right inside the class, too! 

### Singletons
Now you might be wondering how to convert your code snippets into usable classes without too much extra effort. Fear not, there's a very simple way to do that!

Let's say you've got some code that looks like this:
```lua
local money = 10
local gems = 2

-- Called when the player gets a gem
function PlayerGetGem()
    gems = gems + 1
    print(string.format("You got a gem! Total gems: %d", gems)
end

-- Called when the player gets money
function PlayerGetMoney(amount)
    money = money + amount
    print(string.format("You got %d money! You now have %d total.", amount, money))
end
```
This is just some basic logic holds a couple of variables. We've got some functions that update these values, too. How do I run this once so that I can continuously use it?

Answer: use a singleton, aka a class that only has one instance of itself. 
```lua
PlayerMoney = class()
function PlayerMoney:__init(starting_money, starting_gems)
    getter_setter(self, "money")
    getter_setter(self, "gems")
    self:SetMoney(starting_money)
    self:SetGems(starting_gems)
end

function PlayerMoney:PlayerGetGem()
    self:SetGems(self:GetGems() + 1)
    print(string.format("You got a gem! Total gems: %d", self:GetGems())
end

function PlayerMoney:PlayerGetMoney(amount)
    self:SetMoney(self:GetMoney() + amount)
    print(string.format("You got %d money! You now have %d total.", amount, self:GetMoney()))
end

PlayerMoney = PlayerMoney(10, 2)
```
Most of this code should look familiar now from what we learned above! The only new things are the singleton and the class constructor arguments. Let's go over those now.

The singleton is established at the last line, where we set the class equal to an instance of the class. This creates a new class instance and ensures that we cannot create another instance of it because the original class has been overwritten.

This class is initialized with two arguments: 10 and 2. They enter the `__init()` constructor in the same order that they are passed in, and are usable there. In the constructor, you can see that we set our two internal variables to the values passed in. Pretty neat, huh?

Another thing that OOF does it a `print()` call override. We append the resource name and the timestamp on it for better debugging.

## Events System
We use a custom events system through OOF instead of the default events system. This system is fully integrated with the class system so that you can get all the information you need when events are called.

### Non-Network Events
Non-network events are events that exist only on either the server or client. They are not used for transferring data between the two - those are network events. Non-network events are great for passing data between modules or triggering other things to happen based on certain conditions.

Let's look at an example. Take a look at the Events module that was mentioned above, specifically `client/cDefaultEvents.lua`. Here, there is a bunch of logic that relates to the events that this module fires. When an event is "fired", that means it will trigger any event subscriptions of the same name. Consider this:
```lua
Events:Subscribe("PedDied", function(args)
    -- Logic here
end)
```
This code snippet subscribes to the event with name `"PedDied"`, which `cDefaultEvents.lua` calls when it detects a ped has died. But that's not all! The events module also passes in a parameter specifying which ped has died. This is very useful so we can check what kind of ped died and do more things based on that. The ped argument passed in is a custom class from OOF as well, so we can get a lot of different data about it. Let's try this:
```lua
Events:Subscribe("PedDied", function(args)
    local ped_pos = args.ped:GetPosition()
    print(string.format("Ped died! Position: X: %.0f, Y: %.0f, Z: %.0f", ped_pos.x, ped_pos.y, ped_pos.z))
end)
```
In the above snippet, we are now getting the position of the ped right when it dies, and printing it to the console! Wasn't that easy? Now we can do all sorts of other stuff, like add points to our counter, or spawn something else at its position.

If you'd like to create your own network events, it's super easy to do!

#### `Events:Fire(event_name, data)`
- Fires an event across all modules on either server or clientside, depending on where it was called
- `event_name` (string): name of the event. Must match the event subscription to trigger
- `data` (table, optional): table of data that you want to send with the event.

### Network Events
How do we send data from the server to client, or client to server? We've got a few different solutions for that.

#### `Network:Send(event_name, target(s), data)`
- Server ONLY
- Sends data to a specific client or clients
- `event_name` (string): name of the event. Must match client subscription to trigger
- `target(s)` (player id OR table of player ids OR Player): target client(s) that the data will be sent to
- `data` (table): table of data to send to the client(s). Only supports primitive data types like numbers, strings, and tables, so make sure to convert from a class type into a serializable format beforehand.

#### `Network:Broadcast(event_name, data)`
- Server ONLY
- Sends data to all clients.
- `event_name` (string): name of the event. Must match client subscription to trigger
- `data` (table): table of data to send to the clients. Only supports primitive data types like numbers, strings, and tables, so make sure to convert from a class type into a serializable format beforehand.

#### `Network:Send(event_name,  data)`
- Client ONLY
- Sends data to the server from the client
- `event_name` (string): name of the event. Must match server subscription to trigger
- `data` (table): table of data to send to the server. Only supports primitive data types like numbers, strings, and tables, so make sure to convert from a class type into a serializable format beforehand.

These are all global methods to send data. Now let's look at receiving data.

Here's a small code snippet that demonstrates a "ping pong" sort of effect. 

```lua
-- Serverside
TestPingPongServer = class()
function TestPingPongServer:__init()

    Network:Subscribe("Pong", function(args) self:Pong(args) end)

    Events:Subscribe("ClientModulesLoaded", function(args) self:ClientModulesLoaded(args) end)
end

-- Event fired by OOF when a player finishes loading all their scripts after connecting
function TestPingPongServer:ClientModulesLoaded(args)
    Network:Send("Ping", args.player, {
        ping_message = "hello from server!"
    })
end

-- Network event receiver for when a client calls "Pong"
function TestPingPongServer:Pong(args)
    print(string.format("Pong! Message from %s: %s", args.player:GetName(), args.pong_message))
end

-- Singleton
TestPingPongServer = TestPingPongServer()

-------------
-- Clientside
TestPingPongClient = class()
function TestPingPongClient:__init()
    Network:Subscribe("Ping", function(args) self:Ping(args) end)
end

function TestPingPongClient:Ping(args)
    print(string.format("Ping! Message: %s", args.ping_message))

    Network:Send("Pong", {
        pong_message = "hello from client!"
    })
end

-- Singleton
TestPingPongClient = TestPingPongClient()
```
There's a lot going on here in this example, so let's break it down.

The serverside code creates a singleton class and adds two subscriptions in the initialization. These subscriptions are hooked to specific event names that are specified as the first arguments. 

`Network:Subscribe(event_name, callback)` subscribes to a network event that is called by clients. When it is called, the callback function is triggered. The callback includes a table of data that includes the `player` (the Player instance of the client that sent the data) and any data that the player also sent.

`Events:Subscribe(event_name, callback)` works similarly, except that it only works on either serverside or clientside. In this case, we're subscribing to the `ClientModulesLoaded` event that OOF calls when a client has finished loading all their scripts and is ready to be sent data.

The code execution goes something like this:
1. Server loads its scripts and creates the `TestPingPongServer` singleton.
2. The `TestPingPongServer` singleton initializes and subscribes to the two events.
3. A client connects and downloads and executes all scripts. This includes the setup of the singleton, as well as the event subscriptions.
4. After the client loads all scripts, the server receives the `ClientModulesLoaded` event. 
5. Inside the callback, the server triggers the network event on the client.
6. The client receives the network event along with the data passed, and then calls another network event to the server with different data.
7. The server receives this data and prints it accordingly.

The code flow is very similar to default RedM/FiveM networking events since OOF uses it internally. It just has a little bit of a different syntax than you're used to with some extra functionality. It's important that you understand how events work as they are a key part of any gamemode.

## UI System
OOF comes with a system that allows you to easily create and manage UI / HUD, or really anything that you want to display on the screen using HTML, CSS, and JS. You can create as many UI elements as you want. It's super easy to use and allows you to use simple events to transfer data between your Lua scripts and JS scripts.

### Displaying simple player data
To get comfortable with the UI system, let's create a simple UI that displays the player's name and a welcome message. 

To do this, we'll need to create a few files. We'll keep it simple for this example, but it should give you an idea of how things generally work. There are a couple modules that we've released, such as [blackscreen](https://github.com/Paradigm-MP/oof-blackscreen) and [chat](https://github.com/Paradigm-MP/oof-chat), that are great learning resources.

Let's make a new module called `welcomemessage` for this. Inside, the file tree should look like this:

```
welcomemessage
--\ client
    -- cWelcomeMessage.lua
    --\ ui
        -- index.html
        -- script.js
        -- style.css
```

Make sure to add these files to your `fxmanifest`. Add the Lua right under `-- Add other modules here (client and shared)` and add the three ui files under `files` at the end.

Let's focus on `cWelcomeMessage` first. We prefixed it with `c` so that it's easy to differentiate between server and client files with the same name. In the future, we might add an `sWelcomeMessage` on the server side to fetch data for players and perhaps display their play time.

`cWelcomeMessage.lua`
```lua
cWelcomeMessage = class()

function cWelcomeMessage:__init()
    -- Create the UIInstance and store it in our class for easy access
    self.ui = UI:Create({name = "welcome_message", path = "welcomemessage/client/ui/index.html"})

    -- Wait until the UI is ready to CallEvent on it. If we CallEvent before it has loaded, it might not work
    self.ui:Subscribe('Ready', function()
        self:UIReady()
    end)

    -- Control.Jump is normally space, so we'll use that here
    self.key_to_hide = Control.Jump

    -- First tell KeyPress to look for this key being pressed
    KeyPress:Subscribe(self.key_to_hide)

    -- Then subscribe to the KeyUp event, which KeyPress will call when the key is pressed and you release it
    Events:Subscribe('KeyUp', function(args)
        self:KeyUp(args)
    end)

    self.welcome_message = "Hello %s! Welcome to the server! Press Space to hide this."
end

function cWelcomeMessage:UIReady()
    -- CallEvent on the UI to send the message we want to display
    self.ui:CallEvent("DisplayMessage", 
    {
        message = string.format(self.welcome_message, LocalPlayer:GetPlayer():GetName())
    })
end

function cWelcomeMessage:KeyUp(args)
    -- Hide welcome message when key is pressed. You can also do this just in JavaScript, but we are showing more API here. :)
    if args.key == self.key_to_hide then
        self.ui:Hide()
    end 
end

-- Initialize it as a singleton, because this is essentially a "welcome message manager"
cWelcomeMessage = cWelcomeMessage()
```

Hopefully the comments on the above code snippet make sense, as they should explain what's going on. We also are using another part of OOF called `KeyPress`, which is a great way to detect when a player presses certain keys.

`index.html`
```html
<html>
    <!-- Load jQuery from OOF UI. Optional, but highly recommended -->
    <script src="../../../oof/client/ui/jquery.js" type="text/javascript"></script>
    <script src="script.js" type="text/javascript"></script>
    <link rel="stylesheet" href="style.css" type="text/css">
    <body>
        <div class='welcome-message'></div>
    </body>
</html>
```

`style.css`
```css
/* Basic styling to make it appear in the middle of the screen */
div.welcome-message
{
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: red;
    color: white;
    font-weight: bold;
    border: 4px solid orange;
    font-size: 40px;
    padding: 20px;
}
```

`script.js`
```js
// Wrap the entire script in the .ready() to make sure everything has finished loading
$(document).ready(function() 
{
    // Subscribe to the DisplayMessage event to receive the data from Lua
    OOF.Subscribe("DisplayMessage", (data) => 
    {
        // Use jQuery to set the text of our welcome message
        $('div.welcome-message').text(data.message);
    })

    // Call the Ready event at the bottom of the script after everything has loaded
    // This tells Lua that this UI is ready to be used
    OOF.CallEvent("Ready");
})
```

If you did everything right, you should see a welcome message appear with your name when you reload the resource and join the server! And if you press space, it will disappear! That wasn't so bad, right? See some of our other released modules for more UI usage examples and see our wiki for API reference. Our UI system is very powerful and we've only just scratched the surface.


## Closing Remarks
OOF isn't perfect by any means. There are certainly a lot of improvements that could be made and plenty of great things that could be added. The documentation here is very lacking, so it will probably take a lot of looking through OOF to understand what is available and how to use it. 

## Contact Us
Feel free to contact us (Paradigm - Lord Farquaad or Dev_34) on our [Discord here](https://discord.gg/XAQ34Td). We'll be happy to answer any questions you might have about OOF or provide you relevant examples on how to do certain things. Or if you'd like to collaborate on a project, let us know too! We always have too many ideas and not enough time.

## Credits
Huge props to the developers of FiveM and RedM, because without them, this wouldn't be possible. And huge thanks to the RedM/FiveM community as well, because much of the code within OOF regarding natives is based on snippets posted or existing open source scripts. Some specific files within OOF reference where specific code snippets were taken from - all credit for those go to the original authors.

Credit to [Brouznouf](https://github.com/brouznouf) for the original [mysql-async repo](https://github.com/brouznouf/fivem-mysql-async/tree/2.0). We only made slight modifications to integrate it with OOF.
