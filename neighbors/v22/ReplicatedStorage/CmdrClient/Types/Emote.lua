local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(script.Parent.Parent.Shared.Util)
local Emotes

if RunService:IsServer() then
	Emotes = require(ServerStorage.Assets.Data.Emotes)
else
	Emotes = require(ReplicatedStorage.Assets.Data.Store.Emotes)
end

local v = {
	Transform = function(p)
		local v2 = {}

		for k, _ in Emotes do
			table.insert(v2, (k:gsub(" ", "_")))
		end

		return Util.MakeFuzzyFinder(v2)(p)
	end,
	Validate = function(list)
		return #list > 0, "No emote with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(_)
		return "Push_Ups"
	end,
	ArgumentOperatorAliases = {
		all = "*",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("emote", v)
	registry:RegisterType("emotes", Util.MakeListableType(v))
end