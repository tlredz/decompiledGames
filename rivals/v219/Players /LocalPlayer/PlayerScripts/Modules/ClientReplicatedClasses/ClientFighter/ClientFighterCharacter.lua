local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ClientHumanoidEntity = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity)
local ChatBubbleMover = require(script:WaitForChild("ChatBubbleMover"))
local CustomNametag = require(script:WaitForChild("CustomNametag"))
local Animations = require(script:WaitForChild("Animations"))
local Flashlight = require(script:WaitForChild("Flashlight"))
local Visibility = require(script:WaitForChild("Visibility"))
local Airborne = require(script:WaitForChild("Airborne"))
local Gameplay = require(script:WaitForChild("Gameplay"))
local Snowball = require(script:WaitForChild("Snowball"))
local Visuals = require(script:WaitForChild("Visuals"))
local Avatar = require(script:WaitForChild("Avatar"))
local Boosts = require(script:WaitForChild("Boosts"))
local Sounds = require(script:WaitForChild("Sounds"))
local Joints = require(script:WaitForChild("Joints"))
local State = require(script:WaitForChild("State"))
local Arms = require(script:WaitForChild("Arms"))
local object = setmetatable({}, ClientHumanoidEntity)
object.__index = object

function object.new(p, clientFighter)
	local object2 = setmetatable(ClientHumanoidEntity.new(p), object)
	object2.EnteredWorld = Signal.new()
	object2.BoostsChanged = Signal.new()
	object2.AirborneChanged = Signal.new()
	object2.RedirectSliding = Signal.new()
	object2.ClientFighter = clientFighter
	object2.Player = p.Player
	object2.Head = nil
	object2.State = State.new(object2)
	object2.ChatBubbleMover = ChatBubbleMover.new(object2)
	object2.CustomNametag = CustomNametag.new(object2)
	object2.Animations = Animations.new(object2)
	object2.Flashlight = Flashlight.new(object2)
	object2.Visibility = Visibility.new(object2)
	object2.Airborne = Airborne.new(object2)
	object2.Gameplay = Gameplay.new(object2)
	object2.Snowball = Snowball.new(object2)
	object2.Visuals = Visuals.new(object2)
	object2.Avatar = Avatar.new(object2)
	object2.Boosts = Boosts.new(object2)
	object2.Sounds = Sounds.new(object2)
	object2.Joints = Joints.new(object2)
	object2.Arms = Arms.new(object2)
	object2._destroyed = false
	object2._is_in_world = false
	object2:_Init()
	return object2
end

function object.IsRendered(p)
	return ClientHumanoidEntity.IsRendered(p) and not p.ClientFighter:Get("IsHiddenByEmotes")
end

function object.IsAlive(p, ...)
	return p.State:IsAliveCached(...)
end

function object.IsGrounded(p, ...)
	return p.State:IsGroundedCached(...)
end

function object.IsAirborne(p, ...)
	return p.Airborne:IsActive(...)
end

function object:GetBoostByName(...)
	return self.Boosts:GetBoostByName(...)
end

function object:GetBoost(...)
	return self.Boosts:GetBoost(...)
end

function object:GetFOVOffset(...)
	return self.Gameplay:GetFOVOffset(...)
end

function object:IsInWorld()
	return self._is_in_world
end

function object.GetClampedVelocity(p)
	if p.RootPart then
		return p.RootPart.Velocity.Magnitude <= 0.01 and p.RootPart.Velocity or p.RootPart.Velocity.Unit * math.clamp(
			p.RootPart.Velocity.Magnitude,
			0,
			CONSTANTS.BASE_WALKSPEED * 2.5
		)
	end

	return createVector(0, 0, 0)
end

function object.GetFloor(p, p2)
	local v = p2 or 3.5 * p.RootPart.Size.Z
	local raycastResult = Utility:Raycast(
		p.RootPart.Position,
		p.RootPart.Position - createVector(0, 1, 0),
		v,
		p.ClientFighter:GetRaycastWhitelist(),
		Enum.RaycastFilterType.Include
	)
	return raycastResult.Instance, raycastResult
end

function object:GetArmsData()
	return Utility:GetArmsData(self.Model)
end

function object:WaitUntilIsInWorld()
	if not self._is_in_world then
		self.EnteredWorld:Wait()
	end
end

function object:HardDash(...)
	return self.Gameplay:HardDash(...)
end

function object:WarpTo(...)
	return self.Gameplay:WarpTo(...)
end

function object:SetRedFigureMode(...)
	return self.Visuals:SetRedFigureMode(...)
end

function object.AirborneRedirect(p, ...)
	return p.Airborne:Redirect(...)
end

function object.AirborneTrigger(p, ...)
	return p.Airborne:Trigger(...)
end

function object.AirborneCancel(p, ...)
	return p.Airborne:Cancel(...)
end

function object:SetHitboxesVisible(...)
	return self.Visibility:SetHitboxesVisible(...)
end

function object:CloneModel(...)
	return self.Visibility:CloneModel(...)
end

function object:SetTranslucent(...)
	return self.Visibility:SetTranslucent(...)
end

function object:SetBoost(...)
	return self.Boosts:SetBoost(...)
end

function object:RemoveBoost(...)
	return self.Boosts:RemoveBoost(...)
end

function object:SetIKControlTargetItem(...)
	return self.Arms:SetIKControlTargetItem(...)
end

function object:DisableIKArms(...)
	return self.Arms:DisableIKArms(...)
end

function object:PlaySlidingAnimationAsync(...)
	return self.Animations:PlaySlidingAnimationAsync(...)
end

function object:StopSlidingAnimation(...)
	return self.Animations:StopSlidingAnimation(...)
end

function object:AddConnection(p2)
	table.insert(self._connections, p2)
end

function object:Update(p, p2)
	self.State:Update(p, p2)
	self.Sounds:Update(p, p2)
	self.ChatBubbleMover:Update(p, p2)
	self.CustomNametag:Update(p, p2)
	self.Animations:Update(p, p2)
	self.Flashlight:Update(p, p2)
	self.Airborne:Update(p, p2)
	self.Snowball:Update(p, p2)
	self.Visuals:Update(p, p2)
	self.Boosts:Update(p, p2)
	self.Joints:Update(p, p2)
	self.Arms:Update(p, p2)
end

function object:ReplicateFromServer(p, ...)
	if p == "HurtEffect" then
		if not self:IsRendered() then
			return
		end

		self.Visuals:HurtEffect(...)
		self:_HurtEffect(...)
	elseif p == "HealEffect" then
		if not self:IsRendered() then
			return
		end

		if self.ClientFighter.FighterInterface then
			self.ClientFighter.FighterInterface:HealEffect(...)
		end
	elseif p == "BlindedEffect" then
		if self:IsRendered() and not self.ClientFighter:Get("IsSpectating") then
			self.Visuals:BlindedEffect(...)
		end
	elseif p == "KnockbackEffect" then
		self.Airborne:FromServer(...)
	elseif p == "CancelKnockbackEffect" then
		self.Airborne:Cancel(...)
		self.ClientFighter.StopSliding:Fire()
	elseif p == "SetBoost" then
		self:SetBoost(...)
	elseif p == "ThrowSnowball" then
		self.Snowball:ThrowSnowball(...)
	elseif p == "WarpTo" then
		self:WarpTo(...)
	else
		ClientHumanoidEntity.ReplicateFromServer(self, p, ...)
	end
end

function object:Destroy()
	self._destroyed = true
	self.EnteredWorld:Destroy()
	self.BoostsChanged:Destroy()
	self.AirborneChanged:Destroy()
	self.RedirectSliding:Destroy()
	self.State:Destroy()
	self.ChatBubbleMover:Destroy()
	self.CustomNametag:Destroy()
	self.Animations:Destroy()
	self.Flashlight:Destroy()
	self.Visibility:Destroy()
	self.Airborne:Destroy()
	self.Gameplay:Destroy()
	self.Snowball:Destroy()
	self.Visuals:Destroy()
	self.Avatar:Destroy()
	self.Boosts:Destroy()
	self.Sounds:Destroy()
	self.Joints:Destroy()
	self.Arms:Destroy()
	ClientHumanoidEntity.Destroy(self)
end

function object:_SetupAsync()
	while not self.Model:IsDescendantOf(workspace) do
		self.Model.AncestryChanged:Wait()
	end

	if self._destroyed then
		return
	end

	self.Head = self.Model:WaitForChild("Head")

	if self._destroyed then
		return
	end

	self._is_in_world = true
	self.EnteredWorld:Fire()
end

function object:_Init()
	self.Boosts.BoostsChanged:Connect(function(...)
		self.BoostsChanged:Fire(...)
	end)
	self.Airborne.AirborneChanged:Connect(function(...)
		self.AirborneChanged:Fire(...)
	end)
	self.Gameplay.RedirectSliding:Connect(function(...)
		self.RedirectSliding:Fire(...)
	end)
	task.spawn(self._SetupAsync, self)
end

return object