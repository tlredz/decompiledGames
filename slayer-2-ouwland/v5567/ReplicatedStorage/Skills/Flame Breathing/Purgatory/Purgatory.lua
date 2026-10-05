local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local Purgatory = {
	Id = 0
}
local v = {}
local track = nil

function Purgatory.Hold(player)
	local id = Purgatory.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	local id2 = Purgatory.Id
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = gameSettings.skillStandStillForce
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.HOLD_NR_DURATION)
	table.insert(v, boolValue)
	table.insert(v, attachment)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	table.insert(v, v2)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and id == Purgatory.Id do
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end)
	track = humanoid.Animator:LoadAnimation(script.Startup)
	track:Play(nil, nil, Config.STARTUP_ANIM_SPEED)
	task.delay(Config.HOLD_FREEZE_AT, function()
		if Purgatory.Id == id2 then
			track:AdjustSpeed(0)
		end
	end)
end

function Purgatory.UnHold(_)
	if track then
		if track.TimePosition <= Config.HOLD_FREEZE_AT then
			track.TimePosition = Config.HOLD_FREEZE_AT
		end

		track:AdjustSpeed(1)
		track = nil
	end

	for _, v2 in pairs(v) do
		v2:Destroy()
	end
end

function Purgatory.Cancel(_)
	if track then
		track:Stop()
		track = nil
	end

	for _, v2 in pairs(v) do
		v2:Destroy()
	end
end

return Purgatory