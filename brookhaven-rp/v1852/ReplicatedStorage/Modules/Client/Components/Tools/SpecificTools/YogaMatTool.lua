local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local CustomAnimationSequence = require(ReplicatedStorage.Modules.Client.Components.Tools.Animation.CustomAnimationSequence)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = {
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true
}
local v2 = Component.new({
	Tag = "YogaMatTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v2:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self.OnAnimationNumberUpdated = self._Janitor:Add(Signal.new())
	self.tool = self.Instance
	self.currentAnimation = 1
	self._isEquipped = false
	self._cycleDebounced = false
	self._movementLocked = false
	self._humanoid = nil
	self._animationSequence = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"CustomAnimationSequence",
		CustomAnimationSequence
	)
	local currentAnimation = self.Instance:GetAttribute("CurrentAnimation")

	if typeof(currentAnimation) == "number" then
		self.currentAnimation = currentAnimation
	end

	self:_preloadToolAnimations()
end

function v2.GetCurrentAnimation(p)
	return p.currentAnimation
end

function v2:_preloadToolAnimations()
	local animations = self.tool:FindFirstChild("Animations")

	if animations == nil or not animations:IsA("Folder") then
		return
	end

	task.spawn(function()
		local animations2 = {}

		for _, animation in animations:GetChildren() do
			if not (animation:IsA("Animation") and ContentProvider:GetAssetFetchStatus(animation.AnimationId) == Enum.AssetFetchStatus.None) then
				continue
			end

			table.insert(animations2, animation)
		end

		if #animations2 == 0 then
			return
		end

		pcall(function()
			ContentProvider:PreloadAsync(animations2)
		end)
	end)
end

function v2:_setMovementEnabled(flag: boolean)
	local _humanoid = self._humanoid

	if _humanoid == nil then
		return
	end

	if flag then
		_humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
		_humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	else
		_humanoid.WalkSpeed = 0
		_humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end
end

function v2:_suppressDefaultToolAnimation(object)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopIfToolNone(object2)
		local animation = object2.Animation

		if animation == nil then
			return
		end

		local parent = animation.Parent

		if parent ~= nil and parent.Name == "toolnone" then
			object2:Stop(0)
		end
	end

	for _, v3 in object:GetPlayingAnimationTracks() do
		stopIfToolNone(v3) -- equivalent call inferred; original call site unknown
	end

	self._equipJanitor:Add(object.AnimationPlayed:Connect(stopIfToolNone))
end

function v2:_isSeated()
	local _humanoid = self._humanoid

	if _humanoid == nil or _humanoid.Parent == nil then
		return false
	end

	return _humanoid.Sit == true and _humanoid.SeatPart ~= nil
end

function v2:_isOnHorse()
	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return false
	end

	local character = localPlayer.Character
	return character ~= nil and character:GetAttribute("IsOnHorse") == true
end

function v2:_isInAllowedHumanoidState()
	local _humanoid = self._humanoid
	return _humanoid ~= nil and _humanoid.Parent ~= nil and v[_humanoid:GetState()] == true
end

function v2:_isOnNoMotorVehicle()
	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return false
	end

	local character = localPlayer.Character
	return character ~= nil and character:FindFirstChild("NoMotorVehicleModel") ~= nil
end

function v2:_isMatActive()
	local yogaMatVisualState = self.Instance:GetAttribute("YogaMatVisualState")
	local v3 = typeof(yogaMatVisualState) ~= "string" and "Stowed" or yogaMatVisualState
	local currentAnimation = self.Instance:GetAttribute("CurrentAnimation")

	if typeof(currentAnimation) ~= "number" then
		currentAnimation = self.currentAnimation
	end

	return currentAnimation ~= 1 or v3 ~= "Stowed"
end

function v2:_updateMovementLock()
	if self._isEquipped ~= true then
		return
	end

	local _isMatActive = self:_isMatActive()

	if _isMatActive == self._movementLocked then
		return
	end

	self._movementLocked = _isMatActive
	self:_setMovementEnabled(not _isMatActive)
end

function v2:_unequipToBackpackIfEquipped()
	local localPlayer = Players.LocalPlayer

	if not (localPlayer ~= nil and self.tool.Parent == localPlayer.Character) then
		return
	end

	self.tool.Parent = localPlayer.Backpack
end

function v2:_tryAutoUnequipFromRestrictions()
	if not (self._isEquipped == true and self:_isMatActive() == true) then
		return
	end

	if self:_isSeated() or self:_isOnHorse() or self:_isOnNoMotorVehicle() or self:_isInAllowedHumanoidState() ~= true then
		self:_unequipToBackpackIfEquipped()
	end
end

function v2:CycleNextAnimation()
	if self._isEquipped ~= true then
		return
	end

	local _animationSequence = self._animationSequence

	if _animationSequence == nil then
		warn("YogaMatTool: CustomAnimationSequence not found")
		return
	end

	if self:_isSeated() then
		NotificationController.Notify("Cannot use while seated!")
		return
	end

	if self:_isOnHorse() then
		NotificationController.Notify("Cannot use while on a horse!")
		return
	end

	if self:_isOnNoMotorVehicle() then
		NotificationController.Notify("Cannot use while on a vehicle!")
		return
	end

	if self:_isInAllowedHumanoidState() ~= true then
		NotificationController.Notify("Cannot use right now!")
		return
	end

	if self._cycleDebounced then
		return
	end

	self._cycleDebounced = true
	task.delay(0.5, function()
		self._cycleDebounced = false
	end)

	if EmotesController.IsPlayingEmote() then
		EmotesController.StopEmote()
	end

	_animationSequence:CycleNextAnimation()
end

function v2:_onCurrentAnimationChanged()
	local currentAnimation = self.Instance:GetAttribute("CurrentAnimation")

	if typeof(currentAnimation) ~= "number" then
		return
	end

	self.currentAnimation = currentAnimation
	self.OnAnimationNumberUpdated:Fire(currentAnimation)
	self:_updateMovementLock()
	self:_tryAutoUnequipFromRestrictions()
end

function v2:_onVisualStateChanged()
	self:_updateMovementLock()
	self:_tryAutoUnequipFromRestrictions()
end

function v2:OnEquipped()
	if self._isEquipped == true then
		return
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return
	end

	local parent = self.tool.Parent

	if parent == nil or not parent:IsA("Model") or localPlayer.Character ~= parent then
		return
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if animator == nil then
		animator = humanoid:WaitForChild("Animator", 5)
	end

	if animator == nil then
		return
	end

	self._isEquipped = true
	self._humanoid = humanoid
	self._cycleDebounced = false
	self._movementLocked = false
	self:_suppressDefaultToolAnimation(animator)
	self._equipJanitor:Add(humanoid.Died:Connect(function()
		self:OnUnequipped()
	end))
	self._equipJanitor:Add(humanoid.Seated:Connect(function(flag: boolean, _)
		if flag ~= true then
			return
		end

		self:_tryAutoUnequipFromRestrictions()
	end))
	self._equipJanitor:Add(humanoid.StateChanged:Connect(function(_, p)
		if v[p] == true then
			return
		end

		self:_tryAutoUnequipFromRestrictions()
	end))
	self._equipJanitor:Add(parent:GetAttributeChangedSignal("IsOnHorse"):Connect(function()
		self:_tryAutoUnequipFromRestrictions()
	end))
	self._equipJanitor:Add(parent.ChildAdded:Connect(function(child)
		if child.Name ~= "NoMotorVehicleModel" then
			return
		end

		self:_tryAutoUnequipFromRestrictions()
	end))
	self._equipJanitor:Add(humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if not (self._movementLocked == true and humanoid.WalkSpeed ~= 0) then
			return
		end

		self:_unequipToBackpackIfEquipped()
	end))
	self:_onCurrentAnimationChanged()
	self:_onVisualStateChanged()
	self._equipJanitor:Add(function()
		self._isEquipped = false
		self._cycleDebounced = false
		self._movementLocked = false
		self:_setMovementEnabled(true)
		self._humanoid = nil
	end)
end

function v2:OnUnequipped()
	self._isEquipped = false
	self._equipJanitor:Cleanup()
end

function v2:Start()
	self._Janitor:Add(self.tool.Equipped:Connect(function()
		self:OnEquipped()
	end))
	self._Janitor:Add(self.tool.Unequipped:Connect(function()
		self:OnUnequipped()
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("CurrentAnimation"):Connect(function()
		self:_onCurrentAnimationChanged()
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("YogaMatVisualState"):Connect(function()
		self:_onVisualStateChanged()
	end))

	if Players.LocalPlayer ~= nil and Players.LocalPlayer.Character ~= nil and self.tool.Parent == Players.LocalPlayer.Character then
		self:OnEquipped()
		return
	end

	self:_onCurrentAnimationChanged()
	self:_onVisualStateChanged()
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2