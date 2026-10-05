local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local SkillSwitchAdder = {
	Lever_Icon = "http://www.roblox.com/asset/?id=15035746640",
	Lever_Color = Color3.fromRGB(255, 255, 255),
	Switch_Color = Color3.fromRGB(238, 0, 0),
	extension = "Skill_Switch"
}

function SkillSwitchAdder.Add(parent, p: string, p2: number?, value: string?)
	if parent == nil or p == nil or parent:FindFirstChild(p .. SkillSwitchAdder.extension) ~= nil then
		return
	end

	local stringValue = Instance.new("StringValue")
	stringValue.Name = p .. SkillSwitchAdder.extension
	stringValue.Value = value or "Default"

	if p2 then
		DebrisModule:AddItem(stringValue, p2)
	end

	stringValue.Parent = parent
	return stringValue
end

return SkillSwitchAdder