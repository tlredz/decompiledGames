local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
end

function object:PlayClient(...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	self:CreateSound("rbxassetid://91581971640099", 1.5, 1, nil, true, 5)
	self:CreateSound("rbxassetid://17812496122", 0.5, 1.25 + 0.25 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://17812566721", 2, 1 + 0.2 * math.random(), nil, true, 5)
	self:_InternalThread(task.spawn, function()
		wait(0.25)
		self:CreateSound("rbxassetid://18128895977", 2, 1, nil, true, 5)
		wait(0.25)
		local parent = self._is_humanoid and self._subject.Parent or self._subject

		for _, descendant in pairs(parent:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Decal") then
				descendant:Destroy()
			end
		end
	end)
	local v = (Random.new():NextUnitVector() * createVector(1, 0, 1)).Unit * 30
	local position = nil
	Utility:RenderstepForLoop(0, 100, 2, function(p)
		local v2 = p / 100
		local v3 = math.sin(3.141592653589793 * v2)
		local v4

		if v2 < 0.5 then
			v4 = v:Lerp(createVector(0, 0, 0), v2 * 2)
		else
			v4 = (createVector(0, 0, 0)):Lerp(-v, v2 * 2 - 1)
		end

		local v5 = CFrame.new(rootPart.Position) + (createVector(0, -30, 0)):Lerp(createVector(0, 0, 0), v3) + v4

		if position and not position:FuzzyEq(v5.Position) then
			v5 = CFrame.new(v5.Position, position) * CFrame.Angles(1.5707963267948966, 0, 0)
		end

		clone:PivotTo(v5)
		position = v5.Position
	end)
	clone:Destroy()
end

function object:_Init() end

return object