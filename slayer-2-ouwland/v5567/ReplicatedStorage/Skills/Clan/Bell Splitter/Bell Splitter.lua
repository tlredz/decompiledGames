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
local BellSplitter = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local stance = script:FindFirstChild("Stance") or script:FindFirstChild("Animation") or script.Stance

function BellSplitter.Hold(player, vector2: Vector3)
	v:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if animator == nil or humanoidRootPart == nil then
		return
	end

	local id = BellSplitter.Id
	local track = animator:LoadAnimation(stance)
	track.Looped = true
	v:Add(track)
	track:Play()
	local clone = skill_stand_still:Clone()
	v:Add(clone)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	DebrisModule:AddItem(clone, Config.MAX_DURATION + 0.2)
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
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_DURATION + 0.2)
	DebrisModule:AddItem(v2, Config.MAX_DURATION + 0.2)
	v:Connect(RunService.PostSimulation, function()
		if BellSplitter.Id ~= id then
			return
		end

		vector2 = Platform_Handler.mousepos()
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			vector2,
			alignOrientationWithAttachment.CFrame
		)
	end)
	task.wait(Config.STARTUP_BLOCK)
end

function BellSplitter.UnHold(_)
	v:Clean()
	return true
end

function BellSplitter.Counter(_, _: Vector3, _)
	v:Clean()
end

function BellSplitter.Cancel(_)
	v:Clean()
end

return BellSplitter