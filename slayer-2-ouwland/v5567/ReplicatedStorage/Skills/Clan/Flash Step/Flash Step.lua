local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local global = CAM:WaitForChild("Global")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(global:WaitForChild("Utility"))
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local FlashStep = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local currentCamera = workspace.CurrentCamera

local function steer(humanoid)
	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude < Config.INPUT_DEADZONE then
		return createVector(0, 0, 0)
	end

	local lookVector = currentCamera.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude > 0 then
		vector2 = vector2.Unit
	end

	local dot = moveDirection:Dot(vector2)
	local v2 = moveDirection - vector2 * dot
	local v3 = lookVector * dot + v2

	if v3.Magnitude > 0 then
		return v3.Unit
	end

	return createVector(0, 0, 0)
end

local v2 = nil
local v3 = {}

local function endFlight()
	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	for _, v4 in v3 do
		if v4.Parent ~= nil then
			v4:Destroy()
		end
	end

	table.clear(v3)
end

function FlashStep.Hold(player)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	v:Clean()
	local id = FlashStep.Id
	endFlight()
	local attachment = Instance.new("Attachment")
	attachment.Name = "flash_step_mover"
	v2 = attachment
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.PrimaryTangentAxis = createVector(1, 0, 0)
	linearVelocity.SecondaryTangentAxis = createVector(0, 0, 1)
	linearVelocity.MaxForce = Config.MAX_FORCE

	-- equivalent calls inferred from this helper; original call sites unknown
	local function aim()
		local v4 = Platform_Handler.mousepos(Config.MOUSE_RANGE) - currentCamera.CFrame.Position

		if v4.Magnitude > 1 then
			return v4.Unit
		end

		return currentCamera.CFrame.LookVector
	end

	local v4 = aim() -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function drive(vector2: Vector3)
		local vector3 = Vector2.new(vector2.X, vector2.Z)
		local v5 = linearVelocity
		local planeVelocity

		if vector3.Magnitude > 0 then
			planeVelocity = vector3.Unit * Config.SPEED
		else
			planeVelocity = Vector2.zero
		end

		v5.PlaneVelocity = planeVelocity
	end

	local v5 = v4
	local vector2 = Vector2.new(v5.X, v5.Z)
	local planeVelocity2

	if vector2.Magnitude > 0 then
		planeVelocity2 = vector2.Unit * Config.SPEED
	else
		planeVelocity2 = Vector2.zero
	end

	linearVelocity.PlaneVelocity = planeVelocity2
	linearVelocity.Parent = attachment
	attachment.Parent = humanoidRootPart
	DebrisModule:AddItem(attachment, Config.MAX_HOLD + Config.ENDLAG)

	for _, v7 in { "NR", "NOMouvementlines", "NoFootStep" } do
		table.insert(v3, Utility.AddValue(getvaluesfolder, v7, Config.MAX_HOLD + Config.ENDLAG))
	end

	v:Connect(RunService.Heartbeat, function()
		if id ~= FlashStep.Id then
			return
		end

		local unit = steer(humanoid)

		if not (unit.Magnitude > 0) then
			local v7 = Platform_Handler.mousepos(Config.MOUSE_RANGE) - currentCamera.CFrame.Position

			if v7.Magnitude > 1 then
				unit = v7.Unit
			else
				unit = currentCamera.CFrame.LookVector
			end
		end

		v4 = unit
		local v7 = v4
		drive(v7) -- equivalent call inferred; original call site unknown

		if v7.Magnitude > 0 then
			local vector3 = Vector3.new(v7.X, 0, v7.Z)

			if vector3.Magnitude > 0.01 then
				humanoidRootPart.CFrame = CFrame.lookAt(
					humanoidRootPart.Position,
					humanoidRootPart.Position + vector3.Unit
				)
			end
		end
	end)
end

function FlashStep.UnHold(player)
	v:Clean()
	endFlight()
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	end

	task.wait(Config.ENDLAG)
	return false
end

function FlashStep.Cancel(player)
	v:Clean()
	endFlight()
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	end
end

return FlashStep