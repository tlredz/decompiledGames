local createVector = vector.create
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local object = setmetatable({}, {
	__mode = "k"
})

local function getTemplates(instance)
	local parts = {}

	for _, part in instance:GetChildren() do
		if not (part:IsA("MeshPart") and string.match(part.Name, "^keycap_[A-Z]$")) then
			continue
		end

		table.insert(parts, part)
	end

	table.sort(parts, function(a, b)
		return a.Name < b.Name
	end)

	if #parts ~= 26 then
		error("AutoKeycapCover requires 26 keycap_A through keycap_Z MeshPart templates.")
	end

	return parts
end

local function resolveOptions(data)
	local v = (data == nil or data.scale == nil) and 1 or data.scale
	local v2 = (data == nil or data.rotationDegrees == nil) and 0 or data.rotationDegrees
	local maxKeycaps = (data == nil or data.maxKeycaps == nil) and 100000 or data.maxKeycaps
	local yieldEvery = (data == nil or data.yieldEvery == nil) and 250 or data.yieldEvery
	local keycapsPerFrame = (data == nil or data.keycapsPerFrame == nil) and 0 or data.keycapsPerFrame

	if v == v and math.abs(v) ~= 1e999 and not (v <= 0) then
		if v2 == v2 and math.abs(v2) ~= 1e999 then
			if maxKeycaps < 1 or maxKeycaps % 1 ~= 0 then
				error("AutoKeycapCover maxKeycaps must be a positive integer.")
			elseif yieldEvery < 0 or yieldEvery % 1 ~= 0 then
				error("AutoKeycapCover yieldEvery must be a non-negative integer.")
			elseif keycapsPerFrame < 0 or keycapsPerFrame % 1 ~= 0 then
				error("AutoKeycapCover keycapsPerFrame must be a non-negative integer.")
			end
		else
			error("AutoKeycapCover rotationDegrees must be finite.")
		end
	else
		error("AutoKeycapCover scale must be a finite positive number.")
	end

	local v6 = {
		scale = math.clamp(v, 0.25, 50),
		rotationDegrees = v2 % 360,
		maxKeycaps = maxKeycaps,
		yieldEvery = yieldEvery,
		keycapsPerFrame = keycapsPerFrame,
		random = 0,
		parent = 0,
		owner = 0,
		baseColor = 0,
		hueOffsetDegrees = 0,
		saturationOffsetPercent = 0,
		valueOffsetPercent = 0
	}
	local random

	if data == nil or data.random == nil then
		random = Random.new()
	else
		random = data.random
	end

	v6.random = random
	local parent

	if data ~= nil then
		parent = data.parent
	end

	v6.parent = parent
	local owner

	if data ~= nil then
		owner = data.owner
	end

	v6.owner = owner
	local baseColor

	if data ~= nil then
		baseColor = data.baseColor
	end

	v6.baseColor = baseColor
	v6.hueOffsetDegrees = (data == nil or data.hueOffsetDegrees == nil) and 0 or data.hueOffsetDegrees
	v6.saturationOffsetPercent = (data == nil or data.saturationOffsetPercent == nil) and 0 or data.saturationOffsetPercent
	v6.valueOffsetPercent = (data == nil or data.valueOffsetPercent == nil) and 0 or data.valueOffsetPercent
	return v6
end

local function getUpwardFace(instance)
	local v = {
		{
			axis = "X",
			vector = instance.CFrame.RightVector,
			thickness = instance.Size.X
		},
		{
			axis = "Y",
			vector = instance.CFrame.UpVector,
			thickness = instance.Size.Y
		},
		{
			axis = "Z",
			vector = instance.CFrame.ZVector,
			thickness = instance.Size.Z
		}
	}
	local v2 = v[1]
	local v3 = math.abs((v2.vector:Dot(createVector(0, 1, 0))))

	for i = 2, #v do
		local v4 = math.abs((v[i].vector:Dot(createVector(0, 1, 0))))

		if not (v3 < v4) then
			continue
		end

		v2 = v[i]
		v3 = v4
	end

	local v4 = v2.vector:Dot(createVector(0, 1, 0)) >= 0 and 1 or -1
	local normal = v2.vector * v4
	local upVector, Y, Z

	if v2.axis == "X" then
		upVector = instance.CFrame.UpVector
		Y = instance.Size.Y
		Z = instance.Size.Z
	elseif v2.axis == "Y" then
		upVector = instance.CFrame.RightVector
		Y = instance.Size.X
		Z = instance.Size.Z
	else
		upVector = instance.CFrame.RightVector
		Y = instance.Size.X
		Z = instance.Size.Y
	end

	local unit = upVector.Unit
	return {
		center = instance.Position + normal * (v2.thickness / 2),
		normal = normal,
		right = unit,
		back = unit:Cross(normal).Unit,
		width = Y,
		depth = Z,
		thickness = v2.thickness
	}
end

local function getLayout(upwardFace, size: Vector3, scale: number)
	local effectiveScale = math.min(scale, upwardFace.width / size.X, upwardFace.depth / size.Z)

	if effectiveScale <= 0 then
		error("AutoKeycapCover target has no usable upward-facing surface.")
	end

	local keyWidth = size.X * effectiveScale
	local keyDepth = size.Z * effectiveScale
	local columns = math.max(1, (math.ceil(upwardFace.width / keyWidth - 0.0001)))
	local rows = math.max(1, (math.ceil(upwardFace.depth / keyDepth - 0.0001)))
	return {
		effectiveScale = effectiveScale,
		keyWidth = keyWidth,
		keyDepth = keyDepth,
		columns = columns,
		rows = rows,
		count = columns * rows,
		spacingX = not (columns > 1) and 0 or (upwardFace.width - keyWidth) / (columns - 1),
		spacingZ = not (rows > 1) and 0 or (upwardFace.depth - keyDepth) / (rows - 1)
	}
end

local function castTargetSurface(_, data, raycastParams, vector2: Vector3)
	local vector3 = vector2 - data.center
	return Workspace:Raycast(
		data.center + data.right * vector3:Dot(data.right) + data.back * vector3:Dot(data.back) + data.normal * 1,
		-data.normal * (data.thickness + 2),
		raycastParams
	)
end

local function isUpwardHit(raycastResult: RaycastResult?, p)
	return raycastResult ~= nil and raycastResult.Instance ~= nil and raycastResult.Normal:Dot(createVector(0, 1, 0)) > 0.05 and raycastResult.Normal:Dot(p.normal) > 0.05
end

local function getSurfaceBasis(data, normal: Vector3)
	local v = data.right - normal * data.right:Dot(normal)

	if v.Magnitude < 0.001 then
		v = data.back - normal * data.back:Dot(normal)
	end

	if v.Magnitude < 0.001 then
		return nil, nil
	end

	local unit = v.Unit
	local unit2 = unit:Cross(normal).Unit

	if unit2:Dot(data.back) < 0 then
		unit = -unit
		unit2 = -unit2
	end

	return unit, unit2
end

local function getSurfacePlacements(instance, upwardFace, layout, size: Vector3, options)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { instance }
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = false
	local v = -upwardFace.width / 2 + layout.keyWidth / 2
	local v2 = -upwardFace.depth / 2 + layout.keyDepth / 2
	local v3 = math.max(0, layout.keyWidth / 2 - math.min(0.01, layout.keyWidth * 0.1))
	local v4 = math.max(0, layout.keyDepth / 2 - math.min(0.01, layout.keyDepth * 0.1))
	local v5 = size.Y * layout.effectiveScale
	local rotationDegrees = math.rad(options.rotationDegrees)
	local cframes = table.create(layout.count)
	local count = 0

	for i = 0, layout.rows - 1 do
		for i2 = 0, layout.columns - 1 do
			local v7 = castTargetSurface(
				instance,
				upwardFace,
				raycastParams,
				upwardFace.center + upwardFace.right * (v + i2 * layout.spacingX) + upwardFace.back * (v2 + i * layout.spacingZ)
			)
			local v8

			if v7 == nil or v7.Instance == nil or not (v7.Normal:Dot(createVector(0, 1, 0)) > 0.05) then
				v8 = false
			else
				v8 = v7.Normal:Dot(upwardFace.normal) > 0.05
			end

			if v8 then
				local surfaceBasis, v9 = getSurfaceBasis(upwardFace, v7.Normal)

				if surfaceBasis ~= nil and v9 ~= nil then
					local v10 = CFrame.fromMatrix(v7.Position, surfaceBasis, v7.Normal, v9) * CFrame.Angles(
						0,
						rotationDegrees,
						0
					)
					local rightVector = v10.RightVector
					local zVector = v10.ZVector
					local flag = true

					for i3 = -1, 1, 2 do
						for i4 = -1, 1, 2 do
							local v12 = castTargetSurface(
								instance,
								upwardFace,
								raycastParams,
								v7.Position + rightVector * (v3 * i3) + zVector * (v4 * i4)
							)
							local v13

							if v12 == nil or v12.Instance == nil or not (v12.Normal:Dot(createVector(0, 1, 0)) > 0.05) then
								v13 = false
							else
								v13 = v12.Normal:Dot(upwardFace.normal) > 0.05
							end

							if v13 then
								continue
							end

							flag = false
							break
						end

						if not flag then
							break
						end
					end

					if flag then
						table.insert(
							cframes,
							CFrame.fromMatrix(
								v7.Position + v7.Normal * (v5 / 2 + 0.005),
								rightVector,
								v7.Normal,
								zVector
							)
						)
					end
				end
			end

			count += 1

			if options.yieldEvery > 0 and count % options.yieldEvery == 0 then
				task.wait()
			end
		end
	end

	return cframes
end

local function getDefaultColor(p)
	return p.Color
end

local function getRandomizedColor(baseColor: Color3, options)
	local HSV, v, v2 = baseColor:ToHSV()
	local v3 = options.hueOffsetDegrees / 360
	local v4 = options.saturationOffsetPercent / 100
	local v5 = options.valueOffsetPercent / 100
	return Color3.fromHSV(
		(HSV + options.random:NextNumber(-v3, v3)) % 1,
		math.clamp(v + options.random:NextNumber(-v4, v4), 0, 1),
		(math.clamp(v2 + options.random:NextNumber(-v5, v5), 0, 1))
	)
end

local function preserveGeneratedSounds(folder)
	for _, sound in folder:GetDescendants() do
		if sound:IsA("Sound") then
			sound.Parent = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearGenerated(p)
	local v = object[p]

	if v ~= nil then
		object[p] = nil
		v.destroyingConnection:Disconnect()
		preserveGeneratedSounds(v.generated)
		v.generated:Destroy()
	end
end

local AutoKeycapCover = {}

function AutoKeycapCover:apply(p, p2)
	local templates = getTemplates(p)
	local options = resolveOptions(p2)
	local upwardFace = getUpwardFace(self)
	local size = templates[1].Size
	local layout = getLayout(upwardFace, size, options.scale)

	if layout.count > options.maxKeycaps then
		error(string.format(
			"AutoKeycapCover requires %d keycaps, exceeding the configured maximum of %d.",
			layout.count,
			options.maxKeycaps
		))
	end

	local canQuery = self.CanQuery
	self.CanQuery = true
	local success, result = pcall(function()
		return (getSurfacePlacements(self, upwardFace, layout, size, options))
	end)
	self.CanQuery = canQuery

	if not success then
		error((tostring(result)))
	end

	if #result == 0 then
		error("AutoKeycapCover could not fit a keycap completely on the target surface.")
	end

	local model = Instance.new("Model")
	model.Name = "Keycaps"
	model:SetAttribute("AutoKeycapCoverVersion", 1)
	model:SetAttribute("RequestedScale", options.scale)
	model:SetAttribute("RotationDegrees", options.rotationDegrees)
	model:SetAttribute("EffectiveScale", layout.effectiveScale)
	model:SetAttribute("CandidateCount", layout.count)
	model:SetAttribute("KeycapCount", 0)
	clearGenerated(self) -- equivalent call inferred; original call site unknown
	model.Parent = options.parent or self
	local owner = options.owner or self
	object[self] = {
		generated = model,
		destroyingConnection = owner.Destroying:Connect(function()
			local v = object[self]

			if v ~= nil and v.generated == model then
				object[self] = nil
			end

			preserveGeneratedSounds(model)
			model:Destroy()
		end)
	}
	local count = 0
	local success2, result2 = pcall(function()
		local baseColor = options.baseColor or self.Color

		for k, v in result do
			if self.Parent == nil or owner.Parent == nil or model.Parent == nil then
				break
			end

			local template = templates[options.random:NextInteger(1, #templates)]
			local clone = template:Clone()
			clone:ClearAllChildren()
			clone.TextureID = ""
			clone.Color = getRandomizedColor(baseColor, options)
			clone.Size = template.Size * layout.effectiveScale * createVector(1, 0.5, 1)
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = true
			clone.CanTouch = false
			clone.CFrame = v * CFrame.new(0, -1, 0)
			clone.Parent = model
			count += 1
			model:SetAttribute("KeycapCount", count)

			if options.keycapsPerFrame > 0 and k % options.keycapsPerFrame == 0 then
				RunService.Heartbeat:Wait()
			end
		end
	end)

	if not success2 then
		clearGenerated(self) -- equivalent call inferred; original call site unknown
		error((tostring(result2)))
	end

	return {
		generated = model,
		count = count,
		candidateCount = layout.count,
		effectiveScale = layout.effectiveScale
	}
end

function AutoKeycapCover.clear(p)
	clearGenerated(p) -- equivalent call inferred; original call site unknown
end

return AutoKeycapCover