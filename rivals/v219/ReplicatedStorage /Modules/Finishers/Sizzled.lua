local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Spring = require(ReplicatedStorage.Modules.Spring)
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
	local clone = script.Model:Clone()
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local _GetObjects = self:_GetObjects(true)
	local v = Spring.new(rootPart.Position, 1, 2)
	local v2 = {}
	local lastTime = tick()
	table.insert(self._connections, RunService.RenderStepped:Connect(function()
		v.Target = self:_GetGroundPosition(rootPart.Position, _GetObjects) + createVector(0, 0.01, 0)
		clone:PivotTo(CFrame.new(v.Value.X, v.Target.Y, v.Value.Z))
		local v3 = math.clamp((tick() - lastTime) / 4, 0, 1)
		local v4 = math.clamp(v3 * 2, 0, 1)
		local v5 = math.clamp(v3 * 2 - 1, 0, 1)

		for _, part in pairs(self:_GetObjects(true)) do
			if not part:IsA("BasePart") then
				continue
			end

			v2[part] = v2[part] or part.Color
			part.Material = Enum.Material.Glass
			part.MaterialVariant = ""
			part.Color = v2[part]:Lerp(Color3.fromRGB(143, 76, 42), v4):Lerp(Color3.fromRGB(61, 32, 18), v5)
		end
	end))
	self:CreateSound("rbxassetid://120630457366669", 1, 1 + 0.1 * math.random(), nil, true, 10)
	self:CreateSound("rbxassetid://126523239993274", 0.75, 1 + 0.1 * math.random(), nil, true, 10)
end

function object:_Init() end

return object