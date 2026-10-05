local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local names = {}
local modulesByName = {}

for _, moduleScript in ipairs(script:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	table.insert(names, moduleScript.Name)

	if not isServer then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local v = {}
local v2 = {}
local insert = table.insert
local find = table.find

if not isServer then
	local powers = {
		Breathing = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
	}
	local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
	powers["Evil Art"] = DemonArts
	local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
	powers["Fighting Style"] = FightingStyles
	powers.Item = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
	powers.Progress = {
		Slayer = true,
		Demon = true
	}

	for k, v4 in pairs(powers) do
		local lower = k:lower()
		v[k] = {}
		v2[lower] = {
			Upper = k
		}

		for k2, _ in v4 do
			insert(v[k], k2)
			insert(v2[lower], k2:lower())
		end
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
			Type = "Type",
			Required = true,
			Suggester = names,
			Completer = function(value)
				for _, v3 in ipairs(names) do
					if v3:lower() == value:lower() then
						return v3
					end
				end
			end
		},
		{
			Type = "Varies",
			Required = true,
			Suggester = function(list)
				return v[list[2]], true
			end,
			Completer = function(value: string, list)
				local lower = (list[2] or ""):lower()
				local lower2 = value:lower()

				if v2[lower] == nil then
					return tonumber(value) or value
				end

				local index = find(v2[lower], lower2)

				if index == nil then
					return
				else
					return v[v2[lower].Upper][index]
				end
			end
		},
		{
			Type = "Amount",
			Name = "Amount",
			Required = false,
			Completer = function(p: string)
				return (tonumber(p))
			end
		}
	},
	Server = function(_, items, p: string, p2: string, p3)
		if p == nil or not modulesByName[p] then
			error((`Invalid give type: {p}`))
			return
		end

		for _, item in pairs(items) do
			modulesByName[p](item, p2, p3)
		end
	end
}