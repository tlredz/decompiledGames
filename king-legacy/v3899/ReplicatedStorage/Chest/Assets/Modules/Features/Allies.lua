local Players = game:GetService("Players")
game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local ProfileManager = require(ReplicatedStorage.Chest.Assets.Modules.ProfileManager)
local localPlayer = Players.LocalPlayer
local Allies = {}
local total = 0
local v = 0

function Allies:UpdateMountPrompt()
	for _, proximityPrompt in ipairs(CollectionService:GetTagged("MountPrompt")) do
		if not proximityPrompt:IsA("ProximityPrompt") then
			continue
		end

		local promptOwner = proximityPrompt:GetAttribute("PromptOwner")

		if not promptOwner then
			continue
		end

		local child = Players:FindFirstChild(promptOwner)

		if child then
			if _G.CheckAllyClient(localPlayer, child) then
				proximityPrompt.Enabled = true
			else
				proximityPrompt.Enabled = false
			end
		else
			CollectionService:RemoveTag(proximityPrompt, "MountPrompt")
		end
	end
end

function Allies.Step(_, p)
	total += p

	if total < 1 or not _G.CheckAllyClient then
		return
	end

	total = 0
	local count = 0

	for _, v2 in pairs(Players:GetPlayers()) do
		if v2 == localPlayer then
			continue
		end

		local profile = ProfileManager.GetProfile(v2)

		if not profile then
			continue
		end

		local partName = profile:GetPartName("Head")

		if not partName then
			continue
		end

		if _G.CheckAllyClient(localPlayer, v2) then
			count += 1

			if not partName:FindFirstChild("AllyGUI") then
				local clone = script.AllyGUI:Clone()
				clone.Parent = partName
			end
		else
			local allyGUI = partName:FindFirstChild("AllyGUI")

			if allyGUI then
				allyGUI:Destroy()
			end
		end
	end

	if v ~= count then
		v = count
		Allies:UpdateMountPrompt()
	end
end

return Allies