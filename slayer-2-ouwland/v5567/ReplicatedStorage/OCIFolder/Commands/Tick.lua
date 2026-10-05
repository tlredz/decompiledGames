local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local AppliedTicks = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AppliedTicks)
local Utility = isServer and require(ReplicatedStorage.CAM.Global.Utility) or nil
return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Tick",
			Name = "Tick",
			Required = true,
			Suggester = AppliedTicks.Names,
			Completer = function(value: string)
				local v = AppliedTicks.ByName[value:lower()]

				if v == nil then
					return value
				end

				return v.Name
			end
		},
		{
			Type = "Amount",
			Name = "Duration",
			Required = false,
			Completer = function(p: string)
				return (tonumber(p))
			end
		}
	},
	Server = function(player, items, p: string, p2)
		local v = AppliedTicks.ByName[tostring(p):lower()]

		if v == nil then
			return
		end

		local v2 = tonumber(p2) or 10

		if v2 <= 0 then
			return
		end

		local character = player.Character

		for _, item in items do
			local character2 = item.Character

			if character2 == nil then
				continue
			end

			local getvaluesfolder = Utility.getvaluesfolder(character2)

			if getvaluesfolder ~= nil then
				Utility.AddValue(getvaluesfolder, v.Value, v2, "ObjectValue", character)
			end
		end
	end
}