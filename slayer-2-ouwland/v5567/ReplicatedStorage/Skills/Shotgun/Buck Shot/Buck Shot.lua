local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local Config = require(script.Parent.Config)
local BuckShot = {
	Id = 0
}
local buckshotAttempt = script.BuckshotAttempt
local buckshotFollowup = script.BuckshotFollowup
local skill_stand_still = skills.holder.skill_stand_still
local v = nil

function BuckShot.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character.Humanoid
	local animator = humanoid.Animator
	local humanoidRootPart = character.HumanoidRootPart
	local id = BuckShot.Id
	v = nil
	ServerClientPortal.Link(script.Parent.Name):Connect(function(p: string)
		v = p
	end)
	local track = animator:LoadAnimation(buckshotAttempt)
	maid:Add(track)
	track:Play()
	local v2 = humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil or humanoid.FloorMaterial == Enum.Material.Air or humanoid.FloorMaterial == nil
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = v2 and createVector(20000, 20000, 20000) or createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				humanoidRootPart.CFrame
			)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v3)
	local flag = false
	maid:Connect(RunService.PostSimulation, function()
		if BuckShot.Id ~= id then
			return
		end

		local v4 = (Platform_Handler.mousepos(Config.MOUSE_RANGE) - humanoidRootPart.Position) * createVector(1, 0, 1)

		if v4.Magnitude < 0.1 then
			return
		end

		local unit = v4.Unit
		alignOrientationWithAttachment.CFrame = CFrame.lookAt(
			humanoidRootPart.Position,
			humanoidRootPart.Position + unit
		)

		if flag then
			clone.LinearVelocity.VectorVelocity = unit * Config.DASH_SPEED
		end
	end)
	task.wait(0.26666666666666666)

	if BuckShot.Id ~= id then
		return
	end

	flag = true
	task.wait(0.1)
end

function BuckShot.UnHold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character.Humanoid
	local animator = humanoid.Animator
	local humanoidRootPart = character.HumanoidRootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = BuckShot.Id
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local lastTime = os.clock()

	while v == nil and os.clock() - lastTime < Config.BRANCH_SIGNAL_TIMEOUT and BuckShot.Id == id do
		task.wait()
	end

	ServerClientPortal.Destroy(script.Parent.Name)

	if BuckShot.Id ~= id or v ~= "Hit" then
		return
	end

	local v2 = humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil or humanoid.FloorMaterial == Enum.Material.Air or humanoid.FloorMaterial == nil
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = v2 and createVector(20000, 20000, 20000) or createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 1.3))
	local track = animator:LoadAnimation(buckshotFollowup)
	maid:Add(track)
	track:Play()
	task.wait(1.3)

	if BuckShot.Id ~= id then
		return
	end

	maid:Clean()
end

function BuckShot.Cancel(_)
	ServerClientPortal.Destroy(script.Parent.Name)
	maid:Clean()
end

return BuckShot