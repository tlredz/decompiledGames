local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Skill_Info = require(ReplicatedStorage.CAM.Global.PlayerProfile.Skill_Info)
return function(p, list)
	if typeof(p) ~= "table" then
		return
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return
	end

	local _, v = Character_info_provider.HasUnlockedSkills(localPlayer, p)

	for _, v2 in v do
		local v3 = Skill_Info[v2]
		table.insert(list, {
			Text = `Requires {v2}`,
			Image = v3 and v3.Icon or nil
		})
	end
end