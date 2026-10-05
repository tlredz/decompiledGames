local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local Map = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.AdminAbuseUtils.Map)
local Config = require(script.Parent.Parent.Config)
local cframe = CFrame.Angles(0, 0, 1.5707963267948966)
local cframe2 = CFrame.new(-0.101807, -0.5, -318.5)
local color = Color3.fromRGB(210, 75, 60)

local function getRandomCastleLocalCFrame(potentialInstance)
	local v = math.max(0, potentialInstance.Size.X * 0.5 - 55)
	local v2 = math.max(0, potentialInstance.Size.Y * 0.5 - 55)
	local castleHeightOffset = potentialInstance:GetAttribute("CastleHeightOffset") or 1
	assert(
		type(castleHeightOffset) == "number",
		"SandCastle AttackArea is missing a numeric \"CastleHeightOffset\" attribute"
	)
	return CFrame.new((math.random() * 2 - 1) * v, (math.random() * 2 - 1) * v2, castleHeightOffset)
end

local function getLocalRootPart()
	local localPlayer = Players.LocalPlayer
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function isStandingOnCastle(clone, humanoidRootPart, vector: Vector3, p: number)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { clone }
	return Workspace:Raycast(humanoidRootPart.Position, vector * p, raycastParams) ~= nil
end

local function isInsideDamageWater(clone, humanoidRootPart)
	local pointToObjectSpace = clone.CFrame:PointToObjectSpace(humanoidRootPart.Position)
	local v = clone.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v.X and pointToObjectSpace.Y >= -v.Y and pointToObjectSpace.Y <= v.Y + 10 and math.abs(pointToObjectSpace.Z) <= v.Z
end

local function tweenModelPivot(clone, cframe3: CFrame, tweenInfo)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = clone:GetPivot()
	cFrameValue.Parent = clone
	local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		if clone.Parent then
			clone:PivotTo(cFrameValue.Value)
		end
	end)
	local tween = TweenService:Create(cFrameValue, tweenInfo, {
		Value = cframe3
	})
	tween.Completed:Once(function()
		valueChangedConnection:Disconnect()
		cFrameValue:Destroy()
	end)
	tween:Play()
	return tween
end

local function destroyActive(state, list)
	if state.finished then
		return
	end

	state.finished = true
	local index = table.find(list, state)

	if index then
		table.remove(list, index)
	end

	state.telegraph:Destroy()
	state.water:Destroy()
	state.castle:Destroy()
end

return {
	new = function(configIndex: number, callback)
		local sandCastleAttackConfig = Config.sandCastleAttackConfigs[configIndex]
		assert(sandCastleAttackConfig, (`SandCastle config index {configIndex} does not exist`))
		assert(sandCastleAttackConfig.warningDurationSeconds > 0, "SandCastle warningDurationSeconds must be positive")
		assert(sandCastleAttackConfig.telegraphFlashSeconds > 0, "SandCastle telegraphFlashSeconds must be positive")
		assert(
			sandCastleAttackConfig.castleRiseDurationSeconds > 0,
			"SandCastle castleRiseDurationSeconds must be positive"
		)
		assert(
			sandCastleAttackConfig.waterRiseDurationSeconds > 0,
			"SandCastle waterRiseDurationSeconds must be positive"
		)
		assert(
			sandCastleAttackConfig.waterActiveDurationSeconds > 0,
			"SandCastle waterActiveDurationSeconds must be positive"
		)
		assert(sandCastleAttackConfig.damageTickSeconds > 0, "SandCastle damageTickSeconds must be positive")
		assert(
			sandCastleAttackConfig.waterLowerDurationSeconds > 0,
			"SandCastle waterLowerDurationSeconds must be positive"
		)
		assert(
			sandCastleAttackConfig.castleLowerDurationSeconds > 0,
			"SandCastle castleLowerDurationSeconds must be positive"
		)
		assert(sandCastleAttackConfig.recoverySeconds >= 0, "SandCastle recoverySeconds must be non-negative")
		assert(type(callback) == "function", "SandCastle requires an onLocalHit callback")
		local durationSeconds = sandCastleAttackConfig.castleRiseDurationSeconds + sandCastleAttackConfig.warningDurationSeconds + sandCastleAttackConfig.waterRiseDurationSeconds + sandCastleAttackConfig.waterActiveDurationSeconds + sandCastleAttackConfig.waterLowerDurationSeconds + sandCastleAttackConfig.castleLowerDurationSeconds + sandCastleAttackConfig.recoverySeconds
		local v2 = {}
		local flag = false
		return {
			name = "SandCastle",
			durationSeconds = durationSeconds,
			startServer = function(p2, callback2)
				local potentialInstance = InstanceUtils.getPotentialInstance(
					ServerStorage,
					"AdminAbuseMaps/SummerBossAA_August15th"
				)
				local potentialInstance2 = InstanceUtils.getPotentialInstance(potentialInstance, "Anchor")
				local potentialInstance3 = InstanceUtils.getPotentialInstance(
					potentialInstance,
					"Scriptables/AttackArea"
				)
				local parent = p2.Parent.Parent
				local potentialInstance4 = InstanceUtils.getPotentialInstance(parent, "Anchor")
				local v3 = potentialInstance3.CFrame * getRandomCastleLocalCFrame(potentialInstance3)
				local objectSpace = potentialInstance2.CFrame:ToObjectSpace(v3)
				callback2({
					kind = "BossAttack",
					attack = "SandCastle",
					action = "Spawn",
					position = (potentialInstance4.CFrame * objectSpace).Position,
					configIndex = configIndex
				})
			end,
			updateServer = function(_: number, _, _) end,
			handleServerEvent = function(data)
				if RunService:IsServer() or flag or typeof(data) ~= "table" then
					return
				end

				if data.kind ~= "BossAttack" or data.attack ~= "SandCastle" or data.action ~= "Spawn" or typeof(data.position) ~= "Vector3" or type(data.configIndex) ~= "number" then
					return
				end

				local sandCastleAttackConfig2 = Config.sandCastleAttackConfigs[data.configIndex]

				if not sandCastleAttackConfig2 then
					return
				end

				local map = Map.getMap("SummerBossAA_August15th_Live")
				local v3

				if map then
					v3 = InstanceUtils.getPotentialInstance(map, "Anchor")
				end

				if not v3 then
					return
				end

				local potentialInstance = InstanceUtils.getPotentialInstance(
					ReplicatedStorage,
					"AdminAbuse/SummerBossEvent_August15th/Assets/Attacks/SandCastle/CastleModel"
				)
				local potentialInstance2 = InstanceUtils.getPotentialInstance(
					ReplicatedStorage,
					"AdminAbuse/SummerBossEvent_August15th/Assets/Attacks/SandCastle/DamageWater"
				)

				if not (potentialInstance and potentialInstance2) then
					return
				end

				local clone = potentialInstance:Clone()
				local upVector = v3.CFrame.UpVector
				local v4 = CFrame.new(data.position) * v3.CFrame.Rotation * cframe
				local _, v5 = clone:GetBoundingBox()
				local v6 = v4 - upVector * (v5.Y + 5)
				clone:PivotTo(v6)
				clone.Parent = Workspace
				Debris:AddItem(clone, durationSeconds)
				local clone2 = potentialInstance2:Clone()
				local cFrame = v3.CFrame * cframe2
				local cFrame2 = cFrame - upVector * (clone2.Size.Y + 5)
				clone2.CFrame = cFrame2
				clone2.Parent = Workspace
				Debris:AddItem(clone2, durationSeconds)
				local clone3 = potentialInstance2:Clone()
				clone3.Name = "SandCastleFloodTelegraph"
				clone3.Anchored = true
				clone3.CanCollide = false
				clone3.CanQuery = false
				clone3.CanTouch = false
				clone3.CastShadow = false
				clone3.Material = Enum.Material.SmoothPlastic
				clone3.Color = color
				clone3.Transparency = 0.82
				clone3.CFrame = cFrame
				Debris:AddItem(clone3, durationSeconds)
				local v9 = {
					castle = clone,
					water = clone2,
					telegraph = clone3,
					thread = nil,
					finished = false
				}
				table.insert(v2, v9)
				v9.thread = task.spawn(function()
					local potentialInstance3 = InstanceUtils.getPotentialInstance(
						ReplicatedStorage,
						"AdminAbuse/SummerBossEvent_August15th/SFX/SandCastleAppear"
					)
					local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
					local clone4

					if potentialInstance3 and primaryPart then
						clone4 = potentialInstance3:Clone()
						clone4.Looped = true
						clone4.RollOffMinDistance = 80
						clone4.RollOffMaxDistance = 750
						clone4.RollOffMode = Enum.RollOffMode.InverseTapered
						clone4.Parent = primaryPart
						clone4:Play()
					end

					local v10 = tweenModelPivot(
						clone,
						v4,
						TweenInfo.new(
							sandCastleAttackConfig2.castleRiseDurationSeconds,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						)
					)

					if clone4 then
						local v11 = sandCastleAttackConfig2.castleRiseDurationSeconds * 0.35
						task.wait(sandCastleAttackConfig2.castleRiseDurationSeconds - v11)

						if not flag and clone4.Parent then
							TweenService:Create(
								clone4,
								TweenInfo.new(v11, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Volume = 0
								}
							):Play()
						end
					end

					v10.Completed:Wait()

					if clone4 then
						clone4:Stop()
						clone4:Destroy()
					end

					if flag then
						return
					end

					clone3.Parent = Workspace
					local lastTime = os.clock()
					local v11 = lastTime + sandCastleAttackConfig2.warningDurationSeconds

					while not flag and os.clock() < v11 do
						clone3.Transparency = (math.sin((os.clock() - lastTime) * 3.141592653589793 * 2 / sandCastleAttackConfig2.telegraphFlashSeconds) + 1) * 0.5 * 0.19999999999999996 + 0.62
						RunService.Heartbeat:Wait()
					end

					if flag then
						return
					end

					clone3:Destroy()
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(
							sandCastleAttackConfig2.waterRiseDurationSeconds,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							CFrame = cFrame
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local v12 = os.clock() + sandCastleAttackConfig2.waterActiveDurationSeconds
					local v13 = v5.Y + 10

					while not flag and os.clock() < v12 do
						local localPlayer = Players.LocalPlayer
						local character

						if localPlayer then
							character = localPlayer.Character
						end

						local humanoidRootPart

						if character then
							humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
						end

						if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
							humanoidRootPart = nil
						end

						if humanoidRootPart and isInsideDamageWater(clone2, humanoidRootPart) and not isStandingOnCastle(
							clone,
							humanoidRootPart,
							-upVector,
							v13
						) then
							callback()
						end

						task.wait(sandCastleAttackConfig2.damageTickSeconds)
					end

					if flag then
						return
					end

					local tween2 = TweenService:Create(
						clone2,
						TweenInfo.new(
							sandCastleAttackConfig2.waterLowerDurationSeconds,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.In
						),
						{
							CFrame = cFrame2
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					tweenModelPivot(
						clone,
						v6,
						TweenInfo.new(
							sandCastleAttackConfig2.castleLowerDurationSeconds,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.In
						)
					).Completed:Wait()
					destroyActive(v9, v2)
				end)
			end,
			cleanup = function()
				if flag then
					return
				end

				flag = true
				local clone = table.clone(v2)
				table.clear(v2)

				for _, v3 in clone do
					local thread = v3.thread

					if thread and coroutine.status(thread) ~= "dead" then
						task.cancel(thread)
					end

					v3.telegraph:Destroy()
					v3.water:Destroy()
					v3.castle:Destroy()
					v3.finished = true
				end
			end
		}
	end
}