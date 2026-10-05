local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Pool = require(ReplicatedStorage.Pool)
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
workspace:WaitForChild("_WorldOrigin")
local currentCamera = workspace.CurrentCamera
local misc = Util.Misc
local _ = Util.DistributedLoop
local _ = Util.Tween
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local v = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v:setAction(function(object, _)
	local now = tick()

	for _, v2 in pairs(object.Pool) do
		if v2.Delete then
			if now - v2.Delete > v2.MaxLifetime then
				v2.Attachment:Destroy()
				object:remove(v2)
			else
				Util.Sound:FadeOut(v2.Sound, v2.MaxLifetime)

				for _, particle in pairs(v2.Particles) do
					particle.Particle.Enabled = false
				end
			end
		elseif v2.Root and v2.Root:IsDescendantOf(workspace) and v2.Indicator and v2.Indicator:IsDescendantOf(workspace) then
			local cFrame = v2.GetCFrame()
			v2.Attachment.CFrame = cFrame * CFrame.new(0, -v2.Scale / 2, 0)

			for _, particle in pairs(v2.Particles) do
				particle.Particle.Enabled = true
			end

			if now - v2.LastShake >= 0.1 then
				local v3 = math.max(
					0,
					((currentCamera.CFrame.p - v2.Attachment.CFrame.p).Magnitude - (currentCamera.Focus.p - v2.Attachment.CFrame.p).Magnitude) / (20 + 10 * v2.Scale)
				)

				if v3 <= 1 and v3 > 0 then
					local power = 1 - v3
					Effect.new("ShakeCam"):replicate({
						Magnitude = 6,
						Roughness = 4,
						FadeIn = 0.05,
						FadeOut = 0.1,
						PosInfluence = createVector(0.1, 0.1, 0.1),
						RotInfluence = createVector(0, 0, 0.25),
						Power = power
					})
				end

				v2.LastShake = now
			end

			if now - v2.Last >= 1 / v2.Rate then
				doughExplosionsDripScatter:replicate({
					CFrame = v2.Attachment.CFrame * CFrame.Angles(1.5707963267948966, 0, 0),
					Spread = Vector2.new(45, 45),
					Scale = v2.Scale,
					Drag = 4,
					Distance = 2.5 + v2.Scale * 2,
					Rate = 1,
					Gravity = 0.5,
					Time = 0.25,
					Influence = { 0.5, 1 }
				})
				v2.Last = now
			end
		else
			v2.Delete = now
		end
	end
end)
return function(data)
	local root = data.Root
	local indicator = data.Indicator
	local scale = data.Scale or 1
	local rate = data.Rate or 15

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		return data.Root:IsA("BasePart") and data.Root.CFrame or data.Root:IsA("Attachment") and data.Root.WorldCFrame
	end

	local magnitude = ((fn()).p - currentCamera.CFrame.p).Magnitude

	if 175 + scale * 2 < magnitude then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.CFrame = fn()
	local maxLifetime = 0
	local particles = {}

	for _, child in pairs(dough.Particles.Misc.FloorHand:GetChildren()) do
		maxLifetime = math.max(maxLifetime, child.Lifetime.Max)
		local clone = child:Clone()
		clone.Enabled = false
		clone.Parent = attachment
		table.insert(particles, {
			Particle = clone,
			Data = {
				Size = clone.Size.Keypoints,
				Speed = clone.Speed,
				Acceleration = clone.Acceleration
			}
		})
	end

	for _, v4 in pairs(particles) do
		misc.ScaleParticle(v4.Particle, scale, v4.Data)
	end

	attachment.Parent = workspace.Terrain
	local sound = Util.Sound:Play("Dough.DoughAmbienceLoop", attachment, nil, 5.287 / maxLifetime)

	if data.EffectDelay then
		task.wait(data.EffectDelay)
	end

	v:add({
		Sound = sound,
		LastShake = 0,
		Last = 0,
		Rate = rate,
		Root = root,
		Scale = scale,
		GetCFrame = fn,
		Indicator = indicator,
		Attachment = attachment,
		MaxLifetime = maxLifetime,
		Particles = particles
	})
end