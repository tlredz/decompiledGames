local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local PlayerProfile = require(ReplicatedStorage.CAM.Global.PlayerProfile)
return function(player, p: string)
	local character = player.Character

	if character == nil then
		return 0
	end

	local SHCS = character:FindFirstChild("SHCS") or character:FindFirstChild("SHC")

	if SHCS == nil or SHCS.Value == "" then
		return 0
	end

	local value = SHCS.Value
	local v = PlayerProfile.skill_info[value]

	if v == nil then
		return 0
	end

	local item = Items[v.Category]

	if item == nil or item.Skills == nil then
		return 0
	end

	for _, skill in ipairs(item.Skills) do
		if skill.Name == value and skill.PerformanceStats then
			return skill.PerformanceStats[p] or 0
		end
	end

	return 0
end