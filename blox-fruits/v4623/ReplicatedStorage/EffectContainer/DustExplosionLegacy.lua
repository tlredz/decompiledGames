local createVector = vector.create
local FXCreator = require(game.ReplicatedStorage.FXCreator)
local v = FXCreator.Build()
local _WorldOrigin = workspace._WorldOrigin
local DustExplosionLegacy = {}
DustExplosionLegacy.__index = DustExplosionLegacy

function DustExplosionLegacy:new()
	if typeof(self.Size) == "number" then
		self.Size = { self.Size, self.Size }
	end

	local v2 = {
		CFrame = self.CFrame,
		Size = self.Size or { 20, 50 },
		ColorSequence = self.ColorSequence or ColorSequence.new(Color3.new(1, 1, 0), Color3.new(1, 0.5, 0)),
		Duration = self.Duration or 2
	}
	setmetatable(v2, {
		__index = DustExplosionLegacy
	})
	return v2
end

function DustExplosionLegacy.Run(instance)
	local duration = instance.Duration
	local colorSequence = instance.ColorSequence
	local v2 = instance.Size[1]
	local v3 = instance.Size[2]
	local cFrame = instance.CFrame
	local v4 = 500 + v2 * 2 + v3 * 2
	local distance = v.Distance(cFrame.p)

	if v4 * 2 < distance then
		return
	end

	local color = colorSequence.Keypoints[1].Value
	local value2 = colorSequence.Keypoints[2].Value
	local clone = game.ReplicatedStorage.Assets.Models.Explosion:Clone()
	clone:SetPrimaryPartCFrame(cFrame)
	local ring = clone.Ring
	local imageLabel = ring.Top.ImageLabel
	local imageLabel2 = ring.Bottom.ImageLabel
	local part1 = clone.Part1
	local part2 = clone.Part2
	local color1 = clone.Color1
	local color2 = clone.Color2
	color1.Color = color
	color2.Color = color
	local v5 = Vector3.new(math.random(), math.random(), math.random()) * 3.141592653589793 * 2
	color1.CFrame *= CFrame.Angles(v5.x, v5.y, v5.z)
	color2.CFrame = color1.CFrame * CFrame.Angles(
		v5.x + 0.7853981633974483,
		v5.y + 1.5707963267948966,
		v5.z + 2.181661564992912
	)
	part1.CFrame *= CFrame.Angles(
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2
	)
	part2.CFrame *= CFrame.Angles(
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2
	)
	ring.CFrame = color1.CFrame
	clone.Parent = _WorldOrigin
	local part = Instance.new("Part")
	part.CFrame = cFrame
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	part.Material = "Neon"
	part.Transparency = 0.25
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(1, 1, 1) * v2
	part.Parent = _WorldOrigin
	local clone2 = game.ReplicatedStorage.Assets.Models.FireExplosion.Fire:Clone()
	clone2.Color = colorSequence
	clone2.Drag = 0
	clone2.Speed = NumberRange.new(v3 / duration * 1.2, v3 / duration * 1.6)
	clone2.Lifetime = NumberRange.new(duration * 0.8, duration)
	clone2.Parent = part
	clone2:Emit(math.ceil(v3 * 0.5) + 3)
	local v6 = CFrame.new(0, 0, 0.02) * CFrame.Angles(0.004, 0.004, 0.004)
	local v7 = CFrame.new(0, 0, 0.02) * CFrame.Angles(-0.004, -0.004, -0.004)
	v.Animator(cFrame.p, v4, nil, 0.15).Custom({
		Function = function(p, p2)
			local v8 = p2 / duration
			local v9 = v2 + (v3 - v2) * p
			local v10 = (v9 - v2) * 0.06
			specialMesh.Scale = createVector(1, 1, 1) * v9 * 1.666
			part.Transparency = 0.25 + v8 * 1.5
			part.Color = color:Lerp(value2, p)
			imageLabel.Size = UDim2.new(1 + v10, 0, 1 + v10, 0)
			imageLabel.Position = UDim2.new(-v10 / 2, 0, -v10 / 2, 0)
			imageLabel.Rotation = v8 * 720
			imageLabel.ImageTransparency = v8 * 2.5
			imageLabel2.Size = imageLabel.Size
			imageLabel2.Position = imageLabel.Position
			imageLabel2.Rotation = imageLabel.Rotation
			imageLabel2.ImageTransparency = imageLabel.ImageTransparency
			color1.Color = color:Lerp(value2, p)
			color2.Color = color1.Color

			if v8 > 0.5 then
				color1.Transparency = (v8 - 0.5) / 0.5 * 1.75
				color2.Transparency = color1.Transparency

				if v8 > 0.8 then
					part1.Transparency = (v8 - 0.8) / 0.2
					part2.Transparency = part1.Transparency
				end
			end

			part1.CFrame *= v6
			part2.CFrame *= v7
			local _ = v8 * (2 - v8)
			local v11 = math.sin(v8 * 3.141592653589793)
			color1.Mesh.Scale = Vector3.new(v9 * 0.75, v9 * 0.75, v9 * 6 * v11)
			color2.Mesh.Scale = Vector3.new(v9 * 0.75, v9 * 0.75, v9 * 5 * v11)
			part1.Mesh.Scale = createVector(1, 1, 1) * v9
			part2.Mesh.Scale = part1.Mesh.Scale
		end,
		Time = duration,
		Tween = v.Tween.ease.out.expo,
		Completed = function()
			clone:Destroy()
			part:Destroy()
		end
	})
	return instance
end

return DustExplosionLegacy