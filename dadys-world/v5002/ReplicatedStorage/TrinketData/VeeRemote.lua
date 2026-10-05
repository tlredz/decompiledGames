local VeeRemote = {
	Name = "Vee's Remote",
	Icon = "rbxassetid://17653810346",
	Rarity = "Common",
	Description = "Instantly completes the first Machine you extract from on any Floor, but only if the number of Machines completed is below 50%. Limit of 1 activation per Floor.",
	TrinketType = "Toggle",
	MonsterTrinket = true,
	Cost = 350
}
VeeRemote.Requirement1 = { "Coin", VeeRemote.Cost }
VeeRemote.MachineEvent = true

function VeeRemote.TriggerMachineEvent(instance, p, p2)
	if workspace.Info.GeneratorsCompleted.Value / workspace.Info.RequiredGenerators.Value < 0.5 then
		local active = instance:WaitForChild("Active")

		if active.Value == true then
			active.Value = false
			p.Stats.CurrentAmount.Value += 999
			p.PlayerCompletion[p2.Value.Name].Value += 999
		end
	end
end

function VeeRemote.ApplyTrinket(_, instance)
	local active = instance:WaitForChild("Active")
	workspace.Info.Floor.Changed:Connect(function()
		if active and active.Parent ~= nil then
			active.Value = true
		end
	end)
	workspace.Info.GeneratorsCompleted.Changed:Connect(function()
		if workspace.Info.GeneratorsCompleted.Value / workspace.Info.RequiredGenerators.Value >= 0.5 and active and active.Parent ~= nil then
			active.Value = false
		end
	end)
end

function VeeRemote.RemoveTrinket(instance)
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

return VeeRemote