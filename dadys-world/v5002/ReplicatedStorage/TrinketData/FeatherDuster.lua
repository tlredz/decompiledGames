local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local FeatherDuster = {
	Name = "Feather Duster",
	Icon = "rbxassetid://18162115328",
	Rarity = "Common",
	Description = "Restores 20 Stamina when picking up an item. (Does not include Capsules and Tapes)",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
FeatherDuster.Requirement1 = { "Coin", FeatherDuster.Cost }

function FeatherDuster.ApplyTrinket(instance, _)
	local inventory = instance:WaitForChild("Inventory")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local stamina = stats:WaitForChild("Stamina")
	local currentStamina = stats:WaitForChild("CurrentStamina")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Sprinting")
	local slot1 = inventory:WaitForChild("Slot1")
	local slot2 = inventory:WaitForChild("Slot2")
	local slot3 = inventory:WaitForChild("Slot3")
	local slot4 = inventory:FindFirstChild("Slot4")

	local function restoreStaminaFor(p)
		if p.Value == "None" then
			return
		end

		local value = currentStamina.Value

		if value < stamina.Value then
			currentStamina.Value = math.min(value + 20, stamina.Value)
		end

		local v = currentStamina.Value - value

		if v > 0 then
			ActionEvent:Record(instance, "TriggerTrinket", "FeatherDuster", v)
		end
	end

	slot1.Changed:Connect(function()
		if slot1.Value == "None" then
			return
		end

		local value = currentStamina.Value

		if value < stamina.Value then
			currentStamina.Value = math.min(value + 20, stamina.Value)
		end

		local v = currentStamina.Value - value

		if v > 0 then
			ActionEvent:Record(instance, "TriggerTrinket", "FeatherDuster", v)
		end
	end)
	slot2.Changed:Connect(function()
		if slot2.Value == "None" then
			return
		end

		local value = currentStamina.Value

		if value < stamina.Value then
			currentStamina.Value = math.min(value + 20, stamina.Value)
		end

		local v = currentStamina.Value - value

		if v > 0 then
			ActionEvent:Record(instance, "TriggerTrinket", "FeatherDuster", v)
		end
	end)
	slot3.Changed:Connect(function()
		if slot3.Value == "None" then
			return
		end

		local value = currentStamina.Value

		if value < stamina.Value then
			currentStamina.Value = math.min(value + 20, stamina.Value)
		end

		local v = currentStamina.Value - value

		if v > 0 then
			ActionEvent:Record(instance, "TriggerTrinket", "FeatherDuster", v)
		end
	end)

	if slot4 then
		slot4.Changed:Connect(function()
			if slot4.Value == "None" then
				return
			end

			local value = currentStamina.Value

			if value < stamina.Value then
				currentStamina.Value = math.min(value + 20, stamina.Value)
			end

			local v = currentStamina.Value - value

			if v > 0 then
				ActionEvent:Record(instance, "TriggerTrinket", "FeatherDuster", v)
			end
		end)
	end
end

function FeatherDuster.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats")
	instance:WaitForChild("WalkSpeed")
	instance:WaitForChild("RunSpeed")
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

return FeatherDuster