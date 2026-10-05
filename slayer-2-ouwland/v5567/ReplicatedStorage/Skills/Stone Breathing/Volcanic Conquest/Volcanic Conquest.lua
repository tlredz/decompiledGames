local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
require(global.Subsets.Gameplay.ManuelCancel)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(global.Utility)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local VolcanicConquest = {
	Id = 0
}
local v2 = {}

function VolcanicConquest.Hold(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	local track = animator:LoadAnimation(script.User)
	track:Play()
	v2.User_Animation = track
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	v:Add(v3)
	alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
		rootPart.Position,
		mousepos,
		alignOrientationWithAttachment.CFrame
	)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	DebrisModule:AddItem(clone, Config.MOVER_LIFETIME)
	v2.mover = clone
	local linearVelocity = clone.LinearVelocity
	local _ = VolcanicConquest.Id
	linearVelocity.VectorVelocity = rootPart.CFrame.LookVector
	v:Connect(RunService.Heartbeat, function(_: number)
		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			mousepos2,
			alignOrientationWithAttachment.CFrame
		)
		linearVelocity.VectorVelocity = linearVelocity.VectorVelocity:Lerp(
			rootPart.CFrame.LookVector * Config.DRIVE_SPEED * createVector(1, 0, 1),
			0.2
		)
	end)
end

function VolcanicConquest.UnHold(_)
	v:Clean()

	if v2.User_Animation then
		v2.User_Animation:Stop()
		v2.User_Animation:Destroy()
	end

	if v2.mover then
		v2.mover:Destroy()
		v2.mover = nil
	end
end

function VolcanicConquest.Cancel(player)
	v:Clean()

	if v2.User_Animation then
		v2.User_Animation:Stop()
		v2.User_Animation:Destroy()
	end

	if v2.mover then
		v2.mover:Destroy()
		v2.mover = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return
	end

	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return VolcanicConquest