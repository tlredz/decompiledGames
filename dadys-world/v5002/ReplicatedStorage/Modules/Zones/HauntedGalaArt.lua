local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HauntedGalaConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Zones"):WaitForChild("HauntedGalaConfig"))
local v = nil
local now = 0
local v2 = nil
local count = 0
local colorCorrectionEffect = nil
local bloomEffect = nil
local v3 = nil
local folder = nil
local v4 = {}
local v5 = {}
local count2 = 0
local v6 = nil
local count3 = 0
local renderSteppedConnection = nil

local function debugLog(...)
	print("[HauntedGalaArt]", ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMap()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")
	return currentRoom and currentRoom:FindFirstChildOfClass("Model")
end

local function tween(p, duration, p2)
	local tween2 = TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), p2)
	tween2:Play()
	return tween2
end

local function captureOriginals()
	if v2 then
		return
	end

	v2 = {
		lighting = {
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			Brightness = Lighting.Brightness,
			FogColor = Lighting.FogColor,
			FogEnd = Lighting.FogEnd
		},
		atmosphere = nil,
		lights = {}
	}
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

	if atmosphere then
		v2.atmosphere = {
			instance = atmosphere,
			Density = atmosphere.Density,
			Color = atmosphere.Color,
			Haze = atmosphere.Haze
		}
	end

	local map = getMap() -- equivalent call inferred; original call site unknown

	if map then
		for _, light in ipairs(map:GetDescendants()) do
			if light:IsA("Light") then
				v2.lights[light] = {
					Color = light.Color,
					Brightness = light.Brightness
				}
			end
		end
	end

	local count4 = 0

	for _ in pairs(v2.lights) do
		count4 += 1
	end

	debugLog(string.format(
		"Captured originals (atmosphere: %s, map lights: %d)",
		tostring(v2.atmosphere ~= nil),
		count4
	))
end

local function findTemplate(childName, childName2)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local hauntedGala = assets and assets:FindFirstChild("HauntedGala")
	local child = hauntedGala and hauntedGala:FindFirstChild(childName)
	local instance = child and child:FindFirstChild(childName2)

	if instance and (instance:IsA("BasePart") or instance:IsA("Model")) then
		return instance
	end

	return nil
end

local function cloneTemplate(template, name)
	local clone = template:Clone()
	clone.Name = name
	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)

	for _, part in ipairs(descendants) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setRootCFrame(model, cFrame)
	if model:IsA("Model") then
		model:PivotTo(cFrame)
	else
		model.CFrame = cFrame
	end
end

local function makeCameraEmitterPart(cameraParticles)
	local part = Instance.new("Part")
	part.Name = "HauntedGalaCameraParticles"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = cameraParticles.boxSize
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = cameraParticles.texture
	particleEmitter.Color = cameraParticles.color
	particleEmitter.Rate = cameraParticles.rate
	particleEmitter.Lifetime = cameraParticles.lifetime
	particleEmitter.Size = cameraParticles.size
	particleEmitter.Transparency = cameraParticles.transparency
	particleEmitter.Speed = cameraParticles.speed
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.LightEmission = cameraParticles.lightEmission or 0
	particleEmitter.LockedToPart = true
	particleEmitter.Shape = Enum.ParticleEmitterShape.Box
	particleEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	particleEmitter.Parent = part
	return part
end

local function findLowestFloorPosition(folder2)
	local v7 = nil

	for _, part in ipairs(folder2:GetDescendants()) do
		if not (part.Name == "Floor" and part:IsA("BasePart") and (not v7 or part.Position.Y < v7.Position.Y)) then
			continue
		end

		v7 = part
	end

	if v7 then
		return v7.Position + Vector3.new(0, v7.Size.Y / 2, 0)
	end

	local boundingBox, v8 = folder2:GetBoundingBox()
	warn("[HauntedGalaArt] No part named Floor in map - placing GroundFog at the map's bounding box bottom")
	return boundingBox.Position - Vector3.new(0, v8.Y / 2, 0)
end

local function findCloudY(folder2, offsetBelowCeiling)
	local v7 = nil

	for _, part in ipairs(folder2:GetDescendants()) do
		if not (part.Name == "Ceiling" and part:IsA("BasePart") and (not v7 or part.Position.Y > v7.Position.Y)) then
			continue
		end

		v7 = part
	end

	if v7 then
		return v7.Position.Y - v7.Size.Y / 2 - offsetBelowCeiling
	end

	local boundingBox, v8 = folder2:GetBoundingBox()
	warn("[HauntedGalaArt] No part named Ceiling in map - placing Clouds under the map's bounding box top")
	return boundingBox.Position.Y + v8.Y / 2 - offsetBelowCeiling
end

local function getMapExtentsXZ(map)
	local boundingBox, v7 = map:GetBoundingBox()
	local v8 = v7 / 2
	local v9 = 1e999
	local v10 = -1e999
	local v11 = 1e999
	local v12 = -1e999

	for _, v13 in ipairs({ -1, 1 }) do
		for _, v14 in ipairs({ -1, 1 }) do
			for _, v15 in ipairs({ -1, 1 }) do
				local v16 = boundingBox * Vector3.new(v8.X * v13, v8.Y * v14, v8.Z * v15)
				v9 = math.min(v9, v16.X)
				v10 = math.max(v10, v16.X)
				v11 = math.min(v11, v16.Z)
				v12 = math.max(v12, v16.Z)
			end
		end
	end

	return v9, v10, v11, v12
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCloudEmittersLocked(p, lockedToPart)
	for _, emitter in ipairs(p.emitters) do
		emitter.LockedToPart = lockedToPart
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCloudEmittersEnabled(p, enabled)
	for _, emitter in ipairs(p.emitters) do
		emitter.Enabled = enabled
	end
end

local function getFootprintHalfExtents(data, size)
	local xVector = data.XVector
	local yVector = data.YVector
	local zVector = data.ZVector
	return
		(math.abs(xVector.X) * size.X + math.abs(yVector.X) * size.Y + math.abs(zVector.X) * size.Z) / 2,
		(math.abs(xVector.Z) * size.X + math.abs(yVector.Z) * size.Y + math.abs(zVector.Z) * size.Z) / 2
end

local function destroyClouds()
	count2 += 1

	for _, v7 in ipairs(v5) do
		if v7.tween then
			v7.tween:Cancel()
		end

		v7.part:Destroy()
	end

	v5 = {}
end

local function buildClouds(mode, p)
	destroyClouds()
	local template = findTemplate(mode, "Clouds")
	local clouds = p.clouds

	if not (template and clouds and clouds.enabled) then
		return
	end

	if not template:IsA("BasePart") then
		warn("[HauntedGalaArt] Clouds template must be a BasePart (its CFrame is tweened) - skipping Clouds")
		return
	end

	local map = getMap() -- equivalent call inferred; original call site unknown

	if not map then
		warn("[HauntedGalaArt] No map in CurrentRoom - skipping Clouds")
		return
	end

	local cloudY = findCloudY(map, clouds.offsetBelowCeiling)
	local mapExtentsXZ, v7, v8, v9 = getMapExtentsXZ(map)
	local rotation = template:GetPivot().Rotation
	local v10 = count2
	local footprintHalfExtents, v11 = getFootprintHalfExtents(CFrame.new() * rotation, template.Size)

	local function isStillRunning(p2)
		return v10 == count2 and p2.Parent ~= nil
	end

	local function overlapsActiveCloud(vector, p2)
		for _, v12 in ipairs(v5) do
			if not (v12 ~= p2 and v12.active) then
				continue
			end

			local position = v12.part.Position
			local v13 = 2 * footprintHalfExtents + clouds.spacing
			local v14 = 2 * v11 + clouds.spacing

			if math.abs(vector.X - position.X) < v13 and math.abs(vector.Z - position.Z) < v14 then
				return true
			end
		end

		return false
	end

	local function findFreeStartCFrame(p2)
		local v12 = math.min(v8 + clouds.sweepDistance, v9)

		for _ = 1, clouds.placementAttempts do
			local v13 = mapExtentsXZ + math.random() * math.max(v7 - mapExtentsXZ, 0)
			local v14 = v12 + math.random() * math.max(v9 - v12, 0)
			local vector = Vector3.new(v13, cloudY, v14)

			if not overlapsActiveCloud(vector, p2) then
				return CFrame.new(vector) * rotation
			end
		end

		return nil
	end

	local function placeCloud(p2)
		local freeStartCFrame = findFreeStartCFrame(p2)

		if not freeStartCFrame then
			setCloudEmittersEnabled(p2, false) -- equivalent call inferred; original call site unknown
			debugLog(p2.part.Name, "found no free spot - hiding and retrying")

			repeat
				task.wait(clouds.retryDelay)
				local part = p2.part
				local v12

				if v10 == count2 then
					v12 = part.Parent ~= nil
				else
					v12 = false
				end

				if not v12 then
					return false
				end

				freeStartCFrame = findFreeStartCFrame(p2)
			until freeStartCFrame
		end

		setRootCFrame(p2.part, freeStartCFrame) -- equivalent call inferred; original call site unknown
		p2.active = true
		setCloudEmittersEnabled(p2, true) -- equivalent call inferred; original call site unknown
		return true
	end

	for i = 1, clouds.cloudCount do
		local template2 = cloneTemplate(template, "HauntedGalaCloud" .. i)
		local emitters = {}

		for _, emitter in ipairs(template2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.LockedToPart = true
			emitter.Enabled = false
			table.insert(emitters, emitter)
		end

		local v12 = {
			part = template2,
			emitters = emitters,
			tween = nil,
			active = false
		}
		table.insert(v5, v12)
		template2.Parent = workspace
		task.spawn(function()
			if not placeCloud(v12) then
				return
			end

			while true do
				local part = template2
				local v16

				if v10 == count2 then
					v16 = part.Parent ~= nil
				else
					v16 = false
				end

				if not v16 then
					break
				end

				local v17 = clouds.sweepDistance * (clouds.minSweepFraction + math.random() * (1 - clouds.minSweepFraction))
				local cFrame = template2:GetPivot() - Vector3.new(0, 0, v17)
				v12.tween = TweenService:Create(
					template2,
					TweenInfo.new(v17 / clouds.sweepSpeed, Enum.EasingStyle.Linear),
					{
						CFrame = cFrame
					}
				)
				v12.tween:Play()
				v12.tween.Completed:Wait()
				local part2 = template2
				local v20

				if v10 == count2 then
					v20 = part2.Parent ~= nil
				else
					v20 = false
				end

				if not v20 then
					break
				end

				v12.active = false
				setCloudEmittersLocked(v12, false) -- equivalent call inferred; original call site unknown
				RunService.Heartbeat:Wait()
				local part3 = template2
				local v23

				if v10 == count2 then
					v23 = part3.Parent ~= nil
				else
					v23 = false
				end

				if not (v23 and placeCloud(v12)) then
					break
				end

				RunService.Heartbeat:Wait()
				local part4 = template2
				local v25

				if v10 == count2 then
					v25 = part4.Parent ~= nil
				else
					v25 = false
				end

				if not v25 then
					break
				end

				setCloudEmittersLocked(v12, true) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	debugLog(string.format(
		"Spawning %d Clouds for %s at Y %.1f (up to %d studs per sweep at %s studs/s)",
		clouds.cloudCount,
		mode,
		cloudY,
		clouds.sweepDistance,
		(tostring(clouds.sweepSpeed))
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCloudParts()
	count3 += 1

	if v6 then
		v6:Destroy()
		v6 = nil
	end
end

local function buildCloudParts(mode, p)
	destroyCloudParts() -- equivalent call inferred; original call site unknown
	local template = findTemplate(mode, "CloudPart")
	local cloudParts = p.cloudParts

	if not (template and cloudParts and cloudParts.enabled) then
		return
	end

	if not template:IsA("BasePart") then
		warn("[HauntedGalaArt] CloudPart template must be a BasePart (its CFrame and Transparency are tweened) - skipping CloudParts")
		return
	end

	local map = getMap() -- equivalent call inferred; original call site unknown

	if not map then
		warn("[HauntedGalaArt] No map in CurrentRoom - skipping CloudParts")
		return
	end

	local cloudY = findCloudY(map, cloudParts.offsetBelowCeiling)
	local mapExtentsXZ, v7, v8, v9 = getMapExtentsXZ(map)
	local rotation = template:GetPivot().Rotation

	if cloudParts.flipUpsideDown then
		rotation *= CFrame.Angles(3.141592653589793, 0, 0)
	end

	local size = template.Size * cloudParts.sizeStartScale
	local size2 = template.Size * cloudParts.sizeEndScale
	local v12 = cloudParts.fadeInTime + cloudParts.holdTime + cloudParts.fadeOutTime
	local v13 = count3
	local folder2 = Instance.new("Folder")
	folder2.Name = "HauntedGalaCloudParts"
	folder2.Parent = workspace
	v6 = folder2

	local function collectFadeTargets(folder3)
		local result = {
			{
				instance = folder3,
				visible = folder3.Transparency
			}
		}

		for _, decal in ipairs(folder3:GetDescendants()) do
			if decal:IsA("Decal") then
				table.insert(result, {
					instance = decal,
					visible = decal.Transparency
				})
			end
		end

		return result
	end

	local function fadeTo(list, duration, p2)
		for _, v14 in ipairs(list) do
			local transparency = 1 + (v14.visible - 1) * p2
			TweenService:Create(v14.instance, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Transparency = transparency
			}):Play()
		end
	end

	local function spawnCloudPart()
		local v14 = mapExtentsXZ + math.random() * math.max(v7 - mapExtentsXZ, 0)
		local v15 = v8 + math.random() * math.max(v9 - v8, 0)
		local v16 = cloudY + (math.random() * 2 - 1) * cloudParts.heightJitter
		local cFrame = CFrame.new(v14, v16, v15) * rotation
		local template2 = cloneTemplate(template, "CloudPart")
		local v18 = collectFadeTargets(template2)

		for _, v19 in ipairs(v18) do
			v19.instance.Transparency = 1
		end

		template2.Size = size
		template2.CFrame = cFrame
		template2.Parent = folder2
		TweenService:Create(template2, TweenInfo.new(v12, Enum.EasingStyle.Linear), {
			CFrame = cFrame - Vector3.new(0, 0, cloudParts.driftSpeed * v12)
		}):Play()
		TweenService:Create(template2, TweenInfo.new(v12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = size2
		}):Play()
		fadeTo(v18, cloudParts.fadeInTime, 1)
		task.delay(cloudParts.fadeInTime + cloudParts.holdTime, function()
			if template2.Parent then
				fadeTo(v18, cloudParts.fadeOutTime, 0)
			end
		end)
		task.delay(v12 + 0.1, function()
			template2:Destroy()
		end)
	end

	task.spawn(function()
		while v13 == count3 and folder2.Parent do
			if #folder2:GetChildren() < cloudParts.maxActive then
				spawnCloudPart()
			end

			task.wait(cloudParts.spawnInterval)
		end
	end)
	debugLog(string.format(
		"Started CloudPart stream for %s at Y %.1f (every %.2fs, %.0fs life, max %d)",
		mode,
		cloudY,
		cloudParts.spawnInterval,
		v12,
		cloudParts.maxActive
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCameraParticles()
	if v3 then
		v3:Destroy()
		v3 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyGroundFog()
	if folder then
		folder:Destroy()
		folder = nil
	end

	v4 = {}
end

local function buildCameraParticles(p, data)
	destroyCameraParticles() -- equivalent call inferred; original call site unknown
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and data.cameraParticlesEnabled ~= false) then
		return
	end

	local template = findTemplate(p, "CameraParticles")

	if template then
		v3 = cloneTemplate(template, "HauntedGalaCameraParticles")
		debugLog("Using CameraParticles template for", p)
	elseif data.cameraParticles then
		v3 = makeCameraEmitterPart(data.cameraParticles)
	end

	if v3 then
		setRootCFrame(v3, currentCamera.CFrame * data.cameraOffset) -- equivalent call inferred; original call site unknown
		v3.Parent = currentCamera
	end
end

local function buildGroundFog(mode, p)
	destroyGroundFog() -- equivalent call inferred; original call site unknown
	local template = findTemplate(mode, "GroundFog")

	if not template then
		return
	end

	local map = getMap() -- equivalent call inferred; original call site unknown

	if not map then
		warn("[HauntedGalaArt] No map in CurrentRoom - skipping GroundFog")
		return
	end

	folder = cloneTemplate(template, "HauntedGalaGroundFog")
	local lowestFloorPosition = findLowestFloorPosition(map)
	setRootCFrame(folder, CFrame.new(lowestFloorPosition + Vector3.new(0, p.groundFogHeight, 0))) -- equivalent call inferred; original call site unknown

	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		table.insert(v4, {
			emitter = emitter,
			baseRate = emitter.Rate
		})
		emitter.Rate = 0
	end

	folder.Parent = workspace
	debugLog(string.format("Placed GroundFog template for %s at Y %.1f (%d emitters)", mode, lowestFloorPosition.Y, #v4))
end

local function applyLighting(data, transitionTime)
	local v8 = {
		Ambient = data.ambient,
		OutdoorAmbient = data.outdoorAmbient,
		Brightness = data.brightness
	}
	TweenService:Create(Lighting, TweenInfo.new(transitionTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v8):Play()
	local fogRollInTime = data.fogRollInTime or transitionTime

	if v2.atmosphere and v2.atmosphere.instance.Parent then
		local instance = v2.atmosphere.instance
		local v9 = {
			Density = data.atmosphereDensity,
			Color = data.atmosphereColor,
			Haze = data.atmosphereHaze
		}
		TweenService:Create(instance, TweenInfo.new(fogRollInTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v9):Play()
	else
		local v10 = {
			FogColor = data.fogColor,
			FogEnd = data.fogEnd
		}
		TweenService:Create(
			Lighting,
			TweenInfo.new(fogRollInTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			v10
		):Play()
	end

	if not colorCorrectionEffect then
		colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "HauntedGalaColor"
		colorCorrectionEffect.Parent = Lighting
	end

	local v9 = colorCorrectionEffect
	local v10 = {
		TintColor = data.colorTint,
		Saturation = data.colorSaturation,
		Contrast = data.colorContrast,
		Brightness = data.colorBrightness
	}
	TweenService:Create(v9, TweenInfo.new(transitionTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v10):Play()

	if not bloomEffect then
		bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "HauntedGalaBloom"
		bloomEffect.Intensity = 0
		bloomEffect.Parent = Lighting
	end

	local v11 = bloomEffect
	local v12 = {
		Intensity = data.bloomIntensity,
		Size = data.bloomSize,
		Threshold = data.bloomThreshold
	}
	TweenService:Create(v11, TweenInfo.new(transitionTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v12):Play()

	for k, light in pairs(v2.lights) do
		if not k.Parent then
			continue
		end

		local v13 = {
			Color = data.lightColor,
			Brightness = light.Brightness * data.lightBrightnessScale
		}
		TweenService:Create(k, TweenInfo.new(transitionTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v13):Play()
	end
end

local function restoreLighting(duration)
	local v7 = v2

	if not v7 then
		return
	end

	local lighting = v7.lighting
	TweenService:Create(Lighting, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), lighting):Play()

	if v7.atmosphere and v7.atmosphere.instance.Parent then
		local instance = v7.atmosphere.instance
		local v9 = {
			Density = v7.atmosphere.Density,
			Color = v7.atmosphere.Color,
			Haze = v7.atmosphere.Haze
		}
		TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v9):Play()
	end

	for k, light in pairs(v7.lights) do
		if not k.Parent then
			continue
		end

		local v9 = {
			Color = light.Color,
			Brightness = light.Brightness
		}
		TweenService:Create(k, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v9):Play()
	end

	local v9 = colorCorrectionEffect
	local v10 = bloomEffect
	colorCorrectionEffect = nil
	bloomEffect = nil

	if v9 then
		local v11 = {
			TintColor = Color3.new(1, 1, 1),
			Saturation = 0,
			Contrast = 0,
			Brightness = 0
		}
		TweenService:Create(v9, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), v11):Play()
	end

	if v10 then
		TweenService:Create(v10, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Intensity = 0
		}):Play()
	end

	count += 1
	local v11 = count
	task.delay(duration + 0.1, function()
		if v9 then
			v9:Destroy()
		end

		if v10 then
			v10:Destroy()
		end

		if v11 == count and not v then
			v2 = nil
			debugLog("Restore complete - originals released")
		end
	end)
end

local function onRenderStep()
	local v7 = v and HauntedGalaConfig.VISUALS[v]

	if not v7 then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if v3 and currentCamera then
		setRootCFrame(v3, currentCamera.CFrame * v7.cameraOffset) -- equivalent call inferred; original call site unknown
	end

	if #v4 > 0 then
		local fogRollInTime = v7.fogRollInTime or 1
		local v8 = math.clamp((os.clock() - now) / fogRollInTime, 0, 1)

		for _, v9 in ipairs(v4) do
			v9.emitter.Rate = v9.baseRate * v8
		end
	end
end

local HauntedGalaArt = {}

function HauntedGalaArt.Activate(p)
	local mode = HauntedGalaConfig.ResolveMode(p)

	if v == mode then
		return
	end

	local v7 = HauntedGalaConfig.VISUALS[mode]
	local v8 = v ~= nil
	count += 1
	captureOriginals()
	v = mode
	now = os.clock()
	applyLighting(v7, v7.transitionTime)
	buildCameraParticles(mode, v7)
	buildGroundFog(mode, v7)
	buildClouds(mode, v7)
	buildCloudParts(mode, v7)

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(onRenderStep)
	end

	debugLog(string.format("%s mode: %s", v8 and "Swapped to" or "Activated", mode))
end

function HauntedGalaArt.Deactivate()
	if not v then
		return
	end

	debugLog("Deactivating mode:", v)
	v = nil

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	destroyCameraParticles() -- equivalent call inferred; original call site unknown
	destroyGroundFog() -- equivalent call inferred; original call site unknown
	destroyClouds()
	destroyCloudParts() -- equivalent call inferred; original call site unknown
	restoreLighting(1.5)
end

function HauntedGalaArt.OnRespawn()
	if not v then
		return
	end

	buildCameraParticles(v, HauntedGalaConfig.VISUALS[v])
	debugLog("Reattached camera particles after respawn")
end

function HauntedGalaArt.GetMode()
	return v
end

return HauntedGalaArt