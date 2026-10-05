local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local ClimbBar = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.ClimbBar)
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local notification = ReplicatedStorage.Communication.CnC.Notifications.Notification
local v = {
	{
		Name = "Walk",
		Speed = 10,
		StaminaDrain = 0,
		Anim = "Walk"
	},
	{
		Name = "Gallop",
		Speed = 36,
		StaminaDrain = 1,
		Anim = "Gallop"
	},
	{
		Name = "Run",
		Speed = 54,
		StaminaDrain = 2,
		Anim = "Sprint"
	}
}
local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function equipCooldownLeft()
	return (math.max(v2 - os.clock(), 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stampEquipCooldown()
	v2 = os.clock() + gameSettings.horseEquipCooldown
end

local uDim = UDim2.fromScale(0.9, 0.25)
local vector2 = Vector2.new(1, 0.5)
local v3 = nil
local maid = nil
local v4 = 1
local v5 = 45
local Horse = {
	cycleSpeedMode = function()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid == nil or humanoid.MoveDirection.Magnitude <= 0.001 then
			return
		end

		local v6 = v4 + 1
		local v7 = #v < v6 and 1 or v6
		v4 = v[v7].StaminaDrain > 0 and v5 < 1 and 1 or v7
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function flatten(moveDirection: Vector3)
	return (Vector3.new(moveDirection.X, 0, moveDirection.Z))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopDriving()
	if maid then
		maid:Destroy()
		maid = nil
	end
end

local function startDriving(value)
	stopDriving() -- equivalent call inferred; original call site unknown
	local humanoidRootPart = value:FindFirstChild("HumanoidRootPart")
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local hipheight = value:GetAttribute("hipheight")
	local v6 = math.max((hipheight or 0) + 3, 6)
	local head = character:FindFirstChild("Head")

	local function groundHit()
		local Y

		if head then
			Y = head.Position.Y
		else
			Y = humanoidRootPart.Position.Y + 3
		end

		local position = humanoidRootPart.Position
		local vector3 = Vector3.new(position.X, Y, position.Z)
		local v7 = Y - position.Y + v6 + 6
		return workspace:Raycast(vector3, Vector3.new(0, -v7, 0), RaycastHelper.EverythingExceptPlayer)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onGround(raycastResult: RaycastResult?)
		return raycastResult ~= nil and humanoidRootPart.Position.Y - raycastResult.Position.Y <= v6
	end

	local function isGrounded()
		local Y

		if head then
			Y = head.Position.Y
		else
			Y = humanoidRootPart.Position.Y + 3
		end

		local position = humanoidRootPart.Position
		local vector3 = Vector3.new(position.X, Y, position.Z)
		local v7 = Y - position.Y + v6 + 6
		return onGround(workspace:Raycast(vector3, Vector3.new(0, -v7, 0), RaycastHelper.EverythingExceptPlayer))
	end

	local restHeight = value:GetAttribute("RestHeight") or hipheight

	if restHeight == nil then
		warn("Horse: no RestHeight/hipheight on the horse -- hover off")
	end

	maid = cleanit.new()
	v4 = 1
	maid:Add(InputHandler.ListenTo("Run", function(p: string, flag: boolean)
		if p ~= "Down" or flag then
			return
		end

		local character2 = localPlayer.Character
		local humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")

		if humanoid2 ~= nil then
			if humanoid2.MoveDirection.Magnitude <= 0.001 then
				return
			end

			local v7 = v4 + 1
			local v8 = #v < v7 and 1 or v7
			v4 = v[v8].StaminaDrain > 0 and v5 < 1 and 1 or v8
		end
	end))
	local link = ServerClientPortal.Link("HorseGait", -1)
	maid:Add(function()
		if link.__Active then
			link:Destroy()
		end
	end)
	local v7 = nil
	local v8 = nil
	local v9 = nil
	local now = 0
	local v10 = 0
	maid:Add(InputHandler.ListenTo("Jump", function(p: string, flag: boolean)
		if p ~= "Down" or flag or os.clock() - now < 2 then
			return
		end

		local Y

		if head then
			Y = head.Position.Y
		else
			Y = humanoidRootPart.Position.Y + 3
		end

		local position = humanoidRootPart.Position
		local vector3 = Vector3.new(position.X, Y, position.Z)
		local v11 = Y - position.Y + v6 + 6
		local raycastResult = workspace:Raycast(vector3, Vector3.new(0, -v11, 0), RaycastHelper.EverythingExceptPlayer)
		local v12

		if raycastResult == nil then
			v12 = false
		else
			v12 = humanoidRootPart.Position.Y - raycastResult.Position.Y <= v6
		end

		if not v12 then
			return
		end

		now = os.clock()
		v10 = os.clock() + 0.15
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		local attachment = Instance.new("Attachment")
		attachment.Parent = humanoidRootPart
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.MaxForce = 1e999
		linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		linearVelocity.VectorVelocity = Vector3.new(assemblyLinearVelocity.X, 50, assemblyLinearVelocity.Z)
		linearVelocity.Attachment0 = attachment
		linearVelocity.Parent = attachment
		task.delay(0.15, function()
			attachment:Destroy()
		end)
	end))
	local attachment = Instance.new("Attachment")
	attachment.Name = "HorseMover"
	attachment.Parent = humanoidRootPart
	maid:Add(attachment)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	linearVelocity.PrimaryTangentAxis = createVector(1, 0, 0)
	linearVelocity.SecondaryTangentAxis = createVector(0, 0, 1)
	linearVelocity.PlaneVelocity = Vector2.zero
	linearVelocity.MaxForce = 25000
	linearVelocity.Parent = attachment
	local linearVelocity2 = Instance.new("LinearVelocity")
	linearVelocity2.Attachment0 = attachment
	linearVelocity2.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity2.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	linearVelocity2.LineDirection = createVector(0, 1, 0)
	linearVelocity2.LineVelocity = 0
	linearVelocity2.MaxForce = 100000
	linearVelocity2.Enabled = false
	linearVelocity2.Parent = attachment
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.RigidityEnabled = false
	alignOrientation.Responsiveness = 150
	alignOrientation.MaxTorque = 30000
	alignOrientation.Parent = attachment
	local vector3 = createVector(0, 0, 0)
	local lookVector = humanoidRootPart.CFrame.LookVector
	local unit = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
	local unit2 = createVector(0, 1, 0)
	local total = 0

	local function applyOrientation()
		local v11 = unit - unit2 * unit:Dot(unit2)

		if v11.Magnitude > 0.001 then
			local unit3 = v11.Unit
			local unit4 = unit2

			if math.abs(total) > 0.001 then
				local cross = unit3:Cross(unit4)
				unit4 = (unit4 * math.cos(total) + cross * math.sin(total)).Unit
			end

			alignOrientation.CFrame = CFrame.lookAlong(createVector(0, 0, 0), unit3, unit4)
		end
	end

	applyOrientation()
	maid:Connect(RunService.Heartbeat, function(p: number)
		local DISTANCE_EPSILON = 0.001

		if humanoidRootPart.Parent == nil then
			return
		end

		local v11 = flatten(humanoid.MoveDirection) -- equivalent call inferred; original call site unknown
		local v12 = v11.Magnitude > DISTANCE_EPSILON
		local v13 = not v12 and createVector(0, 0, 0) or v11.Unit
		local v14 = v[v4]
		local Y

		if head then
			Y = head.Position.Y
		else
			Y = humanoidRootPart.Position.Y + 3
		end

		local position = humanoidRootPart.Position
		local vector4 = Vector3.new(position.X, Y, position.Z)
		local v15 = Y - position.Y + v6 + 6
		local raycastResult = workspace:Raycast(vector4, Vector3.new(0, -v15, 0), RaycastHelper.EverythingExceptPlayer)
		local v16

		if raycastResult == nil then
			v16 = false
		else
			v16 = humanoidRootPart.Position.Y - raycastResult.Position.Y <= v6
		end

		local v17 = not v16 or os.clock() < v10

		if v12 ~= v7 or v14.Anim ~= v8 or v17 ~= v9 then
			local anim = v14.Anim
			v7 = v12
			v8 = anim
			v9 = v17

			if link.__Active then
				link:Server(v12, v14.Anim, v17)
			end
		end

		if v12 then
			local v18 = 1 - math.exp(p * -3)
			vector3 = vector3:Lerp(v13 * v14.Speed * PlayerStatResolver.GetMovementMultiplier(localPlayer), v18)
		else
			vector3 = createVector(0, 0, 0)
		end

		if v12 then
			local raycastResult2 = workspace:Raycast(
				humanoidRootPart.Position,
				v13 * 6,
				RaycastHelper.EverythingExceptPlayer
			)

			if raycastResult2 and raycastResult2.Normal.Y < 0.5 then
				local vector5 = Vector3.new(raycastResult2.Normal.X, 0, raycastResult2.Normal.Z)

				if vector5.Magnitude > DISTANCE_EPSILON then
					local unit3 = vector5.Unit
					local dot = vector3:Dot(unit3)

					if dot < 0 then
						vector3 -= unit3 * dot
					end
				end
			end
		end

		local v18 = (not raycastResult or v17 or not (raycastResult.Normal.Y > 0.5)) and createVector(0, 1, 0) or raycastResult.Normal
		local unit3 = (createVector(1, 0, 0) - v18 * v18.X).Unit
		local cross = unit3:Cross(v18)
		linearVelocity.PrimaryTangentAxis = unit3
		linearVelocity.SecondaryTangentAxis = cross
		local dot = vector3:Dot(unit3)
		local dot2 = vector3:Dot(cross)
		local v19 = math.sqrt(dot * dot + dot2 * dot2)
		local v20 = not (v19 > 0.001) and 0 or vector3.Magnitude / v19
		linearVelocity.PlaneVelocity = Vector2.new(dot * v20, dot2 * v20)
		local vector5 = unit

		if v12 then
			local v21 = 1 - math.exp(p * -2.5)
			local lerped = unit:Lerp(v13, v21)

			if lerped.Magnitude > DISTANCE_EPSILON then
				unit = lerped.Unit
			end
		end

		local Y2 = vector5:Cross(unit).Y
		local v21 = math.clamp(
			-(not (p > 0) and 0 or math.asin((math.clamp(Y2, -1, 1))) / p) * 0.35,
			-0.2617993877991494,
			0.2617993877991494
		)
		total += (v21 - total) * (1 - math.exp(p * -6))
		local v22 = 1 - math.exp(p * -6)
		local v23

		if not (raycastResult == nil or not (raycastResult.Normal.Y > 0.5)) then
			v23 = raycastResult.Normal
		end

		unit2 = unit2:Lerp(v16 and v23 or createVector(0, 1, 0), v22).Unit
		applyOrientation()

		if v16 and raycastResult and restHeight then
			local now2 = os.clock()

			if v10 <= now2 then
				local v24 = raycastResult.Position.Y + restHeight / math.max(raycastResult.Normal.Y, 0.5)
				linearVelocity2.LineVelocity = math.clamp((v24 - humanoidRootPart.Position.Y) * 12, -40, 40)
				linearVelocity2.Enabled = true
				return
			end
		end

		linearVelocity2.Enabled = false
	end)
end

local v6 = false

local function refresh()
	if (getvaluesfolder and getvaluesfolder:FindFirstChild("RidingHorse")) == nil then
		stopDriving() -- equivalent call inferred; original call site unknown
	else
		if maid ~= nil or v6 then
			return
		end

		v6 = true
		task.spawn(function()
			while maid == nil and v3 ~= nil do
				local ridingHorse = getvaluesfolder and getvaluesfolder:FindFirstChild("RidingHorse")

				if ridingHorse == nil then
					break
				end

				local value = ridingHorse.Value
				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if value and value.Parent ~= nil and value:FindFirstChild("HumanoidRootPart") and humanoid then
					startDriving(value)
				end

				if maid ~= nil then
					break
				end

				task.wait()
			end

			v6 = false
		end)
	end
end

local v7 = nil
local v8 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function killStaminaBar()
	if v7 then
		v7.destroy()
	end

	v7 = nil
	v8 = nil
end

local function ensureStaminaBar()
	local character = localPlayer.Character

	if v7 and v8 == character then
		return
	end

	killStaminaBar() -- equivalent call inferred; original call site unknown
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local billboardComponents = humanoidRootPart and humanoidRootPart:FindFirstChild("BillboardComponents")

	if billboardComponents == nil then
		return
	end

	local destroy, v10, shake = ClimbBar(billboardComponents, uDim, vector2)
	v7 = {
		destroy = destroy,
		value = v10,
		shake = shake
	}
	v8 = character
end

RunService.Heartbeat:Connect(function(dt: number)
	if maid == nil and v5 >= 45 and v7 == nil then
		return
	end

	local v9 = false

	if maid then
		local v10 = v[v4]

		if v10.StaminaDrain > 0 then
			local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local moveDirection = humanoid.MoveDirection

				if Vector3.new(moveDirection.X, 0, moveDirection.Z).Magnitude > 0.001 then
					v5 = math.max(0, v5 - v10.StaminaDrain * dt)
					v9 = true

					if v5 <= 0 then
						v4 = 1
					end
				end
			end
		end
	end

	if not v9 and v5 < 45 then
		v5 = math.min(45, v5 + dt * 2)
	end

	if v5 < 45 then
		ensureStaminaBar()

		if v7 then
			local v10 = v5 / 45
			v7.value:Set(1 - v10)
			v7.shake:Set(v10 < 0.25 and 1 or 0)
		end
	else
		killStaminaBar() -- equivalent call inferred; original call site unknown
	end
end)

function Horse.check(_, _: string)
	if not Checker.check(localPlayer) then
		return false
	end

	local v9 = equipCooldownLeft() -- equivalent call inferred; original call site unknown

	if v9 > 0 then
		notification:Fire("Notify", {
			Text = `Wait {math.ceil(v9)} seconds`,
			Type = "Denied"
		})
		return false
	end

	if not InCombat.biasedCheck(localPlayer) then
		return true
	end

	local biasedTimeLeft = InCombat.biasedTimeLeft(localPlayer)
	notification:Fire("Notify", {
		Text = `Can't mount while in combat ({Utility.formatTime(biasedTimeLeft)} left)`,
		Type = "Denied"
	})
	return false
end

function Horse.Equipped(_, _: string)
	if v3 then
		v3:Destroy()
		v3 = nil
	end

	stopDriving() -- equivalent call inferred; original call site unknown

	if getvaluesfolder == nil then
		return
	end

	v3 = cleanit.new()
	v3:Connect(getvaluesfolder.ChildAdded, function(p)
		if p.Name == "RidingHorse" then
			refresh()
		end
	end)
	v3:Connect(getvaluesfolder.ChildRemoved, function(p)
		if p.Name == "RidingHorse" and maid then
			maid:Destroy()
			maid = nil
		end
	end)
	v3:Add(stopDriving)
	refresh()
end

function Horse.UnEquipped(_, _: string)
	if v3 then
		v3:Destroy()
		v3 = nil
	end

	stopDriving() -- equivalent call inferred; original call site unknown
	stampEquipCooldown() -- equivalent call inferred; original call site unknown
end

function Horse.MouseDown(_, _: string)
	if Platform_Handler.Platform.Value ~= "Mobile" then
		return
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		if humanoid.MoveDirection.Magnitude <= 0.001 then
			return
		end

		local v9 = v4 + 1
		local v10 = #v < v9 and 1 or v9
		v4 = v[v10].StaminaDrain > 0 and v5 < 1 and 1 or v10
	end
end

function Horse.MouseUp(_, _: string) end

return Horse