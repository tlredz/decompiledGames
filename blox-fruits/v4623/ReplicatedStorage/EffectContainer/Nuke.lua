local createVector = vector.create
local FXCreator = require(game.ReplicatedStorage.FXCreator)
local v = FXCreator.Build()
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
require(game.ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace._WorldOrigin
local Nuke = {}
Nuke.__index = Nuke

function Nuke.new(instance)
	local v2 = {
		CFrame = instance.CFrame,
		Duration = instance.Duration or 1.75,
		POW = instance.POW or 2,
		Size = instance.Size or 25,
		InnerColor = instance.InnerColor or Color3.fromRGB(128, 187, 219),
		OuterColor = instance.OuterColor or ColorSequence.new(Color3.new(0, 1, 1), Color3.new(0, 1, 1))
	}
	setmetatable(v2, {
		__index = Nuke
	})
	return v2
end

function Nuke.Run(instance)
	local cFrame = instance.CFrame
	local duration = instance.Duration
	local POW = instance.POW
	local size = instance.Size
	local v2 = 300 + size * 2
	local distance = v.Distance(cFrame.p)

	if v2 * 3 < distance then
		return
	end

	local v3 = 10 + size * 1.666
	local v4 = v.Distance(cFrame.p) / v3

	if v4 < 1 then
		local v5 = 1 - v4 ^ 3
		local _ = math.clamp(v3, 0, 90) * v5 > 20
	end

	local segments = math.clamp(size / 3, 12, 20)
	local part = Instance.new("Part")
	part.CFrame = cFrame
	part.Size = createVector(0.99, 0.99, 0.99)
	part.Anchored = true
	part.CanCollide = false
	part.Color = instance.InnerColor
	part.Material = "Neon"
	part.Transparency = 0.33
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(1, 1, 1) * size
	local clones = {}

	for _ = 1, 2 do
		local clone = game.ReplicatedStorage.Assets.Models.CurvedRing:Clone()
		clone.CFrame = cFrame
		clone.Size = part.Size * size
		clone.Transparency = 0
		clone.Parent = part
		table.insert(clones, clone)
	end

	local v6 = {}

	for i = 1, segments do
		local offset = CFrame.Angles(0, i * 2 * 3.141592653589793 / segments, 0) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local attachment = Instance.new("Attachment")
		attachment.CFrame = CFrame.new(0, size / 2, 0) * offset
		local clone = attachment:Clone()
		clone.CFrame = CFrame.new(0, -size / 2, 0) * offset
		local beam = Instance.new("Beam")
		beam.Texture = "http://www.roblox.com/asset/?id=3693756254"
		beam.TextureLength = 4
		beam.TextureSpeed = -4
		beam.LightEmission = 0.25
		beam.Transparency = NumberSequence.new(0)
		beam.Color = instance.OuterColor
		beam.CurveSize0 = 0.6666666666666666 * size
		beam.CurveSize1 = -beam.CurveSize0
		beam.Width0 = 3.141592653589793 * size / segments + 0.3333333333333333
		beam.Width1 = beam.Width0
		beam.Segments = segments
		beam.Attachment0 = attachment
		beam.Attachment1 = clone
		attachment.Parent = part
		clone.Parent = part
		beam.Parent = part
		table.insert(v6, {
			b = beam,
			a0 = attachment,
			a1 = clone,
			offset = offset
		})
	end

	part.Parent = _WorldOrigin
	local animator = v.Animator(part, 200 + size * 2)
	tick()
	local total = 0
	animator.Custom({
		Function = function(p, p2)
			local v7 = p ^ POW
			local v8 = p2 / duration
			local v9

			if v8 > 0.75 then
				v9 = 1 - (v8 - 0.75) / 0.25
			elseif total < v8 then
				total += 0.04
				v9 = v7

				for _ = 1, math.random(2, 3) do
					local v10 = cFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					Effect.new("FastLightning2"):replicate({
						Position0 = v10 * Vector3.new(0, 0, size * v7 * 0.4),
						Position1 = v10 * Vector3.new(0, 0, size * v7 * 3),
						Length = 40,
						Offset = 40,
						Width = 10
					})
				end
			else
				v9 = v7
			end

			specialMesh.Scale = Vector3.new(size, size, size) * v7
			part.Transparency = math.max(0.33, (1 - v9) * 1.5)

			for i = 1, #v6 do
				local v10 = v6[i]
				local b = v10.b
				local a0 = v10.a0
				local a1 = v10.a1
				local offset = v10.offset
				b.Transparency = NumberSequence.new(1 - v9)
				b.TextureSpeed = -5 * (2 - v8 * 1.5)
				b.CurveSize0 = 0.6666666666666666 * v7 * size
				b.CurveSize1 = -b.CurveSize0
				b.Width0 = 1.7 * v7 * 3.141592653589793 * size / segments + 0.6666666666666666
				b.Width1 = b.Width0
				a0.CFrame = CFrame.new(0, v7 * size / 2, 0) * offset
				a1.CFrame = CFrame.new(0, -v7 * size / 2, 0) * offset
			end

			for i = 1, #clones do
				local v10 = clones[i]
				local v11 = (i - 1) * 0.25 + 0.875
				v10.Size = createVector(1, 0.1, 1) * size * math.sin(v7 * v11 * 3.141592653589793) * 1.5
				v10.CFrame = cFrame * CFrame.new(0, -size / 3 + v7 * v11 * size, 0)
				v10.Transparency = v8 * (v11 + 0.3) * 1.25
			end
		end,
		Time = duration,
		Tween = v.Tween.ease.out.expo,
		Completed = function()
			part:Destroy()
		end
	})
	return instance
end

return Nuke