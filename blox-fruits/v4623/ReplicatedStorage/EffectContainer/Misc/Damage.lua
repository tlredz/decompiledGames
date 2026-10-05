local createVector = vector.create

local function trunc(p, p2)
	local v = 10 ^ p2
	return math.modf(p * v) / v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function format(p)
	if p < 1 then
		return 1
	end

	return (math.floor(p + 0.5))
end

local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin") or workspace.Terrain
local quad = Util.Tween.ease["in"].quad
local color = Color3.new(1, 1, 1)
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("DamageCounter", 10050, function(p)
	local v2 = tick() % 0.1 > math.min(1, #v / 15) * 0.06

	for k, v3 in pairs(v) do
		local v4 = (tick() - v3.Start) / v3.Duration

		if v4 > 1 then
			v3.GUI:Destroy()
			v[k] = nil
		else
			local v5 = v3.Position + v3.Velocity * p
			v3.Position = v5
			v3.Velocity += v3.Acceleration * 0.96 * p

			if v2 and v3.GUI:FindFirstChild("TextLabel") then
				v3.GUI.StudsOffsetWorldSpace = v5

				if v4 > 0.5 then
					local v6 = quad(v4 - 0.5, 0, 1, 0.5) ^ 0.5
					local v7 = 0.65 * (1 - v6 * 0.75)
					local v8 = 0.75 * (1 - v6 * 0.75)
					v3.GUI.TextLabel.Size = UDim2.new(v7, 0, v8, 0)
					v3.GUI.TextLabel.Position = UDim2.new(0.35, 0, 0.15 + (0.75 - v8) / 2, 0)
					v3.GUI.TextLabel.TextTransparency = v6
					v3.GUI.TextLabel.TextStrokeTransparency = 0.8 + v6
					v3.GUI.TextLabel.Inner.TextTransparency = v6
					v3.GUI.TextLabel.Inner.TextStrokeTransparency = 0.7 + v6
					v3.GUI.ImageLabel.ImageTransparency = v6
				else
					v3.GUI.TextLabel.Inner.TextColor3 = color:Lerp(v3.Color, (v4 / 0.5) ^ 3)
				end
			end
		end
	end
end)
local Damage = {}
Damage.__index = Damage

function Damage.new(data)
	local v2 = {
		Duration = data.Duration or 0.65,
		Element = data.Element or "rbxassetid://583589640",
		Value = 0,
		Acceleration = 0,
		Position = 0,
		Root = 0,
		Color = 0
	}
	local value = typeof(data.Value) == "string" and data.Value

	if not value then
		value = format(data.Value)
	end

	v2.Value = value
	v2.Acceleration = data.Acceleration or createVector(0, -98.1, 0)
	v2.Position = data.Position
	v2.Root = data.Root
	v2.Color = data.Color or Color3.new(1, 0, 0)
	return (setmetatable(v2, {
		__index = Damage
	}))
end

function Damage:Run()
	if #v > 30 then
		return self
	end

	if self.Root then
		self.Position = self.Root.Position
	end

	if Util.RenderDistance.value(self.Position) > 100 then
		return self
	end

	self.Start = tick()
	self.Velocity = Vector3.new(math.random() - 0.5, 0.65, math.random() - 0.5).unit * 30
	self.Position -= self.Velocity * createVector(1, 0, 1) * 0.1
	local clone = game.ReplicatedStorage.Assets.GUI.DamageCounter:Clone()
	clone.ImageLabel.Visible = false
	clone.TextLabel.Text = self.Value
	clone.TextLabel.Inner.Text = self.Value
	clone.MaxDistance = 1e999
	clone.Parent = _WorldOrigin
	self.GUI = clone
	table.insert(v, self)
	return self
end

return Damage