local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local rock2 = Util.Rock2
local tweenModel = Util.TweenModel
local currentCamera = workspace.CurrentCamera
local doughMiscDebrisRadial = Effect.new("Dough.Misc.Debris.Radial")
local doughShockwaves1 = Effect.new("Dough.Shockwaves.1")
local doughShockwaves2 = Effect.new("Dough.Shockwaves.2")

-- equivalent calls inferred from this helper; original call sites unknown
local function setColor(data, value)
	local v = value or 5
	return Color3.new(data.r * v, data.g * v, data.b * v)
end

local FloorExpand = {}

function FloorExpand.new(data)
	return setmetatable({
		RNG = Random.new(),
		Scale = data.Scale or 5,
		CFrame = data.CFrame,
		Strength = data.Strength or 0,
		BaseStrength = data.BaseStrength or 0,
		Buso = data.Buso,
		Lifetime = data.Lifetime,
		MaximumStrength = data.MaximumStrength or 10,
		MaxParticleLifetime = 0,
		GenericColor = Color3.new(),
		Brightness = 2.5,
		FastMode = data.FastMode,
		Rocks = {},
		Particles = {},
		CallsStacked = 0,
		LastCall = tick()
	}, {
		__index = FloorExpand
	}):__setup()
end

function FloorExpand:__setup()
	local rayCastWhitelist, v, v2 = Util.RayCastWhitelist(
		self.CFrame * Vector3.new(0, self.Scale / 2, 0),
		-self.CFrame.UpVector * self.Scale,
		{ workspace:FindFirstChild("Map") }
	)
	self.Model = script.Floor:Clone()

	if rayCastWhitelist then
		self.GenericColor = rayCastWhitelist.Color
		self.CFrame = Util.Misc.AlignCFrame(self.CFrame - self.CFrame.p + v, v2)
	end

	local genericColor = self.GenericColor
	local color = Color3.new(genericColor.r * 0.5, genericColor.g * 0.5, genericColor.b * 0.5)

	for _, decal in pairs(self.Model:GetDescendants()) do
		if not decal:IsA("Decal") then
			continue
		end

		local darkness = decal:GetAttribute("Darkness") or 0
		local brightness = decal:GetAttribute("Brightness") or 0

		if darkness > 0 then
			decal.Color3 = color:Lerp(Color3.new(), darkness)
		elseif brightness > 0 then
			decal.Color3 = color:Lerp(Color3.new(1, 1, 1), brightness)
		else
			decal.Color3 = color
		end
	end

	for _, emitter in pairs(self.Model:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		self.MaxParticleLifetime = math.max(self.MaxParticleLifetime or 0, emitter.Lifetime.Max)

		if emitter:GetAttribute("Colorize") then
			if typeof(self.Buso) == "Color3" then
				emitter.Color = ColorSequence.new(self.Buso)
			else
				emitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
			end
		end

		table.insert(self.Particles, {
			Object = emitter,
			Data = {
				Size = emitter.Size.Keypoints,
				Speed = emitter.Speed,
				Lifetime = emitter.Lifetime,
				Acceleration = emitter.Acceleration,
				ZOffset = emitter.ZOffset + 0.5
			}
		})
	end

	self.Model.Standard2.Decal.Transparency = 1
	self.Model:SetPrimaryPartCFrame(self.CFrame * CFrame.Angles(0, 3.141592653589793 * self.RNG:NextNumber(-1, 1), 0))
	self.Model.Parent = _WorldOrigin
	local v3 = self.Scale * math.max(1.25, 1 / (self.Strength + self.BaseStrength) / 2) * Random.new():NextNumber(
		0.5,
		1.5
	)

	for i = 1, v3 do
		local angle = 6.283185307179586 * i / v3
		local object = rock2.new({
			Type = "ShapeShifter",
			FadeOut = { 0.125, 0.25 },
			FadeIn = { 0.125, 0.25 },
			Lifetime = 1e999,
			Size = Vector3.new(
				self.RNG:NextNumber(0.5, 1.5),
				self.RNG:NextNumber(0.25, 1),
				self.RNG:NextNumber(0.5, 1.5)
			),
			Scale = {
				self.Scale * math.max(1, self.Strength + self.BaseStrength) / 7,
				self.Scale * math.max(1, self.Strength + self.BaseStrength) / 3
			},
			AngleOffset = CFrame.Angles(0.3490658503988659 + 0.7853981633974483 * self.RNG:NextNumber(0, 1), 0, 0)
		})
		object:Spawn(self.CFrame * CFrame.Angles(0, angle, 0) * CFrame.new(
			0,
			0,
			-self.Scale * self.RNG:NextNumber(0.25, 1.5)
		))

		if object.Part.Parent then
			table.insert(self.Rocks, {
				Angle = angle,
				Object = object,
				Offset = Vector3.new(),
				ScaleOffset = 0
			})
		end
	end

	self:add(self.Strength + self.BaseStrength)
	return self
end

function FloorExpand:__getScale()
	return self.Scale + self.Scale / 6 * (self.Strength + self.BaseStrength)
end

function FloorExpand:scale(p2, value)
	local tweenInfo = TweenInfo.new(value or 0.25, Enum.EasingStyle.Quad)

	for _, part in pairs(self.Model:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local size = part:GetAttribute("Size") or part.Size
		part:SetAttribute("Size", size)
		TweenService:Create(part, tweenInfo, {
			Size = size * Vector3.new(p2, 1, p2)
		}):Play()
		local attachment = part:FindFirstChildOfClass("Attachment")

		if not attachment or attachment:GetAttribute("Ignore") then
			continue
		end

		attachment.Position = Vector3.new(0, p2 * 0.075, 0)
	end
end

function FloorExpand:popRocks(value)
	local v = value or 1

	for _ = 1, self.Strength + self.BaseStrength >= self.MaximumStrength / 1.25 and #self.Rocks or math.random(
		1,
		(math.max(1, (math.floor(#self.Rocks / 2))))
	) do
		if not (#self.Rocks > 0) then
			continue
		end

		if not (self.Strength + self.BaseStrength >= self.MaximumStrength / 1.5 or math.random((math.max(
			2,
			self.Strength + self.BaseStrength
		))) % math.random(3) == 0) then
			continue
		end

		local v2 = math.random(1, #self.Rocks)
		local rock = self.Rocks[v2]

		if not rock then
			continue
		end

		local v3 = 0.5 + self.RNG:NextNumber(0, 1.25)
		local v4 = not (rock.Offset.Magnitude > 0) and createVector(0, 1, 0) or rock.Offset or createVector(0, 1, 0)
		local object2 = rock.Object
		local v5 = v * (1 - math.min(1, (object2.Part.Position - self.CFrame.p).Magnitude / (self:__getScale() * 2)))
		object2.Type = "Flying"
		object2:Eject({
			Velocity = Util.Misc.Physics.Velocity(
				Vector3.new(),
				v4.Unit * (20 + (self.Strength + self.BaseStrength) * 2) * v5,
				Vector3.new(0, -workspace.Gravity * self.RNG:NextNumber(0.25, 0.5)),
				v3
			),
			AngularVelocity = Vector3.new(
				self.RNG:NextNumber(-1, 1),
				self.RNG:NextNumber(-1, 1),
				self.RNG:NextNumber(-1, 1)
			) * 4 * 3.141592653589793 * (1 / object2.Scale) * v5
		})
		object2:Release(v3)
		self.Rocks[v2] = nil
	end
end

function FloorExpand:add(value)
	if self.Strength + self.BaseStrength + (value or 0) >= self.MaximumStrength then
		self.Strength = self.MaximumStrength - self.BaseStrength
		value = 0
	end

	local v = (currentCamera.CFrame.p - self.CFrame.p).Magnitude / ((self.Scale + self.Scale * ((self.Strength + self.BaseStrength) / 5)) * 4)

	if v < 1 then
		Effect.new("ShakeCam"):replicate({
			Preset = "Bump4",
			Power = 0.25 + 0.75 * (1 - v)
		})
	end

	if tick() - self.LastCall < 0.25 then
		return
	end

	self.Strength += value or 0

	if tick() - self.LastCall < 0.5 then
		self.HeatCount = (self.HeatCount or 0) + 1
	else
		self.HeatCount = 1
	end

	if self.HeatCount > 1 then
		if self.ColorSequencer then
			self.ColorSequencer:refresh()
		else
			self.ColorSequencer = Util.ColorSequencer(
				{ Color3.new(1, 1, 0), Color3.new(1, 0.5, 0), self.GenericColor },
				0.5,
				0.5
			)
		end

		local cFrame = self.CFrame
		local v2 = self.Scale * 1.25 + self.Scale / 6 * (self.Strength + self.BaseStrength)
		local v3 = 0.4 + (self.Strength + self.BaseStrength) / 10 * 0.25
		doughShockwaves1:replicate({
			CFrame = cFrame,
			Scale = v2 * 1.75,
			Color = Color3.fromRGB(555, 555, 555),
			VectorOffset = cFrame.UpVector * v2 / 8,
			Transparency = 0.5,
			Speed = 1,
			Duration = v3 * 0.75
		})
	elseif not self.FastMode then
		local cFrame = self.CFrame
		local v2 = self.Scale * 1.25 + self.Scale / 6 * (self.Strength + self.BaseStrength)
		local v3 = 0.75 + (self.Strength + self.BaseStrength) / 10 * 0.25
		doughShockwaves2:replicate({
			CFrame = cFrame,
			Scale = v2 * 2,
			Color = Color3.fromRGB(555, 555, 555),
			VectorOffset = cFrame.UpVector * v2 / 8,
			Transparency = 0.5,
			Speed = 1,
			Duration = v3 * 0.5
		})
	end

	self:scale(self.Scale + self.Scale * ((self.Strength + self.BaseStrength) / 5))

	if self.FastMode then
		doughMiscDebrisRadial:replicate({
			CFrame = self.CFrame * CFrame.new(0, 0, 0),
			Scale = self.Scale * 2 + self.Scale / 4 * (self.Strength + self.BaseStrength),
			Duration = 0.5 * (1 + 0.5 * self.Strength * 0.1)
		})
	else
		doughMiscDebrisRadial:replicate({
			CFrame = self.CFrame * CFrame.new(0, -0.25, 0),
			Scale = self.Scale * 2 + self.Scale / 4 * (self.Strength + self.BaseStrength),
			Mode = "X",
			Duration = 1.3 * (1 + 0.5 * self.Strength * 0.1)
		})
		doughMiscDebrisRadial:replicate({
			CFrame = self.CFrame * CFrame.new(0, 0.5, 0),
			Scale = self.Scale * 2 + self.Scale / 4 * (self.Strength + self.BaseStrength),
			Mode = "Y",
			Duration = 2 * (1 + 0.5 * self.Strength * 0.1)
		})
	end

	local v2 = self.Scale * 1.25 + self.Scale / 8 * (self.Strength + self.BaseStrength)

	for _, particle in pairs(self.Particles) do
		Util.Misc.ScaleParticle(particle.Object, 0.1 * v2, particle.Data)
		local emitCount = particle.Object:GetAttribute("EmitCount")

		if emitCount then
			self.MaxParticleLifetime = math.max(self.MaxParticleLifetime or 0, particle.Object.Lifetime.Max)
			particle.Object:Emit((emitCount + math.floor(emitCount / 2 * ((self.Strength + self.BaseStrength) / self.MaximumStrength))) * (self.FastMode and 0.5 or 1))
		end

		if not particle.Object:GetAttribute("Colorize") then
			continue
		end

		if typeof(self.Buso) == "Color3" then
			particle.Object.Color = ColorSequence.new(self.Buso)
		else
			particle.Object.Color = ColorSequence.new(Color3.new(1, 1, 1))
		end
	end

	if not self.FastMode then
		local cFrame = self.CFrame
		local v3 = self.Scale * (not (self.Strength + self.BaseStrength < 2) and 1 or 1.125 + 0.25 * ((self.Strength + self.BaseStrength) / 2) or 1) + self.Scale / 5 * (self.Strength + self.BaseStrength)
		local v4 = 0.3 + (self.Strength + self.BaseStrength) / 10 * 0.25
		tweenModel(script.ThinWind, {
			CFrame = cFrame,
			Scale = v3 * 0.3,
			Transparency = 0.3,
			Size = createVector(1, 0.25, 1)
		}, {
			Tween = TweenInfo.new(v4 * 0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			CFrame = CFrame.new(0, -0.125, 0),
			Scale = v3 * 1.5,
			Transparency = 1,
			Size = createVector(1, 1, 1)
		})

		if self.Strength + self.BaseStrength > 1 then
			local cFrame2 = self.CFrame
			local v5 = self.Scale * 1.25 + self.Scale / 6 * (self.Strength + self.BaseStrength)

			for i = 1, math.min(2, self.Strength + self.BaseStrength - 2) do
				local v6 = self.RNG:NextInteger(1, 2) == 1 and 1 or -1
				tweenModel(script.WindRing, {
					CFrame = cFrame2 * CFrame.Angles(0, self.RNG:NextNumber(-1, 1) * 3.141592653589793, 0) * CFrame.new(
						0,
						v5 / 12 * (i / 3),
						0
					),
					Scale = v5 * 0.25,
					Transparency = self.RNG:NextNumber(0.125, 0.5),
					Size = createVector(2, 0.5, 2)
				}, {
					Tween = TweenInfo.new((i / 2 * 0.75 + 0.5) * 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					CFrame = CFrame.Angles(0, v6 * 1.57 * 2, 0) * CFrame.new(
						0,
						(i % 2 == 0 and 1 or -1) * v5 / 8 * (i / 3),
						0
					),
					Scale = v5 * 1.5,
					Transparency = 1,
					Size = Vector3.new(1, self.RNG:NextNumber(0.25, 1) / 2, 1)
				})
			end
		end
	end

	self:popRocks()
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
	local v3 = (self.Strength + self.BaseStrength + 2) / 8
	TweenService:Create(self.Model.Standard2.Decal, tweenInfo, {
		Transparency = value < 0 and 1 or Util.Tween.point(
			1,
			self.Model.Standard2.Decal:GetAttribute("Transparency"),
			v3
		)
	}):Play()

	for _, rock in pairs(self.Rocks) do
		rock.Offset = (self.CFrame * CFrame.Angles(0, rock.Angle, 0)).LookVector * self.Scale / 2 * ((self.Strength + self.BaseStrength) / 5)
		rock.ScaleOffset = self.Scale / 12 * ((self.Strength + self.BaseStrength) / 7)
		rock.Object:TweenShiftScale(rock.ScaleOffset, 0.5)
		rock.Object:TweenShift(rock.Offset, 0.5)
	end

	self.LastCall = tick()
end

function FloorExpand:update(p)
	if self.ColorSequencer then
		if self.ColorSequencer.finished then
			self.ColorSequencer = nil
			return
		end

		self.ColorSequencer:update(p)
		local v = math.min(1, self.ColorSequencer.alpha)
		local point = Util.Tween.point(self.Brightness, 0.5, v)
		local color = setColor(self.ColorSequencer:toColor3(), point) -- equivalent call inferred; original call site unknown

		for _, decal in pairs(self.Model:GetDescendants()) do
			if not decal:IsA("Decal") then
				continue
			end

			local darkness = decal:GetAttribute("Darkness") or 0
			local brightness = decal:GetAttribute("Brightness") or 0

			if darkness > 0 then
				decal.Color3 = color:Lerp(Color3.new(), darkness)
			elseif brightness > 0 then
				decal.Color3 = color:Lerp(Color3.new(1, 1, 1), brightness)
			else
				decal.Color3 = color
			end
		end
	end
end

function FloorExpand.clear(data, value)
	local v = value or 1
	local tweenInfo = TweenInfo.new(v, Enum.EasingStyle.Quad)

	for _, decal in pairs(data.Model:GetDescendants()) do
		if decal:IsA("Decal") then
			TweenService:Create(decal, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	for _, rock in pairs(data.Rocks) do
		rock.Object:Release()
	end

	Util.Debris:AddItem(data.Model, v + data.MaxParticleLifetime)
end

return FloorExpand