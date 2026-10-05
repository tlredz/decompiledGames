local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animations = ReplicatedStorage:FindFirstChild("Animations")
local animals = animations and animations:FindFirstChild("Animals")
local beeLuckyBlock = animals and animals:FindFirstChild("Bee Lucky Block")
local idle = beeLuckyBlock and beeLuckyBlock:FindFirstChild("Idle")

if idle and idle:IsA("Animation") then
	local track = script.Parent.AnimationController.Animator:LoadAnimation(idle)
	track.Looped = true
	track:Play()
end