local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(game.ReplicatedStorage.Util)
require(ReplicatedStorage:WaitForChild("FX"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local arrayQueue = Util.ArrayQueue
local DragonMoverClass = {}
DragonMoverClass.__index = DragonMoverClass
local IKLeg = require(script.IKLeg)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local WriteBuffer = require(game.ReplicatedStorage.Util.WriteBuffer)
local ReadBuffer = require(game.ReplicatedStorage.Util.ReadBuffer)
local DebugOptions = require(game.ReplicatedStorage.Util.DebugOptions)
local FX = require(game.ReplicatedStorage.FX)

local function pcallWarn(fn, ...)
	local success, result = pcall(fn, ...)

	if not success then
		warn("pcallWarn caught an error: " .. tostring(result) .. [[

 
]] .. "Traceback:\n" .. debug.traceback())
	end

	return success, result
end

local function haltUntilCondition(fn, value: number?)
	local v = value or 14
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = Util.HeartbeatLoopFor.HeartbeatLoopFor(v, function()
		local success, result = pcall(fn)

		if success and result then
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		elseif not success then
			print("haltUntilCondition: Error in predicate function: ", result)
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

function DragonMoverClass.new(player, char, hrp, dragonPart, collisionPart, easternDragonModel, script2)
	local object = setmetatable({}, DragonMoverClass)
	object.script = script2
	local dragonCFrameWithoutOffset = object.script.Parent:WaitForChild("DragonCFrameWithoutOffset")
	local dragonCFrameRemote = object.script.Parent:WaitForChild("DragonCFrameRemote")
	local dragonIdleRemote = object.script.Parent:WaitForChild("DragonIdleRemote")
	local isIdle = object.script.Parent:WaitForChild("IsIdle")
	local dragonHeadAimRemote = object.script.Parent:WaitForChild("DragonHeadAimRemote")
	local dragonTrailingPositionsRemote = object.script.Parent:WaitForChild("DragonTrailingPositionsRemote")
	local dragonCollisionVFXRemote = object.script.Parent:WaitForChild("DragonCollisionVFXRemote")
	local accumulatedInputTimeRemote = object.script.Parent:WaitForChild("AccumulatedInputTimeRemote")
	object.DragonCFrameWithoutOffset = dragonCFrameWithoutOffset
	object.DragonCFrameRemote = dragonCFrameRemote
	object.DragonIdleRemote = dragonIdleRemote
	object.IsIdle = isIdle
	object.DragonHeadAimRemote = dragonHeadAimRemote
	object.DragonTrailingPositionsRemote = dragonTrailingPositionsRemote
	object.DragonCollisionVFXRemote = dragonCollisionVFXRemote
	object.AccumulatedInputTimeRemote = accumulatedInputTimeRemote
	object.DragonSetupRemote = object.script.Parent:WaitForChild("DragonSetupRemote")
	object.player = player
	local playerModule

	if localPlayer == player then
		playerModule = require(player.PlayerScripts.PlayerModule)
	end

	object.playerModule = playerModule
	object.char = char
	object.humanoid = object.char:FindFirstChildOfClass("Humanoid")
	object.hrp = hrp
	haltUntilCondition(function()
		return dragonPart.GoalAttach.Value ~= nil
	end, 14)
	object.goalAttach = dragonPart.GoalAttach.Value
	object.goalAttach.WorldCFrame = object.hrp.CFrame.Rotation + object.goalAttach.WorldCFrame.Position

	if localPlayer == player then
		object.mouse = require(game.ReplicatedStorage.Mouse)
		object.stun = char:FindFirstChild("Stun")
	end

	object.heightDifference = 0
	object.dragonPart = dragonPart
	object.collisionPart = collisionPart
	object.alignPosition = dragonPart.AlignPosition
	object.alignOrientation = dragonPart.AlignOrientation
	object.easternDragonModel = easternDragonModel
	object.MAX_SPEED = 150
	object.TURN_SPEED = 0.07
	object.SINUSOIDAL_AMPLITUDE = 6
	object.SINUSOIDAL_FREQUENCY = 3
	object.GROUND_MAX_SPEED = 165
	object.GROUND_TURN_SPEED = 0.08
	object.GROUND_SINUSOIDAL_AMPLITUDE = 20
	object.GROUND_SINUSOIDAL_FREQUENCY = 6.4
	object.IDLE_SPEED_MULTIPLIER = 0.2
	object.TIME_REBOUNDING_UP = 0.6
	object.IDLE_SINE_FREQUENCY = 2.5
	object.IDLE_SINE_MAX_AMPLITUDE = 5
	object.ATTACK_SPEED_NERF = 0.35
	object.ATTACK_SPEED_NERF_TIME = 0.4
	object.ATTACK_SPEED_RECOVERY_TIME = 0.6
	object.HALO_IDLE_DELAY = 0.5
	object.currentSpeed = 0
	object.currentLookVector = object.goalAttach.WorldCFrame.LookVector
	object.goalLookVector = object.goalAttach.WorldCFrame.LookVector
	object.prevCurrentLookVector = object.currentLookVector
	object.positionWithoutOffset = object.dragonPart.Position
	object.currentMaxSpeed = object.MAX_SPEED
	object.currentTurnSpeed = object.TURN_SPEED
	object.currentSinusoidalAmplitude = object.SINUSOIDAL_AMPLITUDE
	object.currentSinusoidalFrequency = object.SINUSOIDAL_FREQUENCY
	object.currentSinusoidalOffset = 0
	object.runningOnGround = false
	object.runningOnGroundDebounceTime = time()
	object.idleSineAmplitude = 0
	object.fakePlayerInputEnabled = false
	object.fakePlayerInputVector = createVector(0, 0, -1)
	object.isAttacking = false
	object.lastSampledPosition = nil
	object.springTimer = 0
	object.initLookVector = object.hrp.CFrame.LookVector
	object.initTime = time()
	object.lastAccumulatedInputTime = 0
	object.lastInputActive = false
	object.lastGroundSlam = time()
	object._customBoneCFEnabled = false
	object._headAimingEnabled = false
	object._headAimingDisabling = false
	object._headAimingProgress = 0
	object.wasFActive = false
	object.wasFEndActive = false
	object.wasXActive = false
	object.wasCActive = false
	object.wasCActive2 = false
	object.wasVActive = false
	object.CFrozen = false
	object.bounceParameter = 0
	object.isRebounding = false
	object.lastReboundInputTime = -1e999
	object.prevAccumulatedInputTime = 0
	object.lastAttackTime = 0
	object.lastAttackReleaseTime = 0
	object.timeStepHistoryQueue = arrayQueue.new(5)
	object.currentDragonLoopedSound = nil
	object.haloCurrentSpeed = 1

	if localPlayer == object.player then
		object.script.Parent.DragonHaloCurrentSpeed:FireServer(object.haloCurrentSpeed)
	end

	object.haloSide = 1
	object.haloCooldown = 0
	object.haloProgress = 0
	object.haloVisible = nil
	object.haloTask = nil
	object.easternScaleModifier = object.easternDragonModel:GetScale() / 0.4
	object.sinusoidalUpVector = createVector(0, 1, 0)
	object.headAimCutoffAngle = 1.5184364492350666
	object.prevCollisionDebounceTime = time()
	object.timeOfNextDragonPacket = 0
	object.dragonUpdateRateHz = object.script.Parent:WaitForChild("UpdateInterval")
	object.events = {}
	object:initAura()
	object:initRobloxAnimations()
	object:initVisuals()
	object:initPhysics()
	object:SetHaloVisible(false)
	assert(
		object.NUM_BONES % object.script.Parent.NUM_TRAILING_CYLINDERS.Value == 0,
		"Trailing cylinders should divide number of bones"
	)

	if localPlayer ~= object.player then
		object:initializeServerTrailingPositions()
		object:enableServerAuthoritativeSimulation()
	end

	object:clearHurtboxes()
	object.proxyCameraPart = object:getDebugPart("ProxyDragonCameraPart", char)
	object.proxyCameraPart.Transparency = 1
	local heartbeatLoopFor = Util.HeartbeatLoopFor
	local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
	local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
	local events = object.events
	local RunService2 = game:GetService("RunService")
	events.renderStep = RunService2.Stepped:Connect(function(_, dt)
		pcallWarn(function()
			for _, v2 in ipairs(object.animator:GetPlayingAnimationTracks()) do
				if v2.Name == "Animation" then
					v2:Stop()
				end
			end

			if object.dragonPart.Parent == nil or object.humanoid.Health <= 0 or object.player == nil or object.player.Parent == nil or object.char == nil or object.char.Parent == nil or object.script.Parent == nil or object.script.Parent.IsTransformed.Value == false then
				object:destroy()
				return
			end

			if object.wasFActive ~= object.script.FDrillActive.Value then
				object.wasFActive = object.script.FDrillActive.Value

				if object.script.FDrillActive.Value == true then
					object.currentMaxSpeed = object.script.FDrillActive.FLIGHT_SPEED.Value
					object.currentSpeed = object.currentMaxSpeed
				elseif object.script.FMidAirEndActive.Value == false then
					object:enableCustomBoneCFrameMode()
					local initialReboundPosition

					if localPlayer == object.player then
						initialReboundPosition = object:getBonePositions()[1]
						local raycastResult = workspace:Raycast(
							initialReboundPosition + createVector(0, 20, 0),
							createVector(-0, -160, -0),
							raycastParams
						)

						if raycastResult then
							initialReboundPosition = raycastResult.Position + raycastResult.Normal
						end
					else
						initialReboundPosition = object.script.FDrillActive.CollisionPosition.Value
					end

					object.initialClientReboundPositions = object:getBonePositions()
					local v2 = object
					local v4

					if localPlayer ~= object.player then
						v4 = initialReboundPosition
					end

					v2.initialServerReboundPositions = object:getBonePositions(v4)

					function object.initialReboundBodySpaceCurve(p)
						return arrayToSpaceCurve(object.initialClientReboundPositions, p)
					end

					heartbeatLoopFor2(object.TIME_REBOUNDING_UP, function(_, _, p)
						local v5 = {}

						for i, initialClientReboundPosition in ipairs(object.initialClientReboundPositions) do
							v5[i] = initialClientReboundPosition:Lerp(object.initialServerReboundPositions[i], p)
						end

						function object.initialReboundBodySpaceCurve(p2)
							return arrayToSpaceCurve(v5, p2)
						end
					end, function()
						function object.initialReboundBodySpaceCurve(p)
							return arrayToSpaceCurve(object.initialServerReboundPositions, p)
						end
					end)
					object.isRebounding = true
					object.ReboundDidCollideWithWall = nil
					object.lastReboundInputTime = object:getAccumulatedInputTime()
					object.initialReboundTime = time()
					object.runningOnGround = false
					object.runningOnGroundDebounceTime = time()
					object.currentMaxSpeed = object.MAX_SPEED
					object.currentTurnSpeed = object.TURN_SPEED
					object:switchSineSmooth(
						object.currentSinusoidalAmplitude,
						object.currentSinusoidalFrequency,
						object:getAccumulatedInputTime(),
						object.currentSinusoidalOffset,
						object.SINUSOIDAL_AMPLITUDE,
						object.SINUSOIDAL_FREQUENCY
					)
					object.currentSinusoidalAmplitude = object.SINUSOIDAL_AMPLITUDE
					object.currentSinusoidalFrequency = object.SINUSOIDAL_FREQUENCY
					object.initialReboundPosition = initialReboundPosition
					task.delay(object.TIME_REBOUNDING_UP, function()
						object.isRebounding = false
						local v5 = object
						local currentMaxSpeed

						if object.runningOnGround == true then
							currentMaxSpeed = object.GROUND_MAX_SPEED
						else
							currentMaxSpeed = object.MAX_SPEED
						end

						v5.currentMaxSpeed = currentMaxSpeed
						object:updateBonePositions((object:getBonePositions()))
						object:disableCustomBoneCFrameMode()
						object:enableFakePlayerInput()
						task.delay(0.15, function()
							object:disableFakePlayerInput()
						end)
					end)
				end
			end

			if object.wasFEndActive ~= object.script.FMidAirEndActive.Value then
				if object.script.FMidAirEndActive.Value == true then
					object.wasFEndActive = true
					object.currentMaxSpeed = 0
					object.currentSpeed = 0
					object.FEndInitTime = time()
					object.FEndInitCF = object.script.FMidAirEndActive.MidAirEndInitCF.Value
					object.FInitClientPositions = object:getBonePositions()
					object.FInitServerPositions = object:getBonePositions(object.FEndInitCF.Position)

					function object.FInitBodySpaceCurve(p)
						return arrayToSpaceCurve(object.FInitClientPositions, p)
					end

					object.VEndDidCollideWithWall = nil
					heartbeatLoopFor2(
						object.script.FMidAirEndActive.F_MID_AIR_END_ANIMATION_LASTS_FOR.Value,
						function(_, _, p)
							local v2 = {}

							for i, fInitClientPosition in ipairs(object.FInitClientPositions) do
								v2[i] = fInitClientPosition:Lerp(object.FInitServerPositions[i], p)
							end

							function object.FInitBodySpaceCurve(p2)
								return arrayToSpaceCurve(v2, p2)
							end
						end,
						function()
							function object.FInitBodySpaceCurve(p)
								return arrayToSpaceCurve(object.FInitServerPositions, p)
							end
						end
					)
					local dragon2TransformedEasternFImpact = Effect.new("Dragon2.TransformedEastern.FImpact")
					local v2 = {
						player = object.player,
						hrp = object.hrp,
						dragonCF = 0,
						collision = false
					}
					local dragonCF

					if object.script.FMidAirEndActive:GetAttribute("FromTransformation") == true then
						dragonCF = object.FEndInitCF
					else
						dragonCF = CFrame.lookAlong(createVector(0, 0, 0), object.currentLookVector) + object.FEndInitCF.Position - object.currentSpeed * object.currentLookVector * dt
					end

					v2.dragonCF = dragonCF
					dragon2TransformedEasternFImpact:play(v2)
					object:enableCustomBoneCFrameMode()
				else
					object.script.FMidAirEndActive.Value = true
					local v2 = time() - object.FEndInitTime
					task.delay(
						math.max(0, object.script.FMidAirEndActive.F_MID_AIR_END_ANIMATION_LASTS_FOR.Value - v2),
						function()
							object.script.FMidAirEndActive.Value = false
							object.wasFEndActive = false
							local v3 = object
							local currentMaxSpeed

							if object.runningOnGround == true then
								currentMaxSpeed = object.GROUND_MAX_SPEED
							else
								currentMaxSpeed = object.MAX_SPEED
							end

							v3.currentMaxSpeed = currentMaxSpeed
							object:updateBonePositions((object:getBonePositions()))
							object:disableCustomBoneCFrameMode()
							object:enableFakePlayerInput()
							task.delay(0.15, function()
								object:disableFakePlayerInput()
							end)
						end
					)
				end
			end

			if object.wasXActive ~= object.script.XSpiralActive.Value then
				if object.script.XSpiralActive.Value == true then
					object.wasXActive = true
					object.currentMaxSpeed = 0
					object.currentSpeed = 0
					object.XInitTime = time()
					local v2 = object
					local v4

					if localPlayer ~= object.player then
						v4 = object.script.XSpiralActive.Origin.Value
					end

					v2.XInitPositions = object:getBonePositions(v4)

					function object.XInitBodySpaceCurve(p)
						return arrayToSpaceCurve(object.XInitPositions, p)
					end

					object:enableCustomBoneCFrameMode()
				else
					object.script.XSpiralActive.Value = true
					local v2 = time() - object.XInitTime
					task.delay(
						math.max(
							0,
							object.script.XSpiralActive.TIME_SPIRALLING.Value + object.script.XSpiralActive.TIME_UNTIL_IMPACT.Value - v2
						),
						function()
							object.script.XSpiralActive.Value = false
							object.wasXActive = false
							object.initialReboundPositions = object:getBonePositions()

							function object.initialReboundBodySpaceCurve(p)
								return arrayToSpaceCurve(object.initialReboundPositions, p)
							end

							object.isRebounding = true
							object.ReboundDidCollideWithWall = nil
							object.lastReboundInputTime = object:getAccumulatedInputTime()
							object.initialReboundTime = time()
							object.initialReboundPosition = object.script.XSpiralActive.ImpactPosition.Value
							object.runningOnGround = false
							object.runningOnGroundDebounceTime = time()
							object.currentMaxSpeed = object.MAX_SPEED
							object.currentTurnSpeed = object.TURN_SPEED
							object:switchSineSmooth(
								object.currentSinusoidalAmplitude,
								object.currentSinusoidalFrequency,
								object:getAccumulatedInputTime(),
								object.currentSinusoidalOffset,
								object.SINUSOIDAL_AMPLITUDE,
								object.SINUSOIDAL_FREQUENCY
							)
							object.currentSinusoidalAmplitude = object.SINUSOIDAL_AMPLITUDE
							object.currentSinusoidalFrequency = object.SINUSOIDAL_FREQUENCY
							task.delay(object.TIME_REBOUNDING_UP, function()
								object.isRebounding = false
								local v3 = object
								local currentMaxSpeed

								if object.runningOnGround == true then
									currentMaxSpeed = object.GROUND_MAX_SPEED
								else
									currentMaxSpeed = object.MAX_SPEED
								end

								v3.currentMaxSpeed = currentMaxSpeed
								object:updateBonePositions((object:getBonePositions()))
								object:disableCustomBoneCFrameMode()
								object:enableFakePlayerInput()
								task.delay(0.15, function()
									object:disableFakePlayerInput()
								end)
							end)
						end
					)
				end
			end

			if object.wasCActive ~= object.script.CActive.Value then
				object.wasCActive = object.script.CActive.Value

				if object.script.CActive.Value == true then
					object.currentMaxSpeed = 0
					object.currentSpeed = 0
					object.CInitTime = time()
					object.CInitCF = object.script.CActive.InitCF.Value
					local v2 = object
					local v4

					if localPlayer ~= object.player then
						v4 = object.CInitCF.Position
					end

					v2.CInitPositions = object:getBonePositions(v4)

					function object.CInitBodySpaceCurve(p)
						return arrayToSpaceCurve(object.CInitPositions, p)
					end

					object.CDidCollideWithWall = nil
					object:enableCustomBoneCFrameMode()
					object.mouthOpeningAnim:Play()
					object.mouthOpeningAnim.Stopped:Once(function()
						if object.script.CActive.Value == false then
							return
						end

						object.mouthOpenedLoopAnim:Play()
					end)
					object.haloCurrentSpeed = 40

					if localPlayer == object.player then
						object.script.Parent.DragonHaloCurrentSpeed:FireServer(object.haloCurrentSpeed)
					end

					object:SetHaloVisible(true)
				else
					object.haloCurrentSpeed = 1

					if localPlayer == object.player then
						object.script.Parent.DragonHaloCurrentSpeed:FireServer(object.haloCurrentSpeed)
					end

					object.haloCooldown = time()
					object:SetHaloVisible(false)
					local v2 = object
					local currentMaxSpeed

					if object.runningOnGround == true then
						currentMaxSpeed = object.GROUND_MAX_SPEED
					else
						currentMaxSpeed = object.MAX_SPEED
					end

					v2.currentMaxSpeed = currentMaxSpeed
					object:updateBonePositions((object:getBonePositions()))
					object:disableCustomBoneCFrameMode()
					object:enableFakePlayerInput()
					task.delay(0.15, function()
						object:disableFakePlayerInput()
					end)
					object.mouthOpeningAnim:Stop(0.1)
					object.mouthOpenedLoopAnim:Stop(0.1)
					object.mouthClosingAnim:Play(0.1)
				end
			end

			if object.wasVActive ~= object.script.VActive.Value then
				object.wasVActive = object.script.VActive.Value

				if object.script.VActive.Value == true then
					object.currentMaxSpeed = 0
					object.currentSpeed = 0
					object.VInitTime = time()
					object.VInitCF = object.script.VActive.Origin.Value
					object.VInitClientPositions = object:getBonePositions()
					local v2 = object
					local v4

					if localPlayer ~= object.player then
						v4 = object.VInitCF.Position
					end

					v2.VInitServerPositions = object:getBonePositions(v4)

					function object.VInitBodySpaceCurve(p)
						return arrayToSpaceCurve(object.VInitClientPositions, p)
					end

					heartbeatLoopFor2(object.script.VActive.V_ANIMATION_LASTS_FOR.Value, function(_, _, p)
						local v5 = {}

						for i, vInitClientPosition in ipairs(object.VInitClientPositions) do
							v5[i] = vInitClientPosition:Lerp(object.VInitServerPositions[i], p)
						end

						function object.VInitBodySpaceCurve(p2)
							return arrayToSpaceCurve(v5, p2)
						end
					end, function()
						function object.VInitBodySpaceCurve(p)
							return arrayToSpaceCurve(object.VInitServerPositions, p)
						end
					end)
					object:enableCustomBoneCFrameMode()
				end
			end

			if object.idleActive == true then
				object:updateLoopedSound("EasternHeavenlyDragonFruitIdle")
			elseif object.runningOnGround == true then
				object:updateLoopedSound("EasternHeavenlyDragonFruitFlyingLowLOOP")
			else
				object:updateLoopedSound("EasternHeavenlyDragonFruitFlyingHigh")
			end

			local accumulatedInputTime = object:getAccumulatedInputTime()

			if math.abs(object.prevAccumulatedInputTime - accumulatedInputTime) > 0.01 then
				object.prevAccumulatedInputTime = accumulatedInputTime

				if localPlayer == object.player then
					object.AccumulatedInputTimeRemote:FireServer(accumulatedInputTime)
				end
			end
		end)
		pcallWarn(function()
			object:physicsUpdate(dt)
		end)
		pcallWarn(function()
			object:visualsUpdate(dt)
		end)
		pcallWarn(function()
			object:updateHeadAimingMode(nil, nil, dt)
		end)
		pcallWarn(function()
			object:updateAura(dt)
		end)
		pcallWarn(function()
			object:updateReplication()
		end)
	end)

	if player == localPlayer then
		object:switchCameraToProxyPart(true)
		object.events.startedAttacking = char.Busy.Changed:Connect(function()
			if char.Busy.Value then
				object.lastAttackTime = time()
				object.isAttacking = true
			else
				object.lastAttackReleaseTime = time()
				object.isAttacking = false
			end
		end)
	end

	pcallWarn(function()
		local v2 = time()
		object.events.hrpChangedCFrameByCode = object.hrp:GetPropertyChangedSignal("CFrame"):Connect(function()
			if object.script.XSpiralActive.Value == false and object.script.FMidAirEndActive.Value == false and object.script.CActive.Value == false and object.script.VActive.Value == false and object._customBoneCFEnabled ~= true and object.isRebounding ~= true and object.player == localPlayer then
				_G.TestGamePrint(time() - v2)

				if time() - v2 < 0.2 then
					_G.TestGamePrint("DRAGON TELEPORT DEBOUNCE YESYES2")
					return
				end

				v2 = time()
				_G.TestGamePrint("DRAGON TELEPORTED YESYES2", dragonPart.Position)
				object:updateHeadCFrame(dragonPart.CFrame)
				local bonePositions = object:getBonePositions(dragonPart.Position)
				object:enableCustomBoneCFrameMode()
				object:updateBonePositions(bonePositions)
				object:disableCustomBoneCFrameMode()
			end
		end)
	end)
	return object
end

local function round_decimal_third(p)
	return math.round(p * 100) / 100
end

function DragonMoverClass:updateReplication()
	if localPlayer == self.player then
		local bonePositions = self:getBonePositions()

		if DebugOptions.get("easternfastupdate") or tick() > self.timeOfNextDragonPacket then
			self.timeOfNextDragonPacket = tick() + 1 / self.dragonUpdateRateHz.Value
			local v = WriteBuffer.new()
			local bonePosition = bonePositions[1]

			for i = 2, #bonePositions do
				local bonePosition2 = bonePositions[i]
				local v2 = bonePosition2 - bonePosition
				v:WriteFloat16(v2.X)
				v:WriteFloat16(v2.Y)
				v:WriteFloat16(v2.Z)
				bonePosition = bonePosition2
			end

			self.DragonTrailingPositionsRemote:FireServer(bonePositions[1], v:GetBuffer())
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function projectVectorOntoPlane(vector2, p)
	local unit = p.Unit
	return vector2 - vector2:Dot(unit) * unit
end

function DragonMoverClass:initIK()
	local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
	local arm1L = self.easternDragonModel.RootPart.S7["Arm1.L"]
	local arm1R = self.easternDragonModel.RootPart.S7["Arm1.R"]
	local leg1L = self.easternDragonModel.RootPart.S19["Leg1.L"]
	local leg1R = self.easternDragonModel.RootPart.S19["Leg1.R"]
	local legJointForwardLeft = self.easternDragonModel.IKLegs.LegJointForwardLeft
	legJointForwardLeft.CFrame = arm1L.WorldCFrame * inverse * CFrame.Angles(0, 0, 3.141592653589793)
	self.legJointForwardLeftParts = storeRelativeCFrames({ legJointForwardLeft }, arm1L)
	local legJointForwardRight = self.easternDragonModel.IKLegs.LegJointForwardRight
	legJointForwardRight.CFrame = arm1R.WorldCFrame * inverse * CFrame.Angles(0, 3.141592653589793, 3.141592653589793)
	self.legJointForwardRightParts = storeRelativeCFrames({ legJointForwardRight }, arm1R)
	local legJointBackLeft = self.easternDragonModel.IKLegs.LegJointBackLeft
	legJointBackLeft.CFrame = leg1L.WorldCFrame * inverse * CFrame.Angles(0, 0, 1.5707963267948966)
	self.legJointBackLeftParts = storeRelativeCFrames({ legJointBackLeft }, leg1L)
	local legJointBackRight = self.easternDragonModel.IKLegs.LegJointBackRight
	legJointBackRight.CFrame = leg1R.WorldCFrame * inverse * CFrame.Angles(0, 0, 3.141592653589793) * CFrame.Angles(
		0,
		3.141592653589793,
		1.5707963267948966
	)
	self.legJointBackRightParts = storeRelativeCFrames({ legJointBackRight }, leg1R)
	self.legJointParts = {}
	self.legJointParts[arm1L] = self.legJointForwardLeftParts
	self.legJointParts[arm1R] = self.legJointForwardRightParts
	self.legJointParts[leg1L] = self.legJointBackLeftParts
	self.legJointParts[leg1R] = self.legJointBackRightParts
	self.forwardLeftHip = self.easternDragonModel.RootPart.S7["Arm1.L"]
	self.forwardLeftKnee = self.forwardLeftHip["Arm2.L"]
	self.forwardLeftFoot = self.forwardLeftKnee["Hand1.L"]
	self.forwardRightHip = self.easternDragonModel.RootPart.S7["Arm1.R"]
	self.forwardRightKnee = self.forwardRightHip["Arm2.R"]
	self.forwardRightFoot = self.forwardRightKnee["Hand1.R"]
	self.backLeftHip = self.easternDragonModel.RootPart.S19["Leg1.L"]
	self.backLeftKnee = self.backLeftHip["Leg2.L"]
	self.backLeftFoot = self.backLeftKnee["Foot.L"]
	self.backRightHip = self.easternDragonModel.RootPart.S19["Leg1.R"]
	self.backRightKnee = self.backRightHip["Leg2.R"]
	self.backRightFoot = self.backRightKnee["Foot.R"]
	local v = 40.32 * self.easternScaleModifier
	local v2 = 29.4 * self.easternScaleModifier
	local v3 = 40.32 * self.easternScaleModifier
	local v4 = 29.4 * self.easternScaleModifier
	local v5 = 40.32 * self.easternScaleModifier
	local v6 = 29.4 * self.easternScaleModifier
	local v7 = 40.32 * self.easternScaleModifier
	local v8 = 29.4 * self.easternScaleModifier
	self.forwardLeftLeg = IKLeg.new(legJointForwardLeft.Attachment, v, v2, true, true, true)
	self.forwardRightLeg = IKLeg.new(legJointForwardRight.Attachment, v3, v4, true, false, true)
	self.backLeftLeg = IKLeg.new(legJointBackLeft.Attachment, v5, v6, true, true, false)
	self.backRightLeg = IKLeg.new(legJointBackRight.Attachment, v7, v8, true, false, false)
	local v9 = {
		self.forwardLeftLeg,
		self.forwardRightLeg,
		self.backLeftLeg,
		self.backRightLeg
	}

	for _, v10 in ipairs(v9) do
		v10.lastFootReachesFloor = v10.footReachesFloor
		v10.lastTimeFootReachesFloorUpdated = time()
		v10.lastFootInterp = 1
	end
end

local cframe = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
CFrame.lookAt(createVector(0, 0, 0), createVector(1, 0, 0)):Inverse()

-- equivalent calls inferred from this helper; original call sites unknown
local function setBoneTransformedWorldCFrame(p, lerped: CFrame)
	p.Transform = p.WorldCFrame:Inverse() * lerped
end

function DragonMoverClass:updateLegBone(p2, p3, p4, state, flag: boolean, _: number)
	if state.lastFootReachesFloor ~= state.footReachesFloor then
		local lastFootInterp = math.clamp(
			state.lastFootInterp + (state.lastFootReachesFloor == true and -1 or 1) * (time() - state.lastTimeFootReachesFloorUpdated) / 0.3,
			0,
			1
		)
		state.lastFootReachesFloor = state.footReachesFloor
		state.lastTimeFootReachesFloorUpdated = time()
		state.lastFootInterp = lastFootInterp
	end

	local v = math.clamp(
		state.lastFootInterp + (state.footReachesFloor == true and -1 or 1) * (time() - state.lastTimeFootReachesFloorUpdated) / 0.3,
		0,
		1
	)

	if v == 1 then
		return
	end

	local transformedWorldCFrame = p2.TransformedWorldCFrame
	local unit = (state.kneeAttachment.WorldPosition - p2.TransformedWorldCFrame.Position).Unit
	setBoneTransformedWorldCFrame(
		p2,
		(alignCFrameToVectorMinimally(
			p2.TransformedWorldCFrame.Rotation * CFrame.Angles(0, 1.5707963267948966, 0):Inverse() * cframe:Inverse(),
			unit
		) * cframe * CFrame.Angles(0, 1.5707963267948966, 0) + p2.TransformedWorldCFrame.Position):Lerp(
			transformedWorldCFrame,
			v
		)
	) -- equivalent call inferred; original call site unknown
	local unit2 = (state.footAttachment.WorldPosition - p3.TransformedWorldCFrame.Position).Unit
	setBoneTransformedWorldCFrame(
		p3,
		(alignCFrameToVectorMinimally(
			p3.TransformedWorldCFrame.Rotation * CFrame.Angles(0, 1.5707963267948966, 0):Inverse() * cframe:Inverse(),
			unit2
		) * cframe * CFrame.Angles(0, 1.5707963267948966, 0) + p3.TransformedWorldCFrame.Position):Lerp(
			p3.TransformedWorldCFrame,
			v
		)
	) -- equivalent call inferred; original call site unknown

	if flag == true then
		local transformedWorldCFrame2 = p4.TransformedWorldCFrame
		local v2 = -(projectVectorOntoPlane(state.hipAttachment.WorldCFrame.RightVector, state.footUpVector)).Unit
		local footUpVector = state.footUpVector
		local unit3 = (projectVectorOntoPlane(-v2, footUpVector)).Unit
		local cross = footUpVector:Cross(unit3)
		local position = transformedWorldCFrame2.Position
		local v4 = CFrame.fromMatrix(position, cross, footUpVector, unit3) * cframe
		local v5

		if p4 == self.forwardLeftFoot then
			v5 = v4 * (CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(2.356194490192345, 0, 0))
		else
			v5 = v4 * CFrame.Angles(2.356194490192345, 0, 0)
		end

		setBoneTransformedWorldCFrame(p4, v5:Lerp(transformedWorldCFrame2, v)) -- equivalent call inferred; original call site unknown
	end
end

function DragonMoverClass:updateIK(p: number)
	if self.script.XSpiralActive.Value ~= false or self.script.CActive.Value ~= false or self.script.VActive.Value ~= false or self.script.FMidAirEndActive.Value ~= false or self._customBoneCFEnabled == true or self.isRebounding == true or self.script.FDrillActive.Value ~= false then
		return
	end

	for k, list in pairs(self.legJointParts) do
		for _, v in ipairs(list) do
			v.CFrame = k.WorldCFrame:ToWorldSpace(v:GetAttribute("RelativeCFrame"))
		end
	end

	self.forwardLeftLeg:update(p)
	self.forwardRightLeg:update(p)
	self.backLeftLeg:update(p)
	self.backRightLeg:update(p)
	self:updateLegBone(self.forwardLeftHip, self.forwardLeftKnee, self.forwardLeftFoot, self.forwardLeftLeg, true, p)
	self:updateLegBone(
		self.forwardRightHip,
		self.forwardRightKnee,
		self.forwardRightFoot,
		self.forwardRightLeg,
		true,
		p
	)
	self:updateLegBone(self.backLeftHip, self.backLeftKnee, self.backLeftFoot, self.backLeftLeg, false, p)
	self:updateLegBone(self.backRightHip, self.backRightKnee, self.backRightFoot, self.backRightLeg, false, p)
end

function DragonMoverClass:resetHistoryQueues(list, p)
	assert(
		#list == self.NUM_BONES,
		"initialBonePositions length must be NUM_BONES " .. tostring(#list) .. " ~= " .. tostring(self.NUM_BONES)
	)
	assert(
		(list[1] - self.dragonPart.Position).Magnitude < 0.01 or self._customBoneCFEnabled == true or p == true,
		"initialBonePosition[1] should be dragon head (bone) position"
	)
	self.positionHistoryQueue = arrayQueue.new(math.ceil(self.DRAGON_LENGTH / self.SAMPLE_POSITION_EVERY) * 3 + 1)
	self.distanceHistoryQueue = arrayQueue.new(self.positionHistoryQueue.capacity - 1)
	self.firstBoneAfterHeadPosition = list[2]
	local v = math.ceil((math.ceil(self.DRAGON_LENGTH / self.SAMPLE_POSITION_EVERY) * 1 + 1) / #list) * 3

	for i = #list, 2, -1 do
		local v2 = list[i]
		local v3 = list[i - 1]

		for i2 = 0, v - 1 do
			local lerped = v2:lerp(v3, i2 / v)
			self.positionHistoryQueue:enqueue(lerped)
		end
	end

	self.positionHistoryQueue:enqueue(list[1])
	self.lengthBetweenConsecutiveBones = {}

	for i = 2, #list do
		local v2 = list[i]
		local v3 = list[i - 1]
		table.insert(self.lengthBetweenConsecutiveBones, (v2 - v3).Magnitude)
	end

	local capacity = self.positionHistoryQueue.capacity

	for k, v2 in self.positionHistoryQueue:iteratorRearToFront() do
		if k == capacity then
			continue
		end

		local _, v3 = self.positionHistoryQueue:iteratorRearToFrontNext(k)
		self.distanceHistoryQueue:enqueue((math.max((v2 - v3).Magnitude, self.LENGTH_BETWEEN_BONES / v)))
	end

	self.distanceHistoryQueue:reverse()
	self.lastSampledPosition = list[1]
	assert(
		self.positionHistoryQueue.count == self.positionHistoryQueue.capacity,
		"positionHistoryQueue count must equal capacity"
	)
	assert(
		self.distanceHistoryQueue.count == self.positionHistoryQueue.capacity - 1,
		"distanceHistoryQueue count must equal capacity minus one"
	)
end

function DragonMoverClass:initVisuals()
	self:updateHeadCFrame(self.script.VActive.Origin.Value)
	self:initEasternDragonModel()
	self.NUM_BONES = #self.easternDragonModelBones
	local total = 0
	local count = 0
	local v = {}

	for i = 2, self.NUM_BONES do
		total += (self.easternDragonModelBones[i].WorldPosition - self.easternDragonModelBones[i - 1].WorldPosition).Magnitude
		count += 1
	end

	self.LENGTH_BETWEEN_BONES = math.floor(total / count + 0.5)
	self.SAMPLE_POSITION_EVERY = self.LENGTH_BETWEEN_BONES / 20
	self.DRAGON_LENGTH = self.LENGTH_BETWEEN_BONES * (self.NUM_BONES - 1)
	v[1] = self.dragonPart.Position

	for i = 2, self.NUM_BONES do
		v[i] = self.dragonPart.Position - self.initLookVector * self.LENGTH_BETWEEN_BONES * (i - 1)
	end

	self:resetHistoryQueues(v)
	self:updateBonePositions(v)
end

local function reverse(list)
	for i = 1, math.floor(#list / 2) do
		local v = #list - i + 1
		local v2 = list[v]
		local v3 = list[i]
		list[i] = v2
		list[v] = v3
	end

	return list
end

function DragonMoverClass:initEasternDragonModel()
	local rootPart = self.easternDragonModel.RootPart
	local children = {}

	for i, childName in ipairs({
		"Head",
		"S1",
		"S2",
		"S3",
		"S4",
		"S5",
		"S6",
		"S7",
		"S8",
		"S9",
		"S10",
		"S11",
		"S12",
		"S13",
		"S14",
		"S15",
		"S16",
		"S17",
		"S18",
		"S19",
		"S20",
		"S21",
		"S22",
		"S23",
		"S24",
		"S25",
		"S26",
		"S27",
		"S28",
		"S29"
	}) do
		local child = rootPart:FindFirstChild(childName)
		assert(child ~= nil, "Bone within eastern dragon model wasn't found: " .. childName)
		children[i] = child
	end

	self.easternDragonModelBones = children
	self.easternDragonRootPart = rootPart
end

function DragonMoverClass:initPhysics() end

function DragonMoverClass:initRobloxAnimations()
	self.animator = self.easternDragonModel:WaitForChild("AnimationController"):WaitForChild("Animator")
	self.animations = {}

	if _G.TestGame then
		for k, v in pairs(self.animator:GetPlayingAnimationTracks()) do
			print("hm", k, v.Animation.AnimationId)
		end
	end

	for _, animation in ipairs(self.animator:GetChildren()) do
		local track = self.animator:LoadAnimation(animation)
		self.animations[animation.Name] = track
	end

	local hair = self.animations.Hair
	hair.Priority = Enum.AnimationPriority.Core
	hair.Looped = true
	hair:Play()
	self.hairAnim = hair
	local idle = self.animations.Idle
	idle.Priority = Enum.AnimationPriority.Idle
	idle.Looped = true
	idle:Play()
	self.idleAnim = idle
	local movement = self.animations.Movement
	movement.Priority = Enum.AnimationPriority.Movement
	movement.Looped = true
	self.movementAnim = movement
	local zRecoil = self.animations.ZRecoil
	zRecoil.Priority = Enum.AnimationPriority.Movement
	zRecoil.Looped = false
	self.zRecoilAnim = zRecoil
	self.script.ZRecoilAnim.Value = zRecoil
	local mouthOpening = self.animations.MouthOpening
	mouthOpening.Priority = Enum.AnimationPriority.Movement
	mouthOpening.Looped = false
	self.mouthOpeningAnim = mouthOpening
	self.script.MouthOpeningAnim.Value = mouthOpening
	local mouthOpenedLoop = self.animations.MouthOpenedLoop
	mouthOpenedLoop.Priority = Enum.AnimationPriority.Movement
	mouthOpenedLoop.Looped = true
	self.mouthOpenedLoopAnim = mouthOpenedLoop
	self.script.MouthOpenedLoopAnim.Value = mouthOpenedLoop
	local mouthClosing = self.animations.MouthClosing
	mouthClosing.Priority = Enum.AnimationPriority.Movement
	mouthClosing.Looped = false
	self.mouthClosingAnim = mouthClosing
	self.script.MouthClosingAnim.Value = mouthClosing
end

function DragonMoverClass:updateLoopedSound(p: string)
	if self.currentDragonLoopedSound then
		if self.currentDragonLoopedSound.Name == p then
			return
		end

		Util.Sound:FadeOut(self.currentDragonLoopedSound, 0.5)
		Util.DestroyAfter(self.currentDragonLoopedSound, 0.6)
	end

	local currentDragonLoopedSound = Util.Sound:Play(p, self.hrp)
	currentDragonLoopedSound.Looped = true
	currentDragonLoopedSound.RollOffMinDistance = math.max(currentDragonLoopedSound.RollOffMinDistance, 200)
	self.currentDragonLoopedSound = currentDragonLoopedSound
end

function DragonMoverClass:enableFakePlayerInput(p2)
	self.fakePlayerInputEnabled = true

	if p2 and typeof(p2) == "Vector3" then
		self.fakePlayerInputVector = p2.Unit
	else
		self.fakePlayerInputVector = createVector(0, 0, -1)
	end
end

function DragonMoverClass:disableFakePlayerInput()
	self.fakePlayerInputEnabled = false
	self.fakePlayerInputVector = createVector(0, 0, -1)
end

function DragonMoverClass:getInputDir()
	if self.fakePlayerInputEnabled then
		return self.fakePlayerInputVector
	end

	if self.script.XSpiralActive.Value or self.script.CActive.Value or self.script.VActive.Value or self.script.FMidAirEndActive.Value or self._customBoneCFEnabled == true or self.isRebounding then
		return createVector(0, 0, 0)
	end

	local unit = self.playerModule:GetControls():GetMoveVector().Unit

	if unit == unit then
		return unit
	end

	return createVector(0, 0, 0)
end

local function nudgeInterpolate(p, p2, p3)
	if math.abs(p - p2) < 1.5 * p3 then
		return p
	end

	return p + math.sign(p2 - p) * p3
end

function DragonMoverClass:getAccumulatedInputTime()
	if localPlayer ~= self.player then
		return self.script.AccumulatedInputTime.Value
	end

	local lastInputActive = self.currentSpeed > 0

	if self.bodyMoverActive == true or self.char:FindFirstChild("FreezeDragonTag") then
		lastInputActive = false
	end

	if self.lastInputActive ~= lastInputActive then
		if lastInputActive == true then
			self.lastInputActiveTime = time()
		else
			local v2 = time() - self.lastInputActiveTime
			self.lastAccumulatedInputTime += v2
		end
	end

	local lastAccumulatedInputTime

	if lastInputActive == true then
		local v2 = time() - self.lastInputActiveTime
		lastAccumulatedInputTime = self.lastAccumulatedInputTime + v2
	else
		lastAccumulatedInputTime = self.lastAccumulatedInputTime
	end

	self.lastInputActive = lastInputActive
	return lastAccumulatedInputTime
end

local function slerp(vector2: Vector3, vector3: Vector3, p: number)
	local unit = vector2.Unit
	local unit2 = vector3.Unit
	local dot = unit:Dot(unit2)

	if dot > 0.9995 then
		return (unit + p * (unit2 - unit)).Unit
	end

	local v = math.clamp(dot, -1, 1)
	local v2 = math.acos(v) * p
	local v3 = math.sin(v2)
	local unit3 = (unit2 - unit * v).Unit

	if v < -0.9995 then
		unit3 = CFrame.lookAlong(createVector(0, 0, 0), unit).RightVector
	end

	return (unit * math.cos(v2) + unit3 * v3).Unit
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicHermite(p, p2, p3, p4, p5)
	return (2 * p ^ 3 - 3 * p ^ 2 + 1) * p2 + (p ^ 3 - 2 * p ^ 2 + p) * p3 + (-2 * p ^ 3 + 3 * p ^ 2) * p4 + (p ^ 3 - p ^ 2) * p5
end

function arrayToSpaceCurve(list, p: number)
	local v = 1 - p
	local count = #list

	if v == 1 then
		return list[count]
	end

	local v2 = count == 2 and 1 or math.floor(v * (count - 1)) + 1
	local v3 = v2 + 1

	if count ~= 2 then
		v = v * (count - 1) - (v2 - 1)
	end

	return list[v2]:Lerp(list[v3], v)
end

function DragonMoverClass:getDebugPart(p: string, p2)
	local v = workspace:FindFirstChild(p .. "_DragonMoverDebug")

	if v ~= nil then
		return v
	end

	v = Instance.new("Part")
	v.CastShadow = false
	v.CanCollide = false
	v.CanTouch = false
	v.CanQuery = false
	v.TopSurface = 0
	v.BottomSurface = 0
	v.Anchored = true
	v.Name = p .. "_DragonMoverDebug"
	v.Parent = p2 or workspace
	return v
end

function DragonMoverClass:visualizeVector(p: string, vector2: Vector3, vector3: Vector3, p2: number, p3: number)
	local debugPart = self:getDebugPart(p)
	local unit = vector3.Unit
	debugPart.Size = Vector3.new(p3, p3, p2)
	debugPart.CFrame = CFrame.lookAt(vector2, vector2 + unit * p2) * CFrame.new(0, 0, -p2 * 0.5 + 0.01 * math.random())
	debugPart.Material = Enum.Material.Neon
	local v = math.atan2(unit.X, unit.Z)
	local v2 = math.acos(unit.Y)
	local v3 = ((v + 3.141592653589793) / 12.566370614359172 + v2 / 6.283185307179586) % 1
	debugPart.Color = Color3.fromHSV(v3, 1, 1)
	local debugPart2 = self:getDebugPart(p .. "_Arrowhead")
	debugPart2.Shape = Enum.PartType.Ball
	debugPart2.Size = Vector3.new(p3, p3, p3) * 2
	debugPart2.CFrame = CFrame.new(vector2 + unit * p2)
	debugPart2.Color = debugPart.Color
	debugPart2.Material = Enum.Material.Neon
	return debugPart
end

function DragonMoverClass:debugSpaceCurve(callback, p: number)
	assert(p > 1, "DragonMoverClass:debugSpaceCurve: numParts must be greater than 1")

	for i = 1, p do
		local debugPart = self:getDebugPart(tostring(tick()), workspace._WorldOrigin)
		Util.DestroyAfter(debugPart, 128)
		debugPart.Size = createVector(2, 2, 2)
		debugPart.Shape = Enum.PartType.Ball
		local v = (i - 1) / (p - 1)
		debugPart.CFrame = CFrame.new(callback(v))
		debugPart.Color = Color3.new(v, v, v)
	end
end

function DragonMoverClass:switchCameraToProxyPart(flag: boolean, _: boolean)
	if localPlayer ~= self.player then
		return
	end

	if flag == true then
		if not self.customCameraActive then
			self.customCameraActive = true
			local currentCamera = workspace.CurrentCamera
			self.proxyCameraPart.CFrame = currentCamera.CFrame
			local clone = self.proxyCameraPart:Clone()
			clone.Parent = self.proxyCameraPart
			task.spawn(function()
				local spring = Util.Spring.new(1.5, 1.5, self.proxyCameraPart.Position)
				local v = 0.016666666666666666

				while self.customCameraActive do
					spring:SetGoal(self.proxyCameraPart.Position)
					spring:Update(v)

					if self.springTimer > 0 then
						self.springTimer -= v

						if self.springTimer < 0 then
							self.springTimer = 0
						end

						local position = spring:GetPosition()

						if self.springTimer < 0.1 then
							position = position:Lerp(self.proxyCameraPart.Position, 1 - self.springTimer / 0.1)
						end

						clone.CFrame = CFrame.new(position) * (self.proxyCameraPart.CFrame - self.proxyCameraPart.Position) + self:getCameraOffset()
					else
						clone.CFrame = self.proxyCameraPart.CFrame + self:getCameraOffset()
					end

					spring.f = math.clamp(0.5 - self.springTimer, 0, 0.5) / 0.5 * 2.5 + 1.5
					v = RunService.PreSimulation:Wait()
				end

				clone:Destroy()
			end)
			currentCamera.CameraSubject = clone
		end
	else
		self.customCameraActive = nil
		workspace.CurrentCamera.CameraSubject = self.humanoid
	end
end

function DragonMoverClass:switchSineSmooth(p2, p3, p4, p5, p6, p7)
	local v = p2 / p6 * math.sin(p3 * (p4 - p5))

	if v >= -1 and v <= 1 then
		self.currentSinusoidalOffset = p4 - (math.floor((math.sign(-math.cos(p3 * (p4 - p5))) + 1) / 2) * (3.141592653589793 / p7) - (2 * math.floor((math.sign(-math.cos(p3 * (p4 - p5))) + 1) / 2) - 1) * math.asin(p2 / p6 * math.sin(p3 * (p4 - p5))) / p7)
	else
		self.currentSinusoidalOffset = p4 - p3 / p7 * (p4 - p5)
	end
end

function DragonMoverClass:setSinusoidalHeightOffsetToZero()
	self.currentSinusoidalOffset = self:getAccumulatedInputTime()
end

local function reflect(vector2, p)
	return vector2 - 2 * vector2:Dot(p) * p
end

function DragonMoverClass:getFPS(p2)
	local _ = self.timeStepHistoryQueue.capacity
	local total = 0

	if self.timeStepHistoryQueue.count >= self.timeStepHistoryQueue.capacity then
		self.timeStepHistoryQueue:dequeue()
	end

	self.timeStepHistoryQueue:enqueue(p2)

	for _, v in self.timeStepHistoryQueue:iteratorRearToFront() do
		total += 1 / v
	end

	return total / self.timeStepHistoryQueue.count
end

function DragonMoverClass:reboundDragon()
	if self.isRebounding ~= true then
		self.ReboundDidCollideWithWall = nil
	elseif self.script.FDrillActive.Value == true or self.script.XSpiralActive.Value == true or self.script.CActive.Value == true or self.script.VActive.Value == true or self.script.FMidAirEndActive.Value == true then
		self.isRebounding = false
		self:disableCustomBoneCFrameMode()
	else
		local TIME_REBOUNDING_UP = self.TIME_REBOUNDING_UP
		local v = slerp(createVector(0, 1, 0), self.script.Parent.CameraCFrame.Value.LookVector, 0.25)
		local v2 = time() - self.initialReboundTime

		local function fn(p: number)
			return self.initialReboundPosition + (CFrame.lookAt(createVector(0, 0, 0), v) * CFrame.new(
				0,
				0,
				-35 * self.easternScaleModifier
			) * CFrame.Angles(p * 2.5 * 3.141592653589793, 0, 0) * CFrame.new(0, 0, 35 * self.easternScaleModifier)).Position + CFrame.lookAt(
				createVector(0, 0, 0),
				v
			).RightVector * p * 20 * self.easternScaleModifier + createVector(0, 1, 0) * p * 30 * self.easternScaleModifier
		end

		local v3 = 0.5

		local function fn2(p)
			if p <= v3 then
				return (self.initialReboundBodySpaceCurve(p / v3))
			end

			return (fn((p - v3) / (1 - v3)))
		end

		local v4, v5 = spaceCurveUniformSpeed(fn2, self.initialReboundTime)
		v3 = self.DRAGON_LENGTH / self.easternScaleModifier / v5
		local v6 = v2 / TIME_REBOUNDING_UP
		local v7 = math.clamp(v6 * (1 - v3) + v3, 0, 1)
		local v8 = math.clamp(v7 - v3, 0, 1)

		if self.ReboundDidCollideWithWall ~= true and v6 > 0.5 then
			self.ReboundDidCollideWithWall = self:detectClippingUpToBone(5, fn2, v8, v7, true)
		end

		if self.ReboundDidCollideWithWall ~= true then
			self:updateBonePositionsAlongSpaceCurve(v4, v8, v7)
		end
	end
end

local v = {}

function spaceCurveUniformSpeed(callback, p)
	if v[p] ~= nil then
		return v[p][1], v[p][2]
	end

	local v2 = {}
	local total = 0
	local v3 = callback(total)
	table.insert(v2, v3)
	local count = 0
	local total2 = 0

	while true do
		count += 1
		total += 0.002
		local v4 = callback(total)
		total2 += (v4 - v3).Magnitude

		if total2 >= 1 or count > 750 then
			total2 = 0

			if total < 1 then
				table.insert(v2, v4)
			end

			if total >= 1 or count > 750 then
				local v5 = (#v2 - 1) * 1
				local v6 = callback(1)
				local v7 = v5 + (v6 - v2[#v2]).Magnitude
				table.insert(v2, v6)

				local function fn(p2)
					return arrayToSpaceCurve(v2, 1 - p2)
				end

				v[p] = { fn, v7 }
				task.delay(10, function()
					v[p] = nil
				end)
				return fn, v7
			end
		end

		v3 = v4
	end
end

function DragonMoverClass:updateBonePositionsAlongSpaceCurve(callback, p: number, p2: number)
	local v2

	if p >= 0 then
		v2 = p <= 1
	else
		v2 = false
	end

	assert(v2)
	local v3

	if p2 >= 0 then
		v3 = p2 <= 1
	else
		v3 = false
	end

	assert(v3)
	local bonePositions = self:getBonePositions()
	local v4 = #bonePositions
	local v5 = {}

	for i, _ in ipairs(bonePositions) do
		local v6 = (i - 1) / (v4 - 1)
		v5[i] = callback(lerp(p2, p, v6))

		if v5[i] == nil then
			return
		end
	end

	self:updateBonePositions(v5)
end

function DragonMoverClass:detectClippingUpToBone(p2: number, callback, p3: number, p4: number, flag: boolean?)
	local v2

	if p3 >= 0 then
		v2 = p3 <= 1
	else
		v2 = false
	end

	assert(v2, "interpTail must be between 0 and 1")
	local v3

	if p4 >= 0 then
		v3 = p4 <= 1
	else
		v3 = false
	end

	assert(v3, "interpHead must be between 0 and 1")
	local v4

	if p2 > 0 then
		v4 = p2 <= self.NUM_BONES
	else
		v4 = false
	end

	assert(v4, "boneIndex must be between 1 and NUM_BONES")
	local v5 = math.min(p2 + 1, self.NUM_BONES)
	local v6 = {}

	for i = 1, v5 do
		local v7 = (i - 1) / (self.NUM_BONES - 1)
		local v8 = callback(lerp(p4, p3, v7))

		if v8 == nil then
			warn("DragonMoverClass.detectClippingUpToBone: Nil curve position")
			v6[i] = v6[#v6]
		elseif typeof(v8) == "Vector3" then
			v6[i] = v8
		else
			warn("DragonMoverClass.detectClippingUpToBone: Non-vector3 curve position")
			v6[i] = v6[#v6]
		end
	end

	for i = v5 - 1, 1, -1 do
		local v7 = v6[i]
		local v8 = v7 - v6[i + 1]

		if not (v8.Magnitude > 0) then
			continue
		end

		local v9 = 0.5 * (self.dragonPart.Size.Y * 0.5 + 1)
		local v10

		if flag == true then
			v10 = workspace:Raycast(v7, v8, raycastParams)
		else
			v10 = workspace:Spherecast(v7, v9, v8, raycastParams)
		end

		if v10 then
			return true
		end
	end

	return false
end

function DragonMoverClass:XSpiralCurve(p2: number)
	local value = self.script.XSpiralActive.TIME_SPIRALLING.Value
	local value2 = self.script.XSpiralActive.TIME_UNTIL_IMPACT.Value
	local value3 = self.script.XSpiralActive.Origin.Value
	local value4 = self.script.XSpiralActive.ImpactPosition.Value
	local v2 = p2 * (value + value2)

	if v2 < value then
		local v3 = v2 / value
		local v4 = math.min(v3 * 4, 0.4) + v3 * 0.6 + math.sin(v3 * 3.141592653589793 * 8) * 0.1

		if v3 > 0.75 then
			v4 = 0.8499999999999999 - 0.9 * (v3 - 0.75) / 0.25
		end

		return value3 + CFrame.Angles(0, 25.132741228718345 * v3, 0).LookVector * v4 * 200 + createVector(0, 140, 0) * v3
	else
		local _ = 1 * 0.6 + 0.4 + -9.797174393178826e-17
		local v3 = v2 - value
		local v4 = value3 + CFrame.Angles(0, 25.132741228718345, 0).LookVector * 0.09999999999999998 * 200 + createVector(
			0,
			140,
			0
		)
		local v5 = v4 - (value3 + CFrame.Angles(0, 24.881413816431163, 0).LookVector * 0.99 * 200 + createVector(
			0,
			138.6,
			0
		))
		local v6 = value2 * 0.4
		local v7 = value3 + createVector(0, 140, 0)
		local v8 = v5.Magnitude * createVector(-0, -1, -0)

		if v3 < v6 then
			return cubicHermite(v3 / v6, v4, v5, v7, v8)
		end

		if v3 < value2 then
			return v7:Lerp(value4, (v3 - v6) / (value2 - v6))
		end

		return nil
	end
end

function DragonMoverClass:VTransformationCurve(p2: number)
	local v2 = 0.5 * self.script.VActive.V_ANIMATION_LASTS_FOR.Value
	local v3 = 0.5 * self.script.VActive.V_ANIMATION_LASTS_FOR.Value
	local v4 = 200 * self.easternScaleModifier
	local position = self.script.VActive.Origin.Value.Position
	local position2 = self.script.VActive.Impact.Value.Position
	local v5 = p2 * (v2 + v3)

	if v5 < v2 then
		local v6 = v5 / v2
		local v7 = math.min(v6 * 4, 0.4) + v6 * 0.6 + math.sin(v6 * 3.141592653589793 * 8) * 0.1

		if v6 > 0.75 then
			v7 = 0.8499999999999999 - 0.9 * (v6 - 0.75) / 0.25
		end

		return position + CFrame.Angles(0, 25.132741228718345 * v6, 0).LookVector * v7 * v4 + createVector(0, 140, 0) * v6
	else
		local _ = 1 * 0.6 + 0.4 + -9.797174393178826e-17
		local v6 = v5 - v2
		local v7 = position + CFrame.Angles(0, 25.132741228718345, 0).LookVector * 0.09999999999999998 * v4 + createVector(
			0,
			140,
			0
		)
		local v8 = v7 - (position + CFrame.Angles(0, 24.881413816431163, 0).LookVector * 0.99 * v4 + createVector(
			0,
			138.6,
			0
		))
		local v9 = v3 * 0.25
		local v10 = position + createVector(0, 140, 0)
		local v11 = v8.Magnitude * createVector(-0, -1, -0)

		if v6 < v9 then
			return cubicHermite(v6 / v9, v7, v8, v10, v11)
		end

		if v6 < v3 then
			return v10:Lerp(position2, (v6 - v9) / (v3 - v9))
		end

		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sinBounceCurve(p, p2)
	return (function(p3)
		return -0.9878048780487805 * (p3 - 3.17) + math.log(1 + 0.19512195121951223 * (p3 - 3.17)) * 2.1874999999999996
	end)((p + 1.5707963267948966) % 6.283185307179586 - 1.5707963267948966) * p2 + math.sin(p) * (1 - p2)
end

function DragonMoverClass:getSinusoidalInterpolationParameter()
	local v2 = ((self:getAccumulatedInputTime() - self.currentSinusoidalOffset) * self.currentSinusoidalFrequency - 4.71238898038469) / 6.283185307179586
	return v2 % 1, v2
end

os.clock()

function DragonMoverClass:physicsUpdate(p)
	local dragonPart = self.dragonPart
	local goalAttach = self.goalAttach
	local _ = self.alignPosition
	local _ = self.alignOrientation
	local v2, unit

	if localPlayer == self.player then
		v2 = self:getInputDir()
		unit = workspace.CurrentCamera.CFrame:VectorToWorldSpace(v2)
	else
		unit = createVector(0, 0, 0)
		v2 = createVector(0, 0, 0)
	end

	if self.script.FDrillActive.Value == true and localPlayer == self.player and self.mouse then
		unit = (self.mouse.Hit.Position - workspace.CurrentCamera.CFrame.Position).Unit
	end

	if unit == createVector(0, 0, 0) then
		self.goalLookVector = self.currentLookVector
	else
		self.goalLookVector = unit
	end

	local spherecast = workspace:Spherecast(
		dragonPart.Position,
		self.dragonPart.Size.Y * 0.5 + 1,
		self.currentLookVector * (self.LENGTH_BETWEEN_BONES + 14),
		raycastParams
	)

	if spherecast and spherecast.Normal.Y < 0.1 then
		local v3

		if self.currentLookVector:Angle(-spherecast.Normal) < 0.7853981633974483 then
			local currentLookVector = self.currentLookVector
			local normal = spherecast.Normal
			v3 = currentLookVector - 2 * currentLookVector:Dot(normal) * normal
		else
			v3 = projectVectorOntoPlane(self.currentLookVector, spherecast.Normal)
		end

		if v3 ~= createVector(0, 0, 0) then
			local currentLookVector = self.currentLookVector
			self.currentLookVector = v3.Unit

			if self._headAimingEnabled ~= true and currentLookVector:Dot(self.currentLookVector) < 0.5 and self.script.FDrillActive.Value == false and self._customBoneCFEnabled == false and self.player == localPlayer and time() - self.prevCollisionDebounceTime > 0.2 then
				self.prevCollisionDebounceTime = time()
				Effect.new("Dragon2.TransformedEastern.WallCollision"):replicate({
					player = self.player,
					cf = CFrame.new(spherecast.Position + spherecast.Normal)
				})
				self.DragonCollisionVFXRemote:FireServer(CFrame.new(spherecast.Position + spherecast.Normal))
			end
		end
	end

	local raycastResult = workspace:Raycast(
		dragonPart.Position,
		self.goalLookVector * (self.LENGTH_BETWEEN_BONES + 14),
		raycastParams
	)

	if raycastResult and raycastResult.Normal.Y > 0.1 then
		local lookVector = Util.Misc.AlignCFrame(
			CFrame.lookAt(createVector(0, 0, 0), self.goalLookVector) + dragonPart.Position,
			raycastResult.Normal
		).LookVector

		if lookVector ~= createVector(0, 0, 0) then
			self.goalLookVector = lookVector
		end
	end

	if self.runningOnGround == true and self.script.FDrillActive.Value ~= true then
		if self.currentLookVector.Y < 0 then
			self.currentLookVector = (createVector(1, 0, 1) * self.currentLookVector).Unit
		else
			self.currentLookVector = (createVector(1, 0.5, 1) * self.currentLookVector).Unit
		end

		if self.goalLookVector.Y < 0 then
			self.goalLookVector = (createVector(1, 0, 1) * self.goalLookVector).Unit
		else
			self.goalLookVector = (createVector(1, 0.5, 1) * self.goalLookVector).Unit
		end
	end

	local v3 = math.acos((math.clamp(self.currentLookVector.Unit:Dot(self.goalLookVector.Unit), -1, 1)))

	if 60 * p * self.currentTurnSpeed < v3 then
		self.currentLookVector = slerp(self.currentLookVector, self.goalLookVector, 60 * p * self.currentTurnSpeed / v3)
	else
		self.currentLookVector = self.goalLookVector
	end

	if localPlayer ~= self.player then
		self.currentLookVector = self.script.Parent.DragonCFrameWithoutOffset.Value.LookVector
	end

	if self.currentLookVector == createVector(0, 0, 0) then
		self.currentLookVector = self.prevCurrentLookVector
	end

	if self.currentLookVector ~= self.currentLookVector then
		self.currentLookVector = self.prevCurrentLookVector
		self.goalLookVector = self.prevCurrentLookVector
	end

	if v2 == createVector(0, 0, 0) then
		if self.script.FDrillActive.Value == false then
			self.currentSpeed = 0
		end
	else
		self.currentSpeed = self.currentMaxSpeed
	end

	if self.currentSpeed > 0 or self.player ~= localPlayer and self.IsIdle.Value == false or self.script.XSpiralActive.Value == true or self.script.CActive.Value == true or self.script.VActive.Value == true or self.script.FMidAirEndActive.Value == true or self.script.FDrillActive.Value == true or self.isRebounding == true then
		self.idleActive = false

		if self.idleActive ~= self.lastIdleActive then
			if self.haloTask then
				task.cancel(self.haloTask)
				self.haloTask = nil
			end

			if not (self.script.HeadAimModeActive.Value or self.script.CActive.Value) then
				self:SetHaloVisible(false)
			end

			self.movementAnim:Play(0.5)

			if localPlayer == self.player then
				self.DragonIdleRemote:FireServer(false)
			end
		end

		self.idleSineAmplitude = lerp(self.idleSineAmplitude, 0, 0.1)
	else
		self.idleActive = true

		if self.idleActive ~= self.lastIdleActive then
			local v4 = self.HALO_IDLE_DELAY + math.max(0, 1.4 - (time() - self.haloCooldown))
			self.haloTask = task.delay(v4, function()
				self:SetHaloVisible(true)
			end)
			self.movementAnim:Stop(0.5)

			if localPlayer == self.player then
				self.DragonIdleRemote:FireServer(true)
			end
		end

		self.idleSineAmplitude = lerp(self.idleSineAmplitude, self.IDLE_SINE_MAX_AMPLITUDE, 0.1)
	end

	self.lastIdleActive = self.idleActive
	local v4 = self.dragonPart.Size.Y * 0.5 + 1 + (self.script.FDrillActive.Value and 39 or 0)
	local v5

	if self.runningOnGround == false then
		v5 = v4 + 2 + 8
	else
		v5 = v4 + 2 * self.GROUND_SINUSOIDAL_AMPLITUDE + 4 + 8
	end

	local v6 = 1

	if self.char:FindFirstChild("FreezeDragonTag") then
		v6 = 0.01
	elseif not self.script.FDrillActive.Value then
		v6 = 1 - self.ATTACK_SPEED_NERF * math.min(1, (time() - self.lastAttackTime) / self.ATTACK_SPEED_NERF_TIME) + (self.isAttacking and 0 or self.ATTACK_SPEED_NERF * math.min(
			1,
			(time() - self.lastAttackReleaseTime) / self.ATTACK_SPEED_RECOVERY_TIME
		))
	end

	local v7 = v6 > 0.5 and self.stun and self.stun.Value > 0 and 0.5 or v6
	self.positionWithoutOffset += self.currentSpeed * v7 * self.currentLookVector * p
	local cframe2

	if self.firstBoneAfterHeadPosition then
		cframe2 = CFrame.lookAlong(createVector(0, 0, 0), dragonPart.Position - self.firstBoneAfterHeadPosition)
	else
		cframe2 = CFrame.new()
	end

	local bounceParameter

	if self.runningOnGround == true then
		bounceParameter = lerp(self.bounceParameter, 0.35, 0.1 * (60 * p))
	else
		bounceParameter = lerp(self.bounceParameter, 0, 0.1 * (60 * p))
	end

	self.bounceParameter = bounceParameter
	local raycastResult2 = workspace:Raycast(dragonPart.Position, createVector(-0, -1, -0) * v5, raycastParams)

	if self.runningOnGround == true and raycastResult2 and raycastResult2.Normal.Y > 0.7 then
		self.sinusoidalUpVector = slerp(self.sinusoidalUpVector, raycastResult2.Normal, 6 * p)
	else
		self.sinusoidalUpVector = slerp(self.sinusoidalUpVector, createVector(0, 1, 0), 6 * p)
	end

	local v10 = self.sinusoidalUpVector * sinBounceCurve(
		(self:getAccumulatedInputTime() - self.currentSinusoidalOffset) * self.currentSinusoidalFrequency,
		self.bounceParameter
	) * self.currentSinusoidalAmplitude
	self:reboundDragon()
	local v11

	if self.script.FDrillActive.Value == true then
		if self._customBoneCFEnabled == true then
			self:disableCustomBoneCFrameMode()
		end

		if self:getFPS(p) >= 25 then
			local v12 = not self.script.FDrillActive:GetAttribute("Ending") and 1 or math.max(
				0,
				1 - (workspace:GetServerTimeNow() - self.script.FDrillActive:GetAttribute("Ending")) / 0.2
			)
			v10 = (CFrame.lookAlong(createVector(0, 0, 0), self.currentLookVector) * CFrame.Angles(
				0,
				0,
				-(self:getAccumulatedInputTime() - self.currentSinusoidalOffset) * 18.84955592153876
			)).UpVector * v12 * 40 * (math.cos(37.69911184307752 * (self:getAccumulatedInputTime() - self.currentSinusoidalOffset)) * 0.2 + 1)
		else
			v10 = createVector(0, 0, 0)
		end

		if math.acos(((createVector(-0, -1, -0)):Dot(self.currentLookVector))) < math.rad(self.script.FDrillActive.DOWNWARD_ANGLE_MAX_OFFSET.Value) then
			self.currentMaxSpeed = self.script.FDrillActive.DOWNWARD_FLIGHT_SPEED.Value
		else
			self.currentMaxSpeed = self.script.FDrillActive.FLIGHT_SPEED.Value
		end

		self.currentSpeed = self.currentMaxSpeed
		self.springTimer = 0.5
		self.proxyCameraPart.Position = self.positionWithoutOffset + createVector(0, 1, 0) * self.heightDifference
		v11 = true
	else
		v11 = false
	end

	if self.script.FMidAirEndActive.Value == true then
		local v12 = 70 * self.easternScaleModifier
		local value = self.script.FMidAirEndActive.F_MID_AIR_END_ANIMATION_LASTS_FOR.Value
		local v13 = 0.8 * value
		local v14 = value - v13
		local v15 = CFrame.lookAlong(
			createVector(0, 0, 0),
			self.FInitBodySpaceCurve(1) - self.FInitBodySpaceCurve(0.999)
		) + self.FInitBodySpaceCurve(1)

		if self.player == localPlayer then
			v15 = CFrame.lookAlong(createVector(0, 0, 0), self.currentLookVector) + self.FEndInitCF.Position - self.currentSpeed * self.currentLookVector * p
		end

		if self.script.FMidAirEndActive:GetAttribute("FromTransformation") == true then
			v15 = self.FEndInitCF.Rotation + self.FInitBodySpaceCurve(1)
		end

		v11 = true
		self.springTimer = 0.5
		self.proxyCameraPart.Position = v15.Position + Vector3.new(0, self.heightDifference, 0)
		local position = v15.Position

		local function fn(p2)
			local v16 = p2 ^ 1.35
			local v17 = v12

			if v16 < 0.25 then
				v17 *= v16 / 0.25
			end

			local v18 = (v15 * CFrame.Angles(0, 11.938052083641214 * v16, 0) * CFrame.new(0, 0, -v17)).Position + v15.UpVector * 40 * 10 * v16 * (v16 - 0.6666666666666666) * (v16 - 1)
			raycastResult2 = nil
			local raycastResult3 = workspace:Raycast(position, v18 - position, raycastParams)

			if raycastResult3 and self.script.FMidAirEndActive:GetAttribute("FromTransformation") ~= true then
				position = raycastResult3.Position + raycastResult3.Normal
				return raycastResult3.Position
			end

			position = v18
			return v18
		end

		local v16 = (time() - self.FEndInitTime) / (v13 + v14)
		local lerped = lerp(0.5, 0.25, v16)
		local v17 = math.clamp(v16 * (1 - lerped) + lerped, 0, 1)
		local v18 = math.clamp(v17 - lerped, 0, 1)

		local function fn2(p2)
			if p2 < lerped then
				return (self.FInitBodySpaceCurve(p2 / lerped))
			end

			return (fn((p2 - lerped) / (1 - lerped)))
		end

		if self.script.FMidAirEndActive:GetAttribute("FromTransformation") == true then
			if self.VEndDidCollideWithWall ~= true then
				self.VEndDidCollideWithWall = self:detectClippingUpToBone(5, fn2, v18, v17)
			end

			if self.VEndDidCollideWithWall ~= true then
				self:updateBonePositionsAlongSpaceCurve(fn2, v18, v17)
			end
		else
			self:updateBonePositionsAlongSpaceCurve(fn2, v18, v17)
		end

		local v19 = CFrame.lookAlong(createVector(0, 0, 0), self.currentLookVector) + dragonPart.Position
		self.DragonCFrameWithoutOffset.DragonCFrameWithoutOffsetClient.Value = v19

		if localPlayer == self.player then
			self.DragonCFrameRemote:FireServer(v19)
		end
	else
		self.VEndDidCollideWithWall = nil
	end

	if self.script.XSpiralActive.Value == true then
		local value = self.script.XSpiralActive.TIME_SPIRALLING.Value
		local value2 = self.script.XSpiralActive.TIME_UNTIL_IMPACT.Value
		local value3 = self.script.XSpiralActive.Origin.Value
		v11 = true
		self.proxyCameraPart.Position = value3 * createVector(1, 0, 1) + self.hrp.Position * createVector(0, 1, 0)
		local lerped = 0.2
		local v12 = (time() - self.XInitTime) / (value + value2)
		local v13 = lerped / (1 - lerped)

		if v13 <= v12 then
			lerped = lerp(lerped, 0.3, (v12 - v13) / (1 - v13))
		end

		local v14 = math.clamp(v12 * (1 - lerped) + lerped, 0, 1)
		self:updateBonePositionsAlongSpaceCurve(function(p2)
			if p2 < lerped then
				return (self.XInitBodySpaceCurve(p2 / lerped))
			end

			return (self:XSpiralCurve((p2 - lerped) / (1 - lerped)))
		end, math.clamp(v14 - lerped, 0, 1), v14)
	end

	if self.script.CActive.Value == not self.CFrozen then
		local v12 = 200 * self.easternScaleModifier
		local v13 = 100 * self.easternScaleModifier
		local value = self.script.CActive.C_ANIMATION_LASTS_FOR.Value
		local v14 = 0.8 * value
		local v15 = value - v14
		local cInitCF = self.CInitCF
		v11 = true
		self.springTimer = 0.5
		self.proxyCameraPart.Position = cInitCF.Position * createVector(1, 0, 1) + self.hrp.Position * createVector(
			0,
			1,
			0
		)
		local position = cInitCF.Position

		local function fn(p2)
			local v16 = v12
			local v17 = v13

			if p2 < 0.33 then
				v17 *= p2 / 0.33
			elseif p2 > 0.66 then
				v17 *= 1 - 1 * (p2 - 0.66) / 0.34
			end

			local _ = p2 > 0.75
			local v18

			if p2 > 0.7 then
				v18 = v16 * (1 - (0.4 * (p2 - 0.7) / 0.3) ^ 1.8)
			else
				v18 = v16 * (p2 / 0.7) ^ 0.9
			end

			local position2 = (cInitCF * CFrame.Angles(0, 9.42477796076938 * p2, 0) * CFrame.new(0, v18, -v17)).Position
			local raycastResult3 = workspace:Raycast(position, position2 - position, raycastParams)

			if raycastResult3 then
				position = raycastResult3.Position + raycastResult3.Normal
				return raycastResult3.Position
			end

			position = position2
			return position2
		end

		local v16 = (time() - self.CInitTime) / (v14 + v15)
		local lerped = lerp(0.5, 0.35, v16)
		local v17 = math.clamp(v16 * (1 - lerped) + lerped, 0, 1)
		local v18 = math.clamp(v17 - lerped, 0, 1)

		local function fn2(p2)
			if p2 < lerped then
				return (self.CInitBodySpaceCurve(p2 / lerped))
			end

			return (fn((p2 - lerped) / (1 - lerped)))
		end

		if self.CDidCollideWithWall ~= true then
			self.CDidCollideWithWall = self:detectClippingUpToBone(5, fn2, v18, v17, true)
		end

		if self.CDidCollideWithWall ~= true then
			self:updateBonePositionsAlongSpaceCurve(fn2, v18, v17)
		end

		local v19 = CFrame.lookAlong(createVector(0, 0, 0), self.currentLookVector) + dragonPart.Position
		self.DragonCFrameWithoutOffset.DragonCFrameWithoutOffsetClient.Value = v19

		if localPlayer == self.player then
			self.DragonCFrameRemote:FireServer(v19)
		end
	else
		self.COrigin = nil
		self.CDidCollideWithWall = nil
	end

	if self.script.VActive.Value and self.VInitTime ~= nil then
		local v12 = 0.5 * self.script.VActive.V_ANIMATION_LASTS_FOR.Value
		local v13 = 0.5 * self.script.VActive.V_ANIMATION_LASTS_FOR.Value
		local position = self.script.VActive.Origin.Value.Position
		local position2 = self.script.VActive.Impact.Value.Position
		local position3 = self.script.VActive.RootOrigin.Value.Position
		local v14 = (time() - (self.VInitTime or 0)) / (v12 + v13)
		self.proxyCameraPart.Position = position * createVector(1, 0, 1) + position3:Lerp(
			position2:Lerp(position, 0.6),
			(math.min(1, v14 * 0.5))
		) * createVector(0, 1, 0)
		local v15 = math.clamp(v14 * 0.8 + 0.2, 0, 1)
		self:updateBonePositionsAlongSpaceCurve(function(p2)
			if p2 < 0.2 then
				return (self.VInitBodySpaceCurve(p2 / 0.2))
			end

			return (self:VTransformationCurve((p2 - 0.2) / 0.8))
		end, math.clamp(v15 - 0.2, 0, 1), v15)
		v11 = true
	end

	if self.script.XSpiralActive.Value == false and self.script.CActive.Value == false and self.script.VActive.Value == false and self.script.FMidAirEndActive.Value == false and self._customBoneCFEnabled ~= true and self.currentSpeed > 0 and self.isRebounding ~= true then
		local raycastResult3 = workspace:Raycast(
			dragonPart.Position,
			self.positionWithoutOffset - dragonPart.Position,
			raycastParams
		)

		if raycastResult3 then
			self.positionWithoutOffset = raycastResult3.Position + raycastResult3.Normal * 0.1
		end

		local v12 = dragonPart.Position * createVector(1, 0, 1) + self.positionWithoutOffset * createVector(0, 1, 0)
		local v13 = self.currentSinusoidalAmplitude + v4 + 8
		local raycastResult4 = workspace:Raycast(v12, v13 * createVector(-0, -1, -0), raycastParams)

		if raycastResult4 then
			local v14 = self.positionWithoutOffset * createVector(0, 1, 0)
			local v15 = (raycastResult4.Position.Y + v13 + 0.1) * createVector(0, 1, 0)
			self.positionWithoutOffset = self.positionWithoutOffset * createVector(1, 0, 1) + v14:Lerp(v15, 0.1)
		end

		if self.script.FDrillActive.Value == false then
			local v14 = v4 + 10

			if v14 < (self.positionWithoutOffset * createVector(1, 0, 1) - dragonPart.Position * createVector(1, 0, 1)).Magnitude then
				local v15 = self.positionWithoutOffset * createVector(1, 0, 1) - dragonPart.Position * createVector(
					1,
					0,
					1
				)
				self.positionWithoutOffset = self.positionWithoutOffset * createVector(0, 1, 0) + dragonPart.Position * createVector(
					1,
					0,
					1
				) + v15.Unit * (v14 - 0.1)
			end
		end
	end

	if self.script.XSpiralActive.Value == false and self.script.FMidAirEndActive.Value == false and self.script.CActive.Value == false and self.script.VActive.Value == false and self._customBoneCFEnabled ~= true and (self.positionWithoutOffset - dragonPart.Position).Magnitude > 100 and self.isRebounding ~= true and self.player == localPlayer then
		_G.TestGamePrint("DRAGON TELEPORTED YESYES", dragonPart.Position)
		self:updateHeadCFrame(dragonPart.CFrame)
		local bonePositions = self:getBonePositions(dragonPart.Position)
		self:enableCustomBoneCFrameMode()
		local v12 = { bonePositions[1] }
		local v13 = v12[1]

		for i = 2, #bonePositions do
			v12[i] = v13 + CFrame.Angles(0, (i - 1) * 5.235987755982989 / (#bonePositions - 1), 0).RightVector * self.LENGTH_BETWEEN_BONES
			v13 = v12[i]
		end

		self:updateBonePositions(v12)
		self:disableCustomBoneCFrameMode()
	end

	if self._customBoneCFEnabled ~= true then
		goalAttach.WorldCFrame = cframe2 + self.positionWithoutOffset + v10
		self:goalAttachFixes()
	end

	if self.player == localPlayer then
		local v12 = CFrame.lookAlong(createVector(0, 0, 0), self.currentLookVector) + self.positionWithoutOffset
		self.DragonCFrameWithoutOffset.DragonCFrameWithoutOffsetClient.Value = v12
		self.DragonCFrameRemote:FireServer(v12)
	end

	self.prevCurrentLookVector = self.currentLookVector

	if not v11 then
		self.proxyCameraPart.Position = self.hrp.Position
	end
end

function DragonMoverClass:goalAttachFixes()
	local hrp = self.hrp
	local goalAttach = self.goalAttach
	local bodyVelocity = hrp:FindFirstChildOfClass("BodyVelocity")
	local bodyMoverActive

	if bodyVelocity and bodyVelocity.Velocity.Magnitude > 10 then
		goalAttach.WorldPosition = hrp.Position
		goalAttach.CFrame = hrp.CFrame - hrp.CFrame.Position + goalAttach.CFrame.Position
		bodyMoverActive = true
	else
		bodyMoverActive = false
	end

	local bodyPosition = hrp:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 10 then
		goalAttach.WorldPosition = hrp.Position
		goalAttach.CFrame = hrp.CFrame - hrp.CFrame.Position + goalAttach.CFrame.Position
		bodyMoverActive = true
	end

	self.bodyMoverActive = bodyMoverActive
end

function DragonMoverClass:debugVisualizePositionHistoryQueue()
	local v2 = 1

	for _, position in self.positionHistoryQueue:iteratorRearToFront() do
		local debugPart = self:getDebugPart("PositionHistoryQueue_" .. v2)
		debugPart.Shape = Enum.PartType.Ball
		debugPart.Size = createVector(0.04, 0.04, 0.04)
		debugPart.Color = Color3.new(1, 1, 0)
		debugPart.Transparency = 0.4
		debugPart.CFrame = CFrame.new(position)
		v2 += 1
	end
end

function DragonMoverClass:debugVisualizeDistanceHistoryQueue()
	local v2 = 1

	for _, v3 in self.distanceHistoryQueue:iteratorRearToFront() do
		local debugPart = self:getDebugPart("PositionHistoryQueue_" .. v2)
		local debugPart2 = self:getDebugPart("PositionHistoryQueue_" .. v2 + 1)

		if debugPart and debugPart2 then
			local debugPart3 = self:getDebugPart("DistanceHistoryQueue_" .. v2)
			local v4 = 0.01 + math.random() * 0.02
			debugPart3.Size = Vector3.new(v4, v4, v3)
			debugPart3.Color = Color3.fromHSV(math.random(), 1, 1)
			local position = debugPart.Position
			local position2 = debugPart2.Position
			local lerped = position:Lerp(position2, 0.5)
			debugPart3.CFrame = CFrame.lookAt(lerped, position2)
		end

		v2 += 1
	end
end

function DragonMoverClass:getTrailingBonePositions()
	local result = { self.dragonPart.Position }
	local magnitude = (result[1] - self.positionHistoryQueue:peekRear()).Magnitude

	for k, v2 in self.positionHistoryQueue:iteratorRearToFront() do
		local _, v3 = self.positionHistoryQueue:iteratorRearToFrontNext(k)
		local _, v4 = self.distanceHistoryQueue:iteratorRearToFrontNext(k - 1)

		if v4 == nil then
			continue
		end

		if #result >= self.NUM_BONES then
			break
		end

		local v5 = magnitude + v4
		local lengthBetweenConsecutiveBone = self.lengthBetweenConsecutiveBones[#result]

		if lengthBetweenConsecutiveBone - 0.01 <= v5 then
			local v6 = math.clamp((lengthBetweenConsecutiveBone - magnitude) / (v5 - magnitude), 0, 1)
			local v7

			if v6 > 0.001 or self.script.CActive.Value == not self.CFrozen or self.script.CActive.Value == true or self.script.XSpiralActive.Value == true or self.script.FDrillActive.Value == true or self.script.FMidAirEndActive.Value == true and self.isRebounding ~= true then
				v7 = v2:lerp(v3, v6)
			else
				v7 = result[#result] + (v3 - result[#result]).Unit * self.LENGTH_BETWEEN_BONES
			end

			magnitude = math.max(0, v5 - lengthBetweenConsecutiveBone)
			table.insert(result, v7)
		else
			magnitude = v5
		end
	end

	return result
end

local v2 = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse() * CFrame.Angles(0, 4.71238898038469, 0)

function DragonMoverClass:visualsUpdate(p)
	if self.player ~= localPlayer then
		self:updateServerTrailingPositions()
	end

	if self._customBoneCFEnabled == true then
		return
	end

	for i, _ in ipairs(self.lengthBetweenConsecutiveBones) do
		self.lengthBetweenConsecutiveBones[i] = lerp(
			self.lengthBetweenConsecutiveBones[i],
			self.LENGTH_BETWEEN_BONES,
			0.1 * (60 * p)
		)
	end

	local magnitude = (self.lastSampledPosition - self.dragonPart.Position).Magnitude

	if self.SAMPLE_POSITION_EVERY < magnitude then
		self.positionHistoryQueue:dequeue()
		self.positionHistoryQueue:enqueue(self.dragonPart.Position)
		self.distanceHistoryQueue:dequeue()
		self.distanceHistoryQueue:enqueue(magnitude)
		self.lastSampledPosition = self.dragonPart.Position
	end

	local v3

	if self.serverAuthoratitiveSimulationEnabled == true then
		v3 = self:getBonePositionsFromServerTrailingPositions()

		if v3 == nil then
			return
		end
	else
		v3 = self:getTrailingBonePositions()
	end

	pcallWarn(function()
		self.firstBoneAfterHeadPosition = v3[2]

		if self.script.FDrillActive.Value == true and self:getFPS(p) < 25 then
			local v4 = #v3

			for i, v5 in ipairs(v3) do
				local v6 = (i - 1) / (v4 - 1)
				local v7 = -30 * v6 + (self:getAccumulatedInputTime() - self.currentSinusoidalOffset)
				v3[i] = v5 + (CFrame.lookAlong(createVector(0, 0, 0), self.currentLookVector) * CFrame.Angles(
					0,
					0,
					-v7 * 18.84955592153876
				)).UpVector * 1 * 25 * math.clamp(
					-v6 + math.clamp(0.5 * (self:getAccumulatedInputTime() - self.currentSinusoidalOffset), 0, 1) * 2,
					0,
					1
				)
			end
		end

		if self.player == localPlayer then
			local v4 = #v3

			for i, v5 in ipairs(v3) do
				local v6 = (i - 1) / (v4 - 1)
				v3[i] = v5 + createVector(0, 1, 0) * v6 * math.sin(2 * self.IDLE_SINE_FREQUENCY * 3.141592653589793 * v6 - time()) * self.idleSineAmplitude
			end
		end
	end)
	self:updateBonePositions(v3)
end

function alignCFrameToVectorMinimally(cframe2: CFrame, vector2: Vector3)
	local lookVector = cframe2.LookVector
	local dot = lookVector:Dot(vector2)

	if dot > 0.99999 then
		return cframe2
	end

	if dot < -0.99999 then
		local unit = (math.abs(lookVector.X) < 0.99999 and Vector3.new(0, lookVector.Z, -lookVector.Y) or Vector3.new(
			-lookVector.Z,
			0,
			lookVector.X
		)).Unit
		return CFrame.fromAxisAngle(unit, 3.141592653589793) * cframe2
	end

	local cross = lookVector:Cross(vector2)
	local v3 = math.acos((math.clamp(dot, -1, 1)))
	return CFrame.fromAxisAngle(cross, v3) * cframe2
end

local function evalNumberSequence(sequence, p: number)
	if p == 0 then
		return sequence.Keypoints[1].Value
	elseif p == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v3 = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value + (keypoint2.Value - keypoint.Value) * v3
	end
end

function DragonMoverClass:updateHeadCFrame(cframe2: CFrame)
	if cframe2 ~= cframe2 then
		return
	end

	self.goalAttach.WorldCFrame = cframe2
	self.dragonPart.CFrame = cframe2
	self.collisionPart.CFrame = cframe2
	self.positionWithoutOffset = cframe2.Position

	if self.script.VActive.Value ~= true then
		self.hrp.CFrame = cframe2
	end

	self.dragonPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	self.dragonPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

function DragonMoverClass:updateBonePositions(list)
	local goalAttach = self.goalAttach
	local v3 = list[1]
	local v4 = list[1] + (list[1] - list[2])
	local cframe2 = CFrame.lookAt(v3, v4)

	if cframe2 ~= cframe2 then
		cframe2 = goalAttach.WorldCFrame.Rotation + v3
	end

	self.easternDragonRootPart.CFrame = cframe2
	self.easternDragonModelBones[1].CFrame = self.easternDragonRootPart.CFrame:Inverse() * (cframe2 * v2)

	if self.easternDragonModelBones[1].CFrame ~= self.easternDragonModelBones[1].CFrame then
		self.easternDragonModelBones[1].CFrame = self.easternDragonRootPart.CFrame:Inverse() * (self.easternDragonModelBones[1].CFrame.Rotation + v3)
	end

	local rotation = cframe2.Rotation

	for i = 2, self.NUM_BONES do
		local v5 = list[i]
		local v6 = list[i - 1]
		local unit = (v6 - v5).Unit
		rotation = alignCFrameToVectorMinimally(rotation, unit)
		local v7 = math.clamp((math.clamp(math.abs(self.currentLookVector.Y), 0.8, 1) - 0.8) * 5, 0, 1)
		local v8 = self.isRebounding == true and 1 or v7

		if self._headAimingEnabled == true then
			v8 = math.clamp(v8 * 10 + math.ceil(v8) * (time() - self._headAimingEnabledStartTime), 0, 1)
		end

		local v9 = math.clamp(
			lerp(3, v8, (math.clamp((self:getAccumulatedInputTime() - self.lastReboundInputTime) / 2, 0, 1))),
			0,
			1
		)
		local v10 = CFrame.lookAt(v5, v6) * v2
		local v11 = rotation * v2 + v5
		self.easternDragonModelBones[i].CFrame = self.easternDragonRootPart.CFrame:Inverse() * v10:Lerp(v11, v9)

		if self.easternDragonModelBones[i].CFrame ~= self.easternDragonModelBones[i].CFrame then
			self.easternDragonModelBones[i].CFrame = self.easternDragonRootPart.CFrame:Inverse() * (self.easternDragonModelBones[i].CFrame.Rotation + v5)
		end
	end

	if self._customBoneCFEnabled == true then
		self:updateHeadCFrame(cframe2)
	end
end

function DragonMoverClass:getBonePositions(vector2: Vector3)
	local v3 = not vector2 and createVector(0, 0, 0) or vector2 - (self.easternDragonRootPart.CFrame * self.easternDragonModelBones[1].CFrame).Position
	local result = {}

	for i = 1, self.NUM_BONES do
		result[i] = v3 + (self.easternDragonRootPart.CFrame * self.easternDragonModelBones[i].CFrame).Position
	end

	return result
end

function DragonMoverClass:enableCustomBoneCFrameMode()
	if self._customBoneCFEnabled == true then
		return
	end

	self._customBoneCFEnabled = true
end

function DragonMoverClass:disableCustomBoneCFrameMode()
	if self._customBoneCFEnabled == false then
		return
	end

	if self.script.XSpiralActive.Value == true or self.script.FMidAirEndActive.Value == true or self.script.CActive.Value == true or self.script.VActive.Value == true then
		return
	end

	self:setSinusoidalHeightOffsetToZero()
	local bonePositions = self:getBonePositions()
	local lookVector = self.dragonPart.CFrame.LookVector
	self.currentLookVector = lookVector
	self.goalLookVector = lookVector
	self.positionWithoutOffset = self.dragonPart.Position
	self:updateBonePositions(bonePositions)
	self:resetHistoryQueues(bonePositions)
	self._customBoneCFEnabled = false
end

function DragonMoverClass:clearHurtboxes()
	local dragonDamageHeadPart = self.char:FindFirstChild("DragonDamageHeadPart")
	task.defer(function()
		dragonDamageHeadPart:Destroy()
	end)
end

function DragonMoverClass:initializeServerTrailingPositions()
	if localPlayer == self.player then
		error("Server authoratitive mode should not be ran on the dragon owner client")
	end

	local value = self.script.Parent.NUM_TRAILING_CYLINDERS.Value
	self.currentTrailingPositions = {}
	self.prevTrailingPositions = {}
	self.targetTrailingPositions = {}
	self.localClientAimBoxes = setmetatable({}, {
		__call = function(list)
			for i = 1, (value - 1) / 3 do
				local currentTrailingPosition = self.currentTrailingPositions[i * 3]
				local currentTrailingPosition2 = self.currentTrailingPositions[i * 3 + 1]

				if not (currentTrailingPosition2 and currentTrailingPosition) then
					continue
				end

				local v3 = list[i]

				if v3 then
					v3.CFrame = CFrame.lookAt(currentTrailingPosition, currentTrailingPosition2)
				end
			end
		end
	})
	local v3 = workspace:FindFirstChild("DragonHitboxesClient")

	if not v3 then
		v3 = Instance.new("Model", workspace.CurrentCamera)
		v3.Name = "DragonHitboxesClient"
	end

	local model = Instance.new("Model", v3)
	model.Name = tostring(self.player)
	local objectValue = Instance.new("ObjectValue", model)
	objectValue.Name = "Object"
	objectValue.Value = self.player
	self.easternDragonModel.AncestryChanged:Connect(function(_, instance)
		if not (instance and instance:IsDescendantOf(workspace)) then
			model:Destroy()

			if #v3:GetChildren() <= 0 then
				v3:Destroy()
			end
		end
	end)

	for i = 1, (value - 1) / 3 do
		local part = Instance.new("Part")
		part.Name = "dragonClientHitboxPart" .. tostring(i)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = true
		part.Transparency = 1
		part.Size = Vector3.new(563.3839721679688 / value, 14.335999755859376, 57.343999023437505)
		part.Color = Color3.new(0, 1, 0)
		part.CastShadow = false
		part.Parent = model
		table.insert(self.localClientAimBoxes, part)
	end

	self.DragonSetupRemote:FireServer(true)
	local v4, v5 = self.script.Parent.DragonTrailingPositionsRemote.OnClientEvent:Wait()
	local v6 = ReadBuffer.new(v5)
	local v7 = { v4 }

	for i = 2, 30 do
		v7[i] = v7[i - 1] + Vector3.new(v6:ReadFloat16(), v6:ReadFloat16(), v6:ReadFloat16())
	end

	self.currentTrailingPositions[1] = v7[1]
	self.prevTrailingPositions[1] = v7[1]
	self.targetTrailingPositions[1] = v7[1]

	for i = 1, value - 1 do
		table.insert(self.currentTrailingPositions, v7[i])
		table.insert(self.prevTrailingPositions, v7[i])
		table.insert(self.targetTrailingPositions, v7[i])
	end

	assert(
		#self.currentTrailingPositions == self.NUM_BONES,
		"currentTrailingPositions array length should be the same as self.NUM_BONES"
	)
	assert(
		#self.prevTrailingPositions == self.NUM_BONES,
		"prevTrailingPositions array length should be the same as self.NUM_BONES"
	)
	assert(
		#self.targetTrailingPositions == self.NUM_BONES,
		"targetTrailingPositions array length should be the same as self.NUM_BONES"
	)
	self.interpolationTimeLength = 0.05
	self.lastInterpolationUpdateTime = time()
	self.events.dragonTrailingPositionsRemoteOnClientEvent = self.script.Parent.DragonTrailingPositionsRemote.OnClientEvent:Connect(function(p, buf: buffer)
		local v8 = ReadBuffer.new(buf)
		local v9 = { p }

		for i = 2, 30 do
			v9[i] = v9[i - 1] + Vector3.new(v8:ReadFloat16(), v8:ReadFloat16(), v8:ReadFloat16())
		end

		local targetTrailingPosition = self.targetTrailingPositions[1]

		if targetTrailingPosition and (p - targetTrailingPosition).magnitude > 2000 then
			_G.TestGamePrint("Dragon Teleported!")

			for i, v10 in ipairs(v9) do
				self.prevTrailingPositions[i] = v10
				self.targetTrailingPositions[i] = v10
				self.currentTrailingPositions[i] = v10
			end
		else
			for i, currentTrailingPosition in ipairs(self.currentTrailingPositions) do
				self.prevTrailingPositions[i] = currentTrailingPosition
			end

			self.localClientAimBoxes()

			for i, v10 in ipairs(v9) do
				self.targetTrailingPositions[i] = v10
			end
		end

		local v10 = time() - self.lastInterpolationUpdateTime
		self.interpolationTimeLength = math.clamp(0.9 * self.interpolationTimeLength + 0.1 * v10, 0.05, 0.5)
		self.lastInterpolationUpdateTime = time()
	end)
	local v8 = CFrame.lookAlong(createVector(0, 0, 0), self.currentLookVector) + self.dragonPart.Position
	self.prevDragonCFrameWithoutOffset = v8
	self.currentDragonCFrameWithoutOffset = v8
	self.targetDragonCFrameWithoutOffset = v8
	self.interpolationTimeLength2 = 0.05
	self.lastInterpolationUpdateTime2 = time()
	self.events.dragonCFrameWithoutOffsetOnClientEvent = self.DragonCFrameRemote.OnClientEvent:Connect(function(targetDragonCFrameWithoutOffset: CFrame)
		self.prevDragonCFrameWithoutOffset = self.currentDragonCFrameWithoutOffset
		self.targetDragonCFrameWithoutOffset = targetDragonCFrameWithoutOffset
		local v9 = time() - self.lastInterpolationUpdateTime2
		self.interpolationTimeLength2 = math.clamp(0.9 * self.interpolationTimeLength2 + 0.1 * v9, 0.05, 0.5)
		self.lastInterpolationUpdateTime2 = time()
	end)
end

function DragonMoverClass:updateServerTrailingPositions()
	local v3 = math.clamp((time() - self.lastInterpolationUpdateTime) / self.interpolationTimeLength, 0, 1)

	for i = 1, #self.currentTrailingPositions do
		self.currentTrailingPositions[i] = self.prevTrailingPositions[i]:Lerp(self.targetTrailingPositions[i], v3)
	end

	local v4 = math.clamp((time() - self.lastInterpolationUpdateTime2) / self.interpolationTimeLength2, 0, 1)
	self.currentDragonCFrameWithoutOffset = self.prevDragonCFrameWithoutOffset:Lerp(
		self.targetDragonCFrameWithoutOffset,
		v4
	)
	self.DragonCFrameWithoutOffset.DragonCFrameWithoutOffsetOtherClient.Value = self.currentDragonCFrameWithoutOffset
end

function DragonMoverClass:getBonePositionsFromServerTrailingPositions()
	return self.currentTrailingPositions
end

function DragonMoverClass:enableServerAuthoritativeSimulation()
	if localPlayer == self.player then
		error("Server authoratitive mode should not be ran on the dragon owner client")
	end

	self.serverAuthoratitiveSimulationEnabled = true
end

function DragonMoverClass:disableServerAuthoritativeSimulation()
	if localPlayer == self.player then
		error("Server authoratitive mode should not be ran on the dragon owner client")
	end

	self.serverAuthoratitiveSimulationEnabled = false
	local v3

	if localPlayer == self.player then
		v3 = self:getBonePositions()
	else
		v3 = self:getBonePositionsFromServerTrailingPositions()
	end

	self:updateBonePositions(v3)
	self:resetHistoryQueues(v3, true)
end

function DragonMoverClass:getMousePos()
	if self.char:GetAttribute("DragonAimValue") then
		return self.char:GetAttribute("DragonAimValue")
	end

	if localPlayer == self.player then
		return self.script.Parent.MousePos.MousePosClient.Value
	end

	return self.script.Parent.MousePos.Value
end

function DragonMoverClass:getCameraCFrame()
	if localPlayer == self.player then
		return workspace.CurrentCamera.CFrame
	end

	return self.script.Parent.CameraCFrame.Value
end

function DragonMoverClass:getCameraOffset()
	local humanoid = self.humanoid
	return (humanoid.RigType ~= Enum.HumanoidRigType.R15 and createVector(0, 1.5, 0) or not humanoid.AutomaticScalingEnabled and createVector(
		0,
		2,
		0
	) or createVector(0, 1.5, 0) + Vector3.new(0, humanoid.RootPart.Size.Y / 2 - 1, 0)) + humanoid.CameraOffset
end

function DragonMoverClass:enableHeadAimingMode()
	if self._headAimingEnabled == true then
		return
	end

	local bonePositions = self:getBonePositions()
	self.NUM_BONES_TO_AIM = math.floor(0.5 + self.NUM_BONES / 8)
	self.headAimHingeVector = (bonePositions[self.NUM_BONES_TO_AIM] - bonePositions[self.NUM_BONES_TO_AIM + 1]).Unit

	if self.headAimHingeVector ~= self.headAimHingeVector then
		self.headAimHingeVector = self:getCameraCFrame().LookVector
	end

	self.prevAimLookVector = self.currentLookVector
	self._headAimingEnabledStartTime = time()
	self._headAimingEnabled = true
	self._headAimingDisabling = false
	self.script.HeadAimModeDisabling.Value = false
	self.mouthOpeningAnim:Play(0.1, 2, 1.4)
	task.delay(0.2 * self.mouthOpeningAnim.Length / 1.4, function()
		if self.script.HeadAimModeDisabling.Value == true then
			return
		end

		self.mouthOpenedLoopAnim:Play(0.5, 2)
	end)
end

function DragonMoverClass:disableHeadAimingMode()
	if self._headAimingEnabled ~= true or self._headAimingDisabling then
		return
	end

	self._headAimingDisablingStartTime = time()
	self._headAimingDisabling = 1
	self.script.HeadAimModeDisabling.Value = true
	self._headAimingProgress = 0
	local heartbeatLoopFor = Util.HeartbeatLoopFor
	local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
	local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
	self.mouthOpeningAnim:Stop(0)
	self.mouthOpenedLoopAnim:Stop(0)

	if localPlayer ~= self.player then
		if self.script.ZActive.Value == false then
			if self.mouthClosingAnim.IsPlaying == false then
				self.mouthClosingAnim:Play(0.1, 2, 1.4)
			end
		elseif self.zRecoilAnim.IsPlaying == false then
			self.zRecoilAnim:Play(0.1, 2, 1.4)
		end
	end

	local v3 = false
	local connection = nil
	connection = heartbeatLoopFor2(1.0333333333333334, function()
		if self.script.HeadAimModeDisabling.Value ~= false then
			return
		end

		v3 = true
		self._headAimingDisabling = false
		self:SetHaloVisible(true)
		self.mouthClosingAnim:Stop(0.1)
		self.zRecoilAnim:Stop(0.1)
		self.mouthOpeningAnim:Play(0.1, 2, 1.4)
		task.delay(0.2 * self.mouthOpeningAnim.Length / 1.4, function()
			if self.script.HeadAimModeDisabling.Value == true then
				return
			end

			self.mouthOpenedLoopAnim:Play(0.5, 2)
		end)
		connection:Disconnect()
	end)
	task.delay(1, function()
		if v3 == true then
			return
		end

		connection:Disconnect()

		if self.script.CActive.Value ~= true then
			self.haloCurrentSpeed = 1

			if localPlayer == self.player then
				self.script.Parent.DragonHaloCurrentSpeed:FireServer(self.haloCurrentSpeed)
			end
		end

		if self.idleActive == false then
			self:SetHaloVisible(false)
		end

		self.mouthOpeningAnim:Stop()
		self.mouthOpenedLoopAnim:Stop()
		self._headAimingEnabled = false
		self._headAimingDisabling = false
		self.script.HeadAimModeDisabling.Value = false
	end)
end

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function DragonMoverClass:detectHeadAimClipping(list)
	for i = self.NUM_BONES_TO_AIM, 1, -1 do
		local v3 = list[i]
		local v4 = list[i + 1]
		local raycastResult = workspace:Raycast(v4, v3 - v4, raycastParams)

		if raycastResult then
			return raycastResult
		end
	end

	return nil
end

local function joystickSlerp(headAimHingeVector: Vector3, headAimCutoffAngle: number, prevAimLookVector: Vector3, unit: Vector3, p: number)
	local v3 = slerp(prevAimLookVector, unit, p)

	if not (headAimCutoffAngle <= headAimHingeVector:Angle(v3)) then
		return v3
	end

	local v4 = slerp(
		-headAimHingeVector,
		prevAimLookVector,
		(3.141592653589793 - headAimCutoffAngle) / prevAimLookVector:Angle(-headAimHingeVector)
	)
	local v5 = slerp(
		-headAimHingeVector,
		unit,
		(3.141592653589793 - headAimCutoffAngle) / unit:Angle(-headAimHingeVector)
	)
	local cframe2 = CFrame.lookAt(createVector(0, 0, 0), -headAimHingeVector)
	local Z = cframe2:VectorToObjectSpace(v4).Z
	local magnitude = (createVector(1, 1, 0) * cframe2:VectorToObjectSpace(v4)).Magnitude
	return (cframe2:VectorToWorldSpace(slerp(
		(createVector(1, 1, 0) * cframe2:VectorToObjectSpace(v4)).Unit,
		(createVector(1, 1, 0) * cframe2:VectorToObjectSpace(v5)).Unit,
		p
	) * magnitude + Vector3.new(0, 0, Z)))
end

function DragonMoverClass:updateHeadAimingMode(unit: Vector3, p: number, p2: number)
	if self.script.HeadAimModeActive.Value ~= self._headAimingEnabled and self._headAimingDisabling == false then
		if self.script.HeadAimModeActive.Value == true then
			self:SetHaloVisible(true)
			self.isZHeadAiming = nil
			self:enableHeadAimingMode()
		else
			if self.idleActive == false then
				self:SetHaloVisible(false)
			end

			self:disableHeadAimingMode()
		end
	end

	if localPlayer ~= self.player or self._headAimingEnabled == false and self._headAimingDisabling == false then
		return
	end

	local NUM_BONES_TO_AIM = self.NUM_BONES_TO_AIM
	local bonePositions = self:getBonePositions()
	self.headAimHingeVector = (bonePositions[self.NUM_BONES_TO_AIM] - bonePositions[self.NUM_BONES_TO_AIM + 1]).Unit

	if self.headAimHingeVector ~= self.headAimHingeVector then
		self.headAimHingeVector = self:getCameraCFrame().LookVector
	end

	local headAimHingeVector = self.headAimHingeVector
	local bonePosition = bonePositions[NUM_BONES_TO_AIM + 1]

	if unit == nil then
		unit = (self:getMousePos() - self.hrp.Position).Unit

		if self._headAimingDisabling then
			unit = self.goalAttach.WorldCFrame.LookVector
		end

		if unit ~= unit then
			unit = self:getCameraCFrame().LookVector
		end
	end

	local lerped = lerp(1.5707963267948966, 1.3439035240356338, -math.clamp(unit:Dot(self.headAimHingeVector), -1, 0))
	local v3 = CFrame.lookAt(createVector(0, 0, 0), self.headAimHingeVector).RightVector * (CFrame.lookAt(
		createVector(0, 0, 0),
		self.headAimHingeVector
	):VectorToObjectSpace(unit).X >= 0 and 1 or -1)
	local angle = unit:Angle(v3)

	if lerped < angle then
		unit = slerp(v3, unit, lerped / angle)
	end

	if self.script.ZActive.ZActiveClient.Value == true then
		self.isZHeadAiming = true
	elseif self.script.M1Active.Value == true then
		self.isZHeadAiming = false
	end

	self.headAimCutoffAngle = self.isZHeadAiming and 2.9670597283903604 or 1.5184364492350666
	local headAimCutoffAngle = self.headAimCutoffAngle
	local unit2 = joystickSlerp(
		self.headAimHingeVector,
		headAimCutoffAngle,
		self.prevAimLookVector,
		unit,
		p2 * 60 * 0.13
	)

	if self._headAimingDisabling then
		if self.script.CActive.Value ~= true then
			unit2 = slerp(self.prevAimLookVector, self.goalAttach.WorldCFrame.LookVector, p2 * 60 * 0.13)
			self._headAimingProgress = 0
			self.haloCurrentSpeed = lerp(self.haloCurrentSpeed, 1, p2 * 60 * 0.12)

			if localPlayer == self.player then
				self.script.Parent.DragonHaloCurrentSpeed:FireServer(self.haloCurrentSpeed)
			end
		end
	else
		self._headAimingProgress += p2
		local v4 = 1

		if self._headAimingProgress > 2 then
			local v5 = v4 - (self._headAimingProgress - 2) / 2
			v4 = v5 < 0 and 0 or v5
		end

		self.haloCurrentSpeed = lerp(self.haloCurrentSpeed, v4 * 45 + 10, p2 * 60 * 0.03)

		if localPlayer == self.player then
			self.script.Parent.DragonHaloCurrentSpeed:FireServer(self.haloCurrentSpeed)
		end
	end

	local v4 = NUM_BONES_TO_AIM * self.LENGTH_BETWEEN_BONES + 20
	local raycastResult = workspace:Raycast(bonePosition, unit2 * v4, raycastParams)

	if raycastResult and (raycastResult.Normal.Y > 0.7 or raycastResult.Instance.Size.Magnitude > 173) then
		local v6 = raycastResult.Position + projectVectorOntoPlane(
			bonePosition - raycastResult.Position,
			raycastResult.Normal
		)
		local magnitude = (bonePosition - v6).Magnitude
		unit2 = (v6 - bonePosition + (projectVectorOntoPlane(unit2, raycastResult.Normal)).Unit * math.sqrt(v4 ^ 2 - magnitude ^ 2)).Unit
	end

	if unit2 ~= unit2 then
		unit2 = unit
	end

	self.prevAimLookVector = unit2

	if localPlayer == self.player then
		self.DragonHeadAimRemote:FireServer(unit2)
		self.script.Parent.HeadAim.HeadAimClient.Value = unit2
	end

	local v5 = bonePosition
	local v6 = {}

	for i = NUM_BONES_TO_AIM, 1, -1 do
		local LENGTH_BETWEEN_BONES = self.LENGTH_BETWEEN_BONES
		v6[i] = v5 + slerp(headAimHingeVector, unit2, 1 - (i - 1) / NUM_BONES_TO_AIM) * LENGTH_BETWEEN_BONES
		v5 = v6[i]
	end

	if self._headAimingDisabling then
		local v7 = math.clamp((time() - self._headAimingDisablingStartTime) / self._headAimingDisabling, 0, 1)

		for i = NUM_BONES_TO_AIM, 1, -1 do
			v6[i] = v6[i]:Lerp(bonePositions[i], v7)
		end
	end

	for i = NUM_BONES_TO_AIM + 1, self.NUM_BONES do
		v6[i] = bonePositions[i]
	end

	local headAimClipping = self:detectHeadAimClipping(v6)
	local v7 = p == nil and 1 or p

	if not (headAimClipping and v7 < 5) then
		self:updateBonePositions(v6)
		return
	end

	local unit3 = (bonePosition + projectVectorOntoPlane(
		headAimClipping.Position - bonePosition,
		headAimClipping.Normal
	) * 100 - bonePosition).Unit

	if unit3 ~= unit3 then
		unit3 = unit
	end

	self:updateHeadAimingMode(unit3, v7 + 1, p2)
end

local function round(p, p2)
	return math.floor((p + p2 / 2) / p2) * p2
end

local getColorPropertiesFor = Util.GetColorPropertiesFor

local function getDefaultColor(instance, p, p2)
	local v3 = "DefaultColor_" .. p
	local attribute = instance:GetAttribute(v3)

	if not attribute then
		instance:SetAttribute(v3, p2)
		attribute = p2
	end

	return attribute
end

local function ensureColor3InRange(color: Color3)
	local v3 = math.max(1, color.R, color.G, color.B)
	local v4 = math.floor(color.R / v3 * 255) % 256
	local v5 = math.floor(color.G / v3 * 255) % 256
	local v6 = math.floor(color.B / v3 * 255) % 256
	return (Color3.fromRGB(v4, v5, v6))
end

local function applyColorTransformation(instance, p, sequence, callback)
	if typeof(sequence) == "Color3" then
		local v3 = "DefaultColor_" .. p
		local attribute = instance:GetAttribute(v3)

		if not attribute then
			instance:SetAttribute(v3, sequence)
			attribute = sequence
		end

		instance[p] = callback(instance, sequence, attribute, p)
	elseif typeof(sequence) == "ColorSequence" then
		local keypoints = sequence.Keypoints
		local colorSequenceKeypoints = {}

		for _, keypoint in pairs(keypoints) do
			local v3 = tostring(math.floor((keypoint.Time + 0.005) / 0.01) * 0.01):gsub("%.", "_")
			local color3InRange = ensureColor3InRange(keypoint.Value)
			local v4 = "DefaultColor_" .. p .. "_" .. v3
			local attribute = instance:GetAttribute(v4)

			if not attribute then
				instance:SetAttribute(v4, color3InRange)
				attribute = color3InRange
			end

			table.insert(
				colorSequenceKeypoints,
				ColorSequenceKeypoint.new(
					keypoint.Time,
					(ensureColor3InRange(callback(instance, color3InRange, attribute, p, keypoint.Time)))
				)
			)
		end

		instance[p] = ColorSequence.new(colorSequenceKeypoints)
	end
end

local function getObjectColorProperties(p)
	local result = {}
	local colorPropertiesFor = getColorPropertiesFor(p)

	if colorPropertiesFor then
		for _, v3 in pairs(colorPropertiesFor) do
			if v3 == "LevelOfDetail" then
				continue
			end

			local v4 = p[v3]

			if not (typeof(v4) == "Color3" or typeof(v4) == "ColorSequence") then
				continue
			end

			table.insert(result, v3)
		end
	end

	if #result == 0 then
		return nil
	end

	return result
end

local v3 = {}

local function adjustObjectDescendantsColors(folder, fn)
	if v3[folder] == nil then
		local v4 = {
			[folder] = getObjectColorProperties(folder)
		}

		for _, descendant in ipairs(folder:GetDescendants()) do
			v4[descendant] = getObjectColorProperties(descendant)
		end

		v3[folder] = v4
		task.delay(20, function()
			v3[folder] = nil
		end)
	end

	for k, list in pairs(v3[folder]) do
		for _, v4 in ipairs(list) do
			applyColorTransformation(k, v4, k[v4], fn)
		end
	end
end

function storeRelativeCFrames(list, p)
	local parts = {}

	for _, part in ipairs(list) do
		if not part:IsA("BasePart") then
			continue
		end

		part:SetAttribute("RelativeCFrame", p.TransformedWorldCFrame:ToObjectSpace(part.CFrame))
		table.insert(parts, part)
	end

	return parts
end

function DragonMoverClass:applyColorChangeToAuraObject(instance, list)
	local HSV, v4, v5 = instance:GetAttribute("Default"):ToHSV()
	local HSV2, v6, v7 = instance.Value:ToHSV()
	local v8 = (HSV2 - HSV + 1) % 1
	local v9 = v6 / v4
	local v10 = v7 / v5

	for _, v11 in ipairs(list) do
		adjustObjectDescendantsColors(v11, function(_, _, p)
			local HSV3, v12, v13 = p:ToHSV()
			return Color3.fromHSV((HSV3 + v8) % 1, v12 * v9, v13 * v10)
		end)
	end
end

function DragonMoverClass:initAura()
	self.auraPart = self.easternDragonModel.Aura
	self.eyeFlamesBoneWeld = self.easternDragonModel.RootPart:FindFirstChild("UpperMouth", true)
	self.handFlamesBoneWeldR = self.easternDragonModel.RootPart.S7["Arm1.R"]["Arm2.R"]["Hand1.R"]
	self.handFlamesBoneWeldL = self.easternDragonModel.RootPart.S7["Arm1.L"]["Arm2.L"]["Hand1.L"]
	self.mouthFlamesBoneWeld = self.easternDragonModel.RootPart:FindFirstChild("UpperMouth", true)
	self.ringBoneWeld = self.easternDragonModel.RootPart:FindFirstChild("S2", true)
	self.eyeFlamesParts = storeRelativeCFrames(self.auraPart.EyeFlames:GetDescendants(), self.eyeFlamesBoneWeld)
	self.handFlamesPartsR = storeRelativeCFrames({ self.auraPart.HandFlames.FlameR }, self.handFlamesBoneWeldR)
	self.handFlamesPartsL = storeRelativeCFrames({ self.auraPart.HandFlames.FlameL }, self.handFlamesBoneWeldL)
	self.mouthFlamesParts = storeRelativeCFrames(self.auraPart.MouthFlames:GetDescendants(), self.mouthFlamesBoneWeld)
	self.ringParts = storeRelativeCFrames(self.auraPart.Ring:GetDescendants(), self.ringBoneWeld)
	self.events.eyeFlamesColorChanged = self.script.Parent.EyeFlamesColor.Changed:Connect(function()
		self:applyColorChangeToAuraObject(self.script.Parent.EyeFlamesColor, { self.auraPart.EyeFlames })
	end)
	self:applyColorChangeToAuraObject(self.script.Parent.EyeFlamesColor, { self.auraPart.EyeFlames })
	self.events.handFlamesColorChanged = self.script.Parent.HandFlamesColor.Changed:Connect(function()
		self:applyColorChangeToAuraObject(self.script.Parent.HandFlamesColor, { self.auraPart.HandFlames })
	end)
	self:applyColorChangeToAuraObject(self.script.Parent.HandFlamesColor, { self.auraPart.HandFlames })
	self.events.mouthFlamesColorChanged = self.script.Parent.MouthFlamesColor.Changed:Connect(function()
		self:applyColorChangeToAuraObject(self.script.Parent.MouthFlamesColor, { self.auraPart.MouthFlames })
	end)
	self:applyColorChangeToAuraObject(self.script.Parent.MouthFlamesColor, { self.auraPart.MouthFlames })
	local v4 = { self.auraPart.EyeFlames, self.auraPart.HandFlames, self.auraPart.MouthFlames }
	local flag = false

	local function restoreFlameDefaults(folder)
		local function restore(instance)
			for _, v5 in getObjectColorProperties(instance) or {} do
				local attribute = instance:GetAttribute("DefaultColor_" .. v5)

				if attribute == nil then
					local v6 = instance[v5]

					if typeof(v6) == "ColorSequence" then
						local v7 = {}
						local flag2 = false

						for _, keypoint in ipairs(v6.Keypoints) do
							local attribute2 = instance:GetAttribute("DefaultColor_" .. v5 .. "_" .. tostring(math.floor((keypoint.Time + 0.005) / 0.01) * 0.01):gsub(
								"%.",
								"_"
							))

							if attribute2 == nil then
								table.insert(v7, keypoint)
							else
								table.insert(v7, ColorSequenceKeypoint.new(keypoint.Time, attribute2))
								flag2 = true
							end
						end

						if flag2 then
							local v8 = v5
							local v9 = v7
							pcall(function()
								instance[v8] = ColorSequence.new(v9)
							end)
						end
					end
				else
					local v6 = v5
					local v7 = attribute
					pcall(function()
						instance[v6] = v7
					end)
				end
			end
		end

		restore(folder)

		for _, descendant in folder:GetDescendants() do
			restore(descendant)
		end
	end

	local function recolorFlames()
		for _, v5 in v4 do
			restoreFlameDefaults(v5)
			Util.ColorShiftObjectDescendants(v5, self.player, "DragonFruitVFXColor")
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scheduleFlameRecolor()
		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false

			if not self.destroyed then
				recolorFlames()
			end
		end)
	end

	recolorFlames()

	if self.player then
		local connections = {}
		local bindFlamePalette

		bindFlamePalette = function()
			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)
			local dragonFruitVFXColor = self.player:FindFirstChild("DragonFruitVFXColor")

			if not dragonFruitVFXColor then
				return
			end

			local attributeChangedSignal = dragonFruitVFXColor:GetAttributeChangedSignal("PaletteVersion")
			local attributeChangedSignal2 = dragonFruitVFXColor:GetAttributeChangedSignal("SkinStorageKey")
			table.insert(connections, attributeChangedSignal:Connect(scheduleFlameRecolor))
			table.insert(connections, attributeChangedSignal2:Connect(scheduleFlameRecolor))
			table.insert(connections, dragonFruitVFXColor.ChildAdded:Connect(function(child)
				if child.Name == "Default" or child.Name == "Shifted" then
					bindFlamePalette()
					scheduleFlameRecolor() -- equivalent call inferred; original call site unknown
				end
			end))

			for _, childName in { "Default", "Shifted" } do
				local child = dragonFruitVFXColor:FindFirstChild(childName)

				if child then
					table.insert(connections, child.AttributeChanged:Connect(scheduleFlameRecolor))
				end
			end
		end

		bindFlamePalette()

		if not flag then
			flag = true
			task.defer(function()
				flag = false

				if not self.destroyed then
					recolorFlames()
				end
			end)
		end

		self.events.flamePaletteFolderAdded = self.player.ChildAdded:Connect(function(child)
			if child.Name == "DragonFruitVFXColor" then
				bindFlamePalette()
				scheduleFlameRecolor() -- equivalent call inferred; original call site unknown
			end
		end)
		self.events.flamePaletteBindings = {
			Disconnect = function()
				for _, connection in connections do
					connection:Disconnect()
				end

				table.clear(connections)
			end
		}
	end

	local clone = FX:WaitForChild("EasternDragon").Halo:Clone()
	local clone_2 = FX:WaitForChild("EasternDragon").Aura:Clone()
	clone_2.Parent = clone
	clone:ScaleTo(clone:GetScale() * self.easternScaleModifier)
	clone.Parent = workspace._WorldOrigin
	self.halo = clone
	self.haloScale = clone:GetScale()
	self.events.ringColorChanged = self.script.Parent.RingColor.Changed:Connect(function()
		self:applyColorChangeToAuraObject(self.script.Parent.RingColor, { self.auraPart.Ring, self.halo })
	end)
	self:applyColorChangeToAuraObject(self.script.Parent.RingColor, { self.auraPart.Ring, self.halo })
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tableAppend(descendants, list)
	if typeof(list) ~= "table" then
		table.insert(descendants, list)
		return
	end

	for _, v4 in ipairs(list) do
		table.insert(descendants, v4)
	end
end

function DragonMoverClass:SetHaloVisible(flag: boolean)
	if flag == false and self.script.CActive.Value == true then
		return
	end

	if self.haloVisible ~= flag then
		self.haloVisible = flag

		if flag then
			self.haloSide *= -1

			if game.Players.LocalPlayer.Character and self.halo.PrimaryPart and (self.halo.PrimaryPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude < 3000 then
				Util.Sound:Play("BF_V3_Halo_Appear_01", self.halo.PrimaryPart)
			end
		else
			if game.Players.LocalPlayer.Character and self.halo.PrimaryPart and (self.halo.PrimaryPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude < 3000 then
				Util.Sound:Play("BF_V3_Halo_Disappear_01", self.halo.PrimaryPart)
			end

			self:resetHaloState()
		end

		task.delay(0.016666666666666666, function()
			if self.destroyed or self.haloVisible ~= flag then
				return
			end

			local clone = self.halo.Aura:Clone()
			clone:ScaleTo(self.easternScaleModifier)
			clone.Aura.CFrame = self.halo.PrimaryPart.CFrame
			clone.Parent = workspace._WorldOrigin

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v4 = emitter
				task.spawn(function()
					if v4:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v4:GetAttribute("EmitDelay"))
					end

					v4:Emit(v4:GetAttribute("EmitCount"))

					if v4.Parent.Name == "Aura2" then
						task.spawn(function()
							for i = 1, 10 do
								v4.Acceleration = Vector3.new(
									math.random(-80, 80),
									math.random(-80, 80),
									math.random(-80, 80)
								) * self.easternScaleModifier
								task.wait(0.05)
							end

							v4.Acceleration = createVector(0, 0, 0)
							task.wait(0.5)
							v4.Acceleration = Vector3.new(
								math.random(-25, 25),
								math.random(-25, 25),
								math.random(-25, 25)
							) * self.easternScaleModifier
							v4.Speed = NumberRange.new(1 * self.easternScaleModifier, 15 * self.easternScaleModifier)
							v4.Drag = 1
							v4.Rate = 10
							v4.SpreadAngle = Vector2.new(90, 90)
						end)
					end
				end)
			end

			clone.Aura.Aura2.WeldConstraint.Part1 = self.halo.PrimaryPart
			clone.Aura.Aura2.Parent = self.halo.PrimaryPart
			task.wait(3)
			clone:Destroy()
		end)
		task.delay(0.16666666666666666, function()
			if self.destroyed or self.haloVisible ~= flag then
				return
			end

			local clone = FX:WaitForChild("EasternDragon").HandAura:Clone()
			Util.ColorShiftObjectDescendants(clone, self.player, "DragonFruitVFXColor")
			clone.HandAura.CFrame = self.auraPart.HandFlames.FlameR.CFrame
			clone.HandAura.Anchored = false
			clone.HandAura.Massless = true
			clone.Parent = workspace._WorldOrigin
			clone.HandAura.WeldConstraint.Part1 = self.auraPart.HandFlames.FlameR
			local clone2 = FX:WaitForChild("EasternDragon").HandAura:Clone()
			Util.ColorShiftObjectDescendants(clone2, self.player, "DragonFruitVFXColor")
			clone2.HandAura.CFrame = self.auraPart.HandFlames.FlameL.CFrame
			clone2.HandAura.Anchored = false
			clone2.HandAura.Massless = true
			clone2.Parent = workspace._WorldOrigin
			clone2.HandAura.WeldConstraint.Part1 = self.auraPart.HandFlames.FlameR

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v4 = emitter
				task.spawn(function()
					if v4:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v4:GetAttribute("EmitDelay"))
					end

					v4:Emit(v4:GetAttribute("EmitCount"))
				end)
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v4 = emitter
				task.spawn(function()
					if v4:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v4:GetAttribute("EmitDelay"))
					end

					v4:Emit(v4:GetAttribute("EmitCount"))
				end)
			end

			task.wait(3)
			clone2:Destroy()
			clone:Destroy()
		end)
		task.delay(0.05, function()
			if self.destroyed or self.haloVisible ~= flag then
				return
			end

			local descendants = self.halo.Group:GetDescendants()
			tableAppend(descendants, self.halo.halo:GetDescendants()) -- equivalent call inferred; original call site unknown
			tableAppend(descendants, self.halo.halo) -- equivalent call inferred; original call site unknown
			tableAppend(descendants, self.halo.RootPart) -- equivalent call inferred; original call site unknown

			for _, folder in ipairs(self.handFlamesPartsL) do
				for _, descendant in pairs(folder:GetDescendants()) do
					table.insert(descendants, descendant)
				end
			end

			for _, folder in ipairs(self.handFlamesPartsR) do
				for _, descendant in pairs(folder:GetDescendants()) do
					table.insert(descendants, descendant)
				end
			end

			for _, instance in pairs(descendants) do
				if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
					instance.Enabled = flag
				elseif instance:IsA("BasePart") and instance.Name ~= "RootPart" and instance.Name ~= "Aura2" then
					instance.Transparency = flag and 0 or 1
				end
			end
		end)
	end
end

function DragonMoverClass:resetHaloState()
	self.initHaloActiveTime = 0

	for _, v4 in ipairs({ self.script.Parent.RingColor }) do
		local prevColorValueBeforeZ = v4:GetAttribute("PrevColorValueBeforeZ")

		if not prevColorValueBeforeZ then
			continue
		end

		v4.Value = prevColorValueBeforeZ
		v4:SetAttribute("PrevColorValueBeforeZ", nil)
	end
end

function DragonMoverClass:updateAura(p)
	for _, eyeFlamesPart in ipairs(self.eyeFlamesParts) do
		eyeFlamesPart.CFrame = self.eyeFlamesBoneWeld.TransformedWorldCFrame:ToWorldSpace(eyeFlamesPart:GetAttribute("RelativeCFrame"))
	end

	for _, v4 in ipairs(self.handFlamesPartsR) do
		v4.CFrame = self.handFlamesBoneWeldR.TransformedWorldCFrame:ToWorldSpace(v4:GetAttribute("RelativeCFrame"))
	end

	for _, v4 in ipairs(self.handFlamesPartsL) do
		v4.CFrame = self.handFlamesBoneWeldL.TransformedWorldCFrame:ToWorldSpace(v4:GetAttribute("RelativeCFrame"))
	end

	for _, mouthFlamesPart in ipairs(self.mouthFlamesParts) do
		mouthFlamesPart.CFrame = self.mouthFlamesBoneWeld.TransformedWorldCFrame:ToWorldSpace(mouthFlamesPart:GetAttribute("RelativeCFrame"))
	end

	for _, ringPart in ipairs(self.ringParts) do
		ringPart.CFrame = self.ringBoneWeld.TransformedWorldCFrame:ToWorldSpace(ringPart:GetAttribute("RelativeCFrame"))
	end

	if self.haloVisible then
		local halo = self.halo

		if halo:FindFirstChild("RootPart") == nil then
			return
		end

		local rootPart = halo.RootPart
		local haloCurrentSpeed

		if self.player == localPlayer then
			haloCurrentSpeed = self.haloCurrentSpeed
		else
			haloCurrentSpeed = self.script.Parent.HaloCurrentSpeed.Value
		end

		local cFrame = self.auraPart.Ring.Ring.Aura.CFrame
		local _ = self.haloScale
		self.haloProgress += p * haloCurrentSpeed * self.haloSide
		local haloProgress = self.haloProgress
		local v4 = math.sin(haloProgress / 2 * 1) * 0.05 * 2 + 1.05
		local v5 = math.sin(haloProgress * 3.141592653589793 * 1) * 0.017453292519943295 * v4
		local v6 = -math.cos(haloProgress * 3.141592653589793 * 1) * 0.017453292519943295 * v4
		local v7 = math.cos(haloProgress * 3.141592653589793 * 1) * 0.017453292519943295 * v4
		rootPart.CFrame = cFrame * CFrame.new(
			v7 * 100 * self.easternScaleModifier,
			v5 * 100 * self.easternScaleModifier,
			v6 * 100 * self.easternScaleModifier
		) * CFrame.Angles(v5, v7, 11.780972450961723 * (haloProgress / 37.69911184307752 * 1))
		halo.Group.out.outMotor6D.C0 = CFrame.new(0, 0, v6 * 75 * self.easternScaleModifier) * CFrame.Angles(
			0,
			0,
			math.sin(haloProgress * 1) * 0.2617993877991494 * v4
		)
		halo.Group.spheres.spheresMotor6D.C0 = CFrame.new(Vector3.new(0, 0, v7 + v5) * 75 * self.easternScaleModifier) * CFrame.Angles(
			v5,
			v6,
			v7
		)
		halo.Group.points.pointsMotor6D.C0 = CFrame.new(Vector3.new(0, 0, -(v7 + v5)) * 100 * self.easternScaleModifier) * CFrame.Angles(
			v7,
			v6,
			v5
		)
	end

	local v4

	if self.script.ZActive.Value == true and self.script.ZActive.FullyEnded.Value == false and self.script.HeadAimModeActive.Value == true then
		v4 = self.script.ZActive.Shot.Value == false
	else
		v4 = false
	end

	local v5 = { self.script.Parent.RingColor }
	local flag

	if self.wasZActive == self.script.ZActive.Value then
		flag = false
	else
		self.wasZActive = self.script.ZActive.Value
		flag = true

		if v4 then
			if self.events.ZUnheld ~= nil then
				self.events.ZUnheld:Disconnect()
				self.events.ZUnheld = nil
			end

			os.clock()
			self.events.ZUnheld = self.script.ZActive.DespawnHalo.Changed:Once(function()
				if not self.script.ZActive.DespawnHalo.Value then
					return
				end

				self.script.ZActive.DespawnHalo.Value = false
				self:SetHaloVisible(false)
				self:resetHaloState()
				self.haloStateReset = false
				self.initHaloActiveTime = 0

				for _, v6 in ipairs(v5) do
					local prevColorValueBeforeZ = v6:GetAttribute("PrevColorValueBeforeZ")

					if prevColorValueBeforeZ then
						v6.Value = prevColorValueBeforeZ
					end
				end
			end)
		elseif self.events.ZUnheld then
			if not (self.currentSpeed > 0) then
				self:SetHaloVisible(true)
			end

			self.events.ZUnheld:Disconnect()
			self.events.ZUnheld = nil
		end
	end

	if self.wasCActive2 ~= self.script.CActive.Value then
		self.wasCActive2 = self.script.CActive.Value
		flag = true
	end

	if flag then
		if v4 or self.script.CActive.Value == true then
			if self.script.ZActive.Value == true then
				self.initHaloActiveTime = time() + 5
			else
				self.initHaloActiveTime = time()
			end

			for _, v6 in ipairs(v5) do
				v6:SetAttribute("PrevColorValueBeforeZ", v6.Value)
			end
		else
			self.initHaloActiveTime = 0

			for _, v6 in ipairs(v5) do
				local prevColorValueBeforeZ = v6:GetAttribute("PrevColorValueBeforeZ")

				if prevColorValueBeforeZ then
					v6.Value = prevColorValueBeforeZ
				end
			end
		end
	end

	if v4 or self.script.CActive.Value == true then
		if not self.haloStateReset then
			self.haloStateReset = true
			self:SetHaloVisible(true)
			self:resetHaloState()

			if self.script.ZActive.Value == true then
				self.initHaloActiveTime = time() + 5
			else
				self.initHaloActiveTime = time()
			end

			for _, v6 in ipairs(v5) do
				v6:SetAttribute("PrevColorValueBeforeZ", v6.Value)
			end
		end

		if self._headAimingDisabling or self.char:FindFirstChild("FreezeDragonTag") then
			self.initHaloActiveTime = 0

			for _, v6 in ipairs(v5) do
				local prevColorValueBeforeZ = v6:GetAttribute("PrevColorValueBeforeZ")

				if prevColorValueBeforeZ then
					v6.Value = prevColorValueBeforeZ
				end
			end

			self.haloStateReset = false
			self:SetHaloVisible(false)
			self:resetHaloState()
		else
			local v6 = time() - self.initHaloActiveTime

			if v6 < 0 then
				return
			end

			if time() - (self._lastColorChange or 0) > 0.1111111111111111 then
				self._lastColorChange = time()

				for _, v7 in ipairs(v5) do
					local prevColorValueBeforeZ = v7:GetAttribute("PrevColorValueBeforeZ")

					if not prevColorValueBeforeZ then
						continue
					end

					local HSV, v8, v9 = prevColorValueBeforeZ:ToHSV()
					v7.Value = Color3.fromHSV((HSV - math.sin(5 * v6) ^ 2 * 0.3333333333333333) % 1, v8, v9)
				end
			end
		end
	elseif self.haloStateReset then
		self.haloStateReset = false
		self:SetHaloVisible(false)
		self:resetHaloState()
	end
end

function DragonMoverClass:destroy()
	self.destroyed = true

	if localPlayer ~= self.player and self.DragonSetupRemote:IsDescendantOf(game) then
		self.DragonSetupRemote:FireServer(false)
	end

	for _, event in pairs(self.events) do
		event:Disconnect()
	end

	self:switchCameraToProxyPart(false)
	self.proxyCameraPart:Destroy()
	self.halo:Destroy()

	if self.currentDragonLoopedSound and self.currentDragonLoopedSound.Parent ~= nil then
		Util.Sound:FadeOut(self.currentDragonLoopedSound, 0.2)
		Util.DestroyAfter(self.currentDragonLoopedSound, 0.3)
	end
end

return DragonMoverClass