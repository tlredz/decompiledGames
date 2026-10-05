local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local Config = require(script.Parent.Config)
local TriClawReversal = {
	Id = 0
}
local track = nil
local v2 = nil
local v3 = nil
local clone = nil
local v4 = Config.SETUP_DELAY + Config.PHASE_GAP

-- equivalent calls inferred from this helper; original call sites unknown
local function clearAim()
	v:Clean()

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	if v3 then
		v3:Destroy()
		v3 = nil
	end
end

local getvaluesfolder = Utility.getvaluesfolder(Players.LocalPlayer, true)

function TriClawReversal.Hold(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local id = TriClawReversal.Id
	clearAim() -- equivalent call inferred; original call site unknown

	if clone then
		clone:Destroy()
		clone = nil
	end

	if track then
		track:Stop()
		track = nil
	end

	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	local mousepos = Platform_Handler.mousepos(500)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v5 = {
		AlignType = Enum.AlignType.AllAxes,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = humanoidRootPart.Position
	local X = mousepos.X
	v5.CFrame = safeLookAt(position, Vector3.new(X, humanoidRootPart.Position.Y, mousepos.Z), humanoidRootPart.CFrame)
	v2, v3 = createAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", v5)
	DebrisModule:AddItem(v3, 6)
	v:Connect(RunService.Heartbeat, function()
		if not v2 or humanoidRootPart.Parent == nil then
			return
		end

		mousepos = Platform_Handler.mousepos(500)
		v2.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			v2.CFrame
		)
	end)
	track = humanoid.Animator:LoadAnimation(script.start_up)
	track:Play()
	task.delay(0.016666666666666666, function()
		if id ~= TriClawReversal.Id then
			return
		end

		if track then
			track:AdjustSpeed(0)
		end
	end)
end

function TriClawReversal.UnHold(player)
	if not (player and player.Character) then
		return
	end

	Utility.AddValue(getvaluesfolder, "NOMouvementlines", 0.4)

	if track then
		track:AdjustSpeed(1)
	end

	local id = TriClawReversal.Id

	if clone then
		clone:Destroy()
		clone = nil
	end

	task.delay(v4, function()
		if id ~= TriClawReversal.Id then
			return
		end

		clearAim() -- equivalent call inferred; original call site unknown
	end)
	task.wait(0.5833333333333334)

	if id ~= TriClawReversal.Id then
		return
	end

	clearAim() -- equivalent call inferred; original call site unknown
end

function TriClawReversal.Cancel(_)
	clearAim() -- equivalent call inferred; original call site unknown

	if clone then
		clone:Destroy()
		clone = nil
	end

	if track then
		track:Stop()
		track = nil
	end
end

return TriClawReversal