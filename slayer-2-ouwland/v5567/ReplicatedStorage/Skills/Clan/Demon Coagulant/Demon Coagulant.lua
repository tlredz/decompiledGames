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
local DemonCoagulant = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")

function DemonCoagulant.Hold(player)
	if player == nil then
		return false
	end

	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	maid:Clean()
	local id = DemonCoagulant.Id
	local ANIM_DURATION = Config.ANIM_DURATION
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, ANIM_DURATION)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", ANIM_DURATION))
	task.wait(ANIM_DURATION)

	if id ~= DemonCoagulant.Id then
		return true
	end

	maid:Clean()
	return true
end

function DemonCoagulant.Cancel(_)
	maid:Clean()
end

return DemonCoagulant