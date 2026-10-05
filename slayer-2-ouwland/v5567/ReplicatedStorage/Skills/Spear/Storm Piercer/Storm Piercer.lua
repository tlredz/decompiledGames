local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local StormPiercer = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local startup = script.Startup
local loop = script.Loop

function StormPiercer.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = StormPiercer.Id
	local track = animator:LoadAnimation(startup)
	maid:Add(track)
	track:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_DASH_DURATION + 0.5)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = Config.STEER_RESPONSIVENESS,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				humanoidRootPart.CFrame
			)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_DASH_DURATION + 0.5)
	DebrisModule:AddItem(v, Config.MAX_DASH_DURATION + 0.5)
	local flag = false
	maid:Connect(RunService.PostSimulation, function()
		if StormPiercer.Id ~= id then
			return
		end

		local v2 = (Platform_Handler.mousepos(Config.MOUSE_RANGE) - humanoidRootPart.Position) * createVector(1, 0, 1)

		if v2.Magnitude < 0.1 then
			return
		end

		local unit = v2.Unit
		alignOrientationWithAttachment.CFrame = CFrame.lookAt(
			humanoidRootPart.Position,
			humanoidRootPart.Position + unit
		)

		if flag then
			clone.LinearVelocity.VectorVelocity = unit * Config.DASH_SPEED
		end
	end)
	task.wait(Config.STARTUP_AT)

	if StormPiercer.Id ~= id then
		return
	end

	flag = true
	local track2 = animator:LoadAnimation(loop)
	track2.Looped = true
	maid:Add(track2)
	track2:Play()
	task.wait(0.1)
end

function StormPiercer.UnHold(player)
	maid:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return true
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = StormPiercer.Id
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local lookVector = humanoidRootPart.CFrame.LookVector
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = lookVector * Config.GLIDE_SPEED
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.SLAM_AT + Config.ENDLAG + 0.5)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.SLAM_AT + Config.ENDLAG))
	local lastTime = os.clock()
	maid:Connect(RunService.PostSimulation, function()
		local v = (os.clock() - lastTime) / Config.GLIDE_DURATION
		clone.LinearVelocity.VectorVelocity = v >= 1 and createVector(0, 0, 0) or lookVector * Config.GLIDE_SPEED * (1 - v)
	end)
	task.wait(Config.SLAM_AT + Config.ENDLAG)

	if StormPiercer.Id ~= id then
		return
	end

	maid:Clean()
end

function StormPiercer.Cancel(_)
	maid:Clean()
end

return StormPiercer