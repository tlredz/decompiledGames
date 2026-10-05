local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Replion = require(ReplicatedStorage.Packages.Replion)
local Observers = require(ReplicatedStorage.Packages.Observers)
local GenericCrateData = require(ReplicatedStorage.Shared.GenericCrateData)
local RewardInfo = require(ReplicatedStorage.Common.Utils.Utilities.RewardInfo)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
Inventory = Inventory.Client

local function SetupLabel(p)
	local v = Replion.Client:WaitReplion("Data")

	local function updateLabel()
		local count = 0
		local count2 = 0

		for _, reward in GenericCrateData.Rewards do
			count += 1

			if RewardInfo.playerOwnsItem(localPlayer, reward.Reward) then
				count2 += 1
			end
		end

		p.Text = `Owned: {count2}/{count}`
	end

	v:OnChange("ExplosionSkins.Unlocked", updateLabel)
	v:OnChange("SwordSkins.Unlocked", updateLabel)
	v:OnChange("Emotes.Unlocked", updateLabel)
	updateLabel()
end

return Observers.observeTagNoAncestry("GenericCrateOwnedAmount", function(p)
	task.delay(1, SetupLabel, p)
end)