local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("StormyLightningStrike")
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local vfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("vfx")
local lightningExplosion = vfx:WaitForChild("LightningExplosion")
local postFire = vfx:WaitForChild("PostFire")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = {
	BoltSegments = 10,
	BoltOffsetMax = 6,
	BoltThickness = 0.55,
	BoltHeight = 100,
	BoltColor = Color3.fromRGB(195, 175, 255),
	BoltCoreColor = Color3.fromRGB(255, 255, 255),
	FormDelayPerSeg = 0.005,
	FormInitialThick = 0.2,
	FormGrowTime = 0.01,
	PulseCount = 4,
	PulseSpeed = 0.001,
	PulseThickMult = 35,
	PulseWaveWidth = 6,
	PulseReturnTime = 0.04,
	BranchChance = 0.2,
	BranchSegsMin = 1,
	BranchSegsMax = 2,
	BranchThickness = 0.28,
	BranchOffsetMax = 5,
	BranchAngleMax = 55,
	SubBranchChance = 0.15,
	DeathFlickerTime = 0.01,
	DeathFlickerRate = 0.01,
	DeathThickMin = 0.001,
	DeathThickMaxMult = 0.1,
	FadeDuration = 0.01,
	FlashBrightness = 1,
	AmbientFlash = Color3.fromRGB(185, 175, 225),
	PreFlashDuration = 0.025,
	ShakeIntensity = 1.8,
	ShakeDuration = 0.12,
	PostfireDuration = 3.5
}
local flag = false
local brightness = nil
local ambient = nil
local outdoorAmbient = nil

local function createSeg(vector2: Vector3, vector3: Vector3, baseThickness: number, boltColor: Color3, parent, fillColor: Color3?)
	local magnitude = (vector3 - vector2).Magnitude
	local cframe = CFrame.lookAt((vector2 + vector3) / 2, vector3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = boltColor
	part.CastShadow = false
	part.Size = Vector3.new(baseThickness, baseThickness, magnitude)
	part.CFrame = cframe
	part.Parent = parent
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.Material = Enum.Material.Neon
	part2.Color = v.BoltCoreColor
	part2.CastShadow = false
	part2.Size = Vector3.new(baseThickness * 0.3, baseThickness * 0.3, magnitude)
	part2.CFrame = cframe
	part2.Parent = parent
	local highlight

	if fillColor then
		highlight = Instance.new("Highlight")
		highlight.FillColor = fillColor
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 1
		highlight.Adornee = part
		highlight.Parent = part
	end

	return {
		outer = part,
		inner = part2,
		highlight = highlight,
		length = magnitude,
		baseThickness = baseThickness
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setThick(data, p: number)
	if not data.outer.Parent then
		return
	end

	data.outer.Size = Vector3.new(p, p, data.length)

	if data.inner.Parent then
		data.inner.Size = Vector3.new(p * 0.3, p * 0.3, data.length)
	end
end

local function tweenThick(data, p: number, duration: number)
	if not data.outer.Parent then
		return
	end

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(data.outer, tweenInfo, {
		Size = Vector3.new(p, p, data.length)
	}):Play()

	if data.inner.Parent then
		TweenService:Create(data.inner, tweenInfo, {
			Size = Vector3.new(p * 0.3, p * 0.3, data.length)
		}):Play()
	end
end

local function genPath(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	local v2 = vector3 - vector2
	local result = {}

	for i = 0, p do
		local v3 = i / p
		local v4 = vector2 + v2 * v3

		if i == 0 or i == p then
			result[#result + 1] = v4
		else
			local v5 = math.sin(v3 * 3.141592653589793)
			result[#result + 1] = v4 + Vector3.new(
				(math.random() - 0.5) * 2 * p2 * v5,
				0,
				(math.random() - 0.5) * 2 * p2 * v5
			)
		end
	end

	return result
end

local function spawnBranch(vector2: Vector3, position: Vector3, parent, segs, color: Color3?)
	local v2 = math.random(v.BranchSegsMin, v.BranchSegsMax)
	local v3 = math.rad((math.random(-v.BranchAngleMax, v.BranchAngleMax)))
	local v4 = CFrame.Angles(0, v3, 0) * CFrame.new(position).Position
	local v6 = genPath(vector2, vector2 + Vector3.new(v4.X * v2 * 3, -v2 * 4, v4.Z * v2 * 3), v2, v.BranchOffsetMax)

	for i = 1, #v6 - 1 do
		local seg = createSeg(v6[i], v6[i + 1], v.FormInitialThick, v.BoltColor, parent, color)
		segs[#segs + 1] = seg
		tweenThick(seg, v.BranchThickness, v.FormGrowTime)
	end

	for i = 2, #v6 - 1 do
		if not (math.random() < v.SubBranchChance) then
			continue
		end

		local v7 = math.random(2, 3)
		local v8 = v6[i] + Vector3.new((math.random() - 0.5) * 14, -v7 * 3, (math.random() - 0.5) * 14)
		local v9 = genPath(v6[i], v8, v7, 3)

		for i2 = 1, #v9 - 1 do
			local seg = createSeg(v9[i2], v9[i2 + 1], v.FormInitialThick, v.BoltColor, parent, color)
			segs[#segs + 1] = seg
			tweenThick(seg, v.BranchThickness * 0.4, v.FormGrowTime)
		end
	end
end

local function sendPulse(segs, p: number)
	local count = #segs

	if count == 0 then
		return
	end

	local v2 = math.floor(v.PulseWaveWidth / 2)

	for i = 1, count do
		for i2 = -v2, v2 do
			local v3 = i + i2

			if not (v3 >= 1 and v3 <= count) then
				continue
			end

			local v4 = (1 - math.abs(i2) / (v2 + 1)) ^ 2
			setThick(segs[v3], segs[v3].baseThickness * ((p - 1) * v4 + 1)) -- equivalent call inferred; original call site unknown
		end

		local v3 = i - v2 - 1

		if v3 >= 1 then
			tweenThick(segs[v3], segs[v3].baseThickness, v.PulseReturnTime)
		end

		if v.PulseSpeed > 0 then
			task.wait(v.PulseSpeed)
		end
	end

	for _, v3 in segs do
		tweenThick(v3, v3.baseThickness, v.PulseReturnTime)
	end
end

local function deathFlicker(segs)
	local total = 0

	while total < v.DeathFlickerTime do
		local v2 = total / v.DeathFlickerTime

		for _, item in segs do
			if not item.outer.Parent then
				continue
			end

			local v3 = math.random()
			local deathThickMin

			if v3 < 0.35 * (0.4 + v2 * 0.6) then
				deathThickMin = v.DeathThickMin
			elseif v3 < 0.55 then
				deathThickMin = item.baseThickness * v.DeathThickMaxMult * (1 - v2 * 0.4)
			else
				deathThickMin = item.baseThickness * (0.15 + math.random() * (1 - v2 * 0.7))
			end

			setThick(item, deathThickMin) -- equivalent call inferred; original call site unknown

			if not (v2 > 0.5 and math.random() < (v2 - 0.5) * 2.5) then
				continue
			end

			item.outer.Transparency = 0.5 + math.random() * 0.45

			if item.inner.Parent then
				item.inner.Transparency = item.outer.Transparency * 0.6
			end

			if item.highlight then
				item.highlight.FillTransparency = item.outer.Transparency
			end
		end

		local v3 = v.DeathFlickerRate * (1 - v2 * 0.4)
		task.wait(v3)
		total += v3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function saveLighting()
	brightness = Lighting.Brightness
	ambient = Lighting.Ambient
	outdoorAmbient = Lighting.OutdoorAmbient
end

local function restoreLighting(duration: number)
	TweenService:Create(Lighting, TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = brightness,
		Ambient = ambient,
		OutdoorAmbient = outdoorAmbient
	}):Play()
end

local function shakeCamera(shakeIntensity: number, shakeDuration: number)
	if not SettingsController:GetSettingValue("cameraShake") or currentCamera.CameraType ~= Enum.CameraType.Custom then
		return
	end

	local lastTime = tick()
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v2 = tick() - lastTime

		if shakeDuration <= v2 then
			renderSteppedConnection:Disconnect()
			return
		end

		local v3 = shakeIntensity * (1 - v2 / shakeDuration)
		currentCamera.CFrame *= CFrame.new((math.random() - 0.5) * 2 * v3, (math.random() - 0.5) * 2 * v3, 0)
	end)
end

local function spawnExplosion(position: Vector3, boltColor: Color3?, notWeather: boolean?)
	local clone = lightningExplosion:Clone()
	clone.Position = position
	clone.Parent = workspace

	if boltColor then
		for _, emitter in clone:QueryDescendants(".ChangeColor") do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = ColorSequence.new(boltColor)
			end
		end
	end

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			emitter:Emit(emitCount)
		end
	end

	local children = clone.Sounds:GetChildren()
	local v2 = children[math.random(1, #children)]

	if notWeather then
		v2.SoundGroup = nil
	end

	v2:Play()
	task.delay(5, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
end

local function spawnPostFire(position: Vector3, postfireDuration: number?)
	local clone = postFire:Clone()
	clone.Position = position
	clone.Parent = workspace

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.delay(postfireDuration or v.PostfireDuration, function()
		if not (clone and clone.Parent) then
			return
		end

		for _, emitter in clone:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.delay(3, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
	end)
end

local function strike(position: Vector3, options)
	local v2 = options or {}
	local skipStrikingLock = v2.SkipStrikingLock or false

	if not skipStrikingLock then
		if flag then
			return
		else
			flag = true
		end
	end

	saveLighting() -- equivalent call inferred; original call site unknown
	local boltHeight = v2.BoltHeight or v.BoltHeight
	local boltColor = v2.BoltColor or v.BoltColor
	local boltSegments = v2.BoltSegments or v.BoltSegments
	local boltOffsetMax = v2.BoltOffsetMax or v.BoltOffsetMax
	local boltThickness = v2.BoltThickness or v.BoltThickness
	local formInitialThick = v2.FormInitialThick or v.FormInitialThick
	local formGrowTime = v2.FormGrowTime or v.FormGrowTime
	local formDelayPerSeg = v2.FormDelayPerSeg or v.FormDelayPerSeg
	local branchChance = v2.BranchChance or v.BranchChance
	local pulseCount = v2.PulseCount or v.PulseCount
	local pulseThickMult = v2.PulseThickMult or v.PulseThickMult
	local flashBrightness = v2.FlashBrightness or v.FlashBrightness
	local preFlashDuration = v2.PreFlashDuration or v.PreFlashDuration
	local shakeIntensity = v2.ShakeIntensity or v.ShakeIntensity
	local shakeDuration = v2.ShakeDuration or v.ShakeDuration
	local postfireDuration = v2.PostfireDuration or v.PostfireDuration
	local ambientFlash = v2.AmbientFlash or v.AmbientFlash
	local fadeDuration = v2.FadeDuration or v.FadeDuration
	local highlightColor = v2.HighlightColor
	local v3 = position + Vector3.new((math.random() - 0.5) * 18, boltHeight, (math.random() - 0.5) * 18)
	local folder = Instance.new("Folder")
	folder.Name = "Lightning"
	folder.Parent = workspace
	local segs = {}
	local segs2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function localFlash(p: number)
		if v2.NoFlash then
			return
		end

		Lighting.Brightness = brightness + flashBrightness * p
		Lighting.Ambient = ambientFlash
		Lighting.OutdoorAmbient = ambientFlash
	end

	localFlash(0.2) -- equivalent call inferred; original call site unknown
	task.wait(preFlashDuration)
	Lighting.Brightness = brightness
	task.wait(0.015)
	local v4 = genPath(v3, position, boltSegments, boltOffsetMax)
	local unit = (position - v3).Unit

	for i = 1, #v4 - 1 do
		local seg = createSeg(v4[i], v4[i + 1], formInitialThick, boltColor, folder, highlightColor)
		segs2[#segs2 + 1] = seg
		segs[#segs + 1] = seg
		tweenThick(seg, boltThickness, formGrowTime)
		local v5 = i / (#v4 - 1)

		if v5 > 0.25 then
			localFlash(v5 * 0.5) -- equivalent call inferred; original call site unknown
		end

		if i > 2 and i < #v4 - 2 and math.random() < branchChance then
			task.spawn(spawnBranch, v4[i], unit, folder, segs, highlightColor)
		end

		task.wait(formDelayPerSeg)
	end

	localFlash(1) -- equivalent call inferred; original call site unknown

	if not v2.NoShake then
		shakeCamera(shakeIntensity, shakeDuration)
	end

	if not v2.NoExplosion then
		spawnExplosion(position, boltColor, v2.NotWeather)
	end

	if not v2.NoPostFire then
		spawnPostFire(position - createVector(0, -1, 0), postfireDuration)
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = position
	part.Parent = folder
	local pointLight = Instance.new("PointLight")
	pointLight.Color = boltColor
	pointLight.Brightness = 4
	pointLight.Range = 28
	pointLight.Parent = part
	task.wait(0.03)
	restoreLighting(0.08)

	for i = 1, pulseCount do
		sendPulse(segs2, pulseThickMult * (1 - (i - 1) * 0.3))
		localFlash(0.25 / i) -- equivalent call inferred; original call site unknown
		restoreLighting(0.06)
	end

	deathFlicker(segs)
	TweenService:Create(pointLight, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 0
	}):Play()
	local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("Highlight") then
			TweenService:Create(descendant, tweenInfo, {
				FillTransparency = 1
			}):Play()
		end
	end

	task.wait(fadeDuration + 0.05)
	folder:Destroy()

	if not skipStrikingLock then
		flag = false
	end
end

local StormyLightningController = {}

function StormyLightningController.Start(_)
	remoteEvent.OnClientEvent:Connect(strike)
end

function StormyLightningController.Strike(_, vector2: Vector3, p)
	strike(vector2, p)
end

function StormyLightningController.Arc(_, vector2: Vector3, vector3: Vector3, options)
	local v2 = options or {}
	local boltSegments = v2.BoltSegments or 4
	local boltThickness = v2.BoltThickness or 0.4
	local boltOffsetMax = v2.BoltOffsetMax or 2
	local boltColor = v2.BoltColor or v.BoltColor
	local arcLifetime = v2.ArcLifetime or 0.2
	local folder = Instance.new("Folder")
	folder.Name = "LightningArc"
	folder.Parent = workspace
	local v3 = genPath(vector2, vector3, boltSegments, boltOffsetMax)

	for i = 1, #v3 - 1 do
		createSeg(v3[i], v3[i + 1], boltThickness, boltColor, folder)
	end

	task.delay(arcLifetime, function()
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

		for _, part in folder:GetDescendants() do
			if part:IsA("BasePart") then
				TweenService:Create(part, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.2)
		folder:Destroy()
	end)
end

function StormyLightningController.PersistentArc(_, vector2: Vector3, vector3: Vector3, options)
	local v2 = options or {}
	local boltSegments = v2.BoltSegments or 4
	local boltThickness = v2.BoltThickness or 0.4
	local boltOffsetMax = v2.BoltOffsetMax or 2
	local boltColor = v2.BoltColor or v.BoltColor
	local folder = Instance.new("Folder")
	folder.Name = "PersistentArc"
	folder.Parent = workspace
	local segs = {}

	local function rebuild()
		for _, v3 in segs do
			v3.outer:Destroy()
			v3.inner:Destroy()
		end

		table.clear(segs)
		local v3 = genPath(vector2, vector3, boltSegments, boltOffsetMax)

		for i = 1, #v3 - 1 do
			local seg = createSeg(v3[i], v3[i + 1], boltThickness, boltColor, folder)
			table.insert(segs, seg)
		end
	end

	rebuild()
	return {
		Update = function(_)
			rebuild()
		end,
		Destroy = function(self)
			for _, v3 in segs do
				v3.outer:Destroy()
				v3.inner:Destroy()
			end

			table.clear(segs)

			if folder.Parent then
				folder:Destroy()
			end
		end
	}
end

function StormyLightningController.CinematicStrike(_, vector2: Vector3, options)
	local v2 = options or {}
	local totalSegments = v2.TotalSegments or 20
	local slowdownStartPercent = v2.SlowdownStartPercent or 0.45
	local stopAtPercent = v2.StopAtPercent or 0.65
	local boltThickness = v2.BoltThickness or 1.8
	local boltOffset = v2.BoltOffset or 10
	local boltHeight = v2.BoltHeight or 300
	local boltColor = v2.BoltColor or v.BoltColor
	local branchChance = v2.BranchChance or 0.6
	local v3 = math.floor(totalSegments * slowdownStartPercent)
	local v4 = math.floor(totalSegments * stopAtPercent)
	local folder = Instance.new("Folder")
	folder.Name = "CinematicLightning"
	folder.Parent = workspace
	local segs = {}
	local segs2 = {}
	local flag2 = false
	local v5 = false
	local thread = nil
	local v6 = vector2 + Vector3.new((math.random() - 0.5) * 18, boltHeight, (math.random() - 0.5) * 18)
	local v7 = genPath(v6, vector2, totalSegments, boltOffset)
	local unit = (vector2 - v6).Unit
	local cc = Lighting:FindFirstChild("cc")
	local saturation = not cc and 0 or cc.Saturation
	local brightness2 = not cc and 0 or cc.Brightness
	local v10 = {}
	task.spawn(function()
		if cc then
			cc.Brightness += 3
		end

		task.wait(0.02)

		if cc then
			cc.Brightness = brightness2
		end

		task.wait(0.01)

		for i = 1, v4 do
			if flag2 then
				return
			end

			local seg = createSeg(v7[i], v7[i + 1], 0.15, boltColor, folder)
			segs2[#segs2 + 1] = seg
			segs[#segs + 1] = seg
			tweenThick(seg, boltThickness, 0.01)

			if i > 2 and math.random() < branchChance then
				task.spawn(spawnBranch, v7[i], unit, folder, segs)
			end

			if v3 <= i then
				local v11 = (i - v3) / (v4 - v3)
				task.wait(v11 * v11 * 0.12 + 0.004)

				if cc then
					cc.Saturation = saturation + (-1 - saturation) * v11
				end
			else
				task.wait(0.004)
			end
		end

		if flag2 then
			return
		end

		local position = v7[v4 + 1]
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Position = position
		part.Parent = folder
		local pointLight = Instance.new("PointLight")
		pointLight.Color = boltColor
		pointLight.Brightness = 6
		pointLight.Range = 40
		pointLight.Parent = part
		v5 = true
		thread = coroutine.running()
		coroutine.yield()
		v5 = false

		if flag2 then
			return
		end

		if cc then
			TweenService:Create(cc, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Saturation = saturation
			}):Play()
		end

		for i = v4 + 1, #v7 - 1 do
			if flag2 then
				return
			end

			local seg = createSeg(v7[i], v7[i + 1], 0.15, boltColor, folder)
			segs2[#segs2 + 1] = seg
			segs[#segs + 1] = seg
			tweenThick(seg, boltThickness, 0.01)

			if math.random() < 0.5 then
				task.spawn(spawnBranch, v7[i], unit, folder, segs)
			end

			task.wait(0.003)
		end

		if cc then
			cc.Brightness += 6
		end

		task.wait(0.05)

		if cc then
			TweenService:Create(cc, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = brightness2
			}):Play()
		end

		for _ = 1, 3 do
			for _, v12 in segs2 do
				setThick(v12, v12.baseThickness * (1 + math.random() * 30)) -- equivalent call inferred; original call site unknown
			end

			task.wait(0.03)

			for _, v12 in segs2 do
				tweenThick(v12, v12.baseThickness, 0.04)
			end

			task.wait(0.02)
		end

		task.wait(0.1)
		TweenService:Create(pointLight, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
			Brightness = 0,
			Range = 0
		}):Play()
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

		for _, part2 in folder:GetDescendants() do
			if part2:IsA("BasePart") then
				TweenService:Create(part2, tweenInfo, {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.35)

		if folder and folder.Parent then
			folder:Destroy()
		end
	end)

	function v10.Resume(_)
		if v5 and thread then
			coroutine.resume(thread)
		end
	end

	function v10:Destroy()
		flag2 = true

		if v5 and thread then
			coroutine.resume(thread)
		end

		if folder and folder.Parent then
			folder:Destroy()
		end

		if cc then
			cc.Saturation = saturation
		end
	end

	return v10
end

return StormyLightningController