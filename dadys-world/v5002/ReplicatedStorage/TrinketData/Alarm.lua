local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local Alarm = {}
Alarm.Name = "Alarm"
Alarm.Icon = "rbxassetid://17660029949"
Alarm.Rarity = "Common"
Alarm.Description = "Increases both Walk and Run Speed by 25% when Panic Mode activates for 10 seconds."
Alarm.TrinketType = "Toggle"
Alarm.Cost = 250
Alarm.Requirement1 = { "Coin", 250 }

function Alarm.ApplyTrinket(p, instance)
	local active = instance:WaitForChild("Active")
	active.Value = false
	workspace.Info.Panic.Changed:Connect(function()
		if active and active.Parent ~= nil and workspace.Info.Panic.Value == true then
			active.Value = true
			local v2 = StatModifierManager.ApplySpeedModifiers(p, 1.25, "Alarm", {
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

function Alarm.RemoveTrinket(instance)
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

return Alarm