local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local names = {}
local FightingStyles2 = {
	TOOL_NAME = "Fighting Style"
}

for k in FightingStyles do
	table.insert(names, k)
end

table.sort(names)
FightingStyles2.Names = names

function FightingStyles2.For(p)
	local data = Utility.GetData(p)

	if data == nil then
		return nil
	end

	local powers = data:FindFirstChild("Powers")
	local fightingStyle

	if powers ~= nil then
		fightingStyle = powers:FindFirstChild("FightingStyle") or nil
	end

	local value

	if fightingStyle ~= nil then
		value = fightingStyle.Value or nil
	end

	local v2

	if value ~= nil then
		v2 = FightingStyles[value] or nil
	end

	if v2 == nil or not ItemRequirements.Passes(data, v2.Requirements) then
		return nil
	end

	return value, v2
end

return FightingStyles2