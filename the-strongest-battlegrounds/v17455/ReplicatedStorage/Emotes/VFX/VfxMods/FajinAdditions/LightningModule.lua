local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LightningModule = {}
LightningModule.__index = LightningModule
local v = {
	Color = Color3.fromRGB(120, 200, 255),
	SecondaryColor = Color3.fromRGB(255, 255, 255),
	Duration = 3,
	Width = 1.5,
	ThicknessJitter = 0.5,
	SegmentCount = 10,
	JitterIntensity = 2.5,
	ArcSway = 12,
	TextureSpeed = 15,
	WanderRadius = 0,
	WanderSpeed = 4,
	CylinderSize = 6,
	CylinderTransparency = 0,
	RaycastDistance = 50,
	IgnoreList = {}
}

function LightningModule.new(source, target, options)
	local object = setmetatable({}, LightningModule)
	object.Config = setmetatable(options or {}, {
		__index = v
	})
	object.Source = source
	object.Target = target
	object._IsAlive = true
	object._StartTime = tick()
	object._Seeds = {
		Wander = Vector2.new(math.random(1000), math.random(1000)),
		Arc = Vector3.new(math.random(1000), math.random(1000), math.random(1000))
	}
	object.Folder = Instance.new("Folder")
	object.Folder.Name = "LightningBolt"
	game.Debris:AddItem(object.Folder, 4)
	object.Folder.Parent = workspace.Thrown
	object.Attachments = {}
	object.Beams = {}

	for i = 1, math.max(3, object.Config.SegmentCount + 1) do
		local part = Instance.new("Part")
		part.Name = "Seg_" .. i
		part.Transparency = 1
		part.CanCollide = false
		part.Anchored = true
		part.CanQuery = false
		part.CanCollide = false
		part.Size = createVector(0.1, 0.1, 0.1)
		part.Parent = workspace.Thrown
		game.Debris:AddItem(part, 4)
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		table.insert(object.Attachments, attachment)

		if not (i > 1) then
			continue
		end

		local attachment2 = object.Attachments[i - 1]
		local beam = Instance.new("Beam")
		beam.Texture = "rbxassetid://448344541"
		beam.TextureMode = Enum.TextureMode.Wrap
		beam.TextureLength = 2
		beam.TextureSpeed = object.Config.TextureSpeed
		beam.LightEmission = 0
		beam.LightInfluence = 0
		beam.Transparency = NumberSequence.new(0)
		beam.Brightness = 11
		beam.Color = ColorSequence.new(object.Config.Color, object.Config.SecondaryColor)
		beam.Width0 = object.Config.Width
		beam.Width1 = object.Config.Width
		beam.FaceCamera = true
		beam.Attachment0 = attachment2
		beam.Attachment1 = attachment
		beam.Parent = object.Folder
		table.insert(object.Beams, beam)
	end

	object.Cylinder = Instance.new("Part")
	object.Cylinder.CanQuery = false
	object.Cylinder.Name = "ImpactRing"
	object.Cylinder.CastShadow = false
	object.Cylinder.Material = Enum.Material.Neon
	object.Cylinder.Color = object.Config.Color
	object.Cylinder.Transparency = object.Config.CylinderTransparency
	object.Cylinder.Anchored = true
	object.Cylinder.CanCollide = false
	object.Cylinder.Shape = Enum.PartType.Cylinder
	object.Cylinder.Size = Vector3.new(0.2, object.Config.CylinderSize, object.Config.CylinderSize)
	object.Cylinder.Parent = object.Folder
	object.Connection = RunService.Heartbeat:Connect(function(dt)
		object:_Update(dt)
	end)

	if object.Config.Duration > 0 then
		task.delay(object.Config.Duration, function()
			if object._IsAlive then
				object:Destroy()
			end
		end)
	end

	return object
end

local function getPosition(instance)
	if typeof(instance) == "Vector3" then
		return instance
	end

	if typeof(instance) ~= "Instance" then
		return createVector(0, 0, 0)
	end

	if instance:IsA("Attachment") then
		return instance.WorldPosition
	end

	if instance:IsA("BasePart") then
		return instance.Position
	end

	return createVector(0, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBezierPoint(p, source, p2, position)
	return source:Lerp(p2, p):Lerp(p2:Lerp(position, p), p)
end

function LightningModule:_Update(_)
	if not self._IsAlive then
		return
	end

	local source = self.Source

	if typeof(source) ~= "Vector3" then
		if typeof(source) == "Instance" then
			if source:IsA("Attachment") then
				source = source.WorldPosition
			else
				source = not source:IsA("BasePart") and createVector(0, 0, 0) or source.Position
			end
		else
			source = createVector(0, 0, 0)
		end
	end

	local target = self.Target

	if typeof(target) ~= "Vector3" then
		if typeof(target) == "Instance" then
			if target:IsA("Attachment") then
				target = target.WorldPosition
			else
				target = not target:IsA("BasePart") and createVector(0, 0, 0) or target.Position
			end
		else
			target = createVector(0, 0, 0)
		end
	end

	local v2 = tick() - self._StartTime
	local v3 = v2 * self.Config.WanderSpeed

	if not source then
		return
	end

	if self.Config.WanderRadius > 0 then
		local v4 = v2 * self.Config.WanderSpeed % 1
		local v5 = math.floor(v2 * self.Config.WanderSpeed)
		local v6 = math.noise(v5, self._Seeds.Wander.X) * 3.141592653589793 * 4
		local vector2 = Vector3.new(math.cos(v6), 0, (math.sin(v6)))
		local v7 = v2 * (self.Config.WanderSpeed * 8)
		local v8 = Vector3.new(math.noise(v7, self._Seeds.Wander.Y), 0, (math.noise(self._Seeds.Wander.Y, v7))) * (self.Config.WanderRadius * 0.4)
		target = target + vector2 * (v4 * self.Config.WanderRadius) + v8
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { self.Folder, unpack(self.Config.IgnoreList) }
	local v4 = target + createVector(0, 5, 0)
	local vector2 = Vector3.new(0, -(self.Config.RaycastDistance + 5), 0)
	local raycastResult = workspace:Raycast(v4, vector2, raycastParams)
	local position = raycastResult and raycastResult.Position or target - Vector3.new(
		0,
		self.Config.RaycastDistance / 2,
		0
	)

	if raycastResult then
		self.Cylinder.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, 1.5707963267948966)
		self.Cylinder.Transparency = self.Config.CylinderTransparency
	else
		self.Cylinder.Transparency = 1
	end

	local v5 = (source + position) / 2 + Vector3.new(
		math.noise(self._Seeds.Arc.X, v3, 0),
		math.noise(self._Seeds.Arc.Y, v3, 0),
		math.noise(self._Seeds.Arc.Z, v3, 0)
	) * self.Config.ArcSway
	local count = #self.Attachments

	for i, attachment in ipairs(self.Attachments) do
		local v6 = (i - 1) / (count - 1)

		if not attachment then
			continue
		end

		local bezierPoint = getBezierPoint(v6, source, v5, position) -- equivalent call inferred; original call site unknown

		if i == 1 then
			attachment.Parent.Position = source
		elseif i == count then
			attachment.Parent.Position = position
		else
			local jitterIntensity = self.Config.JitterIntensity
			local v7 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * jitterIntensity
			attachment.Parent.Position = bezierPoint + v7
		end
	end

	if self.Config.ThicknessJitter > 0 then
		for _, beam in ipairs(self.Beams) do
			local v6 = (math.random() - 0.5) * self.Config.ThicknessJitter
			local width = math.max(0.1, self.Config.Width * (1 + v6))
			beam.Width0 = width
			beam.Width1 = width
		end
	end
end

function LightningModule:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	if self.Connection then
		self.Connection:Disconnect()
	end

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, beam in ipairs(self.Beams) do
		TweenService:Create(beam, tweenInfo, {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end

	local tween = TweenService:Create(self.Cylinder, tweenInfo, {
		Size = createVector(0, 0, 0),
		Transparency = 1
	})
	tween:Play()
	tween.Completed:Wait()
	self.Folder:Destroy()
end

function LightningModule:UpdateTarget(target)
	self.Target = target
end

return LightningModule