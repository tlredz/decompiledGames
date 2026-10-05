local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local movement = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Movement")
local CameraFeelConfig = require(movement:WaitForChild("CameraFeelConfig"))
local MovementProfiles = require(movement:WaitForChild("MovementProfiles"))
local CameraCollision = require(movement:WaitForChild("CameraCollision"))
local v = CameraCollision.new(workspace)
local v2 = {}

local function spring(p, p2, p3, p4)
	local v3 = v2[p]

	if not v3 then
		v3 = {
			x = 0,
			v = 0
		}
		v2[p] = v3
	end

	local v4 = p4 or CameraFeelConfig.SpringFrequency
	local v5 = v3.x - p2
	local v6 = math.exp(-v4 * p3)
	local v7 = v3.v + v4 * v5
	v3.x = p2 + (v5 + v7 * p3) * v6
	v3.v = (v3.v - v4 * v7 * p3) * v6
	return v3.x
end

-- equivalent calls inferred from this helper; original call sites unknown
local function kick(p, p2)
	local v3 = v2[p]

	if not v3 then
		v3 = {
			x = 0,
			v = 0
		}
		v2[p] = v3
	end

	v3.v += p2
end

local v3 = nil
local humanoid = nil
local humanoidRootPart = nil
local dashCount = nil
local tackleStartedAt = nil
local v4 = createVector(0, 0, 0)
local v5 = createVector(0, 0, 0)
local v6 = true
local total = 0
local v7 = 0
local total2 = 0
local v8 = true
local v9 = nil
local cFrame = nil
local cFrame3 = nil
local fieldOfView = nil
local fieldOfView2 = nil
local connections = {}
local v11 = nil
local v12 = nil
local v13 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function removeLastEffect()
	if v9 then
		if v9.CFrame == cFrame then
			v9.CFrame = cFrame3
		end

		if v9.FieldOfView == fieldOfView then
			v9.FieldOfView = fieldOfView2
		end
	end

	v9 = nil
	cFrame = nil
	cFrame3 = nil
	fieldOfView = nil
	fieldOfView2 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clear()
	removeLastEffect() -- equivalent call inferred; original call site unknown
	table.clear(v2)
	v4 = createVector(0, 0, 0)
	v5 = createVector(0, 0, 0)
	total2 = 0
	v6 = true
	total = 0
	v7 = 0
end

table.insert(connections, UserInputService.WindowFocused:Connect(function()
	v8 = true
end))
table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
	v8 = false
end))
RunService:BindToRenderStep("ChickenOrHeroCameraFeelReset", Enum.RenderPriority.Input.Value - 1, removeLastEffect)
RunService:BindToRenderStep("ChickenOrHeroCameraFeel", Enum.RenderPriority.Camera.Value + 2, function(p)
	local v14 = MovementProfiles.get(localPlayer:GetAttribute("GameRole"), localPlayer)
	local character = localPlayer.Character

	if character ~= v3 then
		clear() -- equivalent call inferred; original call site unknown
		v3 = character
		v13 = false
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		dashCount = character and character:GetAttribute("DashCount")
		tackleStartedAt = character and character:GetAttribute("TackleStartedAt")
	end

	if v3 and not (humanoid and humanoidRootPart) then
		humanoid = v3:FindFirstChildOfClass("Humanoid")
		humanoidRootPart = v3:FindFirstChild("HumanoidRootPart")
	end

	local currentCamera = workspace.CurrentCamera
	local movementReset = v3 and v3:GetAttribute("MovementReset")

	if currentCamera ~= v12 then
		clear() -- equivalent call inferred; original call site unknown
		v12 = currentCamera
		v13 = false
	end

	if movementReset ~= v11 then
		v11 = movementReset
		v13 = false
	end

	local enabled = CameraFeelConfig.Enabled

	if enabled then
		if CameraFeelConfig.Intensity > 0 then
			enabled = v8 and currentCamera and humanoid and humanoidRootPart

			if enabled then
				if humanoid.Health > 0 then
					enabled = not (humanoid.Sit or humanoid.PlatformStand)

					if enabled then
						if currentCamera.CameraSubject == humanoid and currentCamera.CameraType ~= Enum.CameraType.Scriptable then
							enabled = not GuiService.MenuIsOpen

							if enabled then
								if UserInputService:GetFocusedTextBox() == nil and (localPlayer:GetAttribute("ReleaseCameraForUI") or localPlayer:GetAttribute("TutorialModalActive")) ~= true and localPlayer:GetAttribute("ChoiceSpotlightActive") ~= true and localPlayer:GetAttribute("ScreenPresentationActive") ~= true and localPlayer:GetAttribute("ReleaseCursorForControls") ~= true then
									enabled = v3:GetAttribute("MovementLocked") ~= true
								else
									enabled = false
								end
							end
						else
							enabled = false
						end
					end
				else
					enabled = false
				end
			end
		else
			enabled = false
		end
	end

	if enabled then
		local v15 = math.min(p, 0.1)

		if v15 <= 0 then
			return
		end

		local cFrame2 = currentCamera.CFrame
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

		if not v13 then
			v5 = vector2
			v4 = vector2
			total = 0
			v7 = 0
			v6 = humanoid.FloorMaterial ~= Enum.Material.Air
			dashCount = v3:GetAttribute("DashCount")
			tackleStartedAt = v3:GetAttribute("TackleStartedAt")
			v13 = true
		end

		v5 = v5:Lerp(vector2, 1 - math.exp(v15 * -12))
		local vectorToObjectSpace = cFrame2:VectorToObjectSpace(v5)
		local magnitude = v5.Magnitude
		local v16 = math.clamp(magnitude / v14.MaxSpeed, 0, 1)
		local vectorToObjectSpace2 = cFrame2:VectorToObjectSpace((v5 - v4) / v15)
		local v17 = humanoid.FloorMaterial ~= Enum.Material.Air
		local dashCount2 = v3:GetAttribute("DashCount") or 0

		if dashCount ~= nil and dashCount < dashCount2 then
			local v18 = math.clamp(vectorToObjectSpace.X / math.max(magnitude, 1), -1, 1)
			local v19 = v14.Dash.Mode ~= "RunBoost" and 1 or CameraFeelConfig.RunBoostKickScale or 1
			kick("roll", -v18 * CameraFeelConfig.DashRollKick * v19) -- equivalent call inferred; original call site unknown
			kick("pitch", CameraFeelConfig.DashPitchKick * v19) -- equivalent call inferred; original call site unknown
			kick("pullback", CameraFeelConfig.DashPullbackKick * v19) -- equivalent call inferred; original call site unknown
			kick("fov", CameraFeelConfig.DashFOV * 22 * v19) -- equivalent call inferred; original call site unknown
		end

		dashCount = dashCount2
		local tackleStartedAt2 = v3:GetAttribute("TackleStartedAt")
		local tackleDuration = v3:GetAttribute("TackleDuration") or 0
		local v18

		if v3:GetAttribute("TackleActive") == true and type(tackleStartedAt2) == "number" then
			v18 = workspace:GetServerTimeNow() < tackleStartedAt2 + tackleDuration
		else
			v18 = false
		end

		if v18 and (type(tackleStartedAt) ~= "number" or math.abs(tackleStartedAt2 - tackleStartedAt) > 0.1) then
			kick("pitch", CameraFeelConfig.DivePitchKick) -- equivalent call inferred; original call site unknown
			kick("pullback", CameraFeelConfig.DivePullbackKick) -- equivalent call inferred; original call site unknown
			kick("fov", CameraFeelConfig.DiveFOV * 18) -- equivalent call inferred; original call site unknown
		end

		tackleStartedAt = tackleStartedAt2

		if v17 then
			if not v6 and total >= 0.12 and v7 <= -3 then
				kick("vertical", -CameraFeelConfig.LandingKick) -- equivalent call inferred; original call site unknown
			end

			total = 0
			v7 = 0
		else
			total += v15
			v7 = math.min(v7, assemblyLinearVelocity.Y)
		end

		v6 = v17
		v4 = v5
		local v19 = spring("gait", v17 and v16 or 0, v15, 10)
		total2 += (CameraFeelConfig.StepFrequency + v16 * 0.6) * 3.141592653589793 * 2 * v15
		local v20 = -math.clamp(vectorToObjectSpace.X / v14.MaxSpeed, -1, 1) * math.rad(CameraFeelConfig.RunRollDegrees)
		local v21 = math.clamp(
			spring("roll", v20, v15),
			-math.rad(CameraFeelConfig.MaxRollDegrees),
			(math.rad(CameraFeelConfig.MaxRollDegrees))
		)
		local v22 = math.clamp(-vectorToObjectSpace2.Z / (v14.Acceleration * 3), -1, 1) * math.rad(CameraFeelConfig.AccelerationPitchDegrees)
		local v23 = math.clamp(
			spring("pitch", v22, v15),
			-math.rad(CameraFeelConfig.MaxPitchDegrees),
			(math.rad(CameraFeelConfig.MaxPitchDegrees))
		)
		local v24 = spring(
			"lateral",
			-math.clamp(vectorToObjectSpace.X / v14.MaxSpeed, -1, 1) * CameraFeelConfig.LateralLag,
			v15
		)
		local v25 = spring("vertical", 0, v15)
		local v26 = math.clamp(
			spring("pullback", v16 * 0.16 + (v18 and CameraFeelConfig.DivePullback or 0), v15),
			0,
			CameraFeelConfig.MaxPullback
		)
		local v27 = math.clamp(
			spring("fov", v16 * CameraFeelConfig.RunFOV, v15, CameraFeelConfig.FOVFrequency),
			0,
			CameraFeelConfig.RunFOV + math.max(CameraFeelConfig.DashFOV, CameraFeelConfig.DiveFOV)
		)
		local v28 = math.clamp(CameraFeelConfig.Intensity, 0, 1.5)
		local v29 = Vector3.new(
			v24 + math.sin(total2) * CameraFeelConfig.BobSide * v19,
			math.clamp(v25, -0.15, 0.15) + math.sin(total2 * 2) * CameraFeelConfig.BobHeight * v19,
			v26
		) * v28
		local position = (cFrame2 * CFrame.new(v29)).Position
		local constrain = v:constrain(cFrame2.Position, position, v3)
		v9 = currentCamera
		cFrame3 = cFrame2
		fieldOfView2 = currentCamera.FieldOfView
		cFrame = CFrame.new(constrain) * cFrame2.Rotation * CFrame.Angles(v23 * v28, 0, v21 * v28)
		fieldOfView = math.clamp(fieldOfView2 + v27 * v28, 1, 120)
		currentCamera.CFrame = cFrame
		currentCamera.FieldOfView = fieldOfView
		fieldOfView = currentCamera.FieldOfView
		cFrame = currentCamera.CFrame
	else
		clear() -- equivalent call inferred; original call site unknown
		dashCount = v3 and v3:GetAttribute("DashCount")
		tackleStartedAt = v3 and v3:GetAttribute("TackleStartedAt")
		v13 = false
	end
end)
script.Destroying:Connect(function()
	RunService:UnbindFromRenderStep("ChickenOrHeroCameraFeelReset")
	RunService:UnbindFromRenderStep("ChickenOrHeroCameraFeel")

	for _, connection in connections do
		connection:Disconnect()
	end

	clear() -- equivalent call inferred; original call site unknown
end)