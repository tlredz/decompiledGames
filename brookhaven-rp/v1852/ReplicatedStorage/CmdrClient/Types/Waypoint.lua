game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local RunService = game:GetService("RunService")
local v = {}
local now = 0
local v2 = {
	DisplayName = "Waypoint",
	Transform = function(p: string, p2)
		if RunService:IsServer() then
			local ProfileService = require(ServerScriptService.Modules.PlayerData.ProfileService)
			local _, v3 = ProfileService.GetProfilePromise(p2):await()
			v = not v3 and {} or v3.Data.waypoints
		elseif tick() - now > 0.5 then
			local v3 = Remotes.invokeServer("GetWaypoints")

			if v3 ~= "ratelimited" then
				v = v3
			end

			now = tick()
		end

		local v3 = v
		local v4 = {}

		if v3 then
			for k, _ in v3 do
				table.insert(v4, k)
			end
		end

		return p, v3, CmdrUtil.MakeFuzzyFinder(v4)(p)
	end,
	ValidateOnce = function(p: string, p2)
		return p2[p] ~= nil, "You have not set a waypoint by this name."
	end,
	Validate = function(p: string, p2)
		return p2[p] ~= nil, "You have no set waypoints by this name."
	end,
	Autocomplete = function(_, _, p)
		return p
	end,
	Parse = function(p)
		return p
	end
}
return function(registry)
	registry:RegisterType("waypoint", v2)
end