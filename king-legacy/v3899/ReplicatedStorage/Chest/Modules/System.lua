local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Debris")
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
local System = {
	EnableDescendantParticles = function(emitter)
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
			return
		end

		for _, effect in pairs(emitter:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = true
			end
		end
	end,
	Random = function(p, p2)
		local random = Random.new()
		return random.NextNumber(random, p * 100, p2 * 100) / 100
	end,
	Lerp = function(_, p, p2, p3)
		return (1 - p3) * p + p3 * p2
	end
}

function System:Curve(list, p)
	while #list > 1 do
		local v = {}

		for i = 1, #list - 1 do
			table.insert(v, (System:Lerp(list[i], list[i + 1], p)))
		end

		list = v
	end

	return list[1]
end

local function Map(p, p2, p3, p4, p5, p6)
	local v = (p - p2) / (p3 - p2) * (p5 - p4) + p4

	if not p6 then
		return v
	end

	if p4 < p5 then
		return (math.max(math.min(v, p5), p4))
	end

	return (math.max(math.min(v, p4), p5))
end

function System.BezierOutlinedLightning(p, p2, color, _, p3, parent, duration, p4, _)
	local model = Instance.new("Model")
	model.Name = "Lightning"
	model.Parent = parent
	local v = {}

	for i = 0, p2 do
		local random = Random.new()
		local vector2 = Vector3.new(random:NextNumber(-p4, p4), random:NextNumber(-p4, p4), random:NextNumber(-p4, p4))
		local v2 = System:Curve(p, (i - 0) / (p2 - 0) * 1 + 0) + vector2
		local v3 = (i == 0 or i == p2) and createVector(0, 0, 0) or vector2
		v[#v + 1] = v2 + v3
		local clone = script.Lightning:Clone()
		clone.Size = Vector3.new(p3, p3, p3)
		clone.Position = v2 + v3
		clone.Color = color
		clone.Parent = model
		clone.Transparency = 1
	end

	local clones = {}

	for i = 1, #v do
		if v[i + 1] == nil then
			continue
		end

		local clone = script.Lightning:Clone()
		clone.Color = color
		clone.Size = Vector3.new(0, 0, (v[i] - v[i + 1]).Magnitude)
		TweenService:Create(clone, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
			Size = Vector3.new(p3 * System.Random(0.9, 1.6), p3 * System.Random(0.9, 1.6), (v[i] - v[i + 1]).Magnitude)
		}):Play()
		clone.CFrame = CFrame.new((v[i] + v[i + 1]) / 2, v[i + 1])
		clone.Parent = model
		table.insert(clones, clone)
	end

	for _, v2 in pairs(clones) do
		v2.Transparency = 0
		local tween = TweenService:Create(v2, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
			Size = Vector3.new(0, 0, v2.Size.Z)
		})
		tween:Play()
		local completedConnection = nil
		local v3 = v2
		completedConnection = tween.Completed:Connect(function()
			v3.Transparency = 1
			completedConnection:Disconnect()
		end)
	end

	_G.PU:Dust(model, #clones / 10 + 1)
end

function System.Rocks(data)
	local originCFrame = data.OriginCFrame
	local rockSize = data.RockSize
	local duration = data.Duration
	local amount = data.Amount
	local radius = data.Radius
	local chance = data.Chance
	local rockModel = data.RockModel or script.Rock
	local deep = data.Deep or 50
	task.spawn(function()
		PeodizService.ForLoop({
			Step = amount
		}, function(p)
			local v = math.floor(p * amount)

			if Random.new():NextNumber(0, 100) < chance then
				local v2 = 6.283185307179586 / amount * v
				local v3 = radius * math.cos(v2)
				local v4 = radius * math.sin(v2)
				local ground = System.GetGround((originCFrame * CFrame.new(v3, 1, v4)).Position, deep)

				if ground then
					local clone = rockModel:Clone()
					clone.CollisionGroup = "Effect"
					clone.Size = rockSize * Vector3.new(
						System.Random(0.1, 2),
						System.Random(0.1, 2),
						System.Random(0.1, 2)
					)
					clone.Position = ground.Position - Vector3.new(0, clone.Size.Y, 0)
					clone.Parent = workspace.Effects
					clone.Color = ground.Object.Color
					clone.Material = ground.Object.Material
					clone.CFrame = CFrame.lookAt(clone.Position, originCFrame.Position)
					TweenService:Create(
						clone,
						TweenInfo.new(System.Random(0.19, 0.28), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Position = ground.Position - Vector3.new(0, clone.Size.Y / 3, 0)
						}
					):Play()
					task.delay(duration * System.Random(0.95, 1.05), function()
						local tween = TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
							{
								Position = ground.Position - Vector3.new(0, clone.Size.Y * 2, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						clone:Destroy()
					end)
				end
			end
		end)
	end)
end

function System.GetGround(p, value)
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = true
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Island }
	local raycastResult = workspace:Raycast(
		p + createVector(0, 5, 0),
		createVector(0, -1, 0) * ((value or 1000) + 2),
		raycastParams
	)

	if raycastResult then
		return {
			Position = raycastResult.Position,
			Object = raycastResult.Instance
		}
	end

	return nil
end

function System.EmitDescendants(emitter)
	coroutine.wrap(function()
		if emitter:IsA("ParticleEmitter") then
			local emitCount = emitter:GetAttribute("EmitCount") or 1
			local emitDelay = emitter:GetAttribute("EmitDelay") or nil

			if emitDelay then
				task.wait(emitDelay)
			end

			emitter:Emit(emitCount)
		else
			for _, emitter2 in pairs(emitter:GetDescendants()) do
				if not emitter2:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter2
				task.spawn(function()
					local emitCount = v:GetAttribute("EmitCount") or 1
					local emitDelay = v:GetAttribute("EmitDelay") or nil

					if emitDelay then
						task.wait(emitDelay)
					end

					v:Emit(emitCount)
				end)
			end
		end
	end)()
end

function System:DisableDescendantParticles()
	if self:IsA("ParticleEmitter") then
		self.Enabled = false
		return
	end

	for _, emitter2 in pairs(self:GetDescendants()) do
		if emitter2:IsA("ParticleEmitter") then
			emitter2.Enabled = false
		end
	end
end

function System.FadeOutDescendantLights(light, duration)
	if light:IsA("Light") then
		TweenService:Create(light, TweenInfo.new(duration), {
			Brightness = 0
		}):Play()
		return
	end

	for _, light2 in pairs(light:GetDescendants()) do
		if light2:IsA("Light") then
			TweenService:Create(light2, TweenInfo.new(duration), {
				Brightness = 0
			}):Play()
		end
	end
end

return System