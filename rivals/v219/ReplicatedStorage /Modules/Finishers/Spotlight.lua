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
		local beam = clone.StageLight.Here.Beam
		local spotLight = clone.StageLight.Here.SpotLight
		self:_InternalThread(task.spawn, function()
			beam.Enabled = false
			spotLight.Enabled = false
			wait(1.25)
			beam.Enabled = true
			spotLight.Enabled = true
			self:CreateSound("rbxassetid://110123816156526", 1.25, 0.95 + 0.1 * math.random(), rootPart, true, 10)
		end)

		if result.IsPlaying then
			result.Stopped:Wait()
		end
	end

	clone:Destroy()
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object