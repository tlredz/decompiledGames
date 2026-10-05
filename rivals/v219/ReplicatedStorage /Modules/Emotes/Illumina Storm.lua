local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(nil, script.Name, ...), object)
	self._illuminas = {}
	self._illumina_anchor = self._humanoid.RootPart
	self:_Init()
	return self
end

function object:PlayClient(...)
	Emote.PlayClient(self, ...)
	self:_PlayAnimation("rbxassetid://77038993402535", nil, nil, 0.5)

	if not self._illumina_anchor then
		return
	end

	local v = self:_IsWorkspaceEmote() and 0.5 or 0.125

	for _, childName in pairs({ "RightHand", "LeftHand" }) do
		local child = self._humanoid.Parent and self._humanoid.Parent:FindFirstChild(childName)

		if not child then
			continue
		end

		local clone = script.IlluminaHand:Clone()
		clone:PivotTo(child.CFrame)
		clone.Parent = child
		table.insert(self._destroy_these, clone)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = child
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone
	end

	local clone = script.IlluminaLight:Clone()
	clone.Parent = self._illumina_anchor
	table.insert(self._destroy_these, clone)
	local clone2 = script.IlluminaSparkles:Clone()
	clone2.Parent = self._illumina_anchor
	table.insert(self._destroy_these, clone2)

	local function new_illumina()
		local clone3 = script.Illumina:Clone()
		clone3.Name = "_Illumina"
		clone3.Parent = self._illumina_anchor.Parent
		local height = -2 + 12 * math.random()
		table.insert(self._illuminas, {
			Object = clone3,
			Start = tick(),
			Rad = math.random() * 3.141592653589793 * 2,
			Lifetime = 2 + 4 * math.random(),
			Speed = (1 + 6 * math.random()) * 2,
			Spin = Random.new():NextUnitVector() * (1 + 9 * math.random()),
			Height = height,
			Spacing = 4 + 2 * math.random() + height / 2
		})
	end

	for _ = 1, v * 20 do
		new_illumina()
	end

	local lastTime = tick()
	local v2 = 0
	local v3 = 0
	table.insert(self._connections, RunService.RenderStepped:Connect(function(dt)
		local now = tick()

		if v2 <= now then
			v2 = tick() + 0.1 / v
			new_illumina()
		end

		local now2 = tick()

		if v3 <= now2 then
			v3 = tick() + 0.05 + 0.15 * math.random()
			local v4 = 1 + (tick() - lastTime) * 0.1
			self:CreateSound(
				"rbxassetid://114436319908436",
				(0.25 + 0.5 * math.random()) / v4,
				0.875 + 0.25 * math.random(),
				nil,
				true,
				5
			)
		end

		for i = #self._illuminas, 1, -1 do
			local _illumina = self._illuminas[i]

			if tick() > _illumina.Start + _illumina.Lifetime then
				_illumina.Object:Destroy()
				table.remove(self._illuminas, i)
			end

			_illumina.Rad -= dt * _illumina.Speed
			local object3 = _illumina.Object
			local transparency

			if tick() - _illumina.Start < 0.5 then
				transparency = 1 - math.clamp((tick() - _illumina.Start) / 0.5, 0, 1)
			else
				transparency = not (tick() > _illumina.Start + _illumina.Lifetime - 0.5) and 0 or math.clamp(
					(tick() - (_illumina.Start + _illumina.Lifetime - 0.5)) / 0.5,
					0,
					1
				)
			end

			object3.Transparency = transparency
			_illumina.Object.CFrame = CFrame.new(self._illumina_anchor.Position) * CFrame.new(
				math.sin(_illumina.Rad) * _illumina.Spacing,
				_illumina.Height,
				math.cos(_illumina.Rad) * _illumina.Spacing
			) * _illumina.Object.CFrame.Rotation * CFrame.Angles(
				_illumina.Spin.X * dt,
				_illumina.Spin.Y * dt,
				_illumina.Spin.Z * dt
			)
		end
	end))
end

function object:Destroy()
	for _, _illumina in pairs(self._illuminas) do
		_illumina.Object.Anchored = false
		_illumina.Object.Velocity = (_illumina.Object.Position - self._illumina_anchor.Position).Unit * (10 + 30 * math.random())
		_illumina.Object.RotVelocity = Random.new():NextUnitVector() * (5 + 20 * math.random())
		BetterDebris:AddItem(_illumina.Object, 3)
	end

	Emote.Destroy(self)
end

function object:_Init() end

return object