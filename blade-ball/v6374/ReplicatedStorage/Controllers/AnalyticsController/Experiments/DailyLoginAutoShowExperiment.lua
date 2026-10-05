local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Types.Analytics)
local v = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local localPlayer = Players.LocalPlayer
return {
	RemoteConfig = "AutoShowDailyLogin",
	DefaultValue = true,
	Disabled = false,
	TestConfigValues = {
		[true] = 100
	},
	Configs = {
		[true] = function()
			if not v.isNewPlayerLobbyServer() then
				return
			end

			local v5 = v2.Client:WaitReplion("Data")
			local currentDailyLoginType = v5:Get("CurrentDailyLoginType")

			while currentDailyLoginType == nil do
				task.wait(0.1)
				currentDailyLoginType = v5:Get("CurrentDailyLoginType")
			end

			if currentDailyLoginType == "Legacy" then
				local sessionStartTime = localPlayer:GetAttribute("SessionStartTime") or workspace:GetServerTimeNow()
				local connection = nil
				connection = v3.Thread.Every(1, function()
					if workspace:GetServerTimeNow() - sessionStartTime < 360 or (not localPlayer.Character or not localPlayer.Character.Parent or localPlayer.Character.Parent == workspace.Alive) then
						return
					end

					if v4._currentGui then
						return
					end

					if not ((v5:Get("DailyLogin") or 0) - workspace:GetServerTimeNow() <= 0) then
						connection:Disconnect()
						return
					end

					v4:Open("DailyLogin_Legacy_Rewards")
					localPlayer.Character.AncestryChanged:Once(function()
						if localPlayer.Character.Parent == workspace.Alive and v4:IsOpen("DailyLogin_Legacy_Rewards") then
							v4:Close("DailyLogin_Legacy_Rewards")
						end
					end)
					connection:Disconnect()
				end)
			elseif v.isTestGame() or RunService:IsStudio() then
				print((`Experiment does not support {currentDailyLoginType} DailyLoginType`))
			end
		end
	}
}