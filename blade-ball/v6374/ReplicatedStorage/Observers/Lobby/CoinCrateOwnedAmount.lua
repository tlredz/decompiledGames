local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Replion = require(ReplicatedStorage.Packages.Replion)
local Observers = require(ReplicatedStorage.Packages.Observers)
local GenericCoinCrateData = require(ReplicatedStorage.Shared.GenericCoinCrateData)
local RewardInfo = require(ReplicatedStorage.Common.Utils.Utilities.RewardInfo)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
Inventory = Inventory.Client

local function SetupLabel(p)
	local v = Replion.Client:WaitReplion("Data")

	local function updateLabel()
		local count = 0

		for i = 1, 9 do
			local reward = GenericCoinCrateData.Rewards[i]

			if reward and RewardInfo.playerOwnsItem(localPlayer, reward.Reward) then
				count += 1
			end
		end

		p.Text = `Owned: {count}/{9}`
	end

	v:OnChange("ExplosionSkins.Unlocked", updateLabel)
	v:OnChange("SwordSkins.Unlocked", updateLabel)
	v:OnChange("Emotes.Unlocked", updateLabel)
	updateLabel()
end

return Observers.observeTagNoAncestry("CoinCrateOwnedAmount", function(p)
	task.delay(1, SetupLabel, p)
end)