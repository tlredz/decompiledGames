local createVector = vector.create
local v = {}

local function ScaleParticle(state, p)
	if not v[state] then
		v[state] = { state.Size.Keypoints, state.Speed }
	end

	local numberSequenceKeypoints = {}

	for _, v2 in next, v[state][1], nil do
		local v3 = v2.Value * p
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(v2.Time, v3, (math.abs(v3 < v2.Envelope and v3 or v2.Envelope)))
		)
	end

	state.Speed = NumberRange.new(v[state][2].Min * p, v[state][2].Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StackAngleCFrame(angleInfluence, p)
	return CFrame.Angles((angleInfluence[1] or 0) * p, (angleInfluence[2] or 0) * p, (angleInfluence[3] or 0) * p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CalculateBrightness(data)
	return (math.sqrt(data.R ^ 2 * 0.241 + data.G ^ 2 * 0.691 + data.B ^ 2 * 0.068))
end

local function CalculateColorByIntensity(data, p)
	if p > 1 then
		local v2 = Vector3.new(1 - data.r, 1 - data.g, 1 - data.b) * (p - 1)
		return Color3.new(data.r + v2.x, data.g + v2.y, data.b + v2.z)
	else
		return Color3.new(data.r * p, data.g * p, data.b * p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleCF(offset, p)
	local p2 = offset.p
	local v2 = offset - p2
	return CFrame.new(p2 * p) * v2
end

local calculateBrightness = CalculateBrightness(BrickColor.new("Black").Color) -- equivalent call inferred; original call site unknown
local RunService = game:GetService("RunService")
local FX = require(game.ReplicatedStorage.FX)
local explosion = FX:WaitForChild("Dragon").Assets.Explosion
local FX2 = require(game.ReplicatedStorage.FX)
local ball = FX2:WaitForChild("Dragon").FX.Ball
local FX3 = require(game.ReplicatedStorage.FX)
local pixie = FX3:WaitForChild("Dragon").FX.Pixie
local FX4 = require(game.ReplicatedStorage.FX)
local blobs_Exhale = FX4:WaitForChild("Dragon").FX.Blobs_Exhale
local FX5 = require(game.ReplicatedStorage.FX)
local glow = FX5:WaitForChild("Dragon").FX.Glow
local _ = workspace._WorldOrigin
local Tween = require(game.ReplicatedStorage.Util.Tween)
require(game.ReplicatedStorage.Effect)
local v3 = {
	Core = {
		{},
		{ 0, -6.283185307179586 },
		{ 0, -6.283185307179586 },
		{ 0, -6.283185307179586 }
	},
	Slash = {
		{ 0, 6.283185307179586, 0 },
		{ 6.283185307179586, 0, 0 },
		{ 0, 0, 6.283185307179586 },
		{ 6.283185307179586, 0, 0 },
		{ 0, -6.283185307179586, 0 },
		{ 0, 0, 6.283185307179586 }
	}
}
local v4 = {}
local v5 = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	local now = tick()
	local count = 0

	for k, v6 in pairs(v4) do
		local _ = count > 0

		if not v6.Start2 then
			v6.Start2 = v6.Start
		end

		local v7 = now - v6.Start
		local v8 = now - v6.Start2

		if v6.Object.Lifetime + v6.Object.FadeIn + v6.Object.FadeOut < v7 then
			if v6.Object.Callback then
				v6.Object.Callback()
			end

			local v9 = v6
			delay(1, function()
				v9.Object.Bin.Center:Destroy()
			end)
			v4[k] = nil
			count += 1
		else
			local v9 = 1
			local v10 = 0
			local transparency = 0
			local v12 = v8 / (1 / v6.PulseSpeed) % 1
			local v13

			if v6.Object.FadeIn + v6.Object.Lifetime < v7 then
				if v6.Object.OnDestroy and not v6.Object.Bin.OnDestroy then
					v6.Object.OnDestroy()
					v6.Object.Bin.OnDestroy = true
				end

				if v7 - (v6.Object.FadeIn + v6.Object.Lifetime) > v6.Object.FadeOut * 0.25 then
					for _, particle in next, v6.Object.Bin.Particles, nil do
						particle.Enabled = false
					end
				end

				local v14 = (v7 - v6.Object.FadeIn - v6.Object.Lifetime) / v6.Object.FadeOut
				v13 = Tween.ease["in"].quad(v14, 1, -1, 1)
				transparency = Tween.ease.out.quad(v14, 0, 1, 1)
				v10 = math.sin(3.141592653589793 * v13)

				if transparency > 0.98 and v6.Object.Bin.Finished then
					v6.Object.Bin.Finished.Enabled = false
				elseif transparency > 0.76 and not v6.Object.Bin.Finished then
					local clone = blobs_Exhale:Clone()
					clone.Rate += (v6.Object.Scale * 0.1) ^ 0.6
					clone.Color = ColorSequence.new(v6.Object.Bin.Colors[1][1])
					clone.Size = ScaleParticle(clone, v6.Object.Scale * 2)
					clone.Lifetime = NumberRange.new(v6.Object.FadeOut * 0.35, v6.Object.FadeOut * 0.5)
					clone.Parent = v6.Object.Bin.Center
					clone.Enabled = true
					v6.Object.Bin.Finished = clone
				end

				v9 = v13
			elseif v6.Object.FadeIn < v7 then
				if v6.Object.CheckDestroy and not (v6.Object.CheckDestroy.Parent or v6.Object.Bin.AdjustTime) then
					v6.Start -= v6.Object.FadeIn + v6.Object.Lifetime - v7
					v7 = now - v6.Start
					v6.Object.Bin.AdjustTime = true
				end

				v13 = 1
			else
				local v14 = v7 / v6.Object.FadeIn
				v9 = Tween.ease.out.quad(v14, 0, 1, 1)
				v13 = Tween.ease.outin.quad(v14, 0, 1, 1)
				v10 = math.sin(3.141592653589793 * v13) ^ 0.75
			end

			local unit = (v6.Object.Bin.CFrame.LookVector - createVector(0, 0.5, 0)).Unit
			v6.Object.CFrame = v6.Object.Bin.CFrame + unit * v6.Object.Scale * v13
			v6.Object.Bin.Center.CFrame = v6.Object.CFrame

			for k2, particle in next, v6.Object.Bin.Particles, nil do
				local v14 = (k2 == 1 or k == 2) and 0.25 or k2 == 4 and 3 or 1
				particle.Size = ScaleParticle(
					particle,
					v9 * 1.25 * v6.Object.Scale + v9 * v14 * 1.5 * v6.Object.Scale * math.sin(3.141592653589793 * v12) ^ 1
				)
			end

			for k2, core in next, v6.Object.Bin.Cores, nil do
				local stackAngleCFrame = StackAngleCFrame(core.AngleInfluence, v12) -- equivalent call inferred; original call site unknown
				core.Part.CFrame = v6.Object.CFrame * stackAngleCFrame

				if k2 > 2 then
					core.Mesh.Scale = v10 * v6.Object.Scale * core.Unit * 2 + v10 * 1 * v6.Object.Scale * core.Unit * math.sin(3.141592653589793 * v12) ^ 1
				else
					core.Mesh.Scale = v9 * v6.Object.Scale * core.Unit + v9 * 1 * v6.Object.Scale * core.Unit * math.sin(3.141592653589793 * (1 - v12))
				end

				core.Part.Transparency = transparency
			end

			for _, slash in next, v6.Object.Bin.Slashes, nil do
				local stackAngleCFrame = StackAngleCFrame(slash.AngleInfluence, v12) -- equivalent call inferred; original call site unknown
				local part = slash.Part
				part.CFrame = v6.Object.CFrame * stackAngleCFrame * scaleCF(
					slash.Offset,
					v9 * v6.Object.Scale + v9 * v6.Object.Scale * math.sin(3.141592653589793 * v12) ^ 1
				)
				slash.Mesh.Scale = slash.Unit * v6.Object.Scale * v9
				slash.Part.Transparency = transparency
			end

			v6.TrailEmission = v6.TrailEmission or 0

			if now - v6.TrailEmission > 0.07 and v7 < v6.Object.FadeIn + v6.Object.Lifetime then
				v6.Object:CreatePixie(v6.Object.FadeIn * Random.new():NextNumber(0.8, 1.12))
				v6.TrailEmission = now
			end
		end
	end

	local count2 = 0

	for k, v6 in next, v5, nil do
		if count2 > 0 then
			v6 = v5[k - count2]
		end

		local v7 = now - v6.Start
		local v8 = v7 / v6.Duration

		if v6.Duration < v7 then
			v6.Attachments[1]:Destroy()
			v6.Attachments[2]:Destroy()
			table.remove(v5, k - count2)
			count2 += 1
		else
			for k2, attachment in next, v6.Attachments, nil do
				local v9 = k2 % 2 == 0 and 1 or -1
				attachment.CFrame = v6.CFrame * v6.Offset * CFrame.Angles(
					0,
					v6.DirectionInfluence * 2 * 3.141592653589793 * v8,
					0
				) * CFrame.new(
					0,
					-v6.Radius + 2 * v6.Radius * math.sin(3.141592653589793 * v8),
					-v6.DirectionInfluence * 2 * v6.Radius * math.sin(3.141592653589793 * v8)
				) * CFrame.new(v9 * v6.Width, 0, 0)
			end
		end
	end
end)
local Orb = {}

function Orb.new(data)
	return setmetatable({
		Scale = data.Scale or 1,
		Color = data.Color or { Color3.new(), Color3.new(1, 1, 1) },
		CFrame = data.CFrame or CFrame.new(),
		FadeIn = data.FadeIn or 0.5,
		Lifetime = data.Lifetime or 1,
		FadeOut = data.FadeOut or 0.5,
		Callback = data.Callback,
		CheckDestroy = data.CheckDestroy,
		OnDestroy = data.OnDestroy
	}, {
		__index = Orb
	}):__init()
end

function Orb:__updateColor(p, p2)
	if not self.Bin then
		return
	end

	self.Color = { p or self.Color[1], p2 or self.Color[2] }
	local v6 = self.Color[1]
	local calculateBrightness2 = CalculateBrightness(v6) -- equivalent call inferred; original call site unknown
	local v8 = not (calculateBrightness < calculateBrightness2) and 1 or 1 + 2 * calculateBrightness2 or 1
	local color2 = Color3.new(v6.r * 0.8, v6.g * 0.8, v6.b * 0.8)
	local calculateBrightness3 = CalculateBrightness(color2) -- equivalent call inferred; original call site unknown
	local v10 = self.Color[2]
	local calculateBrightness4 = CalculateBrightness(v10) -- equivalent call inferred; original call site unknown
	local v12 = calculateBrightness < calculateBrightness4 and 1 + 2 * calculateBrightness4 or 1
	local calculateColorByIntensity = CalculateColorByIntensity(v6, 0.15 + 2 * calculateBrightness2)
	local calculateBrightness5 = CalculateBrightness(calculateColorByIntensity) -- equivalent call inferred; original call site unknown
	local v15 = calculateBrightness < calculateBrightness5 and 1 + 2 * calculateBrightness5 or 1
	local v16 = Vector3.new(1 - v6.r, 1 - v6.g, 1 - v6.b) * 0.125
	local color3 = Color3.new(v6.r + v16.x, v6.g + v16.y, v6.b + v16.z)
	local calculateBrightness6 = CalculateBrightness(color3) -- equivalent call inferred; original call site unknown
	local v18 = calculateBrightness < calculateBrightness6 and 1 + 2 * calculateBrightness6 or 1
	self.Bin.Colors = {
		{ v6, v8 },
		{ color2, calculateBrightness3 },
		{ v10, v12 },
		{ calculateColorByIntensity, v15 },
		{ color3, v18 }
	}
end

function Orb:__init()
	if self.Bin then
		return self
	end

	self.Bin = {}
	self.Bin.CFrame = self.CFrame
	self.Bin.Center = Instance.new("Attachment")
	self.Bin.Center.CFrame = self.CFrame
	self.Bin.Center.Parent = workspace.Terrain
	self.Bin.Particles = {}
	self.Bin.Cores = {}
	self.Bin.Slashes = {}
	self:__updateColor()

	for k, v6 in next, {
		ball.KiImpact,
		ball.KiSpikes,
		ball.Bits,
		glow
	}, nil do
		local clone = v6:Clone()
		local v7 = 1

		if k == 1 then
			clone.Color = ColorSequence.new(self.Bin.Colors[1][1])
			clone.LightEmission = self.Bin.Colors[1][2] / 3
			v7 = 0.25
		elseif k == 2 then
			clone.Color = ColorSequence.new(self.Bin.Colors[3][1])
			clone.LightEmission = self.Bin.Colors[3][2] / 3
			v7 = 0.25
		elseif k == 4 then
			clone.Color = ColorSequence.new(self.Bin.Colors[1][1])
			clone.LightEmission = self.Bin.Colors[1][2] / 4
			v7 = 3
		else
			clone.Color = ColorSequence.new(self.Bin.Colors[3][1], self.Bin.Colors[1][1])
		end

		clone.Rate += math.clamp(self.Scale ^ 0.75, 0, 360)
		clone.Size = ScaleParticle(clone, v7 * 2 * self.Scale)
		clone.Parent = self.Bin.Center
		table.insert(self.Bin.Particles, clone)
	end

	for i = 1, #explosion.Slashes:GetChildren() do
		local color2 = self.Bin.Colors[i % #self.Bin.Colors + 1]
		local v6 = color2[1]
		local v7 = color2[2]
		local clone = explosion.Slashes[i]:Clone():Clone()
		local scale = clone.Mesh.Scale
		clone.Transparency = 0.25
		clone.Mesh.Scale = scale * self.Scale
		clone.Mesh.VertexColor = Vector3.new(v6.r, v6.g, v6.b) * v7
		clone.CFrame = self.CFrame
		clone.Parent = self.Bin.Center
		table.insert(self.Bin.Slashes, {
			Part = clone,
			Mesh = clone.Mesh,
			Unit = scale,
			Offset = clone.Offset.Value,
			AngleInfluence = v3.Slash[i] or v3.Slash[#v3.Slash]
		})
	end

	for i = 1, #explosion.Core:GetChildren() do
		local clone = explosion.Core[i]:Clone()
		local scale = clone.Mesh.Scale
		local v6 = self.Bin.Colors[4][1]
		local v7 = self.Bin.Colors[4][2]

		if i > 1 then
			if i == 2 then
				v6 = self.Bin.Colors[2][1]
				v7 = self.Bin.Colors[2][2]
			elseif i == 4 then
				v6 = self.Bin.Colors[5][1]
				v7 = self.Bin.Colors[5][2]
			elseif i % 2 == 0 then
				v6 = self.Bin.Colors[1][1]
				v7 = self.Bin.Colors[1][2]
			else
				v6 = self.Bin.Colors[3][1]
				v7 = self.Bin.Colors[3][2]
			end
		end

		clone.Mesh.VertexColor = Vector3.new(v6.r, v6.g, v6.b) * v7
		clone.Mesh.Scale = scale * 1 * (i > 2 and 2 or 1)
		clone.CFrame = self.CFrame
		clone.Parent = self.Bin.Center
		table.insert(self.Bin.Cores, {
			Part = clone,
			Mesh = clone.Mesh,
			Unit = scale,
			AngleInfluence = v3.Core[i] or v3.Core[#v3.Core]
		})
	end

	table.insert(v4, {
		Object = self,
		PulseSpeed = 0.75,
		Start = tick()
	})
	return self
end

function Orb:CreatePixie(value)
	self.Bin.Count = (self.Bin.Count or 0) + 1
	local clone = pixie:Clone()
	local attachments = {}
	local attachment = Instance.new("Attachment")
	attachment.CFrame = self.CFrame
	attachment.Parent = workspace.Terrain
	table.insert(attachments, attachment)
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = self.CFrame
	attachment2.Parent = workspace.Terrain
	table.insert(attachments, attachment2)
	local v7 = self.Bin.Count % 2 == 0 and self.Bin.Colors[1][1] or self.Bin.Colors[3][1]
	clone.Color = ColorSequence.new(v7)
	clone.LightEmission = 1.5 * math.sqrt(v7.R ^ 2 * 0.241 + v7.G ^ 2 * 0.691 + v7.B ^ 2 * 0.068)
	local attachment3 = attachments[1]
	local attachment4 = attachments[2]
	clone.Attachment0 = attachment3
	clone.Attachment1 = attachment4
	clone.Parent = attachments[1]
	table.insert(v5, {
		Start = tick(),
		CFrame = self.CFrame,
		Offset = CFrame.Angles(
			3.141592653589793 * Random.new():NextNumber(-1, 1),
			3.141592653589793 * Random.new():NextNumber(-1, 1),
			3.141592653589793 * Random.new():NextNumber(-1, 1)
		),
		Width = (self.Scale * 0.1) ^ 0.5,
		Attachments = attachments,
		Trail = clone,
		Duration = value or 1,
		Radius = 1.25 * self.Scale * Random.new():NextNumber(0.75, 1.25),
		DirectionInfluence = self.Bin.Count % 2 == 0 and 1 or -1,
		Angle = v3.Slash[self.Bin.Count % #v3.Slash + 1]
	})
end

return Orb