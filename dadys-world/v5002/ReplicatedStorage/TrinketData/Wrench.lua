local Wrench = {}
Wrench.Name = "Wrench"
Wrench.Icon = "rbxassetid://17660170044"
Wrench.Rarity = "Common"
Wrench.Description = "Instantly adds a large amount of completion to the first Machine you extract from on any Floor. Limit of 1 activation per Floor."
Wrench.TrinketType = "Toggle"
Wrench.Cost = 250
Wrench.Requirement1 = { "Coin", 250 }
Wrench.MachineEvent = true

function Wrench.TriggerMachineEvent(instance, p, p2)
	local active = instance:WaitForChild("Active")

	if active.Value == true then
		active.Value = false
		p.Stats.CurrentAmount.Value += 15
		p.PlayerCompletion[p2.Value.Name].Value += 15
	end
end

function Wrench.ApplyTrinket(_, instance)
	local active = instance:WaitForChild("Active")
	workspace.Info.Floor.Changed:Connect(function()
		if active and active.Parent ~= nil then
			active.Value = true
		end
	end)
end

function Wrench.RemoveTrinket(instance)
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

return Wrench