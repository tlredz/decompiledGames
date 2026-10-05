local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
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
	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v = 1 - (1 - math.clamp((tick() - lastTime) / 1, 0, 1)) ^ 5
		clone:PivotTo(CFrame.new(rootPart.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		) * CFrame.new(0, v * 8 + -8, 0))
	end)
	table.insert(self._connections, renderSteppedConnection)

	local function reposition()
		clone.LeftCurtain.CFrame = clone.Main.LeftAttachment.WorldCFrame * CFrame.new(
			0,
			0,
			-clone.LeftCurtain.Size.Z / 2
		)
		clone.RightCurtain.CFrame = clone.Main.RightAttachment.WorldCFrame * CFrame.new(
			0,
			0,
			clone.RightCurtain.Size.Z / 2
		)
	end

	clone.LeftCurtain:GetPropertyChangedSignal("Size"):Connect(reposition)
	clone.RightCurtain:GetPropertyChangedSignal("Size"):Connect(reposition)
	TweenService:Create(clone.LeftCurtain, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(0.865, 6.719, 5.066)
	}):Play()
	TweenService:Create(clone.RightCurtain, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(0.865, 6.719, 5.066)
	}):Play()
	self:CreateSound("rbxassetid://129997046680336", 0.75, 0.75 + 0.1 * math.random(), rootPart, true, 10)
	wait(1.5)
	self:_HideBody()
	TweenService:Create(clone.LeftCurtain, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = createVector(0.865, 6.719, 2.066)
	}):Play()
	TweenService:Create(clone.RightCurtain, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = createVector(0.865, 6.719, 2.066)
	}):Play()
	self:CreateSound("rbxassetid://129997046680336", 1, 0.9 + 0.1 * math.random(), rootPart, true, 10)
	wait(1.5)

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	renderSteppedConnection:Disconnect()
	wait(0.5)
end

function object:_Init() end

return object