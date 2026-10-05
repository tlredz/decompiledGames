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
local WarGaleWind = {
	Id = 0
}
local warGaleWind = script.WarGaleWind
local skill_stand_still = skills.holder.skill_stand_still

function WarGaleWind.Hold(player)
	v:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = WarGaleWind.Id
	local track = animator:LoadAnimation(warGaleWind)
	v:Add(track)
	track:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	v:Add(clone)
	DebrisModule:AddItem(clone, Config.CAST_DURATION + 0.5)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 80,
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
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.CAST_DURATION + 0.5)
	DebrisModule:AddItem(v2, Config.CAST_DURATION + 0.5)
	v:Connect(RunService.PostSimulation, function()
		if WarGaleWind.Id ~= id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	task.wait(Config.WINDUP)
end

function WarGaleWind.UnHold(p)
	local id = WarGaleWind.Id
	task.wait(Config.CAST_DURATION - Config.WINDUP)

	if WarGaleWind.Id == id then
		WarGaleWind.Cancel(p)
	end

	return true
end

function WarGaleWind.Cancel(_)
	v:Clean()
end

return WarGaleWind