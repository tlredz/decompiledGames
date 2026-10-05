local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SoundLibrary = require(ReplicatedStorage.Modules.SoundLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local StaticCharacterModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel.StaticCharacterModel)
local StaticViewModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel.StaticViewModel)
local cframe = CFrame.new(0, 0, 30)
local v = CFrame.new(0, -6, -6) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(0.17453292519943295, 0, 0)
local v2 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 2.356194490192345, 0) * CFrame.Angles(0.3490658503988659, 0, 0)
local v3 = CFrame.new(0, -10, -10) * CFrame.Angles(0, 2.356194490192345, 0) * CFrame.Angles(-0.7853981633974483, 0, 0)
local v4 = CFrame.new(0, 0, -10) * CFrame.Angles(0, 3.490658503988659, 0)
local FloatingModel = {}
FloatingModel.__index = FloatingModel

function FloatingModel.new(equipment)
	local self = setmetatable({}, FloatingModel)
	self.CharmAttachmentVisibleChanged = Signal.new()
	self.Equipment = equipment
	self._last_generate_state = nil
	self._last_offset_state = nil
	self._static_viewmodel = nil
	self._static_charactermodel = nil
	self._last_equip_sound = nil
	self._offset_alpha_spring = Spring.new(1, 0.875, 10)
	self:_Init()
	return self
end

function FloatingModel:GetBoundingBox()
	if self._static_viewmodel then
		return self._static_viewmodel:GetBoundingBox()
	end
end

function FloatingModel:GetCharmPivotAttachment()
	return self._static_viewmodel and self._static_viewmodel:GetCharmPivotAttachment()
end

function FloatingModel:Update(p)
	self:_UpdateStaticModel(p, self._static_viewmodel, v, v2)
	self:_UpdateStaticModel(p, self._static_charactermodel, v3, v4)
end

function FloatingModel:OnOpen()
	self:_Generate()
end

function FloatingModel:OnCustomizingStateChanged()
	self:_Generate()
	self:_UpdateViewModel()
end

function FloatingModel:OnStateChanged()
	self:_CheckOffsetAnimation()
	self:_Generate()
end

function FloatingModel:_GetSelectedCosmeticOverride(p2)
	local selectedCosmetic = self.Equipment:GetSelectedCosmetic()
	local cosmetic = CosmeticLibrary.Cosmetics[selectedCosmetic]

	if not cosmetic or cosmetic.Type ~= p2 then
		return
	end

	local cosmeticInverted = self.Equipment.EquipmentState.CosmeticInverted
	local weaponData = PlayerDataController:GetWeaponData(self.Equipment:GetSelectedWeapon())
	local table = Utility:CloneTable(weaponData and weaponData[p2] or {})
	table.Name = selectedCosmetic

	if p2 ~= "Wrap" or cosmeticInverted == nil then
		cosmeticInverted = table.Inverted
	end

	table.Inverted = cosmeticInverted
	return table
end

function FloatingModel:_GetViewModelName()
	local selectedWeapon = self.Equipment:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
	local _GetSelectedCosmeticOverride = self:_GetSelectedCosmeticOverride("Skin")
	local name = _GetSelectedCosmeticOverride and _GetSelectedCosmeticOverride.Name

	if not name then
		if weaponData and weaponData.Skin and weaponData.Skin.Name ~= "RANDOM_COSMETIC" then
			name = weaponData.Skin.Name or selectedWeapon
		else
			name = selectedWeapon
		end
	end

	return name
end

function FloatingModel:_CheckOffsetAnimation()
	local stateID = self.Equipment:GetStateID(true)

	if stateID == self._last_offset_state then
		return
	end

	self._last_offset_state = stateID
	self._offset_alpha_spring.Value = 0
end

function FloatingModel:_UpdateStaticModel(p2, instance, p3, p4)
	if not instance then
		return
	end

	local lerped = p3:Lerp(p4, self._offset_alpha_spring.Value)
	local v5 = self.Equipment.Scene:GetCFrame() * cframe * lerped
	local customizingType = self.Equipment:GetCustomizingType()
	local v6 = (customizingType == "Finisher" or customizingType == "Emote") and createVector(0, -25, 0) or createVector(
		0,
		0,
		0
	)
	instance:PivotTo(CFrame.new(v5.Position) * self.Equipment.SpinControls:GetCFrame() * v5.Rotation + v6)
	instance:Update(p2)
end

function FloatingModel:_PlayEquipSound()
	task.defer(function()
		if not (self.Equipment.IsOpen and self.Equipment.Camera:IsOpenEffectDone()) then
			return
		end

		if self._last_equip_sound then
			self._last_equip_sound:Destroy()
			self._last_equip_sound = nil
		end

		self._last_equip_sound = Utility:CreateSound(
			SoundLibrary.EquipSounds[math.random(#SoundLibrary.EquipSounds)],
			0.5,
			0.9 + 0.2 * math.random(),
			script,
			true,
			5
		)
	end)
end

function FloatingModel:_UpdateViewModel()
	if not (self._static_viewmodel and self.Equipment.IsOpen) then
		return
	end

	local weaponData = PlayerDataController:GetWeaponData(self._static_viewmodel.WeaponName)
	local charm = self:_GetSelectedCosmeticOverride("Charm")
	local wrap = self:_GetSelectedCosmeticOverride("Wrap")
	self._static_viewmodel:SetLocked(not weaponData)
	local _static_viewmodel = self._static_viewmodel

	if not charm then
		if weaponData and weaponData.Charm and weaponData.Charm.Name ~= "RANDOM_COSMETIC" then
			charm = weaponData.Charm or nil
		else
			charm = nil
		end
	end

	_static_viewmodel:SetCharm(charm)
	local _static_viewmodel2 = self._static_viewmodel

	if not wrap then
		if weaponData and weaponData.Wrap and weaponData.Wrap.Name ~= "RANDOM_COSMETIC" then
			wrap = weaponData.Wrap or nil
		else
			wrap = nil
		end
	end

	_static_viewmodel2:SetWrap(wrap)
end

function FloatingModel:_GenerateViewModel()
	if self._static_viewmodel then
		self._static_viewmodel:Destroy()
		self._static_viewmodel = nil
	end

	local _GetViewModelName = self:_GetViewModelName()

	if not (_GetViewModelName and self.Equipment.IsOpen) then
		return
	end

	self._static_viewmodel = StaticViewModel.new(_GetViewModelName)
	self._static_viewmodel:DeleteAnimationContextSubModels("ShowInEquipment")
	self._static_viewmodel:SetParent(workspace)
	self:_UpdateForcedVisibleCharmAttachment()
	self:_UpdateViewModel()
	self:_PlayEquipSound()
end

function FloatingModel:_GenerateCharacterModel()
	if self._static_charactermodel then
		self._static_charactermodel:Destroy()
		self._static_charactermodel = nil
	end

	if not (self.Equipment:IsCareerPageOpen() and self.Equipment.IsOpen) then
		return
	end

	self._static_charactermodel = StaticCharacterModel.new(Players.LocalPlayer.UserId)
	self._static_charactermodel:SetParent(workspace)
	self:_PlayEquipSound()
end

function FloatingModel:_Generate()
	if self.Equipment.IsOpen then
		local _GetViewModelName = self:_GetViewModelName()
		local last_generate_state = self.Equipment:GetStateID(true) .. tostring(_GetViewModelName)

		if last_generate_state == self._last_generate_state then
			return
		end

		self._last_generate_state = last_generate_state
		self:_GenerateViewModel()
		self:_GenerateCharacterModel()
		self:Update(0)
	else
		if self._static_viewmodel then
			self._static_viewmodel:Destroy()
			self._static_viewmodel = nil
		end

		if self._static_charactermodel then
			self._static_charactermodel:Destroy()
			self._static_charactermodel = nil
		end

		self._last_generate_state = nil
	end
end

function FloatingModel:_UpdateForcedVisibleCharmAttachment()
	if not self._static_viewmodel then
		return
	end

	self._static_viewmodel:ForceCharmAttachmentModelVisible(self.Equipment:GetCustomizingType() == "Charm")
	self.CharmAttachmentVisibleChanged:Fire()
end

function FloatingModel:_Init()
	self.Equipment.CustomizingChanged:Connect(function()
		self:_UpdateForcedVisibleCharmAttachment()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_Generate()
		self:_UpdateViewModel()
	end)
	self:_Generate()
	self:_UpdateForcedVisibleCharmAttachment()
end

return FloatingModel