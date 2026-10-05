local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local unlockParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.UnlockParticles
local UnlockModel = {}
UnlockModel.__index = UnlockModel

function UnlockModel.new(scene)
	local self = setmetatable({}, UnlockModel)
	self.UnlockingChanged = Signal.new()
	self.Scene = scene
	self.Model = self.Scene.Model:WaitForChild("UnlockEffect")
	self.IsUnlocking = false
	self._animation_controller = self.Model:WaitForChild("AnimationController")
	self._original_cframe = self.Model:GetPivot()
	self._idle_animation_loaded = false
	self._animation_track = nil
	self._animation_hash = 0
	self:_Init()
	return self
end

function UnlockModel:StopAnimation(_)
	self:_SetIsUnlocking(false)
	self._animation_hash += 1

	if self._animation_track then
		self._animation_track:Stop(0)
	end
end

function UnlockModel:PlayAnimation()
	self:StopAnimation(true)
	self:_SetIsUnlocking(true)
	local success, result = pcall(self._PlayAnimationAsync, self)

	if not success then
		warn("Unlock animation failed, error:", result)
	end

	self:_SetIsUnlocking(false)
end

function UnlockModel:OnStateChanged()
	self:_PlayIdleAnimation()
	self:_UpdateCFrame()
	self:StopAnimation()
end

function UnlockModel:OnOpen()
	self:_PlayIdleAnimation()
end

function UnlockModel:_PlayAnimationAsync()
	self._animation_hash += 1
	local _animation_hash = self._animation_hash
	self.Model.Key.a1.Trail.Enabled = true
	Utility:CreateSound("rbxassetid://17662575024", 1.5, 1, script, true, 5)

	if not self._animation_track then
		self._animation_track = self._animation_controller:LoadAnimation(PreloadController:GetPreloadedAnimation("WeaponUnlockPlay"))
	end

	self._animation_track:Play(0)
	wait(2.25)

	if _animation_hash ~= self._animation_hash then
		return
	end

	Utility:CreateSound("rbxassetid://17662574898", 1.5, 1, script, true, 5)
	wait(0.25)

	if _animation_hash ~= self._animation_hash then
		return
	end

	self.Model.Key.a1.Trail.Enabled = false
	Utility:CreateSound("rbxassetid://17662575175", 1, 1, script, true, 5)
	Utility:PlayParticles(self.Model.ChainsHolder.Attachment)
	wait(1)

	if _animation_hash ~= self._animation_hash then
		return
	end

	Utility:CreateSound("rbxassetid://17662623697", 1.5, 1, script, true, 5)
	local boundingBox, size = self.Scene.Equipment.FloatingModel:GetBoundingBox()
	local part = Instance.new("Part")
	part.CFrame = boundingBox
	part.Size = size
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = workspace
	BetterDebris:AddItem(part, 10)

	for _, child in pairs(unlockParticles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = part
		task.delay(child:GetAttribute("EmitDelay") or 0, clone.Emit, clone, child:GetAttribute("EmitCount"))
	end
end

function UnlockModel:_PlayIdleAnimation()
	self._idle_animation_loaded = false

	for _ = 1, 3 do
		local success, result = pcall(function()
			self._animation_controller:LoadAnimation(PreloadController:GetPreloadedAnimation("WeaponUnlockIdle")):Play(0)
		end)

		if success then
			self._idle_animation_loaded = true
			break
		else
			warn("Failed to load unlock model idle, error", result)
		end
	end
end

function UnlockModel:_UpdateCFrame()
	local selectedWeapon = self.Scene.Equipment:GetSelectedWeapon()
	local _original_cframe = selectedWeapon and not PlayerDataController:GetWeaponData(selectedWeapon) and not Pages.PageSystem.CurrentPage and self._idle_animation_loaded and self._original_cframe or CFrame.identity
	self.Model:PivotTo(_original_cframe)
end

function UnlockModel:_UpdateKey()
	local localTransparencyModifier = self.IsUnlocking and 0 or 1
	self.Model.Key.LocalTransparencyModifier = localTransparencyModifier
	self.Model.Key.a1.Trail.LocalTransparencyModifier = localTransparencyModifier
	self.Model.Key.sparkle.LocalTransparencyModifier = localTransparencyModifier
end

function UnlockModel:_SetIsUnlocking(isUnlocking)
	if self.IsUnlocking == isUnlocking then
		return
	end

	self.IsUnlocking = isUnlocking
	self.UnlockingChanged:Fire()
end

function UnlockModel:_Init()
	self.UnlockingChanged:Connect(function()
		self:_UpdateKey()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateCFrame()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateCFrame()
	end)
	self:_UpdateKey()
end

return UnlockModel