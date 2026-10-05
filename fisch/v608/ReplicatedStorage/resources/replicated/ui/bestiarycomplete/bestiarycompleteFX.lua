local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
local clone = ReplicatedStorage.resources.sounds.sfx.ui.bestiaryComplete:Clone()
local clone2 = ReplicatedStorage.resources.sounds.sfx.ui.bestiaryComplete2:Clone()
parent.Visible = false
local total = 0.01

for _, child in pairs(parent.Parent:GetChildren()) do
	if child.Name == parent.Name and child ~= parent then
		total += 13
	end
end

task.wait(total)
clone.Parent = script.Parent
clone2.Parent = script.Parent
parent.TextTransparency = 1
parent.shine.ImageTransparency = 1
parent.UIStroke.Transparency = 1
local TweenService = game:GetService("TweenService")
TweenService:Create(parent, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
	TextTransparency = 0
}):Play()
local TweenService2 = game:GetService("TweenService")
TweenService2:Create(parent.shine, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
	ImageTransparency = 0
}):Play()
local TweenService3 = game:GetService("TweenService")
TweenService3:Create(parent.UIStroke, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
	Transparency = 0
}):Play()
parent.Visible = true
clone:Play()
task.wait(3)
parent.stamp.Size = UDim2.new(1, 0, 10, 0)
parent.stamp.ImageTransparency = 1
parent.stamp.Visible = true
local TweenService4 = game:GetService("TweenService")
TweenService4:Create(parent.stamp, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	ImageTransparency = 0
}):Play()
parent.stampshine.ImageTransparency = 1
parent.stampshine.Size -= UDim2.new(0, 70, 0, 70)
parent.stampshine.Visible = true
local TweenService5 = game:GetService("TweenService")
TweenService5:Create(parent.stampshine, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	ImageTransparency = 0.2,
	Size = UDim2.new(0.551, 0, 3.873, 0)
}):Play()
local TweenService6 = game:GetService("TweenService")
TweenService6:Create(parent.stamp, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
	Size = UDim2.new(0.453, 0, 4.031, 0)
}):Play()
task.wait(0.5)
clone2:Play()
parent.Rotation = 10
parent.Position += UDim2.new(0, 20, 0, -20)
local TweenService7 = game:GetService("TweenService")
TweenService7:Create(parent, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Rotation = 0
}):Play()
task.wait(10)
local TweenService8 = game:GetService("TweenService")
TweenService8:Create(parent, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
	Position = UDim2.new(0.5, 0, -2, 0),
	Rotation = -45
}):Play()
task.wait(1)
script.Parent:Destroy()