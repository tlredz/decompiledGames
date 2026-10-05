local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local parts = {}
workspace:WaitForChild("Spawn")
local flag = false
local flag2 = true
local v = { Enum.KeyCode.Space, Enum.KeyCode.ButtonA }
local connections = {}
local v2 = {}
local v3 = {}
local _ = {
	createVector(1, 0, 0),
	createVector(-1, 0, 0),
	createVector(0, 1, 0),
	createVector(0, -1, 0),
	createVector(0, 0, 1),
	createVector(0, 0, -1)
}
local flag3 = false
local flag4 = false
local flag5 = false
local flag6 = false
local character = Players.LocalPlayer.Character
local humanoid = character:WaitForChild("Humanoid")
character:WaitForChild("HumanoidRootPart")
local v4 = character.PrimaryPart.AssemblyMass * workspace.Gravity

local function IsInsideBrick(instance, vector2: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)
	local halfSize = instance.Size / 2
	return math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y and math.abs(pointToObjectSpace.Z) <= halfSize.Z
end

local function SetAntiGravityState(flag7: boolean)
	if flag7 then
		if #v2 > 0 or #v3 > 0 then
			return
		end

		local primaryPart = character.PrimaryPart
		local assemblyMass = primaryPart.AssemblyMass
		local attachment = Instance.new("Attachment")
		attachment.WorldPosition = primaryPart.Position
		attachment.Parent = primaryPart
		table.insert(v2, attachment)
		local vectorForce = Instance.new("VectorForce")
		vectorForce.Name = "SwimmingForce"
		vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
		vectorForce.Force = createVector(0, 1, 0) * (workspace.Gravity * assemblyMass)
		vectorForce.Attachment0 = attachment
		vectorForce.ApplyAtCenterOfMass = true
		vectorForce.Parent = primaryPart
		table.insert(v3, vectorForce)
		table.insert(connections, RunService.Heartbeat:Connect(function()
			if humanoid.MoveDirection.Magnitude > 0 then
				return
			end

			local primaryPart2 = character.PrimaryPart

			if primaryPart2 then
				primaryPart2.AssemblyLinearVelocity = createVector(0, 0, 0)
			end
		end))
		return attachment, vectorForce
	else
		if #v2 == 0 or #v3 == 0 then
			return
		end

		for _, v5 in ipairs(v2) do
			v5:Destroy()
		end

		for _, v5 in ipairs(v3) do
			v5:Destroy()
		end

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		table.clear(v2)
		table.clear(v3)
	end
end

local function ApplyDelayedGravity()
	task.delay(0.05, function()
		local primaryPart = character.PrimaryPart

		if primaryPart then
			primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		end
	end)

	if not (#v2 > 0) then
		if #v3 > 0 then
			return
		end

		local primaryPart = character.PrimaryPart
		local assemblyMass = primaryPart.AssemblyMass
		local attachment = Instance.new("Attachment")
		attachment.WorldPosition = primaryPart.Position
		attachment.Parent = primaryPart
		table.insert(v2, attachment)
		local vectorForce = Instance.new("VectorForce")
		vectorForce.Name = "SwimmingForce"
		vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
		vectorForce.Force = createVector(0, 1, 0) * (workspace.Gravity * assemblyMass)
		vectorForce.Attachment0 = attachment
		vectorForce.ApplyAtCenterOfMass = true
		vectorForce.Parent = primaryPart
		table.insert(v3, vectorForce)
		table.insert(connections, RunService.Heartbeat:Connect(function()
			if humanoid.MoveDirection.Magnitude > 0 then
				return
			end

			local primaryPart2 = character.PrimaryPart

			if primaryPart2 then
				primaryPart2.AssemblyLinearVelocity = createVector(0, 0, 0)
			end
		end))
	end
end

local function _SetCharacterSwimState(flag7: boolean, p)
	local flag8 = not flag7
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, flag8)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, flag8)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, flag8)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, flag8)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, flag8)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, flag8)
	humanoid:ChangeState(p)
end

local function SetCharacterSwimState(flag7: boolean, p)
	if flag7 == flag then
		return
	end

	flag = flag7
	_SetCharacterSwimState(flag7, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _LeaveSwimState()
	local jumping = Enum.HumanoidStateType.Jumping

	if flag ~= false then
		flag = false
		_SetCharacterSwimState(false, jumping)
	end

	SetAntiGravityState(false)
end

local function LeaveSwimState()
	if UserInputService.TouchEnabled then
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
		flag2 = false
		task.delay(0.25, function()
			flag2 = true
		end)
	else
		_LeaveSwimState() -- equivalent call inferred; original call site unknown
	end
end

local function GetPressedKeys()
	local keyCodes = {}

	for _, v5 in ipairs(UserInputService:GetKeysPressed()) do
		table.insert(keyCodes, v5.KeyCode)
	end

	return keyCodes
end

local function IsJumpKeyPressed()
	local pressedKeys = GetPressedKeys()

	for _, v6 in ipairs(v) do
		if table.find(pressedKeys, v6) then
			return true
		end
	end

	return false
end

UserInputService.TouchTapInWorld:Connect(function()
	if flag and not flag6 and flag5 then
		LeaveSwimState()
	end
end)

local function SwimHeartbeat(_: number)
	if not (#parts ~= 0 and flag2) then
		return
	end

	if workspace:GetAttribute("PlayingFinisher") then
		flag2 = false
		local freefall = Enum.HumanoidStateType.Freefall

		if flag ~= false then
			flag = false
			_SetCharacterSwimState(false, freefall)
		end

		SetAntiGravityState(false)
	else
		flag2 = true
		local primaryPart = character.PrimaryPart

		if not primaryPart then
			return
		end

		local head = character:FindFirstChild("Head")

		if not head then
			return
		end

		local cFrame = primaryPart.CFrame
		local v5 = primaryPart.CFrame - createVector(0, 1, 0) * (primaryPart.Size.Y / 2)
		local v6 = head.CFrame + createVector(0, 1, 0) * (head.Size.Y / 2)

		for _, v7 in ipairs(parts) do
			local position = cFrame.Position
			local pointToObjectSpace = v7.CFrame:PointToObjectSpace(position)
			local halfSize = v7.Size / 2
			flag4 = math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y and math.abs(pointToObjectSpace.Z) <= halfSize.Z
			local position2 = v5.Position
			local pointToObjectSpace2 = v7.CFrame:PointToObjectSpace(position2)
			local halfSize2 = v7.Size / 2
			flag5 = math.abs(pointToObjectSpace2.X) <= halfSize2.X and math.abs(pointToObjectSpace2.Y) <= halfSize2.Y and math.abs(pointToObjectSpace2.Z) <= halfSize2.Z
			local position3 = v6.Position
			local pointToObjectSpace3 = v7.CFrame:PointToObjectSpace(position3)
			local halfSize3 = v7.Size / 2
			flag6 = math.abs(pointToObjectSpace3.X) <= halfSize3.X and math.abs(pointToObjectSpace3.Y) <= halfSize3.Y and math.abs(pointToObjectSpace3.Z) <= halfSize3.Z

			if flag4 and flag5 then
				break
			end
		end

		if IsJumpKeyPressed() then
			LeaveSwimState()
		end

		if flag4 and flag5 then
			local swimming = Enum.HumanoidStateType.Swimming

			if flag ~= true then
				flag = true
				_SetCharacterSwimState(true, swimming)
			end

			if not (#v2 > 0 or #v3 > 0) then
				local primaryPart2 = character.PrimaryPart
				local assemblyMass = primaryPart2.AssemblyMass
				local attachment = Instance.new("Attachment")
				attachment.WorldPosition = primaryPart2.Position
				attachment.Parent = primaryPart2
				table.insert(v2, attachment)
				local vectorForce = Instance.new("VectorForce")
				vectorForce.Name = "SwimmingForce"
				vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
				vectorForce.Force = createVector(0, 1, 0) * (workspace.Gravity * assemblyMass)
				vectorForce.Attachment0 = attachment
				vectorForce.ApplyAtCenterOfMass = true
				vectorForce.Parent = primaryPart2
				table.insert(v3, vectorForce)
				table.insert(connections, RunService.Heartbeat:Connect(function()
					if humanoid.MoveDirection.Magnitude > 0 then
						return
					end

					local primaryPart3 = character.PrimaryPart

					if primaryPart3 then
						primaryPart3.AssemblyLinearVelocity = createVector(0, 0, 0)
					end
				end))
			end

			if flag3 then
				task.delay(0.05, function()
					local primaryPart2 = character.PrimaryPart

					if primaryPart2 then
						primaryPart2.AssemblyLinearVelocity = createVector(0, 0, 0)
					end
				end)

				if not (#v2 > 0 or #v3 > 0) then
					local primaryPart2 = character.PrimaryPart
					local assemblyMass = primaryPart2.AssemblyMass
					local attachment = Instance.new("Attachment")
					attachment.WorldPosition = primaryPart2.Position
					attachment.Parent = primaryPart2
					table.insert(v2, attachment)
					local vectorForce = Instance.new("VectorForce")
					vectorForce.Name = "SwimmingForce"
					vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
					vectorForce.Force = createVector(0, 1, 0) * (workspace.Gravity * assemblyMass)
					vectorForce.Attachment0 = attachment
					vectorForce.ApplyAtCenterOfMass = true
					vectorForce.Parent = primaryPart2
					table.insert(v3, vectorForce)
					table.insert(connections, RunService.Heartbeat:Connect(function()
						if humanoid.MoveDirection.Magnitude > 0 then
							return
						end

						local primaryPart3 = character.PrimaryPart

						if primaryPart3 then
							primaryPart3.AssemblyLinearVelocity = createVector(0, 0, 0)
						end
					end))
				end

				flag3 = false
			end
		elseif flag4 or flag5 then
			if not flag4 and flag5 then
				SetAntiGravityState(false)
				flag3 = true
			end
		else
			local freefall = Enum.HumanoidStateType.Freefall

			if flag ~= false then
				flag = false
				_SetCharacterSwimState(false, freefall)
			end

			SetAntiGravityState(false)
		end

		local swimmingForce = primaryPart:FindFirstChild("SwimmingForce")

		if swimmingForce then
			if primaryPart:FindFirstChild("SingularityGravity") then
				swimmingForce.Force = createVector(0, 0, 0)
			elseif IsJumpKeyPressed() then
				swimmingForce.Force = createVector(0, 1, 0) * (v4 * 4.2)
			elseif humanoid.MoveDirection.Magnitude == 0 then
				if flag6 then
					swimmingForce.Force = createVector(0, 1, 0) * (v4 * 4)
				end
			else
				swimmingForce.Force = createVector(0, 1, 0) * v4
			end
		end
	end
end

RunService.Heartbeat:Connect(SwimHeartbeat)

local function destroySwimPart(p)
	local index = table.find(parts, p)

	if index then
		table.remove(parts, index)
	end

	if character.PrimaryPart then
		local freefall = Enum.HumanoidStateType.Freefall

		if flag ~= false then
			flag = false
			_SetCharacterSwimState(false, freefall)
		end

		SetAntiGravityState(false)
	end
end

CollectionService:GetInstanceRemovedSignal("CUSTOM_WATER_PART"):Connect(destroySwimPart)

-- equivalent calls inferred from this helper; original call sites unknown
local function createSwimPart(part)
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end

CollectionService:GetInstanceAddedSignal("CUSTOM_WATER_PART"):Connect(createSwimPart)

for _, v5 in ipairs(CollectionService:GetTagged("CUSTOM_WATER_PART")) do
	createSwimPart(v5) -- equivalent call inferred; original call site unknown
end