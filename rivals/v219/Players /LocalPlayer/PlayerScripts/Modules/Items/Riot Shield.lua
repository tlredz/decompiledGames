local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CosmeticLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local StaticViewModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel.StaticViewModel)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self.UnequippedViewModel = nil
	self._shield_attached = false
	self._update_shield_queued = false
	self._is_broken = self:Get("Ammo") <= 0
	self:_Init()
	return self
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "AbsorbedHit" then
		Melee.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	object2.ViewModel:Impulse(createVector(0, -20, 0), 1, nil, true)
	object2.ViewModel:AbsorbedHit()
end

function object.Destroy(p)
	p.UnequippedViewModel:Destroy()
	Melee.Destroy(p)
end

function object:_CheckBroken()
	local is_broken = self:Get("Ammo") <= 0

	if self._is_broken == is_broken then
		return
	end

	self._is_broken = is_broken
	self:_UpdateUnequippedViewModel()
	self.ViewModel:ChangeEquipAnimation(self._is_broken and self.ViewModel.Info.Animations.EmptyEquip and "EmptyEquip" or "Equip")
	self.ViewModel:ChangeInspectAnimation(self._is_broken and self.ViewModel.Info.Animations.EmptyInspect and "EmptyInspect" or "Inspect")
	self.ViewModel:ChangeIdleAnimation(self._is_broken and self.ViewModel.Info.Animations.EmptyIdle and "EmptyIdle" or "Idle")
	self.ViewModel:ChangeSprintAnimation(self._is_broken and self.ViewModel.Info.Animations.EmptySprint and "EmptySprint" or "Sprint")
	local viewModel = self.ViewModel
	local v2

	if self._is_broken and self.ViewModel.Info.Animations.EmptyIdle then
		v2 = CFrame.identity
	end

	viewModel:OverrideRootPartOffset(v2)

	if not self._is_broken then
		return
	end

	self.ViewModel:ShieldBroken()
end

function object:_WaitForUnequippedViewModelRoot()
	return self.ClientFighter.Entity and self.ClientFighter.Entity.Model and self.ClientFighter.Entity.Model:WaitForChild("UpperTorso")
end

function object:_UpdateUnequippedViewModel()
	if self._shield_attached and not self._update_shield_queued then
		self._update_shield_queued = true
		task.delay(0.1, function()
			self._update_shield_queued = false

			if self._destroyed then
				return
			end

			local v = not (self.IsEquipped or self.ClientFighter:IsActuallyFirstPerson() or self.ClientFighter:Get("IsHiddenByEmotes") or self._is_broken)
			local v2 = v and self:_WaitForUnequippedViewModelRoot()

			if v2 then
				self.UnequippedViewModel:BreakWeld(v2)
				self.UnequippedViewModel:PivotTo(v2.CFrame, "_riot_shield_back")
				self.UnequippedViewModel:WeldTo(v2)
			end

			local unequippedViewModel = self.UnequippedViewModel
			local v3

			if v then
				v3 = self.ViewModel:GetWrap()
			end

			unequippedViewModel:SetWrap(v3)
			local unequippedViewModel2 = self.UnequippedViewModel
			local v4

			if v then
				v4 = self.ClientFighter.Entity and self.ClientFighter.Entity.Model or nil
			end

			unequippedViewModel2:SetParent(v4)
		end)
	end
end

function object:_AttachUneqippedViewModel()
	if self._shield_attached then
		return
	end

	local _WaitForUnequippedViewModelRoot = self:_WaitForUnequippedViewModelRoot()

	if not _WaitForUnequippedViewModelRoot or self._shield_attached or not self.ClientFighter:IsAlive() then
		return
	end

	self._shield_attached = true
	self.UnequippedViewModel:PivotTo(_WaitForUnequippedViewModelRoot.CFrame, "_riot_shield_back")
	self.UnequippedViewModel:WeldTo(_WaitForUnequippedViewModelRoot)
	self:_UpdateUnequippedViewModel()
end

function object:_Setup()
	self.UnequippedViewModel = StaticViewModel.new(self.ViewModel.Name)
	self.UnequippedViewModel:SetArchivable(false)
end

function object:_Init()
	self.EquippedChanged:Connect(function()
		self:_UpdateUnequippedViewModel()
	end)
	self:GetDataChangedSignal("Ammo"):Connect(function()
		self:_CheckBroken()
	end)
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_UpdateUnequippedViewModel()
	end))
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsHiddenByEmotes"):Connect(function()
		self:_UpdateUnequippedViewModel()
	end))
	table.insert(self._connections, self.ClientFighter.EntityAdded:Connect(function()
		self:_AttachUneqippedViewModel()
	end))
	table.insert(self._connections, self.ClientFighter.HealthChanged:Connect(function()
		self:_AttachUneqippedViewModel()
	end))
	table.insert(self._connections, PlayerDataController:GetSettingChangedSignal("Wraps Disabled"):Connect(function()
		self:_UpdateUnequippedViewModel()
	end))
	table.insert(self._connections, CameraController.POVStateChanged:Connect(function()
		self:_UpdateUnequippedViewModel()
	end))
	self:_Setup()
	task.spawn(self._CheckBroken, self)
	task.defer(self._AttachUneqippedViewModel, self)
end

return object