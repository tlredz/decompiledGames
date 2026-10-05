local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local HapticEffectsController = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("HapticEffectsController"))
local Audio = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Audio"))
Debris:AddItem(parent, 30)
parent.Visible = true
Audio:Play("Sounds.Twisted.Vee.PopUp")
local size = script.Parent.Size
parent.Position = UDim2.new(math.random(25, 75) / 100, 0, math.random(35, 70) / 100, 0)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
script.Parent.Size = UDim2.new(size.X.Scale * 0.9, 0, size.Y.Scale * 0.9, 0)
TweenService:Create(parent, tweenInfo, {
	Size = UDim2.new(size.X.Scale, 0, size.Y.Scale, 0)
}):Play()
parent.ExitButton.Activated:Connect(function()
	Audio:PlayOne("Sounds.UI.Buttons.Click")
	HapticEffectsController:Play("UIClickSoft")
	parent:Destroy()
end)