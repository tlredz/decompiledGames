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

function object:PlayServer()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	rootPart.Anchored = true

	if self._is_humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://90573604180891"
		local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

		if success then
			result:Play(0)
		end
	end

	wait(1.8)
	rootPart.Anchored = false
	self:_Ragdoll()
	self:_AnchorModel()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local head = self._subject.Parent.Head
	local clone = head:Clone()
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Anchored = true
	clone.Parent = head

	for _, decal in pairs(clone:GetChildren()) do
		if not decal:IsA("Decal") then
			decal:Destroy()
		end
	end

	for _, decal in pairs(head:GetChildren()) do
		if decal:IsA("Decal") then
			decal.LocalTransparencyModifier = 1
		end
	end

	head.LocalTransparencyModifier = 1
	local lastTime = tick()
	table.insert(self._connections, RunService.RenderStepped:Connect(function(_)
		local v = math.clamp((tick() - lastTime) / 1.8, 0, 1)
		clone.Size = head.Size * (v * 2 + 1)
		clone.CFrame = head.CFrame * CFrame.new(0, -head.Size.Y / 2 + clone.Size.Y / 2, 0)
	end))
	self:CreateSound("rbxassetid://102780719481956", 1, 1, nil, true, 5)
end

function object:_Init() end

return object