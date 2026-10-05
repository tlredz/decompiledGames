local createVector = vector.create
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
local ManuelCancel = require(global:FindFirstChild("Subsets"):FindFirstChild("Gameplay"):FindFirstChild("ManuelCancel"))
local Config = require(script.Parent.Config)
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer, true)
local v = {}
local CompoundEyeHexagon = {
	Id = 0
}
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

function CompoundEyeHexagon.Hold(player)
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
	maid:Add(animator:LoadAnimation(script.Loop), "Stop"):Play()
end

function CompoundEyeHexagon.UnHold(player)
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

	local id = CompoundEyeHexagon.Id
	local v2, _ = ManuelCancel.new(character, Config.UNHOLD_CANCEL_WINDOW)
	v2:Connect(function()
		id = -1
		CompoundEyeHexagon.Cancel(player)
	end)
	maid:Add(animator:LoadAnimation(script.End), "Stop"):Play()
	task.wait(Config.DASH_START_AT)

	if id ~= CompoundEyeHexagon.Id then
		return
	end

	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.DASH_DURATION)
	local mover = v.mover
	mover.LinearVelocity.VectorVelocity = humanoidRootPart.CFrame.LookVector * Config.DASH_SPEED * createVector(1, 0, 1)
	DebrisModule:AddItem(mover, Config.DASH_DURATION)
	maid:Add(mover)
	task.delay(Config.DASH_DURATION, function()
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end)
end

function CompoundEyeHexagon.Cancel(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	maid:Clean()

	if v.mover then
		v.mover:Destroy()
		v.mover = nil

		if humanoidRootPart then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end
end

return CompoundEyeHexagon