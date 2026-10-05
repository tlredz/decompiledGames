local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local ExplosiveFury = {
	Id = 0
}
local v = {
	startupTrack = nil,
	loopTrack = nil,
	furyTrack = nil
}
local skill_stand_still = skills.holder.skill_stand_still
local explosiveFuryStart = script.ExplosiveFuryStart
local explosiveFuryLoop = script.ExplosiveFuryLoop
local explosiveFuryHit = script.ExplosiveFuryHit

function ExplosiveFury.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid:FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = ExplosiveFury.Id
	v.startupTrack = animator:LoadAnimation(explosiveFuryStart)
	maid:Add(v.startupTrack)
	v.startupTrack:Play()
	v.startupTrack:AdjustSpeed(Config.DASH_START_ANIM_SPEED)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 6))
	local clone = skill_stand_still:Clone()
	maid:Add(clone)
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(Config.MOUSE_RANGE),
				humanoidRootPart.CFrame
			)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v2)
	task.delay(Config.DASH_STARTUP_DURATION, function()
		if ExplosiveFury.Id ~= id or (clone.Parent == nil or humanoidRootPart.Parent == nil) then
			return
		end

		v.startupTrack:Stop()
		v.loopTrack = animator:LoadAnimation(explosiveFuryLoop)
		maid:Add(v.loopTrack)
		v.loopTrack:Play()
		maid:Connect(RunService.PostSimulation, function()
			if id ~= ExplosiveFury.Id then
				return
			end

			local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			local cframe = CFrame.new(humanoidRootPart.Position, mousepos)
			alignOrientationWithAttachment.CFrame = cframe
			clone.LinearVelocity.VectorVelocity = cframe.LookVector * Config.DASH_SPEED
		end)
	end)
end

function ExplosiveFury.UnHold(player)
	maid:Clean()
	local character = player.Character
	local animator = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = ExplosiveFury.Id
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 3))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 3))
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(Config.MOUSE_RANGE),
				humanoidRootPart.CFrame
			)
		}
	)
	maid:Add(v2)
	maid:Connect(RunService.PostSimulation, function()
		if ExplosiveFury.Id ~= id then
			return
		end

		local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	local v3, v4 = ManuelCancel.new(player, 3)
	v3:Connect(function()
		ExplosiveFury.Id = -1
		ExplosiveFury.Cancel(player)
	end)
	v.hitTrack = animator:LoadAnimation(explosiveFuryHit)
	maid:Add(v.hitTrack)
	v.hitTrack:Play()
	task.wait(1.75)

	if ExplosiveFury.Id ~= id then
		return
	end

	v4()
	ExplosiveFury.Cancel(player)
end

function ExplosiveFury.Cancel(_)
	maid:Clean()
end

return ExplosiveFury