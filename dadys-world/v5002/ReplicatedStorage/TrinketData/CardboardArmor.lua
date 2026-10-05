local CardboardArmor = {
	Name = "Cardboard 'Armor'",
	Icon = "rbxassetid://82393673921418",
	Rarity = "Common",
	Description = "Protects the user from long-ranged Twisted attacks. Limit of 1 activation per Floor.",
	TrinketType = "Toggle",
	Cost = 350
}
CardboardArmor.Requirement1 = { "Coin", CardboardArmor.Cost }
CardboardArmor.AbilityDuration = 10
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function CardboardArmor.ApplyTrinket(instance, instance2)
	instance2:WaitForChild("Active")
	instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	stats:WaitForChild("StaminaModifier")
	instance:WaitForChild("Decoding")
	stats:WaitForChild("StaminaRegenModifier")
	local active = instance2:WaitForChild("Active")
	workspace.Info.Floor.Changed:Connect(function()
		if active and active.Parent ~= nil then
			active.Value = true
		end
	end)
end

function CardboardArmor.SpecialEvent(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	task.spawn(function()
		if instance and instance.Parent ~= nil then
			Audio:Play("Sounds.Trinkets.CardboardArmor.AbilitySound", {
				Parent = humanoidRootPart
			})
		end
	end)
end

function CardboardArmor.RemoveTrinket(instance)
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

return CardboardArmor