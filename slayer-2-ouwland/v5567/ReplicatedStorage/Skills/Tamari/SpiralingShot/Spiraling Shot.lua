local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local ProjectileHoming = require(CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local SpiralingShot = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local spiralingShot = script.SpiralingShot

function SpiralingShot.Hold(player)
	v:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	v:Add(clone)
	local mousepos = Platform_Handler.mousepos()
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = CFrame.lookAt(rootPart.Position, (Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z)))
	})
	v:Add(v2)
	v:Add(alignOrientationWithAttachment)
	local v3 = SkillAimMarker.new({
		Dot = true,
		Highlight = {
			FillColor = Color3.fromRGB(220, 50, 50),
			OutlineColor = Color3.fromRGB(255, 120, 120)
		}
	})
	v:Add(v3)
	local lock = ProjectileHoming.NewLock({
		Script = script,
		Caster = character,
		Range = Config.AIM_RANGE,
		Radius = Config.SPHERECAST_RADIUS,
		Downcast = Config.DOWNCAST,
		Select = true
	})
	v:Connect(RunService.PostSimulation, function()
		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		local child = character:FindFirstChild(Config.POS_PART_NAME)

		if child then
			child.Position = mousepos2
			child.bp.Position = mousepos2
		end

		local target, v5 = lock:Update(rootPart.Position, mousepos2)
		local position = v5 or mousepos2
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(position.X, rootPart.Position.Y, position.Z),
			alignOrientationWithAttachment.CFrame
		)
		v3:Update({
			position = position,
			target = target
		})
	end)
	local track = animator:LoadAnimation(spiralingShot)
	v:Add(track)
	track:Play()
	task.wait(Config.LAUNCH_DELAY + 0.1)
end

function SpiralingShot.UnHold(p)
	SpiralingShot.Cancel(p)
end

function SpiralingShot.Cancel(_)
	v:Clean()
end

return SpiralingShot