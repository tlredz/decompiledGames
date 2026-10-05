local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BoneNeedleAndThread = {}
BoneNeedleAndThread.Name = "Bone Needle and Thread"
BoneNeedleAndThread.Icon = "rbxassetid://127283465808327"
BoneNeedleAndThread.Rarity = "Common"
BoneNeedleAndThread.Description = "Highlights pumpkins and Halloween Decor in your vicinity every 10 seconds during matches, making them easier to spot during events."
BoneNeedleAndThread.TrinketType = "Passive"
BoneNeedleAndThread.MonsterTrinket = true
BoneNeedleAndThread.Cost = 0
BoneNeedleAndThread.Requirement1 = { "None", 0 }

function BoneNeedleAndThread.ApplyTrinket(instance)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)
	local zones = ReplicatedStorage.Modules:FindFirstChild("Zones")
	local boneNeedleAndThreadEffects = zones and zones:FindFirstChild("BoneNeedleAndThreadEffects")

	if playerFromCharacter and boneNeedleAndThreadEffects then
		instance:WaitForChild("Stats"):WaitForChild("InElevator")
		ReplicatedStorage.Events.ClientAbilityEvent:FireClient(
			playerFromCharacter,
			boneNeedleAndThreadEffects,
			instance
		)
	end
end

function BoneNeedleAndThread.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		return "Slot1"
	end

	if trinket2.Value ~= script.Name then
		return "CantRemove"
	end

	trinket2.Value = "None"
	return "Slot2"
end

return BoneNeedleAndThread