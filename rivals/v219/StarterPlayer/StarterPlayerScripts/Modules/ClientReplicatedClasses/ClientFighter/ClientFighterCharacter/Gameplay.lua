local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Spring = require(ReplicatedStorage.Modules.Spring)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local dashParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.DashParticles
local Gameplay = {}
Gameplay.__index = Gameplay

function Gameplay.new(clientFighterCharacter)
	local self = setmetatable({}, Gameplay)
	self.RedirectSliding = Signal.new()
	self.ClientFighterCharacter = clientFighterCharacter
	self._destroyed = false
	self._fov_offset_spring = Spring.new(0, 0.75, 10)
	self._hard_dashes = {}
	self:_Init()
	return self
end

function Gameplay:GetFOVOffset()
	return self._fov_offset_spring.Value
end

function Gameplay:CancelHardDash(p2)
	local _hard_dash = self._hard_dashes[p2]

	if not _hard_dash then
		return
	end

	_hard_dash.Velocity:Destroy()

	for _, thread in pairs(_hard_dash.Threads) do
		pcall(task.cancel, thread)
	end

	self._hard_dashes[p2] = nil
	self.ClientFighterCharacter.RootPart.AssemblyLinearVelocity *= _hard_dash.StopVector
end

function Gameplay:HardDash(velocity, duration, p, p2, p3)
	self.ClientFighterCharacter:AirborneCancel()
	self.ClientFighterCharacter.ClientFighter.StopSliding:Fire()
	self.ClientFighterCharacter.Sounds:DisableFootsteps(duration)
	local v = {
		Velocity = Instance.new("BodyVelocity"),
		Threads = {},
		StopVector = p2 or createVector(0, 0, 0)
	}
	v.Velocity = Instance.new("BodyVelocity")
	v.Velocity.MaxForce = createVector(40000, 40000, 40000)
	v.Velocity.Velocity = velocity
	v.Velocity.Parent = self.ClientFighterCharacter.RootPart
	BetterDebris:AddItem(v.Velocity, duration + 0.1)
	table.insert(v.Threads, task.delay(duration, function()
		if p3 then
			self:CancelHardDash(p3)
		end

		v.Velocity:Destroy()
		self.ClientFighterCharacter.RootPart.AssemblyLinearVelocity *= v.StopVector
		self.ClientFighterCharacter:AirborneCancel()
		self.ClientFighterCharacter.ClientFighter.StopSliding:Fire()
	end))

	if not p then
		table.insert(v.Threads, task.spawn(function()
			local rootPart = self.ClientFighterCharacter.RootPart

			if not rootPart then
				return
			end

			local clone = dashParticles:Clone()
			clone.Parent = rootPart
			BetterDebris:AddItem(clone, duration + 5)
			local position = rootPart.Position
			local v2 = tick() + duration

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			while not self._destroyed and tick() < v2 do
				if (position - rootPart.Position).Magnitude > 0.01 then
					clone.CFrame = CFrame.new(rootPart.Position, position) * CFrame.Angles(0, 3.141592653589793, 0)
				end

				RunService.Heartbeat:Wait()
			end

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end))
	end

	if p3 then
		self._hard_dashes[p3] = v
	end
end

function Gameplay:WarpTo(cFrame)
	if not (self.ClientFighterCharacter.ClientFighter.IsLocalPlayer and self.ClientFighterCharacter:IsAlive()) then
		return
	end

	self.ClientFighterCharacter.RootPart.CFrame = cFrame
	self._fov_offset_spring.Value = 10
	local v = Utility:AngleBetweenVectors(cFrame.LookVector, createVector(0, 1, 0)) < 0.7853981633974483 or Utility:AngleBetweenVectors(
		cFrame.LookVector,
		createVector(-0, -1, -0)
	) < 0.7853981633974483

	if not v then
		CameraController:MimicRotation(cFrame)
	end

	if self.ClientFighterCharacter.ClientFighter:IsSliding() and not v then
		self.RedirectSliding:Fire(cFrame.LookVector)
		return
	end

	local velocity = self.ClientFighterCharacter.RootPart.Velocity
	local v2 = cFrame.LookVector * math.max(16, (math.sqrt(velocity.Magnitude)))
	local v3

	if v then
		v3 = velocity.Unit * math.max(
			(velocity * (createVector(1, 0, 1)).Unit).Magnitude,
			self.ClientFighterCharacter.Humanoid.WalkSpeed
		)
	end

	if not v3 or v3 ~= v3 or not (v3.Magnitude > 0.001 and v3) then
		v3 = nil
	end

	self.ClientFighterCharacter:AirborneTrigger(v2, 12, nil, v3)
end

function Gameplay.Update(_, _, _) end

function Gameplay:Destroy()
	self._destroyed = true
end

function Gameplay:_Init() end

return Gameplay