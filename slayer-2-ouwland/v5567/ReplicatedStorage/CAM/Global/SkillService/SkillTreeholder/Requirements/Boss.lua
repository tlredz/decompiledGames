local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local LiveConfig = require(ReplicatedStorage.CAM.Global.LiveConfig)
local Boss = {}
Boss.Persistent = true
Boss.HideValue = true
Boss.IconColor = Color3.new(1, 1, 1)
Boss.IconCornerRadius = UDim.new(1, 0)
Boss.BackgroundImage = "rbxassetid://92426175647542"

function Boss.DisplayName(p: string)
	local skillInfo = Stats.GetSkillInfo(p)
	return "Defeat " .. (skillInfo and skillInfo.Boss or "Boss")
end

function Boss.Icon(p: string)
	local skillInfo = Stats.GetSkillInfo(p)

	if skillInfo == nil or skillInfo.Boss == nil then
		return ""
	end

	local npcDataTable = LiveConfig.get("NpcDataTable")
	local v = npcDataTable and npcDataTable[skillInfo.Boss]

	if v then
		return v.Icon
	end

	return ""
end

function Boss.CanBuy(p, childName: string, _: string?)
	local data = Utility.GetData(p)
	return data ~= nil and data.MetRequirements.Boss:FindFirstChild(childName) ~= nil
end

function Boss.Buy(_, _: string, _: string?) end

function Boss.Grant(p, name: string)
	local data = Utility.GetData(p)

	if data == nil or data.MetRequirements.Boss:FindFirstChild(name) ~= nil then
		return false
	end

	local boolValue = Instance.new("BoolValue")
	boolValue.Name = name
	boolValue.Parent = data.MetRequirements.Boss
	return true
end

return Boss