local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local ShieldSourceIcon = {
	ENABLED = false,
	SOURCE_ATTRIBUTES = { "GuardedBy" }
}
local v = { "InGamePlayers", "Players" }
local v2 = {}

local function findCharacter(sourceName)
	local player = Players:FindFirstChild(sourceName)

	if player and player:IsA("Player") and player.Character then
		return player.Character
	end

	for _, childName in ipairs(v) do
		local child = workspace:FindFirstChild(childName)
		local child2 = child and child:FindFirstChild(sourceName)

		if child2 then
			return child2
		end
	end

	return nil
end

local function towerNameOf(instance)
	local moduleName = instance:FindFirstChild("ModuleName", true) or instance:FindFirstChild("CharacterName", true)

	if moduleName and moduleName:IsA("StringValue") and moduleName.Value ~= "" then
		return moduleName.Value
	end

	return nil
end

local function voteIconOf(value)
	local v3 = v2[value]

	if v3 ~= nil then
		return v3 or nil
	end

	local success, result = pcall(function()
		local tower = TowerLUT:GetTower(value)
		local module = tower and require(tower)
		return type(module) == "table" and module.VoteIcon or nil
	end)

	if not success or type(result) ~= "string" or result == "" or not result then
		result = nil
	end

	v2[value] = result or false
	return result
end

function ShieldSourceIcon.GetSourceName(instance)
	for _, attributeName in ipairs(ShieldSourceIcon.SOURCE_ATTRIBUTES) do
		local attribute = instance:GetAttribute(attributeName)

		if type(attribute) == "string" and attribute ~= "" then
			return attribute
		end
	end

	return nil
end

function ShieldSourceIcon.Get(p)
	if not (ShieldSourceIcon.ENABLED and p) then
		return nil
	end

	local sourceName = ShieldSourceIcon.GetSourceName(p)
	local value = sourceName and findCharacter(sourceName)

	if not value then
		return value and voteIconOf(value) or nil
	end

	local moduleName = value:FindFirstChild("ModuleName", true) or value:FindFirstChild("CharacterName", true)

	if moduleName and moduleName:IsA("StringValue") and moduleName.Value ~= "" then
		value = moduleName.Value
	else
		value = nil
	end

	return value and voteIconOf(value) or nil
end

return ShieldSourceIcon