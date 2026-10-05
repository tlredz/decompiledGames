local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	if not self._is_humanoid then
		return
	end

	self._subject.RootPart.Anchored = true
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://106864398124698"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(2.15)
	self:_HideBody()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://106864398124698"
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.HumanoidRootPart
	clone:PivotTo(self._subject.RootPart.CFrame)
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 2.15)

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Noclip"
		end
	end

	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, animation)

	if success then
		result:Play(0)
	end

	self:_InternalThread(task.spawn, function()
		wait(1.3)
		self:CreateSound("rbxassetid://113843062064513", 0.75, 1 + 0.1 * math.random(), nil, true, 5)
		self:CreateSound("rbxassetid://95086117365305", 0.75, 1 + 0.1 * math.random(), nil, true, 5)
	end)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(self._subject.RootPart.CFrame)
	end)
	table.insert(self._connections, renderSteppedConnection)
	wait(2.15)
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object