local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Utility = require(CAM.Global.Utility)
local Config = require(script.Parent.Config)
local maid = cleanit.new()

local function startAimRig(humanoidRootPart)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 75,
			MaxTorque = 3000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				humanoidRootPart.CFrame
			)
		}
	)
	maid:Add(v)
	maid:Add(RunService.PostSimulation:Connect(function()
		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end))
end

local FierySlash = {}
FierySlash.Id = 0

function FierySlash.Hold(player)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	maid:Clean()
	startAimRig(humanoidRootPart)
	humanoid.Animator:LoadAnimation(script.Startup):Play()
	task.wait(0.4)
end

function FierySlash.UnHold(_)
	maid:Clean()
end

function FierySlash.Cancel(_)
	maid:Clean()
end

return FierySlash