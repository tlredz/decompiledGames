local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local unlockedCosmeticWeaponSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("UnlockedCosmeticWeaponSlot")
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(cosmetic_name)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.TitleText = self.PromptFrame:WaitForChild("Title")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._cosmetic_name = cosmetic_name
	self._cosmetic_info = CosmeticLibrary.Cosmetics[self._cosmetic_name]
	self._slots = {}
	self:_Init()
	return self
end

function object:_IsEquipped(p2)
	local weaponData = PlayerDataController:GetWeaponData(p2)
	return weaponData and weaponData[self._cosmetic_info.Type] and weaponData[self._cosmetic_info.Type].Name == self._cosmetic_name
end

function object:_UpdateEquipped()
	for k, _slot in pairs(self._slots) do
		_slot.Button.Equipped.Visible = self:_IsEquipped(k)
	end
end

function object:_Setup()
	self.TitleText.Text = self._cosmetic_name .. " " .. self._cosmetic_info.Type
	local cosmeticInventory = PlayerDataController:Get("CosmeticInventory")

	for k, text in pairs(ShopLibrary:GetReleasedOwnableWeapons(
		CONSTANTS.WEAPON_EARLY_ACCESS_TIME_OFFSET,
		ShopLibrary.OwnableWeaponsAlphabetized
	)) do
		local item = ItemLibrary.Items[text]

		if not (self._cosmetic_info.Type ~= "Finisher" or item.CanEliminate) then
			continue
		end

		local weaponData = PlayerDataController:GetWeaponData(text)
		local ownsCosmetic = CosmeticLibrary:OwnsCosmetic(cosmeticInventory, self._cosmetic_name, text)
		local clone = unlockedCosmeticWeaponSlot:Clone()
		clone.LayoutOrder = k + (ownsCosmetic and 0 or 999999)
		clone.Button.Icon.Image = item.Image
		clone.Button.Icon.ImageColor3 = not weaponData and Color3.fromRGB(32, 32, 32) or not ownsCosmetic and Color3.fromRGB(
			32,
			32,
			32
		) or Color3.fromRGB(255, 255, 255)
		clone.Button.Title.Visible = weaponData ~= nil
		clone.Button.Title.Text = text
		clone.Button.Title.TextTransparency = ownsCosmetic and 0 or 0.875
		clone.Button.Locked.Visible = not weaponData
		clone.ZIndex = weaponData and (ownsCosmetic and 2 or 1) or 0
		clone.Parent = self.Container
		self._slots[text] = clone
		ButtonEffect:Add(clone.Button)
		WeaponStatusHandler:ApplyItemStatusToText(clone.Button.Title, ItemLibrary.Items[text].Status)
		local v3 = text
		clone.Button.MouseButton1Click:Connect(function()
			if not ownsCosmetic then
				return
			end

			local equipCosmetic = ReplicatedStorage.Remotes.Data.EquipCosmetic
			local type = self._cosmetic_info.Type
			local v5

			if not self:_IsEquipped(v3) then
				v5 = self._cosmetic_name
			end

			equipCosmetic:FireServer(v3, type, v5)
			PlayerDataController:SilenceCosmeticNotification(self._cosmetic_name, v3)
		end)
		local flag = false

		local function hover()
			if flag then
				return
			end

			flag = true
			clone.ZIndex += 10
		end

		clone.Button.MouseEnter:Connect(hover)
		local v5 = clone

		local function unhover()
			if not flag then
				return
			end

			flag = false
			v5.ZIndex -= 10
		end

		clone.Button.MouseLeave:Connect(unhover)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateEquipped()
	end))
	self:_Setup()
	self:_UpdateEquipped()
	ButtonEffect:Add(self.CloseButton)
end

return object