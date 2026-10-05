local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local NightCap = {}
NightCap.Name = "Star Pillow"
NightCap.Icon = "rbxassetid://125054307527424"
NightCap.Rarity = "Common"
NightCap.Description = "Increases Stamina regeneration by 100% when extracting from a Machine."
NightCap.TrinketType = "Toggle"
NightCap.MonsterTrinket = true
NightCap.Cost = 250
NightCap.Requirement1 = { "Coin", 250 }

function NightCap.ApplyTrinket(instance, instance2)
	local active = instance2:WaitForChild("Active")
	local decoding = instance:WaitForChild("Decoding")
	local v2 = false
	active.Value = false

	if not v[instance] then
		v[instance] = nil
	end

	decoding.Changed:Connect(function()
		if decoding.Value == nil then
			if v2 == true then
				v2 = false

				if v[instance] then
					StatModifierManager.RemoveStaminaRegenModifier(instance, v[instance])
					v[instance] = nil
				end

				active.Value = false
			end
		elseif v2 == false then
			v2 = true
			v[instance] = StatModifierManager.ApplyStaminaRegenModifier(instance, 2, "NightCap", {
				category = "trinket"
			})
			active.Value = true
		end
	end)
end

function NightCap.RemoveTrinket(instance)
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
			StatModifierManager.RemoveStaminaRegenModifier(instance, v[instance])
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
			StatModifierManager.RemoveStaminaRegenModifier(instance, v[instance])
			v[instance] = nil
		end

		return "Slot2"
	end
end

return NightCap