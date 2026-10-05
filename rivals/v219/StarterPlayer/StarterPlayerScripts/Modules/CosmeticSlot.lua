local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("StaticModel"):WaitForChild("StaticViewModel"))
local CosmeticViewportFrame = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("CosmeticViewportFrame"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local EmoteViewportFrame = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("EmoteViewportFrame"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local cosmeticSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CosmeticSlot")
local CosmeticSlot = {}
CosmeticSlot.__index = CosmeticSlot

function CosmeticSlot.new(name, isLocked, ignore_button_effects)
	local self = setmetatable({}, CosmeticSlot)
	self.Name = name
	self.Info = CosmeticLibrary.Cosmetics[self.Name]
	self.IsLocked = isLocked
	self.Frame = cosmeticSlot:Clone()
	self._cleanup = {}
	self._ignore_button_effects = ignore_button_effects
	self._quantity = 1
	self._name_text_override = nil
	self._emote_viewport_frame = nil
	self._cosmetic_viewport_frame = nil
	self:_Init()
	return self
end

function CosmeticSlot:SetWeapon(p2)
	local item = ItemLibrary.Items[p2]
	local viewModel = ItemLibrary.ViewModels[p2]
	local v = p2 == "IsUniversal" or p2 == "IsRandom"
	local UNIVERSAL_WEAPON_ICON

	if p2 == "IsUniversal" then
		UNIVERSAL_WEAPON_ICON = ItemLibrary.UNIVERSAL_WEAPON_ICON
	elseif p2 == "IsRandom" then
		UNIVERSAL_WEAPON_ICON = ItemLibrary.RANDOM_WEAPON_ICON
	else
		UNIVERSAL_WEAPON_ICON = not viewModel and "" or viewModel.ImageCentered or viewModel.Image
	end

	self.Frame.Button.Weapon.Visible = not self.IsLocked and p2
	self.Frame.Button.Weapon.Container.IconCanvas.Icon.Image = UNIVERSAL_WEAPON_ICON
	self.Frame.Button.Weapon.Container.IconCanvas.Icon.ImageTransparency = v and 0.25 or 0
	self.Frame.Button.Weapon.Container.IconCanvas.Icon.Size = v and UDim2.new(0.75, 0, 1, 0) or UDim2.new(4, 0, 4, 0)
	WeaponStatusHandler:ApplyItemStatusToBackground(
		self.Frame.Button.Weapon.Container.Background,
		self.Frame.Button.Weapon.Container.Outline.UIStroke,
		item and item.Status or "Standard"
	)
end

function CosmeticSlot:SetQuantity(value)
	self._quantity = value or 1
	self:_UpdateNameText()
end

function CosmeticSlot.SetInteractable(p, interactable)
	p.Frame.Button.Interactable = interactable
end

function CosmeticSlot:OverrideNameText(name_text_override)
	self._name_text_override = name_text_override
	self:_UpdateNameText()
end

function CosmeticSlot.UseHighResolutionImage(data)
	data.Frame.Button.Icon.Image = CONSTANTS.COSMETIC_IMAGES[data.Name] or ItemLibrary.ViewModels[data.Name] and ItemLibrary.ViewModels[data.Name].ImageHighResolution or data.Info.Image
end

function CosmeticSlot:HideBackground()
	self.Frame.Button.Background.Visible = false

	if self._cosmetic_viewport_frame then
		self._cosmetic_viewport_frame.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end

	if self._emote_viewport_frame then
		self._emote_viewport_frame.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end

function CosmeticSlot:ZoomOutViewportFrame()
	if self._cosmetic_viewport_frame then
		self._cosmetic_viewport_frame:ZoomOut()
	end

	if self._emote_viewport_frame then
		self._emote_viewport_frame:ZoomOut()
	end
end

function CosmeticSlot:Destroy()
	self.Frame:Destroy()

	if self._cosmetic_viewport_frame then
		self._cosmetic_viewport_frame:Destroy()
	end

	if self._emote_viewport_frame then
		self._emote_viewport_frame:Destroy()
	end
end

function CosmeticSlot:_UpdateNameText()
	self.Frame.Button.Title.Size = (self._name_text_override or self._quantity == 1 or self._quantity == 0) and UDim2.new(
		0.9,
		0,
		0.2,
		0
	) or UDim2.new(0.9, 0, 0.4, 0)
	self.Frame.Button.Title.Text = self._name_text_override or self.Name == "RANDOM_COSMETIC" and "Random" or self.Name == "NONE_COSMETIC" and "None" or (self._quantity == 1 or self._quantity == 0) and self.Name or "×" .. Utility:PrettyNumber(self._quantity)
end

function CosmeticSlot:_Setup()
	local color = self.Info and CosmeticLibrary.Rarities[self.Info.Rarity].Color or Color3.fromRGB(0, 0, 0)
	self.Frame.Button.Icon.ZIndex = self.Info and self.Info.Type == "Skin" and not self.IsLocked and 3 or self.Frame.Button.Icon.ZIndex
	self.Frame.Button.Icon.Size = (self.Name == "RANDOM_COSMETIC" or self.Name == "NONE_COSMETIC") and UDim2.new(
		0.45,
		0,
		0.45,
		0
	) or UDim2.new(0.75 * self.Info.ImageScale, 0, 0.75 * self.Info.ImageScale, 0)
	self.Frame.Button.Icon.Image = CONSTANTS.COSMETIC_IMAGES[self.Name] or self.Info.Image
	self.Frame.Button.Icon.ImageTransparency = (self.Name == "RANDOM_COSMETIC" or self.Name == "NONE_COSMETIC") and 0.875 or self.IsLocked and 0.5 or 0
	self.Frame.Button.Icon.ImageColor3 = self.IsLocked and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	self.Frame.Button.Title.TextTransparency = self.IsLocked and 0.5 or 0
	self.Frame.Button.Locked.Visible = self.IsLocked
	self.Frame.Button.Background.UIStroke.Color = color
	self.Frame.Button.Background.BackgroundColor3 = color

	if not self._ignore_button_effects then
		ButtonEffect:Add(self.Frame.Button)
	end

	if self.IsLocked and self.Info then
		self.Frame.Button.Icon.ZIndex = 1
		self.Frame.Button.Icon.Size = UDim2.new(0.6, 0, 0.6, 0)
		self.Frame.Button.Icon.Image = CosmeticLibrary.Types[self.Info.Type].Image
		self.Frame.Button.Icon.ImageTransparency = 0.5
		self.Frame.Button.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
	elseif self.Info then
		if self.Info.Type == "Emote" then
			self._emote_viewport_frame = EmoteViewportFrame.new(self.Name)
			self._emote_viewport_frame.Frame.ZIndex = self.IsLocked and 0 or 1
			self._emote_viewport_frame:SetParent(self.Frame.Button)
			self._emote_viewport_frame:SetLocked(self.IsLocked)
		else
			self._cosmetic_viewport_frame = CosmeticViewportFrame.new(self.Name, self.IsLocked)
			self._cosmetic_viewport_frame.Frame.BackgroundColor3 = color
			self._cosmetic_viewport_frame.Frame.Parent = self.Frame.Button
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 8)
			uICorner.Parent = self._cosmetic_viewport_frame.Frame
		end
	end
end

function CosmeticSlot:_Init()
	self.Frame.Destroying:Connect(function()
		for _, v in pairs(self._cleanup) do
			v:Destroy()
		end
	end)
	self:_Setup()
	self:_UpdateNameText()
	self:SetWeapon(nil)
	self:SetQuantity(nil)
end

return CosmeticSlot