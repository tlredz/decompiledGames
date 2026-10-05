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

	local sponge = character:FindFirstChild("Sponge") or player.Backpack:FindFirstChild("Sponge")

	if sponge then
		sponge:Destroy()
		return
	end

	local clone = script.Sponge:Clone()
	clone.Parent = player.Backpack

	if #houseFromPlayer.Model.Server.Stains:GetChildren() < 20 then
		for _ = 1, 5 do
			HouseStains.GenerateStain(houseFromPlayer.Model, "Window")
		end
	end
end)
return {
	Action = function(_) end
}