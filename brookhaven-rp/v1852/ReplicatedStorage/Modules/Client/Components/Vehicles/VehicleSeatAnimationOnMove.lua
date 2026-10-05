local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSeatAnimationOnMove"
})
local VehicleRoot = require(script.Parent.VehicleRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isLocalPlayerHumanoid(occupant)
	if occupant and occupant.Parent then
		return occupant.Parent == localPlayer.Character
	end

	return false
end

function v:_stopTrack()
	if self._currentTrack then
		self._currentTrack:Stop()
		self._currentTrack = nil
	end

	self._movingDirection = 0
end

function v:_playForDirection(animator, movingDirection: number)
	local _forwardAnim = movingDirection == 1 and self._forwardAnim or movingDirection == -1 and self._backwardAnim or self._idleAnim

	if not _forwardAnim then
		return nil
	end

	self:_stopTrack()
	self._movingDirection = movingDirection
	self._currentTrack = animator:LoadAnimation(_forwardAnim)
	self._currentTrack:Play()
	return self._currentTrack
end

function v:Start()
	local instance

	if self.Instance:HasTag("VehicleSeat") then
		instance = self.Instance
	else
		local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
			self.Instance,
			"VehicleRoot",
			VehicleRoot
		)

		if not waitForAncestorComponent then
			warn("VehicleSeatAnimationOnMove:Start() - VehicleRoot not found")
			return
		end

		local instance2 = waitForAncestorComponent.Instance

		if not instance2 then
			warn("VehicleSeatAnimationOnMove:Start() - VehicleModel not found")
			return
		end

		local seats = instance2:FindFirstChild("Seats")

		if not seats then
			warn("VehicleSeatAnimationOnMove:Start() - SeatsFolder not found")
			return
		end

		instance = seats:FindFirstChild("VehicleSeat")

		if not instance then
			warn("VehicleSeatAnimationOnMove:Start() - VehicleSeat not found")
			return
		end
	end

	self._idleAnim = self.Instance:WaitForChild("AnimationIdle", 10)
	self._forwardAnim = self.Instance:WaitForChild("AnimationForward", 10)
	self._backwardAnim = self.Instance:WaitForChild("AnimationBackward", 10)

	if not (self._idleAnim or self._forwardAnim or self._backwardAnim) then
		warn("VehicleSeatAnimationOnMove:Start() - No animation instances (AnimationIdle/Forward/Backward) found on VehicleSeat")
		return
	end

	self._currentTrack = nil
	self._movingDirection = 0
	self._Janitor:Add(instance:GetPropertyChangedSignal("Throttle"):Connect(function()
		local occupant = self.Instance.Occupant

		-- equivalent call inferred; original call site unknown
		if not isLocalPlayerHumanoid(occupant) then
			return
		end

		local animator = occupant:FindFirstChild("Animator")

		if not animator then
			return
		end

		local throttle = instance.Throttle
		self:_playForDirection(animator, throttle == 1 and 1 or throttle == -1 and -1 or 0)
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = self.Instance.Occupant

		if not occupant then
			self:_stopTrack()
			return
		end

		-- equivalent call inferred; original call site unknown
		if not isLocalPlayerHumanoid(occupant) then
			return
		end

		local animator = occupant:FindFirstChild("Animator")

		if not animator then
			return
		end

		local throttle = instance.Throttle
		self:_playForDirection(animator, throttle == 1 and 1 or throttle == -1 and -1 or 0)
	end))
end

function v:Stop()
	self:_stopTrack()
	self._Janitor:Destroy()
end

return v