local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Net = require(ReplicatedStorage.Packages.Net)
local localPlayer = Players.LocalPlayer
local infoBillboard = script.InfoBillboard
local remoteEvent = Net:RemoteEvent("PlaceTeleport")
return Observers.observeTagNoAncestry("AFK", function(instance)
	local rig = instance:WaitForChild("Rig", 5)

	if not rig then
		return
	end

	local clone = rig:Clone()
	clone.Name = "ClientRig"
	clone.Parent = rig.Parent
	local clone2 = infoBillboard:Clone()
	rig:Destroy()
	task.defer(pcall, function()
		local v = 5
		local humanoidDescriptionFromUserId = nil

		while v > 0 do
			pcall(function()
				humanoidDescriptionFromUserId = Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
			end)

			if humanoidDescriptionFromUserId then
				break
			end

			task.wait(2)
			v -= 1
		end

		if humanoidDescriptionFromUserId then
			clone.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
		end
	end)
	local head = clone:FindFirstChild("Head")

	if head then
		clone2.Parent = head
		head.ProximityPrompt.Triggered:Connect(function()
			if localPlayer:GetAttribute("__isTeleporting") then
				return
			end

			remoteEvent:FireServer("AFK")
		end)
	end

	return nil
end)