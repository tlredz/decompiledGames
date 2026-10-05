local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local ColdWhitePrincesses = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local coldWhitePrincessesStartup = script.ColdWhitePrincessesStartup
local coldWhitePrincessesLoop = script.ColdWhitePrincessesLoop
local coldWhitePrincessesUser = script.ColdWhitePrincessesUser

function ColdWhitePrincesses.Hold(player, vector2: Vector3)
	v:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid:FindFirstChild("Animator")
	local id = ColdWhitePrincesses.Id
	local track = animator:LoadAnimation(coldWhitePrincessesStartup)
	v:Add(track)
	track:Play()
	local clone = skill_stand_still:Clone()
	v:Add(clone)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, vector2, humanoidRootPart.CFrame)
		}
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v2)
	v:Connect(RunService.PostSimulation, function()
		vector2 = Platform_Handler.mousepos()
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			vector2,
			alignOrientationWithAttachment.CFrame
		)
	end)
	task.wait(Config.STARTUP_FREEZE_TIME)

	if ColdWhitePrincesses.Id ~= id then
		return
	end

	local track2 = animator:LoadAnimation(coldWhitePrincessesLoop)
	v:Add(track2)
	track2:Play()
end

function ColdWhitePrincesses.UnHold(p)
	ColdWhitePrincesses.Cancel(p)
end

function ColdWhitePrincesses.Counter(player, _: Vector3, instance)
	v:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid:FindFirstChild("Animator")
	local position = instance:GetPivot().Position

	if (position - humanoidRootPart.Position).Magnitude > 0.01 then
		humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, position)
	end

	local track = animator:LoadAnimation(coldWhitePrincessesUser)
	v:Add(track)
	track:Play()
	task.wait(Config.FLOWERS_LOCK_DURATION)
	ColdWhitePrincesses.Cancel(player)
end

function ColdWhitePrincesses.Cancel(_)
	v:Clean()
end

return ColdWhitePrincesses