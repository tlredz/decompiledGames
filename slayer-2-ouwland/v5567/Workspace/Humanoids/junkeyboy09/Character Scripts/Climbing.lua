local createVector = vector.create
local WAIT_INTERVAL = 0.35
local DISTANCE_EPSILON = 0.01
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local Skill_Info = require(ReplicatedStorage.CAM.Global.PlayerProfile.Skill_Info)
local Stats = require(ReplicatedStorage.CAM.Global.SkillService.Stats)
local v = false
local wallClimb = Skill_Info["Wall Climb"]
local skillTreeUnlockedList = data:WaitForChild("SkillTreeUnlockedList")

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	v = Stats.IsSkillUnlocked(localPlayer, "Wall Climb")
end

local child = skillTreeUnlockedList:FindFirstChild(wallClimb.Category)

if child then
	child.Changed:Connect(refresh)
else
	skillTreeUnlockedList.ChildAdded:Connect(function(child2)
		if child2.Name == wallClimb.Category then
			child2.Changed:Connect(refresh)
			refresh() -- equivalent call inferred; original call site unknown
		end
	end)
end

refresh() -- equivalent call inferred; original call site unknown
local parent = script.Parent.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
assert(humanoid ~= nil, "humanoid does not exist")
local v2 = {
	CurrentStamina = 7,
	MaxClimbTime = 7
}
local v3 = 1
local animator = humanoid:WaitForChild("Animator")
local tracks = {}
local v4 = nil
local v5 = false
local v6 = nil
local numberValue = Instance.new("NumberValue")
local v7 = nil
local TweenService = game:GetService("TweenService")
local ClimbBar = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.ClimbBar)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
numberValue.Changed:Connect(function(p)
	if v5 and v7 then
		v7:AdjustSpeed(p)
	end
end)

for _, v8 in {
	"climbup",
	"climbdown",
	"climbleft",
	"climbright",
	"ledge"
} do
	local get_core_anim = Character_info_provider.get_core_anim(localPlayer, v8)

	if not get_core_anim then
		continue
	end

	local track = animator:LoadAnimation(get_core_anim)
	track.Looped = v8 ~= "ledge"
	tracks[v8] = track
end

local function playClimbAnim(p: string)
	if v6 then
		v6:Cancel()
		v6 = nil
	end

	if v4 == p and not v5 then
		return
	end

	if v4 and v4 ~= p and tracks[v4] then
		tracks[v4]:Stop(0.15)
	end

	if tracks[p] then
		if v4 ~= p or not v5 then
			tracks[p]:Play(0.15)
		end

		tracks[p]:AdjustSpeed(1)
	end

	v5 = false
	v4 = p
end

local function pauseClimbAnim()
	if v4 and tracks[v4] and not v5 then
		v5 = true

		if v6 then
			v6:Cancel()
		end

		local v8 = tracks[v4]
		v7 = v8
		numberValue.Value = v8.Speed
		v6 = TweenService:Create(numberValue, tweenInfo, {
			Value = 0
		})
		v6:Play()
	end
end

local function stopAllClimbAnims()
	if v6 then
		v6:Cancel()
		v6 = nil
	end

	v7 = nil

	for k, v8 in tracks do
		if k ~= "ledge" then
			v8:Stop(0.2)
		end
	end

	v4 = nil
	v5 = false
end

local function resolveClimbAnim(p: number, p2: number)
	local v8 = math.abs(p)
	local v9 = math.abs(p2)

	if v8 < 0.25 and v9 < 0.25 then
		return nil
	end

	if v8 >= 0.25 then
		if p > 0 then
			return "climbup"
		end

		return "climbdown"
	elseif p2 > 0 then
		return "climbright"
	else
		return "climbleft"
	end
end

local clock = os.clock

local function shouldHidePrompt()
	local SHC = parent:FindFirstChild("SHC") or parent:FindFirstChild("SHCS")

	if SHC and SHC.Value ~= "" then
		return true
	end

	return clock() - Combat_presets.Last_Punched <= 1.5 or parent:GetAttribute("SwimDrowning") == true
end

local attachment = Instance.new("Attachment")
attachment.Name = "ClimbProximityAttachment"
local proximityPrompt = Instance.new("ProximityPrompt")
proximityPrompt.KeyboardKeyCode = Enum.KeyCode.T
proximityPrompt.ObjectText = "Wall"
proximityPrompt:SetAttribute("ActionImage", "rbxassetid://76503830534647")
proximityPrompt.RequiresLineOfSight = false
proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
proximityPrompt.ActionText = "Climb"
proximityPrompt:SetAttribute("CoolDown", 0.5)
proximityPrompt:AddTag("Dialogue")
proximityPrompt.Parent = attachment
proximityPrompt.MaxActivationDistance = 10
proximityPrompt.MaxIndicatorDistance = proximityPrompt.MaxActivationDistance + gameSettings.indicatorAdditionalDistance
local attachment2 = Instance.new("Attachment")
attachment2.Name = "ClimbAttachment"
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.MaxForce = 10000
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.VectorVelocity = createVector(0, 0, 0)
linearVelocity.Attachment0 = attachment2
linearVelocity.Parent = attachment2
local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.Attachment0 = attachment2
alignOrientation.Responsiveness = 35
alignOrientation.MaxTorque = 40000
alignOrientation.Parent = attachment2
local v8 = {}
local raycastResult = nil
local normal = nil
local flag = false
local v9 = false
local v10 = 0

local function updateState()
	local currentState = v8.Climbing and 1 or v8.Part == nil and 3 or 2

	if v8.CurrentState ~= currentState then
		v8.CurrentState = currentState

		if currentState == 1 then
			if raycastResult ~= nil then
				alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), -raycastResult.Normal)
			end

			attachment2.Parent = humanoidRootPart
		else
			attachment2.Parent = script
		end
	end
end

local v11 = nil
local v12 = nil
local v13 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function isDrowningInWater()
	return parent:GetAttribute("SwimDrowning") == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isUnderwater()
	return parent:GetAttribute("SwimUnderwater") == true
end

local function startClimbing()
	if not v or v2.CurrentStamina <= 1 or not Checker.check(
		localPlayer,
		"Climb",
		v8.Part and v8.Part:GetAttribute("ClimbBypass")
	) then
		return
	end

	if isDrowningInWater() then
		return
	end

	if v11 == nil then
		v11, v12, v13 = ClimbBar(parent.HumanoidRootPart.BillboardComponents)
	end

	v8.Climbing = true
	Checker.Climbing = true
	proximityPrompt.ActionText = "Stop Climbing"
	local worldPosition = attachment.WorldPosition
	attachment.Parent = humanoidRootPart
	attachment.WorldPosition = worldPosition
	proximityPrompt.Enabled = true
	tracks.climbup:Play(0.15)
	tracks.climbup:AdjustSpeed(0)
	tracks.climbup.TimePosition = 0
	v4 = "climbup"
	v5 = true
	updateState()
end

local v14 = 0

local function stopClimbing()
	local v15 = math.random(1, 99)
	v14 = v15
	v8.Climbing = false
	v8.Part = nil
	Checker.Climbing = false
	proximityPrompt.ActionText = "Climb"
	flag = false
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	proximityPrompt.Enabled = false
	Combat_presets.Last_Climb = os.clock()
	stopAllClimbAnims()
	updateState()
	task.delay(0.5, function()
		if v15 ~= v14 then
			return
		end

		if not v8.Climbing and v8.Part == nil then
			attachment.Parent = nil
		end
	end)
end

local function startCliffing()
	if flag or normal == nil then
		return
	end

	flag = true
	playClimbAnim("ledge")
	local unit = -Vector3.new(normal.X, 0, normal.Z)

	if unit.Magnitude > 0.01 then
		unit = unit.Unit
	end

	linearVelocity.VectorVelocity = (createVector(0, 1, 0) + unit).Unit * 11.5
	task.delay(0.35, function()
		if flag then
			flag = false
			stopClimbing()
		end
	end)
end

proximityPrompt.Triggered:Connect(function()
	if v8.Climbing then
		stopClimbing()
	else
		startClimbing()
	end
end)
parent:GetAttributeChangedSignal("SwimDrowning"):Connect(function()
	if parent:GetAttribute("SwimDrowning") ~= true then
		return
	end

	if v8.Climbing then
		stopClimbing()
	end

	if v11 ~= nil then
		v11()
		v11 = nil
		v12 = nil
		v13 = nil
	end
end)
local v15 = 0

while parent ~= nil and parent.Parent ~= nil do
	if v then
		local instance = nil
		local cFrame = humanoidRootPart.CFrame
		local X, unit, v16, normal2, v17, v18, unit2, moveDirection, lookVector, vector2, vector3, v19, v20, v21, v22, v23, v24, v25, v26

		if v8.Climbing then
			if not flag then
				v2.CurrentStamina = math.clamp(v2.CurrentStamina - v15, 0, v2.MaxClimbTime)
			end

			local v27 = 1 - v2.CurrentStamina / v2.MaxClimbTime

			if v12 ~= nil then
				v12:Set(v27)
			end

			if v13 ~= nil then
				local v28 = v2.CurrentStamina < v2.MaxClimbTime * 0.25 and 1 or 0
				v13:Set(v28)
			end

			if v2.CurrentStamina <= 0 then
				stopClimbing()
			else
				local flag2 = false
				local v28 = cFrame * CFrame.Angles(0, 1.413716694115407 * -v3, 0)
				raycastResult = workspace:Raycast(cFrame.Position, v28.lookVector * 4, RaycastHelper.Crater)

				if raycastResult == nil or not (raycastResult.Normal:Dot(createVector(0, 1, 0)) >= 0.5) then
					if raycastResult == nil then
						raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							cFrame.LookVector * 4,
							RaycastHelper.Crater
						)

						if raycastResult == nil or not (raycastResult.Normal:Dot(createVector(0, 1, 0)) >= 0.5) then
							if raycastResult == nil or raycastResult.Instance == nil then
								local v29 = cFrame * vector.create(v3 * 4 / 4, 0, 0)
								local unit3 = (cFrame * createVector(0, 0, -2) - v29).Unit
								raycastResult = workspace:Raycast(v29, unit3 * 4, RaycastHelper.Crater)

								if raycastResult == nil or not (raycastResult.Normal:Dot(createVector(0, 1, 0)) >= 0.5) then
									if raycastResult ~= nil then
										instance = raycastResult.Instance
										normal = raycastResult.Normal
									end
								else
									flag2 = true
									raycastResult = nil
								end
							else
								instance = raycastResult.Instance
								normal = raycastResult.Normal
							end
						else
							flag2 = true
							raycastResult = nil
						end
					else
						instance = raycastResult.Instance
						normal = raycastResult.Normal
					end
				else
					flag2 = true
					raycastResult = nil
				end

				if flag2 then
					startCliffing()
				end

				if v8.Climbing and linearVelocity.VectorVelocity.Y < -8.049999999999999 and humanoid.FloorMaterial ~= Enum.Material.Air then
					stopClimbing()
					v15 = task.wait()
				elseif raycastResult == nil and v8.Climbing then
					if flag or normal == nil or not (linearVelocity.VectorVelocity.Y > 0.1) then
						if not flag then
							stopClimbing()
						end
					else
						flag = true
						playClimbAnim("ledge")
						X = normal.X
						unit = -Vector3.new(X, 0, normal.Z)

						if unit.Magnitude > DISTANCE_EPSILON then
							unit = unit.Unit
						end

						linearVelocity.VectorVelocity = (createVector(0, 1, 0) + unit).Unit * 11.5
						task.delay(0.35, function()
							if flag then
								flag = false
								stopClimbing()
							end
						end)
					end

					v15 = task.wait()
				else
					v16 = not v8.Climbing and shouldHidePrompt()

					if not v8.Climbing and instance ~= nil and instance == v8.Part and not v9 and v10 <= os.clock() then
						v10 = os.clock() + 0.25

						if instance:GetAttribute("NoClimb") == true then
							v9 = false
						else
							v9 = Checker.check(localPlayer, "Climb", instance:GetAttribute("ClimbBypass"))
						end
					end

					if v8.Part == instance then
						if not v8.Climbing and raycastResult ~= nil and v9 then
							proximityPrompt.Enabled = not v16

							if instance ~= nil then
								attachment.WorldPosition = attachment.WorldPosition:Lerp(raycastResult.Position, 0.1)
							end
						end

						if v8.Climbing and raycastResult ~= nil then
							attachment.WorldPosition = raycastResult.Position
						end

						if v8.Climbing then
							if raycastResult then
								normal2 = raycastResult.Normal
							else
								normal2 = normal
							end

							v18 = (isUnderwater() and 0.6 or 1) * 11.5 * PlayerStatResolver.GetMovementMultiplier(localPlayer)
							unit2 = (createVector(0, 1, 0)):Cross(normal2)

							if unit2.Magnitude > DISTANCE_EPSILON then
								unit2 = unit2.Unit
							end

							moveDirection = humanoid.MoveDirection

							if moveDirection.Magnitude > DISTANCE_EPSILON then
								lookVector = workspace.CurrentCamera.CFrame.LookVector
								vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

								if vector2.Magnitude > DISTANCE_EPSILON then
									vector2 = vector2.Unit
								end

								vector3 = Vector3.new(-vector2.Z, 0, vector2.X)
								v19 = moveDirection:Dot(vector2)
								v20 = moveDirection:Dot(vector3)
								v3 = not (math.abs(v20) > 0.5) and 0 or math.sign(v20)
								v17 = (createVector(0, 1, 0) * v19 + unit2 * v3).Unit * v18
								v21 = v3
							else
								v19 = 0
								v21 = 0
							end

							if not flag then
								v22 = math.abs(v19)
								v23 = math.abs(v21)

								if not (v22 < 0.25 and v23 < 0.25) then
									if v22 >= 0.25 then
										v24 = v19 > 0 and "climbup" or "climbdown"
									else
										v24 = v21 > 0 and "climbright" or "climbleft"
									end
								end

								if v24 then
									playClimbAnim(v24)
								else
									pauseClimbAnim()
								end
							end

							if raycastResult then
								v25 = raycastResult.Distance - 1.45
								v26 = -normal2 * v25 * 11.5
								v17 = (v17 or createVector(0, 0, 0)) + v26
							end

							linearVelocity.VectorVelocity = v17 or createVector(0, 0, 0)
							alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), -normal2)
						end

						if instance == nil and not (v2.CurrentStamina < v2.MaxClimbTime) then
							v15 = task.wait(WAIT_INTERVAL)
						else
							v15 = task.wait()
						end
					elseif v8.Climbing and instance ~= nil and (normal and normal:Dot(createVector(0, 1, 0)) >= 0.5 or instance:GetAttribute("NoClimb") == true) then
						stopClimbing()
						v15 = task.wait()
					else
						if instance == nil then
							v9 = false
						elseif instance:GetAttribute("NoClimb") == true then
							v9 = false
						else
							v9 = Checker.check(localPlayer, "Climb", instance:GetAttribute("ClimbBypass"))
						end

						if not v8.Climbing then
							if raycastResult == nil or not v9 then
								proximityPrompt.Enabled = false
								attachment.Parent = nil
							else
								attachment.Parent = workspace.Terrain
								attachment.WorldPosition = raycastResult.Position
								proximityPrompt.Enabled = not v16
							end
						end

						v8.Part = instance
						updateState()

						if v8.Climbing and raycastResult ~= nil then
							attachment.WorldPosition = raycastResult.Position
						end

						if v8.Climbing then
							if raycastResult then
								normal2 = raycastResult.Normal
							else
								normal2 = normal
							end

							v18 = (isUnderwater() and 0.6 or 1) * 11.5 * PlayerStatResolver.GetMovementMultiplier(localPlayer)
							unit2 = (createVector(0, 1, 0)):Cross(normal2)

							if unit2.Magnitude > DISTANCE_EPSILON then
								unit2 = unit2.Unit
							end

							moveDirection = humanoid.MoveDirection

							if moveDirection.Magnitude > DISTANCE_EPSILON then
								lookVector = workspace.CurrentCamera.CFrame.LookVector
								vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

								if vector2.Magnitude > DISTANCE_EPSILON then
									vector2 = vector2.Unit
								end

								vector3 = Vector3.new(-vector2.Z, 0, vector2.X)
								v19 = moveDirection:Dot(vector2)
								v20 = moveDirection:Dot(vector3)
								v3 = not (math.abs(v20) > 0.5) and 0 or math.sign(v20)
								v17 = (createVector(0, 1, 0) * v19 + unit2 * v3).Unit * v18
								v21 = v3
							else
								v19 = 0
								v21 = 0
							end

							if not flag then
								v22 = math.abs(v19)
								v23 = math.abs(v21)

								if not (v22 < 0.25 and v23 < 0.25) then
									if v22 >= 0.25 then
										v24 = v19 > 0 and "climbup" or "climbdown"
									else
										v24 = v21 > 0 and "climbright" or "climbleft"
									end
								end

								if v24 then
									playClimbAnim(v24)
								else
									pauseClimbAnim()
								end
							end

							if raycastResult then
								v25 = raycastResult.Distance - 1.45
								v26 = -normal2 * v25 * 11.5
								v17 = (v17 or createVector(0, 0, 0)) + v26
							end

							linearVelocity.VectorVelocity = v17 or createVector(0, 0, 0)
							alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), -normal2)
						end

						if instance == nil and not (v2.CurrentStamina < v2.MaxClimbTime) then
							v15 = task.wait(WAIT_INTERVAL)
						else
							v15 = task.wait()
						end
					end
				end
			end
		else
			if v2.CurrentStamina < v2.MaxClimbTime then
				v2.CurrentStamina = math.clamp(v2.CurrentStamina + v15 / 2, 0, v2.MaxClimbTime)

				if v12 ~= nil then
					local v27 = 1 - v2.CurrentStamina / v2.MaxClimbTime
					v12:Set(v27)
				end

				if v13 ~= nil then
					v13:Set(0)
				end

				if v2.CurrentStamina >= v2.MaxClimbTime and v11 ~= nil then
					v11()
					v11 = nil
					v12 = nil
					v13 = nil
				end
			end

			raycastResult = workspace:Raycast(humanoidRootPart.Position, cFrame.LookVector * 4, RaycastHelper.Crater)

			if raycastResult == nil or raycastResult.Instance == nil or not (raycastResult.Normal:Dot(createVector(
				0,
				1,
				0
			)) < 0.5) then
				if raycastResult ~= nil and raycastResult.Normal:Dot(createVector(0, 1, 0)) >= 0.5 then
					raycastResult = nil
				end
			else
				instance = raycastResult.Instance
				normal = raycastResult.Normal
			end

			if v8.Climbing and linearVelocity.VectorVelocity.Y < -8.049999999999999 and humanoid.FloorMaterial ~= Enum.Material.Air then
				stopClimbing()
				v15 = task.wait()
			elseif raycastResult == nil and v8.Climbing then
				if flag or normal == nil or not (linearVelocity.VectorVelocity.Y > 0.1) then
					if not flag then
						stopClimbing()
					end
				else
					flag = true
					playClimbAnim("ledge")
					X = normal.X
					unit = -Vector3.new(X, 0, normal.Z)

					if unit.Magnitude > DISTANCE_EPSILON then
						unit = unit.Unit
					end

					linearVelocity.VectorVelocity = (createVector(0, 1, 0) + unit).Unit * 11.5
					task.delay(0.35, function()
						if flag then
							flag = false
							stopClimbing()
						end
					end)
				end

				v15 = task.wait()
			else
				v16 = not v8.Climbing and shouldHidePrompt()

				if not v8.Climbing and instance ~= nil and instance == v8.Part and not v9 and v10 <= os.clock() then
					v10 = os.clock() + 0.25

					if instance:GetAttribute("NoClimb") == true then
						v9 = false
					else
						v9 = Checker.check(localPlayer, "Climb", instance:GetAttribute("ClimbBypass"))
					end
				end

				if v8.Part == instance then
					if not v8.Climbing and raycastResult ~= nil and v9 then
						proximityPrompt.Enabled = not v16

						if instance ~= nil then
							attachment.WorldPosition = attachment.WorldPosition:Lerp(raycastResult.Position, 0.1)
						end
					end

					if v8.Climbing and raycastResult ~= nil then
						attachment.WorldPosition = raycastResult.Position
					end

					if v8.Climbing then
						if raycastResult then
							normal2 = raycastResult.Normal
						else
							normal2 = normal
						end

						v18 = (isUnderwater() and 0.6 or 1) * 11.5 * PlayerStatResolver.GetMovementMultiplier(localPlayer)
						unit2 = (createVector(0, 1, 0)):Cross(normal2)

						if unit2.Magnitude > DISTANCE_EPSILON then
							unit2 = unit2.Unit
						end

						moveDirection = humanoid.MoveDirection

						if moveDirection.Magnitude > DISTANCE_EPSILON then
							lookVector = workspace.CurrentCamera.CFrame.LookVector
							vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

							if vector2.Magnitude > DISTANCE_EPSILON then
								vector2 = vector2.Unit
							end

							vector3 = Vector3.new(-vector2.Z, 0, vector2.X)
							v19 = moveDirection:Dot(vector2)
							v20 = moveDirection:Dot(vector3)
							v3 = not (math.abs(v20) > 0.5) and 0 or math.sign(v20)
							v17 = (createVector(0, 1, 0) * v19 + unit2 * v3).Unit * v18
							v21 = v3
						else
							v19 = 0
							v21 = 0
						end

						if not flag then
							v22 = math.abs(v19)
							v23 = math.abs(v21)

							if not (v22 < 0.25 and v23 < 0.25) then
								if v22 >= 0.25 then
									v24 = v19 > 0 and "climbup" or "climbdown"
								else
									v24 = v21 > 0 and "climbright" or "climbleft"
								end
							end

							if v24 then
								playClimbAnim(v24)
							else
								pauseClimbAnim()
							end
						end

						if raycastResult then
							v25 = raycastResult.Distance - 1.45
							v26 = -normal2 * v25 * 11.5
							v17 = (v17 or createVector(0, 0, 0)) + v26
						end

						linearVelocity.VectorVelocity = v17 or createVector(0, 0, 0)
						alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), -normal2)
					end

					if instance == nil and not (v2.CurrentStamina < v2.MaxClimbTime) then
						v15 = task.wait(WAIT_INTERVAL)
					else
						v15 = task.wait()
					end
				elseif v8.Climbing and instance ~= nil and (normal and normal:Dot(createVector(0, 1, 0)) >= 0.5 or instance:GetAttribute("NoClimb") == true) then
					stopClimbing()
					v15 = task.wait()
				else
					if instance == nil then
						v9 = false
					elseif instance:GetAttribute("NoClimb") == true then
						v9 = false
					else
						v9 = Checker.check(localPlayer, "Climb", instance:GetAttribute("ClimbBypass"))
					end

					if not v8.Climbing then
						if raycastResult == nil or not v9 then
							proximityPrompt.Enabled = false
							attachment.Parent = nil
						else
							attachment.Parent = workspace.Terrain
							attachment.WorldPosition = raycastResult.Position
							proximityPrompt.Enabled = not v16
						end
					end

					v8.Part = instance
					updateState()

					if v8.Climbing and raycastResult ~= nil then
						attachment.WorldPosition = raycastResult.Position
					end

					if v8.Climbing then
						if raycastResult then
							normal2 = raycastResult.Normal
						else
							normal2 = normal
						end

						v18 = (isUnderwater() and 0.6 or 1) * 11.5 * PlayerStatResolver.GetMovementMultiplier(localPlayer)
						unit2 = (createVector(0, 1, 0)):Cross(normal2)

						if unit2.Magnitude > DISTANCE_EPSILON then
							unit2 = unit2.Unit
						end

						moveDirection = humanoid.MoveDirection

						if moveDirection.Magnitude > DISTANCE_EPSILON then
							lookVector = workspace.CurrentCamera.CFrame.LookVector
							vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

							if vector2.Magnitude > DISTANCE_EPSILON then
								vector2 = vector2.Unit
							end

							vector3 = Vector3.new(-vector2.Z, 0, vector2.X)
							v19 = moveDirection:Dot(vector2)
							v20 = moveDirection:Dot(vector3)
							v3 = not (math.abs(v20) > 0.5) and 0 or math.sign(v20)
							v17 = (createVector(0, 1, 0) * v19 + unit2 * v3).Unit * v18
							v21 = v3
						else
							v19 = 0
							v21 = 0
						end

						if not flag then
							v22 = math.abs(v19)
							v23 = math.abs(v21)

							if not (v22 < 0.25 and v23 < 0.25) then
								if v22 >= 0.25 then
									v24 = v19 > 0 and "climbup" or "climbdown"
								else
									v24 = v21 > 0 and "climbright" or "climbleft"
								end
							end

							if v24 then
								playClimbAnim(v24)
							else
								pauseClimbAnim()
							end
						end

						if raycastResult then
							v25 = raycastResult.Distance - 1.45
							v26 = -normal2 * v25 * 11.5
							v17 = (v17 or createVector(0, 0, 0)) + v26
						end

						linearVelocity.VectorVelocity = v17 or createVector(0, 0, 0)
						alignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), -normal2)
					end

					if instance == nil and not (v2.CurrentStamina < v2.MaxClimbTime) then
						v15 = task.wait(WAIT_INTERVAL)
					else
						v15 = task.wait()
					end
				end
			end
		end
	else
		v15 = task.wait(0.5)
	end
end