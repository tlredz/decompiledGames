local Workspace = game:GetService("Workspace")
local currentCamera = Workspace.CurrentCamera
local v = { script:WaitForChild("CircularConfetti"), script:WaitForChild("SquareConfetti") }
local v2 = {}
do local _values = table.pack(Color3.fromRGB(168, 100, 253), Color3.fromRGB(41, 205, 255), Color3.fromRGB(120, 255, 68), Color3.fromRGB(255, 113, 141), Color3.fromRGB(253, 255, 106)); for _k = 1, _values.n do v2[_k] = _values[_k] end end
local Confetti = {}
Confetti.__index = Confetti
local vector = Vector2.new(0, 1)

function Confetti.setGravity(p)
	vector = p
end

function Confetti.createParticle(emitterPosition, p, parent, list)
	local v3 = {}
	setmetatable(v3, Confetti)
	v2 = list
	local X = p.X

	if X < 0 then
		X *= -1
	end

	local v4 = 0 - X
	local vector2 = Vector2.new(p.X, p.Y + v4 * 0.75)

	if list == nil then
		list = v2
	end

	v3.EmitterPosition = emitterPosition
	v3.EmitterPower = vector2
	v3.Position = Vector2.new(0, 0)
	v3.Power = vector2
	v3.Color = list[math.random(#list)]

	local function getParticle()
		local clone = v[math.random(#v)]:Clone()
		clone.ImageColor3 = v3.Color
		clone.Parent = parent
		clone.Rotation = math.random(360)
		clone.Visible = true
		clone.ZIndex = 20
		return clone
	end

	local clone = v[math.random(#v)]:Clone()
	clone.ImageColor3 = v3.Color
	clone.Parent = parent
	clone.Rotation = math.random(360)
	clone.Visible = true
	clone.ZIndex = 20
	v3.Label = clone
	v3.DefaultSize = 30
	v3.Size = 1
	v3.Side = -1
	v3.OutOfBounds = false
	v3.Enabled = false
	v3.Cycles = 0
	return v3
end

function Confetti:Update(_)
	if self.Enabled and self.OutOfBounds then
		self.Label.ImageColor3 = self.Color
		self.Position = Vector2.new(0, 0)
		self.Power = Vector2.new(self.EmitterPower.X + math.random(10) - 5, self.EmitterPower.Y + math.random(10) - 5)
		self.Cycles += 1
	end

	if (self.Enabled or not self.OutOfBounds) and (self.Enabled or self.Cycles ~= 0) then
		self.Label.Visible = true
		local emitterPosition = self.EmitterPosition
		local position = self.Position
		local power = self.Power
		local label = self.Label

		if label then
			local vector2 = Vector2.new(position.X - power.X, position.Y - power.Y)
			local vector3 = Vector2.new(power.X / 1.09 - vector.X, power.Y / 1.1 - vector.Y)
			local viewportSize = currentCamera.ViewportSize
			label.Position = UDim2.new(emitterPosition.X, vector2.X, emitterPosition.Y, vector2.Y)
			local outOfBounds

			if label.AbsolutePosition.X > viewportSize.X and vector.X > 0 or label.AbsolutePosition.Y > viewportSize.Y and vector.Y > 0 or label.AbsolutePosition.X < 0 and vector.X < 0 then
				outOfBounds = true
			elseif label.AbsolutePosition.Y < 0 then
				outOfBounds = vector.Y < 0
			else
				outOfBounds = false
			end

			self.OutOfBounds = outOfBounds
			self.Position = vector2
			self.Power = vector3

			if vector3.Y < 0 then
				if self.Size <= 0 then
					self.Side = 1
					label.ImageColor3 = self.Color
				end

				if self.Size >= self.DefaultSize then
					self.Side = -1
					label.ImageColor3 = Color3.new(self.Color.r * 0.65, self.Color.g * 0.65, self.Color.b * 0.65)
				end

				self.Size += self.Side * 2
				label.Size = UDim2.new(0, self.DefaultSize, 0, self.Size)
			end
		end
	else
		self.Label.Visible = false
		self.OutOfBounds = true
		self.Color = v2[math.random(#v2)]
	end
end

function Confetti:Toggle()
	self.Enabled = not self.Enabled
end

function Confetti.SetColors(_, p)
	v2 = p
end

return Confetti