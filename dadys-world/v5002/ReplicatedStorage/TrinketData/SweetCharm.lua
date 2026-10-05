local SweetCharm = {}
SweetCharm.Name = "Sweet Charm"
SweetCharm.Icon = "rbxassetid://18688030404"
SweetCharm.Rarity = "Common"
SweetCharm.Description = "Decreases Active Ability Cooldown by 8%. Has no effect on Toons without an Active Ability."
SweetCharm.TrinketType = "Passive"
SweetCharm.MonsterTrinket = true
SweetCharm.Cost = 325
SweetCharm.Requirement1 = { "Coin", 325 }

function SweetCharm.ApplyTrinket(instance)
	instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats")
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):FindFirstChild("Ability1")

	if ability1 and not instance:GetAttribute("HasToggleAbility") then
		local cooldown = ability1:WaitForChild("Cooldown")
		ability1:WaitForChild("CurrentCooldown")
		cooldown.Value = math.floor(cooldown.Value * 0.92)

		if cooldown.Value <= 5 then
			cooldown.Value = 5
		end
	end
end

function SweetCharm.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	local abilities = instance:FindFirstChild("Abilities")
	local ability1 = abilities and abilities:FindFirstChild("Ability1")

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		local cooldown = ability1 and ability1:FindFirstChild("Cooldown")

		if cooldown then
			cooldown.Value = math.ceil(cooldown.Value / 0.92)
		end

		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		local cooldown = ability1 and ability1:FindFirstChild("Cooldown")

		if cooldown then
			cooldown.Value = math.ceil(cooldown.Value / 0.92)
		end

		return "Slot2"
	end
end

return SweetCharm