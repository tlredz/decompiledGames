local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local screenBurn = FX:WaitForChild("DracoRace").ScreenBurn
local debris = Util.Debris
local _ = Util.BoatTween
local TweenService = game:GetService("TweenService")

local function BurnScreenEffect(duration, CC)
	local currentCamera = workspace.CurrentCamera
	local clone = screenBurn.BurnCameraFocus:Clone()
	debris:AddItem(clone, 10)
	clone.Parent = _WorldOrigin
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
	end)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local tweensByClone = {}

	if CC then
		for i = 1, 3 do
			local v = i
			task.spawn(function()
				local clone2 = nil

				if v == 1 then
					clone2 = screenBurn.ScreenColor1:Clone()
				elseif v == 2 then
					clone2 = screenBurn.ScreenColor2:Clone()
				elseif v == 3 then
					clone2 = screenBurn.ScreenColor3:Clone()
				end

				debris:AddItem(clone2, 10)
				clone2.Parent = currentCamera
				local tween = TweenService:Create(
					clone2,
					TweenInfo.new(
						math.random(10, 30) / 100,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.Out,
						0,
						false,
						math.random(0, 10) / 100
					),
					{
						Brightness = clone2.Brightness,
						Contrast = clone2.Contrast,
						Saturation = clone2.Saturation,
						TintColor = clone2.TintColor
					}
				)
				clone2.Brightness = 0
				clone2.Contrast = 0
				clone2.Saturation = 0
				clone2.TintColor = Color3.fromRGB(255, 255, 255)
				tweensByClone[clone2] = tween
				tween:Play()
			end)
		end
	end

	task.wait(duration)

	if CC then
		for k, _ in pairs(tweensByClone) do
			TweenService:Create(k, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Brightness = 0,
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
			game.Debris:AddItem(k, 1)
		end
	end

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.wait(1.5)
	renderSteppedConnection:Disconnect()
	clone:Destroy()
end

return function(p)
	local duration = p.Duration
	local CC = p.CC or false
	BurnScreenEffect(duration, CC)
end