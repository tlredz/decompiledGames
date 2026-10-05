local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject

	for _, part in pairs(self:_GetObjects(true)) do
		if part:IsA("BasePart") and part ~= rootPart then
			part:Destroy()
		end
	end

	rootPart.Size = createVector(0, 0, 0)

	for _ = 1, math.random(5, 10) do
		local v = Random.new():NextUnitVector() * createVector(1, 0, 1) + Vector3.new(0, 0.5 + 0.5 * math.random(), 0)
		local clone = script.Bone:Clone()
		clone.CFrame = rootPart.CFrame
		clone.Size *= 0.875 + 0.25 * math.random()
		clone.Velocity = v * (15 + 15 * math.random())
		clone.RotVelocity = Random.new():NextUnitVector() * (5 + 10 * math.random())
		clone.Parent = rootPart
		table.insert(self._destroy_these, clone)
	end

	local clone = script.BonePile:Clone()
	clone.Size = createVector(0, 0, 0)
	clone.CFrame = rootPart.CFrame
	clone.Velocity = Random.new():NextUnitVector() * (5 + 10 * math.random())
	clone.CollisionGroup = "IgnorePlayers"
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	TweenService:Create(clone, tweenInfo, {
		Size = script.BonePile.Size
	}):Play()
	self:CreateSound("rbxassetid://71015990947254", 1.25, 0.95 + 0.1 * math.random(), clone, true, 10)
	wait(3)
	TweenService:Create(clone, tweenInfo2, {
		Size = createVector(0, 0, 0)
	}):Play()
	wait(1)
end

function object:_Init() end

return object