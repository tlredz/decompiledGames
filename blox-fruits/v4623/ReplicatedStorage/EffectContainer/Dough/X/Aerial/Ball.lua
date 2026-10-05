local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dough = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Dough")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local doughMiscDripBall = Effect.new("Dough.Misc.Drip.Ball")
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
Effect.new("Dough.Misc.Hit.Generic")
local terrain = workspace:WaitForChild("Terrain")
local currentCamera = workspace.CurrentCamera

local function popEffect(cFrame, value)
	local v = value or 1
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if 200 + v * 4 < magnitude then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame
	local v2 = 0

	for _, child in pairs(dough.Particles.Hit.Generic:GetChildren()) do
		v2 = math.max(v2, child.Lifetime.Max)
		local clone = child:Clone()
		Util.Misc.ScaleParticle(clone, v)
		clone.Parent = attachment
	end

	attachment.Parent = terrain

	for _, emitter in pairs(attachment:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emit = emitter:GetAttribute("Emit") or emitter:GetAttribute("EmitCount")

		if emit then
			emitter:Emit(emit)
		end
	end

	Util.Debris:AddItem(attachment, v2)
end

local v = {}
return function(data)
	if not data.EffectId then
		return
	end

	local cFrame = data.CFrame
	local reachCFrame = data.ReachCFrame
	local scale = data.Scale
	local duration = data.Duration

	if v[data.EffectId] then
		v[data.EffectId].CFrame = cFrame
	else
		if 250 + scale * 5 < (currentCamera.CFrame.p - cFrame.p).Magnitude then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame
		attachment.Parent = terrain
		v[data.EffectId] = attachment
		doughMiscDripBall:replicate({
			Anchor = v[data.EffectId],
			Speed = 2,
			Scale = scale,
			FadeIn = data.FadeIn or 0.25,
			FadeOut = data.FadeOut or 0.5
		})
	end

	if v[data.EffectId] then
		v[data.EffectId]:SetAttribute("Scale", scale)
	end

	local random = Random.new()
	doughExplosionsDripScatter:replicate({
		CFrame = cFrame,
		Scale = scale,
		Gravity = 0.5,
		Distance = scale * 5,
		Rate = 4,
		DropLifetime = 1,
		Influence = { 0.5, 2 },
		Time = random:NextNumber(0.3, 0.9)
	})
	local lastTime = tick()

	while true do
		local v2 = math.min(1, (tick() - lastTime + 0) / duration)
		local sine = Util.Tween.ease["in"].sine(v2, 0, 1, 1)

		if not (v[data.EffectId] and v[data.EffectId]:IsDescendantOf(workspace)) then
			break
		end

		v[data.EffectId].CFrame = cFrame:Lerp(reachCFrame, sine)

		if v2 == 1 then
			break
		end

		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Wait()
	end

	local _ = data.Stage == 1

	if v[data.EffectId] then
		v[data.EffectId].CFrame = reachCFrame
	end

	if data.Stage == 2 and v[data.EffectId] then
		v[data.EffectId]:Destroy()
		v[data.EffectId] = nil
	end
end