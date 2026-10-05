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
local v2 = {}
local v3 = Config.SLASHES_FIRST_AT + Config.SLASHES_SECOND_AT + Config.SLASHES_RECOVERY
local ReapingSlashes = {}
ReapingSlashes.Id = 0

function ReapingSlashes.Hold(player)
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
	local mousepos = Platform_Handler.mousepos(Config.SLASHES_MOUSE_RANGE)
	local alignOrientationWithAttachment, v4 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	v:Add(v4)
	alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
		rootPart.Position,
		mousepos,
		alignOrientationWithAttachment.CFrame
	)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	DebrisModule:AddItem(clone, 3)
	v2.mover = clone
	local linearVelocity = clone.LinearVelocity
	v2.startedAt = os.clock()
	linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.SLASHES_GLIDE_SPEED * createVector(1, 0, 1)
	v:Connect(RunService.Heartbeat, function(_: number)
		local mousepos2 = Platform_Handler.mousepos(Config.SLASHES_MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			mousepos2,
			alignOrientationWithAttachment.CFrame
		)
		linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.SLASHES_GLIDE_SPEED * createVector(1, 0, 1)
	end)
end

function ReapingSlashes.UnHold(player)
	if v2.startedAt then
		local v4 = v3 - (os.clock() - v2.startedAt)
		v2.startedAt = nil

		if v4 > 0 then
			task.wait(v4)
		end
	end

	v:Clean()

	if v2.User_Animation then
		v2.User_Animation:Stop()
		v2.User_Animation:Destroy()
		v2.User_Animation = nil
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

function ReapingSlashes.Cancel(player)
	v:Clean()
	v2.startedAt = nil

	if v2.User_Animation then
		v2.User_Animation:Stop()
		v2.User_Animation:Destroy()
		v2.User_Animation = nil
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

return ReapingSlashes