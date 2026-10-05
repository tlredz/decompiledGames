local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local localPlayer = game.Players.LocalPlayer
local v = Component.new({
	Tag = "TikiIslandDoor"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local instance = p.Instance
	local seaEventsCleared = localPlayer:WaitForChild("Data"):WaitForChild("SeaEventsCleared")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reflectDoorOpen()
		local v2 = seaEventsCleared.Value >= 50
		instance.CanCollide = not v2
		instance.Transparency = v2 and 1 or 0
	end

	reflectDoorOpen() -- equivalent call inferred; original call site unknown
	p.trove:Add(seaEventsCleared.Changed:Connect(reflectDoorOpen))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v