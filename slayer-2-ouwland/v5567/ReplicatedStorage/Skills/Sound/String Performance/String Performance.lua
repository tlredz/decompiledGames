local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage2.Packages.cleanit).new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Combat_presets = require(global:WaitForChild("Combat_presets"))
local Config = require(script.Parent.Config)
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer, true)
local StringPerformance = {
	Id = 0
}
local new = Vector3.new
local boolValue = nil

function StringPerformance.Hold(player)
	if boolValue ~= nil then
		boolValue:Destroy()
		boolValue = nil
	end

	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local id = StringPerformance.Id

	if not (humanoidRootPart and humanoid and animator) then
		return
	end

	boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, 0.5)
	local getvaluesfolder2 = Utility.getvaluesfolder(character)
	Combat_presets.stop_extra_anims(humanoid)
	maid:Add(animator:LoadAnimation(script.Run), "Stop"):Play()
	local v = maid:Add(Instance.new("BoolValue"))
	v.Name = "NOMouvementlines"
	v.Parent = getvaluesfolder2
	DebrisModule:AddItem(v, 5)
	local v2 = maid:Add(Instance.new("Attachment", humanoidRootPart))
	v2.Name = "skill_stand_still"
	local v3 = maid:Add(Instance.new("LinearVelocity"))
	v3.Attachment0 = v2
	v3.Name = "bp"
	v3.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	v3.MaxAxesForce = createVector(10000, 0, 10000)
	v3.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	v3.VectorVelocity = (new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * 0
	v3.Parent = v2
	local alignOrientationWithAttachment, v4 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 1000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v4)
	task.spawn(function()
		while id == StringPerformance.Id and v2 ~= nil and humanoidRootPart and v3 ~= nil and v2.Parent == humanoidRootPart and v3.Parent == v2 and v2.Name == "skill_stand_still" and v4:FindFirstChild("Cancel") == nil and v3:FindFirstChild("Cancel") == nil do
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			v3.VectorVelocity = CFrame.new(
				humanoidRootPart.Position,
				(Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z))
			).LookVector * Config.RUN_SPEED
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end)
end

function StringPerformance.UnHold(_)
	if boolValue ~= nil then
		boolValue:Destroy()
		boolValue = nil
	end

	maid:Clean()
end

function StringPerformance.Cancel(_)
	maid:Clean()

	if boolValue ~= nil then
		boolValue:Destroy()
		boolValue = nil
	end
end

return StringPerformance