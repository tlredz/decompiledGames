local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local MovementConfig = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Movement"):WaitForChild("MovementConfig"))
local camera = MovementConfig.Camera
localPlayer.CameraMinZoomDistance = camera.MinZoom
localPlayer.CameraMaxZoomDistance = camera.MaxZoom
local ControlGate = require(game.ReplicatedStorage.ChickenOrHero.Movement:WaitForChild("ControlGate"))
local v = nil
local v2 = nil
local v3 = nil
local autoRotate2 = nil
local cameraOffset2 = nil
local v6 = true
local connections = {}
local v7 = nil
local v8 = false
local unit = nil
local mouseBehavior = UserInputService.MouseBehavior
local mouseIconEnabled = UserInputService.MouseIconEnabled

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseCharacter()
	v8 = false
	unit = nil

	if v2 and v2.Parent then
		v2.AutoRotate = autoRotate2
		v2.CameraOffset = cameraOffset2
	end

	v = nil
	v2 = nil
	v3 = nil
end

local function bindCharacter(instance)
	releaseCharacter() -- equivalent call inferred; original call site unknown
	local humanoid = instance:WaitForChild("Humanoid", 10)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)

	if not humanoid or not humanoidRootPart or localPlayer.Character ~= instance then
		return
	end

	v = instance
	v2 = humanoid
	v3 = humanoidRootPart
	v7 = nil
	local autoRotate = humanoid.AutoRotate
	local cameraOffset = humanoid.CameraOffset
	autoRotate2 = autoRotate
	cameraOffset2 = cameraOffset
end

table.insert(connections, localPlayer.CharacterAdded:Connect(bindCharacter))
table.insert(connections, localPlayer.CharacterRemoving:Connect(function(character)
	if character == v then
		releaseCharacter() -- equivalent call inferred; original call site unknown
	end
end))
table.insert(connections, UserInputService.WindowFocused:Connect(function()
	v6 = true
end))
table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
	v6 = false
end))

if localPlayer.Character then
	task.spawn(bindCharacter, localPlayer.Character)
end

RunService:BindToRenderStep("CoHSpawnFacing", Enum.RenderPriority.Camera.Value - 1, function()
	if localPlayer:GetAttribute("Spectating") == true or not v or not v3 or localPlayer:GetAttribute("ChoiceSpotlightActive") == true then
		return
	end

	local spawnFacingVersion = v:GetAttribute("SpawnFacingVersion")
	local spawnFacing = v:GetAttribute("SpawnFacing")
	local currentCamera = workspace.CurrentCamera

	if spawnFacingVersion ~= nil and spawnFacingVersion ~= v7 and typeof(spawnFacing) == "Vector3" and spawnFacing.Magnitude > 0.001 and currentCamera and currentCamera.CameraType ~= Enum.CameraType.Scriptable and currentCamera.CameraSubject == v2 then
		v7 = spawnFacingVersion
		local v9 = math.clamp(
			(currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude,
			camera.MinZoom,
			camera.MaxZoom
		)
		local v10 = math.clamp(currentCamera.CFrame.LookVector.Y, -0.6, 0.2)
		local v11 = spawnFacing * createVector(1, 0, 1)

		if v11.Magnitude < 0.001 then
			return
		end

		local v12 = v11.Unit * math.sqrt(1 - v10 * v10) + createVector(0, 1, 0) * v10
		local v13 = v3.Position + createVector(0, 1.5, 0)
		currentCamera.CFrame = CFrame.lookAt(v13 - v12 * v9, v13)
		currentCamera.Focus = CFrame.new(v13)
	end
end)
RunService:BindToRenderStep("ChickenOrHeroLockedCamera", Enum.RenderPriority.Camera.Value + 1, function()
	v8 = false

	if localPlayer:GetAttribute("Spectating") == true then
		if v2 then
			v2.AutoRotate = autoRotate2
		end
	else
		local currentCamera = workspace.CurrentCamera
		local v9 = v2 and v3

		if v9 then
			if v2.Health > 0 then
				if currentCamera then
					if currentCamera.CameraSubject == v2 then
						v9 = currentCamera.CameraType ~= Enum.CameraType.Scriptable
					else
						v9 = false
					end
				else
					v9 = currentCamera
				end
			else
				v9 = false
			end
		end

		local v10

		if localPlayer:GetAttribute("MatchSummaryVisible") == true and localPlayer:GetAttribute("InMatch") ~= true then
			v10 = game.ReplicatedStorage.ChickenOrHero.Game.Session:GetAttribute("Phase") == "Intermission"
		else
			v10 = false
		end

		local v11

		if UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
			v11 = localPlayer:GetAttribute("InMatch") ~= true
		else
			v11 = false
		end

		local v12 = ControlGate.cursorReason(localPlayer) ~= nil or v10 and not v11

		if v9 and v6 and (v11 or v12) then
			if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end

			UserInputService.MouseIconEnabled = true
			v2.AutoRotate = autoRotate2
			v2.CameraOffset = cameraOffset2
		elseif v9 and v6 then
			if UserInputService.MouseEnabled then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				UserInputService.MouseIconEnabled = false
			end

			v2.CameraOffset = camera.ShoulderOffset

			if v:GetAttribute("TackleActive") or v:GetAttribute("GearMotion") then
				return
			end

			if v2.Sit or v2.PlatformStand or v3.Anchored or v2:GetState() == Enum.HumanoidStateType.Physics then
				v2.AutoRotate = autoRotate2
			else
				v2.AutoRotate = false
				local lookVector = currentCamera.CFrame.LookVector
				local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

				if vector2.Magnitude > 0.001 then
					unit = vector2.Unit
					v8 = true
				end
			end
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true

			if v2 then
				v2.AutoRotate = autoRotate2
				v2.CameraOffset = cameraOffset2
			end
		end
	end
end)
table.insert(connections, RunService.PreSimulation:Connect(function()
	if not v8 or not unit or not v3 or not v3.Parent or localPlayer.Character ~= v or v2.Health <= 0 or v2.Sit or v2.PlatformStand or v3.Anchored or v2:GetState() == Enum.HumanoidStateType.Physics or v:GetAttribute("TackleActive") or v:GetAttribute("GearMotion") then
		return
	end

	if v3.CFrame.LookVector:Dot(unit) < 0.999999 or v3.CFrame.UpVector:Dot(createVector(0, 1, 0)) < 0.999999 then
		v3.CFrame = CFrame.lookAt(v3.Position, v3.Position + unit)
	end
end))
script.Destroying:Connect(function()
	RunService:UnbindFromRenderStep("ChickenOrHeroLockedCamera")
	RunService:UnbindFromRenderStep("CoHSpawnFacing")

	for _, connection in connections do
		connection:Disconnect()
	end

	releaseCharacter() -- equivalent call inferred; original call site unknown
	UserInputService.MouseBehavior = mouseBehavior
	UserInputService.MouseIconEnabled = mouseIconEnabled
end)