local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local color = Color3.fromRGB(221, 221, 221)
local color2 = Color3.fromRGB(27, 42, 53)
local Utility = require(ReplicatedStorage.Modules.Utility)
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
	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe)
	end)
	table.insert(self._connections, heartbeatConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		wait(1.375)
		clone.Cloud.vfx.water1.Enabled = true
		clone.Cloud.vfx2.water2.Enabled = true
		clone.Cloud.ground.ring1.Enabled = true
		clone.Cloud.ground.splash1.Enabled = true
		self:_InternalThread(task.spawn, Utility.RenderstepForLoop, Utility, 0, 100, 2, function(p)
			local v = 1 - (1 - p / 100) ^ 2
			clone.Cloud.Color = color:Lerp(color2, v)
		end)
		self:_InternalThread(task.defer, function()
			wait(0.5)
			Utility:PlayParticles(clone.Cloud.Thunder)
			self:CreateSound("rbxassetid://79197041664081", 1.5, 0.75 + 0.25 * math.random(), nil, true, 5)
			wait(1)
			Utility:PlayParticles(clone.Cloud.Thunder)
			self:CreateSound("rbxassetid://79197041664081", 1.5, 0.75 + 0.25 * math.random(), nil, true, 5)
			wait(0.3)
			Utility:PlayParticles(clone.Cloud.Thunder)
			self:CreateSound("rbxassetid://79197041664081", 1.5, 0.75 + 0.25 * math.random(), nil, true, 5)
		end)
		self:CreateSound("rbxassetid://114760171297145", 2, 1, nil, true, 5)
		wait(2.75)
		clone.Cloud.vfx.water1.Enabled = false
		clone.Cloud.vfx2.water2.Enabled = false
		clone.Cloud.ground.ring1.Enabled = false
		clone.Cloud.ground.splash1.Enabled = false
		self:_InternalThread(task.spawn, Utility.RenderstepForLoop, Utility, 0, 100, 2, function(p)
			local v = (p / 100) ^ 2
			clone.Cloud.Color = color2:Lerp(color, v)
		end)
		wait(1)
	end

	clone:Destroy()
end

function object:_Init() end

return object