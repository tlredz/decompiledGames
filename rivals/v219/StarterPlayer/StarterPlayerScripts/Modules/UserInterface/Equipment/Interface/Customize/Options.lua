local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local Options = {}
Options.__index = Options

function Options.new(customize)
	local self = setmetatable({}, Options)
	self.Customize = customize
	self.Frame = self.Customize.BottomContainer:WaitForChild("Options")
	self.Background = self.Frame:WaitForChild("Background")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self:_Init()
	return self
end

function Options:OnCustomizingStateChanged()
	self:_Update()
end

function Options:OnStateChanged()
	self:_Update()
end

function Options:_UpdateBackground()
	self.Background.Size = UDim2.new(0, self.Layout.AbsoluteContentSize.X, 1, 0)
	self.Background.Visible = self.Layout.AbsoluteContentSize.X > 1
end

function Options:_OnOptionClicked(childName, onMouseButton1Click)
	local button = self.Container:WaitForChild(childName):WaitForChild("Container"):WaitForChild("Button")
	button.MouseButton1Click:Connect(onMouseButton1Click)
	ButtonEffect:Add(button)
end

function Options:_SetOption(childName, visible, visible2)
	local child = self.Container:WaitForChild(childName)
	local button = child:WaitForChild("Container"):WaitForChild("Button")
	local empty = button:WaitForChild("Empty")
	local filled = button:WaitForChild("Filled")
	child.Visible = visible
	filled.Visible = visible2
	empty.Visible = not visible2
end

function Options:_Update()
	if not self.Customize.Interface.Equipment.IsOpen then
		return
	end

	local selectedWeapon = self.Customize.Interface.Equipment:GetSelectedWeapon()
	local selectedCosmetic = self.Customize.Interface.Equipment:GetSelectedCosmetic()
	local customizingType = self.Customize.Interface.Equipment:GetCustomizingType()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
	local v = weaponData and selectedCosmetic and CosmeticLibrary:OwnsCosmetic(
		PlayerDataController:Get("CosmeticInventory"),
		selectedCosmetic,
		selectedWeapon
	)
	local favoritedCosmetics = PlayerDataController:Get("FavoritedCosmetics")
	local v2 = not selectedCosmetic and customizingType and "NONE_COSMETIC" or selectedCosmetic
	local v3 = v or v2 == "NONE_COSMETIC"
	self:_SetOption(
		"Favorited",
		v3,
		v3 and favoritedCosmetics[selectedWeapon] and favoritedCosmetics[selectedWeapon][CosmeticLibrary:GetNoneSpecificCosmeticName(
			v2,
			customizingType
		)]
	)
	local v4

	if customizingType == "Wrap" then
		v4 = selectedCosmetic and selectedCosmetic ~= "RANDOM_COSMETIC"
	else
		v4 = false
	end

	local v5

	if self.Customize.Interface.Equipment.EquipmentState.CosmeticInverted == nil then
		v5 = weaponData and weaponData.Wrap and weaponData.Wrap.Inverted
	else
		v5 = self.Customize.Interface.Equipment.EquipmentState.CosmeticInverted
	end

	self:_SetOption("Inverted", v4, v5)
	local v6 = selectedCosmetic == "RANDOM_COSMETIC"
	self:_SetOption(
		"OnlyUseFavorites",
		v6,
		v6 and weaponData and weaponData[customizingType] and weaponData[customizingType].OnlyUseFavorites
	)
end

function Options:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateBackground()
	end)
	self:_OnOptionClicked("Favorited", function()
		local selectedWeapon = self.Customize.Interface.Equipment:GetSelectedWeapon()
		local selectedCosmetic = self.Customize.Interface.Equipment:GetSelectedCosmetic()
		local customizingType = self.Customize.Interface.Equipment:GetCustomizingType()
		local favoritedCosmetics = PlayerDataController:Get("FavoritedCosmetics")
		local v = selectedCosmetic or "NONE_COSMETIC"
		local v2 = not (favoritedCosmetics[selectedWeapon] and favoritedCosmetics[selectedWeapon][CosmeticLibrary:GetNoneSpecificCosmeticName(
			v,
			customizingType
		)])
		local v3

		if v == "NONE_COSMETIC" then
			v3 = self.Customize.Interface.Equipment:GetCustomizingType()
		end

		ReplicatedStorage.Remotes.Data.FavoriteCosmetic:FireServer(selectedWeapon, v, v2, v3)
	end)
	self:_OnOptionClicked("Inverted", function()
		local selectedWeapon = self.Customize.Interface.Equipment:GetSelectedWeapon()
		local selectedCosmetic = self.Customize.Interface.Equipment:GetSelectedCosmetic()
		local customizingType = self.Customize.Interface.Equipment:GetCustomizingType()
		local cosmeticInverted = self.Customize.Interface.Equipment.EquipmentState.CosmeticInverted
		local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
		local v = weaponData and selectedCosmetic and CosmeticLibrary:OwnsCosmetic(
			PlayerDataController:Get("CosmeticInventory"),
			selectedCosmetic,
			selectedWeapon
		)

		if cosmeticInverted == nil then
			cosmeticInverted = weaponData and weaponData.Wrap and weaponData.Wrap.Inverted
		end

		local isInverted = not cosmeticInverted
		self.Customize.Interface.Equipment.EquipmentState:SetCosmeticInvertedState(isInverted)

		if v then
			ReplicatedStorage.Remotes.Data.EquipCosmetic:FireServer(
				selectedWeapon,
				customizingType,
				weaponData.Wrap.Name,
				{
					IsInverted = isInverted
				}
			)
		end
	end)
	self:_OnOptionClicked("OnlyUseFavorites", function()
		local selectedWeapon = self.Customize.Interface.Equipment:GetSelectedWeapon()
		local customizingType = self.Customize.Interface.Equipment:GetCustomizingType()
		local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
		local onlyUseFavorites = not weaponData[customizingType].OnlyUseFavorites
		ReplicatedStorage.Remotes.Data.EquipCosmetic:FireServer(
			selectedWeapon,
			customizingType,
			weaponData[customizingType].Name,
			{
				OnlyUseFavorites = onlyUseFavorites
			}
		)
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_Update()
	end)
	PlayerDataController:GetDataChangedSignal("CosmeticInventory"):Connect(function()
		self:_Update()
	end)
	PlayerDataController:GetDataChangedSignal("FavoritedCosmetics"):Connect(function()
		self:_Update()
	end)
	self:_UpdateBackground()
end

return Options