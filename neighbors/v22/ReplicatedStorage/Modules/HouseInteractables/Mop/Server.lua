local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Types)
local House = require(ServerStorage.Modules.Neighbors.House)
local HouseStains = require(ServerStorage.Modules.HouseStains)
script.Parent.GetTool.OnServerEvent:Connect(function(player)
	local character = player.Character
	local houseFromPlayer = House:GetHouseFromPlayer(player)

	if not (character and houseFromPlayer) then
		return
	end

	local mop = character:FindFirstChild("Mop") or player.Backpack:FindFirstChild("Mop")

	if mop then
		mop:Destroy()
		return
	end

	local clone = script.Mop:Clone()
	clone.Parent = player.Backpack

	if #houseFromPlayer.Model.Server.Stains:GetChildren() < 20 then
		for _ = 1, 5 do
			HouseStains.GenerateStain(houseFromPlayer.Model, "Floor")
		end
	end
end)
return {
	Action = function(_) end
}