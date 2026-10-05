local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local PullToy = {
	Name = "Pull Toy",
	Icon = "rbxassetid://18252832073",
	Rarity = "Common",
	Description = "Increases both Walk and Run Speed by 25% when a new Floor arrives for 10 seconds.",
	TrinketType = "Toggle",
	MonsterTrinket = true,
	Cost = 350
}
PullToy.Requirement1 = { "Coin", PullToy.Cost }

function PullToy.ApplyTrinket(p, instance)
	local active = instance:WaitForChild("Active")
	active.Value = false
	workspace.Info.FloorActive.Changed:Connect(function()
		if active and active.Parent ~= nil and workspace.Info.FloorActive.Value == true then
			active.Value = true
			local v2 = StatModifierManager.ApplySpeedModifiers(p, 1.25, "PullToy", {
				category = "trinket",
				unique = true
			})
			v[p] = v2
			task.wait(10)

			if active and active.Parent ~= nil then
				active.Value = false

				if v[p] == v2 then
					StatModifierManager.RemoveSpeedModifiers(p, v2)
					v[p] = nil
				end
			end
		end
	end)
end

function PullToy.RemoveTrinket(instance)
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

return PullToy