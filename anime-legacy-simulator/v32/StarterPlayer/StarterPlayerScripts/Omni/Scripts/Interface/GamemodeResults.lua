require("@game/ReplicatedStorage/Omni")
local Controller = require(script.Controller)
local GamemodeResults = {}

function GamemodeResults.Show(p)
	Controller.Show(p)
end

function GamemodeResults.Init()
	Controller.Init()
end

return GamemodeResults