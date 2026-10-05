local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
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

function object:PlayClient()
	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			local HSV, _, v = instance.Color:ToHSV()
			instance.Color = Color3.fromHSV(HSV, 0, v * 0.5)
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance:Destroy()
		end
	end

	local parent = self._is_humanoid and self._subject.Parent or self._subject
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Skull:Clone()
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	self:CreateSound("rbxassetid://117434088219830", 0.75, 1 + 0.1 * math.random(), nil, true, 5)
	local pivot = parent:GetPivot()
	table.insert(self._connections, RunService.RenderStepped:Connect(function(_)
		local v = pivot + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.1
		parent:PivotTo(v)
		clone.CFrame = v + CFrame.new(workspace.CurrentCamera.CFrame.Position, v.Position).LookVector * -math.min(
			3,
			(workspace.CurrentCamera.CFrame.Position - v.Position).Magnitude * 0.5
		)
	end))
end

function object:_Init() end

return object