local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Crater = {}
local map = workspace:WaitForChild("Map")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { map }
raycastParams.IgnoreWater = true

-- equivalent calls inferred from this helper; original call sites unknown
local function setCollisionGroupSafe(p, value: string?)
	local collisionGroup = value or "debricol"

	if not pcall(function()
		p.CollisionGroup = collisionGroup
	end) then
		p.CollisionGroup = "debricol"
	end
end

local function createRockPart(vector2, material, color, collisionGroup)
	local children = script:GetChildren()
	local clone = nil

	if #children > 0 then
		local part = children[math.random(1, #children)]

		if part and part:IsA("BasePart") then
			clone = part:Clone()
			clone.CollisionGroup = "debricol"
		end
	end

	local v = clone or Instance.new("Part")
	v.Size = vector2
	v.Material = material or Enum.Material.Slate
	v.Color = color or Color3.fromRGB(100, 100, 100)
	v.Anchored = false
	v.CanCollide = true
	v.CanQuery = false
	v.CanTouch = true
	v.CollisionGroup = "nocol"
	v.CastShadow = true
	v.Massless = false
	v.TopSurface = Enum.SurfaceType.Smooth
	v.BottomSurface = Enum.SurfaceType.Smooth
	setCollisionGroupSafe(v, collisionGroup) -- equivalent call inferred; original call site unknown
	return v
end

local function parseOrigin(part)
	if typeof(part) == "CFrame" then
		return part
	end

	if typeof(part) == "Vector3" then
		return CFrame.new(part)
	end

	if typeof(part) == "Instance" and part:IsA("BasePart") then
		return part.CFrame
	end

	return CFrame.new(0, 0, 0)
end

local function parseDirection(direction, data)
	if typeof(direction) == "Vector3" then
		if direction.Magnitude == 0 then
			return createVector(0, 1, 0)
		end

		return direction.Unit
	else
		if typeof(direction) == "CFrame" then
			return direction.LookVector
		end

		if typeof(direction) ~= "string" then
			return data and data.LookVector or createVector(0, 1, 0)
		end

		local lower = direction:lower()

		if lower == "front" then
			return data.LookVector
		elseif lower == "back" then
			return -data.LookVector
		elseif lower == "left" then
			return -data.RightVector
		elseif lower == "right" then
			return data.RightVector
		elseif lower == "up" then
			return data.UpVector
		elseif lower == "down" then
			return -data.UpVector
		elseif lower == "all" then
			local vector2 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			return vector2.Magnitude > 0 and vector2.Unit or createVector(0, 1, 0)
		end

		return data and data.LookVector or createVector(0, 1, 0)
	end
end

local function reflect(vector2, p, p2)
	local dot = vector2:Dot(p)
	return vector2 - (1 + p2) * dot * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySurfaceFromHit(rockPart, raycastResult: RaycastResult?, material, color: Color3)
	if raycastResult and raycastResult.Instance then
		local instance = raycastResult.Instance

		if instance:IsA("BasePart") then
			rockPart.Material = instance.Material
			rockPart.Color = instance.Color
		else
			rockPart.Material = raycastResult.Material
			rockPart.Color = color
		end
	else
		rockPart.Material = material
		rockPart.Color = color
	end
end

local function fadeAndDestroy(instance, fadeTime: number)
	if not (instance and instance.Parent) then
		return
	end

	local tween = TweenService:Create(
		instance,
		TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Size = createVector(0, 0, 0),
			Transparency = 1
		}
	)
	tween:Play()
	tween.Completed:Wait()

	if instance then
		instance:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rayDown(vector2: Vector3, p: number)
	return workspace:Raycast(vector2, Vector3.new(0, -p, 0), raycastParams)
end

local function snapToGround(vector2: Vector3, p: number)
	local v3 = rayDown(vector2 + Vector3.new(0, p + 0.5, 0), p + 120) -- equivalent call inferred; original call site unknown

	if v3 and v3.Position then
		return v3.Position + Vector3.new(0, p, 0), v3.Normal
	end

	return nil, nil
end

local function getRestCFrame(vector2: Vector3, normal: Vector3, vector3: Vector3, landSide: string?)
	local vector4 = Vector3.new(vector3.X, 0, vector3.Z)
	local v = vector4.Magnitude < 0.001 and createVector(0, 0, -1) or vector4.Unit
	local cframe = CFrame.lookAt(vector2, vector2 + v, normal)
	local lower = (landSide or "right"):lower()
	local v2 = lower == "left" and 1.5707963267948966 or 0
	local v3 = lower == "right" and -1.5707963267948966 or v2
	local v4 = lower == "flat" and 0 or v3
	return cframe * CFrame.Angles(0, 0, v4)
end

local function simulateFlyingRockEditMode(rockPart, position: Vector3, vector2: Vector3, cframe: CFrame, vector3: Vector3, lookVector: Vector3, data)
	local gravity = data.Gravity or workspace.Gravity
	local drag = data.Drag or 0.15
	local bounciness = data.Bounciness or 0.25
	local friction = data.Friction or 0.2
	local minSpeed = data.MinSpeed or 1.2
	local maxBounces = data.MaxBounces or 5
	local lifetime = data.Lifetime or 1
	local fadeTime = data.FadeTime or 0.35
	local hardLifetime = data.HardLifetime or 12
	local substeps = data.Substeps or 3
	local landSide = data.LandSide or "right"
	local restTweenTime = data.RestTweenTime or 0.12
	local v = rockPart.Size.Y * 0.5
	local now = os.clock()
	local now2 = os.clock()
	local v2 = false
	local count = 0

	while rockPart and rockPart.Parent do
		local now3 = os.clock()
		local v3 = now3 - now2

		if v3 <= 0 then
			task.wait()
			now2 = now3
		else
			local v4 = v3 > 0.05 and 0.05 or v3
			v2 = hardLifetime <= now3 - now or v2
			local v5 = v4 / substeps
			now2 = now3

			for _ = 1, substeps do
				if v2 then
					break
				end

				vector2 = (vector2 + Vector3.new(0, -gravity, 0) * v5) * math.max(0, 1 - drag * v5)
				local v6 = vector2 * v5
				local raycastResult

				if v6.Magnitude > 0 then
					raycastResult = workspace:Raycast(position, v6, raycastParams)
				end

				if raycastResult then
					local normal = raycastResult.Normal
					position = raycastResult.Position + normal * 0.03
					local dot = vector2:Dot(normal)
					local vector4 = vector2 - (1 + bounciness) * dot * normal
					local dot2 = vector4:Dot(normal)
					local v7 = vector4 - normal * dot2
					vector2 = normal * dot2 + v7 * (1 - friction)
					count += 1

					if maxBounces <= count then
						v2 = true
						break
					end
				else
					position += v6
				end

				local v7 = vector3 * v5

				if v7.Magnitude > 0 then
					cframe *= CFrame.fromAxisAngle(v7.Unit, v7.Magnitude)
				end

				rockPart.CFrame = CFrame.new(position) * cframe
			end

			if v2 then
				break
			end

			if vector2.Magnitude < minSpeed then
				local v8 = rayDown(position + Vector3.new(0, v + 0.5, 0), v + 120) -- equivalent call inferred; original call site unknown
				local v9

				if v8 and v8.Position then
					v9 = v8.Position + Vector3.new(0, v, 0)
					local _ = v8.Normal
				end

				if v9 then
					break
				end
			end

			task.wait()
		end
	end

	if rockPart and rockPart.Parent then
		local v5 = rayDown(rockPart.Position + Vector3.new(0, v + 0.5, 0), v + 120) -- equivalent call inferred; original call site unknown
		local v6, normal

		if v5 and v5.Position then
			v6 = v5.Position + Vector3.new(0, v, 0)
			normal = v5.Normal
		end

		if v6 and normal then
			local restCFrame = getRestCFrame(v6, normal, lookVector, landSide)
			rockPart.Anchored = true
			rockPart.CanCollide = false
			rockPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			rockPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			local tween = TweenService:Create(
				rockPart,
				TweenInfo.new(restTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = restCFrame
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		if lifetime and lifetime > 0 then
			task.wait(lifetime)
		end

		fadeAndDestroy(rockPart, fadeTime)
	end
end

local function spawnOneRock(data, p, p2, parent)
	local minSize = data.MinSize or createVector(0.15, 0.15, 0.15)
	local maxSize = data.MaxSize or createVector(0.5, 0.5, 0.5)
	local speedMin = data.SpeedMin or data.Speed or 35
	local speedMax = data.SpeedMax or data.Speed or 35
	local v = math.random(speedMin, speedMax)
	local material = data.Material or Enum.Material.Slate
	local color = data.Color or Color3.fromRGB(100, 100, 100)
	local spreadAngle = math.rad(data.SpreadAngle or 45)
	local spinAmount = data.SpinAmount or 10
	local collisionGroup = data.CollisionGroup or "debricol"
	local fadeTime = data.FadeTime or 0.35
	local hardLifetime = data.HardLifetime or 12
	local lifetime = data.Lifetime or 1
	local maxBounces = data.MaxBounces or 5
	local landSide = data.LandSide or "right"
	local restTweenTime = data.RestTweenTime or 0.12
	local vector2 = Vector3.new(
		math.random() * (maxSize.X - minSize.X) + minSize.X,
		math.random() * (maxSize.Y - minSize.Y) + minSize.Y,
		math.random() * (maxSize.Z - minSize.Z) + minSize.Z
	)
	local rockPart = createRockPart(vector2, material, color, collisionGroup)

	if not rockPart then
		return
	end

	local vector3 = Vector3.new((math.random() - 0.5) * 0.2, (math.random() - 0.5) * 0.2, (math.random() - 0.5) * 0.2)
	local v2 = p.Position + vector3
	local v3 = v2 + createVector(0, 6, 0)
	local raycastResult = workspace:Raycast(v3, createVector(0, -100, 0), raycastParams)

	if raycastResult and raycastResult.Position then
		applySurfaceFromHit(rockPart, raycastResult, material, color) -- equivalent call inferred; original call site unknown
		v2 = raycastResult.Position + Vector3.new(0, vector2.Y / 2, 0)
	end

	local cframe = CFrame.Angles(
		math.rad((math.random(0, 360))),
		math.rad((math.random(0, 360))),
		(math.rad((math.random(0, 360))))
	)
	rockPart.CFrame = CFrame.new(v2) * cframe
	rockPart.Parent = parent
	local cframe2 = CFrame.fromEulerAnglesXYZ(
		(math.random() - 0.5) * spreadAngle,
		(math.random() - 0.5) * spreadAngle,
		(math.random() - 0.5) * spreadAngle
	)
	local lookVector = (CFrame.lookAt(createVector(0, 0, 0), p2) * cframe2).LookVector
	local assemblyLinearVelocity = lookVector * v
	local vector4 = Vector3.new(
		(math.random() - 0.5) * spinAmount,
		(math.random() - 0.5) * spinAmount,
		(math.random() - 0.5) * spinAmount
	)

	if RunService:IsRunning() then
		rockPart.Anchored = false
		rockPart.CanCollide = true
		rockPart.AssemblyLinearVelocity = assemblyLinearVelocity
		rockPart.AssemblyAngularVelocity = vector4
		local count = 0
		local flag = false
		local touchedConnection = nil
		touchedConnection = rockPart.Touched:Connect(function(part)
			if flag or not (part and part:IsA("BasePart")) or not part:IsDescendantOf(map) then
				return
			end

			count += 1

			if maxBounces <= count then
				flag = true

				if touchedConnection then
					touchedConnection:Disconnect()
				end

				local v5 = rockPart.Size.Y * 0.5
				local v8 = rayDown(rockPart.Position + Vector3.new(0, v5 + 0.5, 0), v5 + 120) -- equivalent call inferred; original call site unknown
				local v9, normal

				if v8 and v8.Position then
					v9 = v8.Position + Vector3.new(0, v5, 0)
					normal = v8.Normal
				end

				if v9 and normal then
					local restCFrame = getRestCFrame(v9, normal, lookVector, landSide)
					rockPart.AssemblyLinearVelocity = createVector(0, 0, 0)
					rockPart.AssemblyAngularVelocity = createVector(0, 0, 0)
					rockPart.Anchored = true
					rockPart.CanCollide = false
					TweenService:Create(
						rockPart,
						TweenInfo.new(restTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = restCFrame
						}
					):Play()
				end

				task.delay(lifetime, function()
					if rockPart and rockPart.Parent then
						fadeAndDestroy(rockPart, fadeTime)
					end
				end)
			end
		end)
		task.delay(hardLifetime, function()
			if rockPart and rockPart.Parent then
				if touchedConnection then
					touchedConnection:Disconnect()
				end

				fadeAndDestroy(rockPart, fadeTime)
			end
		end)
	else
		rockPart.Anchored = true
		rockPart.CanCollide = false
		task.spawn(function()
			simulateFlyingRockEditMode(rockPart, v2, assemblyLinearVelocity, cframe, vector4, lookVector, data)
		end)
	end

	return rockPart
end

function Crater.FlyingRocks(options)
	local v = options or {}
	local direction = v.Direction or "Up"
	local parent = v.Parent or workspace:FindFirstChild("Thrown") or workspace
	local offset = v.Offset or createVector(0, 0, 0)
	local duration = v.Duration or 0
	local rate = v.Rate or 10
	local result = {}

	if duration > 0 then
		local v2 = os.clock() + duration

		while os.clock() < v2 do
			local v3 = parseOrigin(v.Origin) * CFrame.new(offset)
			spawnOneRock(v, v3, parseDirection(direction, v3), parent)
			task.wait(1 / rate)
		end
	else
		for _ = 1, v.Amount or 6 do
			local v2 = parseOrigin(v.Origin) * CFrame.new(offset)
			local v3 = parseDirection(direction, v2)
			table.insert(result, (spawnOneRock(v, v2, v3, parent)))
		end
	end

	return result
end

local random = Random.new()

local function applySurfaceProps(part, raycastResult: RaycastResult?, data, useSurfaceAppearance: boolean)
	if useSurfaceAppearance and raycastResult and raycastResult.Instance then
		local instance = raycastResult.Instance

		if instance:IsA("BasePart") then
			part.Material = instance.Material
			part.Color = instance.Color
			part.Transparency = instance.Transparency
			part.Reflectance = instance.Reflectance
		else
			part.Material = raycastResult.Material
			part.Color = data.colorOverride or Color3.fromRGB(127, 127, 127)
		end
	else
		if data.materialOverride then
			part.Material = data.materialOverride
		end

		if data.colorOverride then
			part.Color = data.colorOverride
		end

		if data.transparencyOverride then
			part.Transparency = data.transparencyOverride
		end

		if data.reflectanceOverride then
			part.Reflectance = data.reflectanceOverride
		end
	end
end

function Crater.GroundRocks(data)
	local v = {
		showTime = 0.25,
		hideTime = 3,
		easingStyle = Enum.EasingStyle.Quad,
		easingDirection = Enum.EasingDirection.Out,
		trailGrowTime = 0.1,
		trailShrinkTime = 0.3,
		startAngleDeg = 11,
		placementRayLength = 10,
		baseOffsetHeight = 5,
		baseOffsetCFrame = CFrame.Angles(-1.5707963267948966, 0, 0),
		maxRockRotation = 0.7,
		sizeJitter = {
			x = NumberRange.new(0.6, 1.1),
			y = NumberRange.new(0.9, 1),
			z = NumberRange.new(0.9, 1.4)
		},
		rotationJitter = {
			x = NumberRange.new(-0.7, -0.4),
			y = NumberRange.new(-0.1, 0.1),
			z = NumberRange.new(-0.1, 0.2)
		},
		lingerTime = NumberRange.new(7, 9),
		shrinkFactor = 0.5,
		hideDepthMultiplier = 1,
		anchored = true,
		canCollide = true,
		canQuery = true,
		canTouch = true,
		castShadow = true,
		collisionGroup = "debricol",
		useSurfaceAppearance = true,
		colorOverride = nil,
		materialOverride = nil,
		transparencyOverride = nil,
		reflectanceOverride = nil,
		finalSizeScalar = NumberRange.new(0.5, 1),
		growTime = 0.1,
		shrinkDelay = NumberRange.new(3, 4),
		shrinkTime = 0.3,
		TrailuseSurfaceAppearance = true,
		TrailcolorOverride = nil,
		TrailmaterialOverride = nil,
		TrailtransparencyOverride = nil,
		TrailreflectanceOverride = nil
	}

	if data.config then
		for k, v2 in pairs(data.config) do
			if v[k] ~= nil then
				v[k] = v2
			end
		end
	end

	local raycastResult = workspace:Raycast(data.origin, data.direction, raycastParams)

	if not raycastResult then
		return {}
	end

	local startAngleDeg = v.startAngleDeg
	local v2 = 360 / data.amount
	local result = {}

	for _ = 1, data.amount do
		local v3 = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * v.baseOffsetCFrame * CFrame.fromEulerAnglesXYZ(
			0,
			math.rad(startAngleDeg),
			0
		) * CFrame.new(data.radius / 2 + data.radius / 15, data.offsetHeight or v.baseOffsetHeight, 0)
		startAngleDeg += v2
		local raycastResult2 = workspace:Raycast(
			v3.Position,
			-raycastResult.Normal * v.placementRayLength,
			raycastParams
		)

		if not raycastResult2 then
			continue
		end

		local vector2 = Vector3.new(
			data.size.X * random:NextNumber(v.sizeJitter.x.Min, v.sizeJitter.x.Max),
			data.size.Y * random:NextNumber(v.sizeJitter.y.Min, v.sizeJitter.y.Max),
			data.size.Z * random:NextNumber(v.sizeJitter.z.Min, v.sizeJitter.z.Max)
		)
		local v4 = raycastResult2.Normal * (data.size.Y * random:NextNumber(0.325, 0.45))
		local cframe = CFrame.lookAt(raycastResult2.Position - v4, raycastResult.Position, raycastResult.Normal)
		local maxRotation = data.maxRotation or v.maxRockRotation
		local v5 = math.clamp(
			random:NextNumber(v.rotationJitter.x.Min, v.rotationJitter.x.Max),
			-maxRotation,
			maxRotation
		)
		local v6 = cframe * CFrame.Angles(
			v5,
			random:NextNumber(v.rotationJitter.y.Min, v.rotationJitter.y.Max),
			random:NextNumber(v.rotationJitter.z.Min, v.rotationJitter.z.Max)
		)
		local cFrame = v6 + raycastResult2.Normal * -vector2.Y / 2
		local part = Instance.new("Part")
		part.Size = vector2
		part.CFrame = cFrame
		part.Anchored = v.anchored
		part.CanCollide = v.canCollide
		part.CanQuery = v.canQuery
		part.CanTouch = v.canTouch
		part.CastShadow = v.castShadow
		applySurfaceProps(part, raycastResult2, v, v.useSurfaceAppearance)
		part.Parent = workspace:FindFirstChild("Ignore") or workspace:FindFirstChild("Thrown") or workspace
		setCollisionGroupSafe(part, v.collisionGroup) -- equivalent call inferred; original call site unknown
		table.insert(result, part)
		TweenService:Create(part, TweenInfo.new(v.showTime), {
			Position = v6.Position
		}):Play()
		local number = random:NextNumber(v.lingerTime.Min, v.lingerTime.Max)
		local v8 = v6 + raycastResult2.Normal * -(vector2.Y * v.hideDepthMultiplier)
		local tweenInfo = TweenInfo.new(v.hideTime, v.easingStyle, v.easingDirection)
		local tweenInfo2 = TweenInfo.new(v.hideTime, v.easingStyle, v.easingDirection)
		local v9 = TweenService:Create(part, tweenInfo, {
			Position = v8.Position
		})
		local v10 = TweenService:Create(part, tweenInfo2, {
			Size = part.Size * v.shrinkFactor
		})
		task.delay(number, function()
			v9:Play()
			v10:Play()
			Debris:AddItem(part, tweenInfo.Time)
		end)
	end

	return result
end

return Crater