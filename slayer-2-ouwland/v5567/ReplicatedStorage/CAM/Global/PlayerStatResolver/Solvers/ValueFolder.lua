local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)

local function conditionalAmount(p, attribute: string)
	local v, v2 = string.match(attribute, "^%s*([^,]-)%s*,%s*([%-%+%.%d]+)%s*$")
	local v3 = tonumber(v2)

	if v == nil or v == "" or v3 == nil then
		return nil
	end

	if table.find(Character_info_provider.GetEquippedPowers(p), v) ~= nil then
		return v3
	end

	local get_equipped_tool = Character_info_provider.Get_equipped_tool(p)
	local v4

	if get_equipped_tool ~= nil then
		v4 = Items[get_equipped_tool.Name] or nil
	end

	if v4 == nil or v4.Mastery ~= v then
		return nil
	end

	return v3
end

return function(p, p2: string)
	local getvaluesfolder = Utility.getvaluesfolder(p)

	if getvaluesfolder == nil then
		return 0
	end

	local v = StatTypes.HighestOnlyStats[p2] == true
	local v2 = 0

	for _, child in ipairs(getvaluesfolder:GetChildren()) do
		if CollectionService:HasTag(child, StatTypes.ValueStatTag) then
			local attribute = child:GetAttribute(StatTypes.StatToAttribute(p2))

			if typeof(attribute) == "string" then
				attribute = conditionalAmount(p, attribute)
			end

			if typeof(attribute) == "number" then
				if v then
					v2 = math.max(v2, attribute)
				else
					v2 += attribute
				end
			elseif attribute == true then
				return true
			end
		elseif child.Name == p2 then
			if typeof(child.Value) == "number" then
				if v then
					v2 = math.max(v2, child.Value)
				else
					v2 += child.Value
				end
			elseif child.Value == true then
				return true
			end
		end
	end

	return v2
end