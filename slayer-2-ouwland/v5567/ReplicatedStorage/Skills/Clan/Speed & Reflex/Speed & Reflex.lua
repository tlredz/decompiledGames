local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
require(global:WaitForChild("Utility"))
local Config = require(script.Parent.Config)
local SpeedReflex = {
	Id = 0
}
local _ = Players.LocalPlayer

local function playClip(humanoid, childName: string)
	local child = script:FindFirstChild(childName)
	local animator = humanoid:FindFirstChild("Animator")

	if child == nil or animator == nil then
		return
	end

	local track = animator:LoadAnimation(child)
	v:Add(track)
	track:Play()
end

function SpeedReflex.Hold(player)
	if player == nil then
		return false
	end

	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return false
	end

	v:Clean()
	local id = SpeedReflex.Id
	playClip(humanoid, "SpeedReflexClone")
	task.wait(Config.WINDUP)

	if id ~= SpeedReflex.Id then
		return true
	end

	v:Clean()
	return true
end

function SpeedReflex.Switch(player)
	if player == nil then
		return false
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return false
	end

	v:Clean()
	playClip(humanoid, "SpeedReflexRecall")
	return false
end

function SpeedReflex.Cancel(_)
	v:Clean()
end

return SpeedReflex