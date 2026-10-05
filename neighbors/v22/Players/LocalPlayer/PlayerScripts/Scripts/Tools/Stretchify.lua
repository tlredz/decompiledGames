local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stretchify = require(ReplicatedStorage.Modules.Stretchify)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local map = Stretchify:GetMap()
local v = {}
local v2 = {}
local v3 = {}
local connections = {}
local class = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function syncLimb(p, limbFromAttributeName)
	if Stretchify:GetTargetPosition(p, limbFromAttributeName) then
		class:Enable(p, limbFromAttributeName, Stretchify:IsLimbPlacing(p, limbFromAttributeName))
	else
		class:Disable(p, limbFromAttributeName)
	end
end

function class:Disable(instance, p: string?)
	for _, v4 in p and { p } or Stretchify:GetLimbGroups() do
		local v5 = v2[instance]
		local v6 = v5 and v5[v4]

		if not v6 then
			continue
		end

		v6.HeartbeatConnection:Disconnect()
		local v7 = map[v4]
		local child = instance:FindFirstChild(v7.Upper)
		local child2 = instance:FindFirstChild(v7.Lower)
		local child3 = instance:FindFirstChild(v7.End)

		if not (child and child2 and child3) then
			continue
		end

		child.Size = v6.UpperSize
		child2.Size = v6.LowerSize

		for _, v8 in { child, child2, child3 } do
			v8.CanCollide = false
			v8.CanQuery = true

			for _, child4 in v8:GetChildren() do
				if child4:IsA("BallSocketConstraint") or child4:IsA("AnimationConstraint") then
					child4.Enabled = true
				end
			end

			v8.Anchored = false
		end

		v5[v4] = nil

		if not next(v5) then
			v2[instance] = nil
		end
	end
end

function class:Enable(instance, p, flag: boolean)
	local v4 = map[p]

	if not v4 then
		return
	end

	local v5 = v2[instance]

	if v5 and v5[p] then
		for _, childName in { v4.Upper, v4.Lower, v4.End } do
			local child = instance:FindFirstChild(childName)

			if child then
				child.CanQuery = not flag
			end
		end
	else
		if not Stretchify:GetTargetPosition(instance, p) then
			return
		end

		local child = instance:FindFirstChild(v4.Upper)
		local child2 = instance:FindFirstChild(v4.Lower)
		local child3 = instance:FindFirstChild(v4.End)
		local child4 = instance:FindFirstChild(v4.Torso)
		local child5 = child4 and child4:FindFirstChild(v4.TorsoJoint)

		if not (child and child2 and child3 and child5) then
			return
		end

		for _, v6 in { child, child2, child3 } do
			v6.CanCollide = false
			v6.CanQuery = not flag

			for _, child6 in v6:GetChildren() do
				if child6:IsA("BallSocketConstraint") or child6:IsA("AnimationConstraint") then
					child6.Enabled = false
				end
			end

			v6.Anchored = true
		end

		local v6 = {
			UpperSize = child.Size,
			LowerSize = child2.Size,
			HeartbeatConnection = nil
		}
		v6.HeartbeatConnection = RunService.RenderStepped:Connect(function()
			if not instance.Parent then
				class:Disable(instance, p)
				return
			end

			local targetPosition = Stretchify:GetTargetPosition(instance, p)

			if not targetPosition then
				return
			end

			local clampStretchPosition = Stretchify:ClampStretchPosition(instance, p, targetPosition)
			local worldPosition = child5.WorldPosition
			local v7 = clampStretchPosition - worldPosition
			local v8 = not (v7.Magnitude > 0.001) and createVector(0, 1, 0) or v7.Unit or createVector(0, 1, 0)
			local v9 = math.clamp(v7.Magnitude, 0.1, Stretchify:GetMaxStretchRange()) / 2
			local v10 = CFrame.lookAt(createVector(0, 0, 0), v8) * CFrame.Angles(1.5707963267948966, 0, 0)
			local v11 = worldPosition + v8 * (v9 / 2)
			local v12 = worldPosition + v8 * (v9 + v9 / 2)
			child.Size = Vector3.new(v6.UpperSize.X, v9, v6.UpperSize.Z)
			child2.Size = Vector3.new(v6.LowerSize.X, v9, v6.LowerSize.Z)
			child.CFrame = CFrame.new(v11) * v10.Rotation
			child2.CFrame = CFrame.new(v12) * v10.Rotation * CFrame.Angles(0, 3.141592653589793, 0)
			child3.CFrame = CFrame.new(clampStretchPosition) * v10.Rotation
		end)
		v2[instance] = v2[instance] or {}
		v2[instance][p] = v6
	end
end

local function bindCharacter(character)
	local connection = v[character]

	if connection then
		connection:Disconnect()
	end

	class:Disable(character)

	local function onAttributeChanged(p: string)
		local limbFromAttributeName = Stretchify:GetLimbFromAttributeName(p) or Stretchify:GetLimbFromPlacingAttributeName(p)

		if not limbFromAttributeName then
			return
		end

		syncLimb(character, limbFromAttributeName) -- equivalent call inferred; original call site unknown
	end

	v[character] = character.AttributeChanged:Connect(onAttributeChanged)

	for k in character:GetAttributes() do
		local limbFromAttributeName = Stretchify:GetLimbFromAttributeName(k) or Stretchify:GetLimbFromPlacingAttributeName(k)

		if not limbFromAttributeName then
			continue
		end

		syncLimb(character, limbFromAttributeName) -- equivalent call inferred; original call site unknown
	end

	character.Destroying:Once(function()
		local connection2 = v[character]

		if connection2 then
			connection2:Disconnect()
			v[character] = nil
		end

		class:Disable(character)
	end)
end

local function bindPlayer(player)
	local v4 = v3[player]

	if v4 then
		for _, connection in v4 do
			connection:Disconnect()
		end
	end

	v3[player] = {}

	if player.Character then
		bindCharacter(player.Character)
	end

	table.insert(v3[player], player.CharacterAdded:Connect(bindCharacter))
end

local function onHouseChanged(_, currentHouse)
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)

	if not currentHouse then
		return
	end

	table.insert(connections, currentHouse.PlayerAdded:Connect(bindPlayer))
	table.insert(connections, currentHouse.PlayerRemoving:Connect(function(player)
		local v4 = v3[player]

		if v4 then
			for _, connection in v4 do
				connection:Disconnect()
			end

			v3[player] = nil
		end

		if player.Character then
			local connection = v[player.Character]

			if connection then
				connection:Disconnect()
				v[player.Character] = nil
			end

			class:Disable(player.Character)
		end
	end))
	task.defer(function()
		for _, v4 in currentHouse:GetPlayers() do
			bindPlayer(v4)
		end
	end)
end

Stretchify:OnPreviewChanged(syncLimb)
onHouseChanged(nil, House:GetCurrentHouse())
House.ActiveHouseChanged:Connect(onHouseChanged)