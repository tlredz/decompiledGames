local ReplicatedStorage = game:GetService("ReplicatedStorage")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local parent = script.Parent
local animator = parent.AnimationController.Animator
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://101584462565852"
local track = animator:LoadAnimation(animation)
track:Play()
track.Looped = true
parent.OpenInterface.Triggered:Connect(function()
	InterfaceController:Toggle("CoinsShop")
end)