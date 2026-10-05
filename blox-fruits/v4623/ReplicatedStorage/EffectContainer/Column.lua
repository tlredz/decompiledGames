local createVector = vector.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace._WorldOrigin
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("Column", Enum.RenderPriority.Last.Value + 1010, function(p)
	for k, v2 in pairs(v) do
		local v3 = math.min(v2.Duration * 1.2, tick() - v2.Start) / v2.Duration

		if v2.RenderDistance:WithinRange(p) then
			local vector2 = Vector3.new(v2.Size.X, v2.Size.Y, v2.Size.X)

			if not v2.Flag1 then
				local v4 = math.min(v3, 1)

				if v4 == 1 then
					v2.Flag1 = true
				end

				local scale = vector2 * v2.Ease(v4, 0, 1, 1) * Vector3.new(
					1 - v4 ^ 1.75,
					(v4 * 0.6 + 0.4) ^ 0.75,
					1 - v4 ^ 1.75
				)

				for i = 1, 2 do
					local v6 = i == 2 and 0.3 or 0
					local v7 = v2.Column[i]
					v7.Mesh.Scale = scale
					v7.Part.Transparency = v6 + (v4 * (1 - v6)) ^ 1.5

					if i == 2 then
						v7.Part.CFrame = v2.CFrame + currentCamera.CFrame.lookVector * -0.1
					end
				end

				v2.Shockwave.Transparency = v4 ^ 1.5
				v2.Shockwave.Size = scale * createVector(2, 0.2, 2)
				v2.Shockwave.CFrame = v2.CFrame
			end

			local v4 = v3 / 1.2
			v2.WindShockwave.Transparency = 0.75 + v4 ^ 0.9 * 0.35
			v2.WindShockwave.Size = vector2 * Vector3.new(1 + v4 ^ 0.25 * 2.3, 0.09, 1 + v4 ^ 0.25 * 2.3) * v2.ShockwaveMultiplier
			v2.WindShockwave.CFrame = v2.CFrame * CFrame.new(
				0,
				(-0.4 + v4 ^ 0.2 * 1.1) * vector2.Y * 0.15 * v2.ShockwaveMultiplier,
				0
			) * CFrame.Angles(0, v4 * 1.75, 0)
		end

		if not (v3 >= 1.2) then
			continue
		end

		v2.Column[1].Part:Destroy()
		v2.Column[2].Part:Destroy()
		v2.Shockwave:Destroy()
		v2.WindShockwave:Destroy()
		v[k] = nil
	end
end)
local Column = {}
Column.__index = Column

function Column.new(instance)
	return (setmetatable({
		CFrame = instance.CFrame,
		Size = instance.Size or Vector2.new(10, 30),
		Color = instance.Color,
		InnerColor = instance.InnerColor or instance.Color,
		ShockwaveColor = instance.ShockwaveColor or Color3.new(1, 1, 1),
		Duration = instance.Duration or 0.5,
		Ease = instance.Ease or Util.Tween.ease.out.back,
		ShockwaveMultiplier = instance.ShockwaveMultiplier or 1
	}, {
		__index = Column
	}))
end

function Column:Run()
	local clone = game.ReplicatedStorage.Assets.Models.ShockwaveNeon:Clone()
	clone.Color = self.Color or self.InnerColor
	clone.Size = createVector(0.05, 0.05, 0.05)
	clone.Transparency = 1
	clone.CFrame = self.CFrame
	clone.Parent = _WorldOrigin
	local clone2 = game.ReplicatedStorage.Assets.Models.SmokeRing:Clone()
	clone2.Color = self.ShockwaveColor
	clone2.Size = createVector(0.05, 0.05, 0.05)
	clone2.Transparency = 1
	clone2.CFrame = self.CFrame
	clone2.Parent = _WorldOrigin
	local column = {}

	for i = 1, 2 do
		local part = Instance.new("Part")
		part.TopSurface = 0
		part.BottomSurface = 0
		part.Anchored = true
		part.CanCollide = false
		part.Material = "Neon"
		part.Color = i == 1 and self.Color or self.InnerColor
		part.Size = createVector(1, 1, 1) * (1 - (i - 1) * 0.4)
		part.CFrame = self.CFrame
		local specialMesh = Instance.new("SpecialMesh", part)
		specialMesh.Scale = Vector3.new()
		specialMesh.MeshType = "Sphere"
		part.Parent = _WorldOrigin
		column[i] = {
			Part = part,
			Mesh = specialMesh
		}
	end

	self.WindShockwave = clone2
	self.Shockwave = clone
	self.Column = column
	self.RenderDistance = Util.RenderDistance.new(self.CFrame, 150 + self.Size.Y * 5, 300 + self.Size.Y * 5)
	self.Start = tick()
	table.insert(v, self)
	return self
end

return Column