# Organized TP

Allows fast remote connection between multiple games & teleports any new player to a target gmae id(api side), being able to edit game target ids without having to shutdown all servers.

# How to use

```lua
local OrgnaizedTP = require(game.ReplicatedStorage.Packages.OrganizedTP)
local Constructor = OrgnaizedTP.new()
Constructor:handleTeleport(true)

Constructor.OnPlayerTeleported:Connect(function()
    -- do sum
end)

Constructor.OnApiCall:Connect(function()
    -- do sum
end)

Constructor.OnError:Connect(function(err)
	warn("Error", err)
end)
```

# You're free to edit the API and use your own just respect the following data structure

```js
const targettedGames = {
  data: {
    [1]: {
      placeID: 1056599488,
      priority: 0, // absolute priority
      tpAll: true,
      whitelist: {}, // tpAll must be true to use whitelist and whitelist must be user IDs
    },
    [2]: {
      placeID: 8956559959,
      priority: 1,
      tpAll: true,
      whitelist: {}, // tpAll must be true to use whitelist and whitelist must be user IDs
    },
  },
};
```