local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Caps = require(ReplicatedStorage.CAM.Global.Caps)
local masteries = {}
local v = {}
local masteries2 = {}

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
		masteries2[mastery:lower()] = mastery
	end
end

local Utility = isServer and require(ReplicatedStorage.CAM.Global.Utility) or nil
return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Mastery",
			Name = "Mastery",
			Required = true,
			Suggester = masteries,
			Completer = function(value: string)
				local lower = value:lower()
				local index = table.find(v, lower)

				if index then
					return masteries[index]
				end

				return lower
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
	Server = function(_, items, value: string, p)
		local name = masteries2[value:lower()] or value
		local v3 = tonumber(p) or 1

		if v3 < 1 or v3 % 1 ~= 0 then
			error((`Mastery level must be a whole number from 1, not {v3}`))
		end

		for _, item in items do
			local data = Utility.GetData(item)

			if data == nil then
				continue
			end

			local expPerMasteryDefault = gameSettings.expPerMasteryDefault
			local parent = data.MasteryProgressionList:FindFirstChild(name)

			if parent == nil then
				parent = Instance.new("Folder")
				parent.Name = name
				local intValue = Instance.new("IntValue")
				intValue.Name = "Current"
				intValue.Value = 0
				intValue.Parent = parent
				local intValue2 = Instance.new("IntValue")
				intValue2.Name = "Goal"
				intValue2.Value = expPerMasteryDefault
				intValue2.Parent = parent
				parent.Parent = data.MasteryProgressionList
			end

			local v5 = math.min(v3, Caps.Get(item, Caps.MasteryKey(name)))
			parent.Goal.Value = v5 * expPerMasteryDefault
			parent.Current.Value = 0
		end
	end
}