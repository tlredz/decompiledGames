return {
	ConfigName = "FailedRewardMap",
	ApplyEnvironment = "Server",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local GenericFailedRewards = require(ServerScriptService.server.player.data.rewardCompensations.GenericFailedRewards)
		local flag = false

		for k, item in items do
			if typeof(item) ~= "table" then
				continue
			end

			for k2, v in item do
				if GenericFailedRewards.handlers[k].NameCorrections[k2] == v then
					continue
				end

				GenericFailedRewards.handlers[k].NameCorrections[k2] = v
				flag = true
			end
		end

		if flag then
			local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
			local Players = game:GetService("Players")

			for _, v in Players:GetPlayers() do
				local v2 = v
				task.spawn(function()
					local v3, v4 = legacyPlayerData.forPlayerNow(v2)

					if v3 and v4 then
						GenericFailedRewards.run(v4, v3, v2)
					end
				end)
			end
		end
	end
}