local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local PlayerProfile = require(ReplicatedStorage.CAM.Global.PlayerProfile)
local v

if isServer then
	local Boss = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.Requirements.Boss)
	v = Boss or nil
else
	v = nil
end

local v2

if isServer then
	local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
	v2 = SignalEvent or nil
else
	v2 = nil
end

local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)

local function bossGated()
	local result = {}
	local v3 = {}
	local categories = {}

	for k, v4 in PlayerProfile.skill_info do
		if not (typeof(v4) == "table" and v4.Boss ~= nil) then
			continue
		end

		result[k] = v4
		local category = v4.Category or k

		if v3[category] then
			continue
		end

		v3[category] = true
		table.insert(categories, category)
	end

	table.sort(categories)
	return result, categories
end

local function categorySuggestions()
	local _, v3 = bossGated()
	return v3, true
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "String",
			Name = "Category",
			Required = false,
			Suggester = categorySuggestions,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()
				local _, v3 = bossGated()

				for _, v4 in v3, true, nil do
					if v4:lower() == lower then
						return v4
					end
				end

				return value
			end
		}
	},
	Server = function(_, items, value)
		local v3, v4 = bossGated()
		local v5 = nil

		if typeof(value) == "string" and value ~= "" then
			for _, v7 in v4 do
				if v7:lower() ~= value:lower() then
					continue
				end

				v5 = v7
				break
			end
		end

		for _, item in items do
			local v6 = {}

			for k, v7 in v3 do
				local category = v7.Category or k

				if (v5 == nil or category == v5) and v.Grant(item, k) then
					table.insert(v6, k)
				end
			end

			if not (#v6 > 0) then
				continue
			end

			table.sort(v6)
			local soroundColor = gameSettings.RichTextPopularConfigs.SoroundColor
			v2.ToClient(item, "Notify", {
				Text = `\\[['{table.concat(v6, ", ")}']<{soroundColor}>] obtained, open your Skill Tree!`,
				Type = "Success",
				Duration = 10
			})
		end
	end
}