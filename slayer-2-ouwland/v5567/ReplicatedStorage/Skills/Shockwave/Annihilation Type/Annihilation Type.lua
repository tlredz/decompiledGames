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
local Config = require(script.Parent.Config)
local AnnihilationType = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local annihilationTypeStart = script.AnnihilationTypeStart
local annihilationTypeLoop = script.AnnihilationTypeLoop

function AnnihilationType.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = AnnihilationType.Id
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 3))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 3))
	local track = animator:LoadAnimation(annihilationTypeStart)
	maid:Add(track)
	track:Play()
	local clone = skill_stand_still:Clone()
	maid:Add(clone)
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	maid:Add(Utility.AddValue(getvaluesfolder, "NOMouvementlines", 7))
	maid:Add(function()
		rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		rootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end)
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(rootPart.Position, Platform_Handler.mousepos(Config.MOUSE_RANGE), rootPart.CFrame)
	})
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v)
	task.wait(Config.STARTUP_LOOP_DURATION)

	if id ~= AnnihilationType.Id then
		return
	end

	local track2 = animator:LoadAnimation(annihilationTypeLoop)
	maid:Add(track2)
	track2:Play()
	maid:Connect(RunService.PostSimulation, function()
		if id ~= AnnihilationType.Id then
			return
		end

		local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		local cframe = CFrame.new(rootPart.Position, mousepos)
		alignOrientationWithAttachment.CFrame = cframe
		clone.LinearVelocity.VectorVelocity = cframe.LookVector * Config.DASH_SPEED
	end)
end

function AnnihilationType.UnHold(p, _: Vector3?)
	AnnihilationType.Cancel(p)
end

function AnnihilationType.Cancel(_)
	maid:Clean()
end

return AnnihilationType