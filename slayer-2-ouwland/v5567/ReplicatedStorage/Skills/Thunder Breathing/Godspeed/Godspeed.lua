local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage3.Packages.cleanit).new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Godspeed = {
	Id = 0
}
local v = {}
local v2 = nil
local attachment = nil
local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopDecel()
	local v3 = thread
	thread = nil

	if v3 ~= nil and coroutine.status(v3) == "suspended" then
		task.cancel(v3)
	end

	if attachment ~= nil then
		attachment:Destroy()
		attachment = nil
	end
end

require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))

function Godspeed.Hold(player)
	if not player then
		return
	end

	local character = player.Character
	local id = Godspeed.Id
	stopDecel() -- equivalent call inferred; original call site unknown

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

	if not humanoidRootPart then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.HOLD_MAX_DUR)
	table.insert(v, boolValue)
	local attachment2 = Instance.new("Attachment", humanoidRootPart)
	attachment2.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment2
	linearVelocity.Name = "bp"
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	local v3 = Config.DASH_SPEED * gameSettings.skillDashForcePerSpeed
	linearVelocity.MaxAxesForce = Vector3.new(v3, 0, v3)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	maid:Add(boolValue)
	maid:Add(attachment2)
	maid:Add(linearVelocity)
	local X = mousepos.X
	linearVelocity.VectorVelocity = (vector.create(X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * 0
	linearVelocity.Parent = attachment2
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

	local function zeroAssembly()
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	maid:Add(zeroAssembly)
	v2 = {
		Attachment = attachment2,
		Mover = linearVelocity,
		Zero = zeroAssembly
	}
	maid:Add(task.spawn(function()
		while attachment2 ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment2.Parent == humanoidRootPart and linearVelocity.Parent == attachment2 and attachment2.Name == "skill_stand_still" and v4:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil and id == Godspeed.Id do
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			linearVelocity.VectorVelocity = (vector.create(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * Config.DASH_SPEED
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end))
end

function Godspeed.UnHold(_)
	local v3 = v2
	v2 = nil

	if v3 == nil or v3.Attachment.Parent == nil or v3.Mover.Parent == nil then
		maid:Clean()
		return
	end

	v3.Attachment.Name = "skill_stand_still_released"
	maid:Remove(v3.Attachment)
	maid:Remove(v3.Zero)
	maid:Clean()
	TweenService:Create(v3.Mover, TweenInfo.new(Config.DASH_DECEL_TIME), {
		VectorVelocity = createVector(0, 0, 0)
	}):Play()
	attachment = v3.Attachment
	thread = task.delay(Config.DASH_DECEL_TIME, function()
		thread = nil
		stopDecel() -- equivalent call inferred; original call site unknown
		v3.Zero()
	end)
end

function Godspeed.Cancel(_)
	v2 = nil
	stopDecel() -- equivalent call inferred; original call site unknown
	maid:Clean()
end

return Godspeed