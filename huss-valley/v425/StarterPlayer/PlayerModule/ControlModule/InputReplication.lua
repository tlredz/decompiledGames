local createVector = vector.create
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsFireThroughScriptableBindings")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsUseReplicatedCameraAPI")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsStopFireCameraAction")
local userFlag4 = flagUtil.getUserFlag("UserPlayerScriptsSAuthDirectAPIs2")
local userFlag5 = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
local StarterPlayer = game:GetService("StarterPlayer")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local Workspace = game:GetService("Workspace")
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local userFlag6 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceB")
local v = userFlag6 and "ControlState" or "PlayerControlState"
local InputReplication = {}
InputReplication.__index = InputReplication

function InputReplication._calculatePlayerInputValues(player)
	local character = player.Character

	if character == nil then
		return createVector(0, 0, 0), createVector(0, 0, 1), false
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return createVector(0, 0, 0), createVector(0, 0, 1), false
	end

	local inputContexts = player:FindFirstChild("InputContexts")

	if inputContexts == nil then
		return createVector(0, 0, 0), createVector(0, 0, 1), false
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if characterContext == nil then
		return createVector(0, 0, 0), createVector(0, 0, 1), false
	end

	local cameraContext = inputContexts:FindFirstChild("CameraContext")
	local moveAction = characterContext.MoveAction
	local cameraAction = cameraContext and cameraContext.CameraAction
	local rotationAction = characterContext:FindFirstChild("RotationAction")
	local state

	if rotationAction == nil then
		state = false
	else
		state = rotationAction:GetState()
	end

	local function isValidInput2D(point: Vector2)
		return point.X == point.X and point.Y == point.Y and point.X ~= 1e999 and point.Y ~= 1e999
	end

	local function isValidInput3D(vector2: Vector3)
		return vector2.X == vector2.X and vector2.Y == vector2.Y and vector2.Z == vector2.Z and vector2.X ~= 1e999 and vector2.Y ~= 1e999 and vector2.Z ~= 1e999
	end

	local vector2

	if moveAction == nil then
		vector2 = Vector2.new(0, 0)
	else
		vector2 = moveAction:GetState()
	end

	local lookVector = nil
	local lookVector2

	if userFlag4 then
		lookVector2 = player:GetCameraState().CFrame.LookVector
	elseif userFlag2 then
		local success, result = pcall(function()
			return player:GetCameraState()
		end)

		if success and result then
			local cFrame = result.CFrame

			if cFrame ~= CFrame.identity and result.FieldOfView > 0 and result.ViewportSize.Magnitude > 0 then
				lookVector = cFrame.LookVector
			end
		end

		lookVector2 = lookVector or cameraAction == nil and createVector(0, 0, 0) or cameraAction:GetState()
	else
		lookVector2 = cameraAction == nil and createVector(0, 0, 0) or cameraAction:GetState()
	end

	if vector2.X ~= vector2.X or vector2.Y ~= vector2.Y or vector2.X == 1e999 or vector2.Y == 1e999 or lookVector2.X ~= lookVector2.X or lookVector2.Y ~= lookVector2.Y or lookVector2.Z ~= lookVector2.Z or lookVector2.X == 1e999 or lookVector2.Y == 1e999 or lookVector2.Z == 1e999 or not (lookVector2.Magnitude > 0) then
		return createVector(0, 0, 0), createVector(0, 0, 1), false
	end

	if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
		lookVector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z).Unit
	end

	local unit = lookVector2:Cross(createVector(0, 1, 0)).Unit
	return lookVector2 * vector2.Y + unit * vector2.X, lookVector2, state
end

function InputReplication.CloneInputsIfAbsent(parent)
	if parent:FindFirstChild("InputContexts") then
		return
	end

	local clone = StarterPlayer.PlayerModule.InputContexts:Clone()
	clone.CharacterContext.Enabled = true
	clone.CameraContext.Enabled = true
	clone.Parent = parent
end

function InputReplication.FireCustomInputs(instance)
	local inputContexts = instance:FindFirstChild("InputContexts")

	if not inputContexts then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if not characterContext then
		return
	end

	local cameraContext = inputContexts:FindFirstChild("CameraContext")

	if not cameraContext then
		return
	end

	if userFlag4 then
		local rotationAction = characterContext:FindFirstChild("RotationAction")
		local rotationScriptableBinding = rotationAction and rotationAction:FindFirstChild("RotationScriptableBinding")

		if rotationScriptableBinding then
			rotationScriptableBinding:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
		end
	else
		local v2 = true

		if userFlag3 then
			local success, result = pcall(function()
				return instance:GetCameraState()
			end)

			if success and result and result.CFrame ~= CFrame.identity and result.FieldOfView > 0 and result.ViewportSize.Magnitude > 0 then
				v2 = false
			end
		end

		local cameraAction = v2 and cameraContext:FindFirstChild("CameraAction")

		if cameraAction then
			local currentCamera = Workspace.CurrentCamera

			if userFlag then
				local cameraScriptableBinding = cameraAction:FindFirstChild("CameraScriptableBinding")

				if cameraScriptableBinding then
					local success, _ = pcall(function()
						cameraScriptableBinding.Type = Enum.InputBindingType.Scriptable
						cameraScriptableBinding:Fire(currentCamera.CFrame.LookVector)
					end)

					if not success then
						cameraAction:Fire(currentCamera.CFrame.LookVector)
					end
				else
					cameraAction:Fire(currentCamera.CFrame.LookVector)
				end
			else
				cameraAction:Fire(currentCamera.CFrame.LookVector)
			end
		end

		local rotationAction = characterContext:FindFirstChild("RotationAction")

		if rotationAction then
			if userFlag then
				local rotationScriptableBinding = rotationAction:FindFirstChild("RotationScriptableBinding")

				if not rotationScriptableBinding then
					rotationAction:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
					return
				end

				local success, _ = pcall(function()
					rotationScriptableBinding.Type = Enum.InputBindingType.Scriptable
					rotationScriptableBinding:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
				end)

				if not success then
					rotationAction:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
				end
			else
				rotationAction:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
			end
		end
	end
end

function InputReplication.SendInputToCCLCharacter(instance)
	if not instance then
		return
	end

	local v2 = AvatarAbilitiesInterface.get(instance)
	local inputContexts = instance:FindFirstChild("InputContexts")

	if not inputContexts then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if not characterContext then
		return
	end

	for _, v3 in v2:GetAbilities() do
		local child = characterContext:FindFirstChild(v3 .. "Action")

		if child then
			v2:SendInput(v3, child:GetState())
		end
	end

	local _calculatePlayerInputValues, v3, v4 = InputReplication._calculatePlayerInputValues(instance)
	v2:SendInput("Move", _calculatePlayerInputValues)
	v2:SendInput("CameraLookDirection", v3)
	v2:SendInput("CameraRelativeRotation", v4)
end

function InputReplication.SendInputToHumanoidForServerAuth(player)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local inputContexts = player:FindFirstChild("InputContexts")

	if inputContexts == nil then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if characterContext == nil then
		return
	end

	local jumpAction = characterContext.JumpAction
	local _calculatePlayerInputValues, v2, v3 = InputReplication._calculatePlayerInputValues(player)
	humanoid:Move(_calculatePlayerInputValues)
	humanoid.AutoRotate = not v3

	if v3 and humanoid.SeatPart == nil and humanoid.RootPart ~= nil and not (humanoid.Sit or humanoid.RootPart:IsGrounded()) then
		humanoid.RootPart.CFrame = CFrame.new(humanoid.RootPart.CFrame.Position, humanoid.RootPart.CFrame.Position + v2)
	end

	humanoid.Jump = jumpAction ~= nil and jumpAction:GetState()
end

function InputReplication.setupPlayerControlState(object)
	object:AddVector3Field("Move", createVector(0, 0, 0), 1)
	object:AddBoolField("Jump", false)
	object:AddBoolField("RotateToLookDirection", false)
	object:AddUnitVector3Field("LookDirection", createVector(0, 0, 1))
end

function InputReplication.watchForPlayerControlState(player)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchCharacter(character)
		local function onPCSAdded(instance)
			if instance:IsA(v) then
				InputReplication.setupPlayerControlState(instance)
			end
		end

		local firstChildOfClass = character:FindFirstChildOfClass(v)

		if firstChildOfClass then
			InputReplication.setupPlayerControlState(firstChildOfClass)
		end

		character.ChildAdded:Connect(onPCSAdded)
	end

	if player.Character then
		watchCharacter(player.Character) -- equivalent call inferred; original call site unknown
	end

	player.CharacterAdded:Connect(watchCharacter)
end

function InputReplication.createPlayerControlState(owner)
	local function createForCharacter(parent)
		if userFlag6 then
			if parent:FindFirstChildOfClass(v) then
				return
			end
		elseif parent:FindFirstChild(v) then
			return
		end

		local instance = Instance.new(v)
		instance.Owner = owner
		instance.Parent = parent
		InputReplication.setupPlayerControlState(instance)
	end

	if owner.Character then
		local character = owner.Character
		local instance

		if userFlag6 then
			if not character:FindFirstChildOfClass(v) then
				instance = Instance.new(v)
				instance.Owner = owner
				instance.Parent = character
				InputReplication.setupPlayerControlState(instance)
			end
		elseif not character:FindFirstChild(v) then
			instance = Instance.new(v)
			instance.Owner = owner
			instance.Parent = character
			InputReplication.setupPlayerControlState(instance)
		end
	end

	owner.CharacterAdded:Connect(createForCharacter)
end

function InputReplication.writeInputToPCS(player, object, flag: boolean)
	local character = player.Character

	if not character then
		return
	end

	local child

	if userFlag6 then
		child = character:FindFirstChildOfClass(v)
	else
		child = character:FindFirstChild(v)
	end

	if not child then
		return
	end

	local humanoid = object.humanoid

	if not humanoid then
		return
	end

	local inputContexts

	if flag then
		inputContexts = player:FindFirstChild("InputContexts")
	else
		inputContexts = script.Parent.Parent:FindFirstChild("InputContexts")
	end

	local characterContext = inputContexts and inputContexts:FindFirstChild("CharacterContext")

	if not characterContext then
		return
	end

	local moveAction = characterContext:FindFirstChild("MoveAction")
	local jumpAction = characterContext:FindFirstChild("JumpAction")
	local state

	if moveAction then
		state = moveAction:GetState()
	else
		state = Vector2.zero
	end

	local state2

	if jumpAction then
		state2 = jumpAction:GetState()
	else
		state2 = false
	end

	local rawMoveVector = object:calculateRawMoveVector(humanoid, (Vector3.new(state.X, 0, -state.Y)))
	local rotateToLookDirection = UserGameSettings.RotationType == Enum.RotationType.CameraRelative
	local lookVector = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.LookVector or createVector(0, 0, 1)
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local v3 = {
		Move = rawMoveVector,
		RotateToLookDirection = rotateToLookDirection,
		LookDirection = not (vector2.Magnitude > 0.001) and createVector(0, 0, 1) or vector2.Unit
	}

	if not (userFlag5 and AvatarAbilitiesInterface.get(player):isEnabled()) then
		v3.Jump = state2
	end

	child:UpdateFields(v3)
end

function InputReplication.processPCSInputs(player)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local child

	if userFlag6 then
		child = character:FindFirstChildOfClass(v)
	else
		child = character:FindFirstChild(v)
	end

	if child == nil then
		return
	end

	local state = child:GetState()
	local move = state.Move
	local jump = state.Jump
	local rotateToLookDirection = state.RotateToLookDirection
	local lookDirection = state.LookDirection

	if move then
		humanoid:Move(move)
	end

	humanoid.AutoRotate = not rotateToLookDirection

	if rotateToLookDirection and lookDirection ~= nil and humanoid.RootPart ~= nil and not humanoid.Sit and humanoid.SeatPart == nil and not humanoid.RootPart:IsGrounded() then
		humanoid.RootPart.CFrame = CFrame.new(
			humanoid.RootPart.CFrame.Position,
			humanoid.RootPart.CFrame.Position + lookDirection
		)
	end

	humanoid.Jump = jump or false
end

return InputReplication