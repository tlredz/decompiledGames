game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
require(packages.Net)
require(packages.Signal)
require(packages.Trove)
local _ = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
require(utils.NumberUtils)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator

local function setupCharacter(character)
	playerDataReplicator:WaitForLoaded()
	local v = playerDataReplicator:TryIndex({ "EquippedAccessories", "Deep Survey Device MK I" }) ~= nil or playerDataReplicator:TryIndex({
		"EquippedAccessories",
		"Deep Survey Device MK II"
	}) ~= nil
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, not v)
	end
end

return {
	Start = function(_)
		localPlayer.CharacterAdded:Connect(setupCharacter)

		if localPlayer.Character then
			task.spawn(setupCharacter, localPlayer.Character)
		end

		playerDataReplicator:Observe({ "EquippedAccessories" }, function()
			if localPlayer.Character then
				setupCharacter(localPlayer.Character)
			end
		end)
	end
}