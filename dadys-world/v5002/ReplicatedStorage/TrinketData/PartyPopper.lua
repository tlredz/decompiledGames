local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
game:GetService("TweenService")
game:GetService("Debris")
local partyPopperEffects = ReplicatedStorage.Modules.Zones.PartyPopperEffects
local PartyPopper = {}
PartyPopper.Name = "Party Popper"
PartyPopper.Icon = "rbxassetid://78956490828021"
PartyPopper.Rarity = "Uncommon"
PartyPopper.Description = "When starting to work on a machine, Twisteds in the initial nearby radius are highlighted for 5 seconds."
PartyPopper.TrinketType = "Passive"
PartyPopper.MonsterTrinket = true
PartyPopper.Cost = 1500
PartyPopper.Requirement1 = { "None", 0 }

function PartyPopper.ApplyTrinket(instance, _)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	instance:WaitForChild("Stats"):WaitForChild("InElevator")
	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(playerFromCharacter, partyPopperEffects, instance)
end

PartyPopper.MachineBuffEvent = true

function PartyPopper.TriggerMachineBuffEvent(character)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return
	end

	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(
		playerFromCharacter,
		partyPopperEffects,
		character,
		"MachineBuff"
	)
end

function PartyPopper.RemoveTrinket(instance)
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

return PartyPopper