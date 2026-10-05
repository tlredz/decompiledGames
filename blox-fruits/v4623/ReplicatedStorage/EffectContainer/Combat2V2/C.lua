local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
local destroyAfter = Util.DestroyAfter
local scaleParticle = Util.ScaleParticle
local random = Random.new()
local combat = ReplicatedStorage.FX.Combat
local v = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function lookSafe(p, p2)
	local unit = p2.Magnitude > 0.0001 and p2.Unit or createVector(0, 0, 1)
	local v2 = math.abs((unit:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)
	return CFrame.lookAt(p, p + unit, v2)
end

local function emitScaled(folder, scale, value)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		scaleParticle({
			Emitter = emitter,
			Scale = scale,
			Time = 0
		})
		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			emitter:Emit((math.max(1, (math.floor(emitCount * (value or 1))))))
		end
	end
end

local success, result = pcall(function()
	local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
	return CustomCollisions.new("Rocks")
end)
local v2 = success and result or nil

local function addDebris(part, assemblyLinearVelocity, p)
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CustomPhysicalProperties = PhysicalProperties.new(2.5, 0.75, 0.12, 1, 1)

	if v2 then
		v2:ApplyCollision(part, nil, true)
	else
		part.CanCollide = true
	end

	part.Anchored = false
	part.AssemblyLinearVelocity = assemblyLinearVelocity
	part.AssemblyAngularVelocity = part.CFrame.UpVector * 4 * random:NextNumber(0.55, 1.45) + part.CFrame.LookVector * 4 * random:NextNumber(
		-0.45,
		0.45
	) + part.CFrame.RightVector * 4 * random:NextNumber(-0.3, 0.3)
	TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, p), {
		Size = createVector(0, 0, 0)
	}):Play()
	destroyAfter(part, p + 0.4)
end

local function punchBlast(cFrame, p)
	local clone = combat.LightningSpark:Clone()
	local clone2 = combat.Shockwave:Clone()
	local clone3 = combat.Shockwave2:Clone()
	local clone4 = combat.ParticlesDash:Clone()
	clone.Mesh.Scale *= 1.5 * p
	clone.CFrame = cFrame * CFrame.new(0, 0, -20 * p) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 1.5)
	TweenService:Create(clone.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Scale = createVector(0.05, 6, 0.05) * p,
		Offset = Vector3.new(0, -20 * p, 0)
	}):Play()
	TweenService:Create(clone.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()
	local v3 = createVector(12.429, 15.5, 57.286) * p

	for i = 1, 5 do
		if not (i < 5) then
			continue
		end

		local clone5 = clone2:Clone()
		local clone6 = clone3:Clone()
		local v4 = 20 * p * (i / 5 + 1)
		local v5 = (i - 1) * -18 * p
		local size = v3

		if i == 1 then
			v4 *= 0.25
			v5 *= 0.25
			size *= 0.75
		end

		clone5.CFrame = cFrame * CFrame.new(-v4, 0, 6 + v5)
		clone6.CFrame = cFrame * CFrame.new(v4, 0, 6 + v5)
		clone5.Parent = _WorldOrigin
		clone6.Parent = _WorldOrigin
		destroyAfter(clone5, 3)
		destroyAfter(clone6, 3)
		task.delay((i - 1) * 0.06, function()
			TweenService:Create(clone5, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(-5 * p, 0, -22 * p)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(5 * p, 0, -16 * p)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	end

	local v4 = math.floor(p / 2) + 3

	for i = 1, v4 do
		local v5 = i
		task.delay((i - 1) * 0.05, function()
			local clone5 = combat.Frontwave:Clone()
			clone5.CFrame = cFrame * CFrame.new(0, 0, -2) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone5.Transparency = 0.5
			clone5.Parent = _WorldOrigin
			destroyAfter(clone5, 3)
			TweenService:Create(
				clone5,
				TweenInfo.new(v5 * 0.02 + 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(26, 26, 26) * p * v5 / 1.5
				}
			):Play()
			TweenService:Create(
				clone5,
				TweenInfo.new(v5 * 0.02 + 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = cFrame * CFrame.new(0, 0, -80 * p) * CFrame.Angles(-1.5707963267948966, 0.57, 0)
				}
			):Play()
			TweenService:Create(
				clone5,
				TweenInfo.new(v5 * 0.02 + 0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
			local clone6 = combat.ringdash:Clone()
			clone6.CFrame = cFrame * CFrame.new(0, 0, v5 * -20 * p * (4 / v4)) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			clone6.Size = Vector3.new(v5 * 9 + 20, 80, v5 * 9 + 20) * p / 4
			clone6.Parent = _WorldOrigin
			destroyAfter(clone6, 2)
			TweenService:Create(
				clone6,
				TweenInfo.new(v5 * 0.05 + 0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					CFrame = clone6.CFrame * CFrame.new(0, -12, 0),
					Size = clone6.Size * createVector(4, 0.1, 4)
				}
			):Play()
		end)
	end

	for i = 1, 3 do
		local clone5 = combat.spiraldash:Clone()
		clone5.CFrame = cFrame * CFrame.new(0, 0, i * -17.5 * p) * CFrame.Angles(
			-1.5707963267948966,
			math.rad(i * 45),
			0
		)
		clone5.Parent = _WorldOrigin
		destroyAfter(clone5, 1.5)
		local cFrame2 = clone5.CFrame
		local v5 = 1.4 / i
		TweenService:Create(clone5, TweenInfo.new(v5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = Vector3.new(25.801, 52.801 / i, 25.001) * p * i,
			Transparency = 1
		}):Play()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		numberValue.Changed:Connect(function(p2)
			clone5.CFrame = cFrame2 * CFrame.new(0, -20 * p2, 0) * CFrame.Angles(0, math.rad(-680 * p2), 0)
		end)
		local tween = TweenService:Create(numberValue, TweenInfo.new(v5, Enum.EasingStyle.Linear), {
			Value = 1
		})
		tween:Play()
		tween.Completed:Connect(function()
			numberValue:Destroy()
		end)
	end

	local part, _, _ = workspace:FindPartOnRayWithWhitelist(
		Ray.new(cFrame.p + createVector(0, 3, 0), createVector(0, -40, 0) * p),
		{ workspace.Map }
	)

	if part then
		clone4.Smoke.Color = ColorSequence.new(part.Color)
		clone4.SlashSmoke.Color = ColorSequence.new(part.Color)
	end

	clone4.CFrame = cFrame * CFrame.new(0, 0, -5 * p)
	clone4.Size *= p * 2
	clone4.Parent = _WorldOrigin
	emitScaled(clone4, p * 2, 1)
	destroyAfter(clone4, 3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spikeProfile(p)
	return math.sin(p * 3.141592653589793) ^ 0.7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spikeAt(p, p2, p3)
	if p.Stagger then
		return (p2 - 0.5) / p3
	end

	return (p2 - 1) / math.max(p3 - 1, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function arcPoint(p, p2, p3, p4, inset)
	local v3 = math.min(p3 / 0.3, 1)
	local v4 = v3 * v3 * (3 - v3 * 2) * 4 + 5 - (inset or 0)
	return (p * CFrame.new(p2 * v4 * p4, 0, -p3 * 70 * p4)).Position
end

local function buildSpike(p, unit, unit2, p2, p3, p4, p5, color, material, value)
	local cross = unit:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.0001 then
		return
	end

	local unit3 = cross.Unit
	local v3 = value or 5
	local v4 = v3 + 3 * (v3 / 5)
	local v5 = p2 + v3
	local v6 = math.clamp(math.round(v5 / 4.5), 2, 4)
	local unit4 = (CFrame.fromAxisAngle(unit3, -1.2217304763960306) * createVector(0, 1, 0)).Unit
	local v7 = p - createVector(0, 1, 0) * v4
	local v8 = v7
	local total = 0
	local v9 = {}

	for i = 1, v6 do
		if 1.75 * (p5 / 2.5) < i / 4 then
			continue
		end

		local v11 = v5 / v6
		local v12 = total / v5
		total += v11
		local v13 = (v12 + total / v5) * 0.5
		local v14 = -70 + 70 * v13 ^ 1.25
		unit4 = (CFrame.fromAxisAngle(unit3, (math.rad(v14))) * createVector(0, 1, 0)).Unit
		local v15 = p3 * (1 - v13 * 0.2)
		local v16 = p4 * (1 - v13 * 0.72)
		local v17 = v7 + unit4 * v11
		local v18 = (v7 + v17) * 0.5
		local part = Instance.new("Part")
		part.Name = "AdvCombatSpike"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Color = color
		part.Material = material
		part.Size = Vector3.new(v15, v11 + v16, v16 * 2)
		local v19 = unit2 - unit4 * unit2:Dot(unit4)
		local unit5

		if v19.Magnitude > 0.0001 then
			unit5 = v19.Unit or unit
		else
			unit5 = unit
		end

		local cframe = CFrame.fromMatrix(v18, unit5, unit4, unit5:Cross(unit4).Unit)
		local v20 = math.rad(70 * v13 ^ 1.25 + 30)
		local v21 = CFrame.new(v8) * CFrame.fromAxisAngle(unit3, -v20) * CFrame.new(-v8) * cframe
		part.CFrame = v21
		part.Parent = _WorldOrigin
		TweenService:Create(
			part,
			TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, (i - 1) * 0.02),
			{
				CFrame = cframe
			}
		):Play()
		table.insert(v9, {
			Part = part,
			Final = cframe,
			Start = v21
		})
		v7 = v17
	end

	task.delay(1.6 + p5 * 0.6, function()
		local v10 = #v9

		for i, v11 in ipairs(v9) do
			local part = v11.Part

			if not part.Parent then
				continue
			end

			TweenService:Create(
				part,
				TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, (v10 - i) * 0.025),
				{
					CFrame = v11.Start,
					Size = createVector(0.05, 0.05, 0.05)
				}
			):Play()
			destroyAfter(part, 0.75)
		end
	end)
	return v7, unit4
end

local function arcSpike(p, p2, p3, p4, p5, value, data)
	local position = arcPoint(p, p2, p3, p5, data.Inset) -- equivalent call inferred; original call site unknown
	local ray, v4 = Util.Ray(position + createVector(0, 14, 0), createVector(0, -45, 0), v, false)

	if not ray then
		return
	end

	local unit = (p.RightVector * p2).Unit
	local position2 = arcPoint(p, p2, math.min(p3 + 0.02, 1), p5, data.Inset) -- equivalent call inferred; original call site unknown
	local v8 = position2 - arcPoint(p, p2, math.max(p3 - 0.02, 0), p5, data.Inset)
	local unit2 = v8.Magnitude > 0.001 and v8.Unit or p.LookVector
	local v9 = (7 + 15 * spikeProfile(p4)) * (0.7 + 0.3 * p5) * (1 + p3 * 0.5) * data.Scale
	local v10 = math.max(4 * (0.8 + 0.2 * p5) * data.Scale, (value or 0) * 1.35)
	local v11 = 7 * (0.8 + 0.2 * p5) * data.Scale
	local v12 = math.max(2, 5 * data.Scale)
	local spike, v13 = buildSpike(v4, unit, unit2, v9, v10, v11, p5, ray.Color, ray.Material, v12)

	if not (spike and data.Chunks) then
		return
	end

	local part = Instance.new("Part")
	part.Name = "AdvCombatArcChunk"
	part.Color = ray.Color
	part.Material = ray.Material
	local v14 = 3 * (0.8 + 0.3 * p5) * random:NextNumber(0.75, 1.45)
	part.Size = Vector3.new(
		v14 * random:NextNumber(2.1, 3),
		v14 * random:NextNumber(0.7, 1.05),
		v14 * random:NextNumber(1.8, 2.6)
	)
	local vector2 = not (v13.Magnitude > 0.0001) and createVector(0, 0, 1) or v13.Unit or createVector(0, 0, 1)
	local v15 = math.abs((vector2:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)
	part.CFrame = CFrame.lookAt(spike, spike + vector2, v15) * CFrame.Angles(
		math.rad((random:NextNumber(-18, 18))),
		math.rad((random:NextNumber(-180, 180))),
		(math.rad((random:NextNumber(-18, 18))))
	)
	part.Parent = _WorldOrigin
	addDebris(
		part,
		(v13 * 64 * random:NextNumber(0.8, 1.25) + unit * random:NextNumber(8, 16)) * (1 + p5 * 0.5),
		1.5 * (1 + p5 * 0.5)
	)
end

local v3 = {
	{
		Inset = 0,
		Scale = 1,
		Chunks = true
	},
	{
		Inset = 1,
		Scale = 0.72,
		Cutoff = 0.35,
		Stagger = true,
		Chunks = false
	}
}

local function rockArcs(cFrame, p)
	local v4 = math.max(3, (math.floor(7 * (0.7 + 0.3 * p))))

	for _, v5 in ipairs(v3) do
		for _, v6 in ipairs({ -1, 1 }) do
			for i = 1, v4 do
				local v7 = spikeAt(v5, i, v4) -- equivalent call inferred; original call site unknown

				if v5.Cutoff and v5.Cutoff < v7 then
					continue
				end

				local v9 = spikeAt(v5, i < v4 and i + 1 or i - 1, v4) -- equivalent call inferred; original call site unknown
				local position = arcPoint(cFrame, v6, v9, p, v5.Inset) -- equivalent call inferred; original call site unknown
				local v11 = v6
				local v12 = v7
				local magnitude = (position - arcPoint(cFrame, v6, v7, p, v5.Inset)).Magnitude
				local v14 = v5
				task.delay(v7 * 0.25, function()
					arcSpike(cFrame, v11, v12, v12, p, magnitude, v14)
				end)
			end
		end
	end
end

return function(data)
	local cFrame = data.CFrame

	if not cFrame then
		return
	end

	local origin = data.Origin or cFrame.Position

	if (origin - workspace.CurrentCamera.CFrame.p).Magnitude > 1200 then
		return
	end

	local v4 = math.clamp(data.Power or 1, 1, 3)
	Util.Sound:Play("CombatV2.BigFatPunch", origin, v4 * 50, 1.25 - v4 * 0.15)
	Util.Sound:Play("HitKnockback", origin, v4 * 50)
	punchBlast(cFrame, v4)
	rockArcs(cFrame, v4)

	if (origin - workspace.CurrentCamera.CFrame.p).Magnitude <= 100 then
		Util.CameraShaker:ShakeOnce(v4 * 7, v4 * 7, 0.03, v4 * 0.5, createVector(1, 1, 1), createVector(1, 1, 1))
	end
end