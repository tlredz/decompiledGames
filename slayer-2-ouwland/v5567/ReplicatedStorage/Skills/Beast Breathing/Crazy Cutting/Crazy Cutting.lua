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
local CrazyCutting = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local startup = script.Startup
local idle = script.Idle

function CrazyCutting.Hold(player, vector: Vector3)
	v:Clean()
	local id = CrazyCutting.Id
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if animator == nil or humanoidRootPart == nil then
		return
	end

	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_HOLD + 0.2)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, vector, humanoidRootPart.CFrame)
		}
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v2)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_HOLD + 0.2)
	DebrisModule:AddItem(v2, Config.MAX_HOLD + 0.2)
	v:Connect(RunService.PostSimulation, function()
		if CrazyCutting.Id ~= id then
			return
		end

		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Platform_Handler.mousepos(),
			alignOrientationWithAttachment.CFrame
		)
	end)
	local track = animator:LoadAnimation(startup)
	v:Add(track)
	track:Play()
	task.wait(Config.STARTUP)

	if CrazyCutting.Id ~= id then
		return
	end

	track:Stop()
	local track2 = animator:LoadAnimation(idle)
	track2.Looped = true
	v:Add(track2)
	track2:Play()
end

function CrazyCutting.UnHold(_)
	v:Clean()
	return true
end

function CrazyCutting.Counter(_, _: Vector3, _)
	v:Clean()
end

function CrazyCutting.Cancel(_)
	v:Clean()
end

return CrazyCutting