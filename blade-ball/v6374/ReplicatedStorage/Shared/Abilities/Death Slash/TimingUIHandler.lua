local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local v2 = require3(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local v3 = require3(ReplicatedStorage3.Common.Utils)
local frame = Players.LocalPlayer.PlayerGui:WaitForChild("DeathSlashTimer").Frame
local imageLabel = frame.ImageLabel
local circle = frame.Circle
local inner = frame.Inner
local uDim = UDim2.new(2, 0, 2, 0)
local color = Color3.fromRGB(255, 255, 255)
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
local signal = v3.Signal.new()
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
	local maid = v3.Maid.new()
	local tween = TweenService:Create(imageLabel, tweenInfo, {
		Size = UDim2.new(0, 0, 0, 0)
	})
	tween:Play()
	local v4 = false
	maid:GiveTask(v.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local v5 = v2:UseBind(input, "Ability") or false

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or v5 then
			v4 = TimingUIHandler.getTimingInput()
			signal:Fire()
		end
	end))
	maid:GiveTask(tween.Completed:Connect(function()
		v4 = false
		signal:Fire()
	end))
	signal:Wait()
	maid:DoCleaning()
	tween:Cancel()
	task.spawn(function()
		TimingUIHandler.giveFeedback(v4)
		task.wait(0.15)
		frame.Visible = false
	end)
	return v4
end

function TimingUIHandler.getTimingInput()
	local scale = imageLabel.Size.X.Scale
	local v4 = circle.Size.X.Scale + 0.1
	return not (scale < inner.Size.X.Scale - 0.1) and not (v4 < scale)
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