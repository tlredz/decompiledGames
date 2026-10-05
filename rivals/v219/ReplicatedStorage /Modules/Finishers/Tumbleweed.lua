local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Modules.BetterDebris)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	self:CreateSound("rbxassetid://125154957015218", 0.5, 0.975 + 0.05 * math.random(), nil, true, 20)

	local function spawn_tumbleweed(p)
		local clone = script.Tumbleweed:Clone()
		clone.PrimaryPart = clone.Primary
		clone.Parent = workspace
		table.insert(self._destroy_these, clone)
		local v = p + createVector(0, 1, 0) * clone.PrimaryPart.Size.Y / 2
		local v2 = CFrame.new(v * createVector(1, 0, 1), rootPart.Position * createVector(1, 0, 1)).RightVector * math.sign(math.random() - 0.5)
		local v3 = v - v2 * 20 / 2
		local v4 = v + v2 * 20 / 2
		local identity = CFrame.identity
		local v5 = Random.new():NextUnitVector() * 0.08726646259971647 * 60
		local lastTime = tick()
		local v6 = tick() + 3

		while not self._destroyed and tick() < v6 do
			local v7 = math.clamp((tick() - lastTime) / 3, 0, 1)
			local v8 = math.abs((math.sin(12.566370614359172 * v7)))
			local v9 = v3:Lerp(v4, v7) + createVector(0, 1, 0) * v8 * 3
			local localTransparencyModifier = math.abs(math.sin(3.141592653589793 * (v7 - 0.5)) ^ 10)
			clone:PivotTo(CFrame.new(v9) * identity)

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = localTransparencyModifier
				end
			end

			local v11 = RunService.RenderStepped:Wait()
			identity *= CFrame.Angles(v5.X * v11, v5.Y * v11, v5.Z * v11)
		end

		clone:Destroy()
	end

	for _ = 1, 15 do
		local v = math.random() * 3.141592653589793 * 2
		local v2 = self:_GetGroundPosition(rootPart.Position) + Vector3.new(math.cos(v), 0, (math.sin(v))) * (0.25 + 3 * math.random())
		self:_InternalThread(task.spawn, spawn_tumbleweed, v2)
		wait(0.25)
	end

	wait(3)
end

function object:_Init() end

return object