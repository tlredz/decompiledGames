local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Shared.LTM)
local v3 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v4 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v5 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
require3(ReplicatedStorage2.Shared.FastUtils)

if v2.isRegionalTournamentMatch() then
	return {}
end

local v6 = {
	Hovergoal = true,
	Soccer = true
}
local playerGui = Players.LocalPlayer.PlayerGui
local remoteEvent = v:RemoteEvent("HovergoalRoundUpdate")
local roundEnded = ReplicatedStorage2.Remotes.RoundEnded
local roundHovergoalPoints = playerGui.RoundHovergoalPoints
local grid = roundHovergoalPoints.Grid
local countdown = roundHovergoalPoints.Countdown
local roundEndTime = nil
local HovergoalPointsController = {
	Start = function(_)
		local function RefreshCounterVisibility()
			roundHovergoalPoints.Enabled = #workspace.Alive:GetChildren() > 0 and not v5.IsUICovered.CurrentState and v6[workspace:GetAttribute("CurrentlySelectedMode")] == true
		end

		local function OnRoundStateUpdated(p)
			local points = p.points

			if not points then
				return
			end

			for childName, point in points do
				local child = grid:FindFirstChild(childName)

				if child then
					child.Score.Text = tostring(point)
				end
			end

			roundEndTime = p.roundEndTime
		end

		local function OnRoundEnded()
			roundEndTime = nil
			task.delay(5, RefreshCounterVisibility)
		end

		v3.Every(1, function()
			if not roundEndTime then
				countdown.Visible = false
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local v7 = math.max(roundEndTime - serverTimeNow, 0)
			countdown.Text = `TIME LEFT: {SecondsToString(v7)}`

			if v7 > 0 then
				countdown.Visible = true
			elseif countdown.Visible and v7 == 0 then
				task.wait(1)
				countdown.Visible = false
			end
		end)
		remoteEvent.OnClientEvent:Connect(OnRoundStateUpdated)
		roundEnded.OnClientEvent:Connect(OnRoundEnded)
		workspace.Alive.ChildAdded:Connect(RefreshCounterVisibility)
		v5.IsUICoveredState:Connect(RefreshCounterVisibility)
		task.spawn(RefreshCounterVisibility)

		local function OnDeviceChanged()
			if v4:IsMobile() then
				roundHovergoalPoints.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
				roundHovergoalPoints.IgnoreGuiInset = false
				roundHovergoalPoints.Countdown.Position = UDim2.fromScale(0.5, 0.01)
				roundHovergoalPoints.Grid.Position = UDim2.fromScale(0.5, 0.01)
			else
				roundHovergoalPoints.ScreenInsets = Enum.ScreenInsets.None
				roundHovergoalPoints.IgnoreGuiInset = true
				roundHovergoalPoints.Countdown.Position = UDim2.fromScale(0.5, 0.05)
				roundHovergoalPoints.Grid.Position = UDim2.fromScale(0.5, 0.05)
			end

			roundHovergoalPoints.UIPadding.PaddingTop = UDim.new(0.01, 0)
			roundHovergoalPoints.UIPadding.PaddingBottom = UDim.new(0.01, 0)
		end

		v4:Observe(OnDeviceChanged)
	end
}

function SecondsToString(p: number)
	math.floor(p / 86400)
	math.floor(p % 86400 / 3600)
	local v7 = math.floor(p % 3600 / 60)
	local v8 = math.floor(p % 60)
	return string.format("%02d:%02d", v7, v8)
end

return HovergoalPointsController