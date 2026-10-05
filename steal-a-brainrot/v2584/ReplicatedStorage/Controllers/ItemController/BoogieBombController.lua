local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local shared = ReplicatedStorage:WaitForChild("Shared")
local ShakePresets = require(shared.ShakePresets)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local module = require("../CameraController")
local remoteEvent = Net:RemoteEvent("UseItem")
local maid = Trove.new()
local BOOM = script.BOOM
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
remoteEvent.OnClientEvent:Connect(function(p)
	if p ~= "Boogie" then
		return
	end

	local colorCCorrection = Lighting:FindFirstChild("ColorCCorrection")

	if colorCCorrection then
		colorCCorrection.Enabled = false
	end

	BOOM:Play()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Name = "DiscoEffect"
	colorCorrectionEffect.Saturation = -0.2
	colorCorrectionEffect.Brightness = 0.1
	colorCorrectionEffect.Contrast = 0.1
	colorCorrectionEffect.Parent = Lighting
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 3
	blurEffect.Parent = Lighting
	local tween = TweenService:Create(currentCamera, tweenInfo2, {
		FieldOfView = 80
	})
	local tween2 = TweenService:Create(colorCorrectionEffect, tweenInfo, {
		Brightness = 0.25
	})
	tween2:Play()
	tween:Play()
	local clone = ShakePresets.Bump:Clone()
	maid:Add(clone)
	clone.Sustain = true
	maid:Add(ShakePresets.BindShakeToCamera(clone, currentCamera))
	clone:Start()
	maid:Add(task.delay(10, function()
		clone:StopSustain()
	end))
	task.delay(10, function()
		tween2:Cancel()
		colorCorrectionEffect:Destroy()
		tween:Cancel()
		BOOM:Stop()
		blurEffect:Destroy()
		task.wait()
		currentCamera.FieldOfView = module:GetDefaultFov()
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(212, 212, 212)

		if colorCCorrection then
			colorCCorrection.Enabled = true
		end

		maid:Clean()
	end)
end)
return {}