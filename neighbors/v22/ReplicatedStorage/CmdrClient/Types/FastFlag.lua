local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local _ = ReplicatedStorage.Modules
local Util = require(script.Parent.Parent.Shared.Util)
local allowedFastFlags

if RunService:IsServer() then
	local FastFlags = require(game.ServerStorage.Modules.FastFlags)
	allowedFastFlags = FastFlags.AllowedFastFlags
else
	local Network = require(game.ReplicatedStorage.Modules.Network)
	allowedFastFlags = Network:invoke("GetAllowedFastFlags")
end

local v = {
	Transform = function(p)
		return Util.MakeFuzzyFinder(allowedFastFlags)(p)
	end,
	Validate = function(list)
		return #list > 0, "not a valid fast flag"
	end,
	Autocomplete = function(p)
		return p
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(_)
		return allowedFastFlags[1]
	end
}
return function(registry)
	registry:RegisterType("fastflag", v)
end