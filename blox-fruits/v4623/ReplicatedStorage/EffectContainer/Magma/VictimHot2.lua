local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
TweenInfo.new(0.15, Enum.EasingStyle.Sine)
local _ = {
	Size = createVector(25, 15, 35),
	Transparency = 1,
	Color = Color3.new(0, 0, 0)
}
local _ = CFrame.Angles
Random.new()

local function fix(instance)
	local touchTransmitter = instance:FindFirstChildWhichIsA("TouchTransmitter")

	if touchTransmitter then
		touchTransmitter:Destroy()
		return
	end

	local childAddedConnection = nil
	childAddedConnection = instance.ChildAdded:Connect(function(touchTransmitter2)
		if touchTransmitter2:IsA("TouchTransmitter") then
			childAddedConnection:Disconnect()
			touchTransmitter2:Destroy()
		end
	end)
end

return function(p)
	local character_to_send = p.character_to_send

	if not (character_to_send and game.Players:FindFirstChild(character_to_send.Name)) then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local count = 0
	local time_to_send = p.time_to_send or 5
	local flag = true
	coroutine.resume(coroutine.create(function()
		wait(time_to_send)
		flag = false
	end))
	coroutine.resume(coroutine.create(function()
		while flag do
			Util.CameraShaker:ShakeOnce(2.5, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
			local v = math.random(2.5, 5) / 10
			count += 1
			local v2 = { currentCamera.CFrame:GetComponents() }
			v2[10] = v2[10] - 0.02 + math.cos(count / 15) * 0.04
			v2[11] = v2[11] - 0.02 + math.cos(count / 20) * 0.04
			currentCamera.CFrame = CFrame.new(table.unpack(v2))
			wait(v / 2)
		end
	end))
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = game.Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.15), {
		Brightness = math.random(10, 20) / 100,
		TintColor = Color3.fromRGB(255, 85, 0)
	}):Play()
	wait(0.15)
	local v = true

	while flag do
		local v2 = math.random(10, 20) / 10

		if v then
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(v2), {
				Brightness = math.random(10, 20) / 100,
				TintColor = Color3.fromRGB(255, 85, 0)
			}):Play()
		elseif not v then
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(v2), {
				Brightness = math.random(10, 20) / 100,
				TintColor = Color3.fromRGB(170, 0, 0)
			}):Play()
		end

		wait(v2 / 2)
		v = not v
	end

	local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
		Brightness = 0,
		TintColor = Color3.fromRGB(255, 255, 255)
	})
	tween:Play()
	tween.Completed:Connect(function()
		colorCorrectionEffect:Destroy()
	end)
	TweenService:Create(currentCamera, TweenInfo.new(0.25), {
		FieldOfView = 70
	}):Play()
	Util.CameraShaker:ShakeOnce(5, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
end