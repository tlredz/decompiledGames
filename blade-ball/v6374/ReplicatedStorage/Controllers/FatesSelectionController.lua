local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local localPlayer = Players.LocalPlayer
local fatesTimer = localPlayer.PlayerGui.FatesTimer
local remoteEvent = v2:RemoteEvent("FatesSelection")
local remoteEvent2 = v2:RemoteEvent("FatesSelectionSchedule")
return {
	Start = function(_)
		remoteEvent2.OnClientEvent:Connect(function(p: number)
			local v3 = p - workspace:GetServerTimeNow()

			if v3 <= 0 or fatesTimer.Enabled then
				return
			end

			fatesTimer.Enabled = true
			local connection = nil
			connection = v.Thread.Every(1, function()
				if connection and not connection.Connected then
					return
				end

				v3 = p - workspace:GetServerTimeNow()
				fatesTimer.Countdown.Text = v.ValueConvertor:FormatTime((math.floor(v3)))

				if v3 <= 0 then
					fatesTimer.Enabled = false

					if connection then
						connection:Disconnect()
						connection = nil
					end
				end
			end)
		end)
		remoteEvent.OnClientEvent:Connect(function(list, items)
			for k, item in items do
				local v3 = list[k]
				local adornee

				if v3 then
					adornee = v3:FindFirstChild("Head")
				end

				item.Adornee = adornee
			end

			if table.find(list, localPlayer.Character) then
				v.Sounds:Play("reward")
			end
		end)
	end
}