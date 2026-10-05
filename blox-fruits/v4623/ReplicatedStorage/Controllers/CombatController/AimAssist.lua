local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local AimAssistSettings = require(ReplicatedStorage.Modules:WaitForChild("AimAssistSettings"))
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
end)
localPlayer.CharacterRemoving:Connect(function(character2)
	if character == character2 then
		character = nil
	end
end)
local connections = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
local defaultProfile = nil
local zero = Vector2.zero
local now = 0
local v = 0
local part = nil
local v2 = 0

local function clamp01(value: number)
	return (math.clamp(value, 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getInitialProfileName()
	if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
		return "Mobile"
	end

	if UserInputService.GamepadEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
		return "Console"
	end

	return AimAssistSettings.DefaultProfile
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isGamepadInput(p)
	return p.Name:sub(1, 7) == "Gamepad"
end

local function getProfileNameForInput(data)
	if isGamepadInput(data.UserInputType) then
		return "Console"
	end

	if data.UserInputType == Enum.UserInputType.Touch then
		return "Mobile"
	end

	if data.UserInputType == Enum.UserInputType.MouseMovement or data.UserInputType == Enum.UserInputType.MouseButton1 or data.UserInputType == Enum.UserInputType.MouseButton2 or data.UserInputType == Enum.UserInputType.MouseButton3 or data.UserInputType == Enum.UserInputType.MouseWheel or data.UserInputType == Enum.UserInputType.Keyboard then
		return "PC"
	end

	return nil
end

local function getProfileName()
	local v3 = defaultProfile or getInitialProfileName()

	if AimAssistSettings.Profiles[v3] ~= nil then
		return v3
	end

	if AimAssistSettings.Profiles[AimAssistSettings.DefaultProfile] == nil then
		return "PC"
	end

	return AimAssistSettings.DefaultProfile
end

local function getProfile(p)
	local profile = AimAssistSettings.Profiles[p]

	if profile == nil then
		return AimAssistSettings.Profiles[AimAssistSettings.DefaultProfile]
	end

	return profile
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEquippedTool()
	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") then
			return tool
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCharacterSpeed()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.AssemblyLinearVelocity.Magnitude
	end

	return 0
end

local function getCameraInputAmount(p, _)
	local magnitude = 0

	if p == "Console" then
		magnitude = zero.Magnitude * 10
	elseif p == "Mobile" then
		if os.clock() - now <= 0.1 then
			magnitude = v
		end
	else
		magnitude = UserInputService:GetMouseDelta().Magnitude
	end

	v = 0
	return magnitude
end

local function getTargetRoot(instance)
	local model = instance:FindFirstAncestorOfClass("Model")

	if model == nil then
		return instance
	end

	return model
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAliveTarget(part2)
	local model = part2:FindFirstAncestorOfClass("Model")

	if model == nil then
		return true
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	return humanoid == nil or humanoid.Health > 0
end

local function hasLineOfSight(object, part2, position: Vector3)
	local position2 = object.CFrame.Position
	local v3 = position - position2

	if v3.Magnitude <= 0.001 then
		return false
	end

	raycastParams.FilterDescendantsInstances = {
		character,
		workspace._WorldOrigin,
		workspace.CurrentCamera,
		workspace.Terrain
	}
	local raycastResult = Workspace:Raycast(position2, v3, raycastParams)

	if not (raycastResult ~= nil and raycastResult.Instance ~= part2) then
		return true
	end

	local instance = raycastResult.Instance
	local model = part2:FindFirstAncestorOfClass("Model")

	if model ~= nil then
		part2 = model
	end

	return instance:IsDescendantOf(part2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRadialStrength(p: number, p2: number, p3: number)
	if p <= p2 then
		return 1
	end

	local v3 = math.max(p3 - p2, 1)
	return 1 - math.clamp((p - p2) / v3, 0, 1)
end

local parts = {}

local function handleFolder(instance)
	local function processChar(child)
		local parts2 = {}
		local thread = task.delay(1, function()
			for _, part2 in child:GetChildren() do
				if not (part2:IsA("BasePart") and part2.Name == "Head") then
					continue
				end

				table.insert(parts2, part2)
				table.insert(parts, part2)
			end
		end)
		local ancestryChangedConnection = nil
		ancestryChangedConnection = child.AncestryChanged:Connect(function(_, parent)
			if parent ~= instance then
				ancestryChangedConnection:Disconnect()
				pcall(task.cancel, thread)

				for _, v3 in parts2 do
					local index = table.find(parts, v3)

					if index then
						table.remove(parts, index)
					end
				end
			end
		end)
	end

	for _, child in instance:GetChildren() do
		processChar(child)
	end

	instance.ChildAdded:Connect(processChar)
end

handleFolder(workspace.Characters)
handleFolder(workspace.Enemies)

local function trackTaggedParts()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(part2)
		if part2:IsA("BasePart") and not table.find(parts, part2) then
			table.insert(parts, part2)
		end
	end

	local function remove(p)
		local index = table.find(parts, p)

		if index then
			table.remove(parts, index)
		end
	end

	for _, v3 in CollectionService:GetTagged(AimAssistSettings.TargetTag) do
		add(v3) -- equivalent call inferred; original call site unknown
	end

	table.insert(connections, CollectionService:GetInstanceAddedSignal(AimAssistSettings.TargetTag):Connect(add))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(AimAssistSettings.TargetTag):Connect(remove))
end

trackTaggedParts()

local function isOwnedByOther(instance)
	local attribute = instance:GetAttribute(AimAssistSettings.OwnerAttribute)
	return attribute ~= nil and attribute ~= localPlayer.UserId
end

local function readTargetParts(_)
	return parts
end

local function chooseTarget(currentCamera, profile, p)
	local viewportSize = currentCamera.ViewportSize
	local v3 = viewportSize.Y / math.max(AimAssistSettings.ReferenceViewportHeight, 1)
	local vector

	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		vector = Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.5)
	else
		vector = UserInputService:GetMouseLocation()
	end

	local now2 = os.clock()
	local v4 = nil

	for _, part2 in parts do
		if typeof(part2) ~= "Instance" or not part2:IsA("BasePart") or part2.Parent == nil or part2:IsDescendantOf(character) then
			continue
		end

		-- equivalent call inferred; original call site unknown
		if not isAliveTarget(part2) then
			continue
		end

		local attribute = part2:GetAttribute(AimAssistSettings.OwnerAttribute)
		local v5

		if attribute == nil then
			v5 = false
		else
			v5 = attribute ~= localPlayer.UserId
		end

		if v5 then
			continue
		end

		local position = part2.Position
		local magnitude = (position - currentCamera.CFrame.Position).Magnitude

		if profile.MaxDistance < magnitude then
			continue
		end

		local worldToViewportPoint, v6 = currentCamera:WorldToViewportPoint(position)

		if not v6 or worldToViewportPoint.Z <= 0 then
			continue
		end

		local magnitude2 = (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - vector).Magnitude
		local v7

		if part2 == part then
			v7 = now2 - v2 <= 0.1
		else
			v7 = false
		end

		local v8

		if v7 then
			v8 = profile.AssistRadiusPixels * 1.5
		else
			v8 = profile.AssistRadiusPixels
		end

		local v9 = (v8 + p.RadiusBoost) * v3
		local v10 = profile.InnerRadiusPixels * v3
		local screenDistance = magnitude2 + magnitude / 20 * v3

		if v9 < screenDistance or not hasLineOfSight(currentCamera, part2, position) then
			continue
		end

		local radialStrength = getRadialStrength(screenDistance, v10, v9) -- equivalent call inferred; original call site unknown
		local score = screenDistance / math.max(v9, 1) * 0.85 + magnitude / math.max(profile.MaxDistance, 1) * 0.15

		if v7 then
			score -= 0.1
		end

		if v4 == nil or score < v4.Score then
			v4 = {
				Part = part2,
				Position = position,
				ScreenDistance = screenDistance,
				WorldDistance = magnitude,
				Strength = radialStrength,
				Score = score
			}
		end
	end

	if v4 == nil then
		if now2 - v2 > 0.1 then
			part = nil
		end
	else
		part = v4.Part
		v2 = now2
	end

	return v4
end

local function trackInput(input)
	local profileNameForInput = getProfileNameForInput(input)

	if profileNameForInput ~= nil then
		defaultProfile = profileNameForInput
	end

	if isGamepadInput(input.UserInputType) and input.KeyCode == Enum.KeyCode.Thumbstick2 then
		zero = Vector2.new(input.Position.X, input.Position.Y)
	elseif input.UserInputType == Enum.UserInputType.Touch then
		now = os.clock()
		v = math.max(v, Vector2.new(input.Delta.X, input.Delta.Y).Magnitude)
	end
end

if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
	defaultProfile = "Mobile"
elseif UserInputService.GamepadEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
	defaultProfile = "Console"
else
	defaultProfile = AimAssistSettings.DefaultProfile
end

table.insert(connections, UserInputService.InputBegan:Connect(trackInput))
table.insert(connections, UserInputService.InputChanged:Connect(trackInput))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
	trackInput(input)

	if isGamepadInput(input.UserInputType) and input.KeyCode == Enum.KeyCode.Thumbstick2 then
		zero = Vector2.zero
	end
end))
return {
	getTargetInfo = function(value: number?)
		local currentCamera = workspace.CurrentCamera

		if character then
			local IsTransformed = require(ReplicatedStorage.Util.IsTransformed)

			if not IsTransformed(character, true) then
				local profileName = defaultProfile or getInitialProfileName()

				if AimAssistSettings.Profiles[profileName] == nil then
					profileName = AimAssistSettings.Profiles[AimAssistSettings.DefaultProfile] == nil and "PC" or AimAssistSettings.DefaultProfile
				end

				local profile = AimAssistSettings.Profiles[profileName]

				if profile == nil then
					profile = AimAssistSettings.Profiles[AimAssistSettings.DefaultProfile]
				end

				if not profile then
					return
				end

				local equippedTool = getEquippedTool() -- equivalent call inferred; original call site unknown

				if equippedTool == nil then
					return
				end

				local magnitude = 0

				if profileName == "Console" then
					magnitude = zero.Magnitude * 10
				elseif profileName == "Mobile" then
					if os.clock() - now <= 0.1 then
						magnitude = v
					end
				else
					magnitude = UserInputService:GetMouseDelta().Magnitude
				end

				v = 0
				local characterSpeed = getCharacterSpeed() -- equivalent call inferred; original call site unknown
				local v4 = {
					Player = localPlayer,
					Character = character,
					Camera = currentCamera,
					ProfileName = profileName,
					Profile = profile,
					EquippedTool = equippedTool,
					DeltaTime = 1,
					CameraInputAmount = magnitude,
					CharacterSpeed = characterSpeed,
					RadiusBoost = value or 0
				}
				return (chooseTarget(workspace.CurrentCamera, profile, v4))
			end
		end

		part = nil
		v2 = 0
		return nil
	end
}