local PopPack = {}
PopPack.Name = "Pop Pack"
PopPack.Icon = "rbxassetid://18250269936"
PopPack.Rarity = "Common"
PopPack.Description = "Grants the 'Pop' Item every new Floor (If user's Inventory has a slot open)."
PopPack.TrinketType = "Passive"
PopPack.Cost = 250
PopPack.Requirement1 = { "Coin", 250 }

function PopPack.ApplyTrinket(instance, p)
	instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats"):WaitForChild("StaminaRegenModifier")
	workspace.Info.Floor.Changed:Connect(function()
		local inventory = instance:WaitForChild("Inventory")
		local slot1 = inventory:WaitForChild("Slot1")
		local slot2 = inventory:WaitForChild("Slot2")
		local slot3 = inventory:WaitForChild("Slot3")
		local slot4 = inventory:FindFirstChild("Slot4")
		local v = false

		if p.Name == "Trinket2" then
			task.wait()
		end

		if slot1.Value == "None" then
			slot1.Value = "Pop"
			v = true
		end

		if slot2.Value == "None" and not v then
			slot2.Value = "Pop"
			v = true
		end

		if slot3.Value == "None" and not v then
			slot3.Value = "Pop"
			v = true
		end

		if slot4 and slot4.Value == "None" and not v then
			slot4.Value = "Pop"
		end
	end)
end

function PopPack.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats"):WaitForChild("DecodeSpeed")
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

return PopPack