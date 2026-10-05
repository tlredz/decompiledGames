local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
game:GetService("Lighting")
local Players = game:GetService("Players")
local LootLibrary = require(ReplicatedStorage.Modules.LootLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ShootingRangeController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShootingRangeController)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.MobileInputs)
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Teleporting)
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Queue)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local EquipmentState = require(script:WaitForChild("EquipmentState"))
local FloatingModel = require(script:WaitForChild("FloatingModel"))
local SpinControls = require(script:WaitForChild("SpinControls"))
local Interface = require(script:WaitForChild("Interface"))
local Camera = require(script:WaitForChild("Camera"))
local Scene = require(script:WaitForChild("Scene"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Opened = Signal.new()
	self.SelectedWeaponChanged = Signal.new()
	self.CareerPageOpened = Signal.new()
	self.CustomizingChanged = Signal.new()
	self.CustomizingStateChanged = Signal.new()
	self.CosmeticSearchChanged = Signal.new()
	self.UnlockingChanged = Signal.new()
	self.FinishedOpenEffect = Signal.new()
	self.CharmAttachmentVisibleChanged = Signal.new()
	self.Frame = UILibrary:GetTo("MainFrame", "Equipment")
	self.IsOpen = false
	self.EquipmentState = EquipmentState.new(self)
	self.Camera = Camera.new(self)
	self.Scene = Scene.new(self)
	self.FloatingModel = FloatingModel.new(self)
	self.SpinControls = SpinControls.new(self)
	self.Interface = Interface.new(self)
	self._is_trying_weapon = false
	self._from_shop = false
	self._was_chat_active = true
	self._open_hash = 0
	self._on_state_changed_queued = false
	self._on_customizing_state_changed_queued = false
	self:_Init()
	return self
end

function class:IsCareerPageOpen()
	return self.EquipmentState.IsCareerPageOpen
end

function class:IsOpenEffectDone(...)
	return self.Camera:IsOpenEffectDone(...)
end

function class.IsUnlocking(p)
	return p.Scene.UnlockModel.IsUnlocking
end

function class:IsCustomizing()
	return self.EquipmentState.CustomizingType ~= nil
end

function class:GetStateID(p)
	self:IsCustomizing()
	local isCareerPageOpen = self:IsCareerPageOpen()
	local selectedWeapon = self:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)

	if isCareerPageOpen then
		return "FAKE_CAREER_STATE"
	end

	if selectedWeapon then
		return selectedWeapon .. (not p and "" or tostring(weaponData ~= nil) or "")
	end

	return "nil"
end

function class:GetSelectedWeapon()
	return self.EquipmentState.SelectedWeapon
end

function class.GetSelectedCosmetic(p)
	return p.EquipmentState.SelectedCosmetic
end

function class.GetCosmeticSearchQuery(p)
	return p.EquipmentState.CosmeticSearchQuery
end

function class.GetCustomizingType(p)
	return p.EquipmentState.CustomizingType
end

function class:SetCosmeticSearchQuery(...)
	return self.EquipmentState:SetCosmeticSearchQuery(...)
end

function class:SelectCosmetic(...)
	return self.EquipmentState:SelectCosmetic(...)
end

function class:SelectWeapon(...)
	return self.EquipmentState:SelectWeapon(...)
end

function class:OpenCareerPage(...)
	return self.EquipmentState:OpenCareerPage(...)
end

function class:StartCustomizing(...)
	return self.EquipmentState:StartCustomizing(...)
end

function class:FavoriteWeapon()
	local selectedWeapon = self:GetSelectedWeapon()

	if not selectedWeapon then
		return
	end

	ReplicatedStorage.Remotes.Data.FavoriteWeapon:FireServer(selectedWeapon)
end

function class:LevelUpWeapon()
	local selectedWeapon = self:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)

	if not weaponData then
		return
	end

	local costToLevelUp = LootLibrary:GetCostToLevelUp(weaponData.Level, weaponData.XP)

	if PlayerDataController:Get("WeaponKeys") < costToLevelUp then
		Pages.PageSystem:OpenPage("Shop", true)
		Pages.PageSystem:WaitForPage("Shop"):SetPage("Currency")
		MonetizationController:PromptCurrencyBundlePurchase(costToLevelUp, "WeaponKeys")
	else
		Utility:CreateSound("rbxassetid://18242015218", 1, 1, script, true, 6)
		ReplicatedStorage.Remotes.Data.LevelUpWeapon:FireServer(selectedWeapon)
	end
end

function class:UnlockWeapon()
	local selectedWeapon = self:GetSelectedWeapon()
	local weaponKeyPriceInfo, v, v2, _ = ShopLibrary:GetWeaponKeyPriceInfo(
		selectedWeapon,
		PlayerDataController:Get("UnlockTokens"),
		PlayerDataController:Get("FreeWeaponUnlockCheck")
	)

	if not (v2 or ShopLibrary:IsWeaponReleased(selectedWeapon)) then
		return
	end

	if PlayerDataController:Get("WeaponKeys") < weaponKeyPriceInfo and not v then
		Pages.PageSystem:OpenPage("Shop", true)
		Pages.PageSystem:WaitForPage("Shop"):SetPage("Currency")
		MonetizationController:PromptCurrencyBundlePurchase(weaponKeyPriceInfo, "WeaponKeys")
	else
		self.Scene.UnlockModel:PlayAnimation()
		ReplicatedStorage.Remotes.Data.UnlockWeapon:FireServer(selectedWeapon)
	end
end

function class:TryWeapon()
	local selectedWeapon = self:GetSelectedWeapon()

	if not selectedWeapon then
		return
	end

	self._is_trying_weapon = true
	self._from_shop = false
	self:Close(nil, true)
	ShootingRangeController:Enter(selectedWeapon)
end

function class:Open(from_shop, p)
	if not p and (CameraController:GetPublicState() or self.IsOpen) then
		return
	end

	self._open_hash += 1
	self:Close(true)
	self._renderstep_connection = RunService.RenderStepped:Connect(function(dt)
		self:_Update(dt)
	end)
	self._from_shop = from_shop
	self._was_chat_active = StarterGui:GetCore("ChatActive")
	GamepadService:EnableGamepadCursor(self.Frame)
	pcall(StarterGui.SetCore, StarterGui, "ChatActive", false)
	self.IsOpen = true
	self.Opened:Fire()
end

function class:Close(p, p2)
	if not (self.IsOpen or p) then
		return
	end

	self._open_hash += 1

	if p2 then
		local _open_hash = self._open_hash
		self.Camera:CloseEffect()

		if _open_hash ~= self._open_hash then
			return
		end
	end

	if self._renderstep_connection then
		self._renderstep_connection:Disconnect()
		self._renderstep_connection = nil
	end

	GamepadService:DisableGamepadCursor()
	pcall(StarterGui.SetCore, StarterGui, "ChatActive", self._was_chat_active)
	self.IsOpen = false
	self.Opened:Fire()

	if self._from_shop then
		self._from_shop = false
		Pages.PageSystem:OpenPage("Shop", true)
	end
end

function class:CloseRequest()
	if self:IsCustomizing() then
		self:StartCustomizing(nil)
	elseif self:IsOpenEffectDone() then
		self:Close(nil, true)
	end
end

function class:_OnCustomizingStateChanged(...)
	if self._on_customizing_state_changed_queued then
		return
	end

	self._on_customizing_state_changed_queued = true
	task.defer(function(...)
		self._on_customizing_state_changed_queued = false
		self.Interface:OnCustomizingStateChanged(...)
		self.FloatingModel:OnCustomizingStateChanged(...)
		self.Scene:OnCustomizingStateChanged(...)
	end, ...)
end

function class:_OnStateChanged(...)
	if self._on_state_changed_queued then
		return
	end

	self._on_state_changed_queued = true
	task.defer(function(...)
		self._on_state_changed_queued = false
		self.Scene:OnStateChanged(...)
		self.Camera:OnStateChanged(...)
		self.SpinControls:OnStateChanged(...)
		self.FloatingModel:OnStateChanged(...)
		self.Interface:OnStateChanged(...)
	end, ...)
end

function class:_OnOpen(...)
	self.EquipmentState:OnOpen(...)
	self.Camera:OnOpen(...)
	self.Scene:OnOpen(...)
	self.SpinControls:OnOpen(...)
	self.FloatingModel:OnOpen(...)
	self.Interface:OnOpen(...)
end

function class:_Update(...)
	self.Camera:Update(...)
	self.SpinControls:Update(...)
	self.FloatingModel:Update(...)
	self.Interface:Update(...)
end

function class:_UpdateVisibility()
	self.Frame.Visible = self.IsOpen and not PlayerDataController:GetSetting("Hide HUD")
end

function class:_CheckInterruption()
	if Queue:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled then
		self:Close()
	end
end

function class:_HookLocalFighter()
	local v = FighterController:WaitForLocalFighter()
	v:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		if v:Get("IsInShootingRange") then
			self:Close()
		elseif self._is_trying_weapon and not v:Get("IsInShootingRange") then
			self._is_trying_weapon = false
			self:Open(nil, true)
		end
	end)
	v:GetDataChangedSignal("IsInDuel"):Connect(function()
		if v:Get("IsInDuel") then
			self:Close()
		end
	end)
end

function class:_Init()
	self.Opened:Connect(function(...)
		self:_UpdateVisibility()
		self:_OnOpen(...)
	end)
	self.SelectedWeaponChanged:Connect(function(...)
		self:_OnStateChanged(...)
	end)
	self.CareerPageOpened:Connect(function(...)
		self:_OnStateChanged(...)
	end)
	self.CustomizingChanged:Connect(function(...)
		self:_OnStateChanged(...)
		self:_OnCustomizingStateChanged()
	end)
	self.CustomizingStateChanged:Connect(function(...)
		self:_OnCustomizingStateChanged(...)
	end)
	self.EquipmentState.SelectedWeaponChanged:Connect(function(...)
		self.SelectedWeaponChanged:Fire(...)
	end)
	self.EquipmentState.CareerPageOpened:Connect(function(...)
		self.CareerPageOpened:Fire(...)
	end)
	self.EquipmentState.CustomizingChanged:Connect(function(...)
		self.CustomizingChanged:Fire(...)
	end)
	self.EquipmentState.CustomizingStateChanged:Connect(function(...)
		self.CustomizingStateChanged:Fire(...)
	end)
	self.EquipmentState.CosmeticSearchChanged:Connect(function(...)
		self.CosmeticSearchChanged:Fire(...)
	end)
	self.Scene.UnlockModel.UnlockingChanged:Connect(function(...)
		self.UnlockingChanged:Fire(...)
	end)
	self.Camera.FinishedOpenEffect:Connect(function(...)
		self.FinishedOpenEffect:Fire(...)
	end)
	self.FloatingModel.CharmAttachmentVisibleChanged:Connect(function(...)
		self.CharmAttachmentVisibleChanged:Fire(...)
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_CheckInterruption()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_CheckInterruption()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_CheckInterruption()
	end)
	PlayerDataController:GetSettingChangedSignal("Hide HUD"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:Close()
	self:_UpdateVisibility()
	task.spawn(self._HookLocalFighter, self)
end

return class._new()