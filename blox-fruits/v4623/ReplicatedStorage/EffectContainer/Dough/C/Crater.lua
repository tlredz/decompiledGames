local createVector = vector.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local smokePath = FX:WaitForChild("Dough").C.Crater.SmokePath
local TweenService = game:GetService("TweenService")
local rock2 = Util.Rock2
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 5
	local rows = data.Rows or 10
	local segments = data.Segments or 4 + scale / 2
	local lineSegments = data.LineSegments or math.ceil(segments)
	local buso = data.Buso
	local emitDelay = data.EmitDelay or 0.5
	local emitDuration = data.EmitDuration or 0.5
	local emitLifetime = data.EmitLifetime or data.Lifetime or 1
	local expandDuration = data.ExpandDuration or 1
	local random = Random.new()
	local cframe = CFrame.Angles(0, random:NextNumber(-1, 1) * 3.141592653589793, 0)
	local total = 0
	local v = {}
	local clones = {}

	for i = 1, rows do
		local v2 = cframe * CFrame.Angles(0, random:NextNumber(-1, 1) * 3.141592653589793, 0)
		local v3 = 0

		for i2 = 1, segments do
			local v4 = 6.283185307179586 * (i2 / segments)
			local v5 = cFrame * v2 * CFrame.Angles(0, v4, 0)
			local new = rock2.new
			local number = random:NextNumber(8, 36)
			local v7 = new({
				FadeIn = 0.5,
				Lifetime = 1e999,
				FadeOut = 0.5,
				Scale = { 1, 2 },
				AngleOffset = CFrame.Angles(3.141592653589793 / number, 0, 0),
				Size = Vector3.new(random:NextNumber(1, 2), 1, random:NextNumber(1, 2)) * Vector3.new(
					i * 1.5 + 1,
					random:NextNumber(2, 8),
					i * 1.5 + 1.5
				)
			})
			v7.Offset = CFrame.new(0, -(v7.Size * v7.Scale).Y / 2.25, 0)
			local v8 = v7.Size.Z * v7.Scale
			v3 = math.max(v3, v8)
			v7:Spawn(v5 * CFrame.new(0, 0, -(total / 2 + v8 / 1.5)))
			v7:TweenShift(
				v7.Scale / 2 * v5.LookVector * random:NextNumber(0.25, 0.5),
				expandDuration * random:NextNumber(0.25, 0.5)
			)
			table.insert(v, v7)
		end

		total += v3
		local v4 = expandDuration / rows

		if v4 > 0.016666666666666666 then
			task.wait(v4)
		end
	end

	local color = nil

	if typeof(buso) == "Instance" then
		color = buso.Color
	elseif typeof(buso) == "Color3" then
		color = buso
	end

	local v2 = 0

	for i = 1, lineSegments do
		local v3 = 6.283185307179586 * (i / lineSegments)
		local v4 = cFrame * CFrame.Angles(0, 3.141592653589793, 0) * cframe * CFrame.Angles(0, v3, 0)
		local v5 = scale * rows * 6.283185307179586 * (1 / lineSegments)
		local halfTotal = total / 2
		local v7 = scale * rows * 1.5
		local clone = smokePath:Clone()
		clone.Size = Vector3.new(0.4, 0.4, halfTotal * 0)
		clone.CFrame = v4 * CFrame.new(0, 0, -segments) * CFrame.new(0, 0, -halfTotal / 2 * 0)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v2 = math.max(v2, emitter.Lifetime.Max)
			Util.Misc.ScaleParticle(emitter, scale * rows / 50)
			emitter.Rate += halfTotal
			emitter.Enabled = false

			if color then
				emitter.Color = Util.Misc.SwapColorInKeypoints(emitter.Color, Color3.new(1, 0, 0), color)
			end

			if not (emitter.Name:find("Spoke") or emitter.Name:find("Circle")) then
				continue
			end

			local v8 = emitter.Speed.Min / emitter.Speed.Max
			local velocity = Util.Misc.CalculateVelocity(v7, emitter.Lifetime.Max, emitter.Drag)
			emitter.Speed = NumberRange.new(velocity * v8, velocity)
		end

		clone.Parent = _WorldOrigin
		TweenService:Create(
			clone,
			TweenInfo.new(expandDuration / rows, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			{
				Size = Vector3.new(v5 / 2, 0.4, halfTotal),
				CFrame = v4 * CFrame.new(0, 0, -segments) * CFrame.new(0, 0, -halfTotal / 2)
			}
		):Play()
		table.insert(clones, clone)
	end

	task.wait(emitDelay)

	for _, folder in pairs(clones) do
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end

	task.wait(emitDuration + emitDelay)

	for _, folder in pairs(clones) do
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end

	local count = 0

	for k, v3 in pairs(v) do
		if k % rows == 0 then
			count += 1
		end

		local v4 = 6.283185307179586 * ((k - (count - 1) * rows) / segments)
		local velocity = Util.Misc.Physics.Velocity(
			createVector(0, 0, 0),
			((cFrame * CFrame.Angles(0, v4, 0)).LookVector / 6 + cFrame.UpVector / 2).Unit * total / 2 * random:NextNumber(
				0.75,
				1
			),
			createVector(-0, -1, -0) * workspace.Gravity,
			random:NextNumber(0.75, 1.25)
		)
		v3.Type = "Flying"
		v3:Eject({
			Velocity = velocity,
			RotVelocity = createVector(0, 0, 3.1415927) * random:NextNumber(-2, 2)
		})
	end

	task.wait(emitLifetime)

	for _, v3 in pairs(clones) do
		Util.Debris:AddItem(v3, v2)
	end

	for _, v3 in pairs(v) do
		local v4 = v3
		task.delay(random:NextNumber(0, emitLifetime), function()
			v4:Release()
		end)
	end
end