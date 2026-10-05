local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	valuename = "ToggleListener",
	new = function(character, p: string, p2)
		if character == nil or p == nil then
			return
		end

		if character.Parent == game.Players then
			character = character.Character
		end

		local v = p2 == nil and {} or p2

		if character == nil then
			return
		end

		if v.amount == nil then
			v.amount = 1
		end

		local getvaluesfolder = Utility.getvaluesfolder(character)
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "SkillToggle"
		stringValue.Value = p
		local intValue = Instance.new("IntValue")
		intValue.Name = "Type"
		intValue.Value = v.toggleType or Menum.toggleSkillType.none
		intValue.Parent = stringValue
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Started"
		numberValue.Parent = stringValue
		numberValue.Value = workspace:GetServerTimeNow()
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Name = "Duration"
		numberValue2.Parent = stringValue
		numberValue2.Value = v.duration or 0
		local intValue2 = Instance.new("IntValue")
		intValue2.Name = "Mode"
		intValue2.Value = v.mode or Menum.toggleSkillMode.all
		intValue2.Parent = stringValue
		local intValue3 = Instance.new("IntValue")
		intValue3.Name = "Remaining"
		intValue3.Value = v.amount
		intValue3.Parent = stringValue
		stringValue:SetAttribute("_Started", workspace:GetServerTimeNow())
		stringValue:SetAttribute("_Duration", v.duration or 0)

		if v.text ~= nil then
			stringValue:SetAttribute("HubText", v.text)
		end

		stringValue.Parent = getvaluesfolder

		if v.duration then
			DebrisModule:AddItem(stringValue, v.duration)
		end

		return stringValue
	end
}