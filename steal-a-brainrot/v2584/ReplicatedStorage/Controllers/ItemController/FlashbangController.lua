local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer.PlayerScripts
local _ = workspace.CurrentCamera
local shared = ReplicatedStorage:WaitForChild("Shared")
require(shared.ShakePresets)
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Trove)
local Net = require(packages.Net)
require("../CameraController")
local module = require("../CharacterController")
local controls = module.Controls
local remoteEvent = Net:RemoteEvent("UseItem")
local originalMoveFunction = module.originalMoveFunction
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
remoteEvent.OnClientEvent:Connect(function(p)
	if p ~= "Flashbang" then
		return
	end

	local colorCCorrection = Lighting:FindFirstChild("ColorCCorrection")

	if colorCCorrection then
		colorCCorrection.Enabled = false
	end

	function controls.moveFunction(p2, p3, p4)
		module:RequestMove(p2, -(p3 * (1 + math.random())), p4)
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Name = "Flashbang"
	colorCorrectionEffect.Saturation = -0.2
	colorCorrectionEffect.Brightness = 0.1
	colorCorrectionEffect.Contrast = 0.1
	colorCorrectionEffect.Parent = Lighting
	local tween = TweenService:Create(colorCorrectionEffect, tweenInfo, {
		Brightness = 1
	})
	tween:Play()
	tween.Completed:Wait()
	task.wait(1)
	local tween2 = TweenService:Create(colorCorrectionEffect, tweenInfo2, {
		Brightness = 0
	})
	tween2:Play()
	tween2.Completed:Wait()
	colorCorrectionEffect:Destroy()
	task.wait()
	Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(212, 212, 212)

	if colorCCorrection then
		colorCCorrection.Enabled = true
	end

	task.delay(1, function()
		controls.moveFunction = originalMoveFunction
	end)
end)
return {}