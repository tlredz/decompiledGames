local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Actions = {}
Actions.__index = Actions

function Actions.new(customize)
	local self = setmetatable({}, Actions)
	self.SearchUpdated = Signal.new()
	self.Customize = customize
	self.Frame = self.Customize.BottomContainer:WaitForChild("Actions")
	self.BackButton = self.Frame:WaitForChild("Back")
	self.EmoteButton = self.Frame:WaitForChild("Emote")
	self.EmoteButtonEquipFrame = self.EmoteButton:WaitForChild("Equip")
	self.EmoteButtonUnequipFrame = self.EmoteButton:WaitForChild("Unequip")
	self.SearchFrame = self.Frame:WaitForChild("Search")
	self.SearchBox = self.SearchFrame:WaitForChild("Box")
	self:_Init()
	return self
end

function Actions:OnCustomizingStateChanged()
	self:_UpdateEmoteButton()
end

function Actions:OnStateChanged()
	self:_UpdateEmoteButton()

	if not self.Customize.Interface.Equipment:IsCustomizing() then
		self.SearchBox.Text = ""
	end
end

function Actions:_UpdateEmoteButton()
	local selectedCosmetic = self.Customize.Interface.Equipment:GetSelectedCosmetic()
	local cosmetic = CosmeticLibrary.Cosmetics[selectedCosmetic]
	local v = cosmetic and cosmetic.Type == "Emote"
	local visible = v and CosmeticLibrary:OwnsCosmetic(
		PlayerDataController:Get("CosmeticInventory"),
		selectedCosmetic,
		self.Customize.Interface.Equipment:GetSelectedWeapon()
	)
	local visible2 = v and PlayerDataController:IsEmoteEquipped(selectedCosmetic)
	self.EmoteButton.Visible = visible
	self.EmoteButtonEquipFrame.Visible = not visible2
	self.EmoteButtonUnequipFrame.Visible = visible2
	self.SearchFrame.Size = visible and UDim2.new(0.75, -10, 1, 0) or UDim2.new(0.875, -5, 1, 0)
end

function Actions:_UpdateSearch()
	self.Customize.Interface.Equipment:SetCosmeticSearchQuery(self.SearchBox.Text)
end

function Actions:_Init()
	self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_UpdateSearch()
	end)
	self.BackButton.MouseButton1Click:Connect(function()
		self.Customize.Interface.Equipment:CloseRequest()
	end)
	self.EmoteButton.MouseButton1Click:Connect(function()
		Pages.PageSystem:OpenPage("EquipEmote")
		Pages.PageSystem:WaitForPage("EquipEmote"):SetEmoteName(self.Customize.Interface.Equipment:GetSelectedCosmetic())
	end)
	PlayerDataController:GetDataChangedSignal("CosmeticInventory"):Connect(function()
		self:_UpdateEmoteButton()
	end)
	ButtonEffect:Add(self.BackButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.EmoteButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
end

return Actions