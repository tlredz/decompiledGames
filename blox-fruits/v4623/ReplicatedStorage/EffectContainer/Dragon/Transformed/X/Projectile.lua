local createVector = vector.create
local v = {}

local function ScaleParticle(clone, scale)
	if not v[clone] then
		v[clone] = { clone.Size.Keypoints, clone.Speed }
	end

	local numberSequenceKeypoints = {}

	for _, v2 in next, v[clone][1], nil do
		local v3 = v2.Value * scale
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(v2.Time, v3, v3 < v2.Envelope and v3 or v2.Envelope)
		)
	end

	clone.Speed = NumberRange.new(v[clone][2].Min * scale, v[clone][2].Max * scale)
	return NumberSequence.new(numberSequenceKeypoints)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CalculateBrightness(data)
	return (math.sqrt(data.R ^ 2 * 0.241 + data.G ^ 2 * 0.691 + data.B ^ 2 * 0.068))
end

local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local FX = require(game.ReplicatedStorage.FX)
local slash = FX:WaitForChild("Dragon").Assets.Slash
local _ = FX:WaitForChild("Dragon").Assets.Shockwave
local fireParticle = FX:WaitForChild("Dragon").FX.FireParticle
local Sound = require(game.ReplicatedStorage.Util.Sound)
local _WorldOrigin = workspace._WorldOrigin
local Projectile = {}

function Projectile.new(options)
	local v2 = options or {}
	return setmetatable({
		Scale = v2.Scale or 1,
		CFrame = v2.CFrame or CFrame.new(),
		Color = v2.Color or { Color3.new(1, 0, 0), Color3.new(1, 0.5, 0) },
		FadeIn = v2.FadeIn or 0.25,
		FadeOut = v2.FadeOut or 0.25,
		Delay = v2.Delay or 0,
		HitboxSize = v2.HitboxSize or createVector(0.5, 1.5, 1)
	}, {
		__index = Projectile
	}):__init()
end

function Projectile:__init()
	if self.Bin then
		return
	end

	self.Bin = {
		Start = tick()
	}
	self.Bin.Model = {}
	local calculateBrightness = CalculateBrightness(self.Color[1]) -- equivalent call inferred; original call site unknown
	local calculateBrightness2 = CalculateBrightness(self.Color[2]) -- equivalent call inferred; original call site unknown
	local brightness = calculateBrightness > 0.14 and 1 + 3 * calculateBrightness or 1
	local brightness2 = calculateBrightness2 > 0.14 and 1 + 3 * calculateBrightness2 or 1
	local clone = slash["1"]:Clone()
	clone.Transparency = 1
	clone.CFrame = self.CFrame
	clone.Size = self.HitboxSize * self.Scale
	local mesh = clone.Mesh
	local unit = clone.Mesh.Scale * createVector(0.5, 1, 1)
	mesh.VertexColor = Vector3.new(self.Color[1].r, self.Color[1].g, self.Color[1].b) * brightness
	mesh.Scale = unit * self.Scale * 2
	local clone2 = slash["2"]:Clone()
	clone2.Transparency = 1
	clone2.Size = createVector(0.3, 1.5, 1) * self.Scale * 2
	clone2.CFrame = self.CFrame
	local mesh2 = clone2.Mesh
	local scale = clone2.Mesh.Scale
	mesh2.VertexColor = Vector3.new(self.Color[2].r, self.Color[2].g, self.Color[2].b) * brightness2
	mesh2.Scale = scale * self.Scale * 2
	table.insert(self.Bin.Model, {
		Part = clone,
		Mesh = mesh,
		Unit = unit,
		Brightness = brightness
	})
	table.insert(self.Bin.Model, {
		Part = clone2,
		Mesh = mesh2,
		Unit = scale,
		Brightness = brightness2
	})

	for _, v9 in next, self.Bin.Model, nil do
		local clone3 = fireParticle:Clone()
		clone3.EmissionDirection = Enum.NormalId.Front
		clone3.Rate = 300
		clone3.Size = ScaleParticle(clone3, self.Scale)
		clone3.Parent = v9.Part
		clone3.Enabled = false
		v9.Particle = clone3
		v9.Part.Parent = _WorldOrigin
	end

	for _, v9 in next, self.Bin.Model, nil do
		v9.Part.Parent = _WorldOrigin
	end

	local integer = Random.new():NextInteger(1, 2)
	self.Bin.Sound = Sound:Play(("Dragon.Burn%d"):format(integer), self.Bin.Model[1].Part, self.Scale * 8)
	self.Bin.Sound2 = Sound:Play("Dragon.Rumble", self.Bin.Model[1].Part, self.Scale * 8)
	local tweenInfo = TweenInfo.new(self.FadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(clone, tweenInfo, {
		Transparency = 0
	})
	local tween2 = TweenService:Create(clone2, tweenInfo, {
		Transparency = 0
	})
	tween.Completed:Connect(function()
		if self.Destroying then
			return
		end

		for _, v9 in next, self.Bin.Model, nil do
			v9.Particle.Enabled = true
		end

		self.Loaded = true
	end)
	tween:Play()
	tween2:Play()
	return self
end

function Projectile:SetCFrame(cFrame)
	self.CFrame = cFrame

	for _, v2 in next, self.Bin.Model, nil do
		v2.Part.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0)
	end
end

function Projectile:Destroy()
	self.Destroying = true
	local tweenInfo = TweenInfo.new(self.FadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.Bin.Model[1].Part, tweenInfo, {
		Transparency = 1,
		CFrame = self.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, 10)
	})
	local tween2 = TweenService:Create(self.Bin.Model[2].Part, tweenInfo, {
		Transparency = 1,
		CFrame = self.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, 10)
	})
	tween.Completed:Connect(function()
		Sound:FadeOut(self.Bin.Sound, 0.5)
		Sound:FadeOut(self.Bin.Sound2, 0.5)
		wait(1)

		for _, v2 in next, self.Bin.Model, nil do
			v2.Part:Destroy()
		end
	end)
	tween:Play()
	tween2:Play()

	for _, v2 in next, self.Bin.Model, nil do
		v2.Particle.Enabled = false
	end

	Sound:Play("Dragon.Spit", self.CFrame.p, self.Scale * 4)
end

function Projectile.Shockwave(_) end

return Projectile