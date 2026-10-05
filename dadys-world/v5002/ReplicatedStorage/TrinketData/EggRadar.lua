local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
game:GetService("TweenService")
game:GetService("Debris")
local eggRadarEffects = ReplicatedStorage.Modules.Zones.EggRadarEffects
local EggRadar = {}
EggRadar.Name = "Egg Radar"
EggRadar.Icon = "rbxassetid://82339467350501"
EggRadar.Rarity = "Common"
EggRadar.Description = "Highlights Baskets in your vicinity every 15 seconds during matches, making them easier to spot during events."
EggRadar.TrinketType = "Passive"
EggRadar.HolidayTrinket = true
EggRadar.Cost = 0
EggRadar.Requirement1 = { "None", 0 }

function EggRadar.ApplyTrinket(instance, _)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	instance:WaitForChild("Stats"):WaitForChild("InElevator")
	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(playerFromCharacter, eggRadarEffects, instance)
end

function EggRadar.RemoveTrinket(instance)
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

return EggRadar