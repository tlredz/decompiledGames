local createVector = vector.create
local Lighting = game:GetService("Lighting")
local dependencies = script.Parent.Parent:WaitForChild("Dependencies")
require(script.Parent:WaitForChild("Bone"))
local Config = require(dependencies:WaitForChild("Config"))
local DefaultObjectSettings = require(dependencies:WaitForChild("DefaultObjectSettings"))
local Gizmo = require(dependencies:WaitForChild("Debug"):WaitForChild("Gizmo"))
local Utilities = require(dependencies:WaitForChild("Utilities"))
local random = Random.new(1029410295159813)
local SB_VERBOSE_LOG = Utilities.SB_VERBOSE_LOG

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(vector2: Vector3)
	if vector2.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return vector2.Unit
end

local function map(p: number, p2: number, p3: number, p4: number, p5: number, flag: boolean)
	local v = (p - p2) / (p3 - p2) * (p5 - p4) + p4

	if not flag then
		return v
	end

	if p4 < p5 then
		if p4 < (v < p5 and v or p5) then
			p4 = v < p5 and v or p5 or p4
		end

		return p4
	else
		if p5 < (v < p4 and v or p4) then
			p5 = v < p4 and v or p4 or p5
		end

		return p5
	end
end

local BoneTree = {}
BoneTree.__index = BoneTree

function BoneTree.new(bone, instance, attributesByAttributeName)
	local object = setmetatable({
		WindOffset = random:NextNumber(0, 1000000),
		Root = bone:IsA("Bone") and bone or nil,
		RootPart = instance,
		RootPartSize = instance.Size,
		Bones = {},
		Settings = attributesByAttributeName,
		UpdateRate = 0,
		InView = true,
		AccumulatedDelta = 0,
		BoundingBoxCFrame = instance.CFrame,
		BoundingBoxSize = instance.Size,
		Destroyed = false,
		IsSkippingUpdates = false,
		InWorkspace = false,
		Force = createVector(0, 0, 0),
		ObjectMove = createVector(0, 0, 0),
		ObjectVelocity = createVector(0, 0, 0),
		ObjectAcceleration = createVector(0, 0, 0),
		ObjectPreviousPosition = instance.Position
	}, BoneTree)
	object.InWorkspace = instance:IsDescendantOf(workspace)
	object.DestroyConnection = instance.AncestryChanged:ConnectParallel(function()
		if not instance:IsDescendantOf(game) then
			object.Destroyed = true
		end

		object.InWorkspace = instance:IsDescendantOf(workspace)
	end)
	object.AttributeConnection = instance.AttributeChanged:ConnectParallel(function(attributeName)
		attributesByAttributeName[attributeName] = instance:GetAttribute(attributeName) or DefaultObjectSettings[attributeName]
	end)
	return object
end

function BoneTree:UpdateBoundingBox()
	if self.InView then
		local vector2 = createVector(1e999, 1e999, 1e999)
		local vector3 = createVector(-1e999, -1e999, -1e999)

		for _, bone in self.Bones do
			local v = bone.Position - bone.LastPosition
			local v2 = bone.Position + v
			vector2 = vector2:Min(v2)
			vector3 = vector3:Max(v2)
		end

		local vector4 = (vector2 + vector3) * 0.5
		self.BoundingBoxCFrame = CFrame.new(vector4)
		self.BoundingBoxSize = self.RootPartSize:Max(vector3 - vector2)
	else
		self.BoundingBoxCFrame = self.RootPart.CFrame
		self.BoundingBoxSize = self.RootPart.Size
	end
end

function BoneTree:UpdateThrottling(vector2: Vector3)
	local settings = self.Settings
	local magnitude = (vector2 - workspace.CurrentCamera.CFrame.Position).Magnitude

	if settings.ActivationDistance < magnitude then
		self.UpdateRate = 0
		return
	end

	local throttleDistance = settings.ThrottleDistance
	local activationDistance = settings.ActivationDistance
	local v = (magnitude - throttleDistance) / (activationDistance - throttleDistance) * 1 + 0
	local v2 = 1 - (not ((v < 1 and v or 1) > 0) and 0 or v < 1 and v or 1)
	self.UpdateRate = settings.UpdateRate * v2
end

function BoneTree:PreUpdate(_: number)
	local position = self.RootPart.CFrame.Position
	local objectVelocity = self.ObjectVelocity
	self.ObjectMove = position - self.ObjectPreviousPosition
	self.ObjectVelocity = self.ObjectMove
	self.ObjectAcceleration = objectVelocity - self.ObjectVelocity
	self.ObjectPreviousPosition = position
	self.RootPartSize = self.RootPart.Size
	self:UpdateThrottling(position)
	self:UpdateBoundingBox()

	for _, bone in self.Bones do
		bone:PreUpdate(self)
	end
end

function BoneTree:StepPhysics(p2: number)
	local settings = self.Settings
	local v = settings.Gravity + settings.Force

	if settings.MatchWorkspaceWind == true then
		local globalWind = workspace.GlobalWind
		settings.WindDirection = SafeUnit(globalWind)
		settings.WindSpeed = globalWind.Magnitude
	else
		local windDirection = Lighting:GetAttribute("WindDirection") or DefaultObjectSettings.WindDirection
		local windSpeed = Lighting:GetAttribute("WindSpeed") or DefaultObjectSettings.WindSpeed
		settings.WindDirection = SafeUnit(windDirection)
		settings.WindSpeed = windSpeed
	end

	settings.WindStrength = Lighting:GetAttribute("WindStrength") or DefaultObjectSettings.WindStrength

	for _, bone in self.Bones do
		bone:StepPhysics(self, v, p2)
	end
end

function BoneTree:Constrain(p2, p3: number)
	for _, bone in self.Bones do
		bone:Constrain(self, p2, p3)
	end
end

function BoneTree:SkipUpdate()
	for _, bone in self.Bones do
		bone:SkipUpdate()
	end

	self.IsSkippingUpdates = true
end

function BoneTree:SolveTransform(p2: number)
	for _, bone in self.Bones do
		bone:SolveTransform(self, p2)
	end

	self.IsSkippingUpdates = false
end

function BoneTree:ApplyTransform()
	for _, bone in self.Bones do
		bone:ApplyTransform(self)
	end
end

function BoneTree:DrawDebug(flag: boolean, flag2: boolean, flag3: boolean, flag4: boolean, flag5: boolean, flag6: boolean, flag7: boolean, flag8: boolean)
	local color = Color3.fromRGB(248, 168, 20)
	local color2 = Color3.fromRGB(76, 208, 223)
	local color3 = Color3.fromRGB(255, 89, 89)
	local color4 = Color3.new(1, 0, 0)
	local color5 = Color3.new(0, 1, 0)
	local color6 = Color3.new(0, 0, 1)

	if flag8 then
		local v = self.RootPart.Position + Vector3.new(0, self.RootPart.Size.Y * 0.5 + 1, 0)
		Gizmo.SetStyle(color4, 0, true)
		Gizmo.Arrow:Draw(v, v + self.ObjectMove, 0.025, 0.1, 6)
		Gizmo.SetStyle(color5, 0, true)
		Gizmo.Arrow:Draw(v, v + self.ObjectVelocity, 0.025, 0.1, 6)
		Gizmo.SetStyle(color6, 0, true)
		Gizmo.Arrow:Draw(v, v + self.ObjectAcceleration, 0.025, 0.1, 6)
	end

	Gizmo.PushProperty("AlwaysOnTop", false)

	if flag6 then
		Gizmo.PushProperty("Color3", color2)
		Gizmo.Box:Draw(self.BoundingBoxCFrame, self.BoundingBoxSize, true)
	end

	if flag5 then
		Gizmo.PushProperty("Color3", color2)
		Gizmo.Box:Draw(self.RootPart.CFrame, self.RootPart.Size, true)
		Gizmo.SetStyle(color3, 0.75, false)
		Gizmo.VolumeBox:Draw(self.RootPart.CFrame, self.RootPart.Size)
		Gizmo.PushProperty("Transparency", 0)
	end

	for k, bone in self.Bones do
		local position = bone.Bone.TransformedWorldCFrame.Position
		local bone2 = self.Bones[bone.ParentIndex]
		bone:DrawDebug(self, flag, flag2, flag3, flag4, flag7)

		if not (flag2 and k ~= 1) then
			continue
		end

		Gizmo.PushProperty("Color3", color)
		Gizmo.Ray:Draw(bone2.Bone.TransformedWorldCFrame.Position, position)
	end
end

function BoneTree:DrawOverlay(data2)
	if Config.DEBUG_OVERLAY_TREE_INFO or Config.DEBUG_OVERLAY_TREE_OBJECTS then
		data2.Text((`Root Part: {self.RootPart.Name}`))
		data2.Text((`Root Bone: {self.Root.Name}`))
		data2.Text((`Root Part Size: {string.format("%.3f, %.3f, %.3f", self.RootPart.Size.X, self.RootPart.Size.Y, self.RootPart.Size.Z)}`))
	end

	if Config.DEBUG_OVERLAY_TREE_INFO or Config.DEBUG_OVERLAY_TREE_NUMERICS then
		data2.Text((`Update Rate: {string.format("%.3f", self.UpdateRate)}`))
		data2.Text((`In View: {self.InView}`))
		data2.Text((`Accumulated Delta: {string.format("%.3f", self.AccumulatedDelta)}`))
		data2.Text((`Force: {string.format("%.3f, %.3f, %.3f", self.Force.X, self.Force.Y, self.Force.Z)}`))
	end

	local color = Color3.new(0.486275, 0.431373, 1)
	local color2 = Color3.new(1, 1, 1)

	if Config.DEBUG_OVERLAY_BONE then
		for k, bone in self.Bones do
			if Config.DEBUG_OVERLAY_MAX_BONES > 0 and Config.DEBUG_OVERLAY_BONE_OFFSET + Config.DEBUG_OVERLAY_MAX_BONES <= k then
				break
			end

			if k < Config.DEBUG_OVERLAY_BONE_OFFSET then
				continue
			end

			data2.Begin(`Bone {k}`, color, color2)
			bone:DrawOverlay(data2)
			data2.End()
		end
	end
end

function BoneTree:Destroy()
	SB_VERBOSE_LOG("Destroy BoneTree")
	task.synchronize()
	self.DestroyConnection:Disconnect()
	self.AttributeConnection:Disconnect()

	for _, bone in self.Bones do
		bone:Destroy()
	end

	setmetatable(self, nil)
	task.desynchronize()
end

return BoneTree