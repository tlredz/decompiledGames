local UserGameSettings = UserSettings():GetService("UserGameSettings")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("AssetService")
game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
game:GetService("CoreGui")
local Players = game:GetService("Players")
local emitter = script.Emitter
local attributes = emitter:GetAttributes()
local v = script.Parent:IsA("LocalScript") == false
local userId

if v then
	local StudioService = game:GetService("StudioService")
	userId = StudioService:GetUserId()
else
	userId = Players.LocalPlayer.UserId
end

local version = emitter:GetAttribute("Version")
local emitter2D_Version = ReplicatedStorage:GetAttribute("Emitter2D_Version")

if emitter2D_Version == nil then
	warn("Emitter2D: Waiting for ReplicatedStorage.Emitter2D_Version attribute...")
	ReplicatedStorage:GetAttributeChangedSignal("Emitter2D_Version"):Wait()
	emitter2D_Version = ReplicatedStorage:GetAttribute("Emitter2D_Version")
	warn("Emitter2D: Version found, now initializing")
end

if typeof(emitter2D_Version) ~= "number" then
	error("ReplicatedStorage.Emitter2D_Version must be a number")
end

if version < emitter2D_Version then
	error((`Cannot load Emitter2D: Version mismatch! Please update your plugin and install the new client version. ({version} vs {emitter2D_Version})`))
end

local _ = workspace.CurrentCamera.ViewportSize

local function NewSpawnRandomizers()
	return {
		Color = Random.new(),
		Depth = Random.new(),
		DepthTransparency = Random.new(),
		EmissionRate = Random.new(),
		FlipbookFramerate = Random.new(),
		FlipbookStartRandom = Random.new(),
		LifeTime = Random.new(),
		Rotation = Random.new(),
		RotationSpeed = Random.new(),
		Scale = Random.new(),
		Size = Random.new(),
		Speed = Random.new(),
		SpreadAngle = Random.new(),
		Squash = Random.new(),
		Transparency = Random.new(),
		Position = Random.new()
	}
end

local enumItems = {
	SizeConstraint = {
		"Offset",
		"RelativeYY",
		"RelativeXX",
		"RelativeMin",
		"RelativeMax"
	},
	Orientation = { "Normal", "VelocityParallel", "VelocityPerpendicular" },
	EmissionShape = { "Rectangle", "Oval", "Point" },
	EmissionShapeStyle = { "Volume", "Surface" },
	EmissionDirectionMode = { "FromUp", "FromCenter", "FromSurface" },
	ClassName = { "Emitter2D" },
	FlipbookMode = {
		"Loop",
		"OneShot",
		"PingPong",
		"Random"
	},
	FlipbookLayout = {
		"None",
		"Grid2x2",
		"Grid4x4",
		"Grid8x8"
	},
	ResampleMode = Enum.ResamplerMode
}
local v2 = {
	SilenceWarnings = true,
	EmitCount = true,
	EmitDelay = true
}
local v3 = {
	Grid2x2 = 2,
	Grid4x4 = 4,
	Grid8x8 = 8
}

for k, v4 in enumItems do
	if typeof(v4) ~= "Enum" then
		continue
	end

	local enumItems2 = v4:GetEnumItems()

	for k2, enumItem in enumItems2 do
		enumItems2[k2] = enumItem.Name
	end

	enumItems[k] = enumItems2
end

local v4 = {
	Version = function(p)
		if p == version then
			return p
		end

		return "__VERIFY_FAILED", "The version attribute cannot be changed manually."
	end,
	FlipbookResolution = function(p)
		if p < 8 or p > 1024 or math.log(p, 2) % 1 ~= 0 then
			return "__VERIFY_FAILED", "Valid FlipbookResolution Values: 8, 16, 32, 64, 128, 256, 512, 1024"
		end

		return p
	end,
	EmissionRate = function(p)
		if p.Max > 10000 then
			return "__VERIFY_FAILED", "EmissionRate is capped below 10000 (and much, much lower is recommended)"
		end

		return p
	end,
	Texture = function(p)
		local v5 = tonumber(p)

		if v5 then
			return "rbxassetid://" .. v5
		end

		return p
	end
}
local v5 = {
	{
		Version = 1.2,
		Added = {
			Paused = false,
			EmissionShapeStyle = "Volume"
		},
		Removed = { "IgnoreClipDescendants", "EasingStyle", "EasingDirection" },
		Changed = {
			EmissionShape = function(p)
				local emissionShape = p.EmissionShape

				if emissionShape == "Area" then
					return "Rectangle"
				elseif emissionShape == "Center" then
					return "Point"
				end

				return emissionShape
			end,
			IgnoreClipsDescendants = function(p)
				return p.IgnoreClipDescendants ~= nil and p.IgnoreClipDescendants
			end
		}
	},
	{
		Version = 1.21,
		Added = {
			Depth = NumberRange.new(0)
		}
	},
	{
		Version = 1.22,
		Added = {
			EmissionDirectionMode = "FromUp"
		}
	},
	{
		Version = 1.23,
		Added = {
			DepthTransparency = NumberSequence.new(0)
		}
	},
	{
		Version = 1.24,
		Added = {
			UseScreenSize = false
		}
	},
	{
		Version = 1.25,
		Added = {
			IgnoreGraphicsLevel = false
		}
	},
	{
		Version = 1.26,
		Added = {
			EmissionRateScaleByArea = false
		}
	}
}

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function reachAfterRepetition(p, p2)
	return p ^ (1 / p2)
end

local function isGuiIntersecting(p, p2, p3, p4)
	return not (p3.x > p.x + p2.x or p3.x + p4.x < p.x or p3.y > p.y + p2.y or p3.y + p4.y < p.y)
end

local function generateSequence(sequence, p: number)
	local keypoints = sequence.Keypoints

	if typeof(sequence) == "NumberSequence" then
		local result = {}

		for i = 1, #keypoints do
			local keypoint = keypoints[i]
			table.insert(result, {
				Time = keypoint.Time,
				Value = keypoint.Value + keypoint.Envelope * 2 * p
			})
		end

		return result
	elseif typeof(sequence) == "ColorSequence" then
		return keypoints
	end
end

local function evaluateSequence(p, p2, count)
	local v6 = p2[count + 1]

	while v6.Time < p do
		count += 1
		v6 = p2[count + 1]
	end

	return p2[count], v6, count
end

local function getFlipbookPosition(p, p2)
	return 1 + (p - 1) % p2, (math.ceil(p2 * p / p2 ^ 2))
end

local function getFlipbookFramesSinceStart(p, p2)
	return math.floor(p * p2) + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAngleFromDirection(p)
	local v6 = math.deg((math.atan2(p.X, -p.Y)))
	return v6 < 1e999 == false and 0 or v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDirectionFromAngle(p)
	local v6 = math.rad(p - 90)
	return Vector2.new(math.cos(v6), (math.sin(v6)))
end

local function ellipseNormalAtPoint(X, Y, p, p2)
	local halfX = X / 2
	local halfY = Y / 2
	local v8 = p / (halfX * halfX)
	local v9 = p2 / (halfY * halfY)
	local v10 = math.sqrt(v8 * v8 + v9 * v9)
	return v8 / v10, v9 / v10
end

local function verifyAttribute(attributeName, p)
	if v2[attributeName] then
		return p
	end

	local callback = v4[attributeName]

	if callback then
		local v6
		p, v6 = callback(p)

		if p == "__VERIFY_FAILED" then
			return "__VERIFY_FAILED", v6
		end
	end

	local v6 = enumItems[attributeName]

	if v6 and not table.find(v6, p) then
		return "__VERIFY_FAILED", "InvalidEnum"
	end

	if typeof(p) == typeof(attributes[attributeName]) then
		return p
	end

	return "__VERIFY_FAILED", "InvalidType"
end

local function migrateAttributes(p)
	for _, v6 in v5 do
		if not (typeof(p.Version) ~= "number" or p.Version < v6.Version) then
			continue
		end

		local added = v6.Added

		if added then
			for k, v7 in added do
				p[k] = v7
			end
		end

		local changed = v6.Changed

		if changed then
			for k, callback in changed do
				local success, result = pcall(callback, p)

				if success then
					p[k] = result
				else
					error((`Failed to change attribute '{k}' during migration to version {v6.Version}:\n{tostring(result)}`))
				end
			end
		end

		local removed = v6.Removed

		if removed then
			for _, v7 in removed do
				p[v7] = nil
			end
		end

		p.Version = v6.Version
	end

	p.Version = emitter:GetAttribute("Version")
end

local v6 = {
	EmissionShape = "Area",
	FlipbookResolution = 1024,
	IgnoreClipsDescendants = false,
	FlipbookFramerate = NumberRange.new(20),
	SizeConstraint = "RelativeYY",
	ZIndex = 1,
	FlipbookLayout = "None",
	SpreadAngle = 45,
	Transparency = NumberSequence.new(0),
	UseJitterFix = true,
	ClassName = "Emitter2D",
	Orientation = "Normal",
	Color = ColorSequence.new(Color3.new(0, 0, 0)),
	Drag = 0,
	EmissionRate = NumberRange.new(10),
	TimeScale = 1,
	FlipbookMode = "OneShot",
	Squash = NumberSequence.new(0.5),
	Speed = NumberRange.new(400),
	Version = 0,
	VelocityInheritance = 0,
	Size = NumberRange.new(300),
	Enabled = true,
	Acceleration = Vector2.new(0, 1000),
	Texture = "rbxassetid://867619398",
	Scale = NumberSequence.new(1),
	FlipbookStartRandom = false,
	Rotation = NumberRange.new(0),
	MasterScale = 1,
	LockedToGui = false,
	EmissionDirection = 0,
	ResampleMode = "Default",
	Paused = false,
	RotationSpeed = NumberRange.new(0),
	LifeTime = NumberRange.new(0.3, 0.7)
}
local version2 = 0

for k, v7 in v5 do
	migrateAttributes(v6)

	if v7.Version <= version2 then
		error((`Version lower or equal to previous, did you forget to change it? [Migration #{k}, v{v7.Version} <= v{version2}]`))
	elseif version < v7.Version then
		error((`Version higher than installed version, did you forget to update the config version attribute? [Migration #{k}, v{v7.Version} <= v{version}]`))
	end

	version2 = v7.Version
end

for k, v7 in emitter:GetAttributes() do
	if typeof(v7) ~= typeof(v6[k]) then
		error((`Final migration check type mismatch for attribute '{k}': [{typeof(v6[k])} ~= {typeof(v7)}]`))
	end
end

local Emitter2D = {}
Emitter2D.__index = Emitter2D

function Emitter2D.__tostring(p)
	return (`Emitter2D [{p.Config:GetFullName()}]`)
end

if v == false then
	StarterGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end

Emitter2D.PlayerGui = StarterGui
Emitter2D.GlobalEnabled = true
Emitter2D.GlobalEvents = {}
Emitter2D.Particles = {}
Emitter2D.ParticleFolders = {}
Emitter2D.EntityList = nil

function Emitter2D.new()
	return (setmetatable({}, Emitter2D))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetReferenceHeight(p, p2)
	if p2.Parent ~= p then
		return 0
	end

	local value = p2.Value

	if value and value:IsA("GuiObject") and value.Parent then
		return value.AbsoluteSize.Y
	end

	return 0
end

function Emitter2D:ClearScreenReference()
	self.ScreenReferenceAncestor = nil
	self.ScreenReferenceValue = nil
	self.ScreenReferenceRetryAt = nil
end

function Emitter2D:GetScreenSize()
	local viewportSize = workspace.CurrentCamera.ViewportSize

	if not self.BillboardGui then
		return viewportSize
	end

	local screenReferenceAncestor = self.ScreenReferenceAncestor

	if screenReferenceAncestor then
		local referenceHeight = GetReferenceHeight(screenReferenceAncestor, self.ScreenReferenceValue) -- equivalent call inferred; original call site unknown

		if referenceHeight > 0 then
			return viewportSize * (screenReferenceAncestor.AbsoluteSize.Y / referenceHeight)
		else
			self:ClearScreenReference()
		end
	elseif self.ScreenReferenceRetryAt and os.clock() < self.ScreenReferenceRetryAt then
		return self.BillboardGui.AbsoluteSize
	end

	local parent = self.Config.Parent

	while parent and parent ~= self.BillboardGui do
		local emitter2DReference = parent:FindFirstChild("Emitter2DReference")

		if parent:IsA("GuiObject") and emitter2DReference and emitter2DReference:IsA("ObjectValue") then
			local referenceHeight = GetReferenceHeight(parent, emitter2DReference) -- equivalent call inferred; original call site unknown

			if referenceHeight > 0 then
				self.ScreenReferenceAncestor = parent
				self.ScreenReferenceValue = emitter2DReference
				self.ScreenReferenceRetryAt = nil
				return viewportSize * (parent.AbsoluteSize.Y / referenceHeight)
			end
		end

		parent = parent.Parent
	end

	self.ScreenReferenceRetryAt = os.clock() + 0.25
	return self.BillboardGui.AbsoluteSize
end

function Emitter2D:Initiate(instance2)
	self.Config = instance2
	local version3 = instance2:GetAttribute("Version")

	if typeof(version3) == "number" and version < version3 then
		error(tostring(self) .. ` Cannot load emitter from a newer version. Please update the plugin and install the new client! ({instance2:GetAttribute("Version")} > {version})`)
	end

	self.ValidAncestry = false
	self.Events = {}
	self.Bindables = {}
	self.Cache = {}
	self.CacheCount = 0
	self.Particles = {}
	self.ParticleCount = 0
	self.Time = 0
	self.NextSpawn = 0
	self.LastPosition = nil
	self.LastRotation = nil
	local folder = Instance.new("Folder")
	folder.Name = "Particles_" .. instance2.Name
	folder.Archivable = false
	folder:AddTag("Emitter2D_ParticleFolder")
	folder:SetAttribute("Owner", userId)
	local frame = Instance.new("Frame")
	frame.Name = "ParticleFrame"
	frame.Interactable = false
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = folder
	self.Events.ParticleFolderDestroyed = folder.Destroying:Connect(function()
		self:Destroy()
	end)
	self.Events.ConfigNameChanged = instance2:GetPropertyChangedSignal("Name"):Connect(function()
		folder.Name = "Particles_" .. instance2.Name
	end)
	self.ParticleFolder = folder
	self.ParticleFrame = frame
	Emitter2D.ParticleFolders[folder] = instance2
	folder.Parent = instance2
	self.FolderParent = instance2
	local attributes2 = instance2:GetAttributes()
	migrateAttributes(attributes2)

	for k in instance2:GetAttributes() do
		if attributes2[k] == nil then
			instance2:SetAttribute(k, nil)
		end
	end

	for k, attribute in attributes2 do
		instance2:SetAttribute(k, attribute)
	end

	local function updateAttribute(attributeName, p)
		local v7 = p or instance2:GetAttribute(attributeName)
		local v8, v9 = verifyAttribute(attributeName, v7)

		if v8 == "__VERIFY_FAILED" then
			local attribute = attributes[attributeName]

			if not attributes2.SilenceWarnings then
				if v9 == "InvalidEnum" then
					warn(tostring(self) .. ` '{tostring(v7)}' is not a valid value for attribute '{attributeName}'`)
					warn((`Valid values for {attributeName} are '{table.concat(enumItems[attributeName], "', '")}'`))
				elseif v9 == "InvalidType" then
					warn(tostring(self) .. ` '{typeof(v7)}' is not a valid type for attribute '{attributeName}'`)
				else
					warn(tostring(self) .. ` Invalid value for attribute '{attributeName}'` .. (not v9 and "" or `: {v9}`))
				end

				warn((`Attribute has been reset to default value. ({tostring(attribute)})`))
			end

			instance2:SetAttribute(attributeName, attribute)
		else
			if v8 == v7 then
				attributes2[attributeName] = v7
				return
			end

			if v9 then
				warn(tostring(self) .. ` {v9}`)
			end

			instance2:SetAttribute(attributeName, v8)
		end
	end

	self.Events.AttributeChanged = instance2.AttributeChanged:Connect(updateAttribute)
	updateAttribute("Version")

	for k, attribute in attributes2 do
		if k ~= "Version" then
			updateAttribute(k, attribute)
		end
	end

	for k, v7 in emitter:GetAttributes() do
		if attributes2[k] ~= nil then
			continue
		end

		warn(("%s Missing attribute '%s', value has been set to default (%s)"):format(tostring(self), k, (tostring(v7))))
		instance2:SetAttribute(k, v7)
	end

	self.Attributes = attributes2
	self.SpawnRandomizers = NewSpawnRandomizers()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		self.Time = 0
		self.NextSpawn = attributes2.EmissionRate.Min > 0 and 0 or 1e999
	end

	fn() -- equivalent call inferred; original call site unknown
	self.Events.RateChanged = instance2:GetAttributeChangedSignal("EmissionRate"):Connect(fn)
	self.Events.EnabledChanged = instance2:GetAttributeChangedSignal("Enabled"):Connect(fn)
	self.Events.TimeScaleChanged = instance2:GetAttributeChangedSignal("TimeScale"):Connect(fn)

	local function UpdateRenderable()
		local guiObject = instance2:FindFirstAncestorWhichIsA("GuiObject")
		local layerCollector = instance2:FindFirstAncestorWhichIsA("LayerCollector")
		self.ParentGui = guiObject
		local v7 = self
		local billboardGui

		if layerCollector and layerCollector:IsA("BillboardGui") then
			billboardGui = layerCollector
		end

		v7.BillboardGui = billboardGui
		self:ClearScreenReference()
		self.ScreenSize = self:GetScreenSize()
		local validAncestry = guiObject ~= nil and layerCollector ~= nil and (instance2:IsDescendantOf(Emitter2D.PlayerGui) ~= false or instance2:IsDescendantOf(workspace) ~= false)

		if validAncestry then
			local parent = instance2.Parent
			local isA = layerCollector:IsA("BillboardGui")

			if not isA then
				isA = layerCollector:IsA("SurfaceGui")
			end

			while parent ~= nil and (parent ~= layerCollector or not isA) do
				if parent:IsA("GuiBase2d") or parent:IsA("Folder") then
					parent = parent.Parent
				else
					if parent == Emitter2D.PlayerGui or parent == workspace then
						break
					end

					validAncestry = false
					break
				end
			end
		end

		if validAncestry then
			fn() -- equivalent call inferred; original call site unknown
			self.ZIndexBehavior = layerCollector.ZIndexBehavior
			self.AbsoluteRotation = guiObject.AbsoluteRotation
			self.AbsolutePosition = guiObject.AbsolutePosition
			self.AbsoluteSize = guiObject.AbsoluteSize
			self.LastPosition = nil
			self.LastRotation = nil

			if self.AncestorEvents then
				for _, ancestorEvent in self.AncestorEvents do
					for _, connection in ancestorEvent do
						connection:Disconnect()
					end
				end
			end

			self.AncestorEvents = {}
			self.NotVisibleCount = 0
			self.ClipCount = 0
			local parent = guiObject

			while parent do
				if parent:IsA("GuiObject") or parent:IsA("LayerCollector") then
					local v10 = {}
					local flag = true

					-- equivalent calls inferred from this helper; original call sites unknown
					local function UpdateVisible(flag2: boolean)
						if flag2 then
							if flag == false then
								flag = true
								self.NotVisibleCount -= 1
							end
						elseif flag == true then
							flag = false
							self.NotVisibleCount += 1
						end
					end

					if parent:IsA("GuiObject") then
						local v11 = parent
						v10.VisibleChanged = parent:GetPropertyChangedSignal("Visible"):Connect(function()
							if v11.Visible then
								UpdateVisible(true) -- equivalent call inferred; original call site unknown
							else
								UpdateVisible(false) -- equivalent call inferred; original call site unknown
							end
						end)

						if parent.Visible then
							UpdateVisible(true) -- equivalent call inferred; original call site unknown
						else
							UpdateVisible(false) -- equivalent call inferred; original call site unknown
						end
					elseif parent:IsA("LayerCollector") then
						local v11 = parent
						v10.VisibleChanged = parent:GetPropertyChangedSignal("Enabled"):Connect(function()
							if v11.Enabled then
								UpdateVisible(true) -- equivalent call inferred; original call site unknown
							else
								UpdateVisible(false) -- equivalent call inferred; original call site unknown
							end
						end)
						local v12 = parent
						v10.ZIndexBehaviorChanged = parent:GetPropertyChangedSignal("ZIndexBehavior"):Connect(function()
							self.ZIndexBehavior = v12.ZIndexBehavior
						end)

						if parent.Enabled then
							UpdateVisible(true) -- equivalent call inferred; original call site unknown
						else
							UpdateVisible(false) -- equivalent call inferred; original call site unknown
						end
					end

					if parent ~= guiObject and attributes2.IgnoreClipsDescendants == false and parent:IsA("GuiObject") then
						local flag2 = false
						-- equivalent calls inferred from this helper; original call sites unknown
						local v11 = parent

						local function CheckClipped()
							local absolutePosition = guiObject.AbsolutePosition
							local absoluteSize = guiObject.AbsoluteSize
							local absolutePosition2 = v11.AbsolutePosition
							local absoluteSize2 = v11.AbsoluteSize
							local v12 = absolutePosition2.x > absolutePosition.x + absoluteSize.x or absolutePosition2.x + absoluteSize2.x < absolutePosition.x or absolutePosition2.y > absolutePosition.y + absoluteSize.y or absolutePosition2.y + absoluteSize2.y < absolutePosition.y

							if flag2 ~= (v12 and true or false) then
								if flag2 then
									flag2 = false
									self.ClipCount -= 1
								else
									flag2 = true
									self.ClipCount += 1
								end
							end
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local v12 = v10

						local function DisconnectClipEvents()
							if v12.SizeChanged then
								v12.SizeChanged:Disconnect()
								v12.SizeChanged = nil
							end

							if v12.ParentPositionChanged then
								v12.ParentPositionChanged:Disconnect()
								v12.ParentPositionChanged = nil
							end

							if v12.PositionChanged then
								v12.PositionChanged:Disconnect()
								v12.PositionChanged = nil
							end
						end

						local v13 = v10
						local guiObject2 = parent
						local CheckClipped2 = CheckClipped

						local function UpdateClipsDescendants()
							DisconnectClipEvents() -- equivalent call inferred; original call site unknown

							if guiObject2:IsA("GuiObject") == false or guiObject2.ClipsDescendants then
								v13.SizeChanged = guiObject2:GetPropertyChangedSignal("AbsoluteSize"):Connect(CheckClipped2)
								v13.ParentPositionChanged = guiObject:GetPropertyChangedSignal("AbsolutePosition"):Connect(CheckClipped2)
								v13.PositionChanged = guiObject2:GetPropertyChangedSignal("AbsolutePosition"):Connect(CheckClipped2)
								CheckClipped2() -- equivalent call inferred; original call site unknown
							elseif flag2 then
								flag2 = false
								self.ClipCount -= 1
							end
						end

						v10.ClipsDescendantsChanged = parent:GetPropertyChangedSignal("ClipsDescendants"):Connect(UpdateClipsDescendants)
						UpdateClipsDescendants()
					end

					self.AncestorEvents[parent] = v10
				end

				parent = parent.Parent
			end
		else
			if self.AncestorEvents then
				for _, ancestorEvent in self.AncestorEvents do
					for _, connection in ancestorEvent do
						connection:Disconnect()
					end
				end

				self.AncestorEvents = nil
			end

			self:ClearAllParticles()

			if not instance2:IsDescendantOf(Emitter2D.PlayerGui) then
				instance2:IsDescendantOf(workspace)
			end
		end

		self.ValidAncestry = validAncestry
	end

	self.Events.AncestryChanged = instance2.AncestryChanged:Connect(UpdateRenderable)
	self.Events.IgnoreClipsDescendantsChanged = instance2:GetAttributeChangedSignal("IgnoreClipsDescendants"):Connect(UpdateRenderable)
	UpdateRenderable()
	local emit = instance2:FindFirstChild("Emit") or Instance.new("BindableEvent")
	self.Events.EmitFired = emit.Event:Connect(function(value)
		if not self.ValidAncestry then
			warn(tostring(self) .. "Cannot emit particles while emitter is inactive. Make sure the emitter is parented to a gui in the players PlayerGui.")
			return
		end

		for _ = 1, value or 1 do
			self:SpawnParticle()
		end
	end)
	emit.Name = "Emit"
	emit.Archivable = false
	emit.Parent = instance2
	table.insert(self.Bindables, emit)
	local timeStep = instance2:FindFirstChild("TimeStep") or Instance.new("BindableEvent")
	self.Events.TimeStepFired = timeStep.Event:Connect(function(p)
		if self.ValidAncestry then
			self:Update(p)
		else
			warn(tostring(self) .. "Cannot update time while emitter is inactive. Make sure the emitter is parented to a gui in the players PlayerGui.")
		end
	end)
	timeStep.Name = "TimeStep"
	timeStep.Archivable = false
	timeStep.Parent = instance2
	table.insert(self.Bindables, timeStep)
	local setSeeds = instance2:FindFirstChild("SetSeeds") or Instance.new("BindableEvent")
	self.Events.SetSeedsFired = setSeeds.Event:Connect(function(items)
		assert(
			typeof(items) == "table",
			"First argument must be a table of seeds with the keys being the seed names and the values being the seed number."
		)
		local flag = false

		for k, item in items do
			if self.SpawnRandomizers[k] then
				self.SpawnRandomizers[k] = Random.new(item)
			else
				warn((`Failed to set seed: '{tostring(k)}' is not a valid seed key!`))
				flag = true
			end
		end

		if flag then
			local v7 = ""

			for k, _ in self.SpawnRandomizers do
				v7 ..= `{k}, `
			end

			warn((`Valid seed keys: {v7:sub(1, -3)}`))
		end
	end)
	setSeeds.Name = "SetSeeds"
	setSeeds.Archivable = false
	setSeeds.Parent = instance2
	table.insert(self.Bindables, setSeeds)
	local clear = instance2:FindFirstChild("Clear") or Instance.new("BindableEvent")
	self.Events.ClearFired = clear.Event:Connect(function()
		self:ClearAllParticles()
	end)
	clear.Name = "Clear"
	clear.Archivable = false
	clear.Parent = instance2
	table.insert(self.Bindables, clear)
	Emitter2D.Particles[instance2] = self
end

function Emitter2D:SpawnParticle(vector, velocity)
	local attributes2 = self.Attributes
	local spawnRandomizers = self.SpawnRandomizers
	local emissionDirection = attributes2.EmissionDirection
	local parent = self.Config.Parent
	local particleGui = self.Cache[self.CacheCount]

	if particleGui then
		self.Cache[self.CacheCount] = nil
		self.CacheCount -= 1
	else
		particleGui = Instance.new("ImageLabel")
	end

	particleGui.Name = "Particle"
	particleGui.Image = attributes2.Texture
	particleGui.Archivable = false
	particleGui.Interactable = false
	particleGui.BackgroundTransparency = 1
	particleGui.AnchorPoint = Vector2.new(0.5, 0.5)
	particleGui.ResampleMode = Enum.ResamplerMode[attributes2.ResampleMode]
	local v8 = {
		ParticleGui = particleGui,
		ParentGui = parent,
		Events = {},
		Time = 0,
		Position = vector,
		Velocity = velocity,
		Size = attributes2.Size.Min + (attributes2.Size.Max - attributes2.Size.Min) * spawnRandomizers.Size:NextNumber(),
		Depth = attributes2.Depth.Min + (attributes2.Depth.Max - attributes2.Depth.Min) * spawnRandomizers.Depth:NextNumber(),
		LifeTime = attributes2.LifeTime.Min + (attributes2.LifeTime.Max - attributes2.LifeTime.Min) * spawnRandomizers.LifeTime:NextNumber(),
		Rotation = attributes2.Rotation.Min + (attributes2.Rotation.Max - attributes2.Rotation.Min) * spawnRandomizers.Rotation:NextNumber(),
		RotationSpeed = attributes2.RotationSpeed.Min + (attributes2.RotationSpeed.Max - attributes2.RotationSpeed.Min) * spawnRandomizers.RotationSpeed:NextNumber()
	}

	if vector == nil then
		local _ = self.AbsoluteRotation
		local _ = self.AbsolutePosition
		local absoluteSize = self.AbsoluteSize
		local position = spawnRandomizers.Position

		if attributes2.EmissionShape == "Rectangle" then
			if attributes2.EmissionShapeStyle == "Volume" then
				vector = Vector2.new(absoluteSize.X * position:NextNumber(), absoluteSize.Y * position:NextNumber())
			elseif attributes2.EmissionShapeStyle == "Surface" then
				local v9 = position:NextNumber() <= absoluteSize.Y / (absoluteSize.X + absoluteSize.Y)
				local integer = position:NextInteger(0, 1)
				local v10

				if v9 then
					v10 = absoluteSize.X * integer
				else
					v10 = absoluteSize.X * position:NextNumber()
				end

				local v11

				if v9 then
					v11 = absoluteSize.Y * position:NextNumber()
				else
					v11 = absoluteSize.Y * integer
				end

				vector = Vector2.new(v10, v11)

				if attributes2.EmissionDirectionMode == "FromSurface" then
					if v9 then
						if integer == 0 then
							emissionDirection -= 90
						else
							emissionDirection += 90
						end
					elseif integer == 0 then
						emissionDirection += 0
					else
						emissionDirection += 180
					end
				end
			else
				error(tostring(self) .. "Invalid EmissionShapeStyle")
			end
		elseif attributes2.EmissionShape == "Point" then
			vector = absoluteSize * 0.5

			if attributes2.EmissionDirectionMode == "FromSurface" then
				emissionDirection += spawnRandomizers.Rotation:NextNumber(0, 360)
			end
		elseif attributes2.EmissionShape == "Oval" then
			local v9 = math.rad(360 * position:NextNumber())
			local v10 = attributes2.EmissionShapeStyle ~= "Volume" and 0.5 or 0.5 * position:NextNumber() ^ 0.5
			vector = absoluteSize * Vector2.new(0.5 + math.cos(v9) * v10, 0.5 + math.sin(v9) * v10)

			if attributes2.EmissionDirectionMode == "FromSurface" then
				emissionDirection += getAngleFromDirection(Vector2.new(ellipseNormalAtPoint(
					absoluteSize.X,
					absoluteSize.Y,
					vector.X - absoluteSize.X / 2,
					vector.Y - absoluteSize.Y / 2
				)))
			end
		else
			error(tostring(self) .. "Invalid EmissionShape")
		end

		v8.Position = vector
	end

	if attributes2.EmissionDirectionMode == "FromCenter" then
		emissionDirection += getAngleFromDirection((v8.Position - parent.AbsoluteSize / 2).Unit)
	end

	if velocity == nil then
		local v9 = attributes2.SpreadAngle * (spawnRandomizers.SpreadAngle:NextNumber() - 0.5) * 2
		local v10 = math.rad(emissionDirection - 90 + v9)
		local v11 = attributes2.Speed.Min + (attributes2.Speed.Max - attributes2.Speed.Min) * spawnRandomizers.Speed:NextNumber()
		v8.Velocity = Vector2.new(math.cos(v10) * v11, math.sin(v10) * v11)
	end

	local flipbookFramerate = attributes2.FlipbookFramerate
	v8.FlipbookFramerate = flipbookFramerate.Min + spawnRandomizers.FlipbookFramerate:NextNumber() * (flipbookFramerate.Max - flipbookFramerate.Min)

	if attributes2.FlipbookStartRandom then
		v8.FlipbookStartFrame = spawnRandomizers.FlipbookStartRandom:NextNumber(1, v3[attributes2.FlipbookLayout])
	else
		v8.FlipbookStartFrame = 1
	end

	v8.FlipbookFrame = v8.FlipbookStartFrame
	v8.ScaleSequence = generateSequence(attributes2.Scale, spawnRandomizers.Scale:NextNumber())
	v8.ScaleSequenceIndex = 1
	v8.SquashSequence = generateSequence(attributes2.Squash, spawnRandomizers.Squash:NextNumber())
	v8.SquashSequenceIndex = 1
	v8.TransparencySequence = generateSequence(attributes2.Transparency, spawnRandomizers.Transparency:NextNumber())
	v8.TransparencySequenceIndex = 1
	v8.ColorSequence = generateSequence(attributes2.Color, spawnRandomizers.Color:NextNumber())
	v8.ColorSequenceIndex = 1

	if attributes2.Depth.Min ~= attributes2.Depth.Max then
		v8.DepthTransparencySequence = generateSequence(
			attributes2.DepthTransparency,
			spawnRandomizers.DepthTransparency:NextNumber()
		)
		v8.DepthTransparencySequenceIndex = 1
	end

	self.Particles[particleGui] = v8
	self.ParticleCount += 1

	if v then
		particleGui:AddTag("Emitter2D_Particle")
	end

	return v8
end

function Emitter2D:UpdateParticle(state, p)
	local attributes2 = self.Attributes
	local particleGui = state.ParticleGui
	local _ = state.ParentGui
	local masterScale = attributes2.MasterScale
	local masterScale2 = attributes2.MasterScale
	local depth = state.Depth

	if depth ~= 0 then
		local v7

		if depth > 0 then
			v7 = 1 / (depth + 1)
		else
			v7 = -depth + 1
		end

		masterScale *= v7
		masterScale2 *= v7
	end

	state.Time += p
	local v7 = state.Time / state.LifeTime

	if v7 > 1 then
		return self:RemoveParticle(state)
	end

	if self.AbsoluteRotation == 0 then
		state.Velocity += attributes2.Acceleration * p
	else
		state.Velocity += self.WorldRight * (attributes2.Acceleration.X * p)
		state.Velocity += self.WorldDown * (attributes2.Acceleration.Y * p)
	end

	local velocity = state.Velocity
	local v8

	if attributes2.Drag == 0 then
		v8 = 1
	elseif attributes2.Drag > 0 then
		v8 = 0.5 ^ (1 / (1 / p / attributes2.Drag))
	else
		v8 = 1.5 ^ (1 / (1 / p / -attributes2.Drag))
	end

	state.Velocity = velocity * v8

	if self.BillboardGui and attributes2.UseScreenSize then
		local screenSize = self.ScreenSize
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local sizeConstraint = attributes2.SizeConstraint

		if sizeConstraint == "RelativeXX" then
			masterScale2 *= screenSize.X / math.max(viewportSize.X, 1)
		elseif sizeConstraint == "RelativeYY" then
			masterScale2 *= screenSize.Y / math.max(viewportSize.Y, 1)
		elseif sizeConstraint == "RelativeMin" then
			masterScale2 *= math.min(screenSize.X, screenSize.Y) / math.max(math.min(viewportSize.X, viewportSize.Y), 1)
		elseif sizeConstraint == "RelativeMax" then
			masterScale2 *= math.max(screenSize.X, screenSize.Y) / math.max(math.max(viewportSize.X, viewportSize.Y), 1)
		end
	end

	state.Position += state.Velocity * masterScale2 * p

	if self.BillboardGui and attributes2.LockedToGui then
		local absoluteSize = self.AbsoluteSize
		particleGui.Position = UDim2.fromScale(
			not (absoluteSize.X > 0) and 0 or state.Position.X / absoluteSize.X,
			not (absoluteSize.Y > 0) and 0 or state.Position.Y / absoluteSize.Y
		)
	elseif self.BillboardGui then
		particleGui.Position = UDim2.fromOffset(state.Position.X, state.Position.Y)
	else
		particleGui.Position = UDim2.fromOffset(math.round(state.Position.X), (math.round(state.Position.Y)))
	end

	state.Rotation += state.RotationSpeed * p

	if attributes2.Orientation == "Normal" then
		particleGui.Rotation = state.Rotation
	elseif attributes2.Orientation == "VelocityParallel" then
		particleGui.Rotation = state.Rotation + getAngleFromDirection(state.Velocity.Unit) + 90
	elseif attributes2.Orientation == "VelocityPerpendicular" then
		particleGui.Rotation = state.Rotation + getAngleFromDirection(state.Velocity.Unit)
	else
		error(tostring(self) .. "Invalid Orientation")
	end

	local squashSequence = state.SquashSequence
	local squashSequenceIndex = state.SquashSequenceIndex
	local v9 = squashSequence[squashSequenceIndex + 1]

	while v9.Time < v7 do
		squashSequenceIndex += 1
		v9 = squashSequence[squashSequenceIndex + 1]
	end

	local v10 = squashSequence[squashSequenceIndex]
	state.SquashSequenceIndex = squashSequenceIndex
	local v11 = (v7 - v10.Time) / (v9.Time - v10.Time)
	local v12 = 6 * (v10.Value + (v9.Value - v10.Value) * v11 - 0.5)
	local scaleSequence = state.ScaleSequence
	local scaleSequenceIndex = state.ScaleSequenceIndex
	local v13 = scaleSequence[scaleSequenceIndex + 1]

	while v13.Time < v7 do
		scaleSequenceIndex += 1
		v13 = scaleSequence[scaleSequenceIndex + 1]
	end

	local v14 = scaleSequence[scaleSequenceIndex]
	state.ScaleSequenceIndex = scaleSequenceIndex
	local v15 = (v7 - v14.Time) / (v13.Time - v14.Time)
	local v16 = (v14.Value + (v13.Value - v14.Value) * v15) * state.Size * masterScale
	local absoluteSize = self.AbsoluteSize

	if attributes2.UseScreenSize then
		if self.BillboardGui then
			absoluteSize = self.ScreenSize
		else
			absoluteSize = workspace.CurrentCamera.ViewportSize
		end
	end

	if attributes2.SizeConstraint == "RelativeXX" then
		local X = absoluteSize.X
		masterScale2 *= X / 150
		v16 *= X / 150
	elseif attributes2.SizeConstraint == "RelativeYY" then
		local Y = absoluteSize.Y
		masterScale2 *= Y / 150
		v16 *= Y / 150
	elseif attributes2.SizeConstraint == "RelativeMin" then
		local v17 = math.min(absoluteSize.X, absoluteSize.Y)
		masterScale2 *= v17 / 150
		v16 *= v17 / 150
	elseif attributes2.SizeConstraint == "RelativeMax" then
		local v17 = math.max(absoluteSize.X, absoluteSize.Y)
		masterScale2 *= v17 / 150
		v16 *= v17 / 150
	end

	local v17 = math.abs(v12) + 1
	local v18 = 1 / v17
	local vector

	if v12 >= 0 then
		vector = Vector2.new(v16 * v18, v16 * v17)
	else
		vector = Vector2.new(v16 * v17, v16 * v18)
	end

	if attributes2.UseJitterFix then
		particleGui.Size = UDim2.fromOffset(math.round(vector.X / 2) * 2 + -1, math.round(vector.Y / 2) * 2 + -1)
	else
		particleGui.Size = UDim2.fromOffset(math.round(vector.X), (math.round(vector.Y)))
	end

	local v19

	if state.DepthTransparencySequence then
		local depthTransparencySequence = state.DepthTransparencySequence
		local depthTransparencySequenceIndex = state.DepthTransparencySequenceIndex
		local v20 = depthTransparencySequence[depthTransparencySequenceIndex + 1]

		while v20.Time < v7 do
			depthTransparencySequenceIndex += 1
			v20 = depthTransparencySequence[depthTransparencySequenceIndex + 1]
		end

		local v21 = depthTransparencySequence[depthTransparencySequenceIndex]
		state.DepthTransparencySequenceIndex = depthTransparencySequenceIndex
		local v22 = (v7 - v21.Time) / (v20.Time - v21.Time)
		local v23 = v21.Value + (v20.Value - v21.Value) * v22
		local depth2 = attributes2.Depth
		v19 = v23 * ((state.Depth - depth2.Min) / (depth2.Max - depth2.Min))
	else
		v19 = 0
	end

	local transparencySequence = state.TransparencySequence
	local transparencySequenceIndex = state.TransparencySequenceIndex
	local v20 = transparencySequence[transparencySequenceIndex + 1]

	while v20.Time < v7 do
		transparencySequenceIndex += 1
		v20 = transparencySequence[transparencySequenceIndex + 1]
	end

	local v21 = transparencySequence[transparencySequenceIndex]
	state.TransparencySequenceIndex = transparencySequenceIndex
	local v22 = (v7 - v21.Time) / (v20.Time - v21.Time)
	local v23 = v21.Value + (v20.Value - v21.Value) * v22
	particleGui.ImageTransparency = v23 + (1 - v23) * v19
	local colorSequence = state.ColorSequence
	local colorSequenceIndex = state.ColorSequenceIndex
	local v24 = colorSequence[colorSequenceIndex + 1]

	while v24.Time < v7 do
		colorSequenceIndex += 1
		v24 = colorSequence[colorSequenceIndex + 1]
	end

	local v25 = colorSequence[colorSequenceIndex]
	state.ColorSequenceIndex = colorSequenceIndex
	local v26 = (v7 - v25.Time) / (v24.Time - v25.Time)
	particleGui.ImageColor3 = v25.Value:Lerp(v24.Value, v26)
	local flipbookLayout = attributes2.FlipbookLayout

	if flipbookLayout == "None" then
		particleGui.ImageRectSize = Vector2.zero
		particleGui.ImageRectOffset = Vector2.zero
	else
		local flipbookMode = attributes2.FlipbookMode
		local flipbookResolution = attributes2.FlipbookResolution
		local v27 = v3[flipbookLayout]
		local v28 = v27 ^ 2
		local v29 = flipbookResolution / v27
		local flipbookFrame = state.FlipbookFrame
		local flipbookStartFrame = state.FlipbookStartFrame

		if flipbookMode == "OneShot" then
			flipbookFrame = flipbookStartFrame + math.ceil(v7 * (1 + v28 - flipbookStartFrame)) - 1
		elseif flipbookMode == "Loop" then
			flipbookFrame = 1 + (flipbookStartFrame + (math.floor(state.Time * state.FlipbookFramerate) + 1) - 1) % v28
		elseif flipbookMode == "Random" then
			local v30 = math.floor(state.Time * state.FlipbookFramerate) + 1

			if math.floor((state.Time - p) * state.FlipbookFramerate) + 1 ~= v30 then
				flipbookFrame = math.random(1, v28)
			end
		elseif flipbookMode == "PingPong" then
			local v30 = flipbookStartFrame + (math.floor(state.Time * state.FlipbookFramerate) + 1)
			flipbookFrame = 1 + (v30 - 1) % v28

			if math.floor((v30 - 1) / v28) % 2 == 1 then
				flipbookFrame = 1 + (v28 - flipbookFrame)
			end
		end

		local v30 = 1 + (flipbookFrame - 1) % v27
		local v31 = math.ceil(v27 * flipbookFrame / v27 ^ 2)
		particleGui.ImageRectSize = Vector2.new(v29, v29)
		particleGui.ImageRectOffset = Vector2.new((v30 - 1) * v29, (v31 - 1) * v29)
		state.FlipbookFrame = flipbookFrame
	end

	particleGui.Visible = true
	particleGui.ZIndex = attributes2.ZIndex
	particleGui.Parent = self.ParticleFrame
end

function Emitter2D:Update(p)
	local attributes2 = self.Attributes
	local parentGui = self.ParentGui
	self.Time += p
	local absoluteRotation = parentGui.AbsoluteRotation
	local absolutePosition = parentGui.AbsolutePosition
	local absoluteSize = parentGui.AbsoluteSize
	self.AbsoluteRotation = absoluteRotation
	self.AbsolutePosition = absolutePosition
	self.AbsoluteSize = absoluteSize
	self.ScreenSize = self:GetScreenSize()
	local v7

	if self.LastPosition and absolutePosition ~= self.LastPosition then
		v7 = absolutePosition - self.LastPosition
	end

	local v8

	if self.LastRotation and absoluteRotation ~= self.LastRotation then
		v8 = absoluteRotation - self.LastRotation
	end

	local vector

	if self.LastSize and absoluteSize ~= self.LastSize then
		vector = Vector2.new(absoluteSize.X / self.LastSize.X, absoluteSize.Y / self.LastSize.Y)
	end

	if v8 or self.WorldDown == nil or self.WorldRight == nil then
		self.WorldDown = getDirectionFromAngle(-absoluteRotation + 180)
		self.WorldRight = getDirectionFromAngle(-absoluteRotation + 90)
	end

	if attributes2.LockedToGui then
		if vector then
			for _, particle in self.Particles do
				particle.Position *= vector
			end
		end
	else
		if v8 then
			local halfAbsoluteSize = absoluteSize / 2

			for _, particle in self.Particles do
				local v10 = particle.Position - halfAbsoluteSize
				local magnitude = v10.Magnitude
				particle.Position = halfAbsoluteSize + getDirectionFromAngle(getAngleFromDirection(v10) - v8) * magnitude

				if attributes2.Orientation == "Normal" then
					particle.Rotation -= v8
				end

				local velocity = particle.Velocity
				local magnitude2 = velocity.Magnitude
				particle.Velocity = getDirectionFromAngle(getAngleFromDirection(velocity) - v8) * magnitude2
			end
		end

		if v7 then
			if absoluteRotation == 0 then
				for _, particle in self.Particles do
					particle.Position -= v7
				end
			else
				for _, particle in self.Particles do
					particle.Position -= self.WorldRight * v7.X
					particle.Position -= self.WorldDown * v7.Y
				end
			end
		end
	end

	self.LastPosition = absolutePosition
	self.LastRotation = absoluteRotation
	self.LastSize = absoluteSize
	self.ParticleFrame.ZIndex = attributes2.ZIndex

	for _, particle in self.Particles do
		self:UpdateParticle(particle, p)
	end

	if attributes2.Enabled then
		local min = attributes2.EmissionRate.Min
		local max = attributes2.EmissionRate.Max

		if attributes2.IgnoreGraphicsLevel == false then
			local v9 = 0.85 ^ (10 - math.min(UserGameSettings.SavedQualityLevel.Value, 10))
			min *= v9
			max *= v9
		end

		if attributes2.EmissionRateScaleByArea and attributes2.EmissionShape ~= "Point" then
			if attributes2.EmissionShapeStyle == "Volume" then
				local viewportSize = workspace.CurrentCamera.ViewportSize
				local v9 = viewportSize.X * viewportSize.Y
				local v10 = math.min(self.AbsoluteSize.X * self.AbsoluteSize.Y, v9)

				if attributes2.EmissionShape == "Oval" then
					v10 *= 0.7853981633974483
				end

				local v11 = 50 * (v10 / v9)
				min *= v11
				max *= v11
			elseif attributes2.EmissionShapeStyle == "Surface" then
				local viewportSize = workspace.CurrentCamera.ViewportSize
				local X = nil

				if attributes2.SizeConstraint == "RelativeXX" then
					X = viewportSize.X
				elseif attributes2.SizeConstraint == "RelativeYY" then
					X = viewportSize.Y
				elseif attributes2.SizeConstraint == "RelativeMin" then
					X = math.min(viewportSize.Y)
				elseif attributes2.SizeConstraint == "RelativeMax" then
					X = math.max(viewportSize.Y)
				end

				local v9 = 10 * ((self.AbsoluteSize.X + self.AbsoluteSize.Y) / 2) / X
				min *= v9
				max *= v9
			end
		end

		self.NextSpawn = math.max(self.NextSpawn, self.Time - 0.2)

		while self.Time > self.NextSpawn do
			local particle = self:SpawnParticle()

			if v7 then
				particle.Velocity += v7 * attributes2.VelocityInheritance / attributes2.MasterScale
			end

			self:UpdateParticle(particle, self.Time - self.NextSpawn)
			local nextSpawn = self.NextSpawn
			local v9 = math.random()
			self.NextSpawn = nextSpawn + 1 / (min + (max - min) * v9)
		end
	else
		self.NextSpawn = self.Time
	end

	if self.ZIndexBehavior ~= Enum.ZIndexBehavior.Global then
		local depth = attributes2.Depth

		if depth.Min ~= depth.Max then
			local particles = table.create(self.ParticleCount)
			local count = 0

			for _, particle in self.Particles do
				count += 1
				particles[count] = particle
			end

			table.sort(particles, function(a, b)
				return a.Depth > b.Depth
			end)

			for k, v9 in particles do
				v9.ParticleGui.ZIndex = attributes2.ZIndex + k
			end
		end
	end
end

function Emitter2D:RemoveParticle(p, p2)
	local particleGui = p.ParticleGui

	if particleGui then
		self.Particles[particleGui] = nil
		self.ParticleCount -= 1

		if p2 then
			particleGui:Destroy()
		else
			particleGui.Visible = false
			self.CacheCount += 1
			self.Cache[self.CacheCount] = particleGui
		end
	end

	local events = p.Events

	if events then
		for _, event in events do
			event:Disconnect()
		end
	end
end

function Emitter2D:ClearAllParticles(p)
	for _, particle in self.Particles do
		self:RemoveParticle(particle, p)
	end
end

function Emitter2D:Destroy()
	self.ParentGui = nil
	self.BillboardGui = nil
	self.ScreenSize = nil
	self:ClearScreenReference()

	if self.Config then
		Emitter2D.Particles[self.Config] = nil
	end

	if self.Events then
		for _, event in self.Events do
			event:Disconnect()
		end
	end

	if self.AncestorEvents then
		for _, ancestorEvent in self.AncestorEvents do
			for _, connection in ancestorEvent do
				connection:Disconnect()
			end
		end
	end

	if self.ParticleFolder then
		Emitter2D.ParticleFolders[self.ParticleFolder] = nil

		if self.ParticleFolder.Parent ~= nil then
			task.defer(function()
				self.ParticleFolder:Destroy()
			end)
		end
	end

	if self.Bindables then
		for _, bindable in self.Bindables do
			bindable:Destroy()
		end
	end
end

local v7 = "Emitter2D_" .. HttpService:GenerateGUID(false)
tick()
RunService:BindToRenderStep(v7, Enum.RenderPriority.First.Value, function(p)
	for k, particle in Emitter2D.Particles do
		if Emitter2D.GlobalEnabled and particle.ValidAncestry and particle.NotVisibleCount == 0 and (particle.Attributes.IgnoreClipsDescendants or particle.ClipCount == 0) then
			local parent = k.Parent

			if particle.FolderParent ~= parent then
				particle.FolderParent = parent
				particle.ParticleFolder.Parent = parent
			end

			if particle.Attributes.Paused == false then
				local success, result = pcall(particle.Update, particle, p * particle.Attributes.TimeScale)

				if not success then
					task.spawn(error, result, 0)
				end
			end
		else
			if particle.FolderParent ~= nil then
				particle.FolderParent = nil
				particle.ParticleFolder.Parent = nil
			end

			if particle.ParticleCount > 0 then
				particle:ClearAllParticles()
			end
		end
	end
end)

if v then
	local v8 = {}
	Emitter2D.GlobalEvents.HideForeignParticles = CollectionService:GetInstanceAddedSignal("Emitter2D_Particle"):Connect(function(instance)
		local parent = instance.Parent
		local parent2 = parent and parent.Parent

		if parent2 and parent2:GetAttribute("Owner") ~= userId then
			local v9 = {
				TransparencyChanged = instance:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
					instance.ImageTransparency = 1
				end)
			}
			instance.ImageTransparency = 1
			v8[instance] = v9
		end
	end)
	Emitter2D.GlobalEvents.CleanupForeignParticles = CollectionService:GetInstanceRemovedSignal("Emitter2D_Particle"):Connect(function(p)
		local v9 = v8[p]

		if v9 then
			for _, connection in v9 do
				connection:Disconnect()
			end

			v8[p] = nil
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CleanUpParticleFolder(instance)
		if instance:GetAttribute("Owner") == userId and Emitter2D.ParticleFolders[instance] == nil then
			task.defer(instance.Destroy, instance)
		end
	end

	Emitter2D.GlobalEvents.RemoveDuplicateFolders = CollectionService:GetInstanceAddedSignal("Emitter2D_ParticleFolder"):Connect(CleanUpParticleFolder)

	for _, v9 in CollectionService:GetTagged("Emitter2D_ParticleFolder") do
		CleanUpParticleFolder(v9) -- equivalent call inferred; original call site unknown
	end
end

function Emitter2D.disconnectGlobalEvents()
	RunService:UnbindFromRenderStep(v7)

	for _, globalEvent in Emitter2D.GlobalEvents do
		globalEvent:Disconnect()
	end
end

if v then
	Emitter2D.GlobalEvents.Deactivate = script.Parent.Parent.Events.Deactivate.Event:Connect(function()
		Emitter2D.disconnectGlobalEvents()
	end)
end

return Emitter2D