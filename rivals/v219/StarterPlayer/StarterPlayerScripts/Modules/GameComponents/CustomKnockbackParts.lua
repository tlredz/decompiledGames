local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._objects = {}
	self._next_update = 0
	self:_Init()
	return self
end

function class:Update(_)
	if tick() < self._next_update then
		return
	end

	self._next_update = tick() + 0.25
	local humanoid = FighterController.LocalFighter and FighterController.LocalFighter.Entity and FighterController.LocalFighter.Entity.Humanoid
	local rootPart = humanoid and humanoid.RootPart

	if not rootPart then
		return
	end

	for k, _object in pairs(self._objects) do
		if _object.MathHitboxCheckEnabled and Utility:IsWithinPart(k, rootPart.Position, createVector(2, 2, 2)) then
			task.spawn(_object.TouchedCallback, rootPart, true)
		end
	end
end

function class:_ObjectAdded(instance)
	local v = {
		Connections = {},
		Cooldowns = {},
		TouchedCallback = nil,
		MathHitboxCheckEnabled = instance:GetAttribute("MathHitboxCheckEnabled")
	}

	function v.TouchedCallback(p2, p3)
		local assemblyRootPart = p2.AssemblyRootPart or p2

		if p2.Parent ~= Players.LocalPlayer.Character or tick() < (v.Cooldowns[assemblyRootPart] or 0) or not (FighterController.LocalFighter and FighterController.LocalFighter:IsAlive()) then
			return
		end

		local velocity = instance:GetAttribute("Velocity")
		local localTo = instance:GetAttribute("LocalTo")
		local minimumYVelocity = instance:GetAttribute("MinimumYVelocity")

		if localTo then
			velocity = instance.CFrame[localTo] * velocity
		end

		if minimumYVelocity then
			local X = velocity.X

			if not (math.abs(velocity.Y) < 0.001) then
				minimumYVelocity = math.max(minimumYVelocity, (math.abs(velocity.Y))) * math.sign(velocity.Y)
			end

			velocity = Vector3.new(X, minimumYVelocity, velocity.Z)
		end

		local hasToBeInFront = instance:GetAttribute("HasToBeInFront")
		local v2

		if typeof(hasToBeInFront) == "CFrame" then
			v2 = hasToBeInFront
		else
			v2 = CFrame.identity
		end

		if not p3 and hasToBeInFront and Utility:AngleBetweenVectors(
			(assemblyRootPart.Position - (instance.CFrame * v2).Position).Unit,
			velocity.Unit
		) > 1.5707963267948966 then
			return
		end

		v.Cooldowns[assemblyRootPart] = tick() + (instance:GetAttribute("Cooldown") or 0.5)
		local velocity2 = FighterController.LocalFighter.Entity.RootPart.Velocity
		local walkSpeed = FighterController.LocalFighter.Entity.Humanoid.WalkSpeed
		local v3 = Utility:AngleBetweenVectors(velocity, createVector(0, 1, 0)) < 0.08726646259971647 or Utility:AngleBetweenVectors(
			velocity,
			createVector(-0, -1, -0)
		) < 0.08726646259971647
		local springSpeed = instance:GetAttribute("SpringSpeed") or 12
		local v4

		if v3 then
			v4 = velocity2.Unit * math.max((velocity2 * (createVector(1, 0, 1)).Unit).Magnitude, walkSpeed)
		end

		if not v4 or v4 ~= v4 or not (v4.Magnitude > 0.001 and v4) then
			v4 = nil
		end

		if instance:GetAttribute("Override") then
			FighterController.LocalFighter.Entity:AirborneCancel()
		end

		FighterController.LocalFighter.Entity:AirborneTrigger(velocity, springSpeed, nil, v4)
		local soundID = instance:GetAttribute("SoundID")
		local soundVolume = instance:GetAttribute("SoundVolume") or 1

		if soundID then
			Utility:CreateSound(soundID, 1 * soundVolume, 1, script, true, 10)
		else
			Utility:CreateSound("rbxassetid://17835965717", 1 * soundVolume, 1.25, script, true, 5)
		end
	end

	local function from_touched(p2)
		v.TouchedCallback(p2)
	end

	table.insert(v.Connections, instance.Touched:Connect(from_touched))
	table.insert(v.Connections, instance.TouchEnded:Connect(from_touched))
	self._objects[instance] = v
end

function class:_ObjectRemoved(p2)
	local _object = self._objects[p2]

	if not _object then
		return
	end

	for _, connection in pairs(_object.Connections) do
		connection:Disconnect()
	end

	self._objects[p2] = nil
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("CustomKnockbackPart"):Connect(function(p)
		self:_ObjectAdded(p)
	end)
	CollectionService:GetInstanceRemovedSignal("CustomKnockbackPart"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("CustomKnockbackPart")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return class._new()