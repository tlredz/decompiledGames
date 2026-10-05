local createVector = vector.create
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
	wait(2.55)
	local _GetObjects = self:_GetObjects(true)
	local _GetGroundPosition = self:_GetGroundPosition(rootPart.Position, _GetObjects)
	local cFrame = rootPart.CFrame
	local v = CFrame.new(_GetGroundPosition + createVector(0, -16, 0)) * cFrame.Rotation
	local lastTime = tick()

	while tick() < lastTime + 0.25 do
		rootPart.CFrame = cFrame:Lerp(v, math.clamp((tick() - lastTime) / 0.25, 0, 1) ^ 2)
		RunService.Heartbeat:Wait()
	end

	wait(0.25)
	rootPart.Anchored = false
	self:_Ragdoll()
	self:_AnchorModel()
	wait(0.5)
end

function object:PlayClient()
	if self._is_humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://82538222745985"
		local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

		if success then
			result:Play(0)
		end
	end

	local clone = script.Hole:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local clones = self:_GetObjects(true)
	table.insert(clones, clone)
	self:CreateSound("rbxassetid://93213527475361", 1, 1, nil, true, 5)
	self:_InternalThread(task.defer, function()
		wait(2.4499999999999997)
		self:CreateSound("rbxassetid://128064423147007", 1, 0.875, nil, true, 5)
		wait(0.6)
		self:CreateSound("rbxassetid://128064423147007", 0.375, 1.5, nil, true, 5)
	end)
	local position = (self._is_humanoid and self._subject.RootPart or self._subject).Position
	local lastTime = tick()

	while tick() < lastTime + 2.55 + 0.25 + 0.5 do
		local v

		if tick() < lastTime + 2.55 + 0.25 then
			v = math.clamp((tick() - lastTime) / 2.55, 0, 1)
		else
			v = math.clamp((tick() - lastTime - 2.55 - 0.25) / 0.5, 0, 1)
		end

		local v2

		if tick() < lastTime + 2.55 + 0.25 then
			v2 = v < 0.5 and v ^ 5 * 16 or 1 - (v * -2 + 2) ^ 5 / 2
		else
			v2 = 1 - v ^ 5
		end

		clone.Size = (createVector(0, 0, 0)):Lerp(createVector(0.5, 12, 12), v2)
		clone.CFrame = CFrame.new(self:_GetGroundPosition(position, clones)) * CFrame.Angles(0, 0, 1.5707963267948966)
		RunService.RenderStepped:Wait()
	end

	clone:Destroy()
end

function object:_Init() end

return object