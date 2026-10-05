local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Debris = game:GetService("Debris")
game:GetService("Players")
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local SafeCast = require(ReplicatedStorage.Shared.SafeCast)
local FindProbableTarget = require(ReplicatedStorage.Classes.Projectile.FindProbableTarget)
local folder

if RunService:IsClient() then
	folder = Instance.new("Folder")
	folder.Name = "__PROJECTILES"
	folder.Parent = workspace
else
	folder = nil
end

local table2 = Asserts.Table({
	Timestamp = Asserts.Finite,
	Character = Asserts.Optional(Asserts.Model),
	CFrame = Asserts.CFrameFinite,
	LinearVelocity = Asserts.Vector3Finite,
	Age = Asserts.FiniteNonNegative,
	Attributes = Asserts.Map(Asserts.String, Asserts.Any),
	HitPart = Asserts.BasePart,
	HitNormal = Asserts.Vector3Unit,
	HitPosition = Asserts.Vector3Finite,
	HitEnding = Asserts.Vector3Finite,
	HitAlpha = Asserts.Range(0, 1),
	HitSize = Asserts.Vector3Positive,
	HitCFrame = Asserts.CFrameFinite
})
local v = {}
Bindable.new()
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.BruteForceAllSlow = false
raycastParams.RespectCanCollide = true
raycastParams.CollisionGroup = "Projectile"
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {}
local raycastParams2 = RaycastParams.new()
raycastParams2.IgnoreWater = false
raycastParams2.BruteForceAllSlow = false
raycastParams2.RespectCanCollide = true
raycastParams2.CollisionGroup = "MobFinder"
raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
raycastParams2.FilterDescendantsInstances = {}
local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 100
overlapParams.BruteForceAllSlow = false
overlapParams.RespectCanCollide = true
overlapParams.CollisionGroup = "MobFinder"
overlapParams.FilterType = Enum.RaycastFilterType.Exclude
overlapParams.FilterDescendantsInstances = {}

local function Destroy(instance)
	if instance.Destroyed then
		return false
	end

	instance.Destroyed = true
	v[instance] = nil
	local model = instance.Model

	if model then
		local v2 = 0

		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("Trail") then
				v2 = math.max(v2, descendant.Lifetime)
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
				v2 = math.max(v2, descendant.Lifetime.Max / descendant.TimeScale)
			end
		end

		Debris:AddItem(model, v2)
	end

	instance.Destroying:Fire()
	return true
end

local function Eval(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number)
	local v2 = p * p
	return vector2 + vector3 * p + vector4 * 0.5 * v2, vector3 + (vector4 + vector5) * p
end

local function ComputeSteeringAccel(state, position: Vector3, linearVelocity: Vector3, trackingRadius: number, trackingFalloff: number, trackingResponse: number)
	local magnitude = linearVelocity.Magnitude
	local vector2 = linearVelocity / magnitude

	if magnitude < 1e-6 then
		return createVector(0, 0, 0)
	end

	local v2 = raycastParams
	v2.FilterDescendantsInstances = state.FilterDescendantsInstances
	local v3 = overlapParams
	v3.FilterDescendantsInstances = state.FilterDescendantsInstances
	local probableTarget = FindProbableTarget(
		position,
		position + vector2 * 1000,
		state.Radius + trackingRadius,
		v2,
		v3
	)

	if not probableTarget then
		return createVector(0, 0, 0)
	end

	local v5 = probableTarget - position
	local magnitude2 = v5.Magnitude

	if magnitude2 < 1e-6 then
		return createVector(0, 0, 0)
	end

	local v6 = v5 / magnitude2
	local v7 = (1 - math.exp(-math.acos((math.clamp(vector2:Dot(v6), -1, 1))) * trackingResponse)) * (1 / (1 + trackingFalloff * magnitude2))
	local vector3 = vector2:Cross(v6)

	if vector3.Magnitude < 1e-6 then
		return createVector(0, 0, 0)
	end

	return (vector2 + vector3:Cross(vector2).Unit * v7).Unit * magnitude - linearVelocity
end

local function Simulate(state, p: number)
	local cFrame = state.CFrame
	local position = cFrame.Position
	local linearVelocity = state.LinearVelocity
	local vector2 = createVector(0, 0, 0)

	if state.TrackingResponse then
		vector2 += ComputeSteeringAccel(
			state,
			position,
			linearVelocity,
			state.TrackingRadius or 0,
			state.TrackingFalloff or 0,
			state.TrackingResponse
		)
	end

	local gravity = state.Gravity
	local v2 = p * p
	local vector3 = position + linearVelocity * p + gravity * 0.5 * v2
	local linearVelocity2 = linearVelocity + (gravity + vector2) * p
	local v4 = raycastParams
	v4.FilterDescendantsInstances = state.FilterDescendantsInstances
	local safeCast = SafeCast(position, vector3, state.Radius, v4)

	if safeCast then
		local alpha = safeCast.Alpha
		vector3 = position:Lerp(vector3, alpha)
		linearVelocity2 = linearVelocity:Lerp(linearVelocity2, alpha)
		p *= alpha
	end

	local rotation = cFrame.Rotation

	if linearVelocity2.Magnitude > 1e-6 then
		rotation = CFrame.lookAlong(createVector(0, 0, 0), linearVelocity2)
	end

	state.CFrame = CFrame.new(vector3) * rotation
	state.LinearVelocity = linearVelocity2
	state.Age += p

	if safeCast then
		state.Hit:Fire(safeCast)
	end

	if state.Age >= state.MaxAge then
		Destroy(state)
	end

	return p
end

local function SimulateTo(data, p: number, value: number?)
	local v2 = p - data.CreationTime

	for _ = 1, value or 4 do
		if data.Destroyed or v2 - data.Age < 0.03333333333333333 then
			break
		else
			Simulate(data, 0.03333333333333333)
		end
	end
end

local function RenderTo(data, p: number)
	local model = data.Model

	if not model then
		return
	end

	local v2 = p - data.CreationTime - data.Age
	local cFrame = data.CFrame
	local position = cFrame.Position
	local linearVelocity = data.LinearVelocity
	local gravity = data.Gravity
	local v3 = v2 * v2
	local vector2 = position + linearVelocity * v2 + gravity * 0.5 * v3
	local v4 = linearVelocity + (gravity + createVector(0, 0, 0)) * v2
	local rotation = cFrame.Rotation

	if v4.Magnitude > 1e-6 then
		rotation = CFrame.lookAlong(createVector(0, 0, 0), v4)
	end

	model:PivotTo(CFrame.new(vector2) * rotation)
end

local frozen = table.freeze({
	IsDestroyed = function(p)
		return p.Destroyed
	end,
	Destroy = Destroy,
	SimulateTo = SimulateTo
})
local frozen2 = table.freeze({
	__index = frozen
})
local table3 = Asserts.Table({
	Id = Asserts.UUIDStripped,
	CreationTime = Asserts.Finite,
	Origin = Asserts.Vector3Finite,
	LinearVelocity = Asserts.Vector3Finite,
	Radius = Asserts.FiniteNonNegative,
	Gravity = Asserts.Optional(Asserts.Vector3Finite),
	MaxAge = Asserts.Optional(Asserts.FiniteNonNegative),
	TrackingRadius = Asserts.Optional(Asserts.FiniteNonNegative),
	TrackingFalloff = Asserts.Optional(Asserts.FiniteNonNegative),
	TrackingResponse = Asserts.Optional(Asserts.FiniteNonNegative),
	FilterDescendantsInstances = Asserts.Optional(Asserts.Array(Asserts.Instance)),
	TemplateModel = Asserts.Optional(Asserts.Model)
})

local function new(data)
	table3(data)
	local cframe = CFrame.lookAlong(data.Origin, data.LinearVelocity)
	local clones = not data.FilterDescendantsInstances and {} or table.clone(data.FilterDescendantsInstances)
	local clone

	if data.TemplateModel then
		clone = data.TemplateModel:Clone()

		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CollisionGroup = "Projectile"
		end

		clone:PivotTo(cframe)
		clone.Parent = folder
		table.insert(clones, clone)
	end

	local object = setmetatable({
		Destroyed = false,
		Hit = Bindable.new(),
		Destroying = Bindable.new(),
		Attributes = {},
		Impacts = {},
		Id = data.Id,
		CreationTime = data.CreationTime,
		CFrame = cframe,
		LinearVelocity = data.LinearVelocity,
		Radius = data.Radius,
		Gravity = data.Gravity or Vector3.new(0, -workspace.Gravity, 0),
		Age = 0,
		MaxAge = data.MaxAge or 5,
		TrackingRadius = data.TrackingRadius,
		TrackingFalloff = data.TrackingFalloff,
		TrackingResponse = data.TrackingResponse,
		FilterDescendantsInstances = clones,
		Model = clone
	}, frozen2)
	v[object] = true
	return object
end

local table4 = Asserts.Table({
	CameraDistance = Asserts.Optional(Asserts.Finite),
	RaycastDistance = Asserts.Optional(Asserts.FiniteNonNegative),
	FilterDescendantsInstances = Asserts.Optional(Asserts.Array(Asserts.Instance))
})

local function PickTarget(data)
	table4(data)
	local cameraDistance = data.CameraDistance or 0
	local raycastDistance = data.RaycastDistance or 1000
	local filterDescendantsInstances = data.FilterDescendantsInstances or {}
	local mouseLocation = UserInputService:GetMouseLocation()
	local guiInset, _ = GuiService:GetGuiInset()
	local v2 = mouseLocation - guiInset
	local screenPointToRay = workspace.CurrentCamera:ScreenPointToRay(v2.X, v2.Y, cameraDistance)
	local unit = screenPointToRay.Direction.Unit
	local origin = screenPointToRay.Origin
	local v3 = unit * raycastDistance
	local v4 = raycastParams
	v4.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = workspace:Raycast(origin, v3, v4)

	if raycastResult then
		return raycastResult.Position
	end

	return origin + v3
end

RunService.PostSimulation:Connect(function(_)
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, _ in pairs(v) do
		local success, result = pcall(SimulateTo, k, serverTimeNow)

		if success then
			continue
		end

		Destroy(k)
		warn("Projectile.SimulateTo", result)
	end
end)

if RunService:IsClient() then
	RunService:BindToRenderStep("Projectile", Enum.RenderPriority.Last.Value - 1, function(_)
		local serverTimeNow = workspace:GetServerTimeNow()

		for k, _ in pairs(v) do
			local success, result = pcall(RenderTo, k, serverTimeNow)

			if success then
				continue
			end

			Destroy(k)
			warn("Projectile.RenderTo", result)
		end
	end)
end

return table.freeze({
	new = new,
	AssertImpactMeta = table2,
	PickTarget = PickTarget
})