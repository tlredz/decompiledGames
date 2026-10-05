local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local v2 = {}

local function countItems(instance)
	local inventory = instance:FindFirstChild("Inventory")

	if not inventory then
		return 0
	end

	local count = 0

	for _, stringValue in ipairs(inventory:GetChildren()) do
		if stringValue:IsA("StringValue") and stringValue.Value ~= "None" then
			count += 1
		end
	end

	return count
end

local function updateModifier(instance)
	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "StaminaRegenModifier", v[instance])
		v[instance] = nil
	end

	local v3 = countItems(instance)

	if v3 > 0 then
		local v4 = 1 + 0.15 * v3
		v[instance] = StatModifierManager.ApplyModifier(instance, "StaminaRegenModifier", v4, "WhisperingFlower", {
			category = "trinket"
		})
	end
end

local WhisperingFlower = {}
WhisperingFlower.Name = "Whispering Flower"
WhisperingFlower.Icon = "rbxassetid://86691466437231"
WhisperingFlower.Rarity = "Common"
WhisperingFlower.Description = "Increases Stamina regeneration by 15% for every item in your inventory."
WhisperingFlower.TrinketType = "Passive"
WhisperingFlower.TrinketState = "Stamina"
WhisperingFlower.Cost = 250
WhisperingFlower.Requirement1 = { "Coin", 250 }

function WhisperingFlower.ApplyTrinket(instance)
	if v2[instance] then
		for _, connection in ipairs(v2[instance]) do
			connection:Disconnect()
		end
	end

	v2[instance] = {}
	local inventory = instance:FindFirstChild("Inventory")

	if not inventory then
		return
	end

	for _, stringValue in ipairs(inventory:GetChildren()) do
		if not stringValue:IsA("StringValue") then
			continue
		end

		local changedConnection = stringValue.Changed:Connect(function()
			updateModifier(instance)
		end)
		table.insert(v2[instance], changedConnection)
	end

	local childAddedConnection = inventory.ChildAdded:Connect(function(stringValue)
		if stringValue:IsA("StringValue") then
			local changedConnection = stringValue.Changed:Connect(function()
				updateModifier(instance)
			end)
			table.insert(v2[instance], changedConnection)
			updateModifier(instance)
		end
	end)
	table.insert(v2[instance], childAddedConnection)
	updateModifier(instance)
end

function WhisperingFlower.RemoveTrinket(instance)
	if v[instance] then
		StatModifierManager.RemoveModifier(instance, "StaminaRegenModifier", v[instance])
		v[instance] = nil
	end

	if v2[instance] then
		for _, connection in ipairs(v2[instance]) do
			connection:Disconnect()
		end

		v2[instance] = nil
	end

	local trinkets = instance:FindFirstChild("Trinkets")

	if not trinkets then
		return "CantRemove"
	end

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

return WhisperingFlower