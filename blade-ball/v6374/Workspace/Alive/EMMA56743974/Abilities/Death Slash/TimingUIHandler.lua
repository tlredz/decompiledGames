local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local SettingsController = require(ReplicatedStorage2:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Utils = require(ReplicatedStorage2.Common.Utils)
local frame = Players.LocalPlayer.PlayerGui.DeathSlashTimer.Frame
local imageLabel = frame.ImageLabel
local circle = frame.Circle
local inner = frame.Inner
local uDim = UDim2.new(2, 0, 2, 0)
local color = Color3.fromRGB(255, 255, 255)
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
local signal = Utils.Signal.new()
local TimingUIHandler = {
	ToggleUIOn = function()
		frame.Parent.Enabled = true
	end,
	ToggleUIOff = function()
		frame.Parent.Enabled = false
	end
}

function TimingUIHandler.activateUI()
	frame.Visible = true
	imageLabel.Size = uDim
	circle.BackgroundColor3 = color
	local maid = Utils.Maid.new()
	local tween = TweenService:Create(imageLabel, tweenInfo, {
		Size = UDim2.new(0, 0, 0, 0)
	})
	tween:Play()
	local v = false
	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local v2 = SettingsController:UseBind(input, "Ability") or false

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or v2 then
			v = TimingUIHandler.getTimingInput()
			signal:Fire()
		end
	end))
	maid:GiveTask(tween.Completed:Connect(function()
		v = false
		signal:Fire()
	end))
	signal:Wait()
	maid:DoCleaning()
	tween:Cancel()
	task.spawn(function()
		TimingUIHandler.giveFeedback(v)
		task.wait(0.15)
		frame.Visible = false
	end)
	return v
end

function TimingUIHandler.getTimingInput()
	local scale = imageLabel.Size.X.Scale
	local v = circle.Size.X.Scale + 0.1
	return not (scale < inner.Size.X.Scale - 0.1) and not (v < scale)
end

function TimingUIHandler.giveFeedback(p)
	if p then
		SoundService:PlayLocalSound(script.Success)
		circle.BackgroundColor3 = Color3.new(0, 0.0509804, 1)
	else
		SoundService:PlayLocalSound(script.Failure)
		circle.BackgroundColor3 = Color3.new(1, 0, 0)
	end
end

return TimingUIHandler