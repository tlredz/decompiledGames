local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	50,
	55,
	57,
	58,
	62,
	63,
	75,
	78,
	104,
	107,
	111,
	115
}
local v2 = { "rbxassetid://11800684674", "rbxassetid://11800684590", "rbxassetid://11800684481" }
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
			Utility:ScaleParticleEmitter(emitter, 1.5)
		end
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe)
	end)
	table.insert(self._connections, renderSteppedConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		result:AdjustSpeed(1)
		self:_InternalThread(task.spawn, function()
			local total = 0.08333333333333333

			for k, v3 in pairs(v) do
				total += wait((v3 - 1 * k) / 60 / 1 - total)
				clone.HumanoidRootPart.Attachment.Position = Vector3.new(
					math.random() - 0.5,
					math.random() - 0.5,
					math.random() - 0.5
				) * 5
				Utility:PlayParticles(clone.HumanoidRootPart.Attachment)
				self:CreateSound(v2[math.random(#v2)], 0.4 + 0.4 * (k / #v), 0.9 + 0.2 * math.random(), nil, true, 5)
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