local PVPZoneClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local pVPHighlight = workspace.Highlights.PVPHighlight
local CollectionService = game:GetService("CollectionService")
local flag = false

function InPVPZone(instance)
	if localPlayer.Character == nil or localPlayer:GetAttribute("DeathTime") then
		return
	end

	local partBoundsInBox = workspace:GetPartBoundsInBox(instance.CFrame, instance.Size)

	for _, v in pairs(partBoundsInBox) do
		if v == localPlayer.Character.HumanoidRootPart then
			return true
		end
	end
end

function PVPZoneClient.IsInPVPZone(player)
	if player == localPlayer then
		print("is player, return yes?", flag)
		return flag
	end

	local character

	if player:IsA("Player") then
		if player.Character == nil then
			return
		else
			character = player.Character
		end
	else
		character = player
	end

	if character:FindFirstChild("Humanoid") == nil or character:FindFirstChild("HumanoidRootPart") == nil or player and player:GetAttribute("DeathTime") then
		return
	end

	local tagged = CollectionService:GetTagged("PVPZone")

	for _, v in pairs(tagged) do
		if not v:IsDescendantOf(workspace) then
			continue
		end

		local partBoundsInBox = workspace:GetPartBoundsInBox(v.CFrame, v.Size)

		for _, v2 in pairs(partBoundsInBox) do
			if v2 == character.HumanoidRootPart then
				return true
			end
		end
	end
end

function EnterPVPZone(p)
	if flag then
		return
	end

	flag = true
	pVPHighlight.Adornee = localPlayer.Character

	repeat
		task.wait()
	until not InPVPZone(p)

	pVPHighlight.Adornee = nil
	flag = false
end

function PVPZoneAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	instance.Touched:Connect(function(otherPart)
		if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPart == localPlayer.Character.HumanoidRootPart then
			EnterPVPZone(instance)
		end
	end)
end

function PVPZoneClient.Init()
	Client.Utility.ForAllTagged("PVPZone", PVPZoneAdded)
end

return PVPZoneClient