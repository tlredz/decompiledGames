local parent = script.Parent
local localPlayer = game.Players.LocalPlayer
wait(2)
local character = localPlayer.Character
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local v = nil
local v2 = {
	[WorldsId.Testing.FirstSea] = true,
	[WorldsId.KingLegacy.FirstSea] = true
}
local v3 = {
	[WorldsId.Testing.SecondSea] = true,
	[WorldsId.KingLegacy.SecondSea] = true
}
local v4 = {
	[WorldsId.Testing.ThirdSea] = true,
	[WorldsId.KingLegacy.ThirdSea] = true
}

if not character then
	repeat
		wait(0.15)
		character = localPlayer.Character
	until character
end

character:WaitForChild("HumanoidRootPart")
character:WaitForChild("Humanoid")
game:GetService("RunService")
local v5 = nil

function CloneLegacyPose(player)
	local character2 = player.Character
	local rightHand = character2:FindFirstChild("RightHand")

	if not rightHand then
		return
	end

	local fakeLegacyPose = character2:FindFirstChild("FakeLegacyPose")

	if fakeLegacyPose then
		fakeLegacyPose:Destroy()
	end

	local clone = ReplicatedStorage.Chest.Etc.FakeLegacyPose:Clone()
	clone.Parent = character2
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = rightHand
	motor6D.Part1 = clone.MainMotor6D
	motor6D.Parent = clone.MainMotor6D
end

function RemoveLegacyPose(player)
	local fakeLegacyPose = player.Character:FindFirstChild("FakeLegacyPose")

	if fakeLegacyPose then
		fakeLegacyPose:Destroy()
	end
end

parent.Equipped:Connect(function()
	v = true
	ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("CompassFrame", {
		VisibleType = true
	})

	if v3[game.PlaceId] then
		ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("LegacyPoseFrame", {
			Sea = "SecondSea",
			VisibleType = true
		})
	elseif v4[game.PlaceId] then
		ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("LegacyPoseFrame", {
			Sea = "ThirdSea",
			VisibleType = true
		})
	end

	v5 = true
end)
local _ = {
	KrakenArrow = true,
	CrabArrow = true,
	SeaDragonArrow = true,
	DragonArrow = true
}
parent.Unequipped:Connect(function()
	v = nil
	ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("CompassFrame", {
		VisibleType = false
	})

	if v3[game.PlaceId] then
		ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("LegacyPoseFrame", {
			VisibleType = nil
		})
	elseif v4[game.PlaceId] then
		ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("LegacyPoseFrame", {
			VisibleType = nil
		})
	end

	v5 = nil
end)