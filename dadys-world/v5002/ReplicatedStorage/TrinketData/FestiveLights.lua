local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
game:GetService("TweenService")
game:GetService("Debris")
local festiveLightsEffects = ReplicatedStorage.Modules.Zones.FestiveLightsEffects
local FestiveLights = {}
FestiveLights.Name = "Festive Lights"
FestiveLights.Icon = "rbxassetid://97258805923306"
FestiveLights.Rarity = "Common"
FestiveLights.Description = "Highlights Ornaments in your vicinity every 15 seconds during matches, making them easier to spot during events."
FestiveLights.TrinketType = "Passive"
FestiveLights.MonsterTrinket = true
FestiveLights.Cost = 0
FestiveLights.Requirement1 = { "None", 0 }

function FestiveLights.ApplyTrinket(instance, _)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	instance:WaitForChild("Stats"):WaitForChild("InElevator")
	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(playerFromCharacter, festiveLightsEffects, instance)
end

function FestiveLights.RemoveTrinket(instance)
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

return FestiveLights