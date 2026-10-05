local createVector = vector.create
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	warn("Attempted to initialize SmartBone on Server.")
	return nil
end

local dependencies = script:WaitForChild("Dependencies")
local components = script:WaitForChild("Components")
local Config = require(dependencies.Config)
local UnitConversion = require(dependencies.UnitConversion)
local DefaultSettings = require(dependencies.DefaultSettings)
local ParticleTree = require(components.ParticleTree)
local Particle = require(components.Particle)
local SettingsMath = require(dependencies.SettingsMath)
local Utilities = require(dependencies.Utilities)
local random = Random.new(12098135901304)
local tagged = CollectionService:GetTagged("SmartBone")
local debug = Config.Debug
local model

if debug then
	model = Instance.new("Model")
	model.Name = "SMARTBONE_DEBUGFOLDER"
	model.Parent = workspace
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 0
	highlight.Parent = model
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = true
else
	model = nil
end

local v = {}
local Smartbone = {}
Smartbone.__index = Smartbone

function Smartbone.new(instance, rootList)
	local object = setmetatable({
		ID = random:NextInteger(1, 10000000),
		RootPart = instance,
		Time = 0,
		ParticleTrees = {},
		Connections = {},
		RootList = rootList,
		ObjectScale = UnitConversion.Convert(math.abs(instance.Size.X), "Millimeter"),
		WindPreviousPosition = createVector(0, 0, 0),
		Removed = false,
		RemovedEvent = Instance.new("BindableEvent"),
		InRange = false,
		Settings = {}
	}, Smartbone)

	for attributeName, defaultSetting in DefaultSettings do
		object.Settings[attributeName] = instance:GetAttribute(attributeName) or defaultSetting
	end

	object.Settings.BlendWeight = 1
	object.Settings.UpdateRate = math.floor(object.Settings.UpdateRate + 0.1)
	object:Init()
	object:UpdateParameters(object.Settings)
	return object
end

function Smartbone:Init()
	local rootPart = self.RootPart
	v[self.ID] = self
	self.Connections.AttributeChanged = rootPart.AttributeChanged:ConnectParallel(function(attributeName: string)
		if not self.Settings[attributeName] then
			return
		end

		self:UpdateParameters(attributeName, rootPart:GetAttribute(attributeName))
	end)
	self.Connections.LightingAttributeChanged = Lighting.AttributeChanged:ConnectParallel(function(attributeName: string)
		if not self.Settings[attributeName] then
			return
		end

		self:UpdateParameters(attributeName, Lighting:GetAttribute(attributeName))
	end)

	for _, bone in rootPart:GetDescendants() do
		if not (bone:IsA("Bone") and bone.Parent:IsA("Bone") and #bone:GetChildren() == 0) then
			continue
		end

		local worldCFrame = bone.WorldCFrame + bone.WorldCFrame.UpVector.Unit * (bone.WorldPosition - bone.Parent.WorldPosition).Magnitude
		local bone2 = Instance.new("Bone")
		bone2.Parent = bone
		bone2.Name = bone.Name .. "_Tail"
		bone2.WorldCFrame = worldCFrame
	end

	for _, v2 in self.RootList do
		self:AppendParticleTree(v2)
	end

	for _, particleTree in self.ParticleTrees do
		self:AppendParticles(particleTree, particleTree.Root, 0, 0)
	end
end

function Smartbone:AppendParticleTree(p)
	table.insert(self.ParticleTrees, ParticleTree.new(p, self.RootPart, self.Settings.Gravity))
end

function Smartbone:AppendParticles(p, instance, parentIndex: number, magnitude: number)
	local settings = self.Settings
	local v2 = Particle.new(instance, p.Root, self.RootPart, settings)
	local worldPosition = instance.WorldPosition
	local worldPosition2 = instance.WorldPosition
	v2.Position = worldPosition
	v2.LastPosition = worldPosition2
	v2.ParentIndex = parentIndex
	v2.BoneLength = magnitude
	v2.HeirarchyLength = 0

	if debug == true then
		v2.DebugPart = Instance.new("Part")
		v2.DebugPart.Size = createVector(0.1, 0.1, 0.1)
		v2.DebugPart.Anchored = true
		v2.DebugPart.CanCollide = false
		v2.DebugPart.CastShadow = false
		v2.DebugPart.CanTouch = false
		v2.DebugPart.CanQuery = false
		v2.DebugPart.Color = Color3.fromRGB(255, 0, 0)
		v2.DebugPart.Parent = model
	end

	if parentIndex >= 1 then
		magnitude = (p.Particles[parentIndex].Bone.WorldPosition - v2.Position).Magnitude
		v2.BoneLength = magnitude
		v2.Weight = magnitude * 0.7
		v2.HeirarchyLength = Utilities.GetHierarchyLength(instance, p.Root)
	end

	if v2.HeirarchyLength <= settings.AnchorDepth then
		v2.Anchored = true
	end

	table.insert(p.Particles, v2)
	local v3 = #p.Particles
	local children = instance:GetChildren()

	for i = 1, #children do
		local bone = children[i]

		if bone:IsA("Bone") then
			self:AppendParticles(p, bone, v3, magnitude)
		end
	end
end

function Smartbone:UpdateParameters(p2, p3)
	if not self.Settings[p2] then
		return
	end

	local settings = self.Settings

	if SettingsMath[p2] then
		p3 = SettingsMath[p2](p3)
	end

	settings[p2] = p3
end

function Smartbone:PreUpdate(state)
	local rootPart = state.RootPart
	local root = state.Root
	state.ObjectMove = rootPart.Position - state.ObjectPreviousPosition
	state.ObjectPreviousPosition = rootPart.Position
	state.RestGravity = root.CFrame:PointToWorldSpace(state.LocalGravity)

	for _, particle in state.Particles do
		particle.LastTransformOffset = particle.TransformOffset

		if particle.Bone == particle.Root then
			particle.TransformOffset = rootPart.CFrame * particle.RootTransform
		else
			particle.TransformOffset = root.WorldCFrame * particle.Transform
		end

		particle.LocalTransformOffset = root.CFrame * particle.LocalTransform
	end
end

function Smartbone:UpdateParticles(data, p: number, p2: number)
	local settings = self.Settings
	local damping = settings.Damping
	local gravity = settings.Gravity
	local unit = settings.Gravity.Unit
	local v2 = (gravity - unit * math.max(data.RestGravity:Dot(unit), 0) + settings.Force) * (self.ObjectScale * p)
	local v3 = p2 ~= 0 and createVector(0, 0, 0) or data.ObjectMove or createVector(0, 0, 0)

	for _, particle in data.Particles do
		if particle.ParentIndex >= 1 and particle.Anchored == false then
			local windPreviousPosition

			if settings.WindInfluence > 0 then
				local v5 = data.WindOffset + (os.clock() - particle.HeirarchyLength / 5) + (particle.TransformOffset.Position - data.Root.WorldPosition).Magnitude / 5 * settings.WindInfluence
				windPreviousPosition = Vector3.new(
					settings.WindDirection.X + settings.WindDirection.X * math.sin(v5 * settings.WindSpeed),
					settings.WindDirection.Y + math.sin(v5 * settings.WindSpeed) * 0.05,
					settings.WindDirection.Z + settings.WindDirection.X * math.sin(v5 * settings.WindSpeed)
				) / particle.BoneLength * settings.WindInfluence * (settings.WindStrength / 100 * (math.clamp(
					particle.HeirarchyLength,
					1,
					10
				) / 10)) * particle.Weight
				self.WindPreviousPosition = windPreviousPosition
			else
				windPreviousPosition = createVector(0, 0, 0)
			end

			local v5 = particle.Position - particle.LastPosition
			local v6 = v3 * settings.Inertia
			particle.LastPosition = particle.Position + v6
			particle.Position += v5 * (1 - damping) + v2 + v6 + windPreviousPosition
		else
			particle.LastPosition = particle.TransformOffset.Position
			particle.Position = particle.TransformOffset.Position
		end
	end
end

function Smartbone:CorrectParticles(p2, p3: number)
	local settings = self.Settings
	local stiffness = settings.Stiffness

	for _, particle in p2.Particles do
		local particle2 = p2.Particles[particle.ParentIndex]

		if not (particle2 and particle.ParentIndex >= 1 and particle.Anchored == false) then
			continue
		end

		local magnitude = (particle2.TransformOffset.Position - particle.TransformOffset.Position).Magnitude

		if stiffness > 0 or settings.Elasticity > 0 then
			local position = (CFrame.new(particle2.Position) * particle2.TransformOffset.Rotation * CFrame.new(particle.LocalTransformOffset.Position)).Position
			local v2 = position - particle.Position
			particle.Position += v2 * (settings.Elasticity * p3)

			if stiffness > 0 then
				local v3 = position - particle.Position
				local magnitude2 = v3.Magnitude
				local v4 = magnitude * (1 - stiffness) * 2

				if v4 < magnitude2 then
					particle.Position += v3 * ((magnitude2 - v4) / magnitude2)
				end
			end
		end

		local v2 = particle2.Position - particle.Position
		local magnitude2 = v2.Magnitude

		if magnitude2 > 0 then
			particle.Position += v2 * ((magnitude2 - magnitude) / magnitude2)
		end
	end
end

function Smartbone:SkipUpdateParticles(p2)
	for _, particle in p2.Particles do
		if particle.ParentIndex >= 1 and not particle.Anchored then
			particle.LastPosition += p2.ObjectMove
			particle.Position += p2.ObjectMove
			local particle2 = p2.Particles[particle.ParentIndex]
			local magnitude = (particle2.TransformOffset.Position - particle.TransformOffset.Position).Magnitude
			local stiffness = self.Settings.Stiffness

			if stiffness > 0 then
				local v2 = particle2.Position + CFrame.lookAt(particle2.Position, particle.Position).LookVector.Unit * (particle2.Position - particle.Position).Magnitude - particle.Position
				local magnitude2 = v2.Magnitude
				local v3 = magnitude * (1 - stiffness) * 2

				if v3 < magnitude2 then
					particle.Position += v2 * ((magnitude2 - v3) / magnitude2)
				end
			end

			local v2 = particle2.Position - particle.Position
			local magnitude2 = v2.Magnitude

			if magnitude < magnitude2 then
				particle.Position += v2 * ((magnitude2 - magnitude) / magnitude2)
			end
		else
			particle.LastPosition = particle.TransformOffset.Position
			particle.Position = particle.TransformOffset.Position
		end
	end
end

function Smartbone:CalculateTransforms(p2, p3: number)
	if self.InRange then
		for _, particle in p2.Particles do
			if not (particle.ParentIndex >= 1 and particle.Anchored == false) then
				continue
			end

			local particle2 = p2.Particles[particle.ParentIndex]
			local bone = particle2.Bone

			if not (particle2 and bone and bone:IsA("Bone") and bone ~= p2.Root) then
				continue
			end

			local position = particle2.LocalTransformOffset.Position
			local transformOffset = particle2.TransformOffset
			local pointToObjectSpace = transformOffset:PointToObjectSpace(position)
			local v2 = particle.Position - particle2.Position
			local v3 = Utilities.GetRotationBetween(transformOffset.UpVector, v2, pointToObjectSpace).Rotation * transformOffset.Rotation
			local v4 = 1 - 0.00001 ^ p3
			particle2.CalculatedWorldCFrame = bone.WorldCFrame:Lerp(CFrame.new(particle2.Position) * v3, v4)
		end
	end
end

function Smartbone.TransformBones(p, p2)
	if p.InRange then
		for _, particle in p2.Particles do
			if not (particle.ParentIndex >= 1 and particle.Anchored == false) then
				continue
			end

			local particle2 = p2.Particles[particle.ParentIndex]
			local bone = particle2.Bone

			if not (particle2 and bone and bone:IsA("Bone") and bone ~= p2.Root) then
				continue
			end

			if particle2.Anchored and p.Settings.AnchorsRotate == false then
				bone.WorldCFrame = particle2.TransformOffset
			else
				bone.WorldCFrame = particle2.CalculatedWorldCFrame
			end
		end
	end
end

function Smartbone.DEBUG(_, p)
	for _, particle in p.Particles do
		if particle then
			particle.DebugPart.CFrame = CFrame.new(particle.Position)
		end
	end
end

function Smartbone:RunLoop(p, p2: number, p3: number)
	local v2 = p2 * 10
	local v3

	if p3 > 0 then
		local v4 = 1 / p3
		self.Time += p2

		if v4 <= self.Time then
			self.Time = 0
			v3 = true
		else
			v3 = false
		end
	else
		v3 = true
	end

	if not v3 then
		self:SkipUpdateParticles(p)
		return
	end

	self:UpdateParticles(p, v2, 0)
	self:CorrectParticles(p, v2)
end

function Smartbone.ResetParticles(_, p)
	for _, particle in p.Particles do
		particle.LastPosition = particle.TransformOffset.Position
		particle.Position = particle.TransformOffset.Position
	end
end

function Smartbone.ResetTransforms(_, data)
	for _, particle in data.Particles do
		local worldCFrame

		if particle.Bone == particle.Root then
			worldCFrame = data.RootPart.CFrame * particle.RootTransform
		else
			worldCFrame = data.Root.WorldCFrame * particle.Transform
		end

		particle.Bone.WorldCFrame = worldCFrame
	end
end

function Smartbone:UpdateBones(p: number, p2: number)
	for _, particleTree in self.ParticleTrees do
		self:PreUpdate(particleTree, p)
		self:RunLoop(particleTree, p, p2)
		self:CalculateTransforms(particleTree, p)
	end
end

function Smartbone.Start()
	local localPlayer = game.Players.LocalPlayer
	local folder = Instance.new("Folder")
	folder.Name = "Actors"
	folder.Parent = localPlayer:WaitForChild("PlayerScripts")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DebugPrint(p: string)
		if debug then
			warn(p)
		end
	end

	local v2 = {}
	local parts = {}

	local function registerSmartBoneObject(part)
		if part:IsA("BasePart") and Utilities.WaitForChildOfClass(part, "Bone", 3) and game.Workspace:IsAncestorOf(part) then
			local bones = {}

			if part:GetAttribute("Roots") and part:GetAttribute("Roots") ~= nil and typeof(part:GetAttribute("Roots")) == "string" then
				local v3 = string.split(part:GetAttribute("Roots"), ",")

				for _, childName in ipairs(v3) do
					local bone = part:FindFirstChild(childName, true)

					if bone and bone:IsA("Bone") then
						table.insert(bones, bone)
					end
				end
			end

			if #bones > 0 then
				local actor = Instance.new("Actor")
				local bindableFunction = Instance.new("BindableFunction")
				bindableFunction.Name = "Event"
				bindableFunction.Parent = actor
				local clone = script.Dependencies.ActorScript:Clone()
				clone.Name = "Runtime"
				clone.Parent = actor
				actor.Parent = folder
				clone.Enabled = true
				v2[part] = actor.Event:Invoke(part, bones)
				actor.Name = part.Name .. v2[part].ID
				v2[part].RemovedEvent.Event:Once(function()
					actor.Runtime.Enabled = false
					actor:Destroy()
				end)
				table.insert(parts, part)
				DebugPrint("Created new SmartBone Object with ID: " .. v2[part].ID) -- equivalent call inferred; original call site unknown
			else
				table.insert(parts, part)
				DebugPrint("Failed to create SmartBone Object for " .. part:GetFullName() .. "! Make sure you have defined the Root Bone(s) for this object!") -- equivalent call inferred; original call site unknown
			end
		end
	end

	local function removeSmartBoneObject(p)
		if v2[p] then
			DebugPrint("Removing SmartBone Object with ID: " .. v2[p].ID) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				for _, connection in pairs(v2[p].Connections) do
					connection:Disconnect()
				end

				v2[p].SimulationConnection:Disconnect()
				task.wait()
				v2[p].RemovedEvent:Destroy()

				for _, particleTree in ipairs(v2[p].ParticleTrees) do
					for _, particle in particleTree.Particles do
						for _, v4 in particle.RecyclingBin do
							v4:Destroy()
						end
					end
				end

				task.wait()

				if v[v2[p].ID] then
					v[v2[p].ID] = nil
				end

				v2[p].Removed = true
				v2[p].RemovedEvent:Fire()
				v2[p] = nil
			end)
		end
	end

	CollectionService:GetInstanceAddedSignal("SmartBone"):Connect(registerSmartBoneObject)
	CollectionService:GetInstanceRemovedSignal("SmartBone"):Connect(removeSmartBoneObject)

	for _, v3 in pairs(tagged) do
		if v2[v3] or table.find(parts, v3) then
			continue
		end

		local v4 = v3
		task.spawn(function()
			registerSmartBoneObject(v4)
		end)
	end
end

return Smartbone