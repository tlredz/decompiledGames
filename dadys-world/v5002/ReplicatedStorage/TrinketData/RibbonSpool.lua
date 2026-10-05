local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local RibbonSpool = {
	Name = "Ribbon Spool",
	Icon = "rbxassetid://17653810096",
	Rarity = "Common",
	Description = "Gain 10% more Walk and Run Speed on even numbered floors.",
	TrinketType = "Toggle",
	MonsterTrinket = true,
	Cost = 350
}
RibbonSpool.Requirement1 = { "Coin", RibbonSpool.Cost }

function RibbonSpool.ApplyTrinket(p, instance)
	local active = instance:WaitForChild("Active")
	active.Value = false

	local function togglestats()
		if workspace.Info.Floor.Value ~= 0 and workspace.Info.Floor.Value ~= 1 then
			if workspace.Info.Floor.Value % 2 == 0 then
				if not v[p] then
					v[p] = StatModifierManager.ApplySpeedModifiers(p, 1.1, "RibbonSpool", {
						category = "trinket"
					})
				end

				active.Value = true
			else
				if v[p] then
					StatModifierManager.RemoveSpeedModifiers(p, v[p])
					v[p] = nil
				end

				active.Value = false
			end
		end
	end

	togglestats()
	workspace.Info.Floor.Changed:Connect(togglestats)
end

function RibbonSpool.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		local active = trinket1:FindFirstChild("Active")
		trinket1.Value = "None"

		if active and active.Value == true and v[instance] then
			StatModifierManager.RemoveSpeedModifiers(instance, v[instance])
			v[instance] = nil
		end

		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		local active = trinket2:FindFirstChild("Active")
		trinket2.Value = "None"

		if active and active.Value == true and v[instance] then
			StatModifierManager.RemoveSpeedModifiers(instance, v[instance])
			v[instance] = nil
		end

		return "Slot2"
	end
end

return RibbonSpool