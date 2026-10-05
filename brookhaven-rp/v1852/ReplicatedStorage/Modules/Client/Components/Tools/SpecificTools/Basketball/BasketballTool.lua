local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "BasketballTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

-- equivalent calls inferred from this helper; original call sites unknown
local function isAirborneState(p)
	return p == Enum.HumanoidStateType.Jumping or p == Enum.HumanoidStateType.Freefall or p == Enum.HumanoidStateType.FallingDown
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self.holdTrack = nil
	self.dribbleTrack = nil
	self.shootTrack = nil
	self.humanoid = nil
	self.isThrowing = false
	self.isAirborne = false
end

function v:PlayHoldAnimation()
	if self.shootTrack ~= nil and self.shootTrack.IsPlaying then
		self.shootTrack:Stop(0.05)
	end

	if self.dribbleTrack ~= nil and self.dribbleTrack.IsPlaying then
		self.dribbleTrack:Stop(0.1)
	end

	if self.holdTrack ~= nil and self.holdTrack.IsPlaying == false then
		self.holdTrack:Play(0.1, 1, 1)
	end
end

function v:PlayDribbleAnimation()
	if self.shootTrack ~= nil and self.shootTrack.IsPlaying then
		self.shootTrack:Stop(0.05)
	end

	if self.holdTrack ~= nil and self.holdTrack.IsPlaying then
		self.holdTrack:Stop(0.1)
	end

	if self.dribbleTrack ~= nil and self.dribbleTrack.IsPlaying == false then
		self.dribbleTrack:Play(0.1, 1, 1)
	end

	self:UpdateDribblePlaybackSpeed()
end

function v:PlayShootAnimation()
	if self.holdTrack ~= nil and self.holdTrack.IsPlaying then
		self.holdTrack:Stop(0.1)
	end

	if self.dribbleTrack ~= nil and self.dribbleTrack.IsPlaying then
		self.dribbleTrack:Stop(0.1)
	end

	if self.shootTrack ~= nil then
		self.shootTrack:Play(0.05, 1, 1)
	end
end

function v:UpdateAnimationState()
	if self.humanoid == nil then
		return
	end

	if self.isThrowing then
		if self.shootTrack ~= nil and self.shootTrack.IsPlaying then
			return
		end

		self:PlayHoldAnimation()
	elseif self.isAirborne then
		self:PlayHoldAnimation()
	elseif self.humanoid.MoveDirection.Magnitude > 0.05 then
		self:PlayDribbleAnimation()
	else
		self:PlayHoldAnimation()
	end
end

function v:TransitionToAirHold()
	if self.dribbleTrack ~= nil and self.dribbleTrack.IsPlaying then
		self.dribbleTrack:Stop(0.05)
	end

	if self.holdTrack ~= nil then
		self.holdTrack.TimePosition = 0

		if self.holdTrack.IsPlaying == false then
			self.holdTrack:Play(0.05, 1, 1)
		end
	end
end

function v:UpdateDribblePlaybackSpeed()
	if self.dribbleTrack == nil then
		return
	end

	if self.humanoid == nil or not (self.humanoid.WalkSpeed >= 20) then
		self.dribbleTrack:AdjustSpeed(1)
	else
		self.dribbleTrack:AdjustSpeed(1.2)
	end
end

function v:GetShootReleaseDelay()
	if self.humanoid == nil then
		return 0
	end

	if self.humanoid.MoveDirection.Magnitude > 0.05 then
		return 0.08
	end

	return 0
end

function v:OnEquip()
	self._equipJanitor:Cleanup()
	self.isThrowing = false
	local instance = self.Instance
	local parent = instance.Parent

	if parent == nil then
		return
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	self.humanoid = humanoid
	local holdAnim = instance:FindFirstChild("HoldAnim")

	if holdAnim ~= nil and holdAnim:IsA("Animation") then
		self.holdTrack = humanoid:LoadAnimation(holdAnim)
	end

	local idle1Anim = instance:FindFirstChild("Idle1Anim")

	if idle1Anim ~= nil and idle1Anim:IsA("Animation") then
		self.dribbleTrack = humanoid:LoadAnimation(idle1Anim)
	end

	local shootAnim = instance:FindFirstChild("ShootAnim")

	if shootAnim ~= nil and shootAnim:IsA("Animation") then
		self.shootTrack = humanoid:LoadAnimation(shootAnim)
	end

	local mouse = Players.LocalPlayer:GetMouse()
	self._equipJanitor:Add(instance.Activated:Connect(function()
		if self.isThrowing or instance.Enabled ~= true then
			return
		end

		self.isThrowing = true
		self:PlayShootAnimation()
		local position = mouse.Hit.Position
		local direction = mouse.UnitRay.Direction
		local shootReleaseDelay = self:GetShootReleaseDelay()

		if self.shootTrack == nil then
			self:PlayHoldAnimation()
		end

		if shootReleaseDelay <= 0 then
			if self.humanoid ~= nil and self.isThrowing == true then
				Remotes.fireServerComponent(self.Instance, "ThrowBasketball", position, direction)
			end
		else
			task.delay(shootReleaseDelay, function()
				if not (self.humanoid ~= nil and self.isThrowing == true) then
					return
				end

				Remotes.fireServerComponent(self.Instance, "ThrowBasketball", position, direction)
			end)
		end

		task.delay(2, function()
			self.isThrowing = false
			self:UpdateAnimationState()
		end)
	end))
	self._equipJanitor:Add(humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		self:UpdateAnimationState()
	end))
	self._equipJanitor:Add(humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		self:UpdateDribblePlaybackSpeed()
	end))
	self._equipJanitor:Add(humanoid.StateChanged:Connect(function(_, p)
		local airborneState = isAirborneState(p) -- equivalent call inferred; original call site unknown

		if airborneState == self.isAirborne then
			return
		end

		self.isAirborne = airborneState

		if not self.isAirborne then
			self:UpdateAnimationState()
		elseif self.isThrowing ~= true then
			self:TransitionToAirHold()
		end
	end))
	self:UpdateAnimationState()
end

function v:OnUnequip()
	self._equipJanitor:Cleanup()
	self.isThrowing = false
	self.isAirborne = false

	if self.holdTrack ~= nil then
		self.holdTrack:Stop()
		self.holdTrack = nil
	end

	if self.dribbleTrack ~= nil then
		self.dribbleTrack:Stop()
		self.dribbleTrack = nil
	end

	if self.shootTrack ~= nil then
		self.shootTrack:Stop()
		self.shootTrack = nil
	end

	self.humanoid = nil
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:OnEquip()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self:OnUnequip()
	end))
end

function v:Stop()
	self:OnUnequip()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v