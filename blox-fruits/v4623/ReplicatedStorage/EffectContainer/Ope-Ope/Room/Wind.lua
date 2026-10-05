local createVector = vector.create

local function xzAim(p, p2)
	return CFrame.new(p, p2 * createVector(1, 0, 1) + Vector3.new(0, p.Y))
end

local RunService = game:GetService("RunService")
local _WorldOrigin = workspace._WorldOrigin
local replicatedStorage = game.ReplicatedStorage
local opeOpe = replicatedStorage["Ope-Ope"]
require(replicatedStorage.Effect)
local Tween = require(replicatedStorage.Util.Tween)
local v = { createVector(0.0025, 0.015, 0.0025), createVector(0.025, 0.02, 0.02) }
local v2 = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(p)
	local now = tick()

	for k, v3 in next, v2, nil do
		local v4 = now - v3.Start
		v3.Angle = v3.Angle % 6.283185307179586 + 12.566370614359172 * p

		if v3.Hand.Parent and not v3.Destroy then
			if v3.Attachment.Parent then
				local quad = Tween.ease.out.quad(math.min(v4, v3.Fade), 1, -0.5, v3.Fade)
				local back = Tween.ease.out.back(math.min(v4, v3.Fade), 0, 1, v3.Fade)

				for k2, v5 in next, v3.Model, nil do
					v5.Transparency = quad
					v5.Mesh.Scale = v[k2] * back * v3.Scale
				end
			else
				if not v3.DestroyTime then
					v3.DestroyTime = now
				end

				if now - v3.DestroyTime > v3.Fade then
					v3.Destroy = true
				else
					local v5 = now - v3.DestroyTime
					local quad = Tween.ease.out.quad(v5, 0.5, 0.5, v3.Fade)
					local quad2 = Tween.ease.out.quad(v5, 1, -1, v3.Fade)

					for k2, v6 in next, v3.Model, nil do
						v6.Transparency = quad
						v6.Mesh.Scale = v[k2] * quad2 * v3.Scale
					end
				end
			end

			local position = v3.Hand.Position
			local v5 = v3.Hand.CFrame * createVector(0, 0, -1)
			local v6 = CFrame.new(position, v5 * createVector(1, 0, 1) + Vector3.new(0, position.Y)) * CFrame.new(
				0,
				v3.Hand.Size.Y / 2,
				0
			)

			for k2, v7 in next, v3.Model, nil do
				if k2 == 1 then
					v7.CFrame = v6 * CFrame.Angles(0, v3.Angle, 0)
				else
					v7.CFrame = v6 * CFrame.Angles(0, v3.Angle, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
				end
			end
		else
			for _, v5 in next, v3.Model, nil do
				v5:Destroy()
			end

			table.remove(v2, k)
		end
	end
end)
return function(list)
	local hand, scale, attachment = unpack(list)
	local clones = {}
	local clone = opeOpe.Effects.WindFlare:Clone()
	clone.Mesh.Scale = Vector3.new()
	clone.CFrame = hand.CFrame
	clone.Parent = _WorldOrigin
	local clone2 = opeOpe.Effects.WindFlare2:Clone()
	clone2.Mesh.Scale = Vector3.new()
	clone2.CFrame = hand.CFrame
	clone2.Parent = _WorldOrigin
	table.insert(clones, clone)
	table.insert(clones, clone2)
	table.insert(v2, {
		Angle = 0,
		Fade = 0.2,
		Model = clones,
		Hand = hand,
		Scale = scale,
		Attachment = attachment,
		Start = tick()
	})
end