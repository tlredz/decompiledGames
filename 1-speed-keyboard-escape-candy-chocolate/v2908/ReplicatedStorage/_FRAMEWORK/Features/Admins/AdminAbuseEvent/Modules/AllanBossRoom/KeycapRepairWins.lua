local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
return {
	start = function(p)
		assert(RunService:IsServer(), "AllanBossRoom.KeycapRepairWins.start is server-only")
		local config = p.config
		local awardWin = p.awardWin
		local v = {}
		local total = 0

		local function flush()
			for k, v2 in v do
				if v2 > 0 then
					awardWin(k, v2 / config.keycapsPerWholeAward)
				end
			end

			table.clear(v)
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			total += dt

			if total >= config.winFlushIntervalSeconds then
				total = 0
				flush()
			end
		end)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
			v[player] = nil
		end)
		return {
			record = function(p2, p3: number)
				v[p2] = (v[p2] or 0) + p3
			end,
			stop = function()
				heartbeatConnection:Disconnect()
				playerRemovingConnection:Disconnect()
				flush()
				table.clear(v)
			end
		}
	end
}