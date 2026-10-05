local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Config = require(script.Parent.Config)
local PurifyingClaws = {
	Id = 0
}
local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local v2 = nil
local v3 = nil
local clone = nil
local track = nil

function PurifyingClaws.Hold(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local id = PurifyingClaws.Id
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
	v:Connect(RunService.Heartbeat, function()
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		v2.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			v2.CFrame
		)
	end)
	local animator = humanoid:FindFirstChild("Animator")

	if animator then
		track = animator:LoadAnimation(script.Anim)
		track:Play()
		task.delay(Config.HOLD_PAUSE_AT, function()
			if id ~= PurifyingClaws.Id then
				return
			end

			if track then
				track:AdjustSpeed(0)
			end
		end)
	end
end

function PurifyingClaws.UnHold(player)
	if not player then
		return
	end

	local character = player.Character

	if not (character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)) then
		return
	end

	local id = PurifyingClaws.Id

	if track then
		if track.TimePosition < Config.HOLD_PAUSE_AT then
			track.TimePosition = Config.HOLD_PAUSE_AT
		end

		track:AdjustSpeed(Config.SWING_ANIM_SPEED)
		task.delay(Config.HITBOX_DELAY, function()
			if id ~= PurifyingClaws.Id then
				return
			end

			if track then
				track:AdjustSpeed(1)
			end
		end)
	end

	Utility.AddValue(getvaluesfolder, "NR", Config.ENDLAG)
	v:Clean()

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	task.wait(Config.ENDLAG)

	if id ~= PurifyingClaws.Id then
		return
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end
end

function PurifyingClaws.Cancel(_)
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
end

return PurifyingClaws