local MenuConfig = {}
local localPlayer = game.Players.LocalPlayer

function MenuConfig.InitiateDestination()
	local menuDestination = localPlayer:FindFirstChild("MenuDestination")

	if menuDestination ~= nil then
		return menuDestination
	end

	local stringValue = Instance.new("StringValue")
	stringValue.Name = "MenuDestination"
	stringValue.Value = ""
	local stringValue2 = Instance.new("StringValue")
	stringValue2.Name = "Last"
	stringValue2.Parent = stringValue
	local stringValue3 = Instance.new("StringValue")
	stringValue3.Name = "InventoryOption"
	stringValue3.Value = "Characters"
	stringValue3.Parent = stringValue
	local stringValue4 = Instance.new("StringValue")
	stringValue4.Name = "ItemSearchbar"
	stringValue4.Parent = stringValue3
	local stringValue5 = Instance.new("StringValue")
	stringValue5.Name = "SkillTreeOption"
	stringValue5.Parent = stringValue
	local stringValue6 = Instance.new("StringValue")
	stringValue6.Name = "RootSearchbar"
	stringValue6.Parent = stringValue5
	local stringValue7 = Instance.new("StringValue")
	stringValue7.Name = "ItemSelected"
	stringValue7.Parent = stringValue3
	local intValue = Instance.new("IntValue")
	intValue.Name = "IdSelected"
	intValue.Parent = stringValue7
	local stringValue8 = Instance.new("StringValue")
	stringValue8.Name = "ItemName"
	stringValue8.Parent = intValue
	local intValue2 = Instance.new("IntValue")
	intValue2.Name = "ItemId"
	intValue2.Parent = stringValue7
	stringValue.Parent = localPlayer
	return stringValue
end

function MenuConfig.inventoryRepsExceeds(instance, p: string)
	local children = instance:GetChildren()
	local v = 0

	for i = 1, #children do
		local v2 = children[i]

		if not (v2 ~= nil and v2.Name == p) then
			continue
		end

		if v == 1 then
			return true
		else
			v = 1
		end
	end

	table.clear(children)
	return false
end

function MenuConfig.Toggle()
	local initiateDestination = MenuConfig.InitiateDestination()

	if initiateDestination.Value == "" then
		initiateDestination.Value = initiateDestination.Last.Value == "" and "Inventory" or initiateDestination.Last.Value or "Inventory"
		return
	end

	initiateDestination.Last.Value = initiateDestination.Value
	initiateDestination.Value = ""
end

return MenuConfig