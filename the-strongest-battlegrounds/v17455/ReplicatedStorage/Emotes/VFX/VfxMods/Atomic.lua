local Atomic = {}
local FrameEvents = require(script:WaitForChild("FrameEvents"))
require(game.ReplicatedStorage.Resources.EmitModule)
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

function Atomic:Stop()
	local v = self and object[self]

	if not v then
		return false
	end

	v()
	return true
end

local v = {
	Back = Enum.EasingStyle.Back,
	Bounce = Enum.EasingStyle.Bounce,
	Circular = Enum.EasingStyle.Circular,
	Circ = Enum.EasingStyle.Circular,
	Cubic = Enum.EasingStyle.Cubic,
	Elastic = Enum.EasingStyle.Elastic,
	Exponential = Enum.EasingStyle.Exponential,
	Expo = Enum.EasingStyle.Exponential,
	Quad = Enum.EasingStyle.Quad,
	Quart = Enum.EasingStyle.Quart,
	Quint = Enum.EasingStyle.Quint,
	Sine = Enum.EasingStyle.Sine
}
local v2 = {
	In = Enum.EasingDirection.In,
	Out = Enum.EasingDirection.Out,
	InOut = Enum.EasingDirection.InOut
}

local function cframeFromComponents(value)
	if typeof(value) == "CFrame" then
		return value
	end

	if type(value) ~= "table" then
		return CFrame.new()
	end

	if #value >= 12 then
		return CFrame.new(table.unpack(value, 1, 12))
	end

	if #value >= 3 then
		return CFrame.new(value[1] or 0, value[2] or 0, value[3] or 0)
	end

	return CFrame.new()
end

local function asNameList(value, value2)
	if type(value) == "table" then
		return value
	end

	if type(value) == "string" then
		return { value }
	end

	if type(value2) == "table" then
		return value2
	end

	if type(value2) == "string" then
		return { value2 }
	end

	return {}
end

local function getPath(child, list)
	if not child then
		return nil
	end

	if type(list) ~= "table" then
		return child
	end

	for _, childName in ipairs(list) do
		if type(childName) ~= "string" or not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function getChild(child, ...)
	for _, childName in ipairs({ ... }) do
		if not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function applyEasing(p, data)
	if type(data) ~= "table" then
		return p
	end

	local type2 = data.Type or data.type or data.Style or data.style or "Linear"
	local direction = data.Direction or data.direction or "Out"

	if type2 == "Constant" then
		if p >= 1 then
			return 1
		end

		return 0
	else
		if type2 == "Linear" then
			return p
		elseif type2 == "Smoother" then
			return p * p * p * (p * (p * 6 - 15) + 10)
		end

		local v3 = v[type2]
		local v4 = v2[direction]

		if v3 and v4 then
			local TweenService = game:GetService("TweenService")
			return TweenService:GetValue(p, v3, v4)
		else
			return p
		end
	end
end

local function interpolateValue(items, p, p2, eases)
	if type(items) ~= "table" or not next(items) then
		return nil
	end

	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = nil

	for k, item in pairs(items) do
		local v7 = tonumber(k)

		if not v7 then
			continue
		end

		if v7 <= p and (not v3 or v3 < v7) then
			v5 = item
			v3 = v7
		end

		if not (p <= v7 and (not v4 or v7 < v4)) then
			continue
		end

		v6 = item
		v4 = v7
	end

	if v3 == v4 or not (v3 and v4) then
		return v5 or v6
	end

	local v9 = applyEasing((p - v3) / (v4 - v3), eases and (eases[v3] or eases[tostring(v3)]))

	if p2 == "Color3" then
		return v5:lerp(v6, v9)
	elseif p2 == "Vector3" then
		return v5:Lerp(v6, v9)
	elseif p2 == "CFrame" then
		return v5:Lerp(v6, v9)
	elseif p2 == "number" then
		return v5 + (v6 - v5) * v9
	end

	if p2 == "boolean" then
	end

	if v9 >= 1 then
		return v6 or v5
	end

	return v5
end

function Atomic.FirstEvent(data)
	local char = data.Char
	local targChar = data.targChar or data.Victim
	local cleanupTable = data.CleanupTable or data.cleanup
	local realAnim = data.RealAnim
	local bind = data.Bind
	local _ = data.Outside
	local v3 = { "Camera", "Lighting", "Bloom" }
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")
	local Lighting = game:GetService("Lighting")
	local TweenService = game:GetService("TweenService")
	local ContentProvider = game:GetService("ContentProvider")
	local localPlayer = Players.LocalPlayer
	local currentCamera = Workspace.CurrentCamera
	local S_FOV = localPlayer and localPlayer:GetAttribute("S_FOV") or not currentCamera and 70 or currentCamera.FieldOfView or 70
	local _ = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ColorShift_Top = Lighting.ColorShift_Top,
		ColorShift_Bottom = Lighting.ColorShift_Bottom,
		ClockTime = Lighting.ClockTime,
		ExposureCompensation = Lighting.ExposureCompensation,
		EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
		EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
	}
	local isme = localPlayer and (char == localPlayer.Character or targChar == localPlayer.Character)
	local v5 = {
		connections = {},
		callbacks = {},
		objects = {},
		tweens = {},
		particles = {},
		beams = {},
		trails = {},
		lights = {},
		tasks = {},
		controllers = {},
		restores = {}
	}
	local run_context = {
		running = true
	}
	local v7 = {}

	if char then
		object2[char] = v7
	end

	local parentChangedConnection = nil
	local flag = false
	local flag2 = false
	local flag3 = false
	local v8 = -1
	local v9 = false
	local v10 = {}
	local v11 = false
	local cameraType = nil
	local v12 = nil
	local v13 = false
	local v14 = nil
	local flag4 = false
	local v15 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function vegPath(instance)
		return instance and instance:GetFullName() or "nil"
	end

	local function vegLog(...) end

	vegLog(
		"FirstEvent",
		"char",
		not char and "nil" or char:GetFullName() or "nil",
		"victim",
		not targChar and "nil" or targChar:GetFullName() or "nil",
		"isme",
		tostring(isme),
		"realanim",
		tostring(realAnim),
		"bind",
		not bind and "nil" or bind:GetFullName() or "nil"
	)
	local v16 = false
	local v17 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mark(instance)
		if instance then
			pcall(function()
				instance:SetAttribute("EmoteEffect", true)
			end)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function markTree(folder)
		if folder then
			mark(true) -- equivalent call inferred; original call site unknown
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if not descendant then
				continue
			end

			mark(true) -- equivalent call inferred; original call site unknown
		end
	end

	local function addTask(p)
		if p then
			table.insert(v5.tasks, p)

			if cleanupTable then
				table.insert(cleanupTable, p)
			end
		end

		return p
	end

	local function stopControllers()
		for _, controller in pairs(v5.controllers) do
			if not (controller and controller.Stop) then
				continue
			end

			local v18 = controller
			pcall(function()
				v18:Stop()
			end)
		end

		table.clear(v5.controllers)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroyLater(instance)
		local thread = nil
		thread = task.delay(40, function()
			stopControllers()

			if instance then
				pcall(function()
					instance:Destroy()
				end)
			end

			local index = table.find(v5.tasks, thread)

			if index then
				table.remove(v5.tasks, index)
			end
		end)
		local v18 = thread

		if v18 then
			table.insert(v5.tasks, v18)

			if cleanupTable then
				table.insert(cleanupTable, v18)
			end
		end
	end

	local function trackParticleEffect(instance)
		if instance:IsA("ParticleEmitter") then
			table.insert(v5.particles, instance)
		elseif instance:IsA("Beam") then
			table.insert(v5.beams, instance)
		elseif instance:IsA("Trail") then
			table.insert(v5.trails, instance)
		elseif instance:IsA("PointLight") then
			table.insert(v5.lights, instance)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function trackTreeEffects(folder)
		trackParticleEffect(folder)

		for _, descendant in pairs(folder:GetDescendants()) do
			trackParticleEffect(descendant)
		end
	end

	local function trackInstance(p, p2, p3)
		if not p then
			return p
		end

		markTree(p) -- equivalent call inferred; original call site unknown
		table.insert(v5.objects, p)

		if cleanupTable and not p3 then
			table.insert(cleanupTable, p)
		end

		if not p2 then
			destroyLater(p) -- equivalent call inferred; original call site unknown
		end

		return p
	end

	local function trackExternal(p)
		if not p then
			return p
		end

		markTree(p) -- equivalent call inferred; original call site unknown
		table.insert(v5.objects, p)

		if cleanupTable then
			table.insert(cleanupTable, p)
		end

		destroyLater(p) -- equivalent call inferred; original call site unknown
		return p
	end

	local function rememberProperty(instance, property)
		if not instance or (instance == currentCamera or instance == Lighting or instance:IsDescendantOf(Lighting)) then
			return
		end

		for _, restore in ipairs(v5.restores) do
			if restore.object == instance and restore.property == property then
				return
			end
		end

		local success, result = pcall(function()
			return instance[property]
		end)

		if success then
			table.insert(v5.restores, {
				object = instance,
				property = property,
				value = result
			})
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function canTweenValue(p)
		local typeName = typeof(p)
		return typeName == "number" or typeName == "Color3" or typeName == "Vector3" or typeName == "CFrame" or typeName == "UDim" or typeName == "UDim2" or typeName == "Rect"
	end

	local function isExternalRestoreObject(instance)
		if isme and instance and instance.Parent then
			if instance:GetAttribute("EmoteEffect") then
				return false
			end

			return instance == currentCamera or instance == Lighting or (instance:IsDescendantOf(Lighting) or instance:IsDescendantOf(Workspace))
		else
			return false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setPropertyNow(p, p2, p3)
		if p and p.Parent then
			pcall(function()
				p[p2] = p3
			end)
		end
	end

	local function tweenPropertyBack(object3, property, p3, list)
		if isExternalRestoreObject(object3) and canTweenValue(p3) then
			local v18 = nil

			if pcall(function()
				v18 = TweenService:Create(
					object3,
					TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						[property] = p3
					}
				)
			end) and v18 then
				table.insert(v5.tweens, v18)
				table.insert(list, {
					object = object3,
					property = property,
					value = p3
				})
				v18:Play()
			else
				setPropertyNow(object3, property, p3) -- equivalent call inferred; original call site unknown
			end

			return
		end

		setPropertyNow(object3, property, p3) -- equivalent call inferred; original call site unknown
	end

	local function restoreProperties(p)
		local v18 = {}

		for _, restore in ipairs(v5.restores) do
			if p then
				tweenPropertyBack(restore.object, restore.property, restore.value, v18)
			else
				setPropertyNow(restore.object, restore.property, restore.value) -- equivalent call inferred; original call site unknown
			end
		end

		table.clear(v5.restores)

		if #v18 > 0 then
			task.delay(0.6000000000000001, function()
				if char and object2[char] ~= v7 then
					return
				end

				for _, v19 in ipairs(v18) do
					setPropertyNow(v19.object, v19.property, v19.value) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	local function setModelTransparency(folder, colorSequence)
		if not folder then
			return
		end

		if folder:IsA("BasePart") or folder:IsA("Decal") or folder:IsA("Texture") then
			rememberProperty(folder, "Transparency")
			folder.Transparency = colorSequence
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
				continue
			end

			rememberProperty(descendant, "Transparency")
			descendant.Transparency = colorSequence
		end
	end

	local function setModelVisible(folder, p)
		if not folder then
			return
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
				continue
			end

			if p then
				local atomicOriginalTransparency = descendant:GetAttribute("AtomicOriginalTransparency")
				descendant.Transparency = typeof(atomicOriginalTransparency) == "number" and atomicOriginalTransparency or 0
			else
				if descendant:GetAttribute("AtomicOriginalTransparency") == nil then
					descendant:SetAttribute("AtomicOriginalTransparency", descendant.Transparency)
				end

				descendant.Transparency = 1
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolvePropertyRoot(data2, root)
		if root == "camera" then
			return currentCamera
		elseif root == "lighting" then
			return Lighting
		elseif root == "vfx" then
			return data2.vfx
		elseif root == "character" then
			return char
		end

		if root == "victim" or root == "Victim" then
			return targChar
		end

		if root == "camera_rig" or root == "cameraRig" then
			return data2.camera_rig or data2.cameraRig
		end

		if root == "workspace" then
			return Workspace
		end

		return data2[root]
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolvePropertyTarget(data2, target)
		if typeof(target) == "Instance" then
			return target
		end

		if type(target) ~= "table" then
			return nil
		end

		local root = target.root or target.Root

		if type(root) ~= "string" then
			return nil
		end

		local propertyRoot = resolvePropertyRoot(data2, root) -- equivalent call inferred; original call site unknown
		return (getPath(propertyRoot, target.path or target.Path))
	end

	local function shouldApplyTrack(p)
		local target = p.target or p.Target
		local root

		if type(target) == "table" then
			root = target.root or target.Root
		else
			root = false
		end

		return root ~= "camera" and root ~= "lighting" and root ~= "workspace" or isme
	end

	local function setPropertyValue(p, colorSequences, property, colorSequence, data2)
		local value_type = data2.value_type or data2.valueType
		local property_type = data2.property_type or data2.propertyType
		local v18

		if data2.relative_to_origin == true then
			v18 = true
		elseif type(data2.target) == "table" then
			v18 = data2.target.relative_to_origin == true
		else
			v18 = false
		end

		if value_type == "CFrame" and v18 and p.cutscene_origin then
			local authored_origin = p.authored_origin or CFrame.new()
			colorSequence = p.cutscene_origin * authored_origin:ToObjectSpace(colorSequence)
		end

		if property_type == "ColorSequence" and typeof(colorSequence) == "Color3" then
			colorSequence = ColorSequence.new(colorSequence)
		end

		if property == "CFrame" and colorSequences:IsA("Model") and typeof(colorSequence) == "CFrame" then
			rememberProperty(colorSequences, "WorldPivot")
			colorSequences:PivotTo(colorSequence)
		else
			if property == "Transparency" and typeof(colorSequence) == "number" and not (colorSequences:IsA("BasePart") or colorSequences:IsA("Decal") or colorSequences:IsA("Texture")) then
				setModelTransparency(colorSequences, colorSequence)
				return
			end

			rememberProperty(colorSequences, property)
			pcall(function()
				colorSequences[property] = colorSequence
			end)
		end
	end

	local function updatePropertyKeyframes(p, p2)
		local property_keyframes = FrameEvents.property_keyframes or FrameEvents.propertyKeyframes

		if type(property_keyframes) ~= "table" then
			return
		end

		for i, property_keyframe in ipairs(property_keyframes) do
			local target = property_keyframe.target or property_keyframe.Target
			local root

			if type(target) == "table" then
				root = target.root or target.Root
			else
				root = false
			end

			if not (root ~= "camera" and root ~= "lighting" and root ~= "workspace" or isme) then
				continue
			end

			local target2 = property_keyframe.target or property_keyframe.Target
			local propertyTarget = resolvePropertyTarget(p, target2) -- equivalent call inferred; original call site unknown
			local property = property_keyframe.property or property_keyframe.Property
			local values = property_keyframe.values or property_keyframe.Values
			local value_type = property_keyframe.value_type or property_keyframe.valueType or "number"
			local root2

			if type(target2) == "table" then
				root2 = target2.root or target2.Root or nil
			end

			local name = property_keyframe.name or property_keyframe.Name or "track_" .. tostring(i)

			if (root2 == "backgroundUI" or root2 == "background_ui" or root2 == "backgroundImage" or root2 == "background_image" or root2 == "impactUI" or root2 == "impact_ui" or root2 == "impactImage" or root2 == "impact_image") and not v15[name] then
				v15[name] = true
				vegLog(
					"property track",
					name,
					"root",
					tostring(root2),
					"property",
					tostring(property),
					"target",
					not propertyTarget and "nil" or propertyTarget:GetFullName() or "nil",
					"values",
					(type(values))
				)
			end

			if not (propertyTarget and type(property) == "string" and type(values) == "table") then
				continue
			end

			local v18 = values
			local v19 = value_type
			local v20 = property_keyframe
			local object3 = propertyTarget
			local property2 = property
			local success, result = pcall(function()
				local v23 = interpolateValue(v18, p2, v19, v20.eases or v20.Eases)

				if v23 ~= nil then
					if isme then
						setPropertyValue(p, object3, property2, v23, v20)
					elseif not table.find(v3, (tostring(object3))) then
						setPropertyValue(p, object3, property2, v23, v20)
					end
				end
			end)

			if success or v15["ERR_" .. name] then
				continue
			end

			v15["ERR_" .. name] = true
			warn("[Atomic] property track failed:", name, result)
		end
	end

	local function executeFrameEvents(p, data2)
		local frame_events = FrameEvents.frame_events or FrameEvents.frameEvents

		if not frame_events then
			return
		end

		local v18 = math.floor(p + 0.5)

		if v18 <= v8 then
			return
		end

		for i = math.max(0, v8 + 1), v18 do
			local frame_event = frame_events[i]

			if not frame_event then
				continue
			end

			local v20 = vegPath(data2.backgroundUI) -- equivalent call inferred; original call site unknown
			local v21 = vegPath(data2.backgroundImage) -- equivalent call inferred; original call site unknown
			local v22 = vegPath(data2.camera_rig) -- equivalent call inferred; original call site unknown
			vegLog(
				"frame event",
				i,
				"backgroundUI",
				v20,
				"backgroundImage",
				v21,
				"cameraRig",
				v22,
				"vfx",
				vegPath(data2.vfx)
			)
			local thread = nil
			local v23 = frame_event
			local v24 = i
			thread = task.spawn(function()
				local success, result = pcall(v23, data2)

				if not (success or flag) then
					warn("Atomic frame event error:", v24, result)
				end

				local index = table.find(v5.tasks, thread)

				if index then
					table.remove(v5.tasks, index)
				end
			end)
			local v25 = thread

			if not v25 then
				continue
			end

			table.insert(v5.tasks, v25)

			if cleanupTable then
				table.insert(cleanupTable, v25)
			end
		end

		v8 = v18
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addPreloadAsset(list, p, value)
		if type(value) ~= "string" or value == "" or p[value] then
			return
		end

		p[value] = true
		table.insert(list, value)
	end

	local function collectPreloadAssets(folder, list, p, p2)
		if not folder then
			return
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("Animation") then
				local animationId = descendant.AnimationId

				if type(animationId) == "string" and animationId ~= "" and not p[animationId] then
					p[animationId] = true
					table.insert(list, animationId)
				end
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				addPreloadAsset(list, p, descendant.Texture) -- equivalent call inferred; original call site unknown
				local list2 = p2.list
				local seen = p2.seen
				local texture2 = descendant.Texture

				if type(texture2) == "string" and texture2 ~= "" and not seen[texture2] then
					seen[texture2] = true
					table.insert(list2, texture2)
				end
			elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				addPreloadAsset(list, p, descendant.Image) -- equivalent call inferred; original call site unknown
				local list2 = p2.list
				local seen = p2.seen
				local image2 = descendant.Image

				if type(image2) == "string" and image2 ~= "" and not seen[image2] then
					seen[image2] = true
					table.insert(list2, image2)
				end
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
				local texture = descendant.Texture
				addPreloadAsset(list, p, texture) -- equivalent call inferred; original call site unknown
				local list2 = p2.list
				local seen = p2.seen

				if type(texture) == "string" and texture ~= "" and not seen[texture] then
					seen[texture] = true
					table.insert(list2, texture)
				end
			elseif descendant:IsA("MeshPart") then
				addPreloadAsset(list, p, descendant.MeshId) -- equivalent call inferred; original call site unknown
				local textureID = descendant.TextureID

				if type(textureID) == "string" and textureID ~= "" and not p[textureID] then
					p[textureID] = true
					table.insert(list, textureID)
				end
			elseif descendant:IsA("SpecialMesh") then
				addPreloadAsset(list, p, descendant.MeshId) -- equivalent call inferred; original call site unknown
				local textureId = descendant.TextureId

				if type(textureId) == "string" and textureId ~= "" and not p[textureId] then
					p[textureId] = true
					table.insert(list, textureId)
				end
			elseif descendant:IsA("Sound") then
				local soundId = descendant.SoundId

				if type(soundId) == "string" and soundId ~= "" and not p[soundId] then
					p[soundId] = true
					table.insert(list, soundId)
				end
			end
		end
	end

	local function buildPreloadList(...)
		local v18 = {}
		local v19 = {}
		local v20 = {
			list = {},
			seen = {}
		}
		local preload_assets = FrameEvents.preload_assets or FrameEvents.preloadAssets

		if type(preload_assets) == "table" then
			for _, preload_asset in ipairs(preload_assets) do
				addPreloadAsset(v18, v19, preload_asset) -- equivalent call inferred; original call site unknown
				local list = v20.list
				local seen = v20.seen

				if type(preload_asset) ~= "string" or preload_asset == "" or seen[preload_asset] then
					continue
				end

				seen[preload_asset] = true
				table.insert(list, preload_asset)
			end
		end

		for _, v21 in ipairs({ ... }) do
			collectPreloadAssets(v21, v18, v19, v20)
		end

		return v18, v20.seen
	end

	local function startPreload(...)
		if v9 or not (isme and localPlayer) then
			return
		end

		v9 = true
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
		local mobileJunk = playerGui:FindFirstChild("MobileJunk") or playerGui:WaitForChild("MobileJunk", 2)
		local instance, v19, v20 = Instance.new(mobileJunk and "Folder" or "ScreenGui")

		if instance then
			markTree(instance) -- equivalent call inferred; original call site unknown
			table.insert(v5.objects, instance)

			if cleanupTable and not v20 then
				table.insert(cleanupTable, instance)
			end

			if not v19 then
				destroyLater(instance) -- equivalent call inferred; original call site unknown
			end
		end

		instance.Name = "AtomicPreload"

		if instance:IsA("ScreenGui") then
			instance.ResetOnSpawn = false
			instance.IgnoreGuiInset = true
			instance.DisplayOrder = -1000
		end

		instance.Parent = mobileJunk or playerGui
		task.delay(25, function()
			if instance and instance.Parent then
				instance:Destroy()
			end
		end)
		local preloadList, v21 = buildPreloadList(...)
		local v22 = 1.5 / math.max(#preloadList, 1)
		local thread = task.spawn(function()
			for _, image in ipairs(preloadList) do
				if not (run_context.running and instance.Parent) then
					break
				end

				if v21[image] then
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.BackgroundTransparency = 1
					imageLabel.ImageTransparency = 1
					imageLabel.Size = UDim2.fromOffset(1, 1)
					imageLabel.Position = UDim2.fromOffset(-4, -4)
					imageLabel.Image = image
					imageLabel.Parent = instance
				end

				local v24 = image
				pcall(function()
					ContentProvider:PreloadAsync({ v24 })
				end)
				task.wait(v22)
			end
		end)

		if thread then
			table.insert(v5.tasks, thread)

			if cleanupTable then
				table.insert(cleanupTable, thread)
			end
		end
	end

	local function trackGeneratedPartIcles()
		local terrain = Workspace:FindFirstChildOfClass("Terrain")

		if not terrain then
			return
		end

		local v18 = terrain:FindFirstChild("EmittedPartsUsingPart_icle")

		if not v18 then
			task.delay(25, function()
				if v18 and v18.Parent then
					v18:Destroy()
				end
			end)
			v18 = Instance.new("Folder")
			v18.Name = "EmittedPartsUsingPart_icle"
			v18.Parent = terrain
		end

		v5.connections.partIclesGenerated = v18.ChildAdded:Connect(function(child)
			if run_context.running and not flag then
				if child then
					markTree(child) -- equivalent call inferred; original call site unknown
					table.insert(v5.objects, child)

					if cleanupTable then
						table.insert(cleanupTable, child)
					end

					destroyLater(child) -- equivalent call inferred; original call site unknown
				end

				trackTreeEffects(child) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local v18 = {}

	local function setupColorSkill()
		if not isme then
			return nil
		end

		local v19 = Lighting:FindFirstChild("ColorSkills")

		if v19 and not v19:IsA("ColorCorrectionEffect") then
			vegLog("ColorSkill invalid", not v19 and "nil" or v19:GetFullName() or "nil", v19.ClassName)
			return nil
		end

		if v19 then
			v13 = v19:GetAttribute("AtomicColorSkill") == true
		else
			v19 = Instance.new("ColorCorrectionEffect")
			v19.Name = "ColorSkills"
			v19.TintColor = Color3.new(1, 1, 1)
			v19.Brightness = 0
			task.delay(25, function()
				if v19 and v19.Parent then
					v19:Destroy()
				end
			end)
			v19.Saturation = 0
			task.delay(25, function()
				if v19 and v19.Parent then
					v19:Destroy()
				end
			end)
			v19.Contrast = 0
			v19.Enabled = true
			v19:SetAttribute("AtomicColorSkill", true)
			v19.Parent = Lighting
			v13 = true
			v17 = v19
			print(isme)
			print("MAKING COLOR SKILL")
		end

		v19:SetAttribute("AtomicColorSkillActive", true)
		v12 = v19
		v14 = {
			TintColor = v19.TintColor,
			Brightness = v19.Brightness,
			Saturation = v19.Saturation,
			Contrast = v19.Contrast,
			Enabled = v19.Enabled
		}
		rememberProperty(v19, "Enabled")
		v19.Enabled = true
		table.insert(v18, v19)
		vegLog(
			"ColorSkill ready",
			not v19 and "nil" or v19:GetFullName() or "nil",
			"created",
			tostring(v13),
			"brightness",
			v19.Brightness,
			"saturation",
			v19.Saturation,
			"contrast",
			v19.Contrast
		)
		return v19
	end

	local function fadeColorSkillOut()
		local v19 = v12

		if not (v19 and v19.Parent) then
			return
		end

		local atomicColorSkill = v19:GetAttribute("AtomicColorSkill") == true
		local v20

		if atomicColorSkill then
			v20 = {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0,
				Saturation = 0,
				Contrast = 0
			}
		else
			v20 = v14
		end

		if not v20 then
			return
		end

		v19:SetAttribute("AtomicColorSkillActive", false)
		local success, result = pcall(function()
			return TweenService:Create(v19, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				TintColor = v20.TintColor,
				Brightness = v20.Brightness,
				Saturation = v20.Saturation,
				Contrast = v20.Contrast
			})
		end)

		if success and result then
			result:Play()
			vegLog(
				"ColorSkill fade out",
				not v19 and "nil" or v19:GetFullName() or "nil",
				"vegetableOwned",
				tostring(atomicColorSkill),
				"destroyAfter",
				(tostring(v13))
			)
		else
			v19.TintColor = v20.TintColor
			v19.Brightness = v20.Brightness
			v19.Saturation = v20.Saturation
			v19.Contrast = v20.Contrast
		end

		task.delay(0.6000000000000001, function()
			if not (v19 and v19.Parent) then
				return
			end

			v19.TintColor = v20.TintColor
			v19.Brightness = v20.Brightness
			v19.Saturation = v20.Saturation
			v19.Contrast = v20.Contrast
			warn("d")

			if not atomicColorSkill and v14 then
				v19.Enabled = v14.Enabled
			end

			if atomicColorSkill and v19:GetAttribute("AtomicColorSkillActive") ~= true then
				local v22 = vegPath(v19) -- equivalent call inferred; original call site unknown
				v19:Destroy()
				vegLog("ColorSkill destroyed", v22)
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restoreVegetableLighting()
		if flag4 then
			return
		end

		flag4 = true

		if shared.originallighting then
			shared.originallighting()
		end

		vegLog("originallighting fired")
		fadeColorSkillOut()
	end

	local function fn()
		if flag2 then
			return
		end

		flag2 = true
		flag3 = false
		run_context.running = false

		for _, v19 in pairs(v10) do
			local v20 = v19
			pcall(function()
				v20:Stop(0)
				v20:Destroy()
			end)
		end

		table.clear(v10)

		for _, callback in ipairs(v5.callbacks) do
			pcall(callback)
		end

		table.clear(v5.callbacks)

		if v11 and currentCamera then
			pcall(function()
				currentCamera.CameraType = cameraType or Enum.CameraType.Custom
			end)
			v11 = false
		end

		for _, connection in pairs(v5.connections) do
			if not connection then
				continue
			end

			local connection2 = connection
			pcall(function()
				connection2:Disconnect()
			end)
		end

		local thread = coroutine.running()

		for _, task2 in pairs(v5.tasks) do
			if not (task2 and task2 ~= thread) then
				continue
			end

			local v19 = task2
			pcall(function()
				task.cancel(v19)
			end)
		end

		for _, tween in pairs(v5.tweens) do
			if not tween then
				continue
			end

			local v19 = tween
			pcall(function()
				v19:Cancel()
			end)
		end

		stopControllers()

		for _, particle in pairs(v5.particles) do
			if not particle then
				continue
			end

			local v19 = particle
			pcall(function()
				v19.Enabled = false
			end)
		end

		for _, beam in pairs(v5.beams) do
			if not beam then
				continue
			end

			local v19 = beam
			pcall(function()
				v19.Enabled = false
			end)
		end

		for _, trail in pairs(v5.trails) do
			if not trail then
				continue
			end

			local v19 = trail
			pcall(function()
				v19.Enabled = false
			end)
		end

		for _, light in pairs(v5.lights) do
			if not light then
				continue
			end

			local v19 = light
			pcall(function()
				v19.Enabled = false
			end)
		end

		restoreProperties(true)
		restoreVegetableLighting() -- equivalent call inferred; original call site unknown

		if isme and currentCamera then
			if shared.originallighting then
				shared.originallighting()
			end

			local v19 = {}
			tweenPropertyBack(currentCamera, "FieldOfView", S_FOV, v19)

			for _, v20 in pairs(v18) do
				v20:Destroy()
			end

			if #v19 > 0 then
				task.delay(0.6000000000000001, function()
					for _, _ in ipairs(v19) do

					end
				end)
			end
		end

		for _, object3 in pairs(v5.objects) do
			if not object3 then
				continue
			end

			local v19 = object3
			pcall(function()
				v19:Destroy()
			end)
		end

		table.clear(v5.connections)
		table.clear(v5.objects)
		table.clear(v5.tweens)
		table.clear(v5.particles)
		table.clear(v5.beams)
		table.clear(v5.trails)
		table.clear(v5.lights)
		table.clear(v5.tasks)
		table.clear(v5.restores)
	end

	local Clean

	Clean = function()
		if flag then
			return
		end

		flag = true

		if object[char] == Clean then
			object[char] = nil
		end

		if parentChangedConnection then
			parentChangedConnection:Disconnect()
			parentChangedConnection = nil
		end

		if fn then
			fn()
		end

		shared.originallighting({
			time = 0.5
		})

		if v17 and v17.Parent then
			v17:Destroy()
		end

		if char == game.Players.LocalPlayer.Character then
			workspace.CurrentCamera.FieldOfView = 70
		end

		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		shared.smoothout(workspace.CurrentCamera.CFrame)
	end

	object[char] = Clean

	if bind then
		parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
			if not (bind and bind.Parent) then
				Clean()
			end
		end)
	end

	local thread = task.delay(40, function()
		Clean()
	end)

	if thread then
		table.insert(v5.tasks, thread)

		if cleanupTable then
			table.insert(cleanupTable, thread)
		end
	end

	local v19

	if v16 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v16 = true
		v19 = false
	else
		v19 = true
	end

	if not v19 then
		Clean()
		return
	end

	local function runCutscene()
		local DELAY_DURATION = 25

		if flag3 then
			return
		end

		local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local misc = script:FindFirstChild("Misc")
		local VFX = script:FindFirstChild("VFX")
		vegLog(
			"runCutscene",
			"root",
			not humanoidRootPart and "nil" or humanoidRootPart:GetFullName() or "nil",
			"misc",
			not misc and "nil" or misc:GetFullName() or "nil",
			"hasBackgroundUI",
			tostring(misc and misc:FindFirstChild("BackgroundUI") ~= nil),
			"vfxTemplate",
			not VFX and "nil" or VFX:GetFullName() or "nil"
		)

		if not VFX then
			vegLog("abort", "missing VFX template")
			return
		end

		local thrown = Workspace:FindFirstChild("Thrown") or Workspace
		local originalCutscene = script:FindFirstChild("OriginalCutscene")
		local cam = originalCutscene and originalCutscene:FindFirstChild("Cam")
		local cameraRig = cam and cam:FindFirstChild("CameraRig")
		startPreload(VFX, misc, cameraRig)
		local pivot = cameraRig and cameraRig:GetPivot() or CFrame.new()
		local cFrame = humanoidRootPart.CFrame

		-- equivalent calls inferred from this helper; original call sites unknown
		local function anchorModelRoot(clone)
			local humanoidRootPart2 = clone and (clone:FindFirstChild("HumanoidRootPart") or clone.PrimaryPart)

			if humanoidRootPart2 and humanoidRootPart2:IsA("BasePart") then
				humanoidRootPart2.Anchored = true
			end
		end

		local clone = nil
		local cameraRig1 = cam and cam:FindFirstChild("CameraRig1")
		local clone2

		if cameraRig then
			local v20, v21
			clone2, v20, v21 = cameraRig:Clone()

			if clone2 then
				markTree(clone2) -- equivalent call inferred; original call site unknown
				table.insert(v5.objects, clone2)

				if cleanupTable and not v21 then
					table.insert(cleanupTable, clone2)
				end

				if not v20 then
					destroyLater(clone2) -- equivalent call inferred; original call site unknown
				end
			end

			clone2.Name = "AtomicCameraRig"
			clone2:PivotTo(cFrame)
			task.delay(DELAY_DURATION, function()
				if clone2 and clone2.Parent then
					clone2:Destroy()
				end
			end)
			clone2.Parent = thrown
		else
			clone2 = nil
		end

		if cameraRig1 then
			local v20, v21
			clone, v20, v21 = cameraRig1:Clone()

			if clone then
				markTree(clone) -- equivalent call inferred; original call site unknown
				table.insert(v5.objects, clone)

				if cleanupTable and not v21 then
					table.insert(cleanupTable, clone)
				end

				if not v20 then
					destroyLater(clone) -- equivalent call inferred; original call site unknown
				end
			end

			clone.Name = "AtomicCameraRig1"
			clone:PivotTo(cFrame)
			task.delay(DELAY_DURATION, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
			clone.Parent = thrown
			anchorModelRoot(clone) -- equivalent call inferred; original call site unknown
		end

		local clone3, v20, v21 = VFX:Clone()

		if clone3 then
			markTree(clone3) -- equivalent call inferred; original call site unknown
			table.insert(v5.objects, clone3)

			if cleanupTable and not v21 then
				table.insert(cleanupTable, clone3)
			end

			if not v20 then
				destroyLater(clone3) -- equivalent call inferred; original call site unknown
			end
		end

		task.delay(DELAY_DURATION, function()
			if clone3 and clone3.Parent then
				clone3:Destroy()
			end
		end)
		clone3.Name = "AtomicVFX"
		clone3:PivotTo(cFrame)
		trackTreeEffects(clone3) -- equivalent call inferred; original call site unknown
		clone3.Parent = thrown
		trackGeneratedPartIcles()
		local colorSkill = setupColorSkill()

		if isme then
			for _, childName in ipairs({ "DepthOfField", "Bloom", "ColorSkills" }) do
				local child = Lighting:FindFirstChild(childName)

				if not child then
					continue
				end

				local v23 = child
				local enabled = child.Enabled
				table.insert(v5.callbacks, function()
					if v23.Parent then
						pcall(function()
							v23.Enabled = enabled
						end)
					end
				end)
				local v25 = child
				pcall(function()
					v25.Enabled = true
				end)
			end
		end

		local clone4 = nil
		local imageLabel = nil

		if isme and misc and misc:FindFirstChild("BackgroundUI") and localPlayer then
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")

			for _, child in ipairs(playerGui:GetChildren()) do
				if child:GetAttribute("AtomicBackgroundUI") ~= true then
					continue
				end

				vegLog("background old clone removed", not child and "nil" or child:GetFullName() or "nil")
				child:Destroy()
			end

			clone4 = misc.BackgroundUI:Clone()
			task.delay(DELAY_DURATION, function()
				if clone4 and clone4.Parent then
					clone4:Destroy()
				end
			end)
			clone4:SetAttribute("AtomicBackgroundUI", true)

			if clone4 then
				markTree(clone4) -- equivalent call inferred; original call site unknown
				table.insert(v5.objects, clone4)

				if cleanupTable then
					table.insert(cleanupTable, clone4)
				end

				destroyLater(clone4) -- equivalent call inferred; original call site unknown
			end

			clone4.Parent = playerGui
			imageLabel = clone4:FindFirstChild("ImageLabel", true)
			vegLog(
				"background screenGui parented",
				"source",
				vegPath(misc.BackgroundUI),
				"backgroundUI",
				not clone4 and "nil" or clone4:GetFullName() or "nil",
				"class",
				clone4.ClassName,
				"children",
				#clone4:GetChildren(),
				"backgroundImage",
				not imageLabel and "nil" or imageLabel:GetFullName() or "nil",
				"displayOrder",
				clone4.DisplayOrder,
				"enabled",
				(tostring(clone4.Enabled))
			)

			if imageLabel then
				vegLog(
					"background image props",
					"image",
					imageLabel.Image,
					"imageTransparency",
					imageLabel.ImageTransparency,
					"backgroundTransparency",
					imageLabel.BackgroundTransparency,
					"visible",
					tostring(imageLabel.Visible),
					"zindex",
					imageLabel.ZIndex
				)
			end
		else
			vegLog(
				"background skipped",
				"isme",
				tostring(isme),
				"misc",
				not misc and "nil" or misc:GetFullName() or "nil",
				"hasBackgroundUI",
				tostring(misc and misc:FindFirstChild("BackgroundUI") ~= nil),
				"player",
				(tostring(localPlayer))
			)
		end

		local v23 = nil
		local screenGui = nil

		if isme and localPlayer then
			local preload_assets = FrameEvents.preload_assets or FrameEvents.preloadAssets

			if type(preload_assets) == "table" and #preload_assets > 0 then
				local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

				if playerGui then
					local v24, v25
					screenGui, v24, v25 = Instance.new("ScreenGui")

					if screenGui then
						markTree(screenGui) -- equivalent call inferred; original call site unknown
						table.insert(v5.objects, screenGui)

						if cleanupTable and not v25 then
							table.insert(cleanupTable, screenGui)
						end

						if not v24 then
							destroyLater(screenGui) -- equivalent call inferred; original call site unknown
						end
					end

					screenGui.Name = "AtomicImageCache"
					screenGui.IgnoreGuiInset = true
					screenGui.ResetOnSpawn = false
					screenGui.DisplayOrder = -1000
					screenGui.Parent = playerGui
					v23 = {}

					for i, preload_asset in ipairs(preload_assets) do
						local imageLabel2 = Instance.new("ImageLabel")
						imageLabel2.Name = "Image" .. i
						imageLabel2.BackgroundTransparency = 1
						imageLabel2.BorderSizePixel = 0
						imageLabel2.Image = preload_asset
						imageLabel2.ImageTransparency = 0
						imageLabel2.Visible = true
						imageLabel2.Position = UDim2.fromOffset(0, 0)
						imageLabel2.Size = UDim2.fromOffset(1, 1)
						imageLabel2.Parent = screenGui
						v23[preload_asset] = imageLabel2
					end
				end
			end
		end

		local animations = originalCutscene and originalCutscene:FindFirstChild("Animations")

		local function getOrCreateAnimator(parent)
			local humanoid = parent:FindFirstChildOfClass("Humanoid")

			if humanoid then
				local v24 = humanoid:FindFirstChildOfClass("Animator")

				if not v24 then
					v24 = Instance.new("Animator")
					v24.Parent = humanoid
				end

				return v24
			else
				local parent2 = parent:FindFirstChildOfClass("AnimationController")

				if not parent2 then
					parent2 = Instance.new("AnimationController")
					parent2.Name = "AnimationController"
					parent2.Parent = parent
				end

				local v25 = parent2:FindFirstChildOfClass("Animator")

				if not v25 then
					v25 = Instance.new("Animator")
					v25.Parent = parent2
				end

				return v25
			end
		end

		local function playSynced(instance, childName, p)
			local animation = animations and animations:FindFirstChild(childName)

			if not (instance and animation and animation:IsA("Animation")) then
				vegLog("playSynced skipped", p, "model", vegPath(instance), "anim", vegPath(animation))
				return
			end

			local success, result = pcall(function()
				return getOrCreateAnimator(instance):LoadAnimation(animation)
			end)

			if not (success and result) then
				vegLog("playSynced load failed", p, (tostring(result)))
				return
			end

			result.Looped = false
			v10[p] = result
			result:Play(0)
		end

		if clone2 then
			playSynced(clone2, "CameraRig", "camera_rig")
		end

		if clone then
			playSynced(clone, "CameraRig1", "camera_rig1")
		end

		local v24 = {
			camera_rig1 = clone,
			cameraRig1 = clone,
			camera_rig_1 = clone
		}

		local function copyAppearance(clone5, targChar2)
			if not (clone5 and targChar2) then
				return
			end

			local humanoid = clone5:FindFirstChildOfClass("Humanoid")

			for _, child in ipairs(clone5:GetChildren()) do
				if not (child:IsA("Shirt") or child:IsA("Pants") or child:IsA("BodyColors") or child:IsA("CharacterMesh") or child:IsA("Accessory") or child:IsA("ShirtGraphic")) then
					continue
				end

				child:Destroy()
			end

			for _, child in ipairs(targChar2:GetChildren()) do
				if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("BodyColors") or child:IsA("CharacterMesh") or child:IsA("ShirtGraphic") then
					local clone = child:Clone()
					clone.Parent = clone5
				elseif child:IsA("Accessory") then
					local clone6 = child:Clone()

					for _, descendant in ipairs(clone6:GetDescendants()) do
						if descendant:IsA("BasePart") then
							descendant.Transparency = 0
							descendant.Anchored = false
							descendant.CanCollide = false
						elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("Sound") then
							descendant:Destroy()
						end
					end

					if humanoid then
						local v25 = clone6
						pcall(function()
							humanoid:AddAccessory(v25)
						end)
					else
						clone6.Parent = clone5
					end
				end
			end

			for _, childName in ipairs({
				"Head",
				"Torso",
				"Left Arm",
				"Right Arm",
				"Left Leg",
				"Right Leg"
			}) do
				local child = targChar2:FindFirstChild(childName)
				local child2 = clone5:FindFirstChild(childName)

				if not (child and child2) then
					continue
				end

				local v25 = child2
				local v26 = child
				pcall(function()
					v25.Color = v26.Color
				end)
				local v27 = child2
				local v28 = child
				pcall(function()
					v27.Material = v28.Material
				end)
			end

			local head = targChar2:FindFirstChild("Head")
			local head2 = clone5:FindFirstChild("Head")

			if head and head2 then
				local dataModelMesh = head:FindFirstChildWhichIsA("DataModelMesh")
				local decal = head:FindFirstChildWhichIsA("Decal")

				if dataModelMesh then
					local dataModelMesh2 = head2:FindFirstChildWhichIsA("DataModelMesh")

					if dataModelMesh2 then
						dataModelMesh2:Destroy()
					end

					local clone_2 = dataModelMesh:Clone()
					clone_2.Parent = head2
				end

				if decal then
					local decal2 = head2:FindFirstChildWhichIsA("Decal")

					if decal2 then
						decal2:Destroy()
					end

					local clone_3 = decal:Clone()
					clone_3.Parent = head2
				end
			end

			print(clone5)
		end

		local user1 = misc and misc:FindFirstChild("User1")

		if user1 then
			local clone5, v25, v26 = user1:Clone()

			if clone5 then
				markTree(clone5) -- equivalent call inferred; original call site unknown
				table.insert(v5.objects, clone5)

				if cleanupTable and not v26 then
					table.insert(cleanupTable, clone5)
				end

				if not v25 then
					destroyLater(clone5) -- equivalent call inferred; original call site unknown
				end
			end

			clone5.Name = "AtomicUser1"
			copyAppearance(clone5, targChar)
			clone5:SetAttribute("CutsceneRuntime", true)
			clone5:PivotTo(cFrame)
			task.delay(DELAY_DURATION, function()
				if clone5 and clone5.Parent then
					clone5:Destroy()
				end
			end)
			clone5.Parent = thrown
			anchorModelRoot(clone5) -- equivalent call inferred; original call site unknown
			trackTreeEffects(clone5) -- equivalent call inferred; original call site unknown
			playSynced(clone5, "User1", "user1")
			v24.user1 = clone5
			v24.User1 = clone5
		end

		if targChar and targChar ~= char then
			playSynced(targChar, "Victim", "victim")
		end

		local v25 = {
			character = char,
			victim = targChar,
			Victim = targChar,
			camera = currentCamera,
			lighting = Lighting,
			cameraRig = clone2,
			camera_rig = clone2,
			vfx = clone3,
			backgroundUI = clone4,
			background_ui = clone4,
			backgroundImage = imageLabel,
			background_image = imageLabel,
			colorSkill = colorSkill,
			ColorSkill = colorSkill,
			cutscene_origin = cFrame,
			authored_origin = pivot,
			run_context = run_context,
			cleanup_objects = v5.objects,
			cleanup_connections = v5.connections,
			cleanup_tasks = v5.tasks,
			cleanup_main = cleanupTable,
			isme = isme,
			camera_rig1 = clone,
			cameraRig1 = clone,
			misc_models = v24,
			miscModels = v24,
			cleanup_callbacks = v5.callbacks,
			image_cache = v23,
			imageCache = v23,
			image_cache_gui = screenGui,
			imageCacheGui = screenGui
		}
		local property_keyframes = FrameEvents.property_keyframes or FrameEvents.propertyKeyframes or {}
		local frame_events = FrameEvents.frame_events or FrameEvents.frameEvents or {}
		local count = 0
		local count2 = 0
		local count3 = 0

		for _, property_keyframe in ipairs(property_keyframes) do
			count += 1
			local target = property_keyframe.target or property_keyframe.Target
			local root

			if type(target) == "table" then
				root = target.root or target.Root or nil
			end

			local path

			if type(target) == "table" then
				path = target.path or target.Path or nil
			end

			if root == "backgroundUI" or root == "background_ui" or root == "backgroundImage" or root == "background_image" or root == "impactUI" or root == "impact_ui" or root == "impactImage" or root == "impact_image" then
				count2 += 1
			elseif root == "lighting" and type(path) == "table" and path[1] == "ColorSkills" then
				count3 += 1
			end
		end

		local count4 = 0

		for _ in pairs(frame_events) do
			count4 += 1
		end

		local v27 = vegPath(v25.backgroundUI) -- equivalent call inferred; original call site unknown
		vegLog(
			"objects ready",
			"backgroundUI",
			v27,
			"backgroundImage",
			vegPath(v25.backgroundImage),
			"colorSkill",
			vegPath(colorSkill),
			"propertyTracks",
			count,
			"backgroundTracks",
			count2,
			"colorSkillTracks",
			count3,
			"frameEvents",
			count4
		)

		if count2 == 0 then
			vegLog("warning", "FrameEvents has no background UI/image property tracks")
		end

		flag3 = true
		local camera = clone2 and (clone2:FindFirstChild("Camera") or clone2:FindFirstChild("CamPart"))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function objectFromKey(object3)
			if type(object3) == "string" then
				return v25[object3] or v25.misc_models and v25.misc_models[object3]
			end

			return nil
		end

		local function getCameraPartForFrame(p)
			local camera_part_keyframes = FrameEvents.camera_part_keyframes or FrameEvents.cameraPartKeyframes

			if type(camera_part_keyframes) ~= "table" then
				return camera
			end

			local v28 = nil
			local v29 = nil

			for k, camera_part_keyframe in pairs(camera_part_keyframes) do
				local v30 = tonumber(k)

				if not (v30 and v30 <= p and (not v28 or v28 < v30)) then
					continue
				end

				v29 = camera_part_keyframe
				v28 = v30
			end

			if v28 == nil then
				return camera
			end

			if v29 == false then
				return nil
			end

			if type(v29) ~= "table" then
				return camera
			end

			local object3 = v29.object or v29.rig or v29.model
			local v30 = objectFromKey(object3) -- equivalent call inferred; original call site unknown

			if not v30 then
				return camera
			end

			local part = v30:FindFirstChild(v29.part or "CamPart") or v30:FindFirstChild("Camera")

			if not (part and part:IsA("BasePart") and part) then
				part = camera
			end

			return part
		end

		if isme and currentCamera and camera then
			cameraType = currentCamera.CameraType
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = camera.CFrame
			v11 = true
		end

		task.delay(24.5, function()
			if not (isme and flag3) then
				return
			end

			local accessory = Instance.new("Accessory")
			accessory.Name = "RootAnchor"
			accessory.Parent = char
			game.Debris:AddItem(accessory, 0.5)
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			frame.Parent = game.Players.LocalPlayer.PlayerGui.MobileJunk
			frame.Size = UDim2.new(1, 0, 1, 0)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(frame, TweenInfo.new(1.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.1, function()
				shared.smoothout(workspace.CurrentCamera.CFrame)
			end)
			task.delay(0.2, function()
				realAnim:Stop(0.5)
			end)

			for _, animationController in pairs(clone2:GetDescendants()) do
				if not animationController:IsA("AnimationController") then
					continue
				end

				for _, v28 in pairs(animationController:GetPlayingAnimationTracks()) do
					v28:Stop()
				end
			end

			for _, animationController in pairs(clone:GetDescendants()) do
				if not animationController:IsA("AnimationController") then
					continue
				end

				for _, v28 in pairs(animationController:GetPlayingAnimationTracks()) do
					v28:Stop()
				end
			end
		end)
		local descendants = {}

		if isme and localPlayer and char == localPlayer.Character then
			for _, descendant in ipairs(char:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					table.insert(descendants, descendant)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function allTracksLoaded()
			for _, v28 in pairs(v10) do
				if v28.Length <= 0 then
					return false
				end
			end

			return true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startTimeline()
			local timeline_start = os.clock() - (realAnim and realAnim.TimePosition or 0)
			v25.timeline_start = timeline_start
			v5.connections.renderStepped = RunService.RenderStepped:Connect(function()
				if flag2 then
					return
				end

				local v29

				if v16 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v16 = true
					v29 = false
				else
					v29 = true
				end

				if not v29 then
					Clean()
					return
				end

				local v30 = os.clock() - timeline_start
				local v31 = v30 * 60
				local length_frames = FrameEvents.length_frames or FrameEvents.lengthFrames

				if typeof(length_frames) == "number" then
					if length_frames + 30 < v31 then
						Clean()
						return v5.connections.renderStepped:Disconnect()
					else
						v31 = math.min(v31, length_frames)
					end
				end

				updatePropertyKeyframes(v25, v31)
				executeFrameEvents(v31, v25)

				for _, v32 in pairs(v10) do
					if not (v32.Length > 0) then
						continue
					end

					local timePosition = math.clamp(v30, 0, (math.max(0, v32.Length - 0.001)))

					if v32.Length - 0.03333333333333333 <= v30 then
						if v32.IsPlaying and v32.Speed ~= 0 then
							v32:AdjustSpeed(0)
							local v34 = v32
							local timePosition2 = timePosition
							pcall(function()
								v34.TimePosition = timePosition2
							end)
						elseif not v32.IsPlaying then
							v32:Play(0)
							v32:AdjustSpeed(0)
							local v34 = v32
							local timePosition2 = timePosition
							pcall(function()
								v34.TimePosition = timePosition2
							end)
						end
					elseif math.abs(v32.TimePosition - timePosition) > 0.03333333333333333 then
						local v34 = v32
						local timePosition2 = timePosition
						pcall(function()
							v34.TimePosition = timePosition2
						end)
					end
				end

				for _, v32 in ipairs(descendants) do
					if v32.Parent then
						v32.LocalTransparencyModifier = 0
					end
				end

				local v32 = v11 and currentCamera and getCameraPartForFrame(v31)

				if v32 then
					currentCamera.CFrame = v32.CFrame
				end
			end)
		end

		local thread2 = task.spawn(function()
			local v28 = os.clock() + 5

			while true do
				local v29

				if v16 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v16 = true
					v29 = false
				else
					v29 = true
				end

				if v29 and not flag2 then
					local v30 = allTracksLoaded() -- equivalent call inferred; original call site unknown

					if not v30 and os.clock() < v28 then
						task.wait()
						continue
					end
				end

				local v30

				if v16 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v16 = true
					v30 = false
				else
					v30 = true
				end

				if not v30 or flag2 then
					break
				end

				startTimeline() -- equivalent call inferred; original call site unknown
				break
			end
		end)

		if thread2 then
			table.insert(v5.tasks, thread2)

			if cleanupTable then
				table.insert(cleanupTable, thread2)
			end
		end
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	v5.connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
		if player == localPlayer then
			Clean()
		end
	end)
	local success, result = pcall(runCutscene)
	print("RUNNING CUTSCENE")

	if not success then
		warn("Atomic cutscene error:", result)
		Clean()
	end
end

return Atomic