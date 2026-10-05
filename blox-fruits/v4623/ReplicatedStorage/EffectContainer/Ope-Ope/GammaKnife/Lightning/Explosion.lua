local createVector = vector.create

local function xzAim(p, p2)
	return CFrame.new(p, p2 * createVector(1, 0, 1) + Vector3.new(0, p.Y))
end

local RunService = game:GetService("RunService")
workspace:WaitForChild("_WorldOrigin")
local util = game.ReplicatedStorage.Util
require(util.Debris)
local Effect = require(game.ReplicatedStorage.Effect)
local Tween = require(util.Tween)
local Sound = require(util.Sound)
local LightningExplosion = require(util.LightningBolt.LightningExplosion)
local LightningBolt = require(util.LightningBolt)
local LightningSparks = require(util.LightningBolt.LightningSparks)

local function Bolt(attachment, clone, number, number2, thickness, p, p2, color, p3)
	Random.new()
	local v = LightningBolt.new(attachment, clone, number, number2, p, color)

	if v then
		v.PulseLength = 1 / (0.5 * p2)
		v.FadeLength = 1 / (0.6 * p2)
		v.PulseSpeed = 1 / (0.4 * p2)
		v.MinThicknessMultiplier = 0.5
		v.MaxThicknessMultiplier = 0.75
		v.AnimationSpeed = 8
		v.Thickness = thickness
		v.AddTransparency = 0.1

		if p3 then
			LightningSparks.new(v, p)
		end
	end
end

return function(list)
	local cFrame, v2, v3, v4 = unpack(list)
	local v5 = Sound:Play("Ope.Explosion.ElectricLoop", cFrame.p, 2 * v3)
	Sound:Play("Explosions.ShortExplosion2", cFrame.p, 2 * v3)

	for i = 1, 7 do
		local v7 = math.random(2)
		local color

		if v7 == 1 and v2 then
			color = v2
		else
			color = v7 == 2 and Color3.new(1, 1, 1)

			if not color then
				if v2 == 3 then
					color = Color3.new(0, 2, 0)
				else
					color = false
				end
			end
		end

		local v8 = cFrame * CFrame.Angles(0, 6.283185307179586 * (i / 7), 0) * CFrame.new(0, 0, -3.5) * CFrame.new(
			0,
			-5,
			0
		)
		Effect.new("Ope-Ope.SpikyFlare"):replicate({
			v8,
			color,
			Vector2.new(5.25, Random.new():NextNumber(v3, v3 * 2)),
			0.25,
			0.5,
			0.5
		})
	end

	LightningExplosion(cFrame.p, v2, v3 * 0.05)
	Effect.new("Ope-Ope.Slash"):replicate({
		cFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, 0, 0.8 * v3) * CFrame.Angles(-0.5235987755982988, 0, 0),
		v3,
		0.75 * v4,
		v2
	})
	Effect.new("Ope-Ope.Slash"):replicate({
		cFrame * CFrame.Angles(3.141592653589793, 0, 0) * CFrame.new(0, 0, 0.8 * v3) * CFrame.Angles(
			0.5235987755982988,
			0,
			0
		),
		v3,
		0.75 * v4,
		v2
	})
	Effect.new("Ope-Ope.Slash"):replicate({
		cFrame * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, 0.8 * v3) * CFrame.Angles(
			-0.5235987755982988,
			0,
			0
		),
		v3,
		0.75 * v4,
		v2
	})
	Effect.new("Ope-Ope.Slash"):replicate({
		cFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(0, 0, 0.8 * v3) * CFrame.Angles(
			-0.5235987755982988,
			0,
			0
		),
		v3,
		0.75 * v4,
		v2
	})
	local v6 = {}
	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame
	attachment.Parent = workspace.Terrain
	table.insert(v6, {
		object = attachment,
		CFrame = attachment.CFrame
	})

	for i = 1, 6 do
		local number = Random.new():NextNumber(4, 7)
		local number2 = Random.new():NextNumber(3, 6)
		local color = i % 3 == 0 and Color3.new(1, 1, 1)

		if not color then
			if i % 3 == 1 and v2 then
				color = v2
			elseif i % 3 == 2 then
				color = Color3.new()
			else
				color = false
			end
		end

		local clone = attachment:Clone()
		clone.CFrame = cFrame * CFrame.Angles(0, 6.283185307179586 * (i / 6), 0)
		clone.Parent = workspace.Terrain
		table.insert(v6, {
			object = clone,
			CFrame = clone.CFrame
		})
		Bolt(attachment, clone, number2, number2, number, 12, v4, color, true)
	end

	for i = 1, 6 do
		local thickness = Random.new():NextNumber(4, 7) * 0.5
		local number = Random.new():NextNumber(3, 6)
		local color = i % 3 == 0 and Color3.new(1, 1, 1)

		if not color then
			if i % 3 == 1 and v2 then
				color = v2
			elseif i % 3 == 2 then
				color = Color3.new()
			else
				color = false
			end
		end

		local clone = attachment:Clone()
		clone.CFrame = cFrame * CFrame.Angles(0, 6.283185307179586 * (i / 6), 0)
		clone.Parent = workspace.Terrain
		table.insert(v6, {
			object = clone,
			CFrame = clone.CFrame
		})
		Bolt(attachment, clone, number, number, thickness, 12, v4, color, true)
	end

	Sound:Play("Explosions.ShortExplosion3", cFrame.p, 2 * v3)
	local lastTime = tick()

	while tick() - lastTime < v4 do
		local circ = Tween.ease.out.circ(tick() - lastTime, 0, 1, v4)

		for k, v7 in next, v6, nil do
			if not (k > 1) then
				continue
			end

			if k > 7 then
				v7.object.CFrame = v7.CFrame * CFrame.Angles(-3.141592653589793 * circ, 0, 0) * CFrame.new(
					0,
					0,
					-v3 * 2
				) + Vector3.new(0, v3, 0)
			else
				v7.object.CFrame = v7.CFrame * CFrame.new(0, 0, -v3 / 2) + Vector3.new(0, 2 * v3, 0)
			end
		end

		RunService.RenderStepped:Wait()
	end

	Sound:FadeOut(v5, 3)
	wait(v4 * 2)

	for _, v7 in next, v6, nil do
		v7.object:Destroy()
	end
end