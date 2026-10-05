local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local Config = require(script.Parent.Config)
local TantoDescent = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local throw = script.Throw
local track = nil

function TantoDescent.Hold(player)
	v:Clean()
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = TantoDescent.Id
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	v:Add(clone)
	local mousepos = Platform_Handler.mousepos()
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z),
			rootPart.CFrame
		)
	})
	v:Add(v2)
	v:Add(alignOrientationWithAttachment)
	local v3 = SkillAimMarker.new({
		Dot = {
			Color = Config.AIM_COLOR
		},
		Highlight = {
			FillColor = Config.AIM_COLOR,
			OutlineColor = Config.AIM_COLOR
		}
	})
	v:Add(v3)
	v:Connect(RunService.PostSimulation, function()
		if id ~= TantoDescent.Id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos2.X, rootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
		local maximizeRayClient, _, _, target = RaycastHelper.MaximizeRayClient(
			rootPart.Position,
			mousepos2,
			Config.AIM_RANGE,
			true,
			Config.SPHERECAST_RADIUS,
			Config.DOWNCAST
		)
		v3:Update({
			position = maximizeRayClient,
			target = target
		})
	end)
	track = animator:LoadAnimation(throw)
	track:Play()
	task.wait(Config.THROW_FREEZE_AT)

	if id ~= TantoDescent.Id then
		return
	end

	if track then
		track:AdjustSpeed(0)
	end
end

function TantoDescent.UnHold(_)
	v:Clean()

	if track then
		if track.TimePosition < Config.THROW_FREEZE_AT then
			track.TimePosition = Config.THROW_FREEZE_AT
		end

		track:AdjustSpeed(1)
	end

	return true
end

function TantoDescent.Cancel(_)
	v:Clean()

	if track then
		track:Stop()
	end
end

return TantoDescent