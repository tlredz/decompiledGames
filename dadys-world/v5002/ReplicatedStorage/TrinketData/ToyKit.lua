local ToyKit = {}
ToyKit.Name = "Toy Kit"
ToyKit.Icon = "rbxassetid://101431482488954"
ToyKit.Rarity = "Common"
ToyKit.Description = "If your Toon has a ring-based aura ability, increases radius by 25%."
ToyKit.TrinketType = "Passive"
ToyKit.MonsterTrinket = true
ToyKit.Cost = 0
ToyKit.Requirement1 = { "None", 0 }

function ToyKit.ApplyTrinket(instance)
	if not instance:GetAttribute("RingAbility") then
		return
	end

	instance:SetAttribute("AuraRadiusBoost", 1.25)
end

function ToyKit.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		instance:SetAttribute("AuraRadiusBoost", nil)
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		instance:SetAttribute("AuraRadiusBoost", nil)
		return "Slot2"
	end
end

return ToyKit