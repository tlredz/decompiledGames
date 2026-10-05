local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	38,
	93,
	113,
	125,
	130,
	139,
	150
}
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

	for _, emitter in pairs(clone.HumanoidRootPart.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, 2)
		end
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe)
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://99054783153991", 1, 1 + 0.05 * math.random(), nil, true, 5)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		result:AdjustSpeed(1.5)
		self:_InternalThread(task.spawn, function()
			local total = 0

			for k, v2 in pairs(v) do
				total += wait((v2 - 1 * k) / 60 / 1.5 - total)
				clone.HumanoidRootPart.Attachment.Position = Vector3.new(
					math.random() - 0.5,
					math.random() - 0.5,
					math.random() - 0.5
				) * 5
				Utility:PlayParticles(clone.HumanoidRootPart.Attachment)
				self:CreateSound("rbxassetid://11170608962", 0.75, 1 + 0.125 * k, nil, true, 5)
				self:CreateSound("rbxassetid://14796313153", 1, 1 + 0.125 * k, nil, true, 5)
			end
		end)

		if result.IsPlaying then
			result.Stopped:Wait()
		end
	end

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end

	BetterDebris:AddItem(clone, 3)
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object