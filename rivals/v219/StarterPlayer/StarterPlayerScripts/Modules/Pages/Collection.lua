local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local CosmeticSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("CosmeticSlot"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local WeaponSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local cosmeticSlotBubble = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CosmeticSlotBubble")
local v = {
	"Weapon",
	"Skin",
	"Wrap",
	"Charm",
	"Finisher",
	"Emote"
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.TabsFrame = self.Container:WaitForChild("Tabs")
	self.SlotsFrame = self.Container:WaitForChild("Slots")
	self.SlotsContainer = self.SlotsFrame:WaitForChild("Container")
	self.SlotsLayout = self.SlotsContainer:WaitForChild("Layout")
	self.SearchFrame = self.Container:WaitForChild("Search")
	self.SearchBox = self.SearchFrame:WaitForChild("Box")
	self.LockedSlotsFrame = self.Container:WaitForChild("LockedSlots")
	self.LockedSlotsContainer = self.LockedSlotsFrame:WaitForChild("Container")
	self.LockedSlotsLayout = self.LockedSlotsContainer:WaitForChild("Layout")
	self.Divider = self.Container:WaitForChild("Divider")
	self.CurrentTab = nil
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._slots = {}
	self._close_bubbles = {}
	self._generate_hash = 0
	self._search_query = ""
	self:_Init()
	return self
end

function object:SetTab(currentTab)
	self.CurrentTab = currentTab

	for _, childName in pairs(v) do
		local v2 = childName == self.CurrentTab
		local child = self.TabsFrame:WaitForChild(childName)
		local background = child:WaitForChild("Background")
		local title = child:WaitForChild("Title")
		title.TextColor3 = v2 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
		background.ImageColor3 = v2 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
		background.ImageTransparency = v2 and 0 or 0.25
		local uIGradient = background:WaitForChild("UIGradient")
		uIGradient.Enabled = not v2
	end

	self:_Generate()
end

function object:Open(...)
	Page.Open(self, ...)
	self.SearchBox.Text = ""
	self:_Generate()
end

function object:Close()
	Page.Close(self)
	self:_Generate()
end

function object:_UpdateLayouts()
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.List.Active = self.Layout.AbsoluteContentSize.Y >= self.List.AbsoluteSize.Y
	self.SlotsFrame.Size = UDim2.new(1, 0, 0, self.SlotsLayout.AbsoluteContentSize.Y)
	self.SlotsFrame.Visible = self.SlotsLayout.AbsoluteContentSize.Y > 0
	self.LockedSlotsFrame.Size = UDim2.new(1, 0, 0, self.LockedSlotsLayout.AbsoluteContentSize.Y)
	self.LockedSlotsFrame.Visible = self.LockedSlotsLayout.AbsoluteContentSize.Y > 0
end

function object:_UpdateSearch(p2)
	p2.Frame.Visible = Utility:IsVisibleFromSearch(self._search_query, table.unpack(p2.SearchArgs))
end

function object:_BulkUpdateSearch()
	self._search_query = string.lower(self.SearchBox.Text)

	for _, _slot in pairs(self._slots) do
		self:_UpdateSearch(_slot)
	end
end

function object:_CloseBubbles()
	for _, _close_bubble in pairs(self._close_bubbles) do
		_close_bubble()
	end
end

function object:_GenerateWeapons()
	local _generate_hash = self._generate_hash
	local unlockedWeapons = PlayerDataController:GetUnlockedWeapons()

	for k, v2 in pairs(ShopLibrary:GetReleasedOwnableWeapons(
		CONSTANTS.WEAPON_REVEAL_TIME_OFFSET,
		ShopLibrary.OwnableWeaponsAlphabetized
	)) do
		if _generate_hash ~= self._generate_hash then
			break
		end

		local item = ItemLibrary.Items[v2]
		local status = ItemLibrary.Statuses[item.Status]
		local v3 = not unlockedWeapons[v2]
		local text = item.Status .. " " .. item.Class
		local object2 = WeaponSlot.new(v2)
		object2.Frame.LayoutOrder = k - status.Value * 999999
		object2.Frame.Parent = v3 and self.LockedSlotsContainer or self.SlotsContainer

		if v3 then
			object2:Lock()

			if not ShopLibrary:IsWeaponReleased(v2) then
				object2:HideName()
			end
		end

		local clone = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_background()
			clone.Background.Size = UDim2.new(0, clone.Title.TextBounds.X + clone.Background.AbsoluteSize.Y, 1, 0)
		end

		self._close_bubbles[v2] = function()
			object2.Frame.ZIndex = 0

			if clone then
				clone:Destroy()
				clone = nil
			end
		end

		local object3 = object2
		local update_background2 = update_background

		local function open_bubble()
			self:_CloseBubbles()
			object3.Frame.ZIndex = 1
			clone = cosmeticSlotBubble:Clone()
			clone.Title.Text = text
			clone.Parent = object3.Frame.Button
			WeaponStatusHandler:ApplyItemStatusToText(clone.Title, item.Status)

			local function update()
				update_background2() -- equivalent call inferred; original call site unknown
			end

			clone.Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_background2)
			clone.Title:GetPropertyChangedSignal("TextBounds"):Connect(update_background2)
			update_background2() -- equivalent call inferred; original call site unknown
			clone.Size = UDim2.new(0, 0, 0.125, 0)
			clone:TweenSize(UDim2.new(5, 0, 0.25, 0), "Out", "Quint", 0.25, true)
		end

		object2.Frame.Button.MouseEnter:Connect(open_bubble)
		object2.Frame.Button.MouseButton1Click:Connect(open_bubble)

		if not v3 then
			self.Divider.Visible = true
		end

		local v10 = {
			Object = object2,
			Frame = object2.Frame,
			SearchArgs = {
				object2.Frame.Button.Title.Text,
				object2.Frame.Button.Title,
				text,
				nil
			}
		}
		table.insert(self._slots, v10)
		self:_UpdateSearch(v10)

		if k % 5 == 0 then
			wait(0.03)
		end
	end
end

function object:_GenerateCosmetics()
	local unlockedWeapons = PlayerDataController:GetUnlockedWeapons()
	local cosmeticInventory = PlayerDataController:Get("CosmeticInventory")
	local _generate_hash = self._generate_hash

	for k, v2 in pairs(CosmeticLibrary.CosmeticsAlphabetized) do
		if _generate_hash ~= self._generate_hash then
			break
		end

		local cosmetic = CosmeticLibrary.Cosmetics[v2]

		if not (cosmetic.Type == self.CurrentTab and (cosmetic.Type ~= "Skin" or unlockedWeapons[cosmetic.ItemName] or ShopLibrary:IsWeaponReleased(cosmetic.ItemName))) then
			continue
		end

		local v3 = not CosmeticLibrary:OwnsCosmeticForSomething(cosmeticInventory, v2)

		if cosmetic.Hidden and v3 then
			continue
		end

		self.Divider.Visible = self.Divider.Visible or not v3
		local object2 = CosmeticSlot.new(v2, v3)
		object2.Frame.LayoutOrder = k - CosmeticLibrary.Rarities[cosmetic.Rarity].Value * 10000 + (v3 and 9999999 or 0)
		object2.Frame.Parent = v3 and self.LockedSlotsContainer or self.SlotsContainer
		local clone = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_background()
			clone.Background.Size = UDim2.new(0, clone.Title.TextBounds.X + clone.Background.AbsoluteSize.Y, 1, 0)
		end

		self._close_bubbles[v2] = function()
			object2.Frame.ZIndex = 0

			if clone then
				clone:Destroy()
				clone = nil
			end
		end

		local v6 = cosmetic
		local object3 = object2
		local update_background2 = update_background

		local function open_bubble()
			if not v6.Description then
				return
			end

			self:_CloseBubbles()
			object3.Frame.ZIndex = 1
			clone = cosmeticSlotBubble:Clone()
			clone.Title.Text = v6.Description or ""
			clone.Parent = object3.Frame.Button

			local function update()
				update_background2() -- equivalent call inferred; original call site unknown
			end

			clone.Title:GetPropertyChangedSignal("TextBounds"):Connect(update_background2)
			clone.Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_background2)
			update_background2() -- equivalent call inferred; original call site unknown
			clone.Size = UDim2.new(0, 0, 0.125, 0)
			clone:TweenSize(UDim2.new(5, 0, 0.25, 0), "Out", "Quint", 0.25, true)
		end

		object2.Frame.Button.MouseEnter:Connect(open_bubble)
		local v8 = cosmetic
		local v9 = v3
		local v10 = v2
		local open_bubble2 = open_bubble
		object2.Frame.Button.MouseButton1Click:Connect(function()
			if not CosmeticLibrary.Types[v8.Type].IsWeaponCosmetic or v8.Type == "Skin" or v9 then
				open_bubble2()
				return
			end

			self:_CloseBubbles()
			self.PromptSystem:Open("InspectCosmetic", v10)
		end)
		local v11 = {
			Object = object2,
			Frame = object2.Frame,
			SearchArgs = {
				object2.Frame.Button.Title.ContentText,
				object2.Frame.Button.Title,
				cosmetic.Description,
				nil
			}
		}
		table.insert(self._slots, v11)
		self:_UpdateSearch(v11)

		if k % 5 == 0 then
			wait(0.03)
		end
	end
end

function object:_Generate()
	for _, _slot in pairs(self._slots) do
		_slot.Object:Destroy()
	end

	self._slots = {}
	self._close_bubbles = {}
	self._generate_hash += 1
	self.Divider.Visible = false
	self:_UpdateLayouts()

	if not self._is_open then
		return
	end

	task.spawn(function()
		if self.CurrentTab == "Weapon" then
			self:_GenerateWeapons()
		else
			self:_GenerateCosmetics()
		end

		self:_UpdateLayouts()
	end)
end

function object:_Setup()
	for _, childName in pairs(v) do
		local child = self.TabsFrame:WaitForChild(childName)
		local v2 = childName
		child.MouseButton1Click:Connect(function()
			self:SetTab(v2)
		end)
		ButtonEffect:Add(child)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.SlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.LockedSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_BulkUpdateSearch()
	end)
	self:_Setup()
	self:SetTab("Weapon")
	ButtonEffect:Add(self.CloseButton)
end

return object._new()