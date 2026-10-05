local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local global = CAM:WaitForChild("Global")
local skills = ReplicatedStorage:WaitForChild("Skills")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global:WaitForChild("Utility"))
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local Config = require(script.Parent.Config)
local Headbutt = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")

function Headbutt.Hold(player)
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

	maid:Clean()
	local id = Headbutt.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.LOCK)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.LOCK))
	local anim = script:FindFirstChild("Anim") or script:FindFirstChild("Animation")
	local animator = humanoid:FindFirstChild("Animator")
	local track

	if not (anim == nil or animator == nil) then
		track = animator:LoadAnimation(anim)
		maid:Add(track)
		track:Play()
		track:AdjustSpeed(Config.WINDUP_SPEED)
	end

	task.wait(Config.HIT_AT)

	if track ~= nil and track.IsPlaying then
		track:AdjustSpeed(1)
	end

	task.wait(Config.LOCK - Config.HIT_AT)

	if id ~= Headbutt.Id then
		return true
	end

	maid:Clean()
	return true
end

function Headbutt.Cancel(_)
	maid:Clean()
end

return Headbutt