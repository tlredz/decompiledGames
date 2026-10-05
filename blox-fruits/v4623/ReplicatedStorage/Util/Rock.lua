local createVector = vector.create
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)

function mergeTable(...)
	local result = {}

	for _, v in next, { ... }, nil do
		for k, v2 in next, v, nil do
			result[k] = v2
		end
	end

	return result
end

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Tween = require(game.ReplicatedStorage.Util.Tween)
require(game.ReplicatedStorage.Util.Routine)
local RayCastWhitelist = require(game.ReplicatedStorage.Util.RayCastWhitelist)
local _WorldOrigin = workspace._WorldOrigin
local v = {}
local RunService2 = game:GetService("RunService")
local part

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	part = Instance.new("Part")
	part.TopSurface = 0
	part.BottomSurface = 0
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = Enum.MeshType.Brick
	RunService:BindToRenderStep(
		script.Parent.Name .. "-" .. script.Name,
		Enum.RenderPriority.Last.Value - 1000,
		function(p)
			local now = tick()

			for k, v2 in next, v, nil do
				local v3 = now - v2.Start

				if k.Parent and not (v2.Duration < v3) then
					local v4 = v3 / v2.Duration
					local quad = Tween.ease.out.quad(v4, 0, 1, 1)

					if not v2:Shift(v2.Direction * quad) then
						local quad2 = Tween.ease.out.quad(v4 - p * 5, 0, 1, 1)
						v2:Shift(v2.Direction * quad2)
						v[k] = nil
					end
				else
					v[k] = nil
				end
			end
		end
	)
else
	part = nil
end

local v2 = {
	Ground = {},
	Flying = {}
}
local Rock = {}

function Rock.new(p, data)
	local v3 = v2[p] or v2.Ground
	local v4 = mergeTable(v3, Rock)
	local v5 = {
		Type = p,
		Scale = data.Scale or 1,
		Lifetime = data.Lifetime or 0,
		FadeIn = data.FadeIn or 0.5,
		FadeOut = data.FadeOut or 0.5
	}

	if v5.Type == "Flying" then
		v5.RotVelocity = data.RotVelocity or Vector3.new()
		v5.Velocity = data.Velocity or Vector3.new()
	end

	return (setmetatable(v5, {
		__index = v4
	}))
end

function Rock:__build()
	if self.Part then
		return
	end

	self.Part = part:Clone()
	self.Mesh = self.Part.Mesh
	self.Scale = type(self.Scale) == "table" and Random.new():NextNumber(self.Scale[1], self.Scale[2]) or self.Scale
	self.Lifetime = type(self.Lifetime) == "table" and Random.new():NextNumber(self.Lifetime[1], self.Lifetime[2]) or self.Lifetime
	self.FadeIn = type(self.FadeIn) == "table" and Random.new():NextNumber(self.FadeIn[1], self.FadeIn[2]) or self.FadeIn
	self.FadeOut = type(self.FadeOut) == "table" and Random.new():NextNumber(self.FadeOut[1], self.FadeOut[2]) or self.FadeOut
	self.AngleOffset = CFrame.Angles(
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793),
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793),
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793)
	)
end

function Rock:__destroy()
	v[self.Part] = nil
	self.Part:Destroy()
end

function Rock:Spawn(cFrame)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return self
	end

	self:__build()
	local color = Color3.new(1, 1, 1)
	local smoothPlastic = Enum.Material.SmoothPlastic
	local vector2 = Vector3.new()
	local v3, v4, _ = RayCastWhitelist(
		cFrame.p + createVector(0, 0.01, 0),
		createVector(0, -1, 0) * self.Scale,
		{ workspace.Map }
	)

	if v3 then
		color = v3.Color
		smoothPlastic = v3.Material
	end

	self.CFrame = cFrame
	self.Part.Color = color
	self.Part.Material = smoothPlastic
	self.Mesh.Scale = vector2
	self.Part.CFrame = CFrame.new(v4) * (cFrame - cFrame.p) * self.AngleOffset
	self.Part.Parent = _WorldOrigin
	local tweenInfo = TweenInfo.new(self.FadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.Mesh, tweenInfo, {
		Scale = createVector(1, 1, 1) * self.Scale
	})
	local tweenInfo2 = TweenInfo.new(self.FadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween2 = TweenService:Create(self.Mesh, tweenInfo2, {
		Scale = Vector3.new()
	})
	tween.Completed:Connect(function()
		wait(self.Lifetime)
		tween2.Completed:Connect(function()
			self:__destroy()
		end)
		tween2:Play()
	end)
	tween:Play()
	return self
end

function v2.Ground:Shift(p)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	assert(
		typeof(p) == "Vector3",
		string.format("Parameter \"direction\" should be a Vector3 value, got %s", (typeof(p)))
	)
	local v3 = self.CFrame * self.AngleOffset + p
	local v4, v5, _ = RayCastWhitelist(
		v3.p + createVector(0, 1, 0) * self.Scale * 0.1,
		createVector(0, -1, 0) * self.Scale * 2,
		{ workspace.Map }
	)

	if v4 then
		self.Part.CFrame = CFrame.new(v5) * (v3 - v3.p) * self.AngleOffset + p
		self.Part.Color = v4.Color
		self.Part.Material = v4.Material
	end

	return v4
end

function v2.Ground:TweenShift(direction, value)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	v[self.Part] = {
		Scale = self.Scale,
		Shift = function(_, p2)
			return self:Shift(p2)
		end,
		Direction = direction,
		Duration = value or 1,
		Start = tick()
	}
end

function v2.Flying.Eject(data, p)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	local velocity = p.Velocity or data.Velocity
	local rotVelocity = p.RotVelocity or data.RotVelocity
	data.Part.Velocity = data.Part.Velocity + velocity
	data.Part.RotVelocity = data.Part.RotVelocity + rotVelocity
	data.Part.Anchored = false
end

return Rock