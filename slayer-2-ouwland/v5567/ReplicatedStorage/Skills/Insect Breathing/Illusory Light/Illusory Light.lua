local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage2.Packages.cleanit).new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Config = require(script.Parent.Config)
local IllusoryLight = {
	Id = 0
}
local v = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

function IllusoryLight.Hold(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid:FindFirstChild("Animator")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local id = IllusoryLight.Id
	maid:Add(animator:LoadAnimation(script.Startup), "Stop"):Play()
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v.mover = clone
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 80,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v2)
	maid:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	task.wait(Config.STARTUP_DUR)

	if id ~= IllusoryLight.Id then
		return
	end

	maid:Add(animator:LoadAnimation(script.Hold), "Stop"):Play()
end

function IllusoryLight.UnHold(player)
	if v.mover then
		DebrisModule:AddItem(v.mover, Config.RELEASE_DELAY)
		v.mover = nil
	end

	maid:Clean()

	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid:FindFirstChild("Animator")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local _ = IllusoryLight.Id
	local v2 = maid:Add(animator:LoadAnimation(script.Release), "Stop")
	v2:Play()
	v2.Priority = Enum.AnimationPriority.Action2
	task.wait(Config.RELEASE_DELAY)
end

function IllusoryLight.Cancel(_)
	if v.mover ~= nil then
		v.mover:Destroy()
		v.mover = nil
	end

	maid:Clean()
end

return IllusoryLight