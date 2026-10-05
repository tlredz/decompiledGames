local createVector = vector.create
local RunService = game:GetService("RunService")
local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(1, 0, 0)):Inverse()
local SimpleElasticCatenary = {}
SimpleElasticCatenary.__index = SimpleElasticCatenary

function SimpleElasticCatenary.new(position: Vector3, position2: Vector3, value: number?, value2: number?)
	local object = setmetatable({}, SimpleElasticCatenary)
	object.Model = Instance.new("Model")
	object.Model.Name = "SimpleElasticCatenary"
	object.Part0 = Instance.new("Part")
	object.Part0.Name = "Part0"
	object.Part0.Size = createVector(1, 1, 1)
	object.Part0.CFrame = CFrame.new(position)
	object.Part0.Anchored = true
	object.Part0.CanCollide = false
	object.Part0.CanTouch = false
	object.Part0.CanQuery = false
	object.Part0.Parent = object.Model
	object.Part1 = Instance.new("Part")
	object.Part1.Name = "Part1"
	object.Part1.Size = createVector(1, 1, 1)
	object.Part1.CFrame = CFrame.new(position2)
	object.Part1.Anchored = true
	object.Part1.CanCollide = false
	object.Part1.CanTouch = false
	object.Part1.CanQuery = false
	object.Part1.Parent = object.Model
	object.Attachment0 = Instance.new("Attachment")
	object.Attachment0.Name = "Attachment0"
	object.Attachment0.Parent = object.Part0
	object.Attachment1 = Instance.new("Attachment")
	object.Attachment1.Name = "Attachment1"
	object.Attachment1.Parent = object.Part1
	object.Ball = Instance.new("Part")
	object.Ball.Name = "Ball"
	object.Ball.Shape = Enum.PartType.Ball
	object.Ball.Size = createVector(1.5, 1.5, 1.5)
	object.Ball.CFrame = CFrame.new((position + position2) * 0.5) - Vector3.new(
		0,
		(position - position2).Magnitude * 0.5,
		0
	)
	object.Ball.Parent = object.Model
	object.Ball.Anchored = false
	object.Ball.CanCollide = false
	object.Part0.RootPriority = 200
	object.Part1.RootPriority = 200
	object.Ball.RootPriority = 200
	object.BallAttachment0 = Instance.new("Attachment")
	object.BallAttachment0.Name = "BallAttachment0"
	object.BallAttachment0.Parent = object.Ball
	object.BallAttachment1 = Instance.new("Attachment")
	object.BallAttachment1.Name = "BallAttachment1"
	object.BallAttachment1.Parent = object.Ball
	object.Beam = Instance.new("Beam")
	object.Beam.Name = "Beam"
	object.Beam.Attachment0 = object.Attachment0
	object.Beam.Attachment1 = object.Attachment1
	object.Beam.FaceCamera = true
	object.Beam.Segments = 8
	object.Beam.Width0 = 0.15
	object.Beam.Width1 = 0.15
	object.Beam.Parent = object.Model
	local damping = value or 50
	local stiffness = value2 or 200
	local magnitude = (position - position2).Magnitude
	object.SpringConstraint0 = Instance.new("SpringConstraint")
	object.SpringConstraint0.Name = "SpringConstraint0"
	object.SpringConstraint0.Attachment0 = object.Attachment0
	object.SpringConstraint0.Attachment1 = object.BallAttachment0
	object.SpringConstraint0.FreeLength = magnitude / 3
	object.SpringConstraint0.Damping = damping
	object.SpringConstraint0.Stiffness = stiffness
	object.SpringConstraint0.Parent = object.Part0
	object.SpringConstraint1 = Instance.new("SpringConstraint")
	object.SpringConstraint1.Name = "SpringConstraint1"
	object.SpringConstraint1.Attachment0 = object.Attachment1
	object.SpringConstraint1.Attachment1 = object.BallAttachment1
	object.SpringConstraint1.FreeLength = magnitude / 3
	object.SpringConstraint1.Damping = damping
	object.SpringConstraint1.Stiffness = stiffness
	object.SpringConstraint1.Parent = object.Part1
	object._connection = RunService.RenderStepped:Connect(function(_, _)
		object.Attachment0.WorldCFrame = CFrame.lookAlong(
			object.Attachment0.WorldPosition,
			object.Ball.Position - object.Attachment0.WorldPosition
		) * inverse
		object.Attachment1.WorldCFrame = CFrame.lookAlong(
			object.Attachment1.WorldPosition,
			-(object.Ball.Position - object.Attachment1.WorldPosition)
		) * inverse
		object.Ball.AssemblyLinearVelocity *= 0.995
		local magnitude2 = (object.Attachment1.WorldPosition - object.Attachment0.WorldPosition).Magnitude
		local beam = object.Beam
		local beam2 = object.Beam
		local curveSize = magnitude2 / 2
		local curveSize2 = magnitude2 / 2
		beam.CurveSize0 = curveSize
		beam2.CurveSize1 = curveSize2
		object.SpringConstraint0.FreeLength = magnitude2 / 3
		object.SpringConstraint1.FreeLength = magnitude2 / 3
	end)
	object.Model.Parent = workspace:WaitForChild("Terrain")
	return object
end

function SimpleElasticCatenary:Destroy()
	if self._connection then
		self._connection:Disconnect()
	end

	self.Model:Destroy()
	table.clear(self)
end

return SimpleElasticCatenary