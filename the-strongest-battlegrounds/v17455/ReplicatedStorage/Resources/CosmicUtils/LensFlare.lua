local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local assets = script.Assets
local Configuration = require(game.ReplicatedStorage.Resources.CosmicUtils.Configuration)
local NUMBER_OF_RAYCASTS = Configuration.NUMBER_OF_RAYCASTS
local RAYCAST_RADIUS = Configuration.RAYCAST_RADIUS
local TRANSPARENCY_THRESHOLD = Configuration.TRANSPARENCY_THRESHOLD
local vector2 = Vector2.new(1920, 1080)
local v = {
	ColorBlend = 0,
	Position = vector.create(1, 1, 1),
	PositionMult = 1,
	Rotates = false,
	SizeFade = NumberSequence.new(1),
	SquashFade = NumberSequence.new(0),
	TransparencyFade = NumberSequence.new(0)
}
local _ = { "Position" }
local v2 = table.create(NUMBER_OF_RAYCASTS)
local v3 = {
	LensFlareStrength = 1,
	LensFlareDistance = 0
}
local v4 = {
	"Size",
	"Squash",
	"Transparency",
	"LocalTransparencyModifier",
	"Color",
	"Rotation",
	"ZOffset",
	"Lifetime"
}

for i = 1, NUMBER_OF_RAYCASTS do
	local v5 = 6.283185307179586 * ((i - 1) / NUMBER_OF_RAYCASTS)
	v2[i] = { math.cos(v5) * RAYCAST_RADIUS, math.sin(v5) * RAYCAST_RADIUS }
end

local particleEmitter = Instance.new("ParticleEmitter")
local emit = particleEmitter.Emit
local clear = particleEmitter.Clear
local LensFlare = {}
LensFlare.__index = LensFlare

local function evalNumberSequence(sequence, p: number)
	if p == 0 then
		return sequence.Keypoints[1].Value
	elseif p == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v5 = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value + (keypoint2.Value - keypoint.Value) * v5
	end
end

function LensFlare.new(p, childName: string, part)
	local child = assets:FindFirstChild(childName)
	assert(child, (`LensFlare: No lens flare folder called {childName} under LensFlare.Assets`))
	local children = child:GetChildren()
	local object = setmetatable({}, LensFlare)
	local GUID = HttpService:GenerateGUID(false)
	object._id = GUID
	object.Enabled = true
	object.Camera = p
	object.Part = part
	object.Attachments = table.create(#children)
	object.FlareEmitters = table.create(#children)
	object.Alpha = 0
	object._forceRecompute = false
	local attributes = {}
	local connections = {}
	local attributeCache = {}
	local v6 = 1
	local propertyCache = {}

	for attributeName, v8 in v3 do
		attributes[attributeName] = part:GetAttribute(attributeName) or v8
		local v9 = attributeName
		local v10 = v8
		table.insert(connections, (part:GetAttributeChangedSignal(attributeName):Connect(function()
			local attribute = part:GetAttribute(v9) or v10
			attributes[v9] = attribute
			object._forceRecompute = true
		end)))
	end

	attributeCache[part] = attributes

	for _, emitter in children do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = `LensFlare_{childName}_{emitter.Name}`
		attachment.Parent = p
		object.Attachments[v6] = attachment
		propertyCache[attachment] = { attachment.Position }
		local instance = Instance.fromExisting(emitter)
		instance.ZOffset = 0
		instance.Enabled = false
		instance.Parent = attachment
		object.FlareEmitters[v6] = instance
		local HSV, v8 = (part:IsA("BasePart") and part.Color or Color3.new(1, 1, 1)):ToHSV()
		local attributesByAttributeName = {}

		for attributeName, v9 in v do
			attributesByAttributeName[attributeName] = instance:GetAttribute(attributeName) or v9
			local v10 = instance
			local v11 = attributeName
			local v12 = v9
			local attributes2 = attributesByAttributeName
			local v13 = HSV
			table.insert(connections, (instance:GetAttributeChangedSignal(attributeName):Connect(function()
				local attribute = v10:GetAttribute(v11) or v12
				attributes2[v11] = attribute
				object._forceRecompute = true

				if v11 == "ColorBlend" then
					attributes2._color = ColorSequence.new(Color3.fromHSV(v13, attribute, 1))
				end
			end)))
		end

		if attributesByAttributeName.ColorBlend and attributesByAttributeName.ColorBlend > 0 then
			attributesByAttributeName._color = ColorSequence.new(Color3.fromHSV(
				HSV,
				v8 * attributesByAttributeName.ColorBlend,
				1
			))

			if part:IsA("BasePart") then
				local v9 = attributesByAttributeName
				table.insert(connections, part:GetPropertyChangedSignal("Color"):Connect(function()
					local HSV2, v10 = part.Color:ToHSV()
					v9._color = ColorSequence.new(Color3.fromHSV(HSV2, v10 * v9.ColorBlend, 1))
					object._forceRecompute = true
				end))
			end
		end

		local v9 = {}

		for _, v10 in v4 do
			v9[v10] = instance[v10]
		end

		attributeCache[instance] = attributesByAttributeName
		propertyCache[instance] = v9
		v6 += 1
	end

	object._attributeCache = attributeCache
	object._attributeConns = connections
	object._propertyCache = propertyCache
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { part, CollectionService:GetTagged("IgnoreLensFlare") }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	object.RaycastParams = raycastParams
	object._connections = {
		CollectionServiceConn = CollectionService:GetInstanceAddedSignal("IgnoreLensFlare"):Connect(function(p2)
			object.RaycastParams:AddToFilter(p2)
		end)
	}
	RunService:BindToRenderStep(`LensFlare_{GUID}`, Enum.RenderPriority.Camera.Value + 10, function(p2: number)
		if not object.Enabled then
			return
		end

		object:Update(p2)
	end)
	return object
end

function LensFlare:Destroy()
	if not self then
		return
	end

	for _, _connection in self._connections do
		_connection:Disconnect()
	end

	for _, _attributeConn in self._attributeConns do
		_attributeConn:Disconnect()
	end

	RunService:UnbindFromRenderStep((`LensFlare_{self._id}`))

	for _, flareEmitter in self.FlareEmitters do
		flareEmitter:Destroy()
	end

	for _, attachment in self.Attachments do
		attachment:Destroy()
	end

	table.clear(self)
	setmetatable(self, nil)
end

function LensFlare:Update(p: number)
	local camera = self.Camera
	local part = self.Part
	local worldPosition = part:IsA("Attachment") and part.WorldPosition or part.Position
	local v5 = worldPosition - camera.CFrame.Position
	local v6 = vector.magnitude(v5)
	local _attributeCache = self._attributeCache
	local _propertyCache = self._propertyCache
	local v7 = _attributeCache[part]
	local lensFlareDistance = v7.LensFlareDistance
	local lensFlareStrength = v7.LensFlareStrength

	if lensFlareStrength and lensFlareStrength <= 0 or lensFlareDistance and lensFlareDistance > 0 and lensFlareDistance < v6 then
		return
	end

	local v8 = math.clamp(vector.angle(camera.CFrame.LookVector, v5) / math.rad(camera.DiagonalFieldOfView) * 2, 0, 1)

	if lensFlareDistance and lensFlareDistance > 0 then
		v8 += v6 / lensFlareDistance
	end

	if v8 >= 1 then
		return
	end

	local worldToViewportPoint = camera:WorldToViewportPoint(worldPosition)
	local origin = camera:ViewportPointToRay(worldToViewportPoint.X, worldToViewportPoint.Y, 1).Origin
	local position = camera.CFrame:ToObjectSpace(CFrame.new(origin)).Position
	local raycastParams = self.RaycastParams
	local magnitude = (camera.ViewportSize / vector2).Magnitude
	local count = 0

	for _, v9 in v2 do
		local v10 = v9[1] * magnitude
		local v11 = v9[2] * magnitude
		local viewportPointToRay = camera:ViewportPointToRay(
			worldToViewportPoint.X + v10,
			worldToViewportPoint.Y + v11,
			1
		)
		local raycastResult = workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * v6,
			raycastParams
		)

		if not raycastResult then
			continue
		end

		local instance = raycastResult.Instance

		if instance:IsA("BasePart") then
			if not (TRANSPARENCY_THRESHOLD < instance.Transparency) and not (TRANSPARENCY_THRESHOLD < instance.LocalTransparencyModifier) then
				count += 1
				continue
			end

			raycastParams:AddToFilter(instance)
		else
			count += 1
		end
	end

	local v9 = count / NUMBER_OF_RAYCASTS
	local attachments = self.Attachments
	local flareEmitters = self.FlareEmitters
	local alpha2 = lensFlareStrength * (1 - v8) * (1 - v9)
	local alpha = self.Alpha

	if v9 < 1 and v8 < 1 then
		if alpha2 == alpha and not self._forceRecompute then
			for _, flareEmitter in flareEmitters do
				clear(flareEmitter)
				local v11 = _propertyCache[flareEmitter]
				local lifetime = v11.Lifetime
				local numberRange = NumberRange.new(p * 3)

				if lifetime ~= numberRange then
					flareEmitter.Lifetime = numberRange
					v11.Lifetime = numberRange
				end

				emit(flareEmitter, 1)
			end

			return
		else
			for i = 1, #flareEmitters do
				local attachment = attachments[i]
				local flareEmitter = flareEmitters[i]
				clear(flareEmitter)
				local v11 = _attributeCache[flareEmitter]
				local v12 = _propertyCache[flareEmitter]
				local _ = v11.ColorBlend
				local _color = v11._color
				local position2 = v11.Position
				local positionMult = v11.PositionMult
				local rotates = v11.Rotates
				local sizeFade = v11.SizeFade
				local squashFade = v11.SquashFade
				local transparencyFade = v11.TransparencyFade
				local v13 = position.X * position2.x * positionMult
				local v14 = position.Y * position2.y * positionMult
				vector.create(v13, v14, position.Z)
				attachment.Position = vector.create(v13, v14, position.Z)
				local numberSequence = NumberSequence.new(evalNumberSequence(sizeFade, v8))
				local numberSequence2 = NumberSequence.new(evalNumberSequence(squashFade, v8))
				local numberSequence3 = NumberSequence.new((math.lerp(evalNumberSequence(transparencyFade, v8), 1, v9)))
				local localTransparencyModifier = 1 - lensFlareStrength

				if numberSequence ~= v12.Size then
					flareEmitter.Size = numberSequence
					v12.Size = numberSequence
				end

				if numberSequence2 ~= v12.Squash then
					flareEmitter.Squash = numberSequence2
					v12.Squash = numberSequence2
				end

				if numberSequence3 ~= v12.Transparency then
					flareEmitter.Transparency = numberSequence3
					v12.Transparency = numberSequence3
				end

				if localTransparencyModifier ~= v12.LocalTransparencyModifier then
					flareEmitter.LocalTransparencyModifier = 1 - lensFlareStrength
					v12.LocalTransparencyModifier = localTransparencyModifier
				end

				if _color and _color ~= v12.Color then
					flareEmitter.Color = _color
					v12.Color = _color
				end

				if rotates then
					local numberRange = NumberRange.new((math.deg((math.atan2(position.Y, position.X)))))

					if numberRange ~= v12.Rotation then
						flareEmitter.Rotation = numberRange
						v12.Rotation = numberRange
					end
				end

				local zOffset = math.min(-attachment.Position.Z * 0.8, 0)

				if zOffset ~= v12.ZOffset then
					flareEmitter.ZOffset = zOffset
					v12.ZOffset = zOffset
				end

				local lifetime = v12.Lifetime
				local numberRange = NumberRange.new(p * 3)

				if lifetime ~= numberRange then
					flareEmitter.Lifetime = numberRange
					v12.Lifetime = numberRange
				end

				emit(flareEmitter, 1)
			end
		end
	end

	self.Alpha = alpha2
end

return LensFlare