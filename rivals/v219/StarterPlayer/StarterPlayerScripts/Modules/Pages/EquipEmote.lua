local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local EmoteController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("EmoteController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local CosmeticSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("CosmeticSlot"))
local EmoteWheel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("EmoteWheel"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.EmoteWheelSlotsFrame = self.PageFrame:WaitForChild("EmoteWheelSlots")
	self.EmoteSlotContainer = self.PageFrame:WaitForChild("EmoteSlotContainer")
	self.HidePartyDisplay = true
	self.EmoteWheel = EmoteWheel.new()
	self._emote_name = nil
	self._emote_slot = nil
	self._just_picked = nil
	self:_Init()
	return self
end

function object.GetDefaultElement(_)
	return nil
end

function object:SetEmoteName(emote_name)
	if self._emote_slot then
		self._emote_slot:Destroy()
		self._emote_slot = nil
	end

	self._emote_name = emote_name

	if self._emote_name then
		self._emote_slot = CosmeticSlot.new(self._emote_name)
		self._emote_slot:SetInteractable(false)
		self._emote_slot.Frame.Parent = self.EmoteSlotContainer
		self:_UpdateEmoteSlotPosition()
	end
end

function object:PickEmoteKey(p)
	if not self._is_open or self._just_picked then
		return
	end

	if not (p and self._emote_name) then
		self:CloseRequest()
		return
	end

	local v = PlayerDataController:Get("EquippedEmotes")[p]
	local v3

	if not (v and v.Name == self._emote_name) then
		v3 = self._emote_name
	end

	EmoteController:EquipEmote(p, v3)
end

function object:Open(...)
	Page.Open(self, ...)
	self.EmoteWheel:SetEnabled(true)
	self.EmoteWheel:StartInputs(true)
	self._just_picked = nil
end

function object:Close(...)
	self._just_picked = nil
	self.EmoteWheel:StopInputs()
	self.EmoteWheel:SetEnabled(false)
	Page.Close(self, ...)
end

function object:_UpdateEmoteSlotPosition()
	if not self._emote_slot then
		return
	end

	local lastHighlightedSlot = self.EmoteWheel:GetLastHighlightedSlot()
	local unit

	if lastHighlightedSlot then
		unit = (lastHighlightedSlot:GetContainerPosition() - (self.EmoteSlotContainer.AbsolutePosition + self.EmoteSlotContainer.AbsoluteSize / 2)).Unit
	else
		unit = Vector2.zero
	end

	self._emote_slot.Frame:TweenPosition(UDim2.new(0.5 + unit.X, 0, 0.5 + unit.Y, 0), "Out", "Quint", 0.25, true)
end

function object:_Setup()
	self.EmoteWheel.Frame.Parent = self.EmoteWheelSlotsFrame
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.EmoteWheel.EmoteKeyPicked:Connect(function(p)
		ButtonEffect:ClickSound()
		self:PickEmoteKey(p)
	end)
	self.EmoteWheel.EmoteWheelSlotHighlighted:Connect(function(_)
		self:_UpdateEmoteSlotPosition()
	end)
	self:_Setup()
	self:_UpdateEmoteSlotPosition()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()