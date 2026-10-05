local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v5 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v6 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
require3(ReplicatedStorage2.Shared.FastUtils)
local v7 = require3(ReplicatedStorage2.Common.Utils)

if v2.isRegionalTournamentMatch() or not table.find(v3.serverProfiles, "SheriffsVsOutlaws") then
	return {}
end

local activeLTM = v3.getActiveLTM("SheriffsVsOutlaws")

if not activeLTM then
	return {}
end

local playerGui = Players.LocalPlayer.PlayerGui
local remoteEvent = v:RemoteEvent("SheriffsVsOutlawsRoundUpdate")
local roundEnded = ReplicatedStorage2.Remotes.RoundEnded
local sheriffsVsOutlawsHUD = playerGui.SheriffsVsOutlawsHUD
local grid = sheriffsVsOutlawsHUD.Grid
local countdown = sheriffsVsOutlawsHUD.Countdown
local roundEndTime = nil

local function secondsToString(p: number)
	math.floor(p / 86400)
	math.floor(p % 86400 / 3600)
	local v8 = math.floor(p % 3600 / 60)
	local v9 = math.floor(p % 60)
	return string.format("%02d:%02d", v8, v9)
end

return {
	Start = function(_)
		local function refreshCounterVisibility()
			sheriffsVsOutlawsHUD.Enabled = #workspace.Alive:GetChildren() > 0 and not v6.IsUICovered.CurrentState and workspace:GetAttribute("CurrentlySelectedMode") == activeLTM.getGameMode()
		end

		local function onRoundStateUpdated(p)
			local gold = p.gold

			if not gold then
				return
			end

			for k, v8 in gold do
				local child = grid:FindFirstChild((`Team{k}`))

				if child then
					child.Score.Text = v7.ValueConvertor:AddCommas(v8)
				end
			end

			roundEndTime = p.roundEndTime
		end

		local function onRoundEnded()
			roundEndTime = nil
			task.delay(5, refreshCounterVisibility)
		end

		v4.Every(1, function()
			if not roundEndTime then
				countdown.Visible = false
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local v8 = math.max(roundEndTime - serverTimeNow, 0)
			local v9 = countdown
			math.floor(v8 / 86400)
			math.floor(v8 % 86400 / 3600)
			local v10 = math.floor(v8 % 3600 / 60)
			local v11 = math.floor(v8 % 60)
			v9.Text = `TIME LEFT: {string.format("%02d:%02d", v10, v11)}`

			if v8 > 0 then
				countdown.Visible = true
			elseif countdown.Visible and v8 == 0 then
				task.wait(1)
				countdown.Visible = false
			end
		end)
		remoteEvent.OnClientEvent:Connect(onRoundStateUpdated)
		roundEnded.OnClientEvent:Connect(onRoundEnded)
		workspace.Alive.ChildAdded:Connect(refreshCounterVisibility)
		v6.IsUICoveredState:Connect(refreshCounterVisibility)
		task.spawn(refreshCounterVisibility)

		local function OnDeviceChanged()
			if v5:IsMobile() then
				sheriffsVsOutlawsHUD.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
				sheriffsVsOutlawsHUD.IgnoreGuiInset = false
				sheriffsVsOutlawsHUD.Countdown.Position = UDim2.fromScale(0.5, 0.01)
				sheriffsVsOutlawsHUD.Grid.Position = UDim2.fromScale(0.5, 0.01)
			else
				sheriffsVsOutlawsHUD.ScreenInsets = Enum.ScreenInsets.None
				sheriffsVsOutlawsHUD.IgnoreGuiInset = true
				sheriffsVsOutlawsHUD.Countdown.Position = UDim2.fromScale(0.5, 0.05)
				sheriffsVsOutlawsHUD.Grid.Position = UDim2.fromScale(0.5, 0.05)
			end

			sheriffsVsOutlawsHUD.UIPadding.PaddingTop = UDim.new(0.01, 0)
			sheriffsVsOutlawsHUD.UIPadding.PaddingBottom = UDim.new(0.01, 0)
		end

		v5:Observe(OnDeviceChanged)
	end
}