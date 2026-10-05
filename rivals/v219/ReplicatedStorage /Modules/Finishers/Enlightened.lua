local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local color = Color3.fromRGB(255, 255, 255)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
	object2:_InternalThread(task.delay, 2, function()
		object2:_AnchorModel(0, false)
		object2:_AnchorModel()
		object2:_BreakJoints()

		for _, instance in pairs(object2:_GetObjects()) do
			if instance:IsA("Clothing") then
				instance:Destroy()
			end

			if not instance:IsA("BasePart") then
				continue
			end

			for _, child in pairs(instance:GetChildren()) do
				if child:IsA("Texture") or child:IsA("Decal") then
					child:Destroy()
				end
			end

			instance.Material = Enum.Material.Neon
			local bodyForce = Instance.new("BodyForce")
			bodyForce.Force = createVector(0, 1, 0) * workspace.Gravity * instance:GetMass() * (1.25 + 0.5 * math.random())
			bodyForce.Parent = instance
			instance.Velocity = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit * 80 * math.random()
			instance.RotVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 180 * math.random()
			instance.CFrame *= CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
		end
	end)
end

function object:PlayClient(...)
	local parent = self._is_humanoid and self._subject.Parent or self._subject
	local head = self._is_humanoid and self._subject.Parent.Head or self._subject
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local pivot = parent:GetPivot()
	local lastTime = tick()
	local v = {}
	local v2 = {}
	table.insert(self._connections, RunService.RenderStepped:Connect(function(_)
		local now = tick()

		if lastTime + 2 <= now then
			return
		end

		local v3 = math.clamp((tick() - lastTime) / 2, 0, 1)
		parent:PivotTo(pivot + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 3 * v3 ^ 3)

		for _, part in pairs(self:_GetObjects(true)) do
			if not part:IsA("BasePart") then
				continue
			end

			v2[part] = v2[part] or part.Color
			part.Color = v2[part]:Lerp(color, v3)
		end

		for _, v4 in pairs(v) do
			local v5 = math.clamp((tick() - lastTime - v4.AppearDelay) / 0.5, 0, 1)

			for _, effect in pairs(v4.Object:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.LocalTransparencyModifier = 1 - v5
				end
			end
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add_effect(clone)
		table.insert(v, {
			AppearDelay = 1.5 * math.random(),
			Object = clone
		})
	end

	for _, child in pairs(script.Head:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = head
		table.insert(self._destroy_these, clone)
		add_effect(clone) -- equivalent call inferred; original call site unknown
	end

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") or part.Name == "Head" or part.Transparency > 0.5 then
			continue
		end

		for _ = 1, math.random(2, 6) do
			local vector2 = Vector3.FromNormalId(Enum.NormalId:GetEnumItems()[math.random(#Enum.NormalId:GetEnumItems())])
			local position = part.Size * vector2 / 2 + part.Size * (createVector(1, 1, 1) - vector2 * vector2) * math.sign(vector2.Magnitude) * Vector3.new(
				math.random() - 0.5,
				math.random() - 0.5,
				math.random() - 0.5
			)
			local clone = script.Beam.Finish:Clone()
			clone.Parent = part
			table.insert(self._destroy_these, clone)
			local clone2 = script.Beam.Start:Clone()
			clone2.Position = position
			clone2.Beam1.Attachment1 = clone
			clone2.Beam2.Attachment1 = clone
			clone2.Beam3.Attachment1 = clone
			clone2.Parent = part
			table.insert(self._destroy_these, clone2)
			add_effect(clone2) -- equivalent call inferred; original call site unknown
			clone.Position = clone2.Position + vector2 * (0.5 + 1.5 * math.random())
		end
	end

	self:CreateSound("rbxassetid://104941307595770", 1, 1, nil, true, 5)
	self:CreateSound("rbxassetid://137299793298455", 1, 1, nil, true, 5)
	wait(2)

	for _, v3 in pairs(v) do
		v3.Object:Destroy()
	end

	local clone = script.Explosion:Clone()
	clone.CFrame = pivot
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://79678979817013", 1.5, 1, nil, true, 5)
end

function object:_Init() end

return object