local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local Net = require(ReplicatedStorage.packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local remoteEvent = Net:RemoteEvent("Bellona/AreaShake")
local color = Color3.fromRGB(180, 40, 40)
local BellonaShake = {}
BellonaShake.__index = BellonaShake

function BellonaShake.Morph(p, _, object)
	p.reelTrove:Add(remoteEvent.OnClientEvent:Connect(function()
		if not object.active then
			return
		end

		object:AddProgress(-p.config.ProgressLoss)
		object.fx:SpawnShake(object.reel_bar, 0.5, 1.5, 0.015, false)
		object.core.ui.CameraShake_Enabled = false

		if object.core.ui.CameraShake_CurrentShake then
			object.core.ui.CameraShake_CurrentShake.Stop()
			object.core.ui.CameraShake_CurrentShake = nil
		end

		fx:ShakeScreen(Players.LocalPlayer, 4, p.config.ShakeDuration)
		fx:ShakeScreen(Players.LocalPlayer, 6, p.config.ShakeDuration - 1)
		object:DelayLogic(p.config.ShakeDuration, function()
			if object.active then
				object.core.ui.CameraShake_Enabled = true
			end
		end)
		TweenService:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				BackgroundColor3 = color
			}
		):Play()
	end))
end

setmetatable(BellonaShake, module)
return BellonaShake