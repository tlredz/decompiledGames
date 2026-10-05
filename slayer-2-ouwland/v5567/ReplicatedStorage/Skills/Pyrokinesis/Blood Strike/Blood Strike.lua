local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage2.Packages.cleanit)
local Utility = require(global.Utility)
require(CAM.DebrisModule)
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local Config = require(script.Parent.Config)
local maid = cleanit.new()
local track = nil
local BloodStrike = {}
BloodStrike.Id = 0

function BloodStrike.Hold(player)
	maid:Clean()

	if track then
		track:Stop()
		track:Destroy()
		track = nil
	end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.BloodStrike)
	track:Play(0.2)
	maid:Add(task.delay(Config.STARTUP_DUR, function()
		local v = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
		v.Parent = rootPart
		local linearVelocity = v.LinearVelocity
		vfxUtility.TweenFOV(0.9, 60)
		local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
			rootPart,
			"skill_look_at",
			{
				AlignType = Enum.AlignType.PrimaryAxisParallel,
				Responsiveness = 75,
				MaxTorque = 3000,
				CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
			}
		)
		maid:Add(v2)
		maid:Add(RunService.PostSimulation:Connect(function(_: number)
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				rootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.DASH_SPEED * createVector(1, 0, 1)
		end))
	end))
end

function BloodStrike.UnHold(player)
	local character = player.Character
	Utility.getvaluesfolder(character)
	local humanoid = character:FindFirstChild("Humanoid")
	humanoid.RootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

	if track then
		track.TimePosition = Config.RELEASE_ANIM_SKIP_TO
		track:Destroy()
		track = nil
	end

	maid:Clean()
	vfxUtility.TweenFOV(0.1, 90)
	task.delay(1, function()
		vfxUtility.TweenFOV(1, 70)
	end)
end

function BloodStrike.Cancel(player)
	local rootPart = player.Character:FindFirstChild("Humanoid").RootPart
	maid:Clean()

	if track then
		track:Stop()
		track:Destroy()
		track = nil
	end

	rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	vfxUtility.TweenFOV(1, 70)
end

return BloodStrike