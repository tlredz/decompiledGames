local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Config = require(script.Parent.Config)
local ShellshockFrenzy = {
	Id = 0
}
local shellshockFrenzyLoop = script.ShellshockFrenzyLoop
local shellshockFrenzyFollowup = script.ShellshockFrenzyFollowup
local skill_stand_still = skills.holder.skill_stand_still

function ShellshockFrenzy.Hold(player)
	maid:Clean()
	local track = player.Character.Humanoid.Animator:LoadAnimation(shellshockFrenzyLoop)
	maid:Add(track)
	track:Play()
	task.wait(0.1)
end

function ShellshockFrenzy.UnHold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character.Humanoid
	local animator = humanoid.Animator
	local humanoidRootPart = character.HumanoidRootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = ShellshockFrenzy.Id
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local v = humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil or humanoid.FloorMaterial == Enum.Material.Air or humanoid.FloorMaterial == nil
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = v and createVector(20000, 20000, 20000) or createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 1.35))
	local track = animator:LoadAnimation(shellshockFrenzyFollowup)
	maid:Add(track)
	track:Play()
	clone.LinearVelocity.VectorVelocity = -(humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit * Config.FLIP_BACK_SPEED
	task.wait(Config.FLIP_BACK_DURATION)

	if ShellshockFrenzy.Id ~= id then
		return
	end

	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	task.wait(1.35 - Config.FLIP_BACK_DURATION)

	if ShellshockFrenzy.Id ~= id then
		return
	end

	maid:Clean()
end

function ShellshockFrenzy.Cancel(_)
	maid:Clean()
end

return ShellshockFrenzy