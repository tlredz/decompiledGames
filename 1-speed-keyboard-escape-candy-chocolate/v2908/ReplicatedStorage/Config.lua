local WorldConfigsBuilder = require(script:WaitForChild("WorldConfigsBuilder"))
local v = WorldConfigsBuilder.buildForPlace()
warn("[Config] PlaceId =", game.PlaceId, "| World =", v.WORLD)
return v