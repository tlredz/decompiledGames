-- equivalent calls inferred from this helper; original call sites unknown
local function CalculateBrightness(color)
	return (math.sqrt(color.R ^ 2 * 0.241 + color.G ^ 2 * 0.691 + color.B ^ 2 * 0.068))
end

local function CalculateColorByIntensity(data, quad)
	if quad > 1 then
		local v = Vector3.new(1 - data.r, 1 - data.g, 1 - data.b) * (quad - 1)
		return Color3.new(data.r + v.x, data.g + v.y, data.b + v.z)
	else
		return Color3.new(data.r * quad, data.g * quad, data.b * quad)
	end
end

local calculateBrightness = CalculateBrightness(BrickColor.new("Black").Color) -- equivalent call inferred; original call site unknown
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tween = require(ReplicatedStorage.Util.Tween)
local _WorldOrigin = workspace._WorldOrigin
local smoke = ReplicatedStorage.Assets.Models.Smoke
local v2 = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	local now = tick()
	local count = 0

	for k, v3 in pairs(v2) do
		local _ = count > 0
		local v4 = now - v3.Start

		if v3.Duration < v4 then
			for _, v5 in next, v3.Object.Model, nil do
				v5.Part:Destroy()
			end

			v2[k] = nil
			count += 1
		else
			local v5 = v4 / v3.Duration
			local quad = Tween.ease.out.quad(v5, 0, 1, 1)
			local v6 = math.sin(3.141592653589793 * quad)
			v3.__Tween = math.max(v3.__Tween or 0, v6)

			if v3.Object.Smoke then
				if not v3.Colors then
					v3.Colors = {
						Inner = v3.Object.InnerColor,
						Outer = v3.Object.OuterColor
					}
				end

				if v6 < v3.__Tween then
					if not v3.DecayTime then
						v3.DecayTime = now
					end

					local v7 = math.min(1, (now - v3.DecayTime) / (v3.Duration / 3))
					local v8 = math.min(1, v7 / 4 / 0.25)
					local v9 = math.sin(3.141592653589793 * v8) * 0.25
					local quad2 = Tween.ease.inout.quad(v7, v9 + 1, -1 - v9, 1)
					local calculateColorByIntensity = CalculateColorByIntensity(v3.Colors.Inner, quad2)
					local calculateColorByIntensity2 = CalculateColorByIntensity(v3.Colors.Outer, quad2)
					v3.Object:UpdateColors(calculateColorByIntensity, calculateColorByIntensity2)
				end
			end

			for k2, v7 in next, v3.Object.Model, nil do
				local v8 = (k2 == 1 and 1 or k2 == 4 and 1.35 or 1.25) * v3.Object.Scale

				if k2 == 1 then
					v7.Part.CFrame = v3.Object.CFrame * v7.Rotation * CFrame.Angles(
						1.5707963267948966 * v5,
						-1.5707963267948966 * v5,
						3.141592653589793 * v5
					)
				elseif k2 == 2 then
					v7.Part.CFrame = v3.Object.CFrame * v7.Rotation * CFrame.Angles(
						-1.5707963267948966 * v5,
						-1.5707963267948966 * v5,
						0
					)
				elseif k2 == 3 then
					v7.Part.CFrame = v3.Object.CFrame * v7.Rotation * CFrame.Angles(
						1.5707963267948966 * v5,
						1.5707963267948966 * v5,
						3.141592653589793 * v5
					)
				elseif k2 == 4 then
					v7.Part.CFrame = v3.Object.CFrame * v7.Rotation * CFrame.Angles(
						1.5707963267948966 * v5,
						-1.5707963267948966 * v5,
						0
					)
				end

				v7.Part.CFrame = v7.Part.CFrame * v3.Object.Rotation
				v7.Mesh.Scale = v7.Unit * v8 * v6
			end
		end
	end
end)
local Smoke = {}

function Smoke.new(options)
	local v3 = options or {}
	return setmetatable({
		Smoke = v3.Smoke,
		Scale = v3.Scale or 0,
		CFrame = v3.CFrame or CFrame.new(),
		Duration = v3.Duration and type(v3.Duration) == "table" and Random.new():NextNumber(
			v3.Duration[1],
			v3.Duration[2]
		) or v3.Duration or 1,
		InnerColor = v3.InnerColor or Color3.new(),
		OuterColor = v3.OuterColor or Color3.new(1, 1, 1),
		Rotation = v3.Rotation or CFrame.Angles(
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793
		)
	}, {
		__index = Smoke
	}):__init()
end

function Smoke:__updateColor(p, p2)
	self.InnerColor = p or Color3.new()
	self.OuterColor = p2 or Color3.new(1, 1, 1)
	local innerColor = self.InnerColor
	self.InnerColorIntensity = math.sqrt(innerColor.R ^ 2 * 0.241 + innerColor.G ^ 2 * 0.691 + innerColor.B ^ 2 * 0.068)
	self.InnerColorIntensity = not (calculateBrightness < self.InnerColorIntensity) and 1 or 1 + 2 * self.InnerColorIntensity or 1
	local outerColor = self.OuterColor
	self.OuterColorIntensity = math.sqrt(outerColor.R ^ 2 * 0.241 + outerColor.G ^ 2 * 0.691 + outerColor.B ^ 2 * 0.068)
	self.OuterColorIntensity = not (calculateBrightness < self.OuterColorIntensity) and 1 or 1 + 2 * self.OuterColorIntensity or 1
	local outerColor2 = self.OuterColor
	local v3 = Vector3.new(1 - outerColor2.r, 1 - outerColor2.g, 1 - outerColor2.b) * 0.125
	self.ColorOffset = Color3.new(outerColor2.r + v3.x, outerColor2.g + v3.y, outerColor2.b + v3.z)
	local colorOffset = self.ColorOffset
	self.ColorOffsetIntensity = math.sqrt(colorOffset.R ^ 2 * 0.241 + colorOffset.G ^ 2 * 0.691 + colorOffset.B ^ 2 * 0.068)
	self.ColorOffsetIntensity = not (calculateBrightness < self.ColorOffsetIntensity) and 1 or 1 + 2 * self.ColorOffsetIntensity or 1
	local outerColor3 = self.OuterColor
	local v4 = Vector3.new(1 - outerColor3.r, 1 - outerColor3.g, 1 - outerColor3.b) * 0.25
	self.ColorOffset2 = Color3.new(outerColor3.r + v4.x, outerColor3.g + v4.y, outerColor3.b + v4.z)
	local colorOffset2 = self.ColorOffset2
	self.ColorOffsetIntensity2 = math.sqrt(colorOffset2.R ^ 2 * 0.241 + colorOffset2.G ^ 2 * 0.691 + colorOffset2.B ^ 2 * 0.068)
	self.ColorOffsetIntensity2 = not (calculateBrightness < self.ColorOffsetIntensity2) and 1 or 1 + 2 * self.ColorOffsetIntensity2 or 1
end

function Smoke:UpdateColors(p, p2)
	if not self.Model then
		return
	end

	self:__updateColor(p, p2)
	local v3 = self.Model[1]
	local v4 = self.Model[2]
	local v5 = self.Model[3]
	local v6 = self.Model[4]
	local innerColor = self.InnerColor
	local colorOffset = self.ColorOffset
	local colorOffset2 = self.ColorOffset2
	v3.Mesh.VertexColor = Vector3.new(innerColor.r, innerColor.g, innerColor.b) * self.InnerColorIntensity
	v4.Mesh.VertexColor = Vector3.new(colorOffset.r, colorOffset.g, colorOffset.b) * self.ColorOffsetIntensity
	v5.Mesh.VertexColor = Vector3.new(colorOffset.r, colorOffset.g, colorOffset.b) * self.ColorOffsetIntensity2
	v6.Mesh.VertexColor = Vector3.new(colorOffset2.r, colorOffset2.g, colorOffset2.b) * self.ColorOffsetIntensity2
end

function Smoke:__init()
	if self.Model then
		return
	end

	self:__updateColor(self.InnerColor, self.OuterColor)
	self.Model = {}
	local cFrame = self.CFrame
	local innerColor = self.InnerColor
	local colorOffset = self.ColorOffset
	local colorOffset2 = self.ColorOffset2
	local scale = self.Scale
	local clone = smoke.Normal:Clone()
	clone.Mesh.Scale = smoke.Normal.Mesh.Scale * scale
	clone.Mesh.VertexColor = Vector3.new(innerColor.r, innerColor.g, innerColor.b) * self.InnerColorIntensity
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	table.insert(self.Model, {
		Part = clone,
		Mesh = clone.Mesh,
		Unit = smoke.Normal.Mesh.Scale,
		Origin = clone.CFrame,
		Rotation = clone.CFrame - clone.Position
	})
	local clone2 = smoke.Inverted:Clone()
	clone2.Mesh.Scale = smoke.Inverted.Mesh.Scale * scale * 1.25
	clone2.Mesh.VertexColor = Vector3.new(colorOffset.r, colorOffset.g, colorOffset.b) * self.ColorOffsetIntensity
	clone2.CFrame = cFrame * CFrame.Angles(0, 0, 0)
	clone2.Parent = _WorldOrigin
	table.insert(self.Model, {
		Part = clone2,
		Mesh = clone2.Mesh,
		Unit = smoke.Inverted.Mesh.Scale,
		Origin = clone2.CFrame,
		Rotation = clone2.CFrame - clone2.Position
	})
	local clone3 = clone2:Clone()
	clone3.Mesh.VertexColor = Vector3.new(colorOffset.r, colorOffset.g, colorOffset.b) * self.ColorOffsetIntensity2
	clone3.CFrame = cFrame
	clone3.Parent = _WorldOrigin
	table.insert(self.Model, {
		Part = clone3,
		Mesh = clone3.Mesh,
		Unit = smoke.Inverted.Mesh.Scale,
		Origin = clone3.CFrame,
		Rotation = clone3.CFrame - clone3.Position
	})
	local clone4 = smoke.Layer:Clone()
	clone4.Mesh.Scale = smoke.Layer.Mesh.Scale * scale * 1.35
	clone4.Mesh.VertexColor = Vector3.new(colorOffset2.r, colorOffset2.g, colorOffset2.b) * self.ColorOffsetIntensity2
	clone4.CFrame = cFrame
	clone4.Parent = _WorldOrigin
	table.insert(self.Model, {
		Part = clone4,
		Mesh = clone4.Mesh,
		Unit = smoke.Layer.Mesh.Scale,
		Origin = clone4.CFrame,
		Rotation = clone4.CFrame - clone4.Position
	})
	table.insert(v2, {
		Start = tick(),
		Duration = self.Duration,
		Object = self
	})
	return self
end

return Smoke