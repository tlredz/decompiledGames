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
local WarChant = {
	Id = 0
}
local warChant = script.WarChant
local skill_stand_still = skills.holder.skill_stand_still

function WarChant.Hold(player, vector2: Vector3)
	v:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = WarChant.Id
	local track = animator:LoadAnimation(warChant)
	v:Add(track)
	track:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	v:Add(clone)
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
		if WarChant.Id ~= id then
			return
		end

		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Platform_Handler.mousepos(),
			alignOrientationWithAttachment.CFrame
		)
	end)
end

function WarChant.UnHold(p)
	WarChant.Cancel(p)
	return true
end

function WarChant.Cancel(_)
	v:Clean()
end

function WarChant.Counter(player, _: Vector3, instance)
	v:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not animator or not humanoidRootPart or instance == nil then
		return
	end

	humanoidRootPart.CFrame = Utility.SafeLookAt(
		humanoidRootPart.Position,
		instance:GetPivot().Position,
		humanoidRootPart.CFrame
	)
	local track = animator:LoadAnimation(warChant)
	v:Add(track)
	track:Play()
	task.wait(1)
	WarChant.Cancel(player)
end

return WarChant