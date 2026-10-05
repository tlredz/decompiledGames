local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Spring = require(ReplicatedStorage.Modules.Spring)
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
local Airborne = {}
Airborne.__index = Airborne

function Airborne.new(clientFighterCharacter)
	local self = setmetatable({}, Airborne)
	self.AirborneChanged = Signal.new()
	self.ClientFighterCharacter = clientFighterCharacter
	self.IsAirborne = false
	self._destroyed = false
	self._airborne_spring = nil
	self._airborne_velocity = nil
	self._airborne_start = 0
	self._effect_objects = {}
	self._animation_hash = 0
	self._animation_track = nil
	self._cleanup = {}
	self:_Init()
	return self
end

function Airborne:IsActive()
	if self.ClientFighterCharacter.ClientFighter.IsLocalPlayer then
		return self.IsAirborne
	end

	return (self.ClientFighterCharacter:Get("IsAirborne"))
end

function Airborne:Redirect(p2, value)
	if not self._airborne_spring then
		return
	end

	local v = p2 or self._airborne_spring.Target
	self._airborne_spring.Value = v * (value or 1)
end

function Airborne:Trigger(data, p, p2, p3, value, value2, value3, value4)
	local v = value or 1
	local v2 = value2 or 1
	local v3 = value3 or 1

	if not self.ClientFighterCharacter.ClientFighter.IsLocalPlayer or data.Magnitude <= 0.01 or self.ClientFighterCharacter:Get("IsFrozen") or self._airborne_velocity and p2 then
		return
	end

	local v4 = not self._airborne_velocity and createVector(0, 0, 0) or self._airborne_velocity.Velocity or createVector(
		0,
		0,
		0
	)
	local velocity

	if self._airborne_velocity then
		velocity = self._airborne_velocity.Velocity or data
	else
		velocity = data
	end

	local vector2 = Vector3.new(
		math.max(math.abs(data.X), (math.abs(v4.X))) * math.sign(velocity.X),
		data.Y,
		math.max(math.abs(data.Z), (math.abs(v4.Z))) * math.sign(velocity.Z)
	)

	if self._airborne_velocity then
		self._airborne_velocity:Destroy()
		self._airborne_velocity = nil
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = createVector(0, 0, 0)
	BetterDebris:AddItem(bodyVelocity, 5)
	self._airborne_start = tick()
	self._airborne_velocity = bodyVelocity
	self.ClientFighterCharacter.ClientFighter.StopSliding:Fire()
	self:_SetIsAirborne(true)
	task.spawn(function()
		bodyVelocity.Parent = self.ClientFighterCharacter.RootPart
		self._airborne_spring = Spring.new(p3 and p3.Unit or vector2.Unit, 1, p)
		local magnitude = p3 and p3.Magnitude or (vector2 * createVector(1, 0, 1)).Magnitude
		local lastTime = tick()
		local v5 = lastTime + (value4 or 1e999)
		local v6 = false
		local lastTime2 = nil
		local position = nil

		while tick() < v5 and not self._destroyed and bodyVelocity == self._airborne_velocity and bodyVelocity:IsDescendantOf(self.ClientFighterCharacter.RootPart) and self.ClientFighterCharacter:IsAlive() and not (tick() - lastTime > 0.2 and self.ClientFighterCharacter.RootPart.Velocity.Magnitude < 5) do
			if not v6 and tick() - lastTime > 0.2 then
				bodyVelocity.MaxForce *= createVector(0.1, 1, 0.1)
				v6 = true
			end

			local floor, v7 = self.ClientFighterCharacter:GetFloor()
			local v8 = floor and Utility:AngleBetweenVectors(createVector(0, 1, 0), v7.Normal) < 0.1308996938995747
			local v9, v10, v11, v12

			if tick() - lastTime > 0.2 and v8 then
				if vector2.Y < 0 then
					break
				end

				if lastTime2 then
					if tick() - lastTime2 > 1 then
						break
					end
				else
					lastTime2 = tick()
				end
			else
				lastTime2 = nil
			end

			if position and not (math.abs(self.ClientFighterCharacter.RootPart.Position.Y - position.Y) > 1) then
				if v8 and ((position - self.ClientFighterCharacter.RootPart.Position) * createVector(1, 0, 1)).Magnitude > 8 then
					break
				end
			else
				position = self.ClientFighterCharacter.RootPart.Position
			end

			self._airborne_spring.Target = self.ClientFighterCharacter.ClientFighter:GetMoveVector(true, true)
			v9 = self._airborne_spring.Value * createVector(1, 0, 1) * magnitude + Vector3.new(0, vector2.Y, 0)
			v10 = 1 + (v - 1) * math.clamp((tick() - lastTime) / v2, 0, 1)
			v11 = 16 / self.ClientFighterCharacter.RootPart.AssemblyMass
			bodyVelocity.Velocity = v9 * v10 * v11

			if bodyVelocity.MaxForce.Y > 0 and tick() - lastTime > 0.2 then
				v12 = bodyVelocity
				v12.MaxForce *= Vector3.new(1, 1 - v3, 1)
			end

			RunService.Heartbeat:Wait()
		end

		if self._airborne_velocity ~= bodyVelocity then
			return
		end

		self:Cancel()
	end)
end

function Airborne:Cancel()
	if not self.ClientFighterCharacter.ClientFighter.IsLocalPlayer then
		return
	end

	self._airborne_spring = nil

	if self._airborne_velocity then
		self._airborne_velocity:Destroy()
		self._airborne_velocity = nil
	end

	self:_SetIsAirborne(false)
end

function Airborne:FromServer(p, p2, value, p3)
	if not self.ClientFighterCharacter.ClientFighter.IsLocalPlayer then
		return
	end

	if p3 then
		self:Cancel()
	end

	self:Trigger(p * 0.75, value or 4, nil, nil, nil, nil, nil, p2)
end

function Airborne.Update(_, _, _) end

function Airborne:Destroy()
	self._destroyed = true

	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	self.AirborneChanged:Destroy()
	self:Cancel()
end

function Airborne:_UpdateEffect()
	for _, trail in pairs(self._effect_objects) do
		if trail:IsA("Trail") then
			trail.Enabled = false
		end

		BetterDebris:AddItem(trail, 0.25)
	end

	self._effect_objects = {}

	if not self:IsActive() or self.ClientFighterCharacter.ClientFighter:Get("IsHiddenByEmotes") or self.ClientFighterCharacter.ClientFighter:Get("IsHiddenByCutscene") then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(-0.5, -2.9, 0)
	attachment.Name = "Airborne0"
	attachment.Parent = self.ClientFighterCharacter.RootPart
	table.insert(self._effect_objects, attachment)
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(0.5, -2.9, 0)
	attachment2.Name = "Airborne1"
	attachment2.Parent = self.ClientFighterCharacter.RootPart
	table.insert(self._effect_objects, attachment2)
	local trail = Instance.new("Trail")
	trail.Transparency = NumberSequence.new(1, 0)
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Lifetime = 0.25
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Parent = self.ClientFighterCharacter.RootPart
	table.insert(self._effect_objects, trail)
end

function Airborne:_UpdateAnimation()
	if not self.ClientFighterCharacter.ClientFighter.IsLocalPlayer then
		return
	end

	local isActive = self:IsActive()
	local v = isActive and 0 or nil

	if self._animation_track then
		self._animation_track:Stop(v)
		self._animation_track:Destroy()
		self._animation_track = nil
	end

	self._animation_hash += 1

	if not isActive then
		return
	end

	local _animation_hash = self._animation_hash
	local success, result = pcall(
		self.ClientFighterCharacter.Humanoid.LoadAnimation,
		self.ClientFighterCharacter.Humanoid,
		PreloadController:GetPreloadedAnimation("SlidingJump")
	)

	if not success then
		return
	end

	table.insert(self._cleanup, result)
	result:Play(0)
	self.ClientFighterCharacter:DisableIKArms(1, true)
	task.delay(0.18333333333333332, function()
		if _animation_hash ~= self._animation_hash or not self.ClientFighterCharacter:IsAlive() then
			return
		end

		local success2, result2 = pcall(
			self.ClientFighterCharacter.Humanoid.LoadAnimation,
			self.ClientFighterCharacter.Humanoid,
			PreloadController:GetPreloadedAnimation("SlidingJumpFall")
		)

		if success2 then
			table.insert(self._cleanup, result2)
			self._animation_track = result2
			self._animation_track:Play(0)
		end
	end)
end

function Airborne:_SetIsAirborne(isAirborne)
	self.IsAirborne = isAirborne
	self.AirborneChanged:Fire()
end

function Airborne:_Init()
	self.AirborneChanged:Connect(function()
		self:_UpdateAnimation()
		self:_UpdateEffect()
	end)
	self.ClientFighterCharacter:GetDataChangedSignal("IsFrozen"):Connect(function()
		if self.ClientFighterCharacter:Get("IsFrozen") then
			self:Cancel()
		end
	end)
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsHiddenByEmotes"):Connect(function()
		self:_UpdateEffect()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsHiddenByCutscene"):Connect(function()
		self:_UpdateEffect()
	end))

	if self.ClientFighterCharacter.ClientFighter.IsLocalPlayer then
		self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.Humanoid.StateChanged:Connect(function(_, p)
			if self._airborne_velocity and not self.ClientFighterCharacter:IsHumanoidStateAirborne(p) and tick() > self._airborne_start + 0.1 then
				self:Cancel()
			end
		end))
	else
		self.ClientFighterCharacter:GetDataChangedSignal("IsAirborne"):Connect(function()
			self:_UpdateEffect()
		end)
	end
end

return Airborne