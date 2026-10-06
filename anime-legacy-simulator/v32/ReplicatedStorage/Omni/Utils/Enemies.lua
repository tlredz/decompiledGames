local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local Instance = require(ReplicatedStorage.Omni.Utils.Instance)
local Characters = require(ReplicatedStorage.Omni.Utils.Characters)
local Enemies = require(ReplicatedStorage.Omni.Shared.Enemies)
local fighters = workspace.Server.Fighters
local v = {}
local v2 = {}
local v3 = {}
local callbacks = {}
local v4 = {}

local function WaitForObject(instance, childName: string, p: number)
	local child = instance:FindFirstChild(childName)

	if child ~= nil then
		return child
	end

	local lastTime = tick()

	while not (p <= tick() - lastTime) do
		local child2 = instance:FindFirstChild(childName)

		if child2 ~= nil then
			return child2
		end

		task.wait()
	end

	return nil
end

local function WaitForAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if attribute ~= nil then
		return attribute
	end

	local lastTime = tick()

	while not (p <= tick() - lastTime) do
		local attribute2 = instance:GetAttribute(attributeName)

		if attribute2 ~= nil then
			return attribute2
		end

		task.wait()
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TargetChanged(p: string, p2: string)
	if not p or p == "" then
		return
	end

	local v5 = v3[p] ~= nil

	for _, v6 in callbacks do
		v6(p, v5, p2)
	end
end

local function CheckTarget(name: string, value: string, last: string?)
	if last and last ~= "" then
		local v5 = v3[last]

		if v5 then
			v5[name] = nil

			if not next(v5) then
				v3[last] = nil
			end

			TargetChanged(last, name) -- equivalent call inferred; original call site unknown
		end
	end

	if value == "" then
		return ""
	end

	if not v3[value] then
		v3[value] = {}
	end

	v3[value][name] = true

	if not value then
		return value
	end

	if value == "" then
		return ""
	end

	local v5 = v3[value] ~= nil

	for _, v6 in callbacks do
		v6(value, v5, name)
	end

	return value
end

local function SetupFighterTarget(folder)
	if not folder:IsA("Folder") then
		return
	end

	local waitForObject = WaitForObject(folder, "Target", 5)

	if not waitForObject then
		return
	end

	local v6 = {}
	local name = folder.Name
	local last = waitForObject.Value

	if last ~= "" then
		if not v3[last] then
			v3[last] = {}
		end

		v3[last][name] = true
		TargetChanged(last, name) -- equivalent call inferred; original call site unknown
	end

	v6.Last = last
	v6.ChangedConnection = waitForObject.Changed:Connect(function()
		v6.Last = CheckTarget(folder.Name, waitForObject.Value, v6.Last)
	end)
	v6.DestroyConnection = folder.AncestryChanged:Connect(function()
		v6.ChangedConnection:Disconnect()
		v6.DestroyConnection:Disconnect()
		local v7 = waitForObject.Value ~= "" and v3[waitForObject.Value]

		if v7 then
			v7[folder.Name] = nil

			if not next(v7) then
				v3[waitForObject.Value] = nil
			end

			TargetChanged(waitForObject.Value, folder.Name) -- equivalent call inferred; original call site unknown
		end

		v[folder.Name] = nil
	end)
	v[folder.Name] = v6
end

local function GetEnemyCFrame(data)
	local value = data.PositionValue.Value
	local value2 = data.EndValue.Value

	if value == value2 then
		return value2
	end

	local instance = data.Instance
	return v4.GetMovementCFrame(
		value,
		value2,
		instance:GetAttribute("MovementStart"),
		instance:GetAttribute("MovementSpeed")
	)
end

function v4.GetStaticTemplate(childName: string)
	local staticModel = Enemies.StaticModels[childName]

	if not staticModel then
		return
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local enemies = assets and assets:FindFirstChild("Enemies")
	local child = enemies and enemies:FindFirstChild(staticModel.Category)
	local model = child and child:FindFirstChild(childName)

	if model and model:IsA("Model") then
		return model
	end
end

function v4.GetModel(name: string)
	if not Enemies.StaticModels[name] then
		return Characters.Get({
			Name = name,
			RemoveHumanoidStates = true
		})
	end

	local staticTemplate = v4.GetStaticTemplate(name)

	if not staticTemplate then
		return
	end

	local humanoidRootPart = staticTemplate:FindFirstChild("HumanoidRootPart")
	local head = staticTemplate:FindFirstChild("Head")
	local hitboxSize = staticTemplate:GetAttribute("HitboxSize")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and (head and head:IsA("BasePart"))) then
		return
	end

	if typeof(hitboxSize) ~= "Vector3" then
		return
	end

	local clone = staticTemplate:Clone()
	return clone, nil, clone.HumanoidRootPart, clone.Head, nil, hitboxSize.Y / 2
end

function v4.GetInfoByDifficulty(items, p: string)
	local v5 = nil
	local v6 = nil

	for k, item in items do
		if item.Difficulty ~= p then
			continue
		end

		v6 = k
		v5 = item
		break
	end

	return v5, v6
end

function v4.IsTargetted(p: string)
	return v3[p] ~= nil
end

function v4.GetFightersOnTarget(p: string)
	return v3[p] or {}
end

function v4.OnEnemyTargetChange(callback)
	if typeof(callback) ~= "function" then
		return
	end

	table.insert(callbacks, callback)
end

function v4.GetMovementCFrame(cframe: CFrame, cframe2: CFrame, value: number?, value2: number?)
	local v5 = cframe2.Position - cframe.Position
	local magnitude = v5.Magnitude

	if magnitude <= 0 then
		return cframe2
	end

	if typeof(value) ~= "number" or typeof(value2) ~= "number" or value2 <= 0 then
		return cframe
	end

	local v6 = (workspace:GetServerTimeNow() - value) * value2

	if magnitude <= v6 then
		return cframe2
	end

	local v7 = cframe.Position + v5.Unit * math.max(v6, 0)
	local vector = Vector3.new(cframe2.Position.X, v7.Y, cframe2.Position.Z)
	return CFrame.lookAt(v7, vector)
end

function v4.GetPosition(p: string)
	local v5 = v2[p]

	if v5 then
		return GetEnemyCFrame(v5)
	end

	return nil
end

function v4.GetEnemiesInRange(vector: Vector3, p: number)
	local result = {}

	for _, v5 in v2 do
		if v5.Instance:GetAttribute("Died") or v5.Instance:GetAttribute("Shielded") then
			continue
		end

		local value = v5.PositionValue.Value
		local value2 = v5.EndValue.Value

		if value ~= value2 then
			local instance = v5.Instance
			value2 = v4.GetMovementCFrame(
				value,
				value2,
				instance:GetAttribute("MovementStart"),
				instance:GetAttribute("MovementSpeed")
			)
		end

		local magnitude = (vector - value2.Position).Magnitude

		if magnitude <= p then
			table.insert(result, {
				ID = v5.ID,
				Distance = magnitude
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Distance < b.Distance
	end)
	return result
end

Instance:ObserveTaggedObject("Enemy", function(instance)
	local ID = WaitForAttribute(instance, "EnemyID", 5)

	if not ID then
		return
	end

	local waitForObject = WaitForObject(instance, "Data", 5)

	if not waitForObject then
		return
	end

	local positionValue = WaitForObject(waitForObject, "CurrentPosition", 5)

	if not positionValue then
		return
	end

	local endValue = WaitForObject(waitForObject, "EndPosition", 5)

	if not (endValue and instance.Parent) then
		return
	end

	local v9 = {
		ID = ID,
		Instance = instance,
		PositionValue = positionValue,
		EndValue = endValue
	}
	v9.Connection = instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			v9.Connection:Disconnect()
			v2[ID] = nil
		end
	end)
	v2[ID] = v9
end)
fighters.ChildAdded:Connect(function(child)
	SetupFighterTarget(child)
end)

for _, child in fighters:GetChildren() do
	SetupFighterTarget(child)
end

return table.freeze(v4)