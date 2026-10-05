local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CosmeticSlot = require(Players.LocalPlayer.PlayerScripts.Modules.CosmeticSlot)
local cosmeticSlotNotification = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CosmeticSlotNotification")
local cosmeticSlotEmpty = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CosmeticSlotEmpty")
local Cosmetics = {}
Cosmetics.__index = Cosmetics

function Cosmetics.new(customize)
	local self = setmetatable({}, Cosmetics)
	self.Customize = customize
	self.List = self.Customize.BottomContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._cosmetic_slots = {}
	self._empty_cosmetic_slots = {}
	self._generate_hash = 0
	self:_Init()
	return self
end

function Cosmetics:OnCustomizingStateChanged()
	self:_BulkUpdateEquipped()
	self:_BulkUpdateSearch()
end

function Cosmetics:OnStateChanged()
	self:_BulkUpdateEquipped()
	task.defer(self._Generate, self)
end

function Cosmetics:_UpdateFavorited(p2)
	local favoritedCosmetics = PlayerDataController:Get("FavoritedCosmetics")
	local selectedWeapon = self.Customize.Interface.Equipment:GetSelectedWeapon()
	local customizingType = self.Customize.Interface.Equipment:GetCustomizingType()
	local visible = favoritedCosmetics[selectedWeapon] and favoritedCosmetics[selectedWeapon][CosmeticLibrary:GetNoneSpecificCosmeticName(
		p2,
		customizingType
	)]
	self._cosmetic_slots[p2].Frame.Button.Favorited.Visible = visible
	self._cosmetic_slots[p2].Frame.LayoutOrder = self._cosmetic_slots[p2].OriginalLayoutOrder + (visible and -9999999 or 0)
	self._cosmetic_slots[p2].Frame.ZIndex = self._cosmetic_slots[p2].Frame.LayoutOrder
end

function Cosmetics:_BulkUpdateFavorited()
	for k in pairs(self._cosmetic_slots) do
		self:_UpdateFavorited(k)
	end
end

function Cosmetics:_UpdateSearch(p2)
	local cosmetic = CosmeticLibrary.Cosmetics[p2]
	local v = cosmetic and cosmetic.GetDescription(false)
	self._cosmetic_slots[p2].Frame.Visible = p2 == "NONE_COSMETIC" or Utility:IsVisibleFromSearch(
		self.Customize.Interface.Equipment:GetCosmeticSearchQuery(),
		self._cosmetic_slots[p2].Frame.Button.Title.ContentText,
		self._cosmetic_slots[p2].Frame.Button.Title,
		v,
		nil
	)
end

function Cosmetics:_BulkUpdateSearch()
	for k in pairs(self._cosmetic_slots) do
		self:_UpdateSearch(k)
	end
end

function Cosmetics:_IsEquipped(p2)
	local selectedWeapon = self.Customize.Interface.Equipment:GetSelectedWeapon()
	local customizingType = self.Customize.Interface.Equipment:GetCustomizingType()

	if customizingType == "Emote" then
		return p2 ~= "NONE_COSMETIC" and PlayerDataController:IsEmoteEquipped(p2)
	else
		local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
		local v = weaponData and weaponData[customizingType]

		if p2 == "NONE_COSMETIC" then
			return not v
		end

		return v and p2 == v.Name
	end
end

function Cosmetics:_UpdateEquipped(p)
	self._cosmetic_slots[p].Frame.Button.Equipped.Visible = self:_IsEquipped(p)
end

function Cosmetics:_BulkUpdateEquipped()
	if not self.Customize.Interface.Equipment.IsOpen then
		return
	end

	for k in pairs(self._cosmetic_slots) do
		self:_UpdateEquipped(k)
	end
end

function Cosmetics:_Cleanup()
	local count = 0

	for _, _cosmetic_slot in pairs(self._cosmetic_slots) do
		_cosmetic_slot.Frame.Parent = nil
		BetterDebris:AddItem(_cosmetic_slot, count * 0.1)
		count += 1
	end

	for _, _empty_cosmetic_slot in pairs(self._empty_cosmetic_slots) do
		_empty_cosmetic_slot:Destroy()
	end

	self._cosmetic_slots = {}
	self._empty_cosmetic_slots = {}
	self._generate_hash += 1
end

function Cosmetics:_Generate()
	self:_Cleanup()
	self._generate_hash += 1
	local _generate_hash = self._generate_hash
	local selectedWeapon = self.Customize.Interface.Equipment:GetSelectedWeapon()
	local selectedCosmetic = self.Customize.Interface.Equipment:GetSelectedCosmetic()
	local customizingType = self.Customize.Interface.Equipment:GetCustomizingType()
	local isWeaponCosmetic = customizingType and CosmeticLibrary.Types[customizingType] and CosmeticLibrary.Types[customizingType].IsWeaponCosmetic
	local cosmeticNotifications = PlayerDataController:Get("CosmeticNotifications")
	local cosmeticInventory = PlayerDataController:Get("CosmeticInventory")

	if not customizingType or isWeaponCosmetic and not selectedWeapon then
		return
	end

	local total = 0
	local v = {}

	for k, name in pairs(CosmeticLibrary.CosmeticsAlphabetized) do
		local cosmetic = CosmeticLibrary.Cosmetics[name]
		local v3 = cosmetic.Type == customizingType
		local v4 = customizingType ~= "Skin" or cosmetic.ItemName == selectedWeapon

		if not (v3 and v4) then
			continue
		end

		local hasNotification = CosmeticLibrary:HasNotification(cosmeticNotifications, name, selectedWeapon)
		local isLocked = not CosmeticLibrary:OwnsCosmetic(cosmeticInventory, name, selectedWeapon)
		local _IsEquipped = self:_IsEquipped(name)
		total += isLocked and 0 or 1
		table.insert(v, {
			Name = name,
			HasNotification = hasNotification or false,
			IsLocked = isLocked,
			IsEquipped = _IsEquipped,
			AlphabeticalValue = k
		})
	end

	table.sort(v, function(a, b)
		local isEquipped = a.IsEquipped

		if isEquipped ~= b.IsEquipped then
			return isEquipped
		end

		local isLocked = a.IsLocked

		if isLocked ~= b.IsLocked then
			return not isLocked
		end

		local hasNotification = a.HasNotification

		if hasNotification ~= b.HasNotification then
			return hasNotification
		end

		local value = CosmeticLibrary.Rarities[CosmeticLibrary.Cosmetics[a.Name].Rarity].Value
		local value2 = CosmeticLibrary.Rarities[CosmeticLibrary.Cosmetics[b.Name].Rarity].Value

		if value == value2 then
			return a.AlphabeticalValue < b.AlphabeticalValue
		end

		return value2 < value
	end)

	if not selectedCosmetic and customizingType == "Emote" and not next(PlayerDataController:Get("EquippedEmotes")) then
		self.Customize.Interface.Equipment:SelectCosmetic("Take The L")
	end

	local v2 = customizingType == "Emote" and 1 or 5
	local count = 0

	local function generate_slot(p, p2, p3)
		local cosmetic = CosmeticLibrary.Cosmetics[p]

		if cosmetic and cosmetic.Hidden and p2 then
			return
		end

		local v3 = CosmeticSlot.new(p, p2)
		v3.OriginalLayoutOrder = count + (cosmetic and 0 or -999999999) + (cosmetic and self:_IsEquipped(p) and -99999999 or 0)
		v3.Frame.LayoutOrder = v3.OriginalLayoutOrder
		v3.Frame.Parent = self.Container
		self._cosmetic_slots[p] = v3
		count += 1
		self:_UpdateSearch(p)
		self:_UpdateEquipped(p)
		self:_UpdateFavorited(p)
		local clone

		if p3 then
			clone = cosmeticSlotNotification:Clone()
			clone.Parent = v3.Frame.Button
		else
			clone = nil
		end

		v3.Frame.Button.MouseButton1Click:Connect(function()
			if clone then
				clone:Destroy()
				clone = nil
				PlayerDataController:SilenceCosmeticNotification(
					p,
					ItemLibrary.Items[selectedWeapon] and selectedWeapon or nil
				)
			end

			self.Customize.Interface.Equipment:SelectCosmetic(p)

			if selectedWeapon and not p2 and isWeaponCosmetic then
				local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
				local v4

				if p ~= "NONE_COSMETIC" then
					v4 = p
				end

				local inverted = weaponData and weaponData.Wrap and weaponData.Wrap.Inverted or nil
				ReplicatedStorage.Remotes.Data.EquipCosmetic:FireServer(selectedWeapon, customizingType, v4, {
					IsInverted = inverted
				})
			end
		end)

		if not self.Customize.Interface.Equipment:GetSelectedCosmetic() and self:_IsEquipped(p) then
			self.Customize.Interface.Equipment:SelectCosmetic(p)
		end

		if count % v2 == 0 then
			wait(0.06)
		end
	end

	if isWeaponCosmetic then
		generate_slot("NONE_COSMETIC", false)

		if _generate_hash ~= self._generate_hash then
			return
		end
	end

	if isWeaponCosmetic and total > 0 then
		generate_slot("RANDOM_COSMETIC", false)

		if _generate_hash ~= self._generate_hash then
			return
		end
	end

	for _, v3 in pairs(v) do
		generate_slot(v3.Name, v3.IsLocked, v3.HasNotification)

		if _generate_hash ~= self._generate_hash then
			return
		end
	end

	for _ = 1, 11 do
		local clone = cosmeticSlotEmpty:Clone()
		clone.LayoutOrder = 999999999
		clone.Parent = self.Container
		table.insert(self._empty_cosmetic_slots, clone)
	end
end

function Cosmetics:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, self.Layout.AbsoluteContentSize.X, 0, 0)
	end)
	self.Customize.Interface.Equipment.CosmeticSearchChanged:Connect(function()
		self:_BulkUpdateSearch()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_BulkUpdateEquipped()
	end)
	PlayerDataController:GetDataChangedSignal("EquippedEmotes"):Connect(function()
		self:_BulkUpdateEquipped()
	end)
	PlayerDataController:GetDataChangedSignal("CosmeticInventory"):Connect(function()
		self:_BulkUpdateEquipped()
	end)
	PlayerDataController:GetDataChangedSignal("FavoritedCosmetics"):Connect(function()
		self:_BulkUpdateFavorited()
	end)
end

return Cosmetics