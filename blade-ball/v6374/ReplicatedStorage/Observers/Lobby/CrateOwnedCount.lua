local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local Replion = require(ReplicatedStorage.Packages.Replion)
local Observers = require(ReplicatedStorage.Packages.Observers)
local LTM = require(ReplicatedStorage.Shared.LTM)
local LTMCrateData = require(ReplicatedStorage.Shared.LTMCrateData)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
local client = Inventory.Client

local function OwnsCrateItem(_, p)
	return #client:FindItems(p.ItemType, p.Reward.Value) > 0
end

local function SetupLabel(p)
	local v = Replion.Client:WaitReplion("Data")
	local currentLTM = LTM.getCurrentLTM()
	local v2 = currentLTM and currentLTM.getGameMode()
	local v3 = v2 and LTMCrateData.Profiles[v2]

	local function updateLabel()
		if not v3 then
			return
		end

		local count = 0

		for i = 1, 8 do
			local v4 = v3.RewardPool[i]

			if v4 and #client:FindItems(v4.ItemType, v4.Reward.Value) > 0 then
				count += 1
			end
		end

		p.Text = `Owned: {count}/{8}`
	end

	v:OnChange("ExplosionSkins.Unlocked", updateLabel)
	v:OnChange("SwordSkins.Unlocked", updateLabel)
	v:OnChange("Emotes.Unlocked", updateLabel)
	LTM.OnModeChange(function(_)
		currentLTM = LTM.getCurrentLTM()
		v2 = currentLTM and currentLTM.getGameMode()
		v3 = v2 and LTMCrateData.Profiles[v2]
		updateLabel()
	end)
	updateLabel()
end

return Observers.observeTagNoAncestry("CrateOwnedCount", function(p)
	task.delay(1, SetupLabel, p)
end)