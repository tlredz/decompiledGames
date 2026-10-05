local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)

-- equivalent calls inferred from this helper; original call sites unknown
local function momentFolder()
	local bonusMoments = ReplicatedStorage:FindFirstChild("BonusMoments")

	if bonusMoments then
		return (bonusMoments:FindFirstChild("Temple Intel"))
	end

	return nil
end

local function requireModule(childName: string)
	local v = momentFolder() -- equivalent call inferred; original call site unknown
	local moduleScript

	if v then
		moduleScript = v:FindFirstChild(childName)
	end

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		warn((`[Temple Intel] {childName} not reachable from the client`))
		return nil
	end

	local success, result = pcall(require, moduleScript)

	if success then
		return result
	end

	warn((`[Temple Intel] {childName} failed to load: {result}`))
	return nil
end

local function template(childName: string)
	local v = momentFolder() -- equivalent call inferred; original call site unknown
	local model

	if v then
		model = v:FindFirstChild(childName)
	end

	if model and model:IsA("Model") and #model:GetChildren() ~= 0 then
		return model
	end

	return nil
end

local function makeColorSequence(edgeColor: Color3, coreColor: Color3)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, edgeColor),
		ColorSequenceKeypoint.new(0.5, coreColor),
		ColorSequenceKeypoint.new(1, edgeColor)
	})
end

local function localise(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.Massless = true
	end
end

local function groundAt(position: Vector3, coilGroundUp: number, coilGroundDown: number)
	local children = { workspace.CurrentCamera }

	for _, childName in { "Characters", "Enemies", "NPCs" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = children
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(
		position + Vector3.new(0, coilGroundUp, 0),
		Vector3.new(0, -(coilGroundUp + coilGroundDown), 0),
		raycastParams
	)

	if raycastResult then
		return raycastResult.Position
	end

	return position
end

local function resolvePoint(attachment, pointPath)
	for _, childName in pointPath do
		if attachment then
			attachment = attachment:FindFirstChild(childName)
		else
			attachment = nil
		end

		if not attachment then
			return nil
		end
	end

	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	return nil
end

local function soundVariants(p: string?, value: number?)
	if not p then
		return {}
	end

	local v = type(value) ~= "number" and 1 or math.max(math.floor(value), 1)

	if v <= 1 then
		return { p }
	end

	local result = table.create(v)

	for i = 1, v do
		result[i] = string.format("%s_%02i", p, i)
	end

	return result
end

local function soundTemplate(p: string)
	local sound = Util.Sound:Get(p)

	if sound and sound:IsA("Sound") then
		return sound
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pickSound(rotate)
	if #rotate > 0 then
		return rotate[math.random(#rotate)]
	end

	return nil
end

local function applyParticle(particleEmitter, particle)
	particleEmitter.Name = "PointSparkle"
	particleEmitter.Texture = particle.Texture
	particleEmitter.Color = ColorSequence.new(particle.Color)
	particleEmitter.LightEmission = particle.LightEmission
	particleEmitter.LightInfluence = particle.LightInfluence
	particleEmitter.ZOffset = particle.ZOffset
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.4, particle.Size),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, particle.Transparency),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(particle.LifetimeMin, particle.LifetimeMax)
	particleEmitter.Rate = particle.Rate
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-particle.SpinSpeed, particle.SpinSpeed)
	particleEmitter.Speed = NumberRange.new(0, 0)
	particleEmitter.SpreadAngle = Vector2.new(0, 0)
	particleEmitter.Acceleration = createVector(0, 0, 0)
	particleEmitter.Drag = 0
	particleEmitter.LockedToPart = true
	particleEmitter.Enabled = false
end

return function(data)
	if not data then
		return
	end

	local templeIntelPuzzle = workspace:FindFirstChild("TempleIntelPuzzle")

	if data.Remove == true then
		if templeIntelPuzzle then
			templeIntelPuzzle:Destroy()
		end
	else
		if templeIntelPuzzle then
			return
		end

		local origin = data.Origin

		if typeof(origin) ~= "CFrame" then
			return
		end

		local config

		if type(data.Config) == "table" then
			config = data.Config
		else
			config = requireModule("PuzzleConfig")
		end

		local logic

		if type(data.Logic) == "table" then
			logic = data.Logic
		else
			logic = requireModule("PuzzleLogic")
		end

		local v = momentFolder() -- equivalent call inferred; original call site unknown
		local coil1

		if v then
			coil1 = v:FindFirstChild("Coil1")
		end

		if not coil1 or not coil1:IsA("Model") or #coil1:GetChildren() == 0 then
			coil1 = nil
		end

		local v2 = momentFolder() -- equivalent call inferred; original call site unknown
		local teslaBall

		if v2 then
			teslaBall = v2:FindFirstChild("TeslaBall")
		end

		if not teslaBall or not teslaBall:IsA("Model") or #teslaBall:GetChildren() == 0 then
			teslaBall = nil
		end

		if not (config and logic and coil1 and teslaBall) then
			warn("[Temple Intel] puzzle assets missing under ReplicatedStorage.BonusMoments")
			return
		end

		local radius

		if typeof(data.Radius) == "number" then
			radius = data.Radius
		else
			radius = typeof(config.Radius) ~= "number" and 18 or config.Radius
		end

		local folder = Instance.new("Folder")
		folder.Name = "TempleIntelPuzzle"
		local folder2 = Instance.new("Folder")
		folder2.Name = "Coils"
		folder2.Parent = folder
		local v3 = {}

		for k in config.Coils do
			table.insert(v3, k)
		end

		table.sort(v3)
		local v4 = {
			Rotate = soundVariants(config.RotateSound, config.RotateSoundVariants),
			Connect = soundVariants(config.ConnectSound, config.ConnectSoundVariants),
			Durations = {}
		}
		local v5 = {}
		local v6 = {}
		local flag = false
		local v7 = false

		for k, id in v3 do
			local coil = config.Coils[id]
			local clone = coil1:Clone()
			clone.Name = coil.Model or id
			localise(clone)
			local coilScale = config.CoilScale

			if typeof(coilScale) == "number" and coilScale > 0 and coilScale ~= 1 then
				local model = clone
				local coilScale2 = coilScale
				pcall(function()
					model:ScaleTo(coilScale2)
				end)
			end

			local v9 = (k - 1) / #v3 * 3.141592653589793 * 2
			local v11 = groundAt(
				(origin * CFrame.new(math.cos(v9) * radius, 0, math.sin(v9) * radius)).Position,
				config.CoilGroundUp or 6,
				config.CoilGroundDown or 400
			)
			local vector2 = Vector3.new(origin.Position.X, v11.Y, origin.Position.Z)

			if not ((vector2 - v11).Magnitude > 0.1) then
				vector2 = v11 + origin.LookVector
			end

			clone:PivotTo(CFrame.lookAt(v11, vector2))
			clone.Parent = folder2
			local point = resolvePoint(clone, config.PointPath)

			if point then
				local pointLight

				if config.Light.Enabled then
					pointLight = point:FindFirstChildOfClass("PointLight") or Instance.new("PointLight")
					pointLight.Color = config.Light.Color
					pointLight.Range = config.Light.Range
					pointLight.Brightness = 0
					pointLight.Enabled = false
					pointLight.Parent = point
				end

				local particleEmitter

				if config.Particle.Enabled then
					particleEmitter = point:FindFirstChildOfClass("ParticleEmitter") or Instance.new("ParticleEmitter")
					applyParticle(particleEmitter, config.Particle)
					particleEmitter.Parent = point
				end

				local clickDetector = clone:FindFirstChildOfClass("ClickDetector")

				if clickDetector then
					clickDetector:Destroy()
				end

				local proximityPrompt = Instance.new("ProximityPrompt")
				proximityPrompt:AddTag("ProximityPrompt")
				proximityPrompt.ActionText = "Rotate"
				proximityPrompt.ObjectText = "Coil"
				proximityPrompt.MaxActivationDistance = math.min(config.MaxClickDistance, 16)
				proximityPrompt.RequiresLineOfSight = false
				proximityPrompt.Parent = point
				v5[id] = {
					id = id,
					model = clone,
					point = point,
					light = pointLight,
					sparkle = particleEmitter,
					prompt = proximityPrompt,
					base = clone:GetPivot(),
					state = coil.Start or 1,
					rotating = false,
					angles = {}
				}
			else
				warn((`[Temple Intel] {clone.Name} has no {table.concat(config.PointPath, ".")} attachment`))
			end
		end

		local clone = teslaBall:Clone()
		clone.Name = "TeslaCoil"
		localise(clone)
		clone:PivotTo(origin)
		clone.Parent = folder
		local part = clone:FindFirstChild(config.Relic.Part)

		if part and part:IsA("BasePart") then
			for k, v8 in v5 do
				local position = v8.base.Position
				local lookVector = v8.base.LookVector
				local v9 = math.atan2(lookVector.X, lookVector.Z)

				for k2, state in config.Coils[k].States do
					local state2 = logic.NormalizeState(state)
					local angle = 0

					if state2.Angle then
						angle = math.rad(state2.Angle)
					elseif config.AutoAim then
						local v10 = v5[state2.Targets[1]]

						if v10 then
							local v11 = v10.base.Position - position
							angle = math.atan2(v11.X, v11.Z) - v9
						end
					end

					v8.angles[k2] = angle
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function angleFor(p: string, state: number)
				local v8 = v5[p]
				return v8 and v8.angles[state] or 0
			end

			for k, v8 in v5 do
				v8.model:PivotTo(v8.base * CFrame.Angles(0, angleFor(k, v8.state), 0))
			end

			local beam = config.Beam

			for k in logic.GetPossibleLinks(config) do
				local splitKey, v8 = logic.SplitKey(k)
				local v9 = v5[splitKey]
				local v10 = v5[v8]

				if not (v9 and v10) then
					continue
				end

				local beam2 = Instance.new("Beam")
				beam2.Name = k
				beam2.Attachment0 = v9.point
				beam2.Attachment1 = v10.point
				beam2.Color = makeColorSequence(beam.EdgeColor, beam.CoreColor)
				beam2.Transparency = NumberSequence.new(beam.Transparency)
				beam2.Width0 = beam.Width
				beam2.Width1 = beam.Width
				beam2.LightEmission = beam.LightEmission
				beam2.LightInfluence = beam.LightInfluence
				beam2.Segments = beam.Segments
				beam2.CurveSize0 = beam.CurveSize
				beam2.CurveSize1 = beam.CurveSize
				beam2.FaceCamera = beam.FaceCamera
				beam2.Texture = beam.Texture
				beam2.TextureMode = beam.TextureMode or Enum.TextureMode.Wrap
				beam2.TextureLength = beam.TextureLength
				beam2.TextureSpeed = beam.TextureSpeed
				beam2.ZOffset = beam.ZOffset
				beam2.Enabled = false
				beam2:SetAttribute("BaseWidth", beam.Width)
				beam2:SetAttribute("BaseTransparency", beam.Transparency)
				beam2.Parent = v9.point
				CollectionService:AddTag(beam2, "TempleIntelBeam")
				v6[k] = beam2
			end

			local requiredLinks = logic.GetRequiredLinks(config)
			local v8 = next(requiredLinks) ~= nil

			local function powerDown()
				if flag then
					return
				end

				flag = true

				if type(data.OnPowerDown) == "function" then
					task.spawn(data.OnPowerDown)
				end

				for _, v9 in v6 do
					v9.Enabled = false
				end

				for _, v9 in v5 do
					if v9.light then
						v9.light.Enabled = false
					end

					if v9.sparkle then
						v9.sparkle.Enabled = false
					end
				end
			end

			local function applySolvedLook()
				local solvedBeam = config.SolvedBeam
				local tweenInfo = TweenInfo.new(solvedBeam.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				for _, v9 in v6 do
					if not v9.Enabled then
						continue
					end

					v9.Color = makeColorSequence(solvedBeam.EdgeColor, solvedBeam.CoreColor)
					v9.TextureSpeed = solvedBeam.TextureSpeed
					v9.Transparency = NumberSequence.new(solvedBeam.Transparency)
					v9:SetAttribute("BaseWidth", solvedBeam.Width)
					v9:SetAttribute("BaseTransparency", solvedBeam.Transparency)
					TweenService:Create(v9, tweenInfo, {
						Width0 = solvedBeam.Width,
						Width1 = solvedBeam.Width
					}):Play()
				end
			end

			local function shutdownDelay()
				local relicFinale = config.RelicFinale or {}
				return (relicFinale.ShakeTime or 0) + (relicFinale.RiseTime or 0) + (relicFinale.OrbitTime or 0) + (relicFinale.BurstTime or 0) + (relicFinale.ApproachTime or 0) + (relicFinale.HoverTime or 0) + (relicFinale.AlignTime or 0) + (not config.Shutdown and 0 or config.Shutdown.ExtraDelay or 0)
			end

			local v9 = false

			local function rotateTime(p: string?)
				local v10

				if p then
					v10 = v4.Durations[p]
				end

				return v10 or config.RotateTime
			end

			local function refresh()
				if flag then
					return
				end

				local states = {}

				for k, v10 in v5 do
					states[k] = v10.state
				end

				local activeLinks = logic.GetActiveLinks(config, states)
				local v10 = {}

				for k, v11 in v6 do
					local enabled2 = activeLinks[k] == true

					if enabled2 and config.ShowOnlyRequired and v8 and not requiredLinks[k] then
						enabled2 = false
					end

					local enabled = v11.Enabled
					v11.Enabled = enabled2
					local v13

					if enabled2 and not enabled and v9 then
						local connect = v4.Connect

						if #connect > 0 then
							v13 = connect[math.random(#connect)]
						end
					end

					if v13 then
						local attachment0 = v11.Attachment0
						local attachment1 = v11.Attachment1

						if attachment0 and attachment1 then
							local v15 = v13
							local v16 = (attachment0.WorldPosition + attachment1.WorldPosition) * 0.5
							pcall(function()
								Util.Sound:Play(v15, v16, nil, nil, config.ConnectSoundVolume)
							end)
						end
					end

					if not enabled2 then
						continue
					end

					local splitKey, v14 = logic.SplitKey(k)
					v10[splitKey] = (v10[splitKey] or 0) + 1
					v10[v14] = (v10[v14] or 0) + 1
				end

				for k, v11 in v5 do
					local v12 = v10[k] or 0

					if v11.light then
						v11.light.Brightness = math.min(v12 * config.Light.PerLink, config.Light.Max or 1e999)
						v11.light.Enabled = v12 > 0
					end

					if v11.sparkle then
						v11.sparkle.Enabled = v12 > 0
					end
				end

				if v7 or not logic.IsSolved(config, states, activeLinks) then
					return
				end

				v7 = true
				applySolvedLook()

				for _, v11 in v5 do
					v11.prompt.Enabled = false

					if not (config.Light.Enabled and v11.light) then
						continue
					end

					v11.light.Enabled = true
					v11.light.Brightness = math.min(
						v11.light.Brightness + config.Light.SolvedBonus,
						config.Light.Max or 1e999
					)
				end

				if config.Shutdown and config.Shutdown.Enabled then
					task.delay(shutdownDelay(), powerDown)
				end

				if type(data.OnSolved) == "function" then
					task.spawn(data.OnSolved, part, folder2)
				end
			end

			local function rotate(p: string)
				local v10 = v5[p]

				if v7 or not v10 or config.LockDuringRotate and v10.rotating then
					return
				end

				v10.state = v10.state % #config.Coils[p].States + 1
				v10.rotating = true
				refresh()
				local sound = pickSound(v4.Rotate) -- equivalent call inferred; original call site unknown

				if sound then
					local worldPosition = v10.model:FindFirstChild(config.CoilSpin and config.CoilSpin.PartName or "teslaCoil")

					if not (worldPosition and worldPosition:IsA("BasePart")) then
						worldPosition = v10.point.WorldPosition
					end

					pcall(function()
						local v12 = Util.Sound:Play(sound, worldPosition, nil, nil, config.RotateSoundVolume)

						if not v4.Durations[sound] and v12 then
							task.spawn(function()
								for _ = 1, 20 do
									if v12.TimeLength > 0 then
										v4.Durations[sound] = v12.TimeLength
										break
									else
										task.wait(0.1)
									end
								end
							end)
						end
					end)
				end

				local v12 = v10.base * CFrame.Angles(0, angleFor(p, v10.state), 0)
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = v10.model:GetPivot()
				local changedConnection = cFrameValue.Changed:Connect(function(cframe)
					if v10.model.Parent then
						v10.model:PivotTo(cframe)
					end
				end)
				local v14

				if sound then
					v14 = v4.Durations[sound]
				end

				local v15 = TweenService:Create(
					cFrameValue,
					TweenInfo.new(v14 or config.RotateTime, config.RotateEasing, config.RotateDirection),
					{
						Value = v12
					}
				)
				v15.Completed:Connect(function()
					changedConnection:Disconnect()
					cFrameValue:Destroy()

					if v10.model.Parent then
						v10.model:PivotTo(v12)
					end

					v10.rotating = false
				end)
				v15:Play()
			end

			for k, v10 in v5 do
				local v11 = k
				v10.prompt.Triggered:Connect(function()
					rotate(v11)
				end)
			end

			task.spawn(function()
				local sounds = {}

				for _, v10 in { v4.Rotate, v4.Connect } do
					for _, v11 in v10 do
						local sound = Util.Sound:Get(v11)

						if not (sound and sound:IsA("Sound")) then
							sound = nil
						end

						if sound then
							table.insert(sounds, sound)
						end
					end
				end

				if #sounds == 0 then
					return
				end

				pcall(function() end)

				for _, v10 in v4.Rotate do
					local sound = Util.Sound:Get(v10)

					if not (sound and sound:IsA("Sound")) then
						sound = nil
					end

					if not sound then
						continue
					end

					for _ = 1, 20 do
						if sound.TimeLength > 0 then
							v4.Durations[v10] = sound.TimeLength
							break
						else
							task.wait(0.1)
						end
					end

					if not v4.Durations[v10] then
						warn((`[Temple Intel] could not read the length of {v10}, using Config.RotateTime`))
					end
				end
			end)
			refresh()
			v9 = true
			folder.Parent = workspace

			if type(data.OnReady) == "function" then
				task.spawn(data.OnReady, part, folder2, folder)
			end
		else
			warn((`[Temple Intel] relic model has no {config.Relic.Part} part`))
			folder:Destroy()
		end
	end
end