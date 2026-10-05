local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Utility = require(CAM.Global.Utility)
local Config = require(script.Parent.Config)
local FreezingCloud = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local freezingCloudStartup = script.FreezingCloudStartup
local freezingCloudLoop = script.FreezingCloudLoop

function FreezingCloud.Hold(player)
	maid:Clean()
	local id = FreezingCloud.Id
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local track = animator:LoadAnimation(freezingCloudStartup)
	maid:Add(track)
	track:Play()
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_DASH_DURATION))
	task.wait(Config.STARTUP_TO_DASH)

	if FreezingCloud.Id ~= id then
		return
	end

	local track2 = animator:LoadAnimation(freezingCloudLoop)
	maid:Add(track2)
	track2:Play()
	track2:AdjustSpeed(1.05)
	local clone = skill_stand_still:Clone()
	maid:Add(clone)
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(rootPart.Position, Platform_Handler.mousepos(Config.MOUSE_RANGE), rootPart.CFrame)
	})
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v)
	maid:Connect(RunService.PostSimulation, function()
		if FreezingCloud.Id ~= id then
			return
		end

		local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		local cframe = CFrame.new(rootPart.Position, mousepos)
		alignOrientationWithAttachment.CFrame = cframe
		clone.LinearVelocity.VectorVelocity = cframe.LookVector * Config.DASH_SPEED
	end)
end

function FreezingCloud.UnHold(_)
	maid:Clean()
end

function FreezingCloud.Cancel(_)
	maid:Clean()
end

return FreezingCloud