local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Workspace")
local DoubleCut = {
	Id = 0
}
local _ = Vector3.new
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local track = nil
local _ = table.find
local _ = table.remove
game:GetService("TweenService")
TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local v = {}

local function clearDebree(duration: number)
	if duration ~= 0 then
		task.wait(duration)
	end

	for k, _ in pairs(v) do
		if not k then
			continue
		end

		pcall(k.Destroy, k)
		v[k] = nil
	end
end

local _ = os.clock

function DoubleCut.Hold(player)
	local _ = DoubleCut.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bv"
	linearVelocity.MaxForce = gameSettings.skillStandStillForce
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local mousepos = Platform_Handler.mousepos(Config.AIM_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 45,
			MaxTorque = 10000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	v[v2] = true
	v[attachment] = true
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			mousepos = Platform_Handler.mousepos(Config.AIM_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end)
	track = humanoid.Animator:LoadAnimation(script.start_up)
	track:Play()
	track:AdjustSpeed(1)
	task.wait(Config.HOLD_FREEZE_AT)
	track:AdjustSpeed(0)
end

function DoubleCut.UnHold(player)
	local _ = DoubleCut.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")

	if track then
		track:AdjustSpeed(1)
	end

	if humanoidRootPart:FindFirstChild("skill_look_at") ~= nil then
		local boolValue = Instance.new("BoolValue", humanoidRootPart:FindFirstChild("skill_look_at"))
		boolValue.Name = "Cancel"
	end

	task.wait(Config.RELEASE_ENDLAG)
	clearDebree(0.15)
end

function DoubleCut.Cancel(player)
	if track then
		track:Stop()
	end

	local _ = DoubleCut.Id
	local _ = player.Character

	for k, _ in pairs(v) do
		if not k then
			continue
		end

		pcall(k.Destroy, k)
		v[k] = nil
	end
end

return DoubleCut