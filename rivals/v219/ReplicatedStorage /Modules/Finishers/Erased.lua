local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe * CFrame.Angles(1.5707963267948966, 0, 0))
	end)
	table.insert(self._connections, renderSteppedConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		wait(0.65)
		self:CreateSound("rbxassetid://121251326830312", 1.25, 1, nil, true, 5)
		wait(0.1)
		local v = {}

		for _, instance in pairs(self:_GetObjects(true)) do
			if not (instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("Beam") or instance:IsA("ParticleEmitter") or instance:IsA("Trail")) then
				continue
			end

			v[instance] = true
		end

		local lastTime = tick()

		while tick() < lastTime + 0.75 do
			local localTransparencyModifier = math.clamp((tick() - lastTime) / 0.75, 0, 1)

			for k in pairs(v) do
				k.LocalTransparencyModifier = localTransparencyModifier
			end

			RunService.RenderStepped:Wait()
		end

		for k in pairs(v) do
			k.LocalTransparencyModifier = 1
		end

		if result.IsPlaying then
			result.Stopped:Wait()
		end
	end

	clone:Destroy()
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object