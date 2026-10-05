local ReplicatedStorage = game:GetService("ReplicatedStorage")
local memoryLocketEffects = ReplicatedStorage.Modules.Zones.MemoryLocketEffects
local MemoryLocket = {}
MemoryLocket.Name = "Memory Locket"
MemoryLocket.Icon = "rbxassetid://90587191377154"
MemoryLocket.Rarity = "Common"
MemoryLocket.Description = "If user is not at full health, highlights all healing items currently on the Floor to the user until the user is healed."
MemoryLocket.TrinketType = "Toggle"
MemoryLocket.MonsterTrinket = true
MemoryLocket.Cost = 0
MemoryLocket.Requirement1 = { "None", 0 }

function MemoryLocket.ApplyTrinket(character, p)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return
	end

	ReplicatedStorage.Events.ClientAbilityEvent:FireClient(playerFromCharacter, memoryLocketEffects, character, p)
end

function MemoryLocket.RemoveTrinket(instance)
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

return MemoryLocket