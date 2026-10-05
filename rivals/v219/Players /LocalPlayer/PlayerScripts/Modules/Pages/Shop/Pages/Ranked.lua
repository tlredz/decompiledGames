local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local DropdownSlot = require(Players.LocalPlayer.PlayerScripts.Modules.DropdownSlot)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v = {
	"loose_glorycharm",
	"loose_glorywrap",
	"loose_gloryfinisher",
	"loose_gloryemote"
}
local Ranked = {}
Ranked.__index = Ranked

function Ranked.new(pages)
	local self = setmetatable({}, Ranked)
	self.Pages = pages
	self.Frame = self.Pages.Frame:WaitForChild("Ranked")
	self.Container = self.Frame:WaitForChild("Container")
	self.LooseFrame = self.Container:WaitForChild("Loose")
	self.LooseSlotsFrame = self.LooseFrame:WaitForChild("Slots")
	self.WeaponFrame = self.Container:WaitForChild("Weapon")
	self.WeaponSlotsFrame = self.WeaponFrame:WaitForChild("Slots")
	self.WeaponHeaderFrame = self.WeaponFrame:WaitForChild("Header")
	self.WeaponIcon = self.WeaponHeaderFrame:WaitForChild("Icon")
	self.WeaponDropdownFrame = self.WeaponHeaderFrame:WaitForChild("Dropdown")
	self.WeaponDropdownButton = self.WeaponDropdownFrame:WaitForChild("Button")
	self.WeaponDropdownTitle = self.WeaponDropdownButton:WaitForChild("Title")
	self._shop_slots = {}
	self._selected_weapon_name = self:_GetWeaponsWithGloriousCosmetics()[1]
	self._dropdown_slot = nil
	self._play_glorious_cosmetic_animation = false
	self._update_cleanup = {}
	self:_Init()
	return self
end

function Ranked:SetSelectedWeaponName(selected_weapon_name)
	self._selected_weapon_name = selected_weapon_name
	self:_Update()
end

function Ranked:Open()
	self:_Update()
end

function Ranked:Close()
	self:_Update()
	self:_StopDropdown()
end

function Ranked.Setup(_) end

function Ranked:_GetWeaponsWithGloriousCosmetics()
	local unlockedWeapons = PlayerDataController:GetUnlockedWeapons()
	local result = {}

	for _, v2 in pairs(ShopLibrary.OwnableWeaponsAlphabetized) do
		if unlockedWeapons[v2] and CosmeticLibrary.Cosmetics["Glorious " .. v2] then
			table.insert(result, v2)
		end
	end

	return result
end

function Ranked:_StopDropdown()
	if self._dropdown_slot then
		self._dropdown_slot:Cancel()
		self._dropdown_slot = nil
	end

	self.WeaponDropdownButton.Visible = true
end

function Ranked:_StartDropdown()
	self:_StopDropdown()
	self.WeaponDropdownButton.Visible = false
	self._dropdown_slot = DropdownSlot.new(self.WeaponDropdownFrame, self:_GetWeaponsWithGloriousCosmetics(), 9)
	self._dropdown_slot.Selected:Connect(function(p)
		if p then
			self._play_glorious_cosmetic_animation = true
			self:SetSelectedWeaponName(p)
		end

		self:_StopDropdown()
	end)
end

function Ranked:_Update()
	for _, _shop_slot in pairs(self._shop_slots) do
		_shop_slot:Destroy()
	end

	for _, v2 in pairs(self._update_cleanup) do
		v2:Destroy()
	end

	self._shop_slots = {}
	self._update_cleanup = {}
	WeaponStatusHandler:ClearStatusElements(self.WeaponDropdownTitle)

	if not self.Pages.Shop:IsOpen() then
		return
	end

	self.WeaponIcon.Image = not ItemLibrary.Items[self._selected_weapon_name] and "" or ItemLibrary.Items[self._selected_weapon_name].Image or ""
	self.WeaponDropdownTitle.Text = self._selected_weapon_name
	WeaponStatusHandler:ApplyItemStatusToText(
		self.WeaponDropdownTitle,
		ItemLibrary.Items[self._selected_weapon_name] and ItemLibrary.Items[self._selected_weapon_name].Status
	)

	for _, childName in pairs(v) do
		local shopSlot = self.Pages.Shop:CreateShopSlot(nil, self.LooseSlotsFrame:WaitForChild(childName), childName)

		if shopSlot then
			table.insert(self._shop_slots, shopSlot)
		end
	end

	local v2 = ShopLibrary.NUM_GLORIOUS_COSMETICS[self._selected_weapon_name] or 0
	local isOwned = true

	for i = 1, 1e999 do
		local child = self.WeaponSlotsFrame:FindFirstChild(i)
		local child2 = self.WeaponSlotsFrame:FindFirstChild("Arrow" .. i)

		if child then
			child.Visible = false
		end

		if child2 then
			child2.Visible = false
		end

		if not (child or child2) then
			break
		end
	end

	for i = 1, v2 do
		local child = self.WeaponSlotsFrame:WaitForChild(i)
		local v3 = "loose_gloriouscosmetic_" .. i .. "_" .. self._selected_weapon_name
		local shopSlot = self.Pages.Shop:CreateShopSlot(nil, child, v3, not isOwned)
		isOwned = shopSlot and shopSlot.IsOwned

		if not shopSlot then
			continue
		end

		child.Visible = true

		for _, parent in pairs({ shopSlot.Frame, self.WeaponSlotsFrame:FindFirstChild("Arrow" .. i - 1) }) do
			parent.Visible = true

			if not self._play_glorious_cosmetic_animation then
				continue
			end

			local v5 = (i - 1) * tweenInfo.Time * 0.5
			local uIScale = Instance.new("UIScale")
			uIScale.Scale = 0
			uIScale.Parent = parent
			table.insert(self._update_cleanup, uIScale)
			BetterDebris:AddItem(uIScale, v5 + tweenInfo.Time)
			task.delay(v5, function()
				TweenService:Create(uIScale, tweenInfo, {
					Scale = 1
				}):Play()
			end)
		end

		table.insert(self._shop_slots, shopSlot)
	end
end

function Ranked:_Init()
	self.WeaponDropdownButton.MouseButton1Click:Connect(function()
		self:_StartDropdown()
	end)
	PlayerDataController:GetDataChangedSignal("CosmeticInventory"):Connect(function()
		self:_Update()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_Update()
	end)
	ButtonEffect:Add(self.WeaponDropdownButton, nil, {
		ReleaseRatio = 1.025,
		HoverRatio = 1.025
	})
end

return Ranked