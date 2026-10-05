local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local rocksModule = Util.RocksModule
local destroyAfter = Util.DestroyAfter
local scaleParticle = Util.ScaleParticle
local random = Random.new()
local combat = ReplicatedStorage.FX.Combat
local filterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local v2 = { workspace.Map }
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = filterDescendantsInstances

local function emitAll(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 8)
		end
	end
end

local function rootsFrom(victims)
	local humanoidRootParts = {}

	for _, v3 in ipairs(victims or {}) do
		if not (typeof(v3) == "Instance" and v3.Parent) then
			continue
		end

		local humanoidRootPart = v3:FindFirstChild("HumanoidRootPart") or v3.PrimaryPart

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			table.insert(humanoidRootParts, humanoidRootPart)
		end
	end

	return humanoidRootParts
end

local function pin(p, cFrame)
	if not (p and p.Parent) then
		return
	end

	p.CFrame = cFrame
	p.AssemblyLinearVelocity = createVector(0, 0, 0)
	p.AssemblyAngularVelocity = createVector(0, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lookSafe(p, p2)
	local unit = p2.Magnitude > 0.0001 and p2.Unit or createVector(0, 1, 0)
	local v3 = math.abs((unit:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)
	return CFrame.lookAt(p, p + unit, v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spread(i, p)
	if p <= 1 then
		return createVector(0, 0, 0)
	end

	local v3 = (i - 1) * (6.283185307179586 / p)
	return (Vector3.new(math.cos(v3) * 3.2 * 2, 0, math.sin(v3) * 3.2 * 2))
end

local v3 = {
	Floor = 0.5,
	Wind2 = 0.6,
	rocks = 0.6,
	Rocks = 0.6
}

local function landingDust(p, p2)
	local clone = combat.cracks:Clone()
	clone.CFrame = CFrame.new(p - createVector(0, 1.25, 0))
	clone.Decal:Destroy()
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 2)
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(9, 0.05, 9)
	}):Play()

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local scale = v3[emitter.Name]

		if scale then
			if p2 then
				emitter.Color = ColorSequence.new(p2.Color)
			end

			scaleParticle({
				Emitter = emitter,
				Scale = scale,
				Time = 0
			})
			emitter:Emit((math.max(1, (math.floor((emitter:GetAttribute("EmitCount") or 6) * 0.5)))))
		else
			emitter:Destroy()
		end
	end
end

local class = {}
class.__index = class

function class:_track(object)
	table.insert(self.Tweens, object)
	object:Play()
	return object
end

function class:_cancelTweens()
	for _, tween in ipairs(self.Tweens) do
		local v4 = tween
		pcall(function()
			v4:Cancel()
		end)
	end

	table.clear(self.Tweens)
end

local function makeFloatRock(ground, float, value, origin)
	local ray, v4 = Util.Ray(
		ground + createVector(0, 4, 0),
		createVector(-0, -40, -0),
		filterDescendantsInstances,
		false
	)
	local color = Color3.fromRGB(112, 98, 84)
	local slate = Enum.Material.Slate

	if ray then
		color = ray.Color
		slate = ray.Material
	end

	if ray then
		ground = v4 or ground
	end

	local object = setmetatable({
		Parts = {},
		Offsets = {},
		Spin = {},
		Tweens = {},
		Center = float
	}, class)

	for i = 1, math.random(1, 4) do
		local v5 = (i == 1 and random:NextNumber(4.6, 6.2) or random:NextNumber(1.3, 2.7)) * 2
		local part = Instance.new("Part")
		part.Name = "AdvCombatFloatRock"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = slate
		part.Color = color
		part.Size = Vector3.new(v5, v5 * random:NextNumber(0.5, 0.85), v5 * random:NextNumber(0.75, 1))
		local cframe

		if i == 1 then
			cframe = CFrame.Angles(
				random:NextNumber(-0.5, 0.5),
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				random:NextNumber(-0.5, 0.5)
			)
		else
			cframe = CFrame.new(
				random:NextNumber(-5, 5) * 2,
				random:NextNumber(-3.2, 3.2) * 2,
				random:NextNumber(-5, 5) * 2
			) * CFrame.Angles(
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				random:NextNumber(-3.141592653589793, 3.141592653589793)
			)
		end

		part.CFrame = CFrame.new(ground + Vector3.new(cframe.X * 0.3, -part.Size.Y * 1.1, cframe.Z * 0.3)) * (cframe - cframe.Position)
		part.Parent = _WorldOrigin
		table.insert(object.Parts, part)
		table.insert(object.Offsets, cframe)
		table.insert(object.Spin, CFrame.new())

		if not origin then
			object:_track(TweenService:Create(
				part,
				TweenInfo.new(value or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					CFrame = CFrame.new(float) * cframe
				}
			))
		end
	end

	if origin then
		object:Launch(origin, ground, float)
		return object
	end

	task.delay(value or 0.35, function()
		if object.Burst or object.Dropping or object.Hit then
			return
		end

		for i, part in ipairs(object.Parts) do
			if part.Parent then
				object:_track(TweenService:Create(
					part,
					TweenInfo.new(
						random:NextNumber(0.9, 1.4),
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut,
						-1,
						true
					),
					{
						CFrame = CFrame.new(float + createVector(0, 1, 0) * random:NextNumber(0.8, 1.8) * 2) * object.Offsets[i] * CFrame.Angles(
							0,
							random:NextNumber(-0.4, 0.4),
							0
						)
					}
				))
			end
		end
	end)
	return object
end

function class:Kick(p)
	if self.Dropping or self.Burst then
		return
	end

	self.Hit = true
	self:_cancelTweens()

	for i, part in ipairs(self.Parts) do
		if not part.Parent then
			continue
		end

		local v4 = part.Position - self.Center
		local unit

		if v4.Magnitude > 0.1 then
			unit = v4.Unit or p
		else
			unit = p
		end

		self.Spin[i] = self.Spin[i] * CFrame.Angles(
			random:NextNumber(-0.8, 0.8),
			random:NextNumber(-0.8, 0.8),
			random:NextNumber(-0.8, 0.8)
		)
		local v5 = unit * random:NextNumber(1.5, 3.5) * 2 + p * 2 * 2
		local cFrame = CFrame.new(self.Center) * self.Offsets[i] * self.Spin[i]
		self:_track(TweenService:Create(part, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame + v5
		}))
		local v7 = part
		task.delay(0.07, function()
			if v7.Parent and not (self.Dropping or self.Burst) then
				self:_track(TweenService:Create(
					v7,
					TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = cFrame
					}
				))
			end
		end)
	end
end

function class:Shatter()
	if self.Burst then
		return
	end

	self.Burst = true
	self:_cancelTweens()

	for _, part in ipairs(self.Parts) do
		if not part.Parent then
			continue
		end

		local v4 = part.Position - self.Center
		local unit = v4.Magnitude > 0.1 and v4.Unit or createVector(0, 1, 0)
		TweenService:Create(part, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = part.CFrame * CFrame.Angles(
				random:NextNumber(-2, 2),
				random:NextNumber(-2, 2),
				random:NextNumber(-2, 2)
			) + unit * random:NextNumber(8, 16) * 2 - createVector(0, 4, 0),
			Size = createVector(0.05, 0.05, 0.05),
			Transparency = 1
		}):Play()
		destroyAfter(part, 0.65)
	end
end

function class:_fly(list)
	local part = self.Parts[1]
	task.spawn(function()
		local lastTime = os.clock()
		local count = #list

		while count > 0 and os.clock() - lastTime < 6 do
			local v4 = RunService.Heartbeat:Wait()
			local parts = {}
			local v5 = {}

			for _, v6 in ipairs(list) do
				local part2 = v6.Part

				if not part2.Parent or v6.Landed then
					continue
				end

				v6.Velocity += Vector3.new(0, -workspace.Gravity, 0) * v4
				local v7 = v6.Velocity * v4
				local _ = v6.CFrame.Position + v7
				local v8 = part2.Size.Y * 0.5
				local v9, v10

				if v6.Velocity.Y < 0 then
					v9, v10 = Util.Ray(
						v6.CFrame.Position,
						v7 + Vector3.new(0, -v8, 0),
						filterDescendantsInstances,
						false
					)
				end

				if v9 then
					v6.Landed = true
					count -= 1
					local cFrame = CFrame.new(v10 + createVector(0, 1, 0) * (v8 * 0.7)) * v6.CFrame.Rotation
					v6.CFrame = cFrame
					table.insert(parts, part2)
					table.insert(v5, cFrame)
					TweenService:Create(part2, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(v10 + createVector(0, 1, 0) * (v8 * 0.35)) * v6.CFrame.Rotation
					}):Play()
					local v12 = part2 == part or part == nil or part.Parent == nil

					if not self.Landed and v12 then
						self.Landed = true
						landingDust(v10, v9)
						rocksModule.Ground(
							v10 + createVector(0, 1, 0),
							11.5,
							createVector(4, 3.2, 4),
							v2,
							5,
							false,
							0.6,
							false
						)
					end
				else
					v6.CFrame = (v6.CFrame + v7) * CFrame.Angles(v6.Spin.X * v4, v6.Spin.Y * v4, v6.Spin.Z * v4)
					table.insert(parts, part2)
					table.insert(v5, v6.CFrame)
				end
			end

			if #parts > 0 then
				workspace:BulkMoveTo(parts, v5)
			end
		end

		if self.Burst then
			return
		end

		task.delay(0.6, function()
			for _, part2 in ipairs(self.Parts) do
				if not part2.Parent then
					continue
				end

				TweenService:Create(part2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = createVector(0.05, 0.05, 0.05),
					CFrame = part2.CFrame - createVector(0, 1, 0) * (part2.Size.Y * 0.5)
				}):Play()
				destroyAfter(part2, 0.7)
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function outwardFrom(p, p2)
	local v4 = (p - (p2 or p)) * createVector(1, 0, 1)

	if v4.Magnitude > 0.1 then
		return v4.Unit
	end

	return Vector3.new(random:NextNumber(-1, 1), 0, random:NextNumber(-1, 1)).Unit
end

function class:Launch(p, p2, p3)
	if self.Burst or self.Dropping then
		return
	end

	self.Dropping = true
	local vector2 = outwardFrom(p3, p) -- equivalent call inferred; original call site unknown
	local v4 = math.max(p3.Y - p2.Y, 6)
	local v5 = math.sqrt(2 * workspace.Gravity * v4) * 1.3
	local v6 = random:NextNumber(12, 22) * 1.5
	local v7 = {}

	for _, part in ipairs(self.Parts) do
		if not part.Parent then
			continue
		end

		local v8 = (part.Position - p2) * createVector(1, 0, 1)
		local v9

		if v8.Magnitude > 0.1 then
			v9 = v8.Unit or vector2
		else
			v9 = vector2
		end

		table.insert(v7, {
			Part = part,
			CFrame = part.CFrame,
			Velocity = vector2 * v6 + v9 * random:NextNumber(3, 9) + createVector(0, 1, 0) * v5 * random:NextNumber(
				0.92,
				1.12
			),
			Spin = Vector3.new(random:NextNumber(-6, 6), random:NextNumber(-6, 6), random:NextNumber(-6, 6)),
			Landed = false
		})
	end

	self:_fly(v7)
end

function class:Drop(p, value)
	if self.Burst or self.Dropping then
		return
	end

	self.Dropping = true
	self:_cancelTweens()
	local v4 = value or 1
	local vector2 = outwardFrom(self.Center, p) -- equivalent call inferred; original call site unknown
	local v5 = random:NextNumber(24, 42) * 1.5 * v4
	local v6 = random:NextNumber(8, 20) * v4
	local v7 = {}

	for _, part in ipairs(self.Parts) do
		if not part.Parent then
			continue
		end

		local v8 = part.Position - self.Center
		local v9

		if v8.Magnitude > 0.1 then
			v9 = v8.Unit or vector2
		else
			v9 = vector2
		end

		table.insert(v7, {
			Part = part,
			CFrame = part.CFrame,
			Velocity = vector2 * v5 + v9 * random:NextNumber(4, 11) + createVector(0, 1, 0) * v6 * random:NextNumber(
				0.7,
				1.3
			),
			Spin = Vector3.new(random:NextNumber(-6, 6), random:NextNumber(-6, 6), random:NextNumber(-6, 6)),
			Landed = false
		})
	end

	self:_fly(v7)
end

local function impactBurst(position, unit, value, p, p2)
	local v4 = (value or 1) * 2
	local cFrame = lookSafe(position, unit) * CFrame.Angles(-1.5707963267948966, 0, 0)
	local clone = combat.ringdash:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 1.2)
	TweenService:Create(clone, TweenInfo.new(0.32, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(28, 2.2, 28) * v4
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	local clone2 = combat.shockyeah:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 1.2)
	TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(48, 0.7, 48) * v4
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		Transparency = 1
	}):Play()
	Util.Sound:Play("CombatV2.RegularPunch", position, nil, 1.1 + math.random(-14, 14) / 100)

	if p then
		local clone3 = combat.Shocklines:Clone()
		clone3.CFrame = cFrame * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
		clone3.Parent = _WorldOrigin
		destroyAfter(clone3, 1.2)
		TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = createVector(34, 1, 34) * v4
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.26, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		local clone4 = combat.purple:Clone()
		clone4.Size = createVector(3, 3, 3)
		clone4.CFrame = CFrame.new(position)
		clone4.Parent = _WorldOrigin
		destroyAfter(clone4, 0.8)
		TweenService:Create(clone4, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(22, 22, 22) * v4,
			Transparency = 1
		}):Play()
		local clone5 = combat.LightningSpark:Clone()

		if p2 then
			cFrame = lookSafe(position, p2) * CFrame.Angles(-1.5707963267948966, 0, 0) or cFrame
		end

		clone5.CFrame = cFrame * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0)
		clone5.Parent = _WorldOrigin
		destroyAfter(clone5, 0.8)
		TweenService:Create(clone5.Mesh, TweenInfo.new(0.26, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = createVector(0.05, 2.4, 0.05) * v4
		}):Play()
		TweenService:Create(clone5.Decal, TweenInfo.new(0.26, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()

		if (position - workspace.CurrentCamera.CFrame.p).Magnitude <= 180 then
			Util.CameraShaker:ShakeOnce(7, 14, 0.02, 0.25, createVector(1, 1, 1), createVector(1, 1, 1))
		end
	end
end

local function groundCrater(position, cFrame)
	Util.Sound:Play("GroundSmash", position)
	local clone = combat.outwind:Clone()
	local clone2 = combat.outwind2:Clone()
	local clone3 = combat.LightningSpark:Clone()
	local clone4 = combat.purple:Clone()
	local clone5 = combat.Ringp:Clone()
	local clone6 = combat.shockyeah:Clone()
	local part, v4, v5 = workspace:FindPartOnRayWithIgnoreList(
		Ray.new(position + createVector(0, 3, 0), createVector(0, -40, 0)),
		filterDescendantsInstances
	)
	local clone7

	if part then
		clone7 = combat.cracks:Clone()
		clone7.CFrame = CFrame.new(v4 + v5 * 0.1)
		clone7.Parent = _WorldOrigin
		destroyAfter(clone7, 1.5)
		TweenService:Create(
			clone7,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = createVector(90, 0.05, 90)
			}
		):Play()
		TweenService:Create(
			clone7.Decal,
			TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
			{
				Transparency = 1
			}
		):Play()
		position = v4
	else
		clone7 = nil
	end

	destroyAfter(clone, 1.5)
	destroyAfter(clone2, 1.5)
	destroyAfter(clone3, 1.5)
	destroyAfter(clone4, 1.5)
	destroyAfter(clone5, 1.5)
	destroyAfter(clone6, 1.5)
	task.wait(0.067)
	task.spawn(function()
		local clone8 = combat.Ribbon:Clone()
		clone8.CFrame = CFrame.new(position) * CFrame.new(0, 5, 0)
		clone8.Parent = _WorldOrigin
		destroyAfter(clone8, 1.8)
		TweenService:Create(clone8, TweenInfo.new(0.44, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(120, 160, 120)
		}):Play()
		TweenService:Create(clone8, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()

		for _ = 1, 5 do
			TweenService:Create(clone8, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = clone8.CFrame * CFrame.Angles(0, -2.9670597283903604, 0)
			}):Play()
			task.wait(0.2)
		end
	end)

	if part then
		rocksModule.Ground(position + createVector(0, 1, 0), 40, createVector(8, 5, 8), v2, 6, false, 0.4)
	end

	clone.CFrame = CFrame.new(position) * CFrame.new(0, 1, 0)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	clone2.CFrame = CFrame.new(position) * CFrame.new(0, 11, 0)
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 7)
	clone3.CFrame = CFrame.new(position) * CFrame.new(0, 3, 0)
	clone3.Parent = _WorldOrigin
	destroyAfter(clone3, 7)
	clone4.CFrame = CFrame.new(position) * CFrame.new(0, 1, 0)
	clone4.Parent = _WorldOrigin
	destroyAfter(clone4, 7)
	clone5.CFrame = CFrame.new(position) * CFrame.new(0, 10, 0)
	clone5.Parent = _WorldOrigin
	destroyAfter(clone5, 7)
	clone6.CFrame = CFrame.new(position)
	clone6.Parent = _WorldOrigin
	destroyAfter(clone6, 7)
	TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Size = createVector(130, 1.2, 130),
		Transparency = 1
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.417, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Size = createVector(100, 2, 100)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.23, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		Scale = createVector(0.05, 6, 0.05)
	}):Play()
	TweenService:Create(clone3.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = createVector(140, 140, 140),
		Transparency = 1
	}):Play()
	TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		CFrame = (cFrame or CFrame.new(position)) * CFrame.new(0, 15, 0),
		Size = createVector(120, 5, 120),
		Transparency = 1
	}):Play()
	TweenService:Create(clone6, TweenInfo.new(0.44, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = createVector(240, 0.72, 240)
	}):Play()
	TweenService:Create(clone6, TweenInfo.new(0.44, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()

	if part and clone7 then
		clone7.Rocks.Color = ColorSequence.new(part.Color)
		clone7.Attachment.ParticleEmitter.Color = ColorSequence.new(part.Color)
		task.spawn(function()
			task.wait()
			clone7.Rocks:Emit(8)
			task.wait()
			clone7.Rocks:Emit(8)
		end)

		for _, child in ipairs(clone7.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end
end

local v4 = {}
local v5 = {}

local function stageCast(data)
	local points = data.Points or {}
	local v6 = math.max(0, masterClock:GetTime() - (data.StartTime or masterClock:GetTime()))
	local v7 = math.max(0.05, (data.Rise or 0.35) - v6)
	local rockKey = data.RockKey or tostring(data.Origin)
	local v8 = {}
	v4[rockKey] = v8
	v5[rockKey] = data.Origin
	local origin

	if data.Miss then
		origin = data.Origin or nil
	else
		origin = nil
	end

	if not data.Airborne then
		for i, point in ipairs(points) do
			local v9 = i
			local v10 = point
			task.delay((i - 1) * 0.045, function()
				v8[v9] = makeFloatRock(v10.Ground, v10.Float, v7, origin)
			end)
		end
	end

	task.spawn(function()
		groundCrater(data.Origin, data.CFrame)
	end)

	if (data.Origin - workspace.CurrentCamera.CFrame.p).Magnitude <= 250 then
		Util.CameraShaker:ShakeOnce(20, 10, 0.05, 0.7, createVector(1.2, 1.2, 1.2), createVector(1.2, 1.2, 1.2))
	end

	task.delay(5, function()
		if not data.Miss and v4[rockKey] == v8 then
			for _, v9 in pairs(v8) do
				v9:Drop(v5[rockKey] or data.Origin)
			end

			v4[rockKey] = nil
			v5[rockKey] = nil
		end
	end)
end

local function stageBounce(data)
	local points = data.Points or {}
	local v6 = rootsFrom(data.Victims)
	local v7 = v4[data.RockKey or tostring(data.Origin)] or {}

	if #v6 == 0 then
		return
	end

	local sequence = data.Sequence

	if not sequence or #sequence == 0 then
		return
	end

	local v8 = math.max(0, masterClock:GetTime() - (data.StartTime or masterClock:GetTime()))
	local v9 = os.clock() - v8
	local position = v6[1].Position
	local time = 0

	for i, v10 in ipairs(sequence) do
		local point = points[v10.Index]

		if not point then
			continue
		end

		local v11 = point.Float + (v10.Offset or createVector(0, 0, 0))
		local v12 = v11 - position
		local unit = v12.Magnitude > 0.05 and v12.Unit or createVector(0, 1, 0)
		local v13 = v9 + time
		local v14 = v9 + v10.Time
		local v15 = math.max(v10.Time - time, 0.008333333333333333)

		if os.clock() < v14 then
			while true do
				local v16 = math.clamp((os.clock() - v13) / v15, 0, 1)
				local v17 = lookSafe(position:Lerp(v11, 1 - (1 - v16) ^ 4), unit) -- equivalent call inferred; original call site unknown

				for i2, v18 in ipairs(v6) do
					local v20 = spread(i2, #v6) -- equivalent call inferred; original call site unknown
					local cFrame = v17 + v20

					if not (v18 and v18.Parent) then
						continue
					end

					v18.CFrame = cFrame
					v18.AssemblyLinearVelocity = createVector(0, 0, 0)
					v18.AssemblyAngularVelocity = createVector(0, 0, 0)
				end

				if v16 >= 1 then
					local v18

					if i == #sequence and data.Landing then
						v18 = data.Landing - v11
					end

					impactBurst(v11, unit, 0.85 + i / #sequence * 0.5, i % 3 == 0 or i == #sequence, v18)
					local v19 = v7[v10.Index]

					if not v19 then
						break
					end

					v19:Kick(unit)
					break
				else
					RunService.Heartbeat:Wait()
				end
			end
		end

		time = v10.Time
		position = v11
	end
end

local function stageSlam(data)
	local v6 = rootsFrom(data.Victims)
	local landing = data.Landing
	local from = data.From or landing
	local fall = data.Fall or 0.13
	local v7 = landing - from
	local unit = v7.Magnitude > 0.05 and v7.Unit or createVector(0, -1, 0)
	local v8 = math.max(0, masterClock:GetTime() - (data.StartTime or masterClock:GetTime()))
	local v9 = os.clock() - v8

	if #v6 > 0 and os.clock() < v9 + fall then
		while true do
			local v10 = math.clamp((os.clock() - v9) / fall, 0, 1)
			local lerped = from:Lerp(landing + createVector(0, 3, 0), v10 * v10)

			for i, v11 in ipairs(v6) do
				local vector2 = not (unit.Magnitude > 0.0001) and createVector(0, 1, 0) or unit.Unit or createVector(
					0,
					1,
					0
				)
				local v12 = math.abs((vector2:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(1, 0, 0) or createVector(
					0,
					1,
					0
				)
				local cframe = CFrame.lookAt(lerped, lerped + vector2, v12)
				local v14 = spread(i, #v6) -- equivalent call inferred; original call site unknown
				local cFrame = cframe + v14

				if not (v11 and v11.Parent) then
					continue
				end

				v11.CFrame = cFrame
				v11.AssemblyLinearVelocity = createVector(0, 0, 0)
				v11.AssemblyAngularVelocity = createVector(0, 0, 0)
			end

			if v10 >= 1 then
				break
			else
				RunService.Heartbeat:Wait()
			end
		end
	end

	local rockKey = data.RockKey or tostring(data.Origin)
	local v10 = v4[rockKey]

	if v10 then
		local v11 = v5[rockKey] or landing
		local count = 0

		for _, v12 in pairs(v10) do
			local v13 = count * 0.025
			count += 1
			local v14 = v12
			task.delay(v13, function()
				v14:Drop(v11, 2.4)
			end)
		end

		v4[rockKey] = nil
		v5[rockKey] = nil
	end

	if (landing - workspace.CurrentCamera.CFrame.p).Magnitude <= 250 then
		Util.CameraShaker:ShakeOnce(35, 14, 0.02, 0.9, createVector(1.4, 1.4, 1.4), createVector(1.4, 1.4, 1.4))
	end

	groundCrater(landing, data.CFrame)
end

local function stageDrop(data)
	local rockKey = data.RockKey or tostring(data.Origin)
	local v6 = v4[rockKey]

	if not v6 then
		return
	end

	local v7 = v5[rockKey] or data.Origin
	v4[rockKey] = nil
	v5[rockKey] = nil

	for k, v8 in pairs(v6) do
		local v9 = v8
		task.delay((k - 1) * 0.06, function()
			v9:Drop(v7)
		end)
	end
end

return function(data)
	local origin = data.Origin or data.CFrame and data.CFrame.p or data.hrp and data.hrp.Position

	if not origin or (origin - workspace.CurrentCamera.CFrame.p).Magnitude > 700 then
		return
	end

	local stage = data.Stage or "Slam"

	if stage == "Cast" then
		stageCast(data)
	elseif stage == "Bounce" then
		stageBounce(data)
	elseif stage == "Slam" then
		stageSlam(data)
	elseif stage == "Drop" then
		stageDrop(data)
	end
end