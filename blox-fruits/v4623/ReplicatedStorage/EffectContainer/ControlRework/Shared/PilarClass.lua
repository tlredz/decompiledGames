local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Maid = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Maid"))
local lightningBoltShafi = Util.LightningBoltShafi

local function RecolorControlColorSequence(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColorSequenceConstructor(p, player, "ControlFruitVFXColor")
	end

	return p
end

local FX = require(ReplicatedStorage:WaitForChild("FX"))
local PilarClass = {
	TemplateModel = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay"):WaitForChild("PilarClassModel"),
	Stored = {}
}
PilarClass.__index = PilarClass

function PilarClass.new(instance, value: string?, player)
	local object = setmetatable({
		Maid = Maid.new(),
		Bolts = {},
		Player = player
	}, PilarClass)
	local model = object.Maid:GiveTask(object.TemplateModel:Clone())
	model.Name = `Pilar: {HttpService:GenerateGUID()}`
	Util.SetParentOverrideWithColor(model, workspace._WorldOrigin, player, "ControlFruitVFXColor")
	object.Model = model
	object:Load()
	local body = model.Body
	object.Body = body

	if instance then
		body.Size = instance.Size * createVector(1, 0, 1)
		model:PivotTo(instance.CFrame * CFrame.Angles(0, 0, 3.141592653589793) + Vector3.new(0, body.Size.Y / 2))
	end

	local collider = object.Maid:GiveTask(model.Collider)
	collider.Parent = workspace.Enemies
	object.Collider = collider
	PilarClass.Stored[collider] = object
	object:Update(true)
	object.Maid:GiveTask(body.Destroying:Connect(function()
		object:Destroy()
	end))
	object.Maid:GiveTask(body:GetPropertyChangedSignal("Size"):Connect(function()
		object:Update(true)
	end))
	object.Maid:GiveTask(body:GetPropertyChangedSignal("CFrame"):Connect(function()
		object:Update()
	end))
	object:SwitchMode(value or "Normal")
	return object
end

function PilarClass:GetModel()
	return self.Model
end

function PilarClass:Load()
	local model = self:GetModel()
	local body = model.Body
	local v = body.Size / body.MeshSize
	local base = model.Base
	local primaryPart = base.PrimaryPart
	local displacementsMap = {
		[base] = primaryPart.Size,
		[primaryPart.BoostMode.Winds] = createVector(0, 20, 0),
		[primaryPart.BoostMode.ShapeAir] = createVector(-0, -5, -0)
	}

	for _, child in model.BodyLayers:GetChildren() do
		displacementsMap[child] = child.Mesh.Scale - v
	end

	for _, child in primaryPart.NormalMode.Bolts:GetChildren() do
		local point = child.Point
		displacementsMap[point] = point.Position
	end

	for _, beam in model:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		local brightness = beam.Brightness

		if beam.LightEmission <= 0 then
			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			beam:SetAttribute("Width0", width0)
			beam:SetAttribute("Width1", width1)
		else
			beam.Brightness = 0
			beam:SetAttribute("Brightness", brightness)
		end

		beam.Enabled = true
	end

	self.DisplacementsMap = displacementsMap
end

function PilarClass:GetDisplacementsMap()
	return self.DisplacementsMap
end

function PilarClass:Update(flag: boolean?)
	local model = self:GetModel()
	local displacementsMap = self:GetDisplacementsMap()
	local body = self.Body
	local bodyLayers = model.BodyLayers
	local size = body.Size
	local meshSize = body.MeshSize
	local v = createVector(0, 1, 0) * size.Y
	local v2 = size / meshSize
	local collider = self.Collider

	if collider then
		collider.Size = size
	end

	local v3 = body.CFrame * CFrame.new(0, -size.Y / 2, 0)

	for _, child in bodyLayers:GetChildren() do
		local vector2 = v2 + displacementsMap[child]

		if child.Name == "GradientPattern" then
			vector2 = Vector3.new(vector2.X, math.min(vector2.Y, 39), vector2.Z)
		end

		child.Mesh.Scale = vector2
		child.CFrame = v3 * CFrame.new(0, vector2.Y * meshSize.Y / 2 - 0.05, 0)
	end

	local base = model.Base
	base:PivotTo(v3 * CFrame.new(0, -0.05, 0))
	base:ScaleTo((math.max(size.X / displacementsMap[base].X, 0.01)))
	local primaryPart = base.PrimaryPart
	local normalMode = primaryPart.NormalMode
	local boostMode = primaryPart.BoostMode

	for _, v4 in {
		boostMode.PatternBeam.Top,
		normalMode.PatternBeam.Top,
		boostMode.Arrow,
		boostMode.ShapeAir,
		boostMode.ShapeBodyAir,
		boostMode.Winds
	} do
		v4.Position = v + (displacementsMap[v4] or createVector(0, 0, 0))
	end

	for _, child in boostMode.ShapeBodyAir:GetChildren() do
		child.Drag.Position = createVector(0, 0, 1) * -size.Y
	end

	if not flag then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateBoltPoint(point)
		local v4 = displacementsMap[point]
		point.Position = Vector3.new(point.Position.X, v4.Y / self.TemplateModel.Body.Size.Y * size.Y, point.Position.Z)
	end

	for _, child in normalMode.Bolts:GetChildren() do
		UpdateBoltPoint(child.Point) -- equivalent call inferred; original call site unknown
	end
end

local function ToggleBeams(folder, flag: boolean, scale: number?)
	local v = scale or 1

	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		local v2 = {}

		if beam.LightEmission <= 0 then
			local width = not flag and 0 or (beam:GetAttribute("Width0") or 0) * v or 0
			local width2 = (not flag and 0 or beam:GetAttribute("Width1") or 0) * v or 0
			v2.Width0 = width
			v2.Width1 = width2
		else
			v2.Brightness = not flag and 0 or beam:GetAttribute("Brightness") or 0
		end

		TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), v2):Play()
	end
end

local function ToggleParticles(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

function PilarClass:GetScale()
	return self:GetModel().Base:GetScale()
end

function PilarClass:SwitchMode(mode: string)
	self.Mode = mode
	local model = self:GetModel()
	local canQuery = mode == "Solid"
	local enabled

	if mode == "Normal" then
		enabled = not canQuery
	else
		enabled = false
	end

	local enabled2

	if mode == "Boost" then
		enabled2 = not canQuery
	else
		enabled2 = false
	end

	local base = model.Base
	local primaryPart = base.PrimaryPart
	local scale = self:GetScale()
	local bolts = self.Bolts
	self:ClearBolts()
	self.Collider.CanQuery = canQuery
	local surfacesParticle = base.SurfacesParticle
	surfacesParticle.Top.Enabled = enabled
	surfacesParticle.Bottom.Enabled = enabled
	local normalMode = primaryPart.NormalMode
	ToggleBeams(normalMode, enabled, scale)
	ToggleParticles(normalMode.Particles, enabled)

	local function NewBolt(child, point, value: number?)
		local v4 = lightningBoltShafi.new(child, point, value or 8, 0.45 * scale, workspace._WorldOrigin)
		local curveSize = -math.random(5, 7)
		local curveSize2 = math.random(5, 7)
		v4.CurveSize0 = curveSize
		v4.CurveSize1 = curveSize2
		v4.MinRadius = 1
		v4.MaxRadius = 3
		v4.Frequency = 0.5
		v4.AnimationSpeed = math.random(5, 9)
		local maxThicknessMultiplier = 0.3 + math.random() * 0.75
		v4.MinThicknessMultiplier = 0.1
		v4.MaxThicknessMultiplier = maxThicknessMultiplier
		v4.MinTransparency = 0
		v4.MaxTransparency = 1
		v4.PulseSpeed = 40
		v4.PulseLength = 1000000
		v4.FadeLength = 0.2
		local player = self.Player
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
		})

		if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
			colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player, "ControlFruitVFXColor")
		end

		v4.Color = colorSequence
		v4.ContractFrom = 0.5
		v4.ColorOffsetSpeed = 3
		table.insert(bolts, v4)
		return v4
	end

	if enabled then
		for _, child in normalMode.Bolts:GetChildren() do
			NewBolt(child, child.Point)
		end
	end

	ToggleBeams(primaryPart.BoostMode, enabled2, scale)
	ToggleParticles(model.Body, enabled2)

	for _, emitter in model.Body:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled2
		end
	end
end

function PilarClass.GetStoredLength(p)
	local count = 0

	for _ in p.Stored do
		count += 1
	end

	return count
end

function PilarClass:RemoveCollider()
	local collider = self.Collider
	PilarClass.Stored[collider] = nil
	collider:Destroy()
	self.Collider = nil
end

function PilarClass.GetPilarByCollider(p, p2)
	return p.Stored[p2]
end

function PilarClass:ClearBolts()
	for _, bolt in self.Bolts do
		bolt:Destroy()
	end
end

function PilarClass:Destroy()
	if self.Collider then
		self:RemoveCollider()
	end

	self:ClearBolts()
	self.Maid:Destroy()
	table.clear(self)
end

return PilarClass