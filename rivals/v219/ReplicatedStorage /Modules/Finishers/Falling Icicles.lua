local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.Utility)
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe)
	end)
	table.insert(self._connections, renderSteppedConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		result:AdjustSpeed(2)
		self:_InternalThread(task.defer, function()
			local v = {}

			for i = 1, 16 do
				table.insert(v, clone["Icicles" .. i])
			end

			local sizes = {}

			for _, v2 in pairs(v) do
				sizes[v2] = v2.Size
				v2.Size = createVector(0, 0, 0)
			end

			for _, v2 in pairs(v) do
				TweenService:Create(v2, tweenInfo, {
					Size = sizes[v2]
				}):Play()
				wait(0.05)
			end
		end)
		self:CreateSound("rbxassetid://93583856628897", 1, 1.5 + 0.2 * math.random(), nil, true, 5)
		wait(0.55)

		for _ = 1, 6 do
			self:CreateSound(
				"rbxassetid://99261833097954",
				0.8 + 0.2 * math.random(),
				1 + 0.2 * math.random(),
				nil,
				true,
				10
			)
			wait(0.05 + 0.1 * math.random())
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