local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local EmoteController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("EmoteController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local CosmeticSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("CosmeticSlot"))
local EmoteWheel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("EmoteWheel"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.EmoteWheelSlotsFrame = self.PageFrame:WaitForChild("EmoteWheelSlots")
	self.EmoteWheelSlotsButton = self.EmoteWheelSlotsFrame:WaitForChild("AllEmotes")
	self.EmoteWheelSlotsButtonMouseKeyboardKeybindFrame = self.EmoteWheelSlotsButton:WaitForChild("Inputs"):WaitForChild("MouseKeyboard"):WaitForChild("Keybind")
	self.EmoteWheelSlotsButtonGamepadKeybindFrame = self.EmoteWheelSlotsButton:WaitForChild("Inputs"):WaitForChild("Gamepad"):WaitForChild("Keybind")
	self.AllEmotesFrame = self.PageFrame:WaitForChild("AllEmotes")
	self.AllEmotesList = self.AllEmotesFrame:WaitForChild("List")
	self.AllEmotesContainer = self.AllEmotesList:WaitForChild("Container")
	self.AllEmotesLayout = self.AllEmotesContainer:WaitForChild("Layout")
	self.AllEmotesCentererFrame = self.AllEmotesContainer:WaitForChild("Centerer")
	self.AllEmotesHeaderFrame = self.AllEmotesContainer:WaitForChild("Header")
	self.AllEmotesHeaderIcon = self.AllEmotesHeaderFrame:WaitForChild("Icon")
	self.AllEmotesHeaderCloseButton = self.AllEmotesHeaderFrame:WaitForChild("Close")
	self.AllEmotesSlotsFrame = self.AllEmotesContainer:WaitForChild("Slots")
	self.AllEmotesSlotsContainer = self.AllEmotesSlotsFrame:WaitForChild("Container")
	self.AllEmotesSlotsLayout = self.AllEmotesSlotsContainer:WaitForChild("Layout")
	self.HidePartyDisplay = true
	self.EmoteWheel = EmoteWheel.new()
	self._all_emotes_open = false
	self._cosmetic_slots = {}
	self:_Init()
	return self
end

function object.GetDefaultElement(_)
	return nil
end

function object:SetAllEmotesOpen(p)
	self._all_emotes_open = self._is_open and p
	self.AllEmotesFrame.Visible = self._all_emotes_open
	self.EmoteWheelSlotsFrame.Visible = not self._all_emotes_open
	self:_VerifyEmoteWheel()
	self:_VerifyAllEmotes()

	if self._all_emotes_open and ControlsController.CurrentControls == "Gamepad" then
		GamepadService:EnableGamepadCursor(self.AllEmotesSlotsFrame)
	end
end

function object:PickEarly()
	if self._all_emotes_open then
		if ControlsController.CurrentControls == "MouseKeyboard" then
			self:_PickHoveredCosmeticSlot()
		end
	else
		self.EmoteWheel:FinishInputs()
	end
end

function object:Open(...)
	Page.Open(self, ...)
	self.EmoteWheelSlotsButtonMouseKeyboardKeybindFrame:AddTag("UIKeybindContainer")
	self.EmoteWheelSlotsButtonGamepadKeybindFrame:AddTag("UIKeybindContainer")
	self:SetAllEmotesOpen(false)
	local total = 0
	table.insert(self._open_connections, UserInputService.InputChanged:Connect(function(input, _)
		if self._all_emotes_open or ControlsController.CurrentControls ~= "MouseKeyboard" then
			return
		end

		total += input.Position.Z

		if math.abs(total) >= 1 then
			self:SetAllEmotesOpen(true)
		end
	end))
end

function object:_UpdateCenterer() end

function object:_Update()
	self.AllEmotesList.CanvasSize = UDim2.new(0, 0, 0, self.AllEmotesLayout.AbsoluteContentSize.Y)
	self.AllEmotesSlotsFrame.Size = UDim2.new(1, 0, 0, self.AllEmotesSlotsLayout.AbsoluteContentSize.Y)
end

function object:_PickByKey(p)
	if not self._is_open then
		return
	end

	EmoteController:UseEmote(p)
	self:CloseRequest()
end

function object:_PickByName(p)
	if not self._is_open then
		return
	end

	EmoteController:UseEmoteByName(p)
	self:CloseRequest()
end

function object:_PickHoveredCosmeticSlot()
	for _, _cosmetic_slot in pairs(self._cosmetic_slots) do
		if not UILibrary:IsMouseWithinBounds(_cosmetic_slot.Frame.AbsolutePosition, _cosmetic_slot.Frame.AbsoluteSize) then
			continue
		end

		self:_PickByName(_cosmetic_slot.Name)
		break
	end
end

function object:_VerifyAllEmotes()
	for _, _cosmetic_slot in pairs(self._cosmetic_slots) do
		_cosmetic_slot:Destroy()
	end

	self._cosmetic_slots = {}

	if not (self._is_open and self._all_emotes_open) then
		return
	end

	local v = {}

	for k, name in pairs(CosmeticLibrary.CosmeticsAlphabetized) do
		table.insert(v, {
			Name = name,
			AlphabeticalValue = k
		})
	end

	table.sort(v, function(a, b)
		local value = CosmeticLibrary.Rarities[CosmeticLibrary.Cosmetics[a.Name].Rarity].Value
		local value2 = CosmeticLibrary.Rarities[CosmeticLibrary.Cosmetics[b.Name].Rarity].Value

		if value == value2 then
			return a.AlphabeticalValue < b.AlphabeticalValue
		end

		return value2 < value
	end)

	for k, v2 in pairs(v) do
		local name = v2.Name

		if not (CosmeticLibrary.Cosmetics[name].Type == "Emote" and CosmeticLibrary:OwnsCosmetic(
			PlayerDataController:Get("CosmeticInventory"),
			name
		)) then
			continue
		end

		local v3 = CosmeticSlot.new(name)
		v3.Frame.LayoutOrder = k
		v3.Frame.Parent = self.AllEmotesSlotsContainer
		table.insert(self._cosmetic_slots, v3)
		local name2 = name
		v3.Frame.Button.MouseButton1Click:Connect(function()
			self:_PickByName(name2)
		end)
	end
end

function object:_VerifyEmoteWheel()
	local v = self._is_open and not self._all_emotes_open
	self.EmoteWheel:SetEnabled(v)

	if v then
		self.EmoteWheel:StartInputs()
	else
		self.EmoteWheel:StopInputs()
	end
end

function object:_Setup()
	self.AllEmotesHeaderIcon.Image = CosmeticLibrary.Types.Emote.Image
	self.EmoteWheel.Frame.Parent = self.EmoteWheelSlotsFrame
end

function object:_Init()
	self.AllEmotesHeaderCloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.EmoteWheelSlotsButton.MouseButton1Click:Connect(function()
		self:SetAllEmotesOpen(true)
	end)
	self.AllEmotesList:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	self.AllEmotesSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.AllEmotesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.AllEmotesList:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		self:_UpdateCenterer()
	end)
	self.AllEmotesList:GetPropertyChangedSignal("CanvasSize"):Connect(function()
		self:_UpdateCenterer()
	end)
	self.OpenChanged:Connect(function()
		self:_VerifyEmoteWheel()
	end)
	self.EmoteWheel.EmoteKeyPicked:Connect(function(p)
		self:_PickByKey(p)
	end)
	EmoteController.CanEmoteChanged:Connect(function()
		if not EmoteController:CanEmote(true) then
			self:CloseRequest()
		end
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.EmoteWheelSlotsButton)
	ButtonEffect:Add(self.AllEmotesHeaderCloseButton)
end

return object._new()