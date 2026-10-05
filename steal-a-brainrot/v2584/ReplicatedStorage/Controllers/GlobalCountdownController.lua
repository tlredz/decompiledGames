local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Timer = require(ReplicatedStorage.Packages.Timer)
local localPlayer = Players.LocalPlayer
local topUI = localPlayer.PlayerGui:WaitForChild("TopUI")
local countdown = topUI.Frame.Countdown
return {
	Start = function(_)
		if ServerData.IsDuelsServer() then
			countdown.Visible = false
			return
		end

		if ServerData.IsJumpLTMServer() then
			topUI.Frame.Position = UDim2.new(0, 0, 0.05, 12)
		end

		local v = Synchronizer:Wait(localPlayer)
		local v2 = nil
		local color = nil
		local title = nil

		local function update()
			local serverTimeNow = workspace:GetServerTimeNow()
			local instant = FFlags:GetInstant("GlobalCountdown")

			if instant and not (instant.timestamp < serverTimeNow) then
				if v2 ~= true then
					v2 = true
					countdown.Visible = v and v:Get("TutorialFinished") == true
				end

				countdown.Timer.Text = TimeUtils:E((math.max(instant.timestamp - serverTimeNow, 0)))

				if title ~= instant.title then
					title = instant.title
					countdown.Title.Text = instant.title
				end

				if color ~= instant.color then
					color = instant.color
					countdown.Title.TextColor3 = Color3.fromHex(instant.color or "ffea00")
				end
			elseif v2 ~= false then
				v2 = false
				countdown.Visible = false
			end
		end

		Timer.Simple(1, update, true)
	end
}