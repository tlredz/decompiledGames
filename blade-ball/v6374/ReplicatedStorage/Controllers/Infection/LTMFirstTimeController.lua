local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("LocalizationService")
local playerGui = Players.LocalPlayer.PlayerGui
require3(ReplicatedStorage2.Shared.UniverseIds)
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.Time)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local dateTime = DateTime.fromUniversalTime(2024, 3, 2)
local dateEndTime = v3.getPriorityLTM().DateEndTime

function applyDateCutoff(object)
	local formatLocalTime = object:FormatLocalTime("LL", "en-us")
	return formatLocalTime:sub(1, #formatLocalTime - 6)
end

return {
	Start = function(_)
		local lTMFirstTime = playerGui:WaitForChild("LTMFirstTime")
		local main = lTMFirstTime:WaitForChild("Main")
		local remoteEvent = v2:RemoteEvent("LTMFirstTimeNotification")
		local v4 = nil

		local function close()
			lTMFirstTime.Enabled = false
			v:Close(lTMFirstTime.Name)

			if v4 then
				task.cancel(v4)
				v4 = nil
			end
		end

		main:WaitForChild("CloseButton").Activated:Connect(close)
		main:WaitForChild("PlayButton").Activated:Connect(close)
		main:WaitForChild("Timer")
		remoteEvent.OnClientEvent:Connect(function() end)
		main.Date.Text = ("%s - %s %s"):format(
			applyDateCutoff(dateTime),
			applyDateCutoff(dateEndTime),
			dateEndTime:FormatLocalTime("LT", "en-us")
		)
	end
}