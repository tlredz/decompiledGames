local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local faye = require(ReplicatedStorage.Packages.faye)
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
return function(options)
	local v = options or {}
	local v2 = faye.new()
	local timeBetween = v.TimeBetween or 0.5
	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.DisplayOrder = v.DisplayOrder or 999999
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.Name = `{script.Name}-Transition`
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = v.Color or Color3.new()
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	TweenService:Create(frame, tweenInfo, {
		BackgroundTransparency = 0
	}):Play()
	v2:Add(screenGui)

	local function fn()
		TweenService:Create(frame, tweenInfo, {
			BackgroundTransparency = 1
		}):Play()
		task.wait(tweenInfo.Time + 0.1)
		v2:Destroy()
	end

	if v.Switch == nil then
		task.delay(timeBetween, fn)
	else
		task.spawn(function()
			repeat
				task.wait()
			until v.Switch

			fn()
		end)
	end
end