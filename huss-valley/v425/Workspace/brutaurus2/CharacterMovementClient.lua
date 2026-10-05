local createVector = vector.create
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local movement = ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Movement")
local MovementProfiles = require(movement:WaitForChild("MovementProfiles"))
local localPlayer = game.Players.LocalPlayer
local v = MovementProfiles.get(localPlayer:GetAttribute("GameRole"), localPlayer)
local boostRequest = movement.Parent:WaitForChild("Presentation"):WaitForChild("BoostRequest")
local MovementModel = require(movement:WaitForChild("MovementModel"))
local BodyFacingModel = require(movement:WaitForChild("BodyFacingModel"))
local BodyFacingConfig = require(movement:WaitForChild("BodyFacingConfig"))
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local BoostInput = require(movement:WaitForChild("BoostInput"))
local ControlGate = require(movement:WaitForChild("ControlGate"))
local TacklePrediction = require(movement.Parent.Game:WaitForChild("TacklePrediction"))

if localPlayer.Character ~= parent then
	return
end

BoostInput.clear()
local v2 = MovementModel.new()
local HttpService = game:GetService("HttpService")
local v3 = "ChickenOrHeroMovement_" .. HttpService:GenerateGUID(false)
local connections = {}
local flag = false
local walkSpeed = humanoid.WalkSpeed
local stateEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, v.JumpEnabled)

local function cleanup()
	if flag then
		return
	end

	flag = true

	if localPlayer.Character == parent then
		BoostInput.clear()
	end

	RunService:UnbindFromRenderStep(v3)

	for _, connection in connections do
		connection:Disconnect()
	end

	if humanoid.Parent then
		humanoid.WalkSpeed = walkSpeed
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, stateEnabled)
	end
end

table.insert(connections, humanoid.Died:Connect(cleanup))
table.insert(connections, script.Destroying:Connect(cleanup))
table.insert(connections, parent.AncestryChanged:Connect(function(_, parent2)
	if not parent2 then
		cleanup()
	end
end))

-- equivalent calls inferred from this helper; original call sites unknown
local function blockReason(movementBlockReason)
	if parent:GetAttribute("MovementBlockReason") ~= movementBlockReason then
		parent:SetAttribute("MovementBlockReason", movementBlockReason)
		parent:SetAttribute("MovementBlockSince", movementBlockReason and workspace:GetServerTimeNow() or nil)
	end
end

local movementReset = parent:GetAttribute("MovementReset")
local total = 0
local dashCount = 0
local v4 = nil
RunService:BindToRenderStep(v3, Enum.RenderPriority.Input.Value + 1, function(p)
	if flag then
		return
	end

	if localPlayer.Character ~= parent then
		cleanup()
		return
	end

	local v5, v6 = BoostInput.consume()
	local v7 = v6 or UserInputService.PreferredInput == Enum.PreferredInput.Touch
	local v8 = MovementProfiles.get(localPlayer:GetAttribute("GameRole"), localPlayer)

	if v8 ~= v then
		v = v8
		v2.dashRemaining = 0
		v2.recoveryRemaining = 0
		v2.armed = false
		v2.speed = math.min(v2.speed, v.MaxSpeed)
		parent:SetAttribute("DashReady", false)
		v5 = false
	end

	local movementReset2 = parent:GetAttribute("MovementReset")

	if movementReset2 ~= movementReset then
		movementReset = movementReset2
		MovementModel.suspend(v2, 0)
		v5 = false
	end

	if parent:GetAttribute("GearMotion") then
		blockReason("GearMotion") -- equivalent call inferred; original call site unknown
		MovementModel.suspend(v2, p)
		humanoid.WalkSpeed = 0
		humanoid:Move(createVector(0, 0, 0), false)
	elseif TacklePrediction.isActive(parent) or parent:GetAttribute("TackleActive") then
		blockReason("Tackle") -- equivalent call inferred; original call site unknown
		MovementModel.suspend(v2, p)
	else
		local state = humanoid:GetState()
		local movementLockReason

		if parent:GetAttribute("MovementLocked") == true then
			movementLockReason = parent:GetAttribute("MovementLockReason") or "Match"
		else
			movementLockReason = ControlGate.movementReason(localPlayer)
		end

		local v9 = movementLockReason ~= nil

		if humanoid.Health <= 0 then
			cleanup()
		elseif humanoid.Sit or humanoid.PlatformStand or humanoidRootPart.Anchored or state == Enum.HumanoidStateType.Swimming or state == Enum.HumanoidStateType.Climbing or state == Enum.HumanoidStateType.Physics then
			blockReason(movementLockReason or humanoidRootPart.Anchored and "Anchored" or humanoid.Sit and "Seated" or humanoid.PlatformStand and "PlatformStand" or state.Name) -- equivalent call inferred; original call site unknown
			MovementModel.suspend(v2, p)
		else
			blockReason(movementLockReason) -- equivalent call inferred; original call site unknown
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

			if v9 then
				MovementModel.suspend(v2, p)
				humanoid.WalkSpeed = 0
				humanoid:Move(createVector(0, 0, 0), false)
			else
				local moveDirection = humanoid.MoveDirection
				local vector2 = createVector(0, 0, 0)
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					local lookVector = currentCamera.CFrame.LookVector
					local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

					if vector3.Magnitude > 0.001 then
						local unit = vector3.Unit
						vector2 = Vector3.new(
							moveDirection:Dot((unit:Cross(createVector(0, 1, 0)))),
							0,
							-moveDirection:Dot(unit)
						)
					end
				end

				local v10

				if currentCamera and humanoid.RigType == Enum.HumanoidRigType.R6 then
					local v11 = moveDirection.Magnitude > v.InputDeadzone and moveDirection or v2.direction
					local v12 = currentCamera.CFrame.LookVector * createVector(1, 0, 1)
					v10 = BodyFacingModel.speedMultiplier(v11, v12, BodyFacingConfig)
				else
					v10 = 1
				end

				local mode = v2.mode
				local v11 = math.min(v2.speed, magnitude)
				MovementModel.step(
					v2,
					moveDirection,
					magnitude,
					p,
					v,
					humanoid.FloorMaterial ~= Enum.Material.Air,
					vector2,
					v10,
					v5,
					assemblyLinearVelocity,
					v7
				)

				if v2.mode == "Braking" and mode ~= "Braking" then
					parent:SetAttribute("MovementStopEntrySpeed", v11)
				end

				parent:SetAttribute("FacingPaceMultiplier", v10)
				humanoid.WalkSpeed = v2.outputSpeed
				humanoid:Move(v2.outputDirection, false)

				if v2.mode == "Dashing" or v2.mode == "Boosting" then
					local assemblyLinearVelocity2 = humanoidRootPart.AssemblyLinearVelocity
					local v12 = v2.outputDirection * v2.outputSpeed
					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(v12.X, assemblyLinearVelocity2.Y, v12.Z)
				end
			end

			local v10 = v9 and "Locked" or v2.mode

			if v10 ~= v4 then
				if v10 == "Boosting" or v10 == "Dashing" then
					parent:SetAttribute("DashFromDirection", v2.dashFromDirection)
					parent:SetAttribute("DashToDirection", v2.dashDirection)
					parent:SetAttribute("DashAnimationSequence", v2.dashCount)
					boostRequest:FireServer(v2.dashFromDirection, v2.dashDirection)
				end

				v4 = v10
				parent:SetAttribute("BoostRecoveryUntil", os.clock() + v2.recoveryRemaining)
				parent:SetAttribute("MovementState", v10)
			end

			total += p

			if total >= 0.1 or v2.dashCount ~= dashCount then
				dashCount = v2.dashCount
				total = 0
				parent:SetAttribute("MovementSpeed", v2.outputSpeed)
				parent:SetAttribute("DashCount", v2.dashCount)
				parent:SetAttribute(
					"DashReady",
					not v9 and MovementModel.canBoost(v2, v, humanoid.FloorMaterial ~= Enum.Material.Air)
				)
				parent:SetAttribute("BoostRecoveryUntil", os.clock() + v2.recoveryRemaining)
				parent:SetAttribute("DashCooldown", v2.cooldown)
				parent:SetAttribute("DashCooldownUntil", os.clock() + v2.cooldown)
				parent:SetAttribute("LastDashDistance", v2.lastDashDistance)
				parent:SetAttribute("LastDashEntrySpeed", v2.lastDashEntrySpeed)
			end
		end
	end
end)