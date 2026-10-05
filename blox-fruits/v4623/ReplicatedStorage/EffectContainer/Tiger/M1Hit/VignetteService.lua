local createVector = vector.create
local Physics = require(script:WaitForChild("Physics"))

-- equivalent calls inferred from this helper; original call sites unknown
local function getHorizontalFov()
	local fieldOfView = game.Workspace.CurrentCamera.FieldOfView
	local viewportSize = game.Workspace.CurrentCamera.ViewportSize
	local v = viewportSize.X / viewportSize.Y
	return (math.deg(math.atan(math.tan(math.rad(fieldOfView) * 0.5) * v) * 2))
end

local function createViewModel(list)
	local v = {}
	local fieldOfView = game.Workspace.CurrentCamera.FieldOfView
	local v2 = fieldOfView + (getHorizontalFov() - fieldOfView) / 1.65
	local v3 = {
		topLeft = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), math.rad(v2 / 2), 0) * CFrame.new(0, 0, -5),
		topRight = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), -math.rad(v2 / 2), 0) * CFrame.new(0, 0, -5),
		bottomLeft = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), math.rad(v2 / 2), 0) * CFrame.new(
			0,
			0,
			-5
		),
		bottomRight = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), -math.rad(v2 / 2), 0) * CFrame.new(
			0,
			0,
			-5
		)
	}
	local magnitude = (v3.topLeft.Position - v3.topRight.Position).magnitude
	local magnitude2 = (v3.topLeft.Position - v3.bottomLeft.Position).magnitude
	v.sides = {
		Top = {
			Size = Vector3.new(0.2, 0.2, magnitude),
			Corners = { "topLeft", "topRight" }
		},
		Bottom = {
			Size = Vector3.new(0.2, 0.2, magnitude),
			Corners = { "bottomRight", "bottomLeft" }
		},
		Right = {
			Size = Vector3.new(0.2, 0.2, magnitude2),
			Corners = { "topRight", "bottomRight" }
		},
		Left = {
			Size = Vector3.new(0.2, 0.2, magnitude2),
			Corners = { "topLeft", "bottomLeft" }
		}
	}
	v.sideInstances = {}
	v.corePart = Instance.new("Part")
	v.corePart.Size = createVector(0.2, 0.2, 0.2)
	v.corePart.Transparency = 1
	v.corePart.CanCollide = false
	v.corePart.Parent = game.Workspace

	local function updateCorePart()
		v.corePart.CFrame = game.Workspace.CurrentCamera.CFrame
	end

	local RunService = game:GetService("RunService")
	v.Connection = RunService.RenderStepped:connect(updateCorePart)

	for k, side in next, v.sides, nil do
		local part = Instance.new("Part")
		part.Anchored = false
		print(side.Size)
		part.Size = side.Size
		part.Transparency = 1
		part.Parent = game.Workspace
		part.CanCollide = false
		local v4 = CFrame.new(v3[side.Corners[1]].Position, v3[side.Corners[2]].Position) * CFrame.new(
			0,
			0,
			-side.Size.Z / 2
		)
		local joint = Physics.joint.new(part, v.corePart, CFrame.new(), v4)
		v.sideInstances[k] = {
			Object = part,
			Joint = joint
		}

		for _, v5 in ipairs(list) do
			local clone = v5:Clone()
			clone.Parent = part
		end
	end

	return v
end

local function adjustViewModel(p, distance)
	local fieldOfView = game.Workspace.CurrentCamera.FieldOfView
	local v = fieldOfView + (getHorizontalFov() - fieldOfView) / 1.65
	local v2 = {
		topLeft = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), math.rad(v / 2), 0) * CFrame.new(
			0,
			0,
			-distance
		),
		topRight = CFrame.new() * CFrame.Angles(math.rad(fieldOfView / 2), -math.rad(v / 2), 0) * CFrame.new(
			0,
			0,
			-distance
		),
		bottomLeft = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), math.rad(v / 2), 0) * CFrame.new(
			0,
			0,
			-distance
		),
		bottomRight = CFrame.new() * CFrame.Angles(-math.rad(fieldOfView / 2), -math.rad(v / 2), 0) * CFrame.new(
			0,
			0,
			-distance
		)
	}
	local magnitude = (v2.topLeft.Position - v2.topRight.Position).magnitude
	local magnitude2 = (v2.topLeft.Position - v2.bottomLeft.Position).magnitude
	p.sides.Top.Size = Vector3.new(0.2, 0.2, magnitude)
	p.sides.Bottom.Size = Vector3.new(0.2, 0.2, magnitude)
	p.sides.Right.Size = Vector3.new(0.2, 0.2, magnitude2)
	p.sides.Left.Size = Vector3.new(0.2, 0.2, magnitude2)

	for k, side in next, p.sides, nil do
		local C1 = CFrame.new(v2[side.Corners[1]].Position, v2[side.Corners[2]].Position) * CFrame.new(
			0,
			0,
			-side.Size.Z / 2
		)
		p.sideInstances[k].Object.Size = side.Size
		p.sideInstances[k].Joint.C1 = C1
		print("done")
	end
end

local VignetteService = {}
local v = {}

function v.new(viewmodel)
	local object = setmetatable({}, {
		__index = v
	})
	object.viewmodel = viewmodel
	object.effects = {}
	object.enabled = true
	object.distance = 5
	object.updating = false
	object.updateConnections = {
		viewport = nil,
		fov = nil
	}

	for _, sideInstance in next, viewmodel.sideInstances, nil do
		for _, child in ipairs(sideInstance.Object:GetChildren()) do
			print("added effect...")
			table.insert(object.effects, child)
		end
	end

	return object
end

function v:Enabled(enabled)
	self.enabled = enabled

	for _, effect in ipairs(self.effects) do
		effect.Enabled = self.enabled
	end
end

function v:SetDistance(distance)
	adjustViewModel(self.viewmodel, distance)
	self.distance = distance
end

function v:UpdateEnabled(updating)
	self.updating = updating

	if self.updating then
		self.updateConnections.viewport = game.Workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			adjustViewModel(self.viewmodel, self.distance)
		end)
		self.updateConnections.fov = game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			adjustViewModel(self.viewmode, self.distance)
		end)
	else
		if self.updateConnections.fov then
			self.updateConnections.fov:Disconnect()
		end

		if self.upateConnections.viewport then
			self.updateConnections.viewport:Disconnect()
		end
	end
end

function v:Destroy()
	for _, sideInstance in next, self.viewmodel.sideInstances, nil do
		sideInstance.Object:Destroy()
	end

	self.viewmodel.Connection:Disconnect()
	self.viewmodel.corePart:Destroy()
end

function VignetteService.CreateVignette(_, list)
	assert(typeof(list) == "table", "CreateVignette only accepts a table of 'ParticleEmitter' objects!")

	for _, emitter in ipairs(list) do
		assert(
			typeof(emitter) == "Instance",
			"All objects provided must be an instance 'ParticleEmitter'! You provided a " .. typeof(emitter)
		)
		assert(
			emitter:IsA("ParticleEmitter"),
			"All objects provided must be an instance 'ParticleEmitter'! You provided a " .. emitter.ClassName
		)
	end

	local viewModel = createViewModel(list)
	return (v.new(viewModel))
end

return VignetteService