local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require(ReplicatedStorage3.Packages.cleanit).new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local CombatMode = require(ReplicatedStorage2.CAM.Global.CombatMode)
local Config = require(script.Parent.Config)
local Roar = {
	Id = 0
}
local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local v2 = nil
local v3 = nil
local clone = nil
local track = nil

function Roar.Hold(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local id = Roar.Id
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v4 = {
		AlignType = Enum.AlignType.AllAxes,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = humanoidRootPart.Position
	local X = mousepos.X
	v4.CFrame = safeLookAt(position, Vector3.new(X, humanoidRootPart.Position.Y, mousepos.Z), humanoidRootPart.CFrame)
	v2, v3 = createAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", v4)
	DebrisModule:AddItem(v3, 6)
	v:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		v2.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			v2.CFrame
		)
	end)
	track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.Anim)
	track:Play()
	task.delay(Config.ANIM_FREEZE_AT, function()
		if id ~= Roar.Id then
			return
		end

		track:AdjustSpeed(0)
	end)
end

function Roar.UnHold(player)
	if not player then
		return
	end

	local character = player.Character

	if not (character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)) then
		return
	end

	local v4 = not CombatMode.InPvPMode(player) and 0 or Config.PVP_WINDUP
	local v5 = track

	if v5.TimePosition < Config.ANIM_FREEZE_AT then
		v5.TimePosition = Config.ANIM_FREEZE_AT
	end

	v5:AdjustSpeed(Config.BLAST_AT / (Config.BLAST_AT + v4))
	Utility.AddValue(getvaluesfolder, "NR", Config.ENDLAG + v4)
	v:Clean()

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	local id = Roar.Id

	if v4 > 0 then
		task.delay(Config.BLAST_AT + v4, function()
			if id ~= Roar.Id then
				return
			end

			v5:AdjustSpeed(1)
		end)
	end

	task.wait(Config.ENDLAG + v4)

	if id ~= Roar.Id then
		return
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end
end

function Roar.Cancel(player)
	v:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return Roar