local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
ReplicatedStorage2:WaitForChild("CAM")
local CAM = ReplicatedStorage.CAM
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require(ReplicatedStorage3.Packages.cleanit).new()
local DebrisModule = require(CAM.DebrisModule)
local ThunderClapAndFlash = {
	Id = 0
}
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)
local clone = nil
local track = nil
local v2 = nil
local v3 = nil

function ThunderClapAndFlash.Hold(player, p)
	if not player then
		return
	end

	local character = player.Character
	local id = ThunderClapAndFlash.Id

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")
	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v2, v3 = Utility.CreateAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", {
		AlignType = Enum.AlignType.AllAxes,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(humanoidRootPart.Position, p, humanoidRootPart.CFrame)
	})
	v:Connect(RunService.Heartbeat, function(_: number)
		p = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		v2.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, p, v2.CFrame)
	end)
	track = animator:LoadAnimation(script.Dash)
	track:Play()
	task.delay(Config.ANIM_FREEZE_AT, function()
		if ThunderClapAndFlash.Id == id then
			track:AdjustSpeed(0)
		end
	end)
	task.wait(Config.STARTUP_DUR)
end

local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)

function ThunderClapAndFlash.UnHold(player, p)
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

	if track ~= nil then
		if track.TimePosition < Config.ANIM_FREEZE_AT then
			track.TimePosition = Config.ANIM_FREEZE_AT
		end

		track:AdjustSpeed(1)
		track = nil
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	v:Clean()
	local cFrame = humanoidRootPart.CFrame
	local normalized = vector.normalize(p - cFrame.Position)
	local position = cFrame.Position + normalized * Config.MAX_DISTANCE
	local raycastResult = workspace:Raycast(cFrame.Position, normalized * Config.MAX_DISTANCE, RaycastHelper.Crater)

	if raycastResult then
		position = raycastResult.Position + raycastResult.Normal * 2.5
	end

	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.ENDLAG + 0.1)
	Utility.AddValue(getvaluesfolder, "NR", Config.ENDLAG + 0.1)
	task.wait(0.1)
	local attachment = Instance.new("Attachment")
	attachment.Parent = humanoidRootPart
	DebrisModule:AddItem(attachment, Config.ENDLAG)

	if v3 ~= nil then
		DebrisModule:AddItem(v3, Config.ENDLAG)
		v3 = nil
	end

	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment
	alignPosition.Responsiveness = 75
	alignPosition.Position = position
	alignPosition.MaxForce = 20000
	alignPosition.Parent = attachment
	task.wait(Config.ENDLAG)

	if humanoidRootPart ~= nil then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

function ThunderClapAndFlash.Cancel(_)
	v:Clean()

	if track ~= nil then
		track:Stop()
		track = nil
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end
end

return ThunderClapAndFlash