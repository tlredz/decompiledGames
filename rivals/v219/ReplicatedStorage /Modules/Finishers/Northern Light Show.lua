local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient()
	Ragdoll.PlayClient(self)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	local clone = script.Aurora:Clone()
	clone.PrimaryPart = clone.Primary
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe)
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://81606650181214", 1, 1.25 + 0.125 * math.random(), nil, true, 5)
	local children = clone.Beams:GetChildren()
	Utility:RenderstepForLoop(0, 100, 1, function(p)
		for _, v in pairs(children) do
			v.LocalTransparencyModifier = 1 - p / 100
		end
	end)
	wait(3)
	Utility:RenderstepForLoop(0, 100, 1, function(p)
		for _, v in pairs(children) do
			v.LocalTransparencyModifier = p / 100
		end
	end)
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object