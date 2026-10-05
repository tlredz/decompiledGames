local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.Utility)
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
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe)
	end)
	table.insert(self._connections, renderSteppedConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		result:AdjustSpeed(0.5)
		wait(0.266)
		self:CreateSound("rbxassetid://8970814590", 1, 1, nil, true, 5)
		wait(0.334)
		self:CreateSound("rbxassetid://8970814590", 1, 1.25, nil, true, 5)
		wait(0.134)
		self:CreateSound("rbxassetid://8970814590", 1, 1.5, nil, true, 5)
		wait(2)
		result:AdjustSpeed(0.25)

		if result.IsPlaying then
			result.Stopped:Wait()
		end
	end

	clone:Destroy()
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object