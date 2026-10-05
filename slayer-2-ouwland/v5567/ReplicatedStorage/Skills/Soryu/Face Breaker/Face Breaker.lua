local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local FaceBreaker = {
	Id = 0
}
local faceBreakerStartup = script.FaceBreakerStartup
local skill_stand_still = skills.holder.skill_stand_still
local track = nil

function FaceBreaker.Hold(player)
	v:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = FaceBreaker.Id

	if track then
		track:Stop(0)
		track = nil
	end

	track = animator:LoadAnimation(faceBreakerStartup)
	track:Play(nil, nil, 2)
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	v:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_DASH_DURATION + 0.5)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
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
	v:Add(alignOrientationWithAttachment)
	v:Add(v2)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_DASH_DURATION + 0.5)
	DebrisModule:AddItem(v2, Config.MAX_DASH_DURATION + 0.5)
	local lastTime = nil
	v:Connect(RunService.PostSimulation, function()
		if FaceBreaker.Id ~= id then
			return
		end

		local v3 = (Platform_Handler.mousepos(Config.MOUSE_RANGE) - humanoidRootPart.Position) * createVector(1, 0, 1)

		if v3.Magnitude < 0.1 then
			return
		end

		local unit = v3.Unit
		alignOrientationWithAttachment.CFrame = CFrame.lookAt(
			humanoidRootPart.Position,
			humanoidRootPart.Position + unit
		)

		if lastTime then
			local v4 = os.clock() - lastTime
			local v5 = math.clamp(v4 / Config.DASH_RAMP_IN, 0, 1)
			local v6 = 1 - math.clamp(v4 / Config.DASH_DURATION, 0, 1)
			clone.LinearVelocity.VectorVelocity = unit * Config.DASH_SPEED * v5 * v6
		end
	end)
	task.wait(Config.STARTUP)

	if FaceBreaker.Id ~= id then
		return
	end

	if track then
		track:AdjustSpeed(0)
	end

	lastTime = os.clock()
end

function FaceBreaker.UnHold(p)
	FaceBreaker.Cancel(p)
	return true
end

function FaceBreaker.Cancel(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	if track then
		track:Stop(Config.DASH_ANIM_FADE)
		track = nil
	end

	v:Clean()
end

return FaceBreaker