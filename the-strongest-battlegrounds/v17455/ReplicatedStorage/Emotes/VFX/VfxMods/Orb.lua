local createVector = vector.create
local Orb = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local _ = game.Workspace.Camera
local ZLib = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib)
local LightningModule = require(game.ReplicatedStorage.Resources.LightningModule)
local v = {
	ChargeTrails = 5,
	ChargeTrailsSpawnRadius = NumberRange.new(50, 80),
	ChargeDuration = 0.25,
	ProjectileSpeed = 400,
	SphereRadius = 41.5,
	TrailsPerSecond = 3,
	SphereTrailExpandDuration = 1.5,
	SphereTrailLifetime = 3,
	SphereDuration = 2,
	SphereShrinkDuration = 1.5,
	MeshesPerSecond = 5.5,
	Rocks = 20
}
local v2 = {
	Sphere = {
		"rbxassetid://87813260707341",
		"rbxassetid://128235032542721",
		"rbxassetid://101631403724748",
		"rbxassetid://92487126129297",
		"rbxassetid://101209535717664",
		"rbxassetid://127786742497869",
		"rbxassetid://107853157871384",
		"rbxassetid://80180539398981",
		"rbxassetid://107639670667934",
		"rbxassetid://136953105980872",
		"rbxassetid://120623009968694",
		"rbxassetid://89866682133420",
		"rbxassetid://76018600364350",
		"rbxassetid://115705092410657",
		"rbxassetid://93161838568726",
		"rbxassetid://116425786562613",
		"rbxassetid://99389310905115",
		"rbxassetid://74172387616259",
		"rbxassetid://123261210382660",
		"rbxassetid://97389873625281",
		"rbxassetid://89153019847048",
		"rbxassetid://108841612117611",
		"rbxassetid://84483791562296",
		"rbxassetid://139851467163949",
		"rbxassetid://72846421222287",
		"rbxassetid://102933154480134",
		"rbxassetid://136344969742427",
		"rbxassetid://120374891849801",
		"rbxassetid://73915201369337",
		"rbxassetid://76903842499983",
		"rbxassetid://85656875146145",
		"rbxassetid://103909940508805"
	}
}
local class2 = {
	lerp = function(_, p, p2, p3)
		return p + (p2 - p) * p3
	end,
	QuadraticEaseOut = function(_, p)
		return 1 - (1 - p) * (1 - p)
	end,
	EmitAll = function(_, folder)
		if not folder then
			return
		end

		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local emitCount = emitter:GetAttribute("EmitCount") or 5
			local emitDelay = emitter:GetAttribute("EmitDelay") or 0
			local emitDuration = emitter:GetAttribute("EmitDuration") or 0
			local v4 = emitter
			task.spawn(function()
				if emitDelay > 0 then
					task.wait(emitDelay)
				end

				v4:Emit(emitCount)

				if emitDuration > 0 then
					v4.Enabled = true
					task.wait(emitDuration)
					v4.Enabled = false
				end
			end)
		end
	end,
	DisableAllParticles = function(self, folder)
		if not folder then
			return
		end

		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end,
	DisableAllTrails = function(self, folder)
		if not folder then
			return
		end

		for _, trail in ipairs(folder:GetDescendants()) do
			if trail:IsA("Trail") then
				trail.Enabled = false
			end
		end
	end,
	ApplyScale = function(self, part, p)
		if not part or p == 1 then
			return
		end

		if part:IsA("BasePart") then
			part.Size *= p
		end

		for _, descendant in ipairs(part:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Size *= p
			elseif descendant:IsA("SpecialMesh") then
				descendant.Scale *= p
			elseif descendant:IsA("Attachment") then
				descendant.Position *= p
			elseif descendant:IsA("ParticleEmitter") then
				local numberSequenceKeypoints = {}

				for _, keypoint in ipairs(descendant.Size.Keypoints) do
					table.insert(
						numberSequenceKeypoints,
						NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * p)
					)
				end

				descendant.Size = NumberSequence.new(numberSequenceKeypoints)
				local speed = descendant.Speed
				descendant.Speed = NumberRange.new(speed.Min * p, speed.Max * p)
			end
		end
	end
}
local count = 0

function class2:RenderStepLoopFor(p, callback, p2, callback2)
	count += 1
	local v3 = "OrbRSL_" .. count
	local total = 0
	RunService:BindToRenderStep(v3, p2 or Enum.RenderPriority.Last.Value, function(p3)
		total += p3
		local v4 = math.min(total / p, 1)
		callback(total, p3, v4)

		if v4 >= 1 then
			RunService:UnbindFromRenderStep(v3)

			if callback2 then
				callback2()
			end
		end
	end)
end

function class2:HeartbeatLoopFor(p, callback, callback2)
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v3 = math.min(total / p, 1)
		callback(total, dt, v3)

		if v3 >= 1 then
			heartbeatConnection:Disconnect()

			if callback2 then
				callback2()
			end
		end
	end)
end

local function PlaySpriteAll(folder, sphere, p)
	local v3 = #sphere / p

	for _, decal in ipairs(folder:GetDescendants()) do
		if not decal:IsA("Decal") then
			continue
		end

		local v4 = decal
		task.spawn(function()
			for i, texture in ipairs(sphere) do
				if not v4.Parent then
					break
				end

				v4.Texture = texture
				task.wait(1 / p)
			end
		end)
	end

	return v3
end

local parent = workspace:FindFirstChild("VFXDebris")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "VFXDebris"
	parent.Parent = workspace.Thrown
end

local random2 = Random.new(os.clock())
local class3 = {}
class3.__index = class3

function class3.new(instance, data)
	local object = setmetatable({
		Radius = 0,
		RotationSpeed = random2:NextNumber(data.RotationSpeed.Min, data.RotationSpeed.Max),
		Seed = random2:NextNumber(1, 1000000),
		NoiseSeed = random2:NextUnitVector() * random2:NextNumber(1, 1000000),
		InitialCFrame = data.CFrame,
		CFrame = data.CFrame,
		NoiseResolution = random2:NextNumber(data.NoiseResolution.Min, data.NoiseResolution.Max),
		_t = 0
	}, class3)
	local clone = instance:Clone()
	clone.CFrame = data.CFrame
	clone.Parent = parent
	object.Instance = clone
	return object
end

function class3:Destroy()
	if self.Instance then
		self.Instance:Destroy()
	end

	setmetatable(self, nil)
end

local class4 = {}
class4.__index = class4

function class4.new(p, trove, value)
	local self = setmetatable({}, class4)
	self.OriginCFrame = p
	self.SpinAngle = 0
	self.CFrame = p
	self.Trove = trove
	self.Scale = value or 1
	self.NoiseResolution = NumberRange.new(10, 20)
	self.RotationSpeed = NumberRange.new(25, 35)
	self.SphereRotSpeed = 0
	self.SphereRotSpeedFinal = 750
	self._running = false
	self._shrinking = false
	self._cancelled = false
	self._trails = {}
	return self
end

function class4:_createTrail(p)
	if self._cancelled then
		return
	end

	local v4 = class3.new(p, self)
	class2:ApplyScale(v4.Instance, self.Scale)
	self.Trove:Add(v4)
	local _ = #self._trails + 1
	table.insert(self._trails, v4)

	local function lerpRadius(_, _, p2)
		if not self._shrinking then
			v4.Radius = class2:lerp(0, v.SphereRadius * self.Scale, p2 ^ 0.3333333333333333)
		end

		local noiseResolution = v4.NoiseResolution
		v4.RotationSpeed = class2:lerp(noiseResolution * 2, noiseResolution / 1.5, p2 ^ 3)
		local trailGlow = v4.Instance:FindFirstChild("TrailGlow")
		local trail = trailGlow and trailGlow:FindFirstChild("Trail")

		if trail then
			trail.Color = ColorSequence.new(v4.Instance.Color)
		end
	end

	local tween = TweenService:Create(v4.Instance, TweenInfo.new(v.SphereTrailLifetime), {
		Color = v4.Instance.Color
	})
	v4.Instance.Color = Color3.fromRGB(255, 125, 60)
	tween:Play()
	class2:RenderStepLoopFor(v.SphereTrailExpandDuration, lerpRadius, Enum.RenderPriority.Last.Value, function() end)
	task.delay(v.SphereTrailLifetime, function()
		local function trailSpeed(_, _, p2)
			v4.RotationSpeed = class2:lerp(v4.RotationSpeed, 0, class2:QuadraticEaseOut(p2))
		end

		class2:HeartbeatLoopFor(0.5, trailSpeed, function()
			class2:DisableAllTrails(v4.Instance)

			for i = #self._trails, 1, -1 do
				if self._trails[i] ~= v4 then
					continue
				end

				table.remove(self._trails, i)
				break
			end
		end)
	end)
end

function class4:Run(p)
	self._running = true
	self.Trove:Add(task.spawn(function()
		while self._running do
			self:_createTrail(p)
			task.wait(1 / v.TrailsPerSecond)
		end
	end))
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if self._cancelled then
			return
		end

		self.SpinAngle += 0.017453292519943295 * dt * self.SphereRotSpeed
		self.CFrame = self.OriginCFrame * CFrame.Angles(0, self.SpinAngle, 0)
	end)
	self.Trove:Add(renderSteppedConnection)
	class2:RenderStepLoopFor(v.SphereDuration, function(_, _, p2)
		self.SphereRotSpeed = class2:lerp(0, self.SphereRotSpeedFinal, p2 ^ 3)
	end, Enum.RenderPriority.Last.Value, function() end)
	self:Render()
end

function class4:Shrink()
	self._shrinking = true
	task.spawn(function()
		local _trails = {}

		for _, _trail in ipairs(self._trails) do
			table.insert(_trails, _trail)
		end

		for _, v4 in ipairs(_trails) do
			local v5 = v4
			local radius = v4.Radius
			local v7 = v4
			class2:HeartbeatLoopFor(v.SphereShrinkDuration / 3, function(p2, p3, p4)
				v5.Radius = class2:lerp(radius, 0, p4 ^ 2)
			end, function()
				v7.RotationSpeed = 0
				class2:DisableAllTrails(v7.Instance)

				if self._trails then
					for i = #self._trails, 1, -1 do
						if self._trails[i] ~= v7 then
							continue
						end

						table.remove(self._trails, i)
						break
					end
				end

				task.delay(0.5, function()
					if v7.Instance then
						v7.Instance:Destroy()
					end
				end)
			end)
			task.wait(0.075)
		end
	end)
end

function class4:Render()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if self._cancelled then
			return
		end

		for _, _trail in ipairs(self._trails) do
			_trail.CFrame = self.CFrame * CFrame.Angles(
				math.clamp(
					math.noise(
						(_trail.Seed + _trail._t) / _trail.NoiseResolution,
						_trail.NoiseSeed.Y / _trail.NoiseResolution,
						_trail.NoiseSeed.Z / _trail.NoiseResolution
					),
					-1,
					1
				) * 3.141592653589793,
				math.clamp(
					math.noise(
						_trail.NoiseSeed.X / _trail.NoiseResolution,
						(_trail.Seed + _trail._t) / _trail.NoiseResolution,
						_trail.NoiseSeed.Z / _trail.NoiseResolution
					),
					-1,
					1
				) * 3.141592653589793,
				math.clamp(
					math.noise(
						_trail.NoiseSeed.X / _trail.NoiseResolution,
						_trail.NoiseSeed.Y / _trail.NoiseResolution,
						(_trail.Seed + _trail._t) / _trail.NoiseResolution
					),
					-1,
					1
				) * 3.141592653589793
			)

			if _trail.Instance and _trail.Instance.Parent then
				_trail.Instance.CFrame = _trail.CFrame * CFrame.new(0, _trail.Radius, 0)
			end

			_trail._t += dt * _trail.RotationSpeed
		end
	end)
	self.Trove:Add(renderSteppedConnection)
	self._renderConnection = renderSteppedConnection
end

function class4:UpdateOrigin(originCFrame)
	self.OriginCFrame = originCFrame
end

function class4:Cancel()
	if self._cancelled then
		return
	end

	self._cancelled = true
	self._running = false

	if self._trails then
		for _, _trail in ipairs(self._trails) do
			if not _trail.Instance then
				continue
			end

			class2:DisableAllTrails(_trail.Instance)
			local v4 = _trail.Instance
			task.delay(0.3, function()
				if v4 then
					pcall(function()
						v4:Destroy()
					end)
				end
			end)
		end

		table.clear(self._trails)
	end
end

function class4:Stop()
	self._running = false
end

function class4:Destroy()
	self._running = false
	self._trails = nil
	setmetatable(self, nil)
end

local class5 = {}
class5.__index = class5

function class5.new(cFrame, trove)
	return (setmetatable({
		CFrame = cFrame,
		Trove = trove
	}, class5))
end

function class5:Play(instance, value)
	local clone = instance:Clone()
	class2:ApplyScale(clone, value or 1)
	self.Trove:Add(clone)
	clone.Parent = parent
	clone:PivotTo(self.CFrame * CFrame.Angles(0, random2:NextNumber(-3.141592653589793, 3.141592653589793), 0))
	local v4 = PlaySpriteAll(clone, v2.Sphere, 80) + 0.5
	local mesh = clone:FindFirstChild("Mesh")
	local sprite = clone:FindFirstChild("Sprite")

	if sprite then
		sprite.Transparency = 1
		TweenService:Create(sprite, TweenInfo.new(0.3), {
			Transparency = 0
		}):Play()
	end

	local v5 = not mesh and createVector(1, 1, 1) or mesh.Scale or createVector(1, 1, 1)
	class2:RenderStepLoopFor(v4, function(_, p2, p3)
		if not clone.Parent then
			return
		end

		clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, 7.853981633974483 * p2, 0))

		if mesh then
			mesh.Scale = v5 + (v5 * 1.15 - v5) * class2:QuadraticEaseOut(p3)
		end
	end, Enum.RenderPriority.Last.Value, function()
		if sprite then
			sprite.Transparency = 1
		end

		if clone.Parent then
			clone:Destroy()
		end
	end)
end

function class5:Destroy()
	setmetatable(self, nil)
end

local function MakeTrove(_maid)
	return {
		Add = function(self, p)
			if type(p) == "thread" then
				_maid:give(function()
					pcall(task.cancel, p)
				end)
				return p
			end

			_maid:give(p)
			return p
		end,
		Clean = function(_)
			_maid:doCleaning()
		end
	}
end

function Orb.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local bind = data.Bind
	local object = setmetatable({}, class)
	object._maid = maid.new()
	object.Trove = MakeTrove(object._maid)
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local parent2 = object._maid:give(Instance.new("Part"))
		parent2.Size = createVector(0.3, 0.3, 0.3)
		parent2.Parent = EFP
		parent2.Anchored = true
		parent2.CanCollide = false
		parent2.Transparency = 1
		parent2.Parent = EFP
		game.Debris:AddItem(parent2, 6)
		local v6 = nil
		local folder = nil
		local folder2 = nil

		local function Energy()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function Orbs()
				task.spawn(function()
					local assets = script.Assets
					local parent3 = EFP
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { game.Workspace.Map }
					local raycastResult = game.Workspace:Raycast(
						humanoidRootPart.Position,
						createVector(0, -10, 0),
						raycastParams
					)

					if not (raycastResult and (bind and bind.Parent)) then
						return
					end

					local cFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					local clone = assets.HitParticles:Clone()
					class2:ApplyScale(clone, 0.3)
					object.Trove:Add(clone)
					clone.Parent = parent3
					clone.CFrame = cFrame * CFrame.new(0, 0.045, 0)

					if not (bind and bind.Parent) then
						return
					end

					local clone2 = assets.SphereParticles:Clone()
					class2:ApplyScale(clone2, 0.3)
					object.Trove:Add(clone2)
					clone2.Parent = parent3
					clone2.CFrame = cFrame * CFrame.new(0, 0.045, 0)

					if not (bind and bind.Parent) then
						return
					end

					local clone3 = assets.SphereMesh2:Clone()
					class2:ApplyScale(clone3, 0.3)
					object.Trove:Add(clone3)
					clone3.Parent = parent3
					clone3.CFrame = cFrame
					clone3.Transparency = 1
					TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						Transparency = 0
					}):Play()
					TweenService:Create(clone3, TweenInfo.new(v.SphereDuration + 0.5), {
						Transparency = 1,
						CFrame = clone3.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
					}):Play()

					if not (bind and bind.Parent) then
						return
					end

					local v9 = class4.new(cFrame, object.Trove, 0.3)
					object.Trove:Add(v9)
					v9:Run(assets.SphereTrail)
					object._maid:giveTask(bind.Destroying:Once(function()
						v9:Cancel()
						class2:DisableAllParticles(clone)
						class2:DisableAllParticles(clone2)

						if clone3 and clone3.Parent then
							pcall(function()
								TweenService:Create(clone3, TweenInfo.new(0.3), {
									Transparency = 1
								}):Play()
							end)
						end
					end))
					object.Trove:Add(RunService.RenderStepped:Connect(function()
						if not (bind and bind.Parent and (humanoidRootPart and humanoidRootPart.Parent)) then
							return
						end

						local raycastResult2 = game.Workspace:Raycast(
							humanoidRootPart.Position,
							createVector(0, -10, 0),
							raycastParams
						)

						if raycastResult2 then
							v9:UpdateOrigin(CFrame.new(
								raycastResult2.Position,
								raycastResult2.Position + raycastResult2.Normal
							) * CFrame.Angles(-1.5707963267948966, 0, 0))
						end
					end))
					local v10 = v.SphereDuration * 3 / 4 + v.SphereShrinkDuration - 0.35
					object.Trove:Add(task.spawn(function()
						task.wait(v.SphereDuration / 4)

						while v10 >= 0 and bind and bind.Parent do
							v10 -= task.wait(1 / v.MeshesPerSecond)
						end
					end))
					class2:DisableAllParticles(clone2)
					task.delay(0.35, function()
						task.wait(2)

						if bind and bind.Parent then
							class2:DisableAllParticles(clone2)
						end
					end)
					task.wait(1.8)

					if not (bind and bind.Parent) then
						return
					end

					v9:Stop()
					v9:Shrink()

					if not (bind and bind.Parent) then
						return
					end

					local clone4 = assets.ShrinkParticles:Clone()
					class2:ApplyScale(clone4, 0.3)
					object.Trove:Add(clone4)
					clone4.Parent = parent3
					clone4.CFrame = clone2.CFrame
					class2:DisableAllParticles(clone4)
				end)
			end

			Orbs() -- equivalent call inferred; original call site unknown
			folder = object._maid:give(vfx.EnergyBall:Clone())
			folder.Parent = EFP
			object._maid:giveTask(bind.Destroying:Connect(function()
				able({
					FX = folder,
					On = false
				})

				if v6 then
					v6:Destroy()
				end

				if folder2 then
					able({
						FX = folder2,
						On = false
					})
				end
			end))
			task.delay(3, function()
				able({
					FX = folder,
					On = false
				})

				if not (bind and bind.Parent) then
					return
				end

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						TweenService:Create(emitter, TweenInfo.new(2, Enum.EasingStyle.Sine), {
							TimeScale = 0.1
						}):Play()
					end
				end
			end)
			task.wait(0.15)

			if not (bind and bind.Parent) then
				return
			end

			local folder3 = object._maid:give(vfx["3"]:Clone())
			local v7 = object._maid:give(Instance.new("NumberValue"))
			v7.Name = "Vibration"
			v7.Parent = folder3
			v6 = folder3

			for _, emitter in pairs(folder3:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter.Parent.Name ~= "ohyeah") then
					continue
				end

				emitter.Rate *= 5
				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min / 5, lifetime.Max / 5)
			end

			local v8 = object._maid:give(Instance.new("NumberValue"))
			folder3:ScaleTo(0.001)
			v8.Value = folder3:GetScale()
			task.delay(0.6, function()
				if bind and bind.Parent then
					TweenService:Create(v8, TweenInfo.new(2.25, Enum.EasingStyle.Sine), {
						Value = 1.7
					}):Play()
					TweenService:Create(v7, TweenInfo.new(3.75, Enum.EasingStyle.Sine), {
						Value = 0.5
					}):Play()
				end
			end)
			object._maid:giveTask(v8.Changed:Connect(function()
				folder3:ScaleTo(v8.Value)
				folder:ScaleTo(v8.Value * 3)
			end))
			folder3.Parent = EFP
			task.delay(4.3, function()
				v6:Destroy()
				folder:Destroy()
			end)
		end

		task.spawn(Energy)
		local v7 = nil
		local v8 = nil
		local count2 = 0
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 6 and bind.Parent do
				count2 += 1
				v7 = char["Left Arm"].CFrame * CFrame.new(0, -0.5, 0)
				v8 = char["Right Arm"].CFrame * CFrame.new(0, -0.5, 0)
				local magnitude = (v8.Position - v7.Position).Magnitude

				if tick() - lastTime > 3 then
					parent2.CFrame = CFrame.new(v7.Position, v8.Position) * CFrame.new(0, 0, magnitude * 0.5)
				else
					parent2.CFrame = CFrame.new(v7.Position, v8.Position) * CFrame.new(0, 0, -magnitude * 0.5)
				end

				local _, v9, _ = humanoidRootPart.CFrame:ToOrientation()

				if v6 then
					local value

					if v6:FindFirstChild("Vibration") then
						value = v6.Vibration.Value
					end

					local v10

					if value then
						v10 = CFrame.new(parent2.Position) * CFrame.new(
							random:NextNumber(-value, value),
							random:NextNumber(-value, value),
							random:NextNumber(-value, value)
						) * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -0.5) * CFrame.Angles(0, math.rad(count2 * 3), 0)
					end

					if tick() - lastTime > 3 then
						v10 = parent2.CFrame * CFrame.new(-1, 0, -3.5) * CFrame.Angles(0, math.rad(count2 * 3), 0)
					end

					v6:PivotTo(v6:GetPivot():Lerp(v10, 1))

					if folder then
						folder:PivotTo(v6:GetPivot())
					end
				end

				local RunService2 = game:GetService("RunService")
				RunService2.RenderStepped:Wait()
			end
		end)
		task.delay(0.25, function()
			folder2 = quickFX({
				FX = vfx.Enabled,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			folder2:ScaleTo(0.7)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
			local raycastResult = game.Workspace:Raycast(
				char:GetPivot().Position,
				createVector(0, -20, 0),
				raycastParams
			)

			if raycastResult then
				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name == "Smoke" then
						emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
					end
				end
			end

			task.delay(1.5, function()
				able({
					FX = folder2,
					On = false
				})
			end)
		end)

		local function Other()
			task.spawn(function()
				local parent3 = object._maid:give(Instance.new("Model"))
				local highlight = Instance.new("Highlight")
				highlight.OutlineTransparency = 1
				highlight.FillTransparency = -4
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = Color3.new(1, 1, 1)
				highlight.Parent = parent3
				parent3.Parent = EFP
				task.wait(0.15)

				if not (bind and bind.Parent) then
					return
				end

				task.spawn(function()
					for i = 1, 20 do
						if not bind.Parent then
							break
						end

						local _, v10, _ = humanoidRootPart.CFrame:ToOrientation()
						local v11 = CFrame.new(parent2.Position) * CFrame.Angles(0, v10, 0) * CFrame.new(0, 0, -1)

						if i <= 14 and i > 5 then
							ZLib.BezierCharge.Create(v11, {
								ParticleTemplate = vfx.BezierTrail,
								Count = 1,
								SpawnRadius = 33,
								MinDuration = 0.44000000000000006,
								MaxDuration = 0.52,
								ControlPointHeight = 6,
								RandomControlOffset = 5,
								Spiral = true,
								SpiralTime = 1,
								SpiralRadius = 55,
								SpiralSpeed = 9.42477796076938,
								SpiralHeight = 3,
								SpiralInward = true,
								SpiralRandomDirection = true,
								SpiralApproachTime = 0.2,
								AlignToTangent = true,
								Noise = 0.8,
								Drag = 0.4
							})
						end

						local pointLight = Instance.new("PointLight")
						pointLight.Parent = parent2
						pointLight.Color = Color3.new(0.639216, 0.223529, 1)
						pointLight.Brightness = 10
						TweenService:Create(pointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Brightness = 0
						}):Play()

						if not (i > 2) then
							continue
						end

						local color = Color3.fromRGB(96, 218, 255)
						local color2 = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)

						for _ = 1, 2 do
							local v12 = LightningModule.Cast(v8.Position, v7.Position, {
								JitterScale = 1,
								Duration = random:NextNumber(0.3, 0.6) * 0.3,
								Thickness = random:NextNumber(5, 11.05) * 0.01,
								Color = color2
							})

							if v12 then
								v12.Object.Parent = parent3
							end
						end

						local v12 = humanoidRootPart.CFrame * CFrame.new(
							random:NextNumber(-5, 5),
							0,
							random:NextNumber(-5, 5)
						)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { game.Workspace.Map }

						for _ = 1, 2 do
							local raycastResult = game.Workspace:Raycast(
								v12.Position,
								createVector(0, -10, 0),
								raycastParams
							)

							if not raycastResult then
								continue
							end

							local v13 = LightningModule.Cast(v11.Position, raycastResult.Position, {
								JitterScale = 3,
								Duration = random:NextNumber(0.3, 0.6) * 0.1,
								Thickness = random:NextNumber(5, 11.05) * 0.1,
								Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
							})

							if not v13 then
								continue
							end

							local parent4 = object._maid:give(Instance.new("Part"))
							parent4.Anchored = true
							parent4.CanCollide = false
							parent4.Shape = Enum.PartType.Cylinder
							parent4.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
								0,
								0,
								1.5707963267948966
							)
							parent4.Transparency = 0
							parent4.Material = Enum.Material.Neon
							parent4.Size = createVector(0.1, 3, 3)
							parent4.Color = color
							parent4.Parent = highlight
							TweenService:Create(parent4, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
								Size = createVector(0, 0, 0)
							}):Play()
							local pointLight2 = Instance.new("PointLight")
							pointLight2.Parent = parent4
							pointLight2.Color = color
							pointLight2.Brightness = 10
							TweenService:Create(pointLight2, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
								Brightness = 0
							}):Play()
							v13.Object.Parent = parent3
						end

						task.wait(0.1)
					end
				end)
				able({
					FX = v6.PrimaryPart.ohyeah,
					On = false
				})
				task.delay(2.75, function()
					if not (bind and bind.Parent) then
						return
					end

					local v10 = quickFX({
						FX = vfx.Charged,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
					})
					v10:ScaleTo(2)
					lifeScale({
						FX = v10.Part.Attachment,
						Scale = 0.5
					})
					lifeScale({
						FX = v10.Part.f0,
						Scale = 2
					})
					playAttachment(v10)
					able({
						FX = v6.PrimaryPart.ohyeah,
						On = true
					})
					local FX = quickWeld({
						FX = vfx.Maybe,
						P = v6.PrimaryPart,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
					})
					FX:ScaleTo(0.2)
					lifeScale({
						FX = FX,
						Scale = 1.3
					})
					playAttachment(FX)
					ZLib.Mesh.EnableAt(5, 0.5, humanoidRootPart:GetPivot(), script.WindUpMesh.RingSmall)
					ZLib.Mesh.EmitAt(humanoidRootPart:GetPivot() * CFrame.new(0, -40, 0), script.Mesh.Wind)
					TweenService:Create(v10.Part.PointLight, TweenInfo.new(3, Enum.EasingStyle.Sine), {
						Brightness = 0
					}):Play()
					ZLib.Mesh.EnableAt(18, 0.15, humanoidRootPart:GetPivot(), script.Mesh.BigSphere)
					ZLib.Mesh.EnableAt(18, 0.15, humanoidRootPart:GetPivot(), script.Mesh.BigSphere2)
					ZLib.Mesh.EnableAt(18, 0.15, humanoidRootPart:GetPivot(), script.Mesh.BigSphere3)

					for i = 1, 5 do
						if not bind.Parent then
							break
						end

						local _, v12, _ = humanoidRootPart.CFrame:ToOrientation()
						local v13 = CFrame.new(parent2.Position) * CFrame.Angles(0, v12, 0) * CFrame.new(0, 0, -1)
						local pointLight = Instance.new("PointLight")
						pointLight.Parent = parent2
						pointLight.Color = Color3.new(0.639216, 0.223529, 1)
						pointLight.Brightness = 10
						TweenService:Create(pointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Brightness = 0
						}):Play()

						if not (i > 2) then
							continue
						end

						local color = Color3.fromRGB(96, 218, 255)
						local color2 = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)

						for _ = 1, 2 do
							local v14 = LightningModule.Cast(
								v8 * CFrame.new(
									random:NextNumber(-3, 3),
									random:NextNumber(-3, 3),
									random:NextNumber(-3, 3)
								).Position,
								v7 * CFrame.new(
									random:NextNumber(-3, 3),
									random:NextNumber(-3, 3),
									random:NextNumber(-3, 3)
								).Position,
								{
									JitterScale = 1,
									Duration = random:NextNumber(0.3, 0.6) * 0.3,
									Thickness = random:NextNumber(5, 11.05) * 0.01,
									Color = color2
								}
							)

							if v14 then
								v14.Object.Parent = parent3
							end
						end

						local v14 = humanoidRootPart.CFrame * CFrame.new(
							random:NextNumber(-15, 15),
							0,
							random:NextNumber(-15, 15)
						)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { game.Workspace.Map }

						for _ = 1, 2 do
							local raycastResult = game.Workspace:Raycast(
								v14.Position,
								createVector(0, -10, 0),
								raycastParams
							)

							if not raycastResult then
								continue
							end

							local v15 = LightningModule.Cast(v13.Position, raycastResult.Position, {
								JitterScale = 3,
								Duration = random:NextNumber(0.3, 0.6) * 0.1,
								Thickness = random:NextNumber(5, 11.05) * 0.1,
								Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
							})

							if not v15 then
								continue
							end

							local parent4 = object._maid:give(Instance.new("Part"))
							parent4.Anchored = true
							parent4.CanCollide = false
							parent4.Shape = Enum.PartType.Cylinder
							parent4.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
								0,
								0,
								1.5707963267948966
							)
							parent4.Transparency = 0
							parent4.Material = Enum.Material.Neon
							parent4.Size = createVector(0.1, 3, 3)
							parent4.Color = color
							parent4.Parent = highlight
							TweenService:Create(parent4, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
								Size = createVector(0, 0, 0)
							}):Play()
							local pointLight2 = Instance.new("PointLight")
							pointLight2.Parent = parent4
							pointLight2.Color = color
							pointLight2.Brightness = 10
							TweenService:Create(pointLight2, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
								Brightness = 0
							}):Play()
							v15.Object.Parent = parent3
						end

						task.wait(0.1)
					end
				end)
			end)
		end

		task.spawn(function()
			local parent3 = object._maid:give(Instance.new("Model"))
			local highlight = Instance.new("Highlight")
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = -4
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.new(1, 1, 1)
			highlight.Parent = parent3
			parent3.Parent = EFP
			task.wait(0.15)

			if not (bind and bind.Parent) then
				return
			end

			task.spawn(function()
				for i = 1, 20 do
					if not bind.Parent then
						break
					end

					local _, v10, _ = humanoidRootPart.CFrame:ToOrientation()
					local v11 = CFrame.new(parent2.Position) * CFrame.Angles(0, v10, 0) * CFrame.new(0, 0, -1)

					if i <= 14 and i > 5 then
						ZLib.BezierCharge.Create(v11, {
							ParticleTemplate = vfx.BezierTrail,
							Count = 1,
							SpawnRadius = 33,
							MinDuration = 0.44000000000000006,
							MaxDuration = 0.52,
							ControlPointHeight = 6,
							RandomControlOffset = 5,
							Spiral = true,
							SpiralTime = 1,
							SpiralRadius = 55,
							SpiralSpeed = 9.42477796076938,
							SpiralHeight = 3,
							SpiralInward = true,
							SpiralRandomDirection = true,
							SpiralApproachTime = 0.2,
							AlignToTangent = true,
							Noise = 0.8,
							Drag = 0.4
						})
					end

					local pointLight = Instance.new("PointLight")
					pointLight.Parent = parent2
					pointLight.Color = Color3.new(0.639216, 0.223529, 1)
					pointLight.Brightness = 10
					TweenService:Create(pointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Brightness = 0
					}):Play()

					if not (i > 2) then
						continue
					end

					local color = Color3.fromRGB(96, 218, 255)
					local color2 = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)

					for _ = 1, 2 do
						local v12 = LightningModule.Cast(v8.Position, v7.Position, {
							JitterScale = 1,
							Duration = random:NextNumber(0.3, 0.6) * 0.3,
							Thickness = random:NextNumber(5, 11.05) * 0.01,
							Color = color2
						})

						if v12 then
							v12.Object.Parent = parent3
						end
					end

					local v12 = humanoidRootPart.CFrame * CFrame.new(
						random:NextNumber(-5, 5),
						0,
						random:NextNumber(-5, 5)
					)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { game.Workspace.Map }

					for _ = 1, 2 do
						local raycastResult = game.Workspace:Raycast(
							v12.Position,
							createVector(0, -10, 0),
							raycastParams
						)

						if not raycastResult then
							continue
						end

						local v13 = LightningModule.Cast(v11.Position, raycastResult.Position, {
							JitterScale = 3,
							Duration = random:NextNumber(0.3, 0.6) * 0.1,
							Thickness = random:NextNumber(5, 11.05) * 0.1,
							Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
						})

						if not v13 then
							continue
						end

						local parent4 = object._maid:give(Instance.new("Part"))
						parent4.Anchored = true
						parent4.CanCollide = false
						parent4.Shape = Enum.PartType.Cylinder
						parent4.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(0, 0, 1.5707963267948966)
						parent4.Transparency = 0
						parent4.Material = Enum.Material.Neon
						parent4.Size = createVector(0.1, 3, 3)
						parent4.Color = color
						parent4.Parent = highlight
						TweenService:Create(parent4, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
							Size = createVector(0, 0, 0)
						}):Play()
						local pointLight2 = Instance.new("PointLight")
						pointLight2.Parent = parent4
						pointLight2.Color = color
						pointLight2.Brightness = 10
						TweenService:Create(pointLight2, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Brightness = 0
						}):Play()
						v13.Object.Parent = parent3
					end

					task.wait(0.1)
				end
			end)
			able({
				FX = v6.PrimaryPart.ohyeah,
				On = false
			})
			task.delay(2.75, function()
				if not (bind and bind.Parent) then
					return
				end

				local v10 = quickFX({
					FX = vfx.Charged,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
				})
				v10:ScaleTo(2)
				lifeScale({
					FX = v10.Part.Attachment,
					Scale = 0.5
				})
				lifeScale({
					FX = v10.Part.f0,
					Scale = 2
				})
				playAttachment(v10)
				able({
					FX = v6.PrimaryPart.ohyeah,
					On = true
				})
				local FX = quickWeld({
					FX = vfx.Maybe,
					P = v6.PrimaryPart,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
				})
				FX:ScaleTo(0.2)
				lifeScale({
					FX = FX,
					Scale = 1.3
				})
				playAttachment(FX)
				ZLib.Mesh.EnableAt(5, 0.5, humanoidRootPart:GetPivot(), script.WindUpMesh.RingSmall)
				ZLib.Mesh.EmitAt(humanoidRootPart:GetPivot() * CFrame.new(0, -40, 0), script.Mesh.Wind)
				TweenService:Create(v10.Part.PointLight, TweenInfo.new(3, Enum.EasingStyle.Sine), {
					Brightness = 0
				}):Play()
				ZLib.Mesh.EnableAt(18, 0.15, humanoidRootPart:GetPivot(), script.Mesh.BigSphere)
				ZLib.Mesh.EnableAt(18, 0.15, humanoidRootPart:GetPivot(), script.Mesh.BigSphere2)
				ZLib.Mesh.EnableAt(18, 0.15, humanoidRootPart:GetPivot(), script.Mesh.BigSphere3)

				for i = 1, 5 do
					if not bind.Parent then
						break
					end

					local _, v12, _ = humanoidRootPart.CFrame:ToOrientation()
					local v13 = CFrame.new(parent2.Position) * CFrame.Angles(0, v12, 0) * CFrame.new(0, 0, -1)
					local pointLight = Instance.new("PointLight")
					pointLight.Parent = parent2
					pointLight.Color = Color3.new(0.639216, 0.223529, 1)
					pointLight.Brightness = 10
					TweenService:Create(pointLight, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						Brightness = 0
					}):Play()

					if not (i > 2) then
						continue
					end

					local color = Color3.fromRGB(96, 218, 255)
					local color2 = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)

					for _ = 1, 2 do
						local v14 = LightningModule.Cast(
							v8 * CFrame.new(
								random:NextNumber(-3, 3),
								random:NextNumber(-3, 3),
								random:NextNumber(-3, 3)
							).Position,
							v7 * CFrame.new(
								random:NextNumber(-3, 3),
								random:NextNumber(-3, 3),
								random:NextNumber(-3, 3)
							).Position,
							{
								JitterScale = 1,
								Duration = random:NextNumber(0.3, 0.6) * 0.3,
								Thickness = random:NextNumber(5, 11.05) * 0.01,
								Color = color2
							}
						)

						if v14 then
							v14.Object.Parent = parent3
						end
					end

					local v14 = humanoidRootPart.CFrame * CFrame.new(
						random:NextNumber(-15, 15),
						0,
						random:NextNumber(-15, 15)
					)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { game.Workspace.Map }

					for _ = 1, 2 do
						local raycastResult = game.Workspace:Raycast(
							v14.Position,
							createVector(0, -10, 0),
							raycastParams
						)

						if not raycastResult then
							continue
						end

						local v15 = LightningModule.Cast(v13.Position, raycastResult.Position, {
							JitterScale = 3,
							Duration = random:NextNumber(0.3, 0.6) * 0.1,
							Thickness = random:NextNumber(5, 11.05) * 0.1,
							Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
						})

						if not v15 then
							continue
						end

						local parent4 = object._maid:give(Instance.new("Part"))
						parent4.Anchored = true
						parent4.CanCollide = false
						parent4.Shape = Enum.PartType.Cylinder
						parent4.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(0, 0, 1.5707963267948966)
						parent4.Transparency = 0
						parent4.Material = Enum.Material.Neon
						parent4.Size = createVector(0.1, 3, 3)
						parent4.Color = color
						parent4.Parent = highlight
						TweenService:Create(parent4, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
							Size = createVector(0, 0, 0)
						}):Play()
						local pointLight2 = Instance.new("PointLight")
						pointLight2.Parent = parent4
						pointLight2.Color = color
						pointLight2.Brightness = 10
						TweenService:Create(pointLight2, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Brightness = 0
						}):Play()
						v15.Object.Parent = parent3
					end

					task.wait(0.1)
				end
			end)
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Orb.SpinEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Bind
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SpinEvent()
		task.spawn(function()
			local lastTime = tick()
			local parent2 = object._maid:give(Instance.new("Model"))
			local highlight = Instance.new("Highlight")
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = -4
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.new(0.756863, 0.580392, 1)
			highlight.Parent = parent2
			parent2.Parent = EFP
			local part = Instance.new("Part")
			part.Size = createVector(0.3, 0.3, 0.3)
			part.Parent = EFP
			part.Anchored = true
			part.Transparency = 0
			part.Parent = EFP
			game.Debris:AddItem(part, 6)

			while tick() - lastTime < 1 do
				local v6 = char["Left Arm"].CFrame * CFrame.new(0, -0.5, 0)
				local v7 = char["Right Arm"].CFrame * CFrame.new(0, -0.5, 0)
				local magnitude = (v7.Position - v6.Position).Magnitude
				local color = Color3.fromRGB(128, 78, 255)
				local v8 = LightningModule.Cast(v6.Position, v7.Position, {
					JitterScale = 3,
					Duration = random:NextNumber(0.3, 0.6) * 0.1,
					Thickness = random:NextNumber(5, 11.05) * 0.1,
					Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
				})

				if v8 then
					v8.Object.Parent = parent2
				end

				part.CFrame = CFrame.new(v6.Position, v7.Position) * CFrame.new(0, 0, -magnitude * 0.5)
				dtwait(0.1)
			end
		end)
		local folder = quickFX({
			FX = vfx.Spin,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, 0)
		})
		able({
			FX = folder,
			On = true
		})
		local v5 = object._maid:give(Instance.new("NumberValue"))
		v5.Value = 1
		folder:ScaleTo(0.3)
		object._maid:giveTask(v5.Changed:Connect(function()
			folder:ScaleTo(v5.Value)
		end))

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local _ = emitter.RotSpeed
			local _ = emitter.SpreadAngle
			emitter.RotSpeed = NumberRange.new(1000, 1000)
			emitter.SpreadAngle = Vector2.new(12, 12)
		end

		task.delay(1, function()
			object._maid:giveTask(RunService.Heartbeat:Connect(function(dt)
				folder:PivotTo(folder:GetPivot() * CFrame.Angles(0, 25.132741228718345 * dt, 0))
			end))
		end)
		task.wait(0.5)
		able({
			FX = folder,
			On = false
		})
	end

	task.spawn(SpinEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Orb.ShootEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Bind
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ShootEvent()
		playAttachment((quickFX({
			FX = vfx.Throw,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		})))
	end

	task.spawn(ShootEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Orb