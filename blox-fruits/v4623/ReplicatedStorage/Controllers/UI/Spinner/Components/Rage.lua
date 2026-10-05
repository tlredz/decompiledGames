local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Rage = {}
Rage.__index = Rage

local function createParticle(data)
	if #data.Particles > 0 then
		return (table.remove(data.Particles, 1))
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	imageLabel.ZIndex = -100
	imageLabel.Image = data.Image
	imageLabel.Parent = data.Container
	return imageLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function recycleParticle(p, p2)
	table.insert(p.Particles, p2)
end

local function emit(data)
	local v = math.random() * 0.8 + 0.2
	local particle = createParticle(data)
	particle.ImageColor3 = data.Color
	particle.Size = UDim2.fromScale(data.ParticleScale, data.ParticleScale)
	particle.Position = UDim2.fromScale(math.random(), math.random())
	local v2 = math.rad(90 + math.random() * 5 - 2.5)
	local vector = Vector2.new(2 * v * math.cos(v2), data.ParticleYOffset * v * math.sin(v2))
	local uDim = UDim2.fromScale(particle.Position.X.Scale - vector.X, particle.Position.Y.Scale - vector.Y)
	TweenService:Create(particle, TweenInfo.new(v, Enum.EasingStyle.Linear), {
		Position = uDim,
		Size = UDim2.fromScale(0, 0)
	}):Play()
	task.delay(v, function()
		recycleParticle(data, particle) -- equivalent call inferred; original call site unknown
	end)
end

function Rage.new(container)
	local object = setmetatable({}, Rage)
	object.Container = container
	object.Particles = {}
	object.Connection = nil
	object.Accumulator = 0
	object.Color = Color3.new(1, 1, 1)
	object.Theme = "Kitsune"
	object.ParticleScale = 5
	object.ParticleYOffset = 20

	function object.ColorFunction()
		if object.Theme == "None" then
			return object.Color
		end

		local v = time() % 6.283185307179586

		if object.Theme == "Kitsune" then
			return Color3.new(0, math.sin(v * 1.5) * 0.45 + 0.5, 1)
		end

		if object.Theme == "Gravity" then
			return Color3.new(math.sin(v * 3) * 0.15 + 0.45, 0, 1)
		end

		if object.Theme == "Fishing" then
			return Color3.new(math.sin(v) * 0.1 + 0.75, math.sin(v) * 0.1 + 0.75, 1)
		end

		if object.Theme == "Pain" then
			return Color3.new(math.sin(v * 2) * 0.5 + 0.5, 0, 0)
		end

		if object.Theme == "TigerAwakened" then
			return Color3.new(1, math.sin(v * 3) * 0.15 + 0.45, math.sin(v * 3) * 0.55 + 0.45)
		end

		return Color3.new(1, math.sin(v * 3) * 0.15 + 0.45, 0)
	end

	object.Image = "rbxassetid://9608875194"
	object.Rate = UserInputService.TouchEnabled and 70 or 90

	for _ = 1, object.Rate do
		recycleParticle(object, createParticle(object)) -- equivalent call inferred; original call site unknown
	end

	return object
end

function Rage:SetRateWithMod(p2)
	self.Rate = (UserInputService.TouchEnabled and 70 or 90) * p2
end

function Rage:SetColor(color)
	self.Color = color
end

function Rage:SetColorFunction(colorFunction)
	self.ColorFunction = colorFunction
end

function Rage:Start()
	if self.Connection then
		return
	end

	self.Connection = RunService.RenderStepped:Connect(function(dt)
		if self.ColorFunction then
			self.Color = self.ColorFunction(time())
		end

		self.Accumulator += dt * self.Rate
		local accumulator = math.floor(self.Accumulator)

		if accumulator > 0 then
			for _ = 1, accumulator do
				emit(self)
			end

			self.Accumulator -= accumulator
		end
	end)
end

function Rage:Stop()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
end

function Rage:Destroy()
	self:Stop()

	for _, particle in self.Particles do
		particle:Destroy()
	end

	table.clear(self.Particles)
end

return Rage