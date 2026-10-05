local createVector = vector.create
local LocalizationService = game:GetService("LocalizationService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local RenderstepForLoop = require(script:WaitForChild("RenderstepForLoop"))
local v = { "rbxassetid://17662038408", "rbxassetid://17662038274", "rbxassetid://17662037971" }
local v2 = {
	a = true,
	e = true,
	i = true,
	o = true,
	u = true
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._particle_hashes = {}
	self._name_to_input_enum = nil
	self._search_translator = nil
	self._cached_sound_groups = {}
	self:_Init()
	return self
end

function class:IsUIElementVisible(instance)
	return (instance:IsDescendantOf(Players.LocalPlayer.PlayerGui) or instance:IsDescendantOf(workspace)) and self:_RecursiveIsUIElementVisible(instance)
end

function class.IsTextBoxFocused(_)
	local success, focusedTextBox = pcall(UserInputService.GetFocusedTextBox, UserInputService)
	return not success or focusedTextBox
end

function class:IsAprilFoolsRaw()
	local universalTime = DateTime.fromUnixTimestamp(ServerOsTime:Get()):ToUniversalTime()
	return universalTime.Month == 4 and universalTime.Day == 1
end

function class:IsAprilFoolsGamemodesEnabled()
	return self:IsAprilFoolsRaw()
end

function class.IsAprilFools(_)
	return false
end

function class.DarkenColor(_, data, p)
	return Color3.new(data.R * p, data.G * p, data.B * p)
end

function class:IsWithinRotatedShape(p, cframe, data, p2)
	if p2 == Enum.PartType.Ball then
		return (p - cframe.Position).Magnitude <= math.max(data.X, data.Y, data.Z) / 2
	end

	if p2 == Enum.PartType.Cylinder then
		local pointToObjectSpace = cframe:PointToObjectSpace(p)
		return pointToObjectSpace.X >= -data.X / 2 and pointToObjectSpace.X <= data.X / 2 and math.sqrt(pointToObjectSpace.Y ^ 2 + pointToObjectSpace.Z ^ 2) <= math.max(
			data.Y,
			data.Z
		) / 2
	else
		local pointToObjectSpace = cframe:PointToObjectSpace(p)
		return pointToObjectSpace.X >= -data.X / 2 and pointToObjectSpace.X <= data.X / 2 and pointToObjectSpace.Y >= -data.Y / 2 and pointToObjectSpace.Y <= data.Y / 2 and pointToObjectSpace.Z >= -data.Z / 2 and pointToObjectSpace.Z <= data.Z / 2
	end
end

function class:IsWithinPart(instance, p, p2)
	return (instance.Position - p).Magnitude < math.max(instance.Size.X, instance.Size.Y, instance.Size.Z) * 1.7320508075688772 and class:IsWithinRotatedShape(
		p,
		instance.CFrame,
		instance.Size + (p2 or createVector(0, 0, 0)),
		instance.ClassName == "Part" and instance.Shape or Enum.PartType.Block
	)
end

function class:IsWithinTaggedParts(tag, p, p2, p3)
	local result = {}

	for _, v3 in pairs(CollectionService:GetTagged(tag)) do
		if not self:IsWithinPart(v3, p, p2) then
			continue
		end

		if not p3 then
			return v3
		end

		table.insert(result, v3)
	end

	if p3 then
		return result
	end

	return nil
end

function class:LookThrough(instance, p)
	for _, child in pairs(instance:GetChildren()) do
		if child:IsA("Model") and child.Name == p then
			return child
		end

		if not child:IsA("Folder") then
			continue
		end

		local lookThrough = self:LookThrough(child, p)

		if lookThrough then
			return lookThrough
		end
	end
end

function class.SilentWaitForChild(_, instance, childName)
	while not instance:FindFirstChild(childName) do
		instance.ChildAdded:Wait()
	end

	return instance[childName]
end

function class.WaitForChildRecursive(_, instance, childName, duration)
	local child = instance:FindFirstChild(childName, true)

	if child then
		return child
	end

	local bindableEvent = Instance.new("BindableEvent")

	if duration then
		task.delay(duration, bindableEvent.Fire, bindableEvent, nil)
	end

	task.defer(function()
		local v3 = false

		if not duration then
			task.delay(5, function()
				if not v3 then
					warn(
						"Infinite yield possible for",
						instance:GetFullName() .. ":WaitForChildRecursive(\"" .. childName .. "\")"
					)
				end
			end)
		end

		local child2

		while true do
			child2 = instance:FindFirstChild(childName, true)

			if child2 then
				break
			end

			instance.DescendantAdded:Wait()
		end

		v3 = true
		bindableEvent:Fire(child2)
	end)
	return bindableEvent.Event:Wait()
end

function class.GetTaggedIn(_, tag, p)
	local result = {}

	for _, v3 in pairs(CollectionService:GetTagged(tag)) do
		if v3:IsDescendantOf(p or workspace) then
			table.insert(result, v3)
		end
	end

	return result
end

function class:GetCharacterModel(character)
	if not character or character == workspace then
		return nil
	end

	if Players:GetPlayerFromCharacter(character) then
		return character
	end

	return (self:GetCharacterModel(character.Parent))
end

function class.GetProperArticle(_, value)
	return "a" .. (v2[string.sub(string.lower(value), 1, 1)] and "n" or "")
end

function class:AntiBarcodeNames(value)
	local count = 0
	local v3 = ""

	for i = 1, #value do
		local v4 = string.sub(value, i, i)

		if v4 == "l" or v4 == "I" then
			count += 1
			v3 ..= v4 == "l" and "L" or v4 == "I" and "i" or v4
		else
			v3 ..= v4
		end
	end

	if count > 3 then
		value = v3 or value
	end

	return value
end

function class:AntiCircleNames(value)
	local count = 0
	local v3 = ""

	for i = 1, #value do
		local v4 = string.sub(value, i, i)

		if v4 == "O" or v4 == "0" then
			count += 1
			v3 ..= v4 == "O" and "o" or v4
		else
			v3 ..= v4
		end
	end

	if count > 3 then
		value = v3 or value
	end

	return value
end

function class:SanitizeName(p)
	return (self:AntiCircleNames((self:AntiBarcodeNames(p))))
end

function class.GetName(_, data, p, p2)
	local v3

	if data.HasVerifiedBadge then
		v3 = " " .. utf8.char(57344)
	elseif p2 or not data.HasRobloxSubscription then
		v3 = (p2 or data.MembershipType ~= Enum.MembershipType.Premium) and "" or " " .. utf8.char(57345)
	else
		v3 = " " .. utf8.char(57347)
	end

	return p .. v3
end

function class.GetConnectionLevelIcon(_, p)
	return v[p]
end

function class.GetConnectionLevel(_, p)
	if p < 60 then
		return 3
	end

	if p < 150 then
		return 2
	end

	return 1
end

function class.GetLocalConnectionPing(_, p)
	return (math.floor((p or Players.LocalPlayer):GetNetworkPing() * 1000))
end

function class.DisableShadows(_, folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:HasTag("DisabledTexturesBlacklist") then
			continue
		end

		if descendant:IsA("Light") then
			descendant.Shadows = false
		elseif descendant:IsA("BasePart") then
			descendant.CastShadow = false
		end
	end
end

function class.DisableTextures(_, folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:HasTag("DisabledTexturesBlacklist") then
			continue
		end

		if descendant:IsA("BasePart") then
			for _, v3 in pairs(Enum.NormalId:GetEnumItems()) do
				descendant[v3.Name .. "Surface"] = Enum.SurfaceType.Smooth
			end

			if descendant.Material ~= Enum.Material.ForceField and descendant.Material ~= Enum.Material.Neon then
				local currentPhysicalProperties = descendant.CurrentPhysicalProperties
				descendant.Material = Enum.Material.SmoothPlastic
				descendant.MaterialVariant = ""
				descendant.CustomPhysicalProperties = descendant.CustomPhysicalProperties or currentPhysicalProperties
			end
		elseif (descendant:IsA("Texture") or descendant:IsA("Decal")) and descendant.Texture ~= "rbxassetid://7658055825" then
			descendant:Destroy()
		end
	end
end

function class:IsVisibleFromSearch(p2, ...)
	if not p2 or p2 == "" then
		return true
	end

	local v3 = { ... }

	for i = 1, #v3, 2 do
		local v4 = v3[i]

		if not v4 then
			continue
		end

		local v5 = v3[i + 1] or game

		if self._search_translator then
			local success, result = pcall(self._search_translator.Translate, self._search_translator, v5, v4)

			if success then
				v4 = string.lower(result)
			end
		end

		if string.find(string.lower(v4), p2) then
			return true
		end
	end

	return false
end

function class:IsValidHex(value)
	if typeof(value) ~= "string" or #value ~= 7 or string.sub(value, 1, 1) ~= "#" then
		return false
	end

	for i = 2, 7 do
		local v3 = string.byte((string.sub(value, i, i)))

		if not (v3 >= 48 and v3 <= 57 or v3 >= 97 and v3 <= 102) then
			return false
		end
	end

	return true
end

function class:Color3FromHex(value)
	assert(self:IsValidHex(value), "Argument 1 invalid, expected a valid hex string")
	local v3 = tonumber("0x" .. string.sub(value, 2, 3))
	local v4 = tonumber("0x" .. string.sub(value, 4, 5))
	local v5 = tonumber("0x" .. string.sub(value, 6, 7))
	return Color3.fromRGB(v3, v4, v5)
end

function class.HexFromColor3(_, data)
	assert(typeof(data) == "Color3", "Argument 1 invalid, expected a Color3")
	local v3 = math.floor(data.R * 255 + 0.5)
	local v4 = math.floor(data.G * 255 + 0.5)
	local v5 = math.floor(data.B * 255 + 0.5)
	return string.format("#%02x%02x%02x", v3, v4, v5)
end

function class:GetInputEnumFromName(p2)
	if self._name_to_input_enum then
		return self._name_to_input_enum[p2]
	end

	self._name_to_input_enum = {}
	local v3 = {}

	for _, v4 in pairs({ Enum.KeyCode, Enum.UserInputType }) do
		for _, v5 in pairs(v4:GetEnumItems()) do
			if v3[v5] == nil then
				v3[v5] = true
			elseif v3[v5] == true then
				v3[v5] = false
			end
		end
	end

	for k, v4 in pairs(v3) do
		if v4 then
			self._name_to_input_enum[k.Name] = k
		end
	end

	return self._name_to_input_enum[p2]
end

function class.SphereLineIntersection(_, p, p2, p3, p4)
	local v3 = p4 - p3
	local magnitude = v3.magnitude
	local unit = v3.unit
	local vector2 = p3 - p
	local dot = vector2:Dot(unit)
	local v4 = vector2:Dot(vector2) - p2 * p2

	if v4 > 0 and dot > 0 then
		return false
	end

	local v5 = dot * dot - v4
	return not (v5 < 0) and not (magnitude < -dot - math.sqrt(v5))
end

function class.Knockback(_, parent, velocity, duration)
	parent.Velocity = createVector(0, 0, 0)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(
		math.abs(velocity.X) > 0.1 and 1 or 0,
		math.abs(velocity.Y) > 0.1 and 1 or 0,
		math.abs(velocity.Z) > 0.1 and 1 or 0
	) * 100000
	bodyVelocity.Velocity = velocity
	bodyVelocity.Parent = parent
	BetterDebris:AddItem(bodyVelocity, 0.2)

	if duration then
		BetterDebris:AddItem(bodyVelocity, duration)
		task.delay(duration, function()
			parent.Velocity = createVector(0, 0, 0)
		end)
	end

	return bodyVelocity
end

function class.GetArmsData(_, instance)
	if not instance then
		return
	end

	local shirt = instance:FindFirstChildOfClass("Shirt")
	local shirtTemplate = shirt and shirt.ShirtTemplate
	local bodyColors = instance:FindFirstChildOfClass("BodyColors")
	return shirtTemplate, bodyColors and bodyColors.LeftArmColor3, bodyColors and bodyColors.RightArmColor3
end

function class.TimeFormat(_, p)
	local v3 = math.floor(p)
	local v4 = v3 % 60
	return math.floor(v3 / 60) .. ":" .. (v4 < 10 and "0" or "") .. v4
end

function class.TimeFormat2(_, p, value, p2)
	if not p2 and p <= 0 then
		return "0s"
	end

	if p2 and p < 60 then
		return "0m"
	end

	local v3 = p % 60
	local v4 = p - v3
	local v5 = v4 / 60 % 60
	local v6 = v4 - v5 * 60
	local v7 = v6 / 60 / 60 % 24
	local v8 = v6 - v7 * 60 * 60
	local v9 = v8 / 60 / 60 / 24 % 365
	local v10 = (v8 - v9 * 24 * 60 * 60) / 60 / 60 / 24 / 365

	if not value then
		return (not (v10 > 0) and "" or v10 .. "y " or "") .. (not (v10 > 0 or v9 > 0) and "" or v9 .. "d " or "") .. (not (v10 > 0 or v9 > 0 or v7 > 0) and "" or v7 .. "h " or "") .. (not (v10 > 0 or v9 > 0 or v7 > 0 or v5 > 0) and "" or v5 .. "m " or "") .. ((not (v10 > 0 or v9 > 0 or v7 > 0 or v5 > 0 or v3 > 0) or p2) and "" or v3 .. "s" or "")
	end

	local v11 = typeof(value) == "number" and value or 1
	local count = 0
	local v12 = ""

	for _, v14 in pairs({
		{ v10, "y" },
		{ v9, "d" },
		{ v7, "h" },
		{ v5, "m" },
		{ v3, "s" }
	}) do
		if not (v14[1] > 0) then
			continue
		end

		count += 1
		v12 ..= (count > 1 and " " or "") .. v14[1] .. v14[2]

		if v11 <= count then
			break
		end
	end

	return v12
end

function class.ScaleParticleEmitter(_, emitter, p)
	local emitters = emitter:IsA("ParticleEmitter") and {} or emitter:GetDescendants()
	table.insert(emitters, emitter)

	for _, emitter2 in pairs(emitters) do
		if not emitter2:IsA("ParticleEmitter") then
			continue
		end

		local numberSequenceKeypoints = {}

		for _, keypoint in pairs(emitter2.Size.Keypoints) do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * p)
			)
		end

		emitter2.Size = NumberSequence.new(numberSequenceKeypoints)
		emitter2.Speed = NumberRange.new(emitter2.Speed.Min * p, emitter2.Speed.Max * p)
		emitter2.Acceleration *= p ^ 2
	end
end

function class.EncodeCFrame(_, cframe)
	local orientation, v3, v4 = cframe:ToOrientation()
	return {
		[utf8.char(0)] = cframe.X,
		[utf8.char(1)] = cframe.Y,
		[utf8.char(2)] = cframe.Z,
		[utf8.char(3)] = orientation,
		[utf8.char(4)] = v3,
		[utf8.char(5)] = v4
	}
end

function class.DecodeCFrame(_, p)
	return CFrame.new(p[utf8.char(0)], p[utf8.char(1)], p[utf8.char(2)]) * CFrame.fromOrientation(
		p[utf8.char(3)],
		p[utf8.char(4)],
		p[utf8.char(5)]
	)
end

function class:FromXYToCameraRotation(p, p2)
	return Vector2.new(p, p2) * 3.141592653589793 * 2 / 256
end

function class:DecodeCameraRotation(list)
	local v3, v4 = utf8.codepoint(list, 1, #list)
	return self:FromXYToCameraRotation(v3, v4)
end

function class.DecodeCameraRotationBulk(_, list)
	local v3 = { utf8.codepoint(list, 1, #list) }
	local result = {}

	for i = 1, #list, 3 do
		table.insert(result, { v3[i], v3[i + 1], v3[i + 2] })
	end

	return result
end

function class.EncodeCameraRotation(_, p)
	if p ~= p then
		return utf8.char(0) .. utf8.char(0)
	end

	local v3 = math.clamp(math.floor(p.X % 6.283185307179586 / 3.141592653589793 / 2 * 256 + 0.5), 0, 255)
	local v4 = math.clamp(math.floor(p.Y % 6.283185307179586 / 3.141592653589793 / 2 * 256 + 0.5), 0, 255)
	return utf8.char(v3) .. utf8.char(v4)
end

function class.AngleBetweenVectors(_, p, vector2)
	return (math.acos(vector2:Dot(p) / vector2.Magnitude / p.Magnitude))
end

function class:PlayParticles(folder)
	if not folder then
		return
	end

	assert(
		typeof(folder) == "Instance" or typeof(folder) == "table",
		"Argument 1 invalid, expected an Instance or table"
	)
	local v3 = typeof(folder) == "Instance"
	local v4 = v3 and not folder:IsDescendantOf(workspace)
	local v5

	if v3 and not v4 then
		if not self._particle_hashes[folder] then
			self._particle_hashes[folder] = 0
			local ancestryChangedConnection = nil
			ancestryChangedConnection = folder.AncestryChanged:Connect(function()
				if not folder:IsDescendantOf(workspace) then
					ancestryChangedConnection:Disconnect()
					self._particle_hashes[folder] = nil
				end
			end)
		end

		self._particle_hashes[folder] += 1
		v5 = self._particle_hashes[folder]
	else
		v5 = nil
	end

	local descendants

	if v3 then
		descendants = folder:GetDescendants()
		table.insert(descendants, folder)
	else
		descendants = {}

		for _, folder2 in pairs(folder) do
			table.insert(descendants, folder2)

			for _, descendant in pairs(folder2:GetDescendants()) do
				table.insert(descendants, descendant)
			end
		end
	end

	for _, instance in pairs(descendants) do
		if instance:IsA("ParticleEmitter") then
			local emitCount = instance:GetAttribute("EmitCount") or 0
			local emitDelay = instance:GetAttribute("EmitDelay") or 0
			local emitDuration = instance:GetAttribute("EmitDuration") or 0

			if emitDelay > 0 then
				task.delay(emitDelay, instance.Emit, instance, emitCount)
			else
				task.spawn(instance.Emit, instance, emitCount)
			end

			if emitDuration > 0 then
				local v6 = instance
				local v7 = emitDuration
				task.defer(function()
					v6.Enabled = true
					task.wait(v7)
					v6.Enabled = false
				end)
			end
		elseif instance:IsA("Light") then
			local brightness = instance:GetAttribute("Brightness") or 0
			local decaySpeed = instance:GetAttribute("DecaySpeed") or 1

			if not v4 then
				local v6 = instance
				local brightness2 = brightness
				local v8 = decaySpeed
				task.spawn(function()
					v6.Brightness = brightness2
					v6.Enabled = true
					self:RenderstepForLoop(0, 100, 10 * v8, function(p)
						if v3 and self._particle_hashes[folder] ~= v5 then
							return true
						end

						v6.Brightness = brightness2 * (1 - p / 100)
					end)

					if not self._particle_hashes[folder] then
						v6.Brightness = 0
						v6.Enabled = false
					end
				end)
			end
		end
	end
end

function class.StringLessThan(_, value, value2)
	if value == value2 then
		return false
	end

	for i = 1, math.min(#value, #value2) do
		local v3 = string.byte((string.sub(value, i, i)))
		local v4 = string.byte((string.sub(value2, i, i)))

		if v3 ~= v4 then
			return v3 < v4
		end
	end

	return #value < #value2
end

function class:CloneTable(items, p)
	local result = {}

	for k, item in pairs(items) do
		if p or typeof(item) ~= "table" then
			result[k] = item
		else
			result[k] = self:CloneTable(item)
		end
	end

	return result
end

function class.PrettyNumber(_, p)
	local v3 = tonumber(p)

	if typeof(v3) ~= "number" then
		assert(false, "Argument 1 invalid, expected a number or string, got " .. tostring(p))
	end

	if tostring(p) == "inf" then
		return "inf"
	end

	local v4, v5, v6 = string.match(v3, "^([^%d]*%d)(%d*)(.-)$")
	return v4 .. v5:reverse():gsub("(%d%d%d)", "%1,"):reverse() .. v6
end

function class:Raycast(p, p2, distance, options, p3, p4)
	assert(typeof(p) == "Vector3", "Argument 1 invalid, expected a Vector3")
	assert(typeof(p2) == "Vector3", "Argument 2 invalid, expected a Vector3")
	assert(typeof(distance) == "number", "Argument 3 invalid, expected a number")
	assert(not options or typeof(options) == "table", "Argument 4 invalid, expected a table or nil")
	assert(not p3 or typeof(p3) == "EnumItem", "Argument 5 invalid, expected a RaycastFilterType")
	assert(not p4 or typeof(p4) == "boolean", "Argument 6 invalid, expected a boolean or nil")
	local filterType = p3 or Enum.RaycastFilterType.Exclude
	local v4 = (p2 - p).Unit * distance
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = options or {}
	raycastParams.FilterType = filterType
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(p, v4, raycastParams)
	local v5 = {
		Position = raycastResult and raycastResult.Position or p + (p2 - p).Unit * distance
	}

	if raycastResult then
		distance = raycastResult.Distance or distance
	end

	v5.Distance = distance
	local instance

	if raycastResult then
		instance = raycastResult.Instance or nil
	end

	v5.Instance = instance
	local material

	if raycastResult then
		material = raycastResult.Material or nil
	end

	v5.Material = material
	v5.Normal = raycastResult and raycastResult.Normal or nil

	if not p4 then
		return v5
	end

	local magnitude = (p - v5.Position).Magnitude
	local part = Instance.new("Part")
	part.Color = Color3.fromHSV(math.random(), 1, 1)
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.01, 0.01, magnitude)
	part.CFrame = CFrame.new(p, v5.Position) * CFrame.new(0, 0, -magnitude / 2)
	part.Parent = workspace
	BetterDebris:AddItem(part, 10)
	return v5
end

function class.WaitForChildWhichIsA(_, instance, className, p)
	assert(typeof(instance) == "Instance", "Argument 1 invalid, expected an Instance, got " .. tostring(instance))
	assert(typeof(className) == "string", "Argument 2 invalid, expected a string, got " .. tostring(className))
	assert(not p or typeof(p) == "boolean", "Argument 3 invalid, expected a boolean or nil, got " .. tostring(p))
	local v3

	while true do
		v3 = instance:FindFirstChildWhichIsA(className, p)

		if v3 then
			break
		end

		if p then
			instance.DescendantAdded:Wait()
		else
			instance.ChildAdded:Wait()
		end
	end

	return v3
end

function class:CreateSound(soundId, value, value2, script2, p, value3, value4, value5, value6, options)
	assert(typeof(soundId) == "string", soundId)
	assert(not value or typeof(value) == "number", value)
	assert(not value2 or typeof(value2) == "number", value2)
	assert(not script2 or script2 == "script" or typeof(script2) == "Instance" or typeof(script2) == "Vector3", script2)
	assert(not p or typeof(p) == "boolean", "Argument 5 invalid, expected a boolean", p)
	assert(not value3 or typeof(value3) == "number", "Argument 6 invalid, expected a number or nil", value3)
	assert(not value4 or typeof(value4) == "number", "Argument 7 invalid, expected a number or nil", value4)
	assert(not value5 or typeof(value5) == "number", "Argument 8 invalid, expected a number or nil", value5)
	assert(not value6 or typeof(value6) == "string", "Argument 9 invalid, expected a string or nil", value6)
	assert(not options or typeof(options) == "table", "Argument 10 invalid, expected a table or nil", options)

	if CONSTANTS.IS_SERVER then
		ReplicatedStorage.Remotes.Misc.FunctionsUnreliable:FireAllClients(
			EnumLibrary:ToEnum("CreateSound"),
			soundId,
			value,
			value2,
			script2,
			p,
			value3,
			value4,
			value5,
			value6,
			options
		)
		return
	end

	if typeof(script2) == "Vector3" then
		local part = Instance.new("Part")
		part.CFrame = CFrame.new(script2)
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.CastShadow = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Anchored = true
		part.Parent = workspace
		BetterDebris:AddItem(part, value3 or 60)
		script2 = part
	elseif script2 == "script" then
		script2 = script
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = value or 1
	sound.PlaybackSpeed = value2 or 1
	sound.RollOffMinDistance = value4 or 50
	sound.RollOffMaxDistance = value5 or 400
	sound.RollOffMode = Enum.RollOffMode.Inverse
	sound.SoundGroup = self:_GetSoundGroup(value6)
	sound:AddTag("AudioVisualizer")

	for k, v3 in pairs(options or {}) do
		sound[k] = v3
	end

	sound.Parent = script2

	if p then
		sound:Play()
	end

	if value3 then
		BetterDebris:AddItem(sound, value3)
	end

	return sound
end

function class:WaitForChild(child, ...)
	assert(typeof(child) == "Instance", "Argument 1 invalid, expected an Instance, got " .. tostring(child))

	for k, childName in pairs({ ... }) do
		assert(
			typeof(childName) == "string",
			"Argument " .. k + 1 .. " invalid, expected a string, got " .. tostring(childName)
		)
		child = child:WaitForChild(childName)
	end

	return child
end

function class:RenderstepForLoop(...)
	RenderstepForLoop(...)
end

function class:_GetSoundGroup(value)
	local v3 = value or "Other"

	if not self._cached_sound_groups[v3] then
		self._cached_sound_groups[v3] = SoundService:FindFirstChild(v3, true)
	end

	return self._cached_sound_groups[v3]
end

function class:_RecursiveIsUIElementVisible(instance)
	if instance:IsA("ScreenGui") or instance:IsA("SurfaceGui") or instance:IsA("BillboardGui") then
		return instance.Enabled
	end

	return instance.Visible and self:_RecursiveIsUIElementVisible(instance.Parent)
end

function class:_SetupTranslator()
	if not CONSTANTS.IS_CLIENT then
		return
	end

	local success, translatorForPlayerAsync = pcall(
		LocalizationService.GetTranslatorForPlayerAsync,
		LocalizationService,
		Players.LocalPlayer
	)

	if success then
		self._search_translator = translatorForPlayerAsync
	else
		warn("Failed to fetch translator, error:", translatorForPlayerAsync)
	end
end

function class:_Init()
	task.defer(self._SetupTranslator, self)
end

return class._new()