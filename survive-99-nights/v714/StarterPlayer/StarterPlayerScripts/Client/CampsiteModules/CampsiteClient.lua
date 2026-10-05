local CampsiteClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function CampsiteClient.Init()
	task.spawn(function()
		local campground = workspace:WaitForChild("Map"):WaitForChild("Campground")
		campground:GetAttributeChangedSignal("OuterZoneSize"):Connect(function()
			local outerZoneSize = campground:GetAttribute("OuterZoneSize")
			Client.GlobalSettings.FireOuterZoneSize = outerZoneSize
		end)

		if campground:GetAttribute("OuterZoneSize") then
			local outerZoneSize = campground:GetAttribute("OuterZoneSize")
			Client.GlobalSettings.FireOuterZoneSize = outerZoneSize
		end
	end)
end

return CampsiteClient