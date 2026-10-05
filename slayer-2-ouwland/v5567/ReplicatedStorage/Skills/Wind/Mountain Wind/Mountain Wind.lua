local createVector = vector.create
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
local MountainWind = {
	Id = 0
}
local v2 = nil
local v3 = nil
local clone = nil
local track = nil

function MountainWind.Hold(player)
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
	local id = MountainWind.Id
	local animator = humanoid:FindFirstChild("Animator")

	if animator then
		track = animator:LoadAnimation(script.Startup)
		track:Play(nil, nil, Config.STARTUP_ANIM_SPEED)
	end

	task.wait(Config.STARTUP_PAUSE_AT)

	if id ~= MountainWind.Id then
		return
	end

	if track then
		track:AdjustSpeed(0)
	end
end

function MountainWind.UnHold(_)
	v:Clean()

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

	if track then
		if track.TimePosition < Config.STARTUP_PAUSE_AT then
			track.TimePosition = Config.STARTUP_PAUSE_AT
		end

		track:AdjustSpeed(1)
	end
end

function MountainWind.Cancel(player)
	v:Clean()

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

	if track then
		track:Stop()
		track:Destroy()
		track = nil
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

return MountainWind