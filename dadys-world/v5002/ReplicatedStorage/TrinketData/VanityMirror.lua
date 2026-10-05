local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local VanityMirror = {
	Name = "Vanity Mirror",
	Icon = "rbxassetid://18805945248",
	Rarity = "Common",
	Description = "Increases Run Speed by 30% during Panic Mode.",
	TrinketType = "Toggle",
	MonsterTrinket = true,
	Cost = 350
}
VanityMirror.Requirement1 = { "Coin", VanityMirror.Cost }
VanityMirror.AbilityDuration = 3

function VanityMirror.ApplyTrinket(p, instance)
	local active = instance:WaitForChild("Active")
	active.Value = false
	local flag = false
	workspace.Info.Panic.Changed:Connect(function()
		if active and active.Parent ~= nil then
			if workspace.Info.Panic.Value == true then
				if not flag then
					active.Value = true
					flag = true
					v[p] = StatModifierManager.ApplyModifier(p, "RunSpeedModifier", 1.3, "VanityMirror", {
						category = "trinket"
					})
				end
			elseif flag then
				flag = false

				if active and active.Parent ~= nil then
					active.Value = false

					if v[p] then
						StatModifierManager.RemoveModifier(p, "RunSpeedModifier", v[p])
						v[p] = nil
					end
				end
			end
		end
	end)
end

function VanityMirror.RemoveTrinket(instance)
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
			StatModifierManager.RemoveModifier(instance, "RunSpeedModifier", v[instance])
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
			StatModifierManager.RemoveModifier(instance, "RunSpeedModifier", v[instance])
			v[instance] = nil
		end

		return "Slot2"
	end
end

return VanityMirror