local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
return {
	ConfigName = "OverrideCodes",
	ApplyEnvironment = "Server",
	Apply = function(p)
		if typeof(p) ~= "table" then
			return
		end

		local codes = require(ServerScriptService.server.player.replicatedevents.codes)
		codes.Valid = GeneralUtils.applyTable(codes.Valid, p, true)

		for k, v in pairs(codes.Valid) do
			if v.Run then
				continue
			end

			local v2 = k
			local v3 = v

			function v.Run(p2)
				codes._redeem(p2, v2, v3)
			end
		end
	end
}