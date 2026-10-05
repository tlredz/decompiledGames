local v = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local xpGain = ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("xpGain")
xpGain.PlaybackSpeed = 1.4
local numberValue = Instance.new("NumberValue")
numberValue.Value = 0.01
numberValue.Parent = script.Parent
local TweenService = game:GetService("TweenService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
TweenService:Create(
	ReplicatedStorage3:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("xpGain"),
	TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0),
	{
		PlaybackSpeed = 0.7
	}
):Play()
local TweenService2 = game:GetService("TweenService")
TweenService2:Create(numberValue, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
	Value = 0.1
}):Play()
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
fx:PlaySound(
	ReplicatedStorage4:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("xpGain"),
	script.Parent,
	false
)
script.Parent.bar.fill:GetPropertyChangedSignal("Size"):Connect(function()
	if v == false then
		v = true
		local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage5:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("xpGain"),
			script.Parent,
			false
		)
		task.wait(numberValue.Value)
		v = false
	end
end)