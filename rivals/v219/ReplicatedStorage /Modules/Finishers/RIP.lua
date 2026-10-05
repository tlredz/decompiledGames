local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.Utility)
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
	local playerFromCharacter = self._is_humanoid and Players:GetPlayerFromCharacter(self._subject.Parent)
	local displayName = playerFromCharacter and playerFromCharacter.DisplayName or ""
	local clone = script.Model:Clone()
	clone.Tomb.Part.Front.Player.Text = displayName
	clone.Tomb.Part.Back.Player.Text = displayName
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe + createVector(0, 2.25, 0))
	end)
	table.insert(self._connections, renderSteppedConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		self:CreateSound("rbxassetid://85156927480464", 1.5, 0.75, nil, true, 5)
		wait(0.7)

		for _, descendant in pairs((self._is_humanoid and self._subject.Parent or self._subject):GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Decal") then
				descendant:Destroy()
			end
		end

		self:CreateSound("rbxassetid://112796414625817", 2, 0.75, nil, true, 5)
		wait(9)
		self:CreateSound("rbxassetid://125843357117650", 2, 0.75, nil, true, 5)

		if result.IsPlaying then
			result.Stopped:Wait()
		end

		clone:Destroy()
		wait(3)
	end

	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object