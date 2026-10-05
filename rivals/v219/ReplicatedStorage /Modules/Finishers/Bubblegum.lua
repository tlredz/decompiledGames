local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
	wait(2)
	object2:_HideBody()
end

function object:PlayClient()
	local parts = {}

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Color = Color3.fromRGB(248, 151, 255)
		part.Material = Enum.Material.Glass

		if part:IsA("MeshPart") then
			part.TextureID = ""
		end

		table.insert(parts, part)
	end

	local parent

	if self._is_humanoid then
		parent = self._subject.Parent or nil
	else
		parent = nil
	end

	local scale = parent and parent:GetScale()
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v = ((tick() - lastTime) / 2) ^ 1.5
		local v2 = ((1 - math.cos(15.707963267948966 * v)) / 4 + 4 * v) / 4.5
		local v3 = 0.5 + 2.5 * v2

		if parent then
			parent:ScaleTo(scale * v3)
		end

		local localTransparencyModifier = v2 < 0.15 and 0 or (v2 ^ 4 - 0.15) / 0.75 * 0.5

		for _, v5 in pairs(parts) do
			v5.LocalTransparencyModifier = localTransparencyModifier
		end
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:_InternalThread(task.defer, function()
		self:CreateSound("rbxassetid://135921915396785", 1, 1, nil, true, 5)
		wait(0.78)
		self:CreateSound("rbxassetid://135921915396785", 1, 1, nil, true, 5)
		wait(0.8)
		self:CreateSound("rbxassetid://135921915396785", 1, 1, nil, true, 5)
	end)
	wait(2)
	renderSteppedConnection:Disconnect()
	local clone = script.Particles:Clone()
	clone.Parent = workspace
	clone.CFrame = (self._is_humanoid and self._subject.RootPart or self._subject).CFrame
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://94915446476512", 1, 1, clone, true, 5)
end

function object:_Init() end

return object