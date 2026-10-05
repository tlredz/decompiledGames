local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local _ = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Config = require(script.Parent.Config)
local CompassNeedle = {
	Id = 0
}
local v2 = {
	mover = nil,
	startupTrack = nil,
	loopTrack = nil,
	hitTrack = nil
}
local skill_stand_still = skills.holder.skill_stand_still
local compassNeedleStartup = script.CompassNeedleStartup
local compassNeedleLoop = script.CompassNeedleLoop
local compassNeedleHit = script.CompassNeedleHit

function CompassNeedle.Hold(player, vector2: Vector3)
	v:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid:FindFirstChild("Animator")
	local id = CompassNeedle.Id
	v2.startupTrack = animator:LoadAnimation(compassNeedleStartup)
	v:Add(v2.startupTrack)
	v2.startupTrack:Play()
	local clone = skill_stand_still:Clone()
	v:Add(clone)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, vector2, humanoidRootPart.CFrame)
		}
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v3)
	v:Connect(RunService.PostSimulation, function()
		vector2 = Platform_Handler.mousepos()
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			vector2,
			alignOrientationWithAttachment.CFrame
		)
	end)
	task.delay(1.13, function()
		if not (id == CompassNeedle.Id and clone.Parent ~= nil) then
			return
		end

		v2.startupTrack:Stop()
		v2.loopTrack = animator:LoadAnimation(compassNeedleLoop)
		v:Add(v2.loopTrack)
		v2.loopTrack:Play()
	end)
end

function CompassNeedle.UnHold(p)
	CompassNeedle.Cancel(p)
end

function CompassNeedle.Cancel(_)
	v:Clean()
end

function CompassNeedle.Counter(player, _: Vector3, instance)
	v:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid:FindFirstChild("Animator")
	local position = instance:GetPivot().Position

	if (position - humanoidRootPart.Position).Magnitude > 0.01 then
		humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, position)
	end

	local id = CompassNeedle.Id
	v2.hitTrack = animator:LoadAnimation(compassNeedleHit)
	v2.hitTrack:Play()
	task.delay(Config.COUNTER_ANIM_LENGTH, function()
		if id ~= CompassNeedle.Id then
			return
		end

		CompassNeedle.Cancel(player)
	end)
end

return CompassNeedle