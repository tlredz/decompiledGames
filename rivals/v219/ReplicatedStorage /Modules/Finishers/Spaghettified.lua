local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
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
	self._subject.RootPart.CFrame *= CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	TweenService:Create(self._subject.RootPart, TweenInfo.new(1.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		CFrame = self._subject.RootPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -10)
	}):Play()
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://84375821263857"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(1.6)
	self:_HideBody()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://84375821263857"
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.HumanoidRootPart
	clone:PivotTo(self._subject.RootPart.CFrame)
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 1.6)

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
		self:CreateSound("rbxassetid://86826830376840", 0.75, 1, nil, true, 5)
		wait(0.15)
		self:CreateSound("rbxassetid://7127702569", 1, 1.2, nil, true, 5)
		wait(1.4500000000000002)
		self:CreateSound("rbxassetid://7127702569", 1, 0.8, nil, true, 5)
	end)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(self._subject.RootPart.CFrame)
	end)
	table.insert(self._connections, renderSteppedConnection)
	wait(1.6)
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object