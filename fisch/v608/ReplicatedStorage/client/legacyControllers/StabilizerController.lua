local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local Observers = require(ReplicatedStorage.packages.Observers)
local localPlayer = Players.LocalPlayer
local terrain = workspace.Terrain
local v = {
	Tidebreaker = true,
	Frostbreaker = true
}
local color = Color3.fromRGB(162, 234, 166)
local color2 = Color3.fromRGB(255, 255, 255)
local v2 = 0
local v3 = 0
local v4 = 0
local v5 = false
local v6 = false
local v7 = false
local flag = false
local v8 = false
local v9 = nil
local v10 = nil
local connections = {}
local v11 = {}
local v12 = nil
local v13 = nil
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true
local StabilizerController = {}

local function getRoot()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function isWaterAt(vector2: Vector3)
	local v14 = vector2 // 4 * 4
	local expandToGrid = Region3.new(v14, v14 + createVector(1, 1, 1)):ExpandToGrid(4)
	local success, result = pcall(terrain.ReadVoxels, terrain, expandToGrid, 4)

	if success then
		return (result[1] and result[1][1] and result[1][1][1]) == Enum.Material.Water
	end

	return false
end

local function isObstructed(humanoidRootPart, p: number)
	if p <= 0 then
		return false
	end

	local filterDescendantsInstances = {}
	local character = localPlayer.Character

	if character then
		table.insert(filterDescendantsInstances, character)
	end

	local zones = workspace:FindFirstChild("zones")

	if zones then
		table.insert(filterDescendantsInstances, zones)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local v15 = humanoidRootPart.Size.Y / 2 + 4
	return workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, v15, 0), raycastParams) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHumanoid()
	local character = localPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function isSeated()
	local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
	return humanoid ~= nil and humanoid.SeatPart ~= nil
end

local function isUsingMobilityTool()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool ~= nil and v[tool.Name] == true
end

local function isSuspended()
	local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
	local v14

	if humanoid == nil then
		v14 = false
	else
		v14 = humanoid.SeatPart ~= nil
	end

	if v14 then
		return v14
	end

	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool ~= nil and v[tool.Name] == true
end

local function isActive()
	local v14 = v5

	if not v14 then
		return v14
	end

	local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
	local v15

	if humanoid == nil then
		v15 = false
	else
		v15 = humanoid.SeatPart ~= nil
	end

	if v15 then
		return not v15 and (v6 or v7)
	end

	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool == nil then
		v15 = false
	else
		v15 = v[tool.Name] == true
	end

	return not v15 and (v6 or v7)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isOnGamepad()
	return UserInputService.GamepadEnabled and UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
end

local function updateConsoleToggle()
	local v14 = v9

	if not v14 then
		return
	end

	local visible = isOnGamepad() and v5

	if visible then
		local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
		local v16

		if humanoid == nil then
			v16 = false
		else
			v16 = humanoid.SeatPart ~= nil
		end

		if not v16 then
			local character = localPlayer.Character
			local tool = character and character:FindFirstChildOfClass("Tool")

			if tool == nil then
				v16 = false
			else
				v16 = v[tool.Name] == true
			end
		end

		visible = not v16 and (v6 or v7)
	end

	v14.Visible = visible
	local condition = v14:FindFirstChild("Condition")

	if condition and condition:IsA("TextLabel") then
		if v8 then
			condition.Text = "Stabilizer: Enabled"
			condition.TextColor3 = color
		else
			condition.Text = "Stabilizer: Disabled"
			condition.TextColor3 = color2
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setConsoleToggled(flag2: boolean)
	if v8 == flag2 then
		return
	end

	v8 = flag2

	if not flag2 then
		v2 = 0
		v3 = 0
	end

	updateConsoleToggle()
end

local function isGamepadInput(p)
	return p.UserInputType.Name:sub(1, 7) == "Gamepad"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSwimEnabled(flag2: boolean)
	local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown

	if not humanoid then
		return
	end

	v13 = flag2

	if humanoid:GetStateEnabled(Enum.HumanoidStateType.Swimming) == flag2 then
		return
	end

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, flag2)

	if not flag2 and humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreSwimState()
	if v13 == nil then
		return
	end

	local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown

	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	end

	v13 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearRealWaterPhysics()
	if v12 then
		v12:Destroy()
		v12 = nil
	end
end

local function ensureRealWaterPhysics(parent)
	if v12 and v12.Parent == parent then
		return v12
	end

	clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
	local rootAttachment = parent:FindFirstChild("RootAttachment")

	if not (rootAttachment and rootAttachment:IsA("Attachment")) then
		return nil
	end

	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "StabilizerLift"
	linearVelocity.Attachment0 = rootAttachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.ForceLimitsEnabled = true
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(0, 0, 0)
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = parent
	v12 = linearVelocity
	return linearVelocity
end

local function updateGamepadContext()
	local v14 = v10

	if not v14 then
		return
	end

	local enabled = v5

	if enabled then
		local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
		local v16

		if humanoid == nil then
			v16 = false
		else
			v16 = humanoid.SeatPart ~= nil
		end

		if not v16 then
			local character = localPlayer.Character
			local tool = character and character:FindFirstChildOfClass("Tool")

			if tool == nil then
				v16 = false
			else
				v16 = v[tool.Name] == true
			end
		end

		enabled = not v16 and (v6 or v7)
	end

	v14.Enabled = enabled
	local stabilizerAscend = v14:FindFirstChild("StabilizerAscend")
	local stabilizerDescend = v14:FindFirstChild("StabilizerDescend")

	if stabilizerAscend and stabilizerAscend:IsA("InputAction") then
		stabilizerAscend.Enabled = enabled and v8
	end

	if stabilizerDescend and stabilizerDescend:IsA("InputAction") then
		stabilizerDescend.Enabled = enabled and v8
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateMobileVisibility()
	local v14 = v5

	if v14 then
		local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
		local v15

		if humanoid == nil then
			v15 = false
		else
			v15 = humanoid.SeatPart ~= nil
		end

		if not v15 then
			local character = localPlayer.Character
			local tool = character and character:FindFirstChildOfClass("Tool")

			if tool == nil then
				v15 = false
			else
				v15 = v[tool.Name] == true
			end
		end

		v14 = not v15 and (v6 or v7)
	end

	local visible = v14 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

	for k in v11 do
		k.Visible = visible
	end

	updateConsoleToggle()
	updateGamepadContext()
end

local function setRealWaterActive(flag2: boolean)
	if v7 == flag2 then
		return
	end

	v7 = flag2
	updateMobileVisibility() -- equivalent call inferred; original call site unknown
end

local function applyRealWater(humanoidRootPart)
	if v7 then
		if not (isWaterAt(humanoidRootPart.Position) and isWaterAt(humanoidRootPart.Position + createVector(0, 5, 0))) and v7 ~= false then
			v7 = false
			local v14 = v5

			if v14 then
				local humanoid = getHumanoid()
				local v15

				if humanoid == nil then
					v15 = false
				else
					v15 = humanoid.SeatPart ~= nil
				end

				if not v15 then
					local character = localPlayer.Character
					local tool = character and character:FindFirstChildOfClass("Tool")

					if tool == nil then
						v15 = false
					else
						v15 = v[tool.Name] == true
					end
				end

				v14 = not v15 and (v6 or v7)
			end

			local visible = v14 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

			for k in v11 do
				k.Visible = visible
			end

			updateConsoleToggle()
			updateGamepadContext()
		end
	elseif isWaterAt(humanoidRootPart.Position) and isWaterAt(humanoidRootPart.Position + createVector(0, 8, 0)) and v7 ~= true then
		v7 = true
		local v14 = v5

		if v14 then
			local humanoid = getHumanoid()
			local v15

			if humanoid == nil then
				v15 = false
			else
				v15 = humanoid.SeatPart ~= nil
			end

			if not v15 then
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildOfClass("Tool")

				if tool == nil then
					v15 = false
				else
					v15 = v[tool.Name] == true
				end
			end

			v14 = not v15 and (v6 or v7)
		end

		local visible = v14 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

		for k in v11 do
			k.Visible = visible
		end

		updateConsoleToggle()
		updateGamepadContext()
	end

	if v7 then
		setSwimEnabled(false) -- equivalent call inferred; original call site unknown
		local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown

		if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air and v4 <= 0 then
			v4 = 0
			clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
		else
			local realWaterPhysics = ensureRealWaterPhysics(humanoidRootPart)

			if not realWaterPhysics then
				return
			end

			local humanoid2 = getHumanoid() -- equivalent call inferred; original call site unknown
			local v14 = (not humanoid2 and createVector(0, 0, 0) or humanoid2.MoveDirection * createVector(1, 0, 1)) * (not humanoid2 and 0 or humanoid2.WalkSpeed)
			local v15 = workspace.Gravity * humanoidRootPart.AssemblyMass * 10
			realWaterPhysics.MaxAxesForce = Vector3.new(v15, v15, v15)
			realWaterPhysics.VectorVelocity = Vector3.new(v14.X, v4 * 50, v14.Z)
		end
	else
		v2 = 0
		v3 = 0
		v4 = 0
		clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
		setSwimEnabled(true) -- equivalent call inferred; original call site unknown
		setConsoleToggled(false) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupConsoleToggle()
	local consoleToggle = script:FindFirstChild("consoleToggle")

	if not (consoleToggle and consoleToggle:IsA("Frame")) then
		return
	end

	local safeZone = HudController:GetSafeZone()
	local clone = consoleToggle:Clone()
	clone.Name = "stabilizerConsoleToggle"
	clone.Visible = false
	clone.Parent = safeZone
	v9 = clone
end

local function handleAscend(_, p, p2)
	if p2.KeyCode.Name == "Unknown" or p2.UserInputType.Name:sub(1, 7) == "Gamepad" then
		return Enum.ContextActionResult.Pass
	end

	local v14 = v5

	if v14 then
		local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
		local v15

		if humanoid == nil then
			v15 = false
		else
			v15 = humanoid.SeatPart ~= nil
		end

		if not v15 then
			local character = localPlayer.Character
			local tool = character and character:FindFirstChildOfClass("Tool")

			if tool == nil then
				v15 = false
			else
				v15 = v[tool.Name] == true
			end
		end

		v14 = not v15 and (v6 or v7)
	end

	if not v14 then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin then
		v2 = 1
		return Enum.ContextActionResult.Sink
	end

	if p ~= Enum.UserInputState.End and p ~= Enum.UserInputState.Cancel then
		return Enum.ContextActionResult.Pass
	end

	v2 = 0
	return Enum.ContextActionResult.Sink
end

local function handleDescend(_, p, p2)
	if p2.KeyCode.Name == "Unknown" or p2.UserInputType.Name:sub(1, 7) == "Gamepad" then
		return Enum.ContextActionResult.Pass
	end

	local v14 = v5

	if v14 then
		local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
		local v15

		if humanoid == nil then
			v15 = false
		else
			v15 = humanoid.SeatPart ~= nil
		end

		if not v15 then
			local character = localPlayer.Character
			local tool = character and character:FindFirstChildOfClass("Tool")

			if tool == nil then
				v15 = false
			else
				v15 = v[tool.Name] == true
			end
		end

		v14 = not v15 and (v6 or v7)
	end

	if not v14 then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin then
		v3 = -1
		return Enum.ContextActionResult.Sink
	end

	if p ~= Enum.UserInputState.End and p ~= Enum.UserInputState.Cancel then
		return Enum.ContextActionResult.Pass
	end

	v3 = 0
	return Enum.ContextActionResult.Sink
end

local function setupGamepadContext()
	local backpack = ReplicatedStorage:FindFirstChild("client") and ReplicatedStorage.client:FindFirstChild("inputs") and ReplicatedStorage.client.inputs:FindFirstChild("Backpack")
	local v14 = not (backpack and backpack:IsA("InputContext")) and 1000 or backpack.Priority
	local inputContext = Instance.new("InputContext")
	inputContext.Name = "Stabilizer"
	inputContext.Priority = v14 + 1
	inputContext.Sink = true
	inputContext.Enabled = false

	local function makeAction(name: string, keyCode)
		local inputAction = Instance.new("InputAction")
		inputAction.Name = name
		inputAction.Type = Enum.InputActionType.Bool
		inputAction.Enabled = false
		inputAction.Parent = inputContext
		local inputBinding = Instance.new("InputBinding")
		inputBinding.KeyCode = keyCode
		inputBinding.Parent = inputAction
		return inputAction
	end

	local buttonR1 = Enum.KeyCode.ButtonR1
	local inputAction = Instance.new("InputAction")
	inputAction.Name = "StabilizerAscend"
	inputAction.Type = Enum.InputActionType.Bool
	inputAction.Enabled = false
	inputAction.Parent = inputContext
	local inputBinding = Instance.new("InputBinding")
	inputBinding.KeyCode = buttonR1
	inputBinding.Parent = inputAction
	local buttonL1 = Enum.KeyCode.ButtonL1
	local inputAction2 = Instance.new("InputAction")
	inputAction2.Name = "StabilizerDescend"
	inputAction2.Type = Enum.InputActionType.Bool
	inputAction2.Enabled = false
	inputAction2.Parent = inputContext
	local inputBinding2 = Instance.new("InputBinding")
	inputBinding2.KeyCode = buttonL1
	inputBinding2.Parent = inputAction2
	local buttonY = Enum.KeyCode.ButtonY
	local inputAction3 = Instance.new("InputAction")
	inputAction3.Name = "StabilizerToggle"
	inputAction3.Type = Enum.InputActionType.Bool
	inputAction3.Enabled = false
	inputAction3.Parent = inputContext
	local inputBinding3 = Instance.new("InputBinding")
	inputBinding3.KeyCode = buttonY
	inputBinding3.Parent = inputAction3
	inputAction3.Enabled = true
	inputAction.Pressed:Connect(function()
		local v15 = v5

		if v15 then
			local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
			local v16

			if humanoid == nil then
				v16 = false
			else
				v16 = humanoid.SeatPart ~= nil
			end

			if not v16 then
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildOfClass("Tool")

				if tool == nil then
					v16 = false
				else
					v16 = v[tool.Name] == true
				end
			end

			v15 = not v16 and (v6 or v7)
		end

		if v15 and v8 then
			v2 = 1
		end
	end)
	inputAction.Released:Connect(function()
		v2 = 0
	end)
	inputAction2.Pressed:Connect(function()
		local v15 = v5

		if v15 then
			local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
			local v16

			if humanoid == nil then
				v16 = false
			else
				v16 = humanoid.SeatPart ~= nil
			end

			if not v16 then
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildOfClass("Tool")

				if tool == nil then
					v16 = false
				else
					v16 = v[tool.Name] == true
				end
			end

			v15 = not v16 and (v6 or v7)
		end

		if v15 and v8 then
			v3 = -1
		end
	end)
	inputAction2.Released:Connect(function()
		v3 = 0
	end)
	inputAction3.Pressed:Connect(function()
		local v15 = v5

		if v15 then
			local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
			local v16

			if humanoid == nil then
				v16 = false
			else
				v16 = humanoid.SeatPart ~= nil
			end

			if not v16 then
				local character = localPlayer.Character
				local tool = character and character:FindFirstChildOfClass("Tool")

				if tool == nil then
					v16 = false
				else
					v16 = v[tool.Name] == true
				end
			end

			v15 = not v16 and (v6 or v7)
		end

		if v15 then
			setConsoleToggled(not v8) -- equivalent call inferred; original call site unknown
			updateGamepadContext()
		end
	end)
	inputContext.Parent = script
	v10 = inputContext
end

local function bindSteerActions()
	pcall(ContextActionService.UnbindAction, ContextActionService, "StabilizerAscend")
	pcall(ContextActionService.UnbindAction, ContextActionService, "StabilizerDescend")
	ContextActionService:BindActionAtPriority(
		"StabilizerAscend",
		handleAscend,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.E
	)
	ContextActionService:BindActionAtPriority(
		"StabilizerDescend",
		handleDescend,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.Q
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindActions()
	if flag then
		return
	end

	flag = true
	bindSteerActions()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindActions()
	if not flag then
		return
	end

	flag = false
	pcall(ContextActionService.UnbindAction, ContextActionService, "StabilizerAscend")
	pcall(ContextActionService.UnbindAction, ContextActionService, "StabilizerDescend")
end

local function setEnabled(flag2: boolean)
	if flag2 == v5 then
		return
	end

	v5 = flag2

	if flag2 then
		bindActions() -- equivalent call inferred; original call site unknown
	else
		unbindActions() -- equivalent call inferred; original call site unknown
		v2 = 0
		v3 = 0
		v4 = 0

		if v7 ~= false then
			v7 = false
			local v14 = v5

			if v14 then
				local humanoid = getHumanoid()
				local v15

				if humanoid == nil then
					v15 = false
				else
					v15 = humanoid.SeatPart ~= nil
				end

				if not v15 then
					local character = localPlayer.Character
					local tool = character and character:FindFirstChildOfClass("Tool")

					if tool == nil then
						v15 = false
					else
						v15 = v[tool.Name] == true
					end
				end

				v14 = not v15 and (v6 or v7)
			end

			local visible = v14 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

			for k in v11 do
				k.Visible = visible
			end

			updateConsoleToggle()
			updateGamepadContext()
		end

		clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
		restoreSwimState() -- equivalent call inferred; original call site unknown
		setConsoleToggled(false) -- equivalent call inferred; original call site unknown
	end

	updateMobileVisibility() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function observeMobileControls()
	Observers.observeTagNoAncestry("StabilizerControls", function(p)
		v11[p] = true
		updateMobileVisibility() -- equivalent call inferred; original call site unknown
		local mouseButton1DownConnection = p.Up.MouseButton1Down:Connect(function()
			if v5 and v3 == 0 then
				v2 = 1
			end
		end)
		local mouseButton1UpConnection = p.Up.MouseButton1Up:Connect(function()
			v2 = 0
		end)
		local mouseButton1DownConnection2 = p.Down.MouseButton1Down:Connect(function()
			if v5 and v2 == 0 then
				v3 = -1
			end
		end)
		local mouseButton1UpConnection2 = p.Down.MouseButton1Up:Connect(function()
			v3 = 0
		end)
		return function()
			v11[p] = nil
			mouseButton1DownConnection:Disconnect()
			mouseButton1UpConnection:Disconnect()
			mouseButton1DownConnection2:Disconnect()
			mouseButton1UpConnection2:Disconnect()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearCharacterConns()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end

local function watchCharacter(instance)
	clearCharacterConns() -- equivalent call inferred; original call site unknown
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if not (humanoid and humanoid:IsA("Humanoid")) then
		return
	end

	v6 = humanoid:GetAttribute("InFakeWater") == true
	table.insert(connections, instance:GetAttributeChangedSignal("BuoyancyStabilizer"):Connect(function()
		setEnabled(instance:GetAttribute("BuoyancyStabilizer") == true)
	end))
	table.insert(connections, humanoid:GetAttributeChangedSignal("InFakeWater"):Connect(function()
		v6 = humanoid:GetAttribute("InFakeWater") == true
		updateMobileVisibility() -- equivalent call inferred; original call site unknown
	end))
	table.insert(connections, humanoid.Seated:Connect(function()
		v2 = 0
		v3 = 0
		updateMobileVisibility() -- equivalent call inferred; original call site unknown
	end))
	table.insert(connections, instance.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and v[tool.Name] then
			v2 = 0
			v3 = 0
			updateMobileVisibility() -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, instance.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") and v[tool.Name] then
			updateMobileVisibility() -- equivalent call inferred; original call site unknown
		end
	end))
	setEnabled(instance:GetAttribute("BuoyancyStabilizer") == true)
	updateMobileVisibility() -- equivalent call inferred; original call site unknown
end

function StabilizerController.IsEnabled()
	local v14 = v5

	if not v14 then
		return v14
	end

	local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
	local v15

	if humanoid == nil then
		v15 = false
	else
		v15 = humanoid.SeatPart ~= nil
	end

	if v15 then
		return not v15
	end

	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool == nil then
		v15 = false
	else
		v15 = v[tool.Name] == true
	end

	return not v15
end

function StabilizerController.GetVerticalVelocity()
	return v4 * 50
end

function StabilizerController.Tick(p: number)
	if not v5 then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if not humanoidRootPart then
		v4 = 0
		return
	end

	local humanoid = getHumanoid() -- equivalent call inferred; original call site unknown
	local v14

	if humanoid == nil then
		v14 = false
	else
		v14 = humanoid.SeatPart ~= nil
	end

	if not v14 then
		local character2 = localPlayer.Character
		local tool = character2 and character2:FindFirstChildOfClass("Tool")

		if tool == nil then
			v14 = false
		else
			v14 = v[tool.Name] == true
		end
	end

	if v14 then
		v2 = 0
		v3 = 0
		v4 = 0

		if v7 ~= false then
			v7 = false
			local v15 = v5

			if v15 then
				local humanoid2 = getHumanoid()
				local v16

				if humanoid2 == nil then
					v16 = false
				else
					v16 = humanoid2.SeatPart ~= nil
				end

				if not v16 then
					local character2 = localPlayer.Character
					local tool = character2 and character2:FindFirstChildOfClass("Tool")

					if tool == nil then
						v16 = false
					else
						v16 = v[tool.Name] == true
					end
				end

				v15 = not v16 and (v6 or v7)
			end

			local visible = v15 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

			for k in v11 do
				k.Visible = visible
			end

			updateConsoleToggle()
			updateGamepadContext()
		end

		clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
		setConsoleToggled(false) -- equivalent call inferred; original call site unknown

		if not v6 then
			local humanoid2 = getHumanoid() -- equivalent call inferred; original call site unknown

			if not humanoid2 then
				return
			end

			v13 = true

			if humanoid2:GetStateEnabled(Enum.HumanoidStateType.Swimming) == true then
				return
			else
				humanoid2:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
			end
		end
	else
		local v15 = v2 + v3

		if v15 == 0 then
			if v4 > 0 then
				v4 = math.clamp(v4 - p * 1, 0, 1)
			else
				v4 = math.clamp(v4 + p * 1, -1, 0)
			end

			if math.abs(v4) < 0.001 then
				v4 = 0
			end
		else
			v4 = math.clamp(v4 + v15 * 0.5 * p, -1, 1)
		end

		if v4 ~= 0 and isObstructed(humanoidRootPart, v4) then
			v4 = 0
		end

		if not v6 then
			applyRealWater(humanoidRootPart)
			return
		end

		if v7 ~= false then
			v7 = false
			local v16 = v5

			if v16 then
				local humanoid2 = getHumanoid()
				local v17

				if humanoid2 == nil then
					v17 = false
				else
					v17 = humanoid2.SeatPart ~= nil
				end

				if not v17 then
					local character2 = localPlayer.Character
					local tool = character2 and character2:FindFirstChildOfClass("Tool")

					if tool == nil then
						v17 = false
					else
						v17 = v[tool.Name] == true
					end
				end

				v16 = not v17 and (v6 or v7)
			end

			local visible = v16 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

			for k in v11 do
				k.Visible = visible
			end

			updateConsoleToggle()
			updateGamepadContext()
		end

		clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
		setSwimEnabled(false) -- equivalent call inferred; original call site unknown
	end
end

function StabilizerController.Start(_)
	observeMobileControls() -- equivalent call inferred; original call site unknown
	setupConsoleToggle() -- equivalent call inferred; original call site unknown
	setupGamepadContext()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateMobileVisibility)
	UserInputService.LastInputTypeChanged:Connect(updateConsoleToggle)
	Observers.observeCharacter(localPlayer, function(_, p)
		watchCharacter(p)
		return function()
			clearCharacterConns() -- equivalent call inferred; original call site unknown
			clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
			v13 = nil
			v6 = false

			if v7 ~= false then
				v7 = false
				local v14 = v5

				if v14 then
					local humanoid = getHumanoid()
					local v15

					if humanoid == nil then
						v15 = false
					else
						v15 = humanoid.SeatPart ~= nil
					end

					if not v15 then
						local character = localPlayer.Character
						local tool = character and character:FindFirstChildOfClass("Tool")

						if tool == nil then
							v15 = false
						else
							v15 = v[tool.Name] == true
						end
					end

					v14 = not v15 and (v6 or v7)
				end

				local visible = v14 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

				for k in v11 do
					k.Visible = visible
				end

				updateConsoleToggle()
				updateGamepadContext()
			end

			if v5 == false then
				return
			end

			v5 = false
			unbindActions() -- equivalent call inferred; original call site unknown
			v2 = 0
			v3 = 0
			v4 = 0

			if v7 ~= false then
				v7 = false
				local visible = v5 and not (isSeated() or isUsingMobilityTool()) and (v6 or v7) and UserInputService.PreferredInput == Enum.PreferredInput.Touch

				for k in v11 do
					k.Visible = visible
				end

				updateConsoleToggle()
				updateGamepadContext()
			end

			clearRealWaterPhysics() -- equivalent call inferred; original call site unknown
			restoreSwimState() -- equivalent call inferred; original call site unknown
			setConsoleToggled(false) -- equivalent call inferred; original call site unknown
			local v14 = v5

			if v14 then
				local humanoid = getHumanoid()
				local v15

				if humanoid == nil then
					v15 = false
				else
					v15 = humanoid.SeatPart ~= nil
				end

				if not v15 then
					local character = localPlayer.Character
					local tool = character and character:FindFirstChildOfClass("Tool")

					if tool == nil then
						v15 = false
					else
						v15 = v[tool.Name] == true
					end
				end

				v14 = not v15 and (v6 or v7)
			end

			local visible2 = v14 and UserInputService.PreferredInput == Enum.PreferredInput.Touch

			for k in v11 do
				k.Visible = visible2
			end

			updateConsoleToggle()
			updateGamepadContext()
		end
	end)
	RunService.PreSimulation:Connect(StabilizerController.Tick)
end

return StabilizerController