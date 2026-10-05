local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dough = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Dough")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Ball = require(dough.Util.Drip.Ball)
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local v = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v:setAction(function(object, p)
	local now = tick()

	for k, v2 in pairs(object.Pool) do
		local v3 = now - v2.Start
		local v4 = math.min(1, v3 / v2.Ball.FadeIn)
		local quad = Util.Tween.ease.out.quad(v4, 0, 1, 1)
		local scale = v2.Scale

		if v2.SpecialLifetime then
			v2.ScaleToReach = v2.Ball.Lifetime:GetAttribute("Scale")
		else
			v2.ScaleToReach = scale
		end

		if typeof(v2.Ball.Anchor) == "Instance" and not (v2.ReadyToDestroy or v2.Ball.Anchor:IsDescendantOf(workspace)) then
			v2.ReadyToDestroy = now
		end

		if v2.ReadyToDestroy then
			local v5 = math.min(1, (now - v2.ReadyToDestroy) / v2.Ball.FadeOut)
			local circ = Util.Tween.ease.out.circ(v5, 0, 1, 1)

			if not v2.Exploded then
				v2.Exploded = true
				doughExplosionsDripScatter:replicate({
					CFrame = v2.Ball:__getCFrame() + Vector3.new(0, v2.Ball.Scale, 0),
					Scale = v2.Ball.Scale,
					Gravity = 0.5,
					Distance = v2.Ball.Scale * 5,
					Rate = 15,
					DropLifetime = 2,
					Influence = { 0.5, 2 },
					Time = v2.RNG:NextNumber(0.3, 1.5),
					Force = true
				})
			end

			v2.Ball:enable(false)
			v2.Ball.Scale = Util.Tween.point(v2.ScaleToReach, 0, circ)
			v2.Ball:update(p)

			if v5 == 1 then
				v2.Ball:Destroy()
				object:remove(k)
			end
		else
			if v2.Ball.FadeIn < v3 then
				if v2.SpecialLifetime then
					if not (v2.Ball.Anchor and v2.Ball.Anchor:IsDescendantOf(workspace)) then
						v2.ReadyToDestroy = now
					end
				elseif v2.Ball.Lifetime < v4 then
					v2.ReadyToDestroy = now
				end

				v2.Ball.Scale = v2.ScaleToReach
			else
				v2.Ball:enable(true)
				v2.Ball.Scale = v2.ScaleToReach * quad
			end

			v2.Ball:update(p)
		end
	end
end)
return function(data)
	local anchor = data.Anchor
	local cFrame = data.CFrame
	local scale = data.Scale
	local speed = data.Speed
	local ball = Ball.new({
		Anchor = anchor,
		CFrame = cFrame,
		Scale = scale,
		FadeIn = data.FadeIn,
		FadeOut = data.FadeOut,
		Lifetime = data.Lifetime or anchor,
		AnimationSpeed = speed
	})
	v:add({
		SpecialLifetime = typeof(ball.Lifetime) == "Instance",
		AnimatedScale = scale,
		Scale = scale,
		Ball = ball,
		OutlineScale = 1.1,
		RNG = Random.new(),
		Start = tick()
	})
end