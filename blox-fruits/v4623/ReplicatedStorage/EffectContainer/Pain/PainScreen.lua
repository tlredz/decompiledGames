local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").PainScreen.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
return function(data)
	local player = data.Player
	local victimRoot = data.VictimRoot
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "PainFruitVFXColor")
	Util.Debris:AddItem(folder, data.Duration + 2)
	local clone = assets.Phase1.CameraFocus:Clone()
	Util.SetParentOverrideWithColor(clone, folder, player, "PainFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, 0, 0)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(1)
	end

	local _ = assets.Phase1.ScreenColorPainT
	local duration = data.Duration
	local screenColorPainT = game.Lighting:FindFirstChild("ScreenColorPainT")

	if screenColorPainT then
		screenColorPainT:SetAttribute("UsedTimes", screenColorPainT:GetAttribute("UsedTimes") + 3)
	else
		screenColorPainT = assets.Phase1.ScreenColorPainT:Clone()
		screenColorPainT:SetAttribute("UsedTimes", duration)
	end

	Util.SetParentOverrideWithColor(screenColorPainT, game.Lighting, player, "PainFruitVFXColor")
	local tween = TweenService:Create(
		screenColorPainT,
		TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 100, true, 0),
		{
			TintColor = Util.WrapColor3Constructor(Color3.fromRGB(194, 84, 84), player, "PainFruitVFXColor"),
			Brightness = -0.3
		}
	)
	tween:Play()
	local tween2 = TweenService:Create(
		currentCamera,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In, 100, true, 0),
		{
			FieldOfView = 85
		}
	)
	tween2:Play()

	repeat
		task.wait(0.1)
		screenColorPainT:SetAttribute("UsedTimes", screenColorPainT:GetAttribute("UsedTimes") - 0.1)
	until screenColorPainT:GetAttribute("UsedTimes") <= 0 or not (victimRoot and victimRoot:IsDescendantOf(workspace))

	tween:Pause()
	tween2:Pause()

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * 0.1, emitter.Lifetime.Max * 0.1)
		emitter.Enabled = false
	end

	local tween3 = TweenService:Create(screenColorPainT, TweenInfo.new(0.35), {
		TintColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 255, 255), player, "PainFruitVFXColor"),
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	})
	tween3:Play()
	TweenService:Create(currentCamera, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = 70
	}):Play()
	tween3.Completed:Wait()
	screenColorPainT:Destroy()
	task.wait(0.5)
	renderSteppedConnection:Disconnect()
	clone:Destroy()
end