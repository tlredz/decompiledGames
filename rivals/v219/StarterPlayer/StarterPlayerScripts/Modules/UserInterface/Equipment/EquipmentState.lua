local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local v = CONSTANTS.DEFAULT_WEAPONS[1]
local EquipmentState = {}
EquipmentState.__index = EquipmentState

function EquipmentState.new(equipment)
	local self = setmetatable({}, EquipmentState)
	self.SelectedWeaponChanged = Signal.new()
	self.CareerPageOpened = Signal.new()
	self.CareerPageOpened = Signal.new()
	self.CustomizingChanged = Signal.new()
	self.CustomizingStateChanged = Signal.new()
	self.CosmeticSearchChanged = Signal.new()
	self.Equipment = equipment
	self.SelectedWeapon = nil
	self.IsCareerPageOpen = false
	self.CustomizingType = nil
	self.SelectedCosmetic = nil
	self.CosmeticInverted = nil
	self.CosmeticSearchQuery = ""
	self:_Init()
	return self
end

function EquipmentState:SelectWeapon(selectedWeapon)
	assert(not selectedWeapon or ItemLibrary.Items[selectedWeapon] ~= nil, selectedWeapon)

	if selectedWeapon then
		self:OpenCareerPage(false)
	end

	self.SelectedWeapon = selectedWeapon
	self.SelectedWeaponChanged:Fire()
end

function EquipmentState:OpenCareerPage(isCareerPageOpen)
	assert(typeof(isCareerPageOpen) == "boolean")

	if isCareerPageOpen then
		self:SelectWeapon(nil)
	end

	self.IsCareerPageOpen = isCareerPageOpen
	self.CareerPageOpened:Fire()
end

function EquipmentState:StartCustomizing(customizingType)
	local type = CosmeticLibrary.Types[customizingType]
	assert(not customizingType or type and not type.NotCosmetic)

	if customizingType then
		self:OpenCareerPage(customizingType == "Emote")
		local v2

		if type.IsWeaponCosmetic then
			v2 = self.SelectedWeapon or v or nil
		end

		self:SelectWeapon(v2)
	else
		self:SelectCosmetic(nil)
		self:SetCosmeticInvertedState(nil)
		self:SetCosmeticSearchQuery(nil)
	end

	self.CustomizingType = customizingType
	self.CustomizingChanged:Fire()
end

function EquipmentState:SelectCosmetic(selectedCosmetic)
	assert(
		not selectedCosmetic or selectedCosmetic == "NONE_COSMETIC" or selectedCosmetic == "RANDOM_COSMETIC" or CosmeticLibrary.Cosmetics[selectedCosmetic] ~= nil,
		selectedCosmetic
	)

	if selectedCosmetic == "NONE_COSMETIC" then
		selectedCosmetic = nil
	end

	self.SelectedCosmetic = selectedCosmetic
	self.CustomizingStateChanged:Fire()
end

function EquipmentState:SetCosmeticInvertedState(cosmeticInverted)
	self.CosmeticInverted = cosmeticInverted
	self.CustomizingStateChanged:Fire()
end

function EquipmentState:SetCosmeticSearchQuery(value)
	self.CosmeticSearchQuery = value and string.lower(value) or ""
	self.CosmeticSearchChanged:Fire()
end

function EquipmentState:OnOpen()
	if self.Equipment.IsOpen then
		self:SelectWeapon(self.SelectedWeapon or v)
	else
		self:StartCustomizing(nil)
	end
end

function EquipmentState:_Init() end

return EquipmentState