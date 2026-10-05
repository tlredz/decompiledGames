local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local names = {}
local names2 = {}
local modulesByName = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	table.insert(names, moduleScript.Name)
	table.insert(names2, moduleScript.Name:lower())

	if not isServer then
		continue
	end

	local name = moduleScript.Name:lower()
	local module = require(moduleScript)
	modulesByName[name] = module
end

local masteries = {}
local v = {}

if not isServer then
	local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
	local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
	local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
	local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)

	for _, v2 in {
		Items,
		Breathings,
		DemonArts,
		FightingStyles
	} do
		for mastery, v3 in v2 do
			if not (v2 ~= Items or v3.HasCombat or v3.Mastery ~= nil) then
				continue
			end

			if type(v3.Mastery) == "string" then
				mastery = v3.Mastery
			elseif type(v3.Mastery) == "table" then
				mastery = v3.Mastery.Value or mastery
			end

			table.insert(masteries, mastery)
			table.insert(v, mastery:lower())
		end
	end
end

local v2 = {
	mastery = true,
	["skill tree"] = true
}
local names3 = {}
local v3 = {}

if not isServer then
	local FightingStyles = require(ReplicatedStorage.CAM.Global.Collectibles.FightingStyles)

	for _, name in FightingStyles.Names do
		table.insert(names3, name)
		table.insert(v3, name:lower())
	end
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Reset Category",
			Required = true,
			Suggester = names,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local index = table.find(names2, value:lower())

				if index == nil then
					return nil
				end

				return names[index]
			end
		},
		{
			Type = "Name",
			Name = "Name",
			Required = false,
			Suggester = function(list)
				local lower = (list[2] or ""):lower()

				if lower == "fighting style" then
					return names3, true
				end

				if v2[lower] then
					return masteries, true
				end
			end,
			Completer = function(value: string, list)
				if value == nil or value == "" then
					return nil
				end

				local lower = (list[2] or ""):lower()

				if lower == "fighting style" then
					local index = table.find(v3, value:lower())

					if index == nil then
						return value
					end

					return names3[index]
				else
					if not v2[lower] then
						return nil
					end

					local index = table.find(v, value:lower())

					if index == nil then
						return value
					end

					return masteries[index]
				end
			end
		}
	},
	Server = function(_, p, value: string, p2: string?)
		local v4

		if value ~= nil then
			v4 = modulesByName[value:lower()] or nil
		end

		if v4 == nil then
			error((`Invalid reset category: {tostring(value)}`))
		end

		return v4(p, p2)
	end
}