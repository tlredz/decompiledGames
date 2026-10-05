local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v5 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local playerGui = Players.LocalPlayer.PlayerGui
local currentLTM = v3.getCurrentLTM()
local v6 = v2.isLTMServer() and currentLTM and (currentLTM.getGameMode() == "Flying" or currentLTM.getGameMode() == "Storm")

if not v6 then
	return {}
end

local lTMPhase = playerGui:WaitForChild("LTMPhase")
local frame = lTMPhase:WaitForChild("Frame")
local remoteEvent = v:RemoteEvent("PhaseChanged")
local v7 = 0
workspace:WaitForChild("Alive")
workspace:WaitForChild("Dead")

function UpdateGuiInset(_)
	lTMPhase.IgnoreGuiInset = v5.Device ~= "Phone"
end

function UpdateTimer()
	if v7 == 0 then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local v8 = math.max(v7 - serverTimeNow, 0)

	if v8 == 0 then
		if frame.TimerFrame.Timer.Text ~= "PAUSED" then
			frame.TimerFrame.Timer.Text = `{v4:FormatShortTime(v8)} Left`
			task.wait(1)
			frame.TimerFrame.Timer.Text = "PAUSED"
			frame.TimerFrame.Clock.Visible = false
		end
	else
		frame.TimerFrame.Timer.Text = `{v4:FormatShortTime(v8)} Left`
		frame.TimerFrame.Clock.Visible = true
		frame.Visible = true
	end
end

function OnPhaseChanged(p: number, p2: number)
	if p == 0 then
		v7 = 0
		lTMPhase.Enabled = false
	else
		if p2 == 0 then
			frame.TimerFrame.Visible = false
		else
			frame.TimerFrame.Visible = true
		end

		v7 = p2
		local currentLTM2 = v3.getCurrentLTM()
		frame.TopLabel.TextLabel.Text = (not currentLTM2 or currentLTM2.getGameMode() ~= "Flying") and "Safe Zone Moving" or `Phase {p}`
		UpdateTimer()
		lTMPhase.Enabled = true
	end
end

return {
	Start = function(_)
		lTMPhase.Enabled = false

		if v6 then
			remoteEvent.OnClientEvent:Connect(OnPhaseChanged)
			v5:Observe(UpdateGuiInset)
			task.spawn(function()
				while true do
					UpdateTimer()
					task.wait(0.5)
				end
			end)
		end
	end
}